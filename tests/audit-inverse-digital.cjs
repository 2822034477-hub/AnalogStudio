'use strict';
// Independent audit. No HDL simulator is available: this does not certify generated HDL.
const assert=require('node:assert/strict');
const D=require('../digital-design.js'), I=require('../inverse-mixed.js');
let checks=0,seed=8313;
const rand=()=>((seed=(Math.imul(seed,1664525)+1013904223)>>>0)/4294967296);
const eq=(a,b,m)=>{checks++;assert.deepEqual(a,b,m)};
const close=(a,b,t=1e-8)=>{checks++;assert(Math.abs(a-b)<=t*Math.max(1,Math.abs(b)),`${a} != ${b}`)};
const cmul=(a,b)=>({re:a.re*b.re-a.im*b.im,im:a.re*b.im+a.im*b.re});
const cdiv=(a,b)=>{const r=Math.hypot(b.re,b.im);return {re:(a.re*(b.re/r)+a.im*(b.im/r))/r,im:(a.im*(b.re/r)-a.re*(b.im/r))/r}};
const real=re=>({re,im:0,pair:false});
function zpk(target,w){let v={re:target.gain,im:0};for(const r of I.expanded(target.zeros))v=cmul(v,{re:-r.re,im:w-r.im});for(const r of I.expanded(target.poles))v=cdiv(v,{re:-r.re,im:w-r.im});return v;}
// Independent scalar integer recurrence uses division/remainders rather than shifts.
function fixedOracle(m,x){const f=m.fixed,S=2**f.coefficientFraction,round=v=>Math.sign(v)*Math.floor(Math.abs(v)+.5),B=m.b.map(v=>BigInt(round(v*S))),A=m.a.map(v=>BigInt(round(v*S))),s=BigInt(S),lo=-(1n<<BigInt(f.outputBits-1)),hi=-lo-1n,y=[];
for(let n=0;n<x.length;n++){let acc=0n;for(let k=0;k<B.length;k++)if(n>=k)acc+=B[k]*BigInt(x[n-k]);for(let k=1;k<A.length;k++)if(n>=k)acc-=A[k]*BigInt(y[n-k]);let q=acc/s,r=acc%s;if(f.rounding==='floor'&&r<0n)q--;if(f.rounding==='nearest'&&2n*(r<0n?-r:r)>=s&&r!==0n)q+=r<0n?-1n:1n;y.push(Number(q<lo?lo:q>hi?hi:q));}return y;}
for(let trial=0;trial<300;trial++){
const ib=8+trial%17,ob=8+(trial*7)%17,cb=8+(trial*11)%23,cf=trial%(cb-1),m=D.create({b:Array.from({length:1+trial%3},()=>3.8*rand()-1.9),a:[1,-1.2*rand(),.4*rand()],fixed:{inputBits:ib,outputBits:ob,coefficientBits:cb,coefficientFraction:cf,dataFraction:0,accumulatorBits:64,rounding:trial%2?'nearest':'floor'}}),x=[-(2**(ib-1)),2**(ib-1)-1,...Array.from({length:128},()=>Math.floor(rand()*2**ib)-2**(ib-1))];
eq(D.runFixed(m,x).raw,fixedOracle(m,x));const h=D.generateVerilog(m);eq(h.includes('out_valid <= in_valid;'),true);eq(h.includes('ext = {acc[63], acc};'),true);
}
// Generated-source contract checks, not HDL compilation.
const fixture=D.create(D.presets.lowpass);
for(const moduleName of ['module','wire','logic','final','ref','var','timeunit','checker','randcase']){checks++;assert.throws(()=>D.generateVerilog(fixture,{moduleName}));}
const tb=D.generateTestbench(fixture);eq((tb.match(/Mismatch /g)||[]).length,128);eq(tb.includes('Mismatch post-reset sample 63:'),true);eq(tb.includes('Zero means this filter/vector pair does not test output clipping.'),true);
const collision=D.generateTestbench(fixture,{moduleName:'digital_filter_tb'});eq(collision.includes('module digital_filter_tb_tb;'),true);
const longName='a'.repeat(64),longTB=D.generateTestbench(fixture,{moduleName:longName}),tbId=/^module (\w+);/m.exec(longTB)[1];eq(tbId!==longName,true);eq(tbId.length<=64,true);
const clipping=D.create({b:[3],a:[1],fixed:{coefficientBits:8,coefficientFraction:1,inputBits:8,outputBits:8,dataFraction:0,accumulatorBits:20}});eq(/Golden vectors exercise [1-9]\d* saturated outputs/.test(D.generateTestbench(clipping)),true);
// Complex-factor oracle independently verifies s/z mapping, including conjugate pairs,
// repeated poles, negative gains, direct feedthrough and cancellation.
for(let trial=0;trial<120;trial++){
const poles=trial%3===0?[{re:-2-rand()*10,im:2+rand()*10,pair:true}]:[real(-2-rand()*10),real(-2-rand()*10)];
const zeros=trial%4===0?[...poles]:trial%4===1?[real(-rand()*10)]:[];
const target={poles,zeros,gain:(trial%2?-1:1)*(1+rand()*10)},T=.02+rand()*.03,b=I.bilinear(target,T);
for(const omega of [.001,.01,.1,.5,1,2,3]){const w=2/T*Math.tan(omega/2),expected=zpk(target,w),actual=I.digitalResponse(b,omega),analog=I.evaluate(I.transfer(target),w);close(actual.re,expected.re);close(actual.im,expected.im);close(analog.re,expected.re);close(analog.im,expected.im);}
}
// Exact inverse families; independent ZPK and analytic topology checks.
for(let trial=0;trial<60;trial++){
const w=10**(-1+5*rand()),Q=.5+20*rand(),K=3-1/Q,re=-w/(2*Q),im=Math.sqrt(w*w-re*re),target={zeros:[],poles:[{re,im,pair:true}],gain:K*w*w};if(target.gain>1e12)continue;
const c=I.realize(target).candidates[0];eq(c.kind,'sallen-key-lowpass');const v=Object.fromEntries(c.components.map(x=>[x.name,x.value]));close(v.R1,v.R2);close(v.C1,v.C2);close(1+(v.Rf||0)/(v.Rg||1),K);
for(const factor of [.001,.1,1,10,1000]){const frequency=w*factor,t=zpk(target,frequency),r=I.circuitResponse(c.circuit,frequency);close(r.re,t.re,1e-7);close(r.im,t.im,1e-7);}
}
// Cascade time-domain associativity against separate analog and digital recurrences.
for(let trial=0;trial<60;trial++){
const T=.02,target={zeros:trial%2?[real(-3)]:[],poles:[real(-2),real(-5)],gain:10},digital={b:[.2+rand()*.2,.1,.05],a:[1,-.6,.08]},h=I.cascade(target,digital,T),ha=I.bilinear(target,T),x=Array.from({length:300},(_,n)=>Math.sin(.23*n)+.3*Math.cos(.71*n));
const sequential=D.run(D.fromCoefficients(digital),I.simulate(ha,x)),combined=I.simulate(h,x);combined.forEach((v,n)=>close(v,sequential[n],1e-8));
}
// Proper unstable and marginal mappings are structural, never silently stabilized.
const unstable=I.bilinear({zeros:[],poles:[real(1)],gain:1},.1);close(-unstable.a[1],21/19);eq(-unstable.a[1]>1,true);
const integrator=I.bilinear({zeros:[],poles:[real(0)],gain:1},.1);eq(integrator.a,[1,-1]);close(integrator.b[0],.05);eq(I.simulate(integrator,[1,1,1]).map(v=>Number(v.toFixed(5))),[.05,.15,.25]);
// Regression cases must either be accurately represented or explicitly rejected.
for(const [n,p,g,T] of [[4,-1000,1e12,1e-9],[4,-1,1,.0001],[8,-10,1e8,.0001]]){
const target={zeros:[],poles:Array.from({length:n},()=>real(p)),gain:g};let b;try{b=I.bilinear(target,T);}catch(e){checks++;assert(/condition|precision|numeric|stable section/i.test(e.message));continue;}
const omega=2*Math.atan(-p*T/2),expected=zpk(target,-p),actual=I.digitalResponse(b,omega);close(actual.re,expected.re,1e-5);close(actual.im,expected.im,1e-5);
}
checks++;assert.throws(()=>I.validate({...I.defaults(),digital:{b:[1],a:[Number.MIN_VALUE]}}));
console.log(`PASS independent inverse/digital audit: ${checks} checks; HDL source inspected, never compiled/simulated.`);
