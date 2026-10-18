'use strict';
const assert=require('node:assert/strict'),M=require('../digital-modules'),D=require('../digital-design');
const copy=x=>JSON.parse(JSON.stringify(x));
for(const kind of Object.keys(M.types).filter(k=>k!=='filter'))for(const timing of ['combinational','registered']){
 const c=M.defaults(kind);c.timing=timing;const p=M.create(c);assert.deepEqual(M.load(JSON.stringify(p)),p);assert.equal(p.moduleName,c.moduleName);assert(p.verilog.includes('module '+p.moduleName+'('));assert.equal(p.clocked,kind==='integrator'||timing==='registered');
 for(const field of ['verilog','moduleName','latency','ports']){const bad=copy(p);if(field==='ports')bad.ports[0].signed=!bad.ports[0].signed;else if(field==='latency')bad.latency++;else bad[field]+='changed';assert.throws(()=>M.load(bad),/不一致/);}
}
const filter=M.create({kind:'filter',moduleName:'saved_filter',model:D.create(D.presets.lowpass)});assert.equal(filter.verilog,D.generateVerilog(filter.config.model,{moduleName:'saved_filter'}));assert.deepEqual(M.load(filter),filter);assert(filter.clocked);
const sub=M.create(M.defaults('subtract')),s=M.empty();s.view='system';s.modules=[{key:'m1',design:sub}];s.instances=[{id:'u1',moduleKey:'m1'},{id:'u2',moduleKey:'m1'}];s.ports=[{name:'x',direction:'input',width:16,signed:true,fraction:8},{name:'y',direction:'output',width:16,signed:true,fraction:8}];
let linked=s;for(const [from,to]of [['in:x','u1:a'],['in:x','u1:b'],['u1:data_out','u2:a'],['in:x','u2:b'],['u2:data_out','out:y']])linked=M.connect(linked,from,to);
const code=M.generateSystem(linked);assert.equal((code.match(/module digital_subtract\(/g)||[]).length,1);assert(code.includes('digital_subtract u1(')&&code.includes('digital_subtract u2('));assert(!code.includes('input wire clk'));assert.deepEqual(M.validateState(copy(linked)),linked);
for(const field of ['width','signed','fraction']){const bad=copy(s);bad.ports[0][field]=field==='signed'?false:bad.ports[0][field]+1;assert.throws(()=>M.connect(bad,'in:x','u1:a'),/接口不匹配/);}
assert.throws(()=>M.connect(linked,'in:x','u1:a'),/一个输入/);assert.throws(()=>M.connect(s,'u1:data_out','u1:a'),/纯组合/);assert.throws(()=>M.connect(s,'u1:a','u2:b'),/方向/);assert.throws(()=>M.generateSystem(s),/尚未连接/);
const conflicting=copy(s);const changed=copy(sub.config);changed.output.width++;conflicting.modules.push({key:'m2',design:M.create(changed)});conflicting.instances[1].moduleKey='m2';assert.throws(()=>M.validateState(conflicting),/对应不同 Verilog/);
const reg=M.defaults('subtract');reg.timing='registered';const loop=M.empty();loop.modules=[{key:'m1',design:M.create(reg)}];loop.instances=[{id:'u1',moduleKey:'m1'}];assert.doesNotThrow(()=>M.connect(loop,'u1:data_out','u1:a'));
const project={...D.defaults(),system:linked};assert.deepEqual(D.validate(project).system,linked);assert.deepEqual(D.validate(JSON.stringify(project)).system,linked);
const extreme=M.defaults('quantize');extreme.inputs[0].fraction=127;extreme.output.fraction=0;extreme.params.rounding='nearest';assert(M.create(extreme).verilog.includes("assign data_out = 1'b0;"));
console.log('PASS digital modules: every simple kind/timing roundtrip, configuration-HDL binding, saved filter reuse, unchanged module names, deduplicated repeated instances, exact interface checks, driver/direction checks, registered vs combinational feedback, name collisions, incomplete graphs and digital-project persistence.');
