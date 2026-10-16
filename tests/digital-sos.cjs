'use strict';
const assert=require('node:assert/strict'),D=require('../digital-design'),S=require('../digital-sos'),oracle=require('./sos-golden.cjs');
let checks=0;const near=(a,b,tol=1e-8)=>{assert(Math.abs(a-b)<tol*Math.max(1,Math.abs(a),Math.abs(b)),`${a} != ${b}`);checks++;};
const cmul=(a,b)=>({re:a.re*b.re-a.im*b.im,im:a.im*b.re+a.re*b.im});
const cdiv=(a,b)=>{const m=b.re*b.re+b.im*b.im;return {re:(a.re*b.re+a.im*b.im)/m,im:(a.im*b.re-a.re*b.im)/m};};
function evalFactors(z,f,fs){const w=2*Math.PI*f/fs,v={re:Math.cos(w),im:-Math.sin(w)},one={re:1,im:0};let h={re:z.gain,im:0};for(const kind of ['zeros','poles'])for(const r of z[kind])for(const sign of r.im?[1,-1]:[1]){const k=cmul({re:r.re,im:r.im*sign},v),factor={re:one.re-k.re,im:-k.im};h=kind==='zeros'?cmul(h,factor):cdiv(h,factor);}return cmul(h,{re:Math.cos(w*z.delaySamples),im:-Math.sin(w*z.delaySamples)});}
function check(m,label){
 const z=D.factorRoots(m),q=D.quantize(m),sos=D.toSOS(m);assert(q.sections.length<=4);assert.equal(q.pipelineDelay,q.sections.reduce((n,s)=>n+Math.max(1,Math.max(s.a.length,s.b.length)-1),0)-1);checks+=2;
 for(let i=0;i<=128;i++){const f=m.sampleRate*i/256,h=evalFactors(z,f,m.sampleRate),actual=D.evaluate(m,f);near(h.re,actual.re,2e-7);near(h.im,actual.im,2e-7);let h2={re:1,im:0};for(const s of sos.sections){const h=D.evaluate({...m,b:s.b,a:s.a,factors:undefined},f);h2=cmul(h2,h);}const w=2*Math.PI*f/m.sampleRate;h2=cmul(h2,{re:Math.cos(w*sos.delaySamples),im:-Math.sin(w*sos.delaySamples)});near(h2.re,actual.re,2e-7);near(h2.im,actual.im,2e-7);}
 // Independent coefficient rounding checks, followed by a clocked register-level integer oracle.
 sos.sections.forEach((s,i)=>{const round=x=>Math.sign(x)*Math.floor(Math.abs(x)*q.scale+.5)||0;assert.deepEqual(q.sections[i].b,s.b.map(round));assert.deepEqual(q.sections[i].a,[q.scale,...s.a.slice(1).map(round)]);checks+=2;});
 let seed=0x45f712,max=2**(m.fixed.inputBits-1)-1,min=-max-1;
 const inputs=[max,min,0,1,-1,...Array.from({length:507},()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%(max-min+1)+min;}),...Array(q.latency+10).fill(0)];
 const expected=oracle(q,inputs,m.fixed.rounding),actual=D.runFixed(m,inputs);assert.deepEqual(actual.clockRaw,expected.raw,label);checks+=inputs.length;
 const minAcc=-(1n<<BigInt(m.fixed.accumulatorBits-1)),maxAcc=-minAcc-1n;assert(expected.accumulators.every(a=>a.every(v=>BigInt(v)>=minAcc&&BigInt(v)<=maxAcc)));checks++;
 const rtl=D.generateVerilog(m);assert(!/in_valid|out_valid|ready|enable|posedge rst_n|negedge rst_n/.test(rtl));assert.equal((rtl.match(/^  input /gm)||[]).length,3);assert.equal((rtl.match(/\boutput reg /g)||[]).length,1);assert(rtl.includes('parameter integer IN_WIDTH'));assert(rtl.includes(`Sample clock: ${m.sampleRate} Hz`));checks+=5;
 const snap=D.serialize(m);assert.deepEqual(D.load(snap),m);checks++;return q;
}
for(const order of [3,4,5,6,7,8])for(const rounding of ['nearest','floor']){
 const poles=Array.from({length:Math.floor(order/2)},(_,i)=>({re:.2+.1*i,im:.11+.047*i}));if(order%2)poles.push({re:-.35,im:0});
 const zeros=Array.from({length:Math.floor(order/2)},(_,i)=>({re:-.25+.06*i,im:.22+.05*i}));if(order%2)zeros.push({re:.14,im:0});
 const m=D.create({poles,zeros,gain:rounding==='nearest'?.013:-.013,sampleRate:32000,fixed:{sectionBits:20,accumulatorBits:44,rounding}});check(m,'order '+order+' '+rounding);
 const tf={...m};delete tf.factors;const recovered=D.factorRoots(tf);const rebuild=D.create({...recovered,fixed:m.fixed,sampleRate:m.sampleRate});m.a.forEach((x,i)=>near(x,rebuild.a[i]));m.b.forEach((x,i)=>near(x,rebuild.b[i]));
}
// Floating high-order SOS time response independently compared with the original recurrence.
for(const key of ['sos4','sos6','sos8']){const m=D.create(D.presets[key]),inputs=[1,...Array(255).fill(0)],expected=[];inputs.forEach((x,n)=>{let y=0;m.b.forEach((b,k)=>y+=b*(inputs[n-k]||0));m.a.slice(1).forEach((a,k)=>y-=a*(expected[n-k-1]||0));expected.push(y);});D.run(m,inputs).forEach((y,i)=>near(y,expected[i],1e-9));}
for(const delaySamples of [1,3,8])check(D.create({poles:[],gain:-.75,delaySamples}),'delay '+delaySamples);
check(D.create({poles:[{re:.4,im:.2},{re:.6,im:.15}],zeros:[.3],gain:.01,delaySamples:3,fixed:{sectionBits:24,accumulatorBits:48}}),'SOS delay');
check(D.create({poles:[.5,.5,.5,.5,.5,.5,.5,.5],gain:.001}),'ZPK repeated order 8');
check(D.create({poles:[{re:.4,im:.2},{re:.4,im:.2},{re:.4,im:.2}],gain:.01}),'repeated pairs');
check(D.create({poles:[.4,.6,.7,.8],gain:0}),'zero transfer');
assert.throws(()=>D.create({poles:Array(9).fill(.2)}));assert.throws(()=>D.create({poles:[],zeros:Array(7).fill(.2),delaySamples:2}));
assert.throws(()=>D.fromCoefficients({b:[1],a:Array(10).fill(1)}));
const repeated=D.create({poles:Array(8).fill(.5),gain:.001});delete repeated.factors;assert.throws(()=>D.factorRoots(repeated),/重根|收敛|校验/);
assert.throws(()=>D.create({b:[1,0,0,.1],a:[1],factors:{zeros:[],poles:[]}}));
assert.throws(()=>D.quantize(D.create({poles:[.4,.5,.6,.7],gain:1e-30})),/全零/);
assert.throws(()=>D.quantize(D.create({poles:[.4,.5,.6,.7],gain:1,fixed:{sectionBits:24,accumulatorBits:30}})),/Accumulator/);
const legacy=D.create({gain:1,fixed:{inputBits:12,outputBits:16,dataFraction:8}});assert.deepEqual(D.load(D.serialize(legacy)),legacy);assert.throws(()=>D.generateVerilog(legacy),/同位宽/);
const high=D.create({poles:[.2,.3,.4,.5,.6,.7],gain:.002,fixed:{coefficientFraction:3,coefficientBits:8,sectionBits:16}});assert.throws(()=>D.quantize(high),/全零/);
const edge=D.create({poles:[{re:.995,im:.01},{re:.6,im:.2}],gain:1,fixed:{coefficientFraction:6,coefficientBits:18}});const qe=D.quantize(edge);assert(!D.analysis(qe.model).stable);checks+=9;
const narrow=D.create({poles:Array(8).fill(.99),gain:1e-8});near(D.evaluate(narrow,0).re,1e8,1e-10);
console.log(`PASS SOS: ${checks} checks, order 3–8 TF/ZPK reconstruction, independent BigInt clock oracle, signs/rounding/section widths/accumulator bounds, delays, repeated roots, reset-ready zero state and four-port source contract. HDL execution is separate.`);
