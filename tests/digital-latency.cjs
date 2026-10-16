'use strict';
const assert=require('node:assert/strict'),D=require('../digital-design'),oracle=require('./sos-golden.cjs');
let checks=0;
const fixed={inputBits:12,outputBits:12,dataFraction:6,coefficientBits:14,coefficientFraction:10,sectionBits:16,accumulatorBits:36};
const models={fo:D.create({b:[.5],a:[1,-.25],fixed}),so:D.create({b:[.5],a:[1,-.5,.125],fixed}),gain:D.create({b:[.5],a:[1],fixed}),delay:D.create({b:[0,0,.5],a:[1],fixed}),odd3:D.create({poles:[.25,{re:.4,im:.2}],gain:.03,fixed}),odd5:D.create({poles:[.25,{re:.4,im:.2},{re:.6,im:.1}],gain:.03,fixed}),sos4:D.create(D.presets.sos4),sos6:D.create(D.presets.sos6),sos8:D.create(D.presets.sos8)};
for(const [name,m]of Object.entries(models)){
 const q=D.quantize(m),cycles=q.sections.map(s=>Math.max(1,Math.max(s.a.length,s.b.length)-1));
 assert.deepEqual(q.sections.map(s=>s.latency),cycles);assert.equal(q.filterLatency,cycles.reduce((a,b)=>a+b));assert.equal(q.latency,q.filterLatency+q.delaySamples);assert.equal(q.edgeOffset,q.latency-1);assert.equal(q.pipelineDelay,q.filterLatency-1);checks+=5;
 const input=[64,...Array(47).fill(0)],r=D.runFixed(m,input),g=oracle(q,input,m.fixed.rounding);
 assert.deepEqual(r.clockRaw,g.raw,name);assert.deepEqual(r.clockRaw,Array(q.pipelineDelay).fill(0).concat(r.raw).slice(0,input.length));checks+=2;
 if(['fo','so','gain','delay'].includes(name)){assert.equal(r.clockRaw.findIndex(x=>x!==0),q.edgeOffset);checks++;}
 const sequence=Array.from({length:128},(_,n)=>(n*73)%1024-512),continuous=D.runFixed(m,sequence);
 assert.deepEqual(continuous.clockRaw,oracle(q,sequence,m.fixed.rounding).raw);checks+=sequence.length;
 // Compare unshifted values to a direct independent recurrence for the low-order transfer function.
 if(['fo','so','gain','delay'].includes(name)){
  const scale=q.scale,y=[];for(let n=0;n<input.length;n++){let a=0;for(let k=0;k<m.b.length;k++)a+=Math.round(m.b[k]*scale)*(input[n-k]||0);for(let k=1;k<m.a.length;k++)a-=Math.round(m.a[k]*scale)*(y[n-k]||0);y.push(Math.sign(a)*Math.floor(Math.abs(a)/scale+.5)||0);}assert.deepEqual(r.raw,y);checks++;
 }
 const rtl=D.generateVerilog(m),top=rtl.split('endmodule')[0];assert(!top.includes('data_out <='));assert.equal((rtl.match(/module digital_filter_fo\b/g)||[]).length,q.sections.some(s=>s.order<2)?1:0);assert.equal((rtl.match(/module digital_filter_so\b/g)||[]).length,q.sections.some(s=>s.order===2)?1:0);assert(top.includes('EDGE_OFFSET = '+q.edgeOffset));checks+=4;
 if(q.sections.some(s=>s.order===2)){assert(rtl.includes('y1 <= next_y; x2 <= x1; y2 <= y1;'));assert(rtl.includes('assign data_out = y2;'));checks+=2;}
 // The implementation frequency response adds only the displayed hardware edge offset beyond H(z).
 const frequency=m.sampleRate/16,ideal=D.evaluate(q.model,frequency),actual=D.evaluateImplementation(m,frequency),w=2*Math.PI*frequency/m.sampleRate*q.pipelineDelay;
 assert(Math.abs(actual.re-(ideal.re*Math.cos(w)+ideal.im*Math.sin(w)))<1e-10);assert(Math.abs(actual.im-(ideal.im*Math.cos(w)-ideal.re*Math.sin(w)))<1e-10);checks+=2;
}
assert.equal(D.quantize(models.fo).latency,1);assert.equal(D.quantize(models.so).latency,2);assert.equal(D.quantize(models.sos8).latency,8);
assert.deepEqual(D.quantize(models.odd3).sections.map(s=>s.latency),[1,2]);assert.deepEqual(D.quantize(models.odd5).sections.map(s=>s.latency),[1,2,2]);
assert(Number.isNaN(D.evaluateImplementation(D.create({gain:0,poles:[]}),1000).phase));
assert.throws(()=>D.generateTestbench(models.fo,{testbenchName:'digital_filter_fo'}));
console.log(`PASS exact FO/SO timing: ${checks} assertions/sample checks; capture edge = cycle 1, FO1/SO2, additive cascade, gain/delay policy, continuous throughput, independent recurrence, phase shift and no top output register.`);
