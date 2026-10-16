'use strict';
// Independent clock-by-clock oracle: quotient/remainder rounding, explicit register old/new state.
// No DigitalDesign import and no reuse of its shifts or cascade runner.
module.exports=function golden(spec,inputs,rounding='nearest'){
 const stages=spec.sections.map(s=>({x:Array(s.b.length-1).fill(0n),y:Array(s.a.length-1).fill(0n),out:0n,pending:Array(Math.max(0,Math.max(s.a.length,s.b.length)-2)).fill(0n)}));
 const delay=Array(spec.delaySamples).fill(0n),scale=BigInt(spec.scale),samples=[],saturation=Array(stages.length).fill(0),accumulators=[];
 for(const input of inputs){
  const old=stages.map(s=>s.out),stageAcc=[];
  spec.sections.forEach((s,i)=>{
   const state=stages[i],value=i?old[i-1]:delay.length?delay.at(-1):BigInt(input),xs=[value,...state.x];
   let acc=s.b.reduce((v,c,k)=>v+BigInt(c)*xs[k],0n)-s.a.slice(1).reduce((v,c,k)=>v+BigInt(c)*state.y[k],0n);
   let output=acc/scale,remainder=acc%scale;
   if(rounding==='floor'&&remainder<0n)output-=1n;
   else if(rounding==='nearest'&&2n*(remainder<0n?-remainder:remainder)>=scale&&remainder!==0n)output+=remainder<0n?-1n:1n;
   const limit=2n**BigInt(s.outputBits-1),clipped=output<-limit?-limit:output>limit-1n?limit-1n:output;
   if(clipped!==output)saturation[i]++;state.x=xs.slice(0,state.x.length);state.y=[clipped,...state.y].slice(0,state.y.length);state.out=state.pending.length?state.pending.shift():clipped;if(Math.max(s.a.length,s.b.length)>2)state.pending.push(clipped);stageAcc.push(acc.toString());
  });
  if(delay.length){delay.unshift(BigInt(input));delay.pop();}samples.push(Number(stages.at(-1).out));accumulators.push(stageAcc);
 }
 return {raw:samples,saturation,accumulators};
};
