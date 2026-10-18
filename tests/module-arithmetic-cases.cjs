'use strict';
// Mathematical fixed-point oracle, independent of Verilog sizing rules.
const M=require('../digital-modules'),fs=require('node:fs'),path=require('node:path');
const copy=x=>JSON.parse(JSON.stringify(x));
const format=(width,signed,fraction)=>({width,signed,fraction});
const bounds=p=>p.signed?[-(1n<<BigInt(p.width-1)),(1n<<BigInt(p.width-1))-1n]:[0n,(1n<<BigInt(p.width))-1n];
function wrap(x,p){const m=1n<<BigInt(p.width);x=((x%m)+m)%m;return p.signed&&x>=m/2n?x-m:x;}
function evaluate(c,x,state=0n){
 let raw=x[0],f=c.inputs[0].fraction;
 if(c.kind==='subtract'){f=Math.max(...c.inputs.map(p=>p.fraction));raw=(x[0]<<BigInt(f-c.inputs[0].fraction))-(x[1]<<BigInt(f-c.inputs[1].fraction));}
 if(c.kind==='multiply'){f+=c.inputs[1].fraction;raw=x[0]*x[1];}
 if(c.kind==='gain'){f+=c.params.gainFraction;raw=x[0]*BigInt(c.params.gainInteger);}
 if(c.kind==='absolute'&&raw<0n)raw=-raw;
 const shift=c.output.fraction-f-(c.kind==='integrator'?c.params.stepShift:0);
 if(shift>=0)raw<<=BigInt(shift);
 else if(c.params.rounding==='floor')raw>>=BigInt(-shift);
 else{const div=1n<<BigInt(-shift),half=div/2n;raw=raw<0n?-((-raw+half)/div):(raw+half)/div;}
 if(c.kind==='integrator')raw+=state;
 if(c.params.overflow==='saturate'){const [lo,hi]=bounds(c.output);raw=raw<lo?lo:raw>hi?hi:raw;}
 return wrap(raw,c.output);
}
function configurations(){
 const configs=[];
 function add(kind,inputs,out,params={},timing='combinational'){
  const c=M.defaults(kind);c.moduleName='arithmetic_'+configs.length;c.inputs=c.inputs.map((p,i)=>({...p,...inputs[i]}));c.output={...c.output,...out};c.params={...c.params,...params};c.timing=timing;configs.push(M.config(c));
 }
 for(const kind of Object.keys(M.types).filter(k=>k!=='filter'))for(const timing of ['combinational','registered']){
  const c=M.defaults(kind);c.timing=timing;c.moduleName='arithmetic_'+configs.length;configs.push(M.config(c));
 }
 for(const kind of ['subtract','multiply'])for(const a of [false,true])for(const b of [false,true])for(const of of [false,true])for(const rounding of ['floor','nearest']){
  add(kind,[format(8,a,1),format(5,b,4)],format(9,of,2),{rounding,overflow:rounding==='nearest'?'saturate':'wrap'});
 }
 for(const kind of ['absolute','quantize','delay','integrator'])for(const inputSigned of [false,true])for(const outputSigned of [false,true])for(const rounding of ['floor','nearest'])for(const overflow of ['wrap','saturate']){
  add(kind,[format(7,inputSigned,3)],format(5,outputSigned,1),{rounding,overflow,stepShift:kind==='integrator'?1:0});
 }
 for(const k of [-2147483648,-17,-8,-3,-1,0,1,2,3,7,2147483647])for(const signed of [false,true]){
  add('gain',[format(12,signed,1)],format(16,!signed,2),{gainInteger:k,gainFraction:2,rounding:'nearest',overflow:'saturate'});
  add('gain',[format(8,signed,1)],format(12,signed,4),{gainInteger:k,gainFraction:0,rounding:'floor',overflow:'wrap'},'registered');
 }
 for(const w of [1,2,32,128])for(const s of [false,true])for(const overflow of ['wrap','saturate']){
  add('absolute',[format(w,s,0)],format(Math.min(128,w+2),s,0),{overflow});
  add('quantize',[format(w,s,127)],format(8,!s,0),{overflow,rounding:'nearest'});
  add('quantize',[format(w,s,0)],format(16,!s,127),{overflow});
  add('integrator',[format(w,s,0)],format(Math.min(128,w+1),!s,0),{overflow,stepShift:0});
 }
 // Full-product precision, huge right shifts, minimal widths, unsigned scale
 // before signed subtraction, and all original legal user port names.
 add('multiply',[format(128,true,127),format(128,false,127)],format(128,true,0),{rounding:'nearest',overflow:'saturate'});
 add('subtract',[format(8,false,0),format(8,true,8)],format(24,true,8));
 add('subtract',[format(8,false,0),format(8,false,8)],format(24,true,8));
 for(const w of [1,2,8])for(const f of [1,w,w+1])for(const s of [false,true])add('quantize',[format(w,s,f)],format(16,true,0),{rounding:'nearest'});
 const collision=M.defaults('multiply');collision.moduleName='arithmetic_'+configs.length;collision.inputs[0].name='product';collision.inputs[1].name='rounded';collision.output.name='difference';configs.push(M.config(collision));
 return configs;
}
function generate(){
 const configs=configurations(),checks=[],declarations=[],instances=[],stimuli=[],code=[];
 // A retained copy is a test fixture only; public exports never use it for
 // newly-created designs. Exact source matching protects old design packages.
 const oldPath=path.join(__dirname,'fixtures/module-generator-v1.js');
 const legacy=fs.existsSync(oldPath)?require(oldPath):null;
 let vectorCount=0,seed=0x12345678;
 const random=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return BigInt(seed);};
 const hex=(n,p)=>p.width+"'h"+BigInt.asUintN(p.width,n).toString(16);
 for(const [i,c] of configs.entries()){
  const p=M.create(c),o=c.output;code.push(p.verilog);if(legacy){const old=copy(c);old.moduleName+='__old';code.push(legacy.create(old).verilog);}
  c.inputs.forEach((p,j)=>declarations.push('reg '+(p.signed?'signed ':'')+'['+(p.width-1)+':0] v_'+i+'_'+j+'=0;'));
  declarations.push('wire '+(o.signed?'signed ':'')+'['+(o.width-1)+':0] y_'+i+';');
  const pins=[...(p.clocked?['.clk(clk)','.rst_n(rst_n)']:[]),...c.inputs.map((p,j)=>'.'+p.name+'(v_'+i+'_'+j+')'),'.'+o.name+'(y_'+i+')'];
  instances.push(c.moduleName+' u_'+i+'('+pins.join(',')+');');
  if(legacy){declarations.push('wire ['+(o.width-1)+':0] old_'+i+';');instances.push(c.moduleName+'__old old_u_'+i+'('+pins.slice(0,-1).concat('.'+o.name+'(old_'+i+')').join(',')+');');}
  let state=0n;const steps=[];
  for(let t=0;t<48;t++){
   const x=c.inputs.map(p=>{const [lo,hi]=bounds(p),edge=[lo,hi,0n,lo+1n,hi-1n,1n,-1n,2n,-2n];return t<edge.length?wrap(edge[t],p):wrap((random()<<96n)|(random()<<64n)|(random()<<32n)|random(),p);});
   const expected=evaluate(c,x,state);if(c.kind==='integrator')state=expected;
   steps.push({x,expected});vectorCount++;
  }
  stimuli.push(steps.map(v=>c.inputs.map((p,j)=>'v_'+i+'_'+j+'='+hex(v.x[j],p)+';').join(' ')));
  checks.push(steps.map(v=>'if(y_'+i+' !== '+hex(v.expected,o)+') $fatal(1,"Arithmetic case '+i+' '+c.kind+' mismatch: got %h expected %h",y_'+i+','+hex(v.expected,o)+');'+(legacy?' if(y_'+i+' !== old_'+i+') $fatal(1,"Legacy equivalence case '+i+'");':'')));
 }
 const tb=['module primitive_cases_tb(output reg done=0);','reg clk=0; always #5 clk=~clk; reg rst_n=0;',...declarations,...instances,'initial begin','@(posedge clk); #1;'];
 for(const [i,c]of configs.entries())if(c.timing==='registered')tb.push('if(y_'+i+' !== 0) $fatal(1,"Reset case '+i+'");');
 tb.push('@(negedge clk); rst_n=1;');
 for(let t=0;t<48;t++){
  tb.push(...stimuli.map(a=>a[t]),'#1;');
  for(const [i,c]of configs.entries())if(c.timing==='combinational')tb.push(checks[i][t]);
  tb.push('@(posedge clk); #1;');
  for(const [i,c]of configs.entries())if(c.timing==='registered')tb.push(checks[i][t]);
  tb.push('@(negedge clk);');
 }
 tb.push('rst_n=0; @(posedge clk); #1;');
 for(const [i,c]of configs.entries())if(c.timing==='registered')tb.push('if(y_'+i+' !== 0) $fatal(1,"Second reset case '+i+'");');
 tb.push('done=1; $display("PASS: '+configs.length+' arithmetic configurations, '+vectorCount+' mathematical checks'+(legacy?', legacy equivalence':'')+'");','end','endmodule');
 return {code:code.join('\n'),tb:tb.join('\n'),configurations:configs.length,vectors:vectorCount};
}
module.exports={generate,configurations,evaluate};
