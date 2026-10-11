'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),cp=require('node:child_process'),os=require('node:os'),path=require('node:path');
const D=require('../digital-design.js');let assertions=0;
const close=(a,b,tol=1e-10)=>{assert(Math.abs(a-b)<=tol,`${a} differs from ${b}`);assertions++;};
const fail=f=>{assert.throws(f);assertions++;};
const low=D.create(D.presets.lowpass);close(D.evaluate(low,0).re,1);close(D.evaluate(low,24000).re,1/9);close(D.analysis(low).zeros[0].re,0);assert(D.analysis(low).stable);assertions++;
D.step(low,128).values.forEach((v,n)=>close(v,1-.8**(n+1)));
const delay=D.create(D.presets.delay);assert.deepEqual(D.run(delay,[1,2,3,4]),[0,1,2,3]);close(D.evaluate(delay,12000).phase,-90);close(D.analysis(delay).poles[0].re,0);assertions+=2;
const fir=D.create(D.presets.fir);assert.deepEqual(D.step(fir,5).values,[.25,.75,1,1,1]);assertions++;D.analysis(fir).zeros.forEach(r=>close(r.re,-1));
const notch=D.create(D.presets.notch);close(D.evaluate(notch,6000).magnitude,0,1e-12);close(D.evaluate(notch,0).magnitude,1);close(D.analysis(notch).radius,.95);assertions++;
assert.deepEqual(D.create({zeros:'-1\n-1',poles:'',gain:.25}).b,[.25,.5,.25]);assert.deepEqual(D.create({zeros:'0 .5',poles:'',gain:1}).b,[1,0,.25]);assertions+=2;
const singular=D.create({poles:[1],gain:1});assert(D.evaluate(singular,0).singular);assert(!D.analysis(singular).stable);assert(!D.analysis(D.create(D.presets.unstable)).stable);assertions+=3;
const normalized=D.fromCoefficients({b:[2],a:[2,-1],sampleRate:10});assert.deepEqual(normalized.b,[1]);assert.deepEqual(normalized.a,[1,-.5]);assertions+=2;
for(const f of [()=>D.create({poles:'evil()'}),()=>D.create({poles:'0 .2\n.4'}),()=>D.create({zeros:[1,2],delaySamples:1}),()=>D.create({gain:Infinity}),()=>D.create({sampleRate:0}),()=>D.create({b:[1],a:[0]}),()=>D.create({b:[1,2,3,4],a:[1]}),()=>D.evaluate(low,-1),()=>D.evaluate(low,24001),()=>D.step(low,1),()=>D.step(low,2049),()=>D.create({fixed:{coefficientBits:31}}),()=>D.quantize({...low,fixed:{...low.fixed,accumulatorBits:20}}),()=>D.quantize(D.create({gain:100})),()=>D.generateVerilog(low,{moduleName:'x);evil'}),()=>D.load({format:'bad'}),()=>D.validate({...D.defaults(),ui:{b:3}})])fail(f);
assert.deepEqual(D.load(D.serialize(notch)),notch);assertions++;
// Independent Number-based reference is exact in the deliberately small test widths.
function golden(m,x){const q=D.quantize(m),f=m.fixed,y=[];for(let n=0;n<x.length;n++){let acc=0;for(let k=0;k<q.b.length;k++)acc+=q.b[k]*(x[n-k]??0);for(let k=1;k<q.a.length;k++)acc-=q.a[k]*(y[n-k]??0);let v;if(f.rounding==='floor')v=Math.floor(acc/q.scale);else v=Math.sign(acc)*Math.floor(Math.abs(acc)/q.scale+.5);y.push(Math.max(-(2**(f.outputBits-1)),Math.min(2**(f.outputBits-1)-1,v))||0);}return y;}
let seed=42;const random=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed/2**32;};
for(let trial=0;trial<100;trial++){const m=D.create({b:Array.from({length:1+trial%3},()=>random()*1.8-.9),a:trial%2?[1,-.7,.12]:[1,-.3],fixed:{coefficientBits:12,coefficientFraction:8,inputBits:10,outputBits:10,dataFraction:7,accumulatorBits:28,rounding:trial%2?'nearest':'floor'}});const x=Array.from({length:96},()=>Math.floor(random()*1024)-512);assert.deepEqual(D.runFixed(m,x).raw,golden(m,x));assertions++;const q=D.quantize(m).model;const ys=D.run(q,x.map(v=>v/128));assert(ys.every(Number.isFinite));assertions++;}
const tiny=D.create({b:[.5],a:[1],fixed:{coefficientBits:8,coefficientFraction:1,inputBits:8,outputBits:8,dataFraction:0,accumulatorBits:20}});assert.deepEqual(D.runFixed(tiny,[1,-1,3,-3]).raw,[1,-1,2,-2]);assertions++;
const floor={...tiny,fixed:{...tiny.fixed,rounding:'floor'}};assert.deepEqual(D.runFixed(floor,[1,-1,3,-3]).raw,[0,-1,1,-2]);assertions++;
const saturate=D.create({b:[3],a:[1],fixed:{coefficientBits:8,coefficientFraction:1,inputBits:8,outputBits:8,dataFraction:0,accumulatorBits:20}});assert.deepEqual(D.runFixed(saturate,[127,-128]).raw,[127,-128]);assert.equal(D.runFixed(saturate,[127,-128]).saturationCount,2);assertions+=2;
fail(()=>D.runFixed(tiny,[128]));fail(()=>D.runFixed(tiny,[1.2]));
// Close agreement on bounded lowpass is meaningful; clipping cases are separately tested above.
const floating=D.step(low,256).values,fixed=D.step(low,256,{quantized:true});assert(Math.max(...floating.map((x,i)=>Math.abs(x-fixed.values[i])))<.001);assert.equal(fixed.saturationCount,0);assertions+=2;
// Independent impulse-DFT comparison checks z^-1 signs and discrete frequency scaling.
const band=D.create({b:[.2,-.1,.05],a:[1,-.7,.15],sampleRate:32000});const impulse=D.run(band,[1,...Array(1023).fill(0)]);for(const f of [0,123,1000,8000,16000]){const w=2*Math.PI*f/32000;const real=impulse.reduce((s,x,n)=>s+x*Math.cos(w*n),0),imag=impulse.reduce((s,x,n)=>s-x*Math.sin(w*n),0),v=D.evaluate(band,f);close(v.re,real);close(v.im,imag);}
const edge=D.create({poles:[.99999],gain:.125,fixed:{coefficientBits:8,coefficientFraction:6,inputBits:8,outputBits:8,dataFraction:4,accumulatorBits:20}});assert(D.analysis(edge).stable);assert(!D.analysis(D.quantize(edge).model).stable);assertions+=2;
const huge=D.validate({...D.defaults(),model:{...D.defaults().model,fixed:{...D.DEFAULT_FIXED,ignored:'drop unknown setting'}}});assert(!('ignored' in huge.model.fixed));assertions++;fail(()=>D.create({fixed:'bad'}));
// Wide configurations exercise BigInt accumulators beyond Number's exact integer range.
const wide=D.create({b:[1.75,-.5,.25],a:[1,-.25,.1],fixed:{coefficientBits:30,coefficientFraction:27,inputBits:24,outputBits:24,dataFraction:20,accumulatorBits:58}});const wideRun=D.runFixed(wide,Array(100).fill(8388607));assert(wideRun.raw.every(Number.isSafeInteger));assertions++;
const verilog=D.generateVerilog(notch),testbench=D.generateTestbench(notch);assert(verilog.includes('module digital_filter('));assert(testbench.includes('Mismatch sample 63'));assert(verilog.includes('out_valid <= in_valid'));assert(verilog.includes('No FPGA timing'));assertions+=4;
for(const moduleName of ['module','wire','reg','always','logic','final','ref','var','timeunit','checker','nettype','accept_on','until_with'])fail(()=>D.generateVerilog(low,{moduleName}));
assert(D.generateTestbench(low,{moduleName:'digital_filter_tb'}).includes('module digital_filter_tb_tb;'));assertions++;
assert(D.generateTestbench(low,{moduleName:'custom_dut',testbenchName:'custom_tb'}).includes('module custom_tb;'));assertions++;
fail(()=>D.generateTestbench(low,{moduleName:'same',testbenchName:'same'}));fail(()=>D.generateTestbench(low,{testbenchName:'module'}));
assert(testbench.includes('Mismatch post-reset sample 63'));assert(testbench.includes('Golden vector saturation count per run:'));assertions+=2;
for(const moduleName of ['x'.repeat(64),'x'.repeat(61)+'_tb']){const tb=D.generateTestbench(low,{moduleName});const name=tb.match(/module (\w+);/)[1];assert(name.length<=64&&name!==moduleName);assertions++;}
let simulator='not installed';try{cp.execFileSync('iverilog',['-V'],{stdio:'ignore'});const dir=fs.mkdtempSync(path.join(os.tmpdir(),'digital-hdl-'));for(const [name,m] of Object.entries({low,notch,fir,delay,tiny,floor,saturate,wide})){fs.writeFileSync(path.join(dir,'filter.v'),D.generateVerilog(m));fs.writeFileSync(path.join(dir,'tb.sv'),D.generateTestbench(m));cp.execFileSync('iverilog',['-g2012','-s','digital_filter_tb','-o',path.join(dir,'sim'),path.join(dir,'filter.v'),path.join(dir,'tb.sv')]);const output=cp.execFileSync('vvp',[path.join(dir,'sim')],{encoding:'utf8'});assert(output.includes('PASS:'));assertions++;}simulator='passed 8 models';}catch(e){if(e.code!=='ENOENT')throw e;}
console.log(`PASS digital math/fixed-point: ${assertions} assertions; HDL simulator: ${simulator}. Generated HDL is not hardware-verified.`);
