'use strict';
const fs=require('node:fs'),path=require('node:path'),D=require('../digital-design'),S=(()=>{const box={};require('node:vm').runInNewContext(fs.readFileSync(path.join(__dirname,'fixtures/digital-sos-withdrawn.js'),'utf8'),box);return box.DigitalSOS;})();
const root=path.resolve(__dirname,'../timing-retiming');fs.mkdirSync(root,{recursive:true});
const models={fo:D.create({b:[.2,.1],a:[1,-.8]}),so:D.create(D.presets.notch),sos8:D.load(JSON.parse(fs.readFileSync(path.join(__dirname,'../examples/simulation/sos8/model.json'),'utf8')))};
const specs=[];
const tag=process.argv[2]?'-'+process.argv[2]:'';
for(const [name,m]of Object.entries(models))for(const variant of ['before','after']){
 const dir=path.join(root,name+'-'+variant+tag);fs.mkdirSync(dir,{recursive:true});const q=D.quantize(m),rtl=variant==='before'?S.legacyVerilog(m,q,'digital_filter'):S.verilog(m,q,'digital_filter');
 fs.writeFileSync(path.join(dir,'digital_filter.v'),rtl);specs.push({name,variant,rtl:path.relative(root,path.join(dir,'digital_filter.v')),fixed:m.fixed,sections:q.sections,latency:q.latency});
}
fs.writeFileSync(path.join(root,'cases.json'),JSON.stringify(specs,null,2));console.log('Generated matched FO, SO and SOS8 timing sources.');
