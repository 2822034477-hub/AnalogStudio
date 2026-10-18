'use strict';
const fs=require('node:fs'),path=require('node:path'),D=require('../digital-design'),S=(()=>{const box={};require('node:vm').runInNewContext(fs.readFileSync(path.join(__dirname,'fixtures/digital-sos-withdrawn.js'),'utf8'),box);return box.DigitalSOS;})();
const root=path.resolve(__dirname,'../timing-retiming'),m=D.create(D.presets.lowpass),q=D.quantize(m),cases=JSON.parse(fs.readFileSync(path.join(root,'cases.json'),'utf8'));
for(const variant of ['before','after']){
 const dir=path.join(root,'lowpass-'+variant+'-chosen');fs.mkdirSync(dir,{recursive:true});const rtl=variant==='before'?S.legacyVerilog(m,q,'digital_filter'):S.verilog(m,q,'digital_filter');fs.writeFileSync(path.join(dir,'digital_filter.v'),rtl);
 cases.push({name:'lowpass',variant,rtl:path.relative(root,path.join(dir,'digital_filter.v')),fixed:m.fixed,sections:q.sections,latency:q.latency});
}
fs.writeFileSync(path.join(root,'cases.json'),JSON.stringify(cases,null,2));
