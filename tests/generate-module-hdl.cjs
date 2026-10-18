'use strict';
const fs=require('node:fs'),path=require('node:path'),M=require('../digital-modules');
const dir=path.join(__dirname,'../test-results/module-hdl');fs.mkdirSync(dir,{recursive:true});
const extra=require('./module-arithmetic-cases.cjs').generate();
const f=(width,signed=true,fraction=0)=>({width,signed,fraction});
function make(kind,name,inputs,output,params={},timing='combinational'){const c=M.defaults(kind);c.moduleName=name;c.inputs=c.inputs.map((p,i)=>({...p,...inputs[i]}));c.output={...c.output,...output};c.params={...c.params,...params};c.timing=timing;return M.create(c);}
const modules=[
 make('subtract','sub_signed',[f(8),f(8)],f(9)),
 make('absolute','abs_unsigned',[f(8)],f(8,false)),
 make('multiply','mul_unsigned',[f(8,false),f(8,false)],f(16,false)),
 make('quantize','q_nearest',[f(12,true,2)],f(8),{rounding:'nearest',overflow:'saturate'}),
 make('quantize','q_floor',[f(12,true,2)],f(8),{rounding:'floor',overflow:'wrap'}),
 make('gain','gain_negative',[f(8)],f(10),{gainInteger:-3,gainFraction:1,rounding:'nearest'}),
 make('subtract','sub_registered',[f(8),f(8)],f(9),{},'registered'),
 make('subtract','dc_sub',[f(8),f(8)],f(8)),
 make('integrator','dc_integrator',[f(8)],f(16,true,8),{stepShift:8},'registered'),
 make('quantize','dc_quantizer',[f(16,true,8)],f(8))
];
const s=M.empty();s.topName='dc_removal';s.modules=modules.slice(7).map((design,i)=>({key:'m'+i,design}));s.instances=[{id:'sub',moduleKey:'m0'},{id:'acc',moduleKey:'m1'},{id:'quant',moduleKey:'m2'}];s.ports=[{name:'x',direction:'input',...f(8)},{name:'y',direction:'output',...f(8)}];
for(const [from,to]of [['in:x','sub:a'],['quant:data_out','sub:b'],['sub:data_out','out:y'],['sub:data_out','acc:data_in'],['acc:data_out','quant:data_in']])s.connections.push({from,to});
const D=require('../digital-design'),fp=M.create({kind:'filter',moduleName:'filter_cell',model:D.create({b:[.5],a:[1,-.25]})});
const chain=M.empty();chain.topName='filter_chain';chain.modules=[{key:'mf',design:fp}];chain.instances=[{id:'first',moduleKey:'mf'},{id:'second',moduleKey:'mf'}];chain.ports=[{name:'x',direction:'input',...f(16,true,14)},{name:'y',direction:'output',...f(16,true,14)}];chain.connections=[{from:'in:x',to:'first:data_in'},{from:'first:data_out',to:'second:data_in'},{from:'second:data_out',to:'out:y'}];
fs.writeFileSync(path.join(dir,'modules.v'),modules.slice(0,7).map(m=>m.verilog).join('\n')+'\n'+M.generateSystem(s)+'\n'+M.generateSystem(chain)+'\n'+extra.code);
const tb=`
\`timescale 1ns/1ps
module module_tb;
wire arithmetic_done; primitive_cases_tb arithmetic_checks(arithmetic_done);
reg clk=0;always #5 clk=~clk;
reg rst_n=0;
reg signed [7:0] a=0,b=0;
reg [7:0] ua=0,ub=0;
reg signed [11:0] qin=0;
reg signed [7:0] dx=0;
reg signed [15:0] fx=0;wire signed [15:0] fy;
wire signed [8:0] sub_out,reg_out;
wire [7:0] abs_out;wire [15:0] mul_out;
wire signed [7:0] near_out,floor_out,dy;
wire signed [9:0] gain_out;
sub_signed u0(.a(a),.b(b),.data_out(sub_out));
abs_unsigned u1(.data_in(a),.data_out(abs_out));
mul_unsigned u2(.a(ua),.b(ub),.data_out(mul_out));
q_nearest u3(.data_in(qin),.data_out(near_out));
q_floor u4(.data_in(qin),.data_out(floor_out));
gain_negative u5(.data_in(a),.data_out(gain_out));
sub_registered u6(.clk(clk),.rst_n(rst_n),.a(a),.b(b),.data_out(reg_out));
dc_removal dc(.clk(clk),.rst_n(rst_n),.x(dx),.y(dy));
filter_chain fc(.clk(clk),.rst_n(rst_n),.x(fx),.y(fy));
integer i,j,expected,nearest,fl,oracle_state,oracle_q,oracle_y,first_state,second_state,next_first,next_second;
initial begin
 #1;
 for(i=-128;i<128;i=i+7) begin
  for(j=-128;j<128;j=j+13) begin
   a=i;b=j;ua=i+128;ub=j+128;#1;
   expected=i-j;if(sub_out!==expected)$fatal(1,"signed subtract");
   expected=i<0?-i:i;if(abs_out!==expected)$fatal(1,"absolute minimum / unsigned output");
   expected=(i+128)*(j+128);if(mul_out!==expected)$fatal(1,"unsigned multiply");
   expected=i*-3;nearest=expected<0?-((-expected+1)/2):(expected+1)/2;
   if(gain_out!==nearest)$fatal(1,"negative fractional gain");
  end
 end
 for(i=-2048;i<2048;i=i+17) begin
  qin=i;#1;
  nearest=i<0?-((-i+2)/4):(i+2)/4;if(nearest>127)nearest=127;if(nearest< -128)nearest=-128;
  if(near_out!==nearest)$fatal(1,"nearest saturation");
  fl=i<0?-((-i+3)/4):i/4;expected=fl&255;if(expected>127)expected=expected-256;
  if(floor_out!==expected)$fatal(1,"floor wrap");
 end
 @(negedge clk);a=100;b=-100;rst_n=0;
 @(posedge clk);#1;if(reg_out!==0||dy!==0)$fatal(1,"synchronous reset");
 @(negedge clk);rst_n=1;dx=60;
 @(posedge clk);#1;if(reg_out!==200)$fatal(1,"registered output");
 // Reset again, then compare every clock against an independent integer recurrence.
 @(negedge clk);rst_n=0;dx=0;
 @(posedge clk);#1;oracle_state=0;first_state=0;second_state=0;
 @(negedge clk);rst_n=1;dx=60;fx=100;
 for(i=0;i<4000;i=i+1) begin
  oracle_q=oracle_state>=0?oracle_state/256:-((-oracle_state+255)/256);
  oracle_y=60-oracle_q;oracle_state=oracle_state+oracle_y;
  next_first=(200+first_state+2)/4;next_second=(2*first_state+second_state+2)/4;
  first_state=next_first;second_state=next_second;
  @(posedge clk);#1;
  oracle_q=oracle_state/256;expected=60-oracle_q;
  if(dy!==expected)$fatal(1,"DC loop clock mismatch %0d: got %0d expected %0d",i,dy,expected);
  if(fy!==second_state)$fatal(1,"Repeated saved filter mismatch %0d: got %0d expected %0d",i,fy,second_state);
  @(negedge clk);
 end
 if(dy!==0)$fatal(1,"DC was not removed");
 rst_n=0;dx=0;@(posedge clk);#1;if(dy!==0||reg_out!==0)$fatal(1,"second reset");
 if(arithmetic_done!==1)$fatal(1,"Extended arithmetic checks incomplete");
 $display("PASS: module arithmetic, repeated saved filters, saved system wiring, registered latency, DC feedback and reset");$finish;
end
endmodule
`;
fs.writeFileSync(path.join(dir,'module_tb.sv'),tb+'\n'+extra.tb);fs.writeFileSync(path.join(dir,'run.tcl'),'run all\nquit\n');console.log('Generated '+extra.configurations+' arithmetic configurations / '+extra.vectors+' independent checks and 4000-cycle DC-loop checks.');
