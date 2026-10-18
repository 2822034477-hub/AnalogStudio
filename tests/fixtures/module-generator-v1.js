/* Saved digital designs: explicit interfaces, immutable HDL, reusable instances. */
(function(root){
'use strict';
if(typeof module!=='undefined'&&module.exports&&!root.DigitalSystemLayout)root.DigitalSystemLayout=require('../../digital-system-layout.js');
const copy=x=>JSON.parse(JSON.stringify(x));
const reserved=new Set(('always always_comb always_ff always_latch and assign automatic begin buf bufif0 bufif1 case casex casez cell cmos config deassign default defparam design disable edge else end endcase endconfig endfunction endgenerate endmodule endprimitive endspecify endtable endtask event for force forever fork function generate genvar highz0 highz1 if ifnone incdir include initial inout input instance integer join large liblist library localparam macromodule medium module nand negedge nmos nor noshowcancelled not notif0 notif1 or output parameter pmos posedge primitive pull0 pull1 pulldown pullup pulsestyle_onevent pulsestyle_ondetect rcmos real realtime reg release repeat rnmos rpmos rtran rtranif0 rtranif1 scalared showcancelled signed small specify specparam strong0 strong1 supply0 supply1 table task time tran tranif0 tranif1 tri tri0 tri1 triand trior trireg unsigned use uwire vectored wait wand weak0 weak1 while wire wor xnor xor logic bit byte shortint int longint struct union enum typedef package endpackage import export interface endinterface modport program endprogram class endclass virtual void string const static protected local rand randc constraint solve before inside dist return break continue do foreach unique priority assert assume cover property endproperty sequence endsequence clocking endclocking iff soft this super new null chandle mailbox semaphore process forkjoin join_any join_none accept_on alias bind bins binsof checker context covergroup coverpoint cross endchecker endgroup expect extends extern final first_match global ignore_bins illegal_bins implements implies interconnect intersect let matches nettype nexttime packed randcase randsequence ref reject_on restrict s_always s_eventually s_nexttime s_until s_until_with soft solve static string strong sync_accept_on sync_reject_on tagged throughout timeprecision timeunit type untyped until until_with var weak wildcard with within eventually pure shortreal unique0 wait_order').split(' '));
function id(x){if(typeof x!=='string'||! /^[A-Za-z_][A-Za-z0-9_]{0,63}$/.test(x)||reserved.has(x))throw Error('请输入合法且非保留字的 Verilog 名称。');return x;}
function int(x,lo,hi,label){if(!Number.isInteger(x)||x<lo||x>hi)throw Error(label+' 应为 '+lo+'～'+hi+' 的整数。');return x;}
function fmt(p){if(!p||typeof p.signed!=='boolean')throw Error('接口须明确有符号或无符号。');return {width:int(p.width,1,128,'接口位宽'),signed:p.signed,fraction:int(p.fraction,0,127,'小数位数')};}
function port(p,direction){return {name:id(p.name),direction,...fmt(p)};}
const match=(a,b)=>a.width===b.width&&a.signed===b.signed&&a.fraction===b.fraction;
const describe=p=>p.width+' 位 · '+(p.signed?'signed':'unsigned')+' · F='+p.fraction;
const D=()=>root.DigitalDesign||(typeof require==='function'?require('../../digital-design.js'):null);
const types={subtract:'减法器',multiply:'乘法器',absolute:'绝对值',gain:'常系数增益',quantize:'量化器 / 格式转换',delay:'直通 / 延时',integrator:'积分滤波器',filter:'已有滤波器'};
function defaults(kind='subtract'){
 if(!types[kind]||kind==='filter')throw Error('请选择基础模块类型。');
 const f={width:16,signed:true,fraction:8};
 return {kind,moduleName:'digital_'+kind,timing:kind==='integrator'?'registered':'combinational',inputs:(['subtract','multiply'].includes(kind)?['a','b']:['data_in']).map(name=>({name,...f})),output:{name:'data_out',...f,...(kind==='integrator'?{width:24,fraction:16}:{})},params:{rounding:'floor',overflow:'wrap',gainInteger:1,gainFraction:0,stepShift:8}};
}
function config(value){
 if(!value||!types[value.kind])throw Error('不支持的模块类型。');
 const name=id(value.moduleName);
 if(value.kind==='filter')return {kind:'filter',moduleName:name,model:D().fromCoefficients(value.model)};
 const base=defaults(value.kind),timing=value.kind==='integrator'?'registered':value.timing;
 if(!['combinational','registered'].includes(timing))throw Error('请选择组合逻辑或打一拍。');
 const inputs=value.inputs.map(p=>port(p,'input')),output=port(value.output,'output');
 if(inputs.length!==base.inputs.length)throw Error('输入端口数量不正确。');
 const names=inputs.map(p=>p.name).concat(output.name),internal=['clk','rst_n','x0','x1','a0','a1','state','output_reg','result_value','raw_value','wide_value','scaled_value','state_ext','accumulated','MIN_VALUE','MAX_VALUE'];if(new Set(names).size!==names.length||names.some(n=>internal.includes(n)))throw Error('端口名称重复或占用了模块内部名称。');
 const p={...base.params,...value.params};
 if(!['floor','nearest'].includes(p.rounding)||!['wrap','saturate'].includes(p.overflow))throw Error('量化规则无效。');
 return {kind:value.kind,moduleName:name,timing,inputs,output,params:{rounding:p.rounding,overflow:p.overflow,gainInteger:int(p.gainInteger,-2147483648,2147483647,'增益整数'),gainFraction:int(p.gainFraction,0,63,'增益小数位'),stepShift:int(p.stepShift,0,127,'积分步长移位')}};
}
const decl=(p,d=p.direction)=>d+' '+(d==='output'?'wire ':'wire ')+(p.signed?'signed ':'')+'['+(p.width-1)+':0] '+p.name;
const lit=(width,n)=>n<0n?'-'+width+"'sd"+(-n):width+"'sd"+n;
function primitive(c){
 const output=c.output,inputs=c.inputs,lines=['// '+types[c.kind]+'; explicit interface formats.','// Output overflow: '+c.params.overflow+'; rounding: '+c.params.rounding+'.',
 'module '+c.moduleName+'(',...(c.timing==='registered'?['  input wire clk,','  input wire rst_n,']:[]),...inputs.map(p=>'  '+decl(p)+','),'  '+decl(output),');'];
 const ex=[];
 inputs.forEach((p,i)=>{lines.push('  wire signed ['+p.width+':0] x'+i+' = '+(p.signed?'{'+p.name+'['+(p.width-1)+'], '+p.name+'}':"{1'b0, "+p.name+'}')+';');ex.push(p.width+1);});
 let rawWidth,rawF,expression;
 if(c.kind==='subtract'){
  rawF=Math.max(...inputs.map(p=>p.fraction));rawWidth=Math.max(...inputs.map((p,i)=>ex[i]+rawF-p.fraction))+1;
  inputs.forEach((p,i)=>lines.push('  wire signed ['+(rawWidth-1)+':0] a'+i+' = {{'+(rawWidth-ex[i])+'{x'+i+'['+(ex[i]-1)+']}}, x'+i+'};'));
  expression='(a0 <<< '+(rawF-inputs[0].fraction)+') - (a1 <<< '+(rawF-inputs[1].fraction)+')';
 }else if(c.kind==='multiply'){rawWidth=ex[0]+ex[1];rawF=inputs[0].fraction+inputs[1].fraction;expression='x0 * x1';}
 else if(c.kind==='gain'){rawWidth=ex[0]+64;rawF=inputs[0].fraction+c.params.gainFraction;expression='x0 * '+lit(64,BigInt(c.params.gainInteger));}
 else{rawWidth=ex[0];rawF=inputs[0].fraction;expression=c.kind==='absolute'?'(x0 < 0) ? -x0 : x0':'x0';}
 let shift=output.fraction-rawF-(c.kind==='integrator'?c.params.stepShift:0);
 const work=Math.max(rawWidth+Math.max(shift,0)+2,output.width+2,-shift+2),sign=output.signed?1:0;
 lines.push('  wire signed ['+(rawWidth-1)+':0] raw_value = '+expression+';',
 '  wire signed ['+(work-1)+':0] wide_value = {{'+(work-rawWidth)+'{raw_value['+(rawWidth-1)+']}}, raw_value};');
 let scaled=shift>=0?'wide_value <<< '+shift:'wide_value >>> '+(-shift);
 if(shift<0&&c.params.rounding==='nearest'){
  const half=lit(work,1n<<BigInt(-shift-1));
  scaled='(wide_value < 0) ? -(((-wide_value) + '+half+') >>> '+(-shift)+') : ((wide_value + '+half+') >>> '+(-shift)+')';
 }
 lines.push('  wire signed ['+(work-1)+':0] scaled_value = '+scaled+';');
 let raw='scaled_value';
 if(c.kind==='integrator'){
  lines.push('  reg '+(output.signed?'signed ':'')+'['+(output.width-1)+':0] state;',
  '  wire signed ['+(work-1)+':0] state_ext = '+(output.signed?'{{'+(work-output.width)+'{state['+(output.width-1)+']}}, state}':'{{'+(work-output.width)+"{1'b0}}, state}")+';',
  '  wire signed ['+(work-1)+':0] accumulated = state_ext + scaled_value;');raw='accumulated';
 }
 let result=raw+'['+(output.width-1)+':0]';
 if(c.params.overflow==='saturate'){
  const lo=output.signed?-(1n<<BigInt(output.width-1)):0n,hi=(1n<<BigInt(output.width-sign))-1n;
  lines.push('  localparam signed ['+(work-1)+':0] MIN_VALUE = '+lit(work,lo)+', MAX_VALUE = '+lit(work,hi)+';');
  result='('+raw+' < MIN_VALUE) ? MIN_VALUE['+(output.width-1)+':0] : (('+raw+' > MAX_VALUE) ? MAX_VALUE['+(output.width-1)+':0] : '+result+')';
 }
 lines.push('  wire ['+(output.width-1)+':0] result_value = '+result+';');
 if(c.kind==='integrator')lines.push('  always @(posedge clk) begin','    if (!rst_n) state <= 0;','    else state <= result_value;','  end','  assign '+output.name+' = state;');
 else if(c.timing==='registered')lines.push('  reg ['+(output.width-1)+':0] output_reg;','  always @(posedge clk) begin','    if (!rst_n) output_reg <= 0;','    else output_reg <= result_value;','  end','  assign '+output.name+' = output_reg;');
 else lines.push('  assign '+output.name+' = result_value;');
 lines.push('endmodule','');return lines.join('\n');
}
function create(value){
 const c=config(value);let ports,verilog,latency,clocked;
 if(c.kind==='filter'){
  const q=D().quantize(c.model),f=c.model.fixed;ports=[{name:'data_in',direction:'input',width:f.inputBits,signed:true,fraction:f.dataFraction},{name:'data_out',direction:'output',width:f.outputBits,signed:true,fraction:f.dataFraction}];
  verilog=D().generateVerilog(c.model,{moduleName:c.moduleName});latency=q.latency;clocked=true;
 }else{ports=c.inputs.concat(c.output);verilog=primitive(c);clocked=c.timing==='registered';latency=clocked?1:0;}
 return {format:'analog-studio-digital-module',version:1,moduleName:c.moduleName,kind:c.kind,config:c,ports,clocked,latency,verilog};
}
function load(value){
 if(typeof value==='string'){if(value.length>1000000)throw Error('模块设计包过大。');value=JSON.parse(value);}
 if(value?.format!=='analog-studio-digital-module'||value.version!==1)throw Error('只能导入已保存的数字模块设计包。');
 const p=create(value.config);
 if(value.moduleName!==p.moduleName||value.kind!==p.kind||value.clocked!==p.clocked||value.latency!==p.latency||!Array.isArray(value.ports)||JSON.stringify(value.ports.map(v=>port(v,v.direction)))!==JSON.stringify(p.ports)||value.verilog!==p.verilog)throw Error('配置、接口与保存的 Verilog 不一致。请从模块设计页重新保存。');
 return p;
}
function empty(){return {version:1,view:'filter',topName:'digital_system',modules:[],instances:[],ports:[],connections:[]};}
function definitions(s){
 const bodies=new Map();for(const n of s.instances){const p=s.modules.find(m=>m.key===n.moduleKey).design;for(const m of p.verilog.matchAll(/\bmodule\s+([A-Za-z_]\w*)\b[\s\S]*?\bendmodule\b/g)){if(bodies.has(m[1])&&bodies.get(m[1])!==m[0])throw Error('模块名 '+m[1]+' 对应不同 Verilog，不能同时使用。请在模块设计页明确命名。');bodies.set(m[1],m[0]);}}return bodies;
}
function endpoint(s,key,source){
 const m=/^([A-Za-z_]\w*):([A-Za-z_]\w*)$/.exec(key);if(!m)throw Error('端点格式错误。');
 const [_,owner,name]=m;
 if(owner==='in'||owner==='out'){
  if((owner==='in')!==source)throw Error('连接方向应为输出到输入。');
  const p=s.ports.find(p=>p.name===name&&p.direction===(source?'input':'output'));if(!p)throw Error('顶层端口不存在。');return {...p,owner};
 }
 const n=s.instances.find(n=>n.id===owner);if(!n)throw Error('模块实例不存在。');
 const p=s.modules.find(p=>p.key===n.moduleKey).design.ports.find(p=>p.name===name&&p.direction===(source?'output':'input'));if(!p)throw Error('连接方向错误或端口不存在。');return {...p,owner};
}
function check(s,complete=false){
 const driven=new Set(),edges=new Map(s.instances.map(n=>[n.id,[]]));
 for(const c of s.connections){const a=endpoint(s,c.from,true),b=endpoint(s,c.to,false);if(!match(a,b))throw Error('接口不匹配：位宽、符号和小数位必须全部相同。');if(driven.has(c.to))throw Error('一个输入只能连接一个驱动。');driven.add(c.to);
  if(edges.has(a.owner)&&edges.has(b.owner)){const n=s.instances.find(n=>n.id===b.owner),p=s.modules.find(p=>p.key===n.moduleKey).design;if(!p.clocked)edges.get(a.owner).push(b.owner);}}
 const visiting=new Set(),done=new Set();function visit(k){if(visiting.has(k))throw Error('存在纯组合反馈环路，请加入打一拍模块或积分状态。');if(done.has(k))return;visiting.add(k);for(const v of edges.get(k))visit(v);visiting.delete(k);done.add(k);}for(const k of edges.keys())visit(k);
 const defs=definitions(s);if(defs.has(s.topName))throw Error('系统顶层名称与导入模块名称重复。');
 const names=new Set(['clk','rst_n']);for(const name of [...s.ports.map(p=>p.name),...s.instances.map(n=>n.id),...s.instances.flatMap(n=>s.modules.find(m=>m.key===n.moduleKey).design.ports.filter(p=>p.direction==='output').map(p=>'n_'+n.id+'_'+p.name))]){if(names.has(name))throw Error('系统名称重复：'+name);names.add(name);}
 if(complete){if(!s.instances.length)throw Error('请先导入已保存的模块设计。');if(!s.ports.some(p=>p.direction==='input')||!s.ports.some(p=>p.direction==='output'))throw Error('请定义系统输入和输出端口。');
  for(const p of s.ports.filter(p=>p.direction==='output'))if(!driven.has('out:'+p.name))throw Error('系统输出 '+p.name+' 尚未连接。');
  for(const n of s.instances)for(const p of s.modules.find(m=>m.key===n.moduleKey).design.ports.filter(p=>p.direction==='input'))if(!driven.has(n.id+':'+p.name))throw Error('实例输入 '+n.id+'.'+p.name+' 尚未连接。');}
 return s;
}
function validateState(v){
 if(v==null)return empty();if(v.version!==1||!['filter','module','system'].includes(v.view)||!Array.isArray(v.modules)||v.modules.length>40||!Array.isArray(v.instances)||v.instances.length>32||!Array.isArray(v.ports)||v.ports.length>32||!Array.isArray(v.connections)||v.connections.length>160)throw Error('系统工作台数据无效或超出容量。');
 const s={version:1,view:v.view,topName:id(v.topName),modules:v.modules.map(m=>({key:id(m.key),design:load(m.design)})),instances:v.instances.map(n=>({id:id(n.id),moduleKey:id(n.moduleKey)})),ports:v.ports.map(p=>{if(!['input','output'].includes(p.direction))throw Error('顶层端口方向无效。');return port(p,p.direction);}),connections:v.connections.map(c=>({from:String(c.from),to:String(c.to)}))};
 if(new Set(s.modules.map(m=>m.key)).size!==s.modules.length||new Set(s.instances.map(m=>m.id)).size!==s.instances.length||new Set(s.ports.map(p=>p.name)).size!==s.ports.length||s.instances.some(n=>['in','out','clk','rst_n'].includes(n.id)||!s.modules.some(m=>m.key===n.moduleKey)))throw Error('模块或实例名称重复，或引用丢失。');
 if(v.layout!==undefined)s.layout=root.DigitalSystemLayout.validateLayout(v.layout,[...s.instances.map(n=>n.id),...s.ports.map(p=>(p.direction==='input'?'in:':'out:')+p.name)]);
 return check(s);
}
function connect(value,from,to){const s=validateState(value);s.connections.push({from,to});return check(s);}
function generateSystem(value){
 const s=check(validateState(value),true),clocked=s.instances.some(n=>s.modules.find(m=>m.key===n.moduleKey).design.clocked),ports=[...(clocked?['input wire clk','input wire rst_n']:[]),...s.ports.map(p=>decl(p))];
 const lines=['// AnalogStudio digital system. Module names and saved HDL are preserved.','// Common clock; synchronous active-low reset. Interfaces are never resized here.','module '+s.topName+'(',ports.map(p=>'  '+p).join(',\n'),');'];
 const signal=key=>{const e=endpoint(s,key,true);return e.owner==='in'?e.name:'n_'+e.owner+'_'+e.name;};
 // Declare all nets before any instance: feedback may reference a later instance.
 for(const n of s.instances)for(const o of s.modules.find(m=>m.key===n.moduleKey).design.ports.filter(o=>o.direction==='output'))lines.push('  '+decl({...o,name:'n_'+n.id+'_'+o.name},'wire').replace('wire wire','wire')+';');
 for(const n of s.instances){const p=s.modules.find(m=>m.key===n.moduleKey).design;
  const pins=[...(p.clocked?['.clk(clk)','.rst_n(rst_n)']:[]),...p.ports.map(o=>'.'+o.name+'('+(o.direction==='output'?'n_'+n.id+'_'+o.name:signal(s.connections.find(c=>c.to===n.id+':'+o.name).from))+')')];lines.push('  '+p.moduleName+' '+n.id+'('+pins.join(', ')+');');}
 for(const o of s.ports.filter(p=>p.direction==='output'))lines.push('  assign '+o.name+' = '+signal(s.connections.find(c=>c.to==='out:'+o.name).from)+';');
 lines.push('endmodule','',...definitions(s).values(),'');return lines.join('\n');
}
root.DigitalModules={types,defaults,config,create,load,fmt,match,describe,id,empty,validateState,connect,check,endpoint,generateSystem};
if(typeof module!=='undefined'&&module.exports)module.exports=root.DigitalModules;
})(typeof window!=='undefined'?window:globalThis);
