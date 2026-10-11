'use strict';
const fs=require('fs'),path=require('path'),D=require('../digital-design'),R=require('../simulation-runners');
const root=path.resolve(process.argv[2]||path.join(__dirname,'../examples/simulation'));
const small={coefficientBits:8,coefficientFraction:1,inputBits:8,outputBits:8,dataFraction:0,accumulatorBits:20};
const models={lowpass:D.create(D.presets.lowpass),saturation:D.create({b:[3],a:[1],fixed:small}),notch:D.create(D.presets.notch),delay:D.create(D.presets.delay),fir:D.create(D.presets.fir),floor:D.create({b:[.5],a:[1],fixed:{...small,rounding:'floor'}}),wide:D.create({b:[1.75,-.5,.25],a:[1,-.25,.1],fixed:{coefficientBits:30,coefficientFraction:27,inputBits:24,outputBits:24,dataFraction:20,accumulatorBits:58}})};
models.edited=D.editRoot(D.editRoot(models.notch,{action:'move',kind:'poles',index:0,re:.6,im:.25,pair:true,sourcePair:true}),{action:'move',kind:'zeros',index:0,re:.7,im:.5,pair:true,sourcePair:true});
for(const [name,m] of Object.entries(models)){const dir=path.join(root,name);fs.mkdirSync(dir,{recursive:true});fs.writeFileSync(path.join(dir,'model.json'),JSON.stringify(D.serialize(m),null,2));fs.writeFileSync(path.join(dir,'digital_filter.v'),D.generateVerilog(m));fs.writeFileSync(path.join(dir,'digital_filter_tb.sv'),D.generateTestbench(m));for(const f of R.generate())fs.writeFileSync(path.join(dir,f.filename),f.content);}
console.log('Generated vendor cases:',Object.keys(models).join(', '));
