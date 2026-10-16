/* Finite-window step observations and advisory widths; never changes the HDL contract. */
(function(root){
'use strict';
const S=root.DigitalSOS||(typeof require==='function'?require('./digital-sos.js'):null);
const absMax=xs=>xs.reduce((p,x)=>Math.max(p,Math.abs(x)),0);
const sum=xs=>xs.reduce((a,b)=>a+b,0);
const away=x=>Math.sign(x)*Math.floor(Math.abs(x)+.5);
function bits(peak,fraction,marginDb=0){
 if(!Number.isFinite(peak)||peak<0)throw Error('Peak must be finite and nonnegative.');
 // One extra raw LSB covers the positive signed endpoint and observation rounding.
 return Math.max(fraction+2,1+Math.ceil(Math.log2(Math.ceil(peak*2**fraction*10**(marginDb/20))+1)));
}
function stable(sections){return sections.every(s=>S.roots(s.a).every(r=>Math.hypot(r.re,r.im)<1-1e-12));}
function trace(sections,delay,amplitude,count,fraction,rounded=false,rounding='nearest'){
 let signal=Array.from({length:count},(_,n)=>n<delay?0:amplitude),expected=amplitude;
 const stats=[];
 for(const s of sections){
  const output=[],acc=[],terms=[];let dcDen=sum(s.a);
  expected=dcDen===0?NaN:expected*sum(s.b)/dcDen;
  for(let n=0;n<count;n++){
   let v=0,t=0;
   s.b.forEach((b,k)=>{const p=b*(n>=k?signal[n-k]:0);v+=p;t+=Math.abs(p);});
   s.a.slice(1).forEach((a,k)=>{const p=a*(n>k?output[n-k-1]:0);v-=p;t+=Math.abs(p);});
   if(!Number.isFinite(v)||Math.abs(v)>1e100)throw Error('观察窗口内响应发散或超出数值范围；不提供位宽建议。');
   acc.push(v);terms.push(t);
   output.push(rounded?(rounding==='nearest'?away(v*2**fraction):Math.floor(v*2**fraction))/2**fraction:v);
  }
  const peak=absMax(output),tail=output.slice(-Math.max(8,Math.ceil(count/8))),tolerance=Math.max(Math.abs(expected)*.005,peak*.0001,2**(-fraction)*2);
  // Insist on a real observation window; a zero plateau before a long delay is not convergence.
  const settled=count>=32&&count>delay+16&&Number.isFinite(expected)&&tail.every(v=>Math.abs(v-expected)<=tolerance);
  stats.push({inputPeak:absMax(signal),outputPeak:peak,accumulatorPeak:absMax(acc),sumProductsPeak:absMax(terms),expected,settled,values:output});
  signal=output;
 }
 return stats;
}
function overshoot(values,expected){
 if(!Number.isFinite(expected)||Math.abs(expected)<1e-15)return null;
 const signedPeak=values.reduce((p,v)=>Math.max(p,Math.sign(expected)*v),0);
 return Math.max(0,(signedPeak-Math.abs(expected))/Math.abs(expected))*100;
}
function advise(model,{amplitude=1,count=128,marginDb=6}={}){
 if(typeof amplitude!=='number'||!Number.isFinite(amplitude)||Math.abs(amplitude)>1e6)throw Error('阶跃幅度必须是绝对值不超过 10^6 的有限数。');
 if(!Number.isInteger(count)||count<2||count>2048)throw Error('阶跃样本数必须为 2–2048。');
 if(typeof marginDb!=='number'||!Number.isFinite(marginDb)||marginDb<0||marginDb>60)throw Error('安全余量必须为 0–60 dB。');
 const f=model.fixed,warnings=[],plan=S.sections(model),floating=trace(plan.sections,plan.delaySamples,amplitude,count,f.dataFraction),isStable=stable(plan.sections);
 let q=null,shadow=null,fixed=null,fixedError=null;
 try{
  // Inspect an otherwise representable quantization even if the configured accumulator is too narrow.
  q=S.quantize({...model,fixed:{...f,accumulatorBits:64}});
  const sections=q.sections.map(s=>({b:s.b.map(x=>x/q.scale),a:s.a.map(x=>x/q.scale)})),raw=away(amplitude*2**f.dataFraction);
  shadow=trace(sections,q.delaySamples,raw/2**f.dataFraction,count,f.dataFraction,true,f.rounding);
  if(raw<-(2**(f.inputBits-1))||raw>2**(f.inputBits-1)-1)fixedError='输入阶跃超出当前 IN_WIDTH 可表示范围；未裁剪输入。';
  else if(f.accumulatorBits<q.requiredAccumulatorBits)fixedError='当前累加器低于既有全范围下界；不执行当前定点配置。';
  else fixed=S.runFixed(model,Array(count).fill(raw));
  if(!stable(sections))warnings.push('量化后的极点非严格稳定。');
 }catch(e){fixedError=e.message;}
 if(fixedError)warnings.push(fixedError);
 if(!isStable)warnings.push('浮点极点非严格稳定。');
 if(!floating.every(s=>s.settled)||shadow&&!shadow.every(s=>s.settled))warnings.push('当前窗口尚未满足收敛判据；请增加样本数或检查模型/量化极限环。');
 const rows=floating.map((s,i)=>{
  const run=fixed?.sections[i],wide=shadow?.[i];
  let fixedStats=null;
  if(run){
   const accumulators=run.accumulators.map(BigInt),peakRaw=accumulators.reduce((p,v)=>{v=v<0n?-v:v;return v>p?v:p;},0n),input=i?fixed.sections[i-1].raw:Array.from({length:count},(_,n)=>n<q.delaySamples?0:away(amplitude*2**f.dataFraction));
   fixedStats={inputPeak:absMax(input)/2**f.dataFraction,outputPeak:absMax(run.raw)/2**f.dataFraction,accumulatorRawPeak:peakRaw.toString(),accumulatorPeak:Number(peakRaw)/2**(f.dataFraction+f.coefficientFraction),saturationCount:run.saturationCount};
  }
  const observedOutput=Math.max(s.outputPeak,wide?.outputPeak||0,fixedStats?.outputPeak||0,fixedStats?.accumulatorPeak||0);
  const observedAcc=Math.max(s.sumProductsPeak,wide?.sumProductsPeak||0,fixedStats?.accumulatorPeak||0);
  return {index:i+1,floating:{inputPeak:s.inputPeak,outputPeak:s.outputPeak,accumulatorPeak:s.accumulatorPeak,sumProductsPeak:s.sumProductsPeak},fixed:fixedStats,unclippedQuantizedPeak:wide?.outputPeak??null,observedDataBits:bits(observedOutput,f.dataFraction,marginDb),observedAccumulatorBits:bits(observedAcc,f.dataFraction+f.coefficientFraction,marginDb)};
 });
 const final=floating.at(-1),quantizedStable=q&&stable(q.sections.map(s=>({a:s.a.map(x=>x/q.scale)}))),settled=floating.every(s=>s.settled)&&!!shadow?.every(s=>s.settled);
 let recommendation=null;
 if(isStable&&quantizedStable&&settled){
  const inputBits=Math.max(8,bits(Math.abs(amplitude),f.dataFraction,marginDb),rows.at(-1).observedDataBits);
  const sectionBits=Math.max(inputBits,...rows.slice(0,-1).map(s=>s.observedDataBits));
  // Keep the existing full-range MAC bound for the proposed widths, even when the measured peak is small.
  const fullRangeAccumulatorBits=Math.max(...q.sections.map((s,i)=>Math.max(i?sectionBits:inputBits,i===rows.length-1?inputBits:sectionBits)+f.coefficientBits+Math.ceil(Math.log2(s.b.length+s.a.length-1))+1));
  const accumulatorBits=Math.max(20,fullRangeAccumulatorBits,...rows.map(s=>s.observedAccumulatorBits));
  recommendation={inputBits,sectionBits,accumulatorBits,integerBitsIncludingSign:inputBits-f.dataFraction,dataFraction:f.dataFraction,coefficientFraction:f.coefficientFraction,fullRangeAccumulatorBits,supported:inputBits<=24&&sectionBits<=32&&accumulatorBits<=64};
  if(!recommendation.supported)warnings.push('建议超出当前 HDL 支持位宽；请降低幅度/增益或调整精度，不能静默截断。');
 }
 if(fixed?.saturationCount)warnings.push('当前定点阶跃发生 '+fixed.saturationCount+' 次节输出饱和；建议同时参考未饱和轨迹。');
 if(!recommendation)warnings.push('不提供可应用的有限位宽建议；下表仅为本窗口观测。');
 return {amplitude,count,durationSeconds:count/model.sampleRate,marginDb,stable:isStable,quantizedStable:!!quantizedStable,settled,rows,recommendation,warnings,outputPeak:final.outputPeak,steadyState:isStable?final.expected:null,overshootPercent:isStable?overshoot(final.values,final.expected):null,fixedOutputPeak:fixed?absMax(fixed.values):null,fixedOvershootPercent:fixed&&isStable?overshoot(fixed.values,final.expected):null,saturationCount:fixed?.saturationCount??null,scope:'仅指定阶跃与观察窗口；不是任意输入无溢出保证。'};
}
root.DigitalWidth={advise,bits};
if(typeof module!=='undefined'&&module.exports)module.exports=root.DigitalWidth;
})(typeof window!=='undefined'?window:globalThis);
