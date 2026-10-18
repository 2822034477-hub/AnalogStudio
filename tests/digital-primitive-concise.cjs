'use strict';
const assert=require('node:assert/strict'),M=require('../digital-modules'),legacy=require('./fixtures/module-generator-v1');
const {configurations}=require('./module-arithmetic-cases.cjs');
const copy=x=>JSON.parse(JSON.stringify(x));
for(const kind of ['delay','quantize','gain'])for(const timing of ['combinational','registered']){
 const c=M.defaults(kind);c.timing=timing;const v=M.create(c).verilog;
 assert(!v.includes('wire signed [16:0]')&&!v.includes('wide_value')&&!v.includes('<<< 0')&&!v.includes('>>> 0'));
 assert(!v.includes('result_value')&&!v.includes('output_reg'));
 if(timing==='combinational')assert(v.includes('assign data_out = data_in;'));
 else{assert(v.includes('output reg signed [15:0] data_out'));assert(v.includes('else data_out <= data_in;'));}
}
assert(M.create(M.defaults('subtract')).verilog.includes('assign data_out = a - b;'));
const product=M.create(M.defaults('multiply')).verilog;assert(product.includes('wire signed [31:0] product = a * b;'));assert(product.includes('assign data_out = product >>> 8;'));
const integral=M.create(M.defaults('integrator')).verilog;assert(integral.includes('else data_out <= data_out + data_in;'));assert(!integral.includes('state_ext'));
let c=M.defaults('gain');c.params.gainInteger=8;assert(M.create(c).verilog.includes('assign data_out = data_in <<< 3;'));assert(!M.create(c).verilog.includes('*'));
c.params.gainInteger=3;assert(M.create(c).verilog.includes("data_in * 3'sd3"));assert(!M.create(c).verilog.includes("64'sd"));
c.params.gainInteger=0;assert(M.create(c).verilog.includes("assign data_out = 1'b0;"));
c=M.defaults('delay');c.params.overflow='saturate';c.params.rounding='nearest';assert(M.create(c).verilog.includes('assign data_out = data_in;'));assert(!M.create(c).verilog.includes('MIN_VALUE'));
c=M.defaults('delay');c.output.width=24;assert(M.create(c).verilog.includes('assign data_out = data_in;'));
c=M.defaults('quantize');c.inputs[0].fraction=127;c.output.fraction=0;c.params.rounding='nearest';assert(M.create(c).verilog.includes("assign data_out = 1'b0;"));
let accepted=0;
for(const config of configurations()){
 const current=M.create(config),saved=legacy.create(config),loaded=M.load(saved);
 assert.deepEqual(loaded,saved,'legacy source must stay exact');
 assert.deepEqual(M.load(current),current);
 const changed=copy(saved);changed.verilog=changed.verilog.replace('endmodule','assign not_in_config = 1;\nendmodule');assert.throws(()=>M.load(changed),/不一致/);
 const project=M.empty();project.modules=[{key:'m1',design:saved}];assert.deepEqual(M.validateState(project).modules[0].design,saved);
 const reopened=M.create(loaded.config);assert.deepEqual(reopened,current,'explicit resave uses current emitter');accepted++;
}
console.log('PASS concise primitive generation: direct connections/registered outputs, exact product width, power-of-two/zero/unit gains, eliminated inert rounding/saturation, '+accepted+' exact legacy package/project imports and tamper rejection.');
