'use strict';
const assert=require('node:assert/strict'),D=require('../digital-design'),oracle=require('./sos-golden.cjs');
let checks=0;
const near=(a,b,t=1e-9)=>{assert(Math.abs(a-b)<=t*Math.max(1,Math.abs(a),Math.abs(b)),`${a} != ${b}`);checks++;};
const fixed={inputBits:16,outputBits:16,dataFraction:10,coefficientBits:18,coefficientFraction:15,sectionBits:20,accumulatorBits:44};
const models={fo:D.create({b:[.5],a:[1,-.25],fixed}),so:D.create({b:[.5],a:[1,-.5,.125],fixed}),gain:D.create({gain:.5,poles:[],fixed}),delay:D.create({gain:.5,poles:[],delaySamples:3,fixed}),so_delay:D.create({gain:.5,poles:[{re:.4,im:.2}],delaySamples:3,fixed}),odd3:D.create({poles:[.25,{re:.4,im:.2}],gain:.03,fixed}),odd5:D.create({poles:[.25,{re:.4,im:.2},{re:.6,im:.1}],gain:.03,fixed}),zero:D.create({zeros:[{re:.3,im:.2}],poles:[.5],gain:0,delaySamples:2,fixed}),negative:D.create({gain:-.5,poles:[.2],delaySamples:1,fixed}),clipping:D.create({gain:3,poles:[.5],fixed:{...fixed,inputBits:8,outputBits:8,dataFraction:6,sectionBits:8}})};
models.collapsed_so=D.create({b:[.5],a:[1,-.25,1e-7],fixed});
models.quantized_leading_zero=D.create({b:[1e-7,.5],a:[1,-.25],fixed});
for(const n of [4,6,8])models['sos'+n]=D.create({...D.presets['sos'+n],fixed});
// Independent floating clock machine: every section reads the preceding OLD
// output at an edge, and SO exposes old y1. No post-hoc zero padding here.
function floatingClock(plan,input){
 const delay=Array(plan.delaySamples).fill(0),state=plan.sections.map(()=>({x:[0,0],y:[0,0],out:0}));
 return input.map(x=>{
  let v=delay.length?delay.at(-1):x;if(delay.length){delay.pop();delay.unshift(x);}
  plan.sections.forEach((s,i)=>{const r=state[i],previousOut=r.out,oldY=r.y[0];let y=s.b.reduce((sum,b,k)=>sum+b*(k?r.x[k-1]:v),0);s.a.slice(1).forEach((a,k)=>y-=a*r.y[k]);r.x=[v,r.x[0]];r.y=[y,oldY];r.out=s.latency===2?oldY:y;v=previousOut;});
  return state.at(-1).out;
 });
}
const complex=c=>({re:c,im:0}),mul=(a,b)=>({re:a.re*b.re-a.im*b.im,im:a.re*b.im+a.im*b.re});
function transfer(b,a,w){const sum=c=>c.reduce((s,x,k)=>({re:s.re+x*Math.cos(w*k),im:s.im-x*Math.sin(w*k)}),complex(0)),n=sum(b),d=sum(a),q=d.re*d.re+d.im*d.im;return {re:(n.re*d.re+n.im*d.im)/q,im:(n.im*d.re-n.re*d.im)/q};}
for(const [name,m] of Object.entries(models)){
 const count=96,amplitude=.5,plan=D.toSOS(m),q=D.quantize(m),snapshot=JSON.stringify(m),rtl=D.generateVerilog(m);
 const floating=D.step(m,count,{amplitude}),fixedStep=D.step(m,count,{amplitude,quantized:true});
 const expected=floatingClock(plan,Array(count).fill(amplitude));
 floating.clockValues.forEach((v,n)=>near(v,expected[n]));
 const fixedExpected=oracle(q,Array(count).fill(amplitude*2**m.fixed.dataFraction),m.fixed.rounding).raw;
 assert.deepEqual(fixedStep.clockValues,fixedExpected.map(x=>x/2**m.fixed.dataFraction));checks++;
 assert.equal(floating.pipelineDelay,q.pipelineDelay);assert.equal(floating.latency,q.latency);checks+=2;
 for(const [index,point] of floating.clockPoints.entries()){near(point.y,expected[index]);near(point.t,index/m.sampleRate);assert.equal(point.n,index);checks++;}
 if(name!=='zero'){assert.equal(floating.clockValues.findIndex(x=>x!==0),q.edgeOffset);checks++;}
 for(const f of [0,m.sampleRate/32,m.sampleRate*.1234,m.sampleRate/4,m.sampleRate*.499]){
  const w=2*Math.PI*f/m.sampleRate,delay={re:Math.cos(w*q.pipelineDelay),im:-Math.sin(w*q.pipelineDelay)};
  for(const quantized of [false,true]){
   const h=quantized?transfer(q.model.b,q.model.a,w):transfer(m.b,m.a,w),want=mul(h,delay),got=D.evaluateImplementation(m,f,{quantized}),base=D.evaluate(quantized?q.model:m,f);
   near(got.re,want.re);near(got.im,want.im);near(got.magnitude,base.magnitude);
   if(name==='zero')assert(Number.isNaN(got.phase));else near(got.phase,Math.atan2(want.im,want.re)*180/Math.PI,1e-8);
   checks++;
  }
 }
 assert.equal(JSON.stringify(m),snapshot);assert.equal(D.generateVerilog(m),rtl);checks+=2;
}
// Pure delay has no extra hardware offset; explicit delay belongs to H(z) once.
assert.equal(D.toSOS(models.delay).pipelineDelay,0);
near(D.evaluateImplementation(models.delay,models.delay.sampleRate/32,{quantized:false}).phase,-360*3/32);
// Saturation changes the actual fixed step, not the linear frequency model.
const clipped=D.step(models.clipping,96,{quantized:true});assert(clipped.saturationCount>0);assert(clipped.clockValues.at(-1)<D.step(models.clipping,96).clockValues.at(-1));
const badFixed=D.create({b:[.5],a:[1,-.5,.125],fixed:{accumulatorBits:20}});assert.throws(()=>D.quantize(badFixed));assert(Number.isFinite(D.evaluateImplementation(badFixed,1000,{quantized:false}).phase));assert.equal(D.step(badFixed,16).pipelineDelay,1);
console.log(`PASS two-curve timing: ${checks} comparisons/assertions, 15 models, independent per-edge floating machine and BigInt fixed oracle, intrinsic/explicit/implementation phase separation, FO/SO/odd/cascade/gain/zero/saturation; unchanged RTL bytes.`);
