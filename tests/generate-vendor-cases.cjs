'use strict';
const fs=require('fs'),path=require('path'),D=require('../digital-design'),R=require('../simulation-runners');
const root=path.resolve(process.argv[2]||path.join(__dirname,'../examples/simulation'));
const small={coefficientBits:8,coefficientFraction:1,inputBits:8,outputBits:8,dataFraction:0,accumulatorBits:20};
const models={lowpass:D.create(D.presets.lowpass),saturation:D.create({b:[3],a:[1],fixed:small}),notch:D.create(D.presets.notch),delay:D.create(D.presets.delay),fir:D.create(D.presets.fir),floor:D.create({b:[.5],a:[1],fixed:{...small,rounding:'floor'}}),wide:D.create({b:[1.75,-.5,.25],a:[1,-.25,.1],fixed:{coefficientBits:30,coefficientFraction:27,inputBits:24,outputBits:24,dataFraction:20,accumulatorBits:58}})};
models.edited=D.editRoot(D.editRoot(models.notch,{action:'move',kind:'poles',index:0,re:.6,im:.25,pair:true,sourcePair:true}),{action:'move',kind:'zeros',index:0,re:.7,im:.5,pair:true,sourcePair:true});
for(const order of [4,6,8]){const poles=Array.from({length:order/2},(_,i)=>({re:.2+.1*i,im:.11+.047*i})),zeros=Array.from({length:order/2},(_,i)=>({re:-.25+.06*i,im:.22+.05*i}));models['sos'+order]=D.create({poles,zeros,gain:.013,fixed:{sectionBits:20,accumulatorBits:44}});}
delete models.sos4.factors; // Exercise transfer-function-to-SOS conversion, not only supplied ZPK.
models.odd5=D.create({poles:[{re:.3,im:.17},{re:.5,im:.21},-.35],zeros:[{re:-.2,im:.25},.2],gain:-.03,fixed:{sectionBits:20,accumulatorBits:44}});
models.delay8=D.create({poles:[],gain:.75,delaySamples:8});
models.sos_delay=D.create({poles:[{re:.4,im:.2},{re:.6,im:.15}],zeros:[.3],gain:.01,delaySamples:3,fixed:{sectionBits:24,accumulatorBits:48,rounding:'floor'}});
models.repeated8=D.create({poles:Array(8).fill(.5),gain:.001,fixed:{sectionBits:20,accumulatorBits:44}});
models.sos_clip=D.create({poles:[{re:.4,im:.15},{re:.5,im:.2}],gain:8,fixed:{coefficientBits:20,sectionBits:16,accumulatorBits:44}});
models.width18=models.sos6;
models.latency_fo=D.create({b:[.5],a:[1,-.25]});
models.latency_so=D.create({b:[.5],a:[1,-.5,.125]});
models.odd3=D.create({poles:[.25,{re:.4,im:.2}],gain:.03,fixed:{sectionBits:20,accumulatorBits:44}});
models.odd5_fo=D.create({poles:[.25,{re:.4,im:.2},{re:.6,im:.1}],gain:.03,fixed:{sectionBits:20,accumulatorBits:44}});
models.width8=D.create({poles:[{re:.4,im:.2}],gain:.125,fixed:{inputBits:12,outputBits:12,dataFraction:4,coefficientBits:12,coefficientFraction:8,sectionBits:16,accumulatorBits:32}});
models.width24=models.sos6;
models.zero_gain=D.create({zeros:[{re:.3,im:.2}],poles:[.5],gain:0,delaySamples:2});
const oracle=require('./sos-golden.cjs'),assert=require('node:assert/strict');
function vectors(m){let seed=12345;const max=2**(m.fixed.inputBits-1)-1,min=-max-1,q=D.quantize(m),inputs=[max,min,0,1,-1,...Array.from({length:123},()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%(max-min+1)+min;}),...Array(q.pipelineDelay+8).fill(0)],expected=oracle(q,inputs,m.fixed.rounding);assert.deepEqual(D.runFixed(m,inputs).clockRaw,expected.raw);return {inputs,expected:expected.raw,sectionSaturation:expected.saturation,sections:q.sections,scale:q.scale,delaySamples:q.delaySamples,pipelineDelay:q.pipelineDelay,filterLatency:q.filterLatency,latency:q.latency,edgeOffset:q.edgeOffset,rounding:m.fixed.rounding};}
for(const [name,m] of Object.entries(models)){const dir=path.join(root,name);fs.mkdirSync(dir,{recursive:true});const options=/^width(8|18|24)$/.test(name)?{inputWidth:Number(name.slice(5))}:{},delta=(options.inputWidth??m.fixed.inputBits)-m.fixed.inputBits,vm=delta?D.fromCoefficients({...m,fixed:{...m.fixed,inputBits:m.fixed.inputBits+delta,outputBits:m.fixed.outputBits+delta,sectionBits:m.fixed.sectionBits+delta,accumulatorBits:m.fixed.accumulatorBits+delta}}):m;fs.writeFileSync(path.join(dir,'golden.json'),JSON.stringify(vectors(vm),null,2));fs.writeFileSync(path.join(dir,'test-options.json'),JSON.stringify(options,null,2));fs.writeFileSync(path.join(dir,'model.json'),JSON.stringify(D.serialize(m),null,2));fs.writeFileSync(path.join(dir,'digital_filter.v'),D.generateVerilog(m));fs.writeFileSync(path.join(dir,'digital_filter_tb.sv'),D.generateTestbench(m,options));for(const f of R.generate())fs.writeFileSync(path.join(dir,f.filename),f.content);}
console.log('Generated vendor cases:',Object.keys(models).join(', '));
