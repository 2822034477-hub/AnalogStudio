'use strict';
const assert=require('node:assert/strict'),D=require('../digital-design'),W=require('../digital-width');
let checks=0;
const close=(a,b,tol=1e-8)=>{assert(Math.abs(a-b)<tol*Math.max(1,Math.abs(a),Math.abs(b)),`${a} != ${b}`);checks++;};
const advice=(v,o)=>D.widthAdvice(D.create(v),o);
const low=advice(D.presets.lowpass);assert(low.recommendation&&low.settled);assert(low.recommendation.inputBits>=16);assert.equal(low.recommendation.dataFraction,14);close(low.outputPeak,1-.8**128);close(low.overshootPercent,0);close(low.durationSeconds,128/48000);
// Boundary formula reserves positive endpoint, sign and unchanged fractional precision.
assert.equal(W.bits(127,0),8);assert.equal(W.bits(128,0),9);assert.equal(W.bits(0,14),16);assert(W.bits(1,14,12)>W.bits(1,14,0));checks+=4;
// Actual fixed accumulators/outputs are compared with the existing BigInt runner, not UI text.
for(const key of ['lowpass','notch','sos4','sos6','sos8']){
 const m=D.create(D.presets[key]),a=D.widthAdvice(m,{count:512,amplitude:.5,marginDb:0}),run=D.runFixed(m,Array(512).fill(8192));
 assert(a.recommendation);assert.equal(a.rows.length,run.sections.length);
 a.rows.forEach((s,i)=>{const r=run.sections[i];const peak=r.accumulators.map(BigInt).reduce((p,v)=>{v=v<0n?-v:v;return v>p?v:p;},0n);assert.equal(s.fixed.accumulatorRawPeak,peak.toString());close(s.fixed.outputPeak,Math.max(...r.raw.map(Math.abs))/16384);});
 // Independent floating recurrence follows the selected SOS plan, preserving every internal peak.
 let signal=Array(512).fill(.5);D.toSOS(m).sections.forEach((s,i)=>{const y=[];signal.forEach((x,n)=>{let v=s.b.reduce((v,b,k)=>v+b*(signal[n-k]||0),0);s.a.slice(1).forEach((c,k)=>v-=c*(y[n-k-1]||0));y.push(v);});close(a.rows[i].floating.inputPeak,Math.max(...signal.map(Math.abs)));close(a.rows[i].floating.outputPeak,Math.max(...y.map(Math.abs)));signal=y;});
 assert(a.recommendation.accumulatorBits>=a.recommendation.fullRangeAccumulatorBits);checks++;
}
// A clipped output must not make the recommended width smaller than the unclipped trajectory.
const clip=advice({gain:3,poles:[.8]},{marginDb:0});assert(clip.saturationCount>0);assert(clip.outputPeak>14);assert(clip.fixedOutputPeak<2);assert(clip.recommendation.inputBits>=19);assert(clip.rows[0].unclippedQuantizedPeak>14);checks+=5;
const bigInput=advice(D.presets.lowpass,{amplitude:3});assert(bigInput.warnings.some(x=>x.includes('输入阶跃超出')));assert.equal(bigInput.fixedOutputPeak,null);assert(bigInput.recommendation.inputBits>16);
const short=advice(D.presets.lowpass,{count:8});assert.equal(short.recommendation,null);assert(!short.settled);
const slow=advice({gain:.0001,poles:[.9999]},{count:2048});assert.equal(slow.recommendation,null);assert(!slow.settled);
for(const pole of [1,1.01]){const a=advice({gain:.2,poles:[pole]});assert.equal(a.recommendation,null);assert(!a.stable);assert.equal(a.overshootPercent,null);}
const qUnstable=advice({gain:.01,poles:[.999],fixed:{coefficientFraction:3}});assert.equal(qUnstable.recommendation,null);assert(!qUnstable.quantizedStable);
const highPass=advice({zeros:[1],poles:[],gain:1},{marginDb:0});assert.equal(highPass.overshootPercent,null);assert.equal(highPass.steadyState,0);
const negative=advice(D.presets.lowpass,{amplitude:-1});close(negative.outputPeak,low.outputPeak);close(negative.overshootPercent,0);
const zero=advice(D.presets.lowpass,{amplitude:0});assert.equal(zero.outputPeak,0);assert.equal(zero.overshootPercent,null);
const huge=advice(D.presets.lowpass,{amplitude:1e6});assert(huge.recommendation&&!huge.recommendation.supported);assert(huge.recommendation.inputBits>24);
const narrowAcc=advice({gain:.2,fixed:{accumulatorBits:20}});assert(narrowAcc.warnings.some(x=>x.includes('累加器')));assert(narrowAcc.recommendation.accumulatorBits>=36);
for(const bad of [{amplitude:NaN},{amplitude:Infinity},{amplitude:1e7},{count:1},{count:2049},{count:3.5},{marginDb:-1},{marginDb:61},{marginDb:NaN}])assert.throws(()=>advice(D.presets.lowpass,bad));
// Advisory is pure; signed gain and dormant zero-gain shape round-trip without altering the RTL interface.
const m=D.create({gain:.2,zeros:[{re:.2,im:.3}],poles:[.5,.5],delaySamples:2}),saved=JSON.stringify(m),rtl=D.generateVerilog(m);D.widthAdvice(m);assert.equal(JSON.stringify(m),saved);assert.equal(D.generateVerilog(m),rtl);
const z=D.create({...D.factorRoots(m),gain:0});assert.equal(D.factorRoots(z).zeros.length,1);assert.equal(D.factorRoots(z).delaySamples,2);assert.equal(D.analysis(z).zeros.length,0);assert.deepEqual(D.load(D.serialize(z)),z);
const restored=D.create({...D.factorRoots(z),gain:-.2});m.b.forEach((b,i)=>close(restored.b[i],-b));assert.deepEqual(restored.a,m.a);
assert.throws(()=>D.fromCoefficients({...z,factors:{...z.factors,delaySamples:9}}));checks+=35;
console.log(`PASS width advice: ${checks} numerical comparisons and boundaries; peak/BigInt traces, clipping, signed/zero inputs, zero DC, unstable/slow/quantized-unstable models, finite windows, margins, support limits and pure recommendations.`);
