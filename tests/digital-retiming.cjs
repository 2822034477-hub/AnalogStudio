'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path'),vm=require('node:vm'),D=require('../digital-design'),S=require('../digital-sos'),M=require('../digital-modules');
function fixture(name){const box={};vm.runInNewContext(fs.readFileSync(path.join(__dirname,'fixtures',name),'utf8'),box);return box.DigitalSOS;}
const original=fixture('digital-sos-pre-retiming.js'),withdrawn=fixture('digital-sos-withdrawn.js');
const cases=fs.readdirSync(path.join(__dirname,'../examples/simulation')).filter(n=>fs.existsSync(path.join(__dirname,'../examples/simulation',n,'model.json')));
for(const name of cases){
 const m=D.load(JSON.parse(fs.readFileSync(path.join(__dirname,'../examples/simulation',name,'model.json'),'utf8'))),q=D.quantize(m),code=original.verilog(m,q,'saved_filter');
 assert.equal(S.verilog(m,q,'saved_filter'),code,'new generation must use original architecture');
 const p=M.create({kind:'filter',moduleName:'saved_filter',model:m});assert.equal(p.verilog,code);assert.deepEqual(M.load(p),p);
 const archived={...p,verilog:withdrawn.verilog(m,q,'saved_filter')};assert.deepEqual(M.load(archived),archived,'preserve an already-saved immutable package');assert.equal(M.create(M.load(archived).config).verilog,code,'explicit resave returns to original implementation');
 assert.throws(()=>M.load({...archived,verilog:archived.verilog+'\nchanged'}),/不一致/);
}
console.log('PASS withdrawn filter optimization: '+cases.length+' original generators/fixtures restored, immutable historical HDL imports retained and tampered source rejected; explicit resave generates original FO/SO.');
