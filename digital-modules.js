/* Saved digital designs: explicit interfaces, immutable HDL, reusable instances. */
(function(root){
'use strict';
if(typeof module!=='undefined'&&module.exports&&!root.DigitalSystemLayout)root.DigitalSystemLayout=require('./digital-system-layout.js');
const copy=x=>JSON.parse(JSON.stringify(x));
const reserved=new Set(('always always_comb always_ff always_latch and assign automatic begin buf bufif0 bufif1 case casex casez cell cmos config deassign default defparam design disable edge else end endcase endconfig endfunction endgenerate endmodule endprimitive endspecify endtable endtask event for force forever fork function generate genvar highz0 highz1 if ifnone incdir include initial inout input instance integer join large liblist library localparam macromodule medium module nand negedge nmos nor noshowcancelled not notif0 notif1 or output parameter pmos posedge primitive pull0 pull1 pulldown pullup pulsestyle_onevent pulsestyle_ondetect rcmos real realtime reg release repeat rnmos rpmos rtran rtranif0 rtranif1 scalared showcancelled signed small specify specparam strong0 strong1 supply0 supply1 table task time tran tranif0 tranif1 tri tri0 tri1 triand trior trireg unsigned use uwire vectored wait wand weak0 weak1 while wire wor xnor xor logic bit byte shortint int longint struct union enum typedef package endpackage import export interface endinterface modport program endprogram class endclass virtual void string const static protected local rand randc constraint solve before inside dist return break continue do foreach unique priority assert assume cover property endproperty sequence endsequence clocking endclocking iff soft this super new null chandle mailbox semaphore process forkjoin join_any join_none accept_on alias bind bins binsof checker context covergroup coverpoint cross endchecker endgroup expect extends extern final first_match global ignore_bins illegal_bins implements implies interconnect intersect let matches nettype nexttime packed randcase randsequence ref reject_on restrict s_always s_eventually s_nexttime s_until s_until_with soft solve static string strong sync_accept_on sync_reject_on tagged throughout timeprecision timeunit type untyped until until_with var weak wildcard with within eventually pure shortreal unique0 wait_order').split(' '));
function id(x){if(typeof x!=='string'||! /^[A-Za-z_][A-Za-z0-9_]{0,63}$/.test(x)||reserved.has(x))throw Error('请输入合法且非保留字的 Verilog 名称。');return x;}
function int(x,lo,hi,label){if(!Number.isInteger(x)||x<lo||x>hi)throw Error(label+' 应为 '+lo+'～'+hi+' 的整数。');return x;}
function fmt(p){if(!p||typeof p.signed!=='boolean')throw Error('接口须明确有符号或无符号。');return {width:int(p.width,1,128,'接口位宽'),signed:p.signed,fraction:int(p.fraction,0,127,'小数位数')};}
function port(p,direction){return {name:id(p.name),direction,...fmt(p)};}
const match=(a,b)=>a.width===b.width&&a.signed===b.signed&&a.fraction===b.fraction;
const describe=p=>p.width+' 位 · '+(p.signed?'signed':'unsigned')+' · F='+p.fraction;
const D=()=>root.DigitalDesign||(typeof require==='function'?require('./digital-design.js'):null);
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
function legacyPrimitive(c){
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
// Keep expressions at their actual arithmetic precision. Assignment handles
// ordinary extension/truncation; intermediates are needed only before rounding,
// a precision-losing right shift, or a repeated saturation comparison.
function primitive(c){
 const out=c.output,lines=['// '+types[c.kind]+'; explicit interface formats.',
  '// Output overflow: '+c.params.overflow+'; rounding: '+c.params.rounding+'.',
  'module '+c.moduleName+'(',...(c.timing==='registered'?['  input wire clk,','  input wire rst_n,']:[]),
  ...c.inputs.map(p=>'  '+decl(p)+','),
  '  output '+(c.timing==='registered'?'reg ':'wire ')+(out.signed?'signed ':'')+'['+(out.width-1)+':0] '+out.name,');'];
 const bounds=p=>p.signed?[-(1n<<BigInt(p.width-1)),(1n<<BigInt(p.width-1))-1n]:[0n,(1n<<BigInt(p.width))-1n];
 const bits=(lo,hi,signed)=>{let w=1;while(signed?(lo<-(1n<<BigInt(w-1))||hi>=(1n<<BigInt(w-1))):hi>=(1n<<BigInt(w)))w++;return w;};
 const literal=(w,n,signed)=>n<0n?lit(w,n):w+(signed?"'sd":"'d")+n;
 const node=(text,lo,hi,signed,leaf=false)=>({text,lo,hi,signed,width:bits(lo,hi,signed),leaf});
 const constant=n=>({...node(n===0n?"1'b0":literal(bits(n,n,n<0n),n,n<0n),n,n,n<0n,true),constant:true});
 const input=p=>{const [lo,hi]=bounds(p);return {...node(p.name,lo,hi,p.signed,true),width:p.width};};
 const group=n=>n.leaf?n.text:'('+n.text+')';
 const used=new Set([...c.inputs.map(p=>p.name),out.name,'clk','rst_n']);
 function fresh(base){let name=base,i=1;while(used.has(name))name=base+'_'+i++;used.add(name);return name;}
 const signed=n=>{if(n.signed)return group(n);if(n.constant)return lit(bits(n.lo,n.hi,true),n.lo);n=hold(n,'unsigned_value');return "$signed({1'b0, "+n.text+'})';};
 function hold(n,name){if(n.leaf)return n;name=fresh(name);lines.push('  wire '+(n.signed?'signed ':'')+'['+(n.width-1)+':0] '+name+' = '+n.text+';');return {...n,text:name,leaf:true};}
 function left(n,k){if(!k||n.lo===0n&&n.hi===0n)return n;return node(group(n)+(n.signed?' <<< ':' << ')+k,n.lo<<BigInt(k),n.hi<<BigInt(k),n.signed);}
 function add(a,b,op){const isSigned=a.signed||b.signed||op==='-',lo=op==='-'?a.lo-b.hi:a.lo+b.lo,hi=op==='-'?a.hi-b.lo:a.hi+b.hi;return node((isSigned?signed(a):group(a))+' '+op+' '+(isSigned?signed(b):group(b)),lo,hi,isSigned);}
 function multiply(a,b){const range=[a.lo*b.lo,a.lo*b.hi,a.hi*b.lo,a.hi*b.hi],isSigned=a.signed||b.signed;return node((isSigned?signed(a):group(a))+' * '+(isSigned?signed(b):group(b)),range.reduce((x,y)=>x<y?x:y),range.reduce((x,y)=>x>y?x:y),isSigned);}
 let value=input(c.inputs[0]),rawF=c.inputs[0].fraction,extraShift=0,rawName='raw_value';
 if(c.kind==='subtract'){
  rawF=Math.max(...c.inputs.map(p=>p.fraction));
  value=add(left(input(c.inputs[0]),rawF-c.inputs[0].fraction),left(input(c.inputs[1]),rawF-c.inputs[1].fraction),'-');rawName='difference';
 }else if(c.kind==='multiply'){
  value=multiply(value,input(c.inputs[1]));rawF+=c.inputs[1].fraction;rawName='product';
 }else if(c.kind==='gain'){
  let k=BigInt(c.params.gainInteger);rawF+=c.params.gainFraction;rawName='product';
  if(k===0n)value=constant(0n);
  else{
   while(k%2n===0n){k/=2n;extraShift++;}
   if(k===-1n)value=node('-'+signed(value),-value.hi,-value.lo,true);
   else if(k!==1n)value=multiply(value,constant(k));
  }
 }else if(c.kind==='absolute'&&value.signed){
  // The magnitude of the most-negative signed number fits in an unsigned bus
  // of the same width. $unsigned also gives correct extension on wider outputs.
  value=node('$unsigned('+value.text+'['+(value.width-1)+'] ? -'+value.text+' : '+value.text+')',0n,-value.lo,false);
 }
 const shift=out.fraction-rawF+extraShift-(c.kind==='integrator'?c.params.stepShift:0);
 if(shift>0)value=left(value,shift);
 else if(shift<0){
  const d=-shift,half=1n<<BigInt(d-1),nearest=n=>n<0n?-((-n+half)>>BigInt(d)):(n+half)>>BigInt(d);
  const lo=c.params.rounding==='nearest'?nearest(value.lo):value.lo>>BigInt(d),hi=c.params.rounding==='nearest'?nearest(value.hi):value.hi>>BigInt(d);
  if(lo===hi)value=constant(lo);
  else{
   value=hold(value,rawName);
   if(c.params.rounding==='nearest'){
    // A half-LSB bias (one less for negative values) implements ties away
    // from zero with one addition, without negating the full data path twice.
    const biasLo=value.lo+(value.lo<0n?half-1n:half),biasHi=value.hi+(value.hi<0n?half-1n:half);
    const w=Math.max(value.width,bits(biasLo,biasHi,value.signed));
    const bias=value.lo<0n?'('+value.text+'['+(value.width-1)+'] ? '+literal(w,half-1n,value.signed)+' : '+literal(w,half,value.signed)+')':literal(w,half,value.signed);
    const rounded=fresh('rounded');lines.push('  wire '+(value.signed?'signed ':'')+'['+(w-1)+':0] '+rounded+' = '+value.text+' + '+bias+';');
    value=node(rounded+(value.signed?' >>> ':' >> ')+d,lo,hi,value.signed);
   }else value=node(value.text+(value.signed?' >>> ':' >> ')+d,lo,hi,value.signed);
  }
 }
 if(c.kind==='integrator')value=add(input(out),value,'+');
 const [min,max]=bounds(out),low=c.params.overflow==='saturate'&&value.lo<min,high=c.params.overflow==='saturate'&&value.hi>max;
 let result=value.text;
 if(low||high){
  value=hold(value,'scaled_value');result=value.text;
  if(high)result='('+value.text+' > '+literal(value.width,max,value.signed)+') ? '+literal(out.width,max,out.signed)+' : '+result;
  if(low)result='('+value.text+' < '+literal(value.width,min,value.signed)+') ? '+literal(out.width,min,out.signed)+' : ('+result+')';
 }
 if(c.timing==='registered')lines.push('  always @(posedge clk) begin','    if (!rst_n) '+out.name+" <= "+out.width+"'d0;",'    else '+out.name+' <= '+result+';','  end');
 else lines.push('  assign '+out.name+' = '+result+';');
 lines.push('endmodule','');return lines.join('\n');
}

// Validate and retain previously saved, now-withdrawn filter HDL only.
// New filter generation always uses the restored original DigitalSOS.
function withdrawnFilter(m,q,name){
 let source=root.DigitalSOS.verilog(m,q,name);
 const kinds=[...new Set(q.sections.map(s=>s.order===2?'so':'fo'))];
 for(const kind of kinds){
  const order=kind==='so'?2:1,start=source.indexOf('module '+name+'_'+kind+' #('),end=source.indexOf('endmodule',start)+'endmodule'.length;
  const original=source.slice(start,end),header=original.slice(0,original.indexOf('  reg signed'));
  const rounding=original.slice(original.indexOf('  wire signed [AW-1:0] acc;'),original.indexOf('  (* use_dsp'));
  const lines=[header.trimEnd(),
   '  reg signed [OW-1:0] y1'+(order===2?', y2':'')+';',
   ...(order===2?['  reg signed [IW-1:0] x1;','  reg signed [AW-1:0] history;']:['  reg signed [IW+CW-1:0] history;']),
   rounding.trimEnd()];
  function product(p,signal,width,extend=true){
   if(p[0]==='A'&&order===1)lines.push('  reg signed ['+width+'+CW-1:0] P_'+p+';',
    '  (* use_dsp = "yes" *) wire signed ['+width+'+CW-1:0] M_'+p+' = $signed(next_y) * $signed('+p+');');
   else lines.push('  (* use_dsp = "yes" *) wire signed ['+width+'+CW-1:0] P_'+p+' = $signed('+signal+') * $signed('+p+');');if(extend)lines.push(
   '  wire signed [AW-1:0] E_'+p+' = {{(AW-('+width+'+CW)){P_'+p+'['+width+'+CW-1]}}, P_'+p+'};');}
  product('B0','data_in','IW');product('B1','data_in','IW',order===2);product('A1','y1','OW');
  // a+b-c: the shifted carry vector has bit zero clear, so the
  // two's-complement +1 fits in that bit without another compressor stage.
  function subtract3(a,b,c,prefix,result){
   lines.push('  wire [AW-1:0] '+prefix+'_sum = '+a+' ^ '+b+' ^ ~'+c+';',
    '  wire [AW-1:0] '+prefix+'_carry = ((('+a+' & '+b+') | ('+a+' & ~'+c+') | ('+b+' & ~'+c+')) << 1) | {{(AW-1){1\'b0}}, 1\'b1};',
    '  assign '+result+' = $signed('+prefix+'_sum) + $signed('+prefix+'_carry);');
  }
  if(order===2){
   product('B2','x1','IW');product('A2','y1','OW');
   lines.push('  wire signed [AW-1:0] history_next;');
   subtract3('E_B1','E_B2','E_A2','hist','history_next');
   lines.push('  wire signed [AW-1:0] E_history = history;');
  }else lines.push('  wire signed [AW-1:0] E_history = {{(AW-(IW+CW)){history[IW+CW-1]}}, history};');
  subtract3('E_B0','E_history','E_A1','out','acc');
  lines.push('  always @(posedge clk) begin','    if (!rst_n) begin',
   '      history <= 0; y1 <= 0;'+(order===2?' x1 <= 0; y2 <= 0;':' P_A1 <= 0;'),
   '    end else begin','      history <= '+(order===2?'history_next':'P_B1')+';',
   ...(order===1?['      P_A1 <= M_A1;']:[]),
   '      y1 <= next_y;'+(order===2?' x1 <= data_in; y2 <= y1;':''),'    end','  end',
   '  assign data_out = y'+order+'; // '+order+' registered cycle'+(order===2?'s':'')+'; weighted history keeps sample alignment.',
   'endmodule');
  source=source.slice(0,start)+lines.join('\n')+source.slice(end);
 }
 return source;
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
 if(value.moduleName!==p.moduleName||value.kind!==p.kind||value.clocked!==p.clocked||value.latency!==p.latency||!Array.isArray(value.ports)||JSON.stringify(value.ports.map(v=>port(v,v.direction)))!==JSON.stringify(p.ports))throw Error('配置、接口与保存的 Verilog 不一致。请从模块设计页重新保存。');
 if(value.verilog!==p.verilog){
  const legacy=p.kind==='filter'?withdrawnFilter(p.config.model,D().quantize(p.config.model),p.moduleName):legacyPrimitive(p.config);
  if(value.verilog!==legacy)throw Error('配置、接口与保存的 Verilog 不一致。请从模块设计页重新保存。');
  // Old validated packages keep the exact source the user saved. Editing and
  // saving again explicitly generates the concise implementation.
  p.verilog=value.verilog;
 }
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
