/* Saved digital designs: explicit interfaces, immutable HDL, reusable instances. */
(function(root){
'use strict';
if(typeof module!=='undefined'&&module.exports&&!root.DigitalSystemLayout)root.DigitalSystemLayout=require('./digital-system-layout.js');
const copy=x=>JSON.parse(JSON.stringify(x));
const reserved=new Set(('always always_comb always_ff always_latch and assign automatic begin buf bufif0 bufif1 case casex casez cell cmos config deassign default defparam design disable edge else end endcase endconfig endfunction endgenerate endmodule endprimitive endspecify endtable endtask event for force forever fork function generate genvar highz0 highz1 if ifnone incdir include initial inout input instance integer join large liblist library localparam macromodule medium module nand negedge nmos nor noshowcancelled not notif0 notif1 or output parameter pmos posedge primitive pull0 pull1 pulldown pullup pulsestyle_onevent pulsestyle_ondetect rcmos real realtime reg release repeat rnmos rpmos rtran rtranif0 rtranif1 scalared showcancelled signed small specify specparam strong0 strong1 supply0 supply1 table task time tran tranif0 tranif1 tri tri0 tri1 triand trior trireg unsigned use uwire vectored wait wand weak0 weak1 while wire wor xnor xor logic bit byte shortint int longint struct union enum typedef package endpackage import export interface endinterface modport program endprogram class endclass virtual void string const static protected local rand randc constraint solve before inside dist return break continue do foreach unique priority assert assume cover property endproperty sequence endsequence clocking endclocking iff soft this super new null chandle mailbox semaphore process forkjoin join_any join_none accept_on alias bind bins binsof checker context covergroup coverpoint cross endchecker endgroup expect extends extern final first_match global ignore_bins illegal_bins implements implies interconnect intersect let matches nettype nexttime packed randcase randsequence ref reject_on restrict s_always s_eventually s_nexttime s_until s_until_with soft solve static string strong sync_accept_on sync_reject_on tagged throughout timeprecision timeunit type untyped until until_with var weak wildcard with within eventually pure shortreal unique0 wait_order').split(' '));
function id(x){if(typeof x!=='string'||! /^[A-Za-z_][A-Za-z0-9_]{0,63}$/.test(x)||reserved.has(x))throw Error('请输入合法且非保留字的 Verilog 名称。');return x;}
function int(x,lo,hi,label){if(!Number.isInteger(x)||x<lo||x>hi)throw Error(label+' 应为 '+lo+'～'+hi+' 的整数。');return x;}
function fmt(p){if(!p||typeof p.signed!=='boolean')throw Error('接口须明确有符号或无符号。');return {width:int(p.width,1,128,'接口位宽'),signed:p.signed,fraction:int(p.fraction,0,127,'小数位数')};}
function port(p,direction){const q={name:id(p.name),direction,...fmt(p)};if(p.constant===true){q.constant=true;q.format=['bin','dec','hex'].includes(p.format)?p.format:'dec';q.value=String(p.value??'0').replace(/[\s_]/g,'');}return q;}
const constBounds=p=>p.signed?[-(1n<<BigInt(p.width-1)),(1n<<BigInt(p.width-1))-1n]:[0n,(1n<<BigInt(p.width))-1n];
function parseConstant(p){
 let text=String(p.value??'0').replace(/[\s_]/g,'');
 if(!text)throw Error('请输入常数值。');
 let v;
 try{
  if(p.format==='bin')v=BigInt('0b'+text);
  else if(p.format==='hex')v=BigInt('0x'+text);
  else if(p.format==='dec')v=BigInt(text);
  else throw Error('常数进制无效。');
 }catch(e){throw Error('常数值不是合法的 '+p.format+' 数。');}
 const mod=1n<<BigInt(p.width);
 if(p.format!=='dec'){if(v<0n||v>=mod)throw Error('常数值超出位宽。');if(p.signed&&v>=mod/2n)v-=mod;}
 const [lo,hi]=constBounds(p);
 if(v<lo||v>hi)throw Error('常数值超出接口范围。');
 return v;
}
function constLiteral(p){const v=parseConstant(p),w=p.width;if(p.signed)return v<0n?'-'+w+"'sd"+(-v):w+"'sd"+v;return w+"'d"+v;}
const match=(a,b)=>a.width===b.width;
const formatPort=p=>{
 const w=p.width,f=p.fraction;
 if(f===0)return (p.signed?'s':'us')+'['+w+':0]';
 return (p.signed?'s.':'us.')+'['+(w-f)+':'+f+']';
};
const describe=formatPort;
const D=()=>root.DigitalDesign||(typeof require==='function'?require('./digital-design.js'):null);
const types={subtract:'减法器',multiply:'乘法器',absolute:'绝对值',gain:'常系数增益',quantize:'量化器 / 格式转换',delay:'直通 / 延时',integrator:'积分滤波器',dds:'DDS 波形发生器',offset:'偏移二进制转有符号',filter:'已有滤波器'};
function defaults(kind='subtract'){
 if(!types[kind]||kind==='filter')throw Error('请选择基础模块类型。');
 if(kind==='dds')return {kind,moduleName:'dds_wave',timing:'registered',inputs:[{name:'freq_word',width:24,signed:true,fraction:0}],output:{name:'data_out',width:16,signed:true,fraction:0},params:{waveform:'sine',tableLength:256,accWidth:24}};
 if(kind==='offset')return {kind,moduleName:'offset_to_signed',timing:'combinational',inputs:[{name:'data_in',width:16,signed:false,fraction:0}],output:{name:'data_out',width:16,signed:true,fraction:0},params:{mode:'forward',rounding:'floor',overflow:'wrap',gainInteger:1,gainFraction:0,stepShift:8}};
 const f={width:16,signed:true,fraction:8};
 return {kind,moduleName:'digital_'+kind,timing:kind==='integrator'?'registered':'combinational',inputs:(['subtract','multiply'].includes(kind)?['a','b']:['data_in']).map(name=>({name,...f})),output:{name:'data_out',...f,...(kind==='integrator'?{width:24,fraction:16}:{})},params:{rounding:'floor',overflow:'wrap',gainInteger:1,gainFraction:0,stepShift:8}};
}
function config(value){
 if(!value||!types[value.kind])throw Error('不支持的模块类型。');
 const name=id(value.moduleName);
 if(value.kind==='filter')return {kind:'filter',moduleName:name,model:D().fromCoefficients(value.model)};
 if(value.kind==='dds'){
  const base=defaults('dds'),output=port(value.output||base.output,'output');
  if(output.width!==16||!output.signed||output.fraction!==0)throw Error('DDS 输出必须为 16 bit signed、0 位小数。');
  const p={...base.params,...value.params};
  if(!['sine','square','triangle'].includes(p.waveform))throw Error('不支持的 DDS 波形。');
  const tableLength=int(p.tableLength,16,4096,'波表长度');
  if((tableLength&(tableLength-1))!==0)throw Error('波表长度必须是 2 的幂。');
  const accWidth=int(p.accWidth,8,32,'相位累加器位宽');
  if(tableLength>2**accWidth)throw Error('波表长度不能超过 2^累加器位宽。');
  const inputs=(value.inputs||[]).map(v=>port(v,'input'));
  if(inputs.length!==1||inputs[0].name!=='freq_word')throw Error('DDS 必须且只能有 freq_word 一个输入端口。');
  if(inputs[0].width!==accWidth||!inputs[0].signed||inputs[0].fraction!==0)throw Error('freq_word 必须为 signed、0 位小数，位宽等于相位累加器位宽。');
  let output2=null;
  if(p.waveform==='sine'){
   output2=port(value.output2||{name:'data_out_q',direction:'output',width:16,signed:true,fraction:0},'output');
   if(output2.name===output.name)throw Error('正交输出端口名不能与主输出相同。');
   if(output2.width!==16||!output2.signed||output2.fraction!==0)throw Error('DDS 正交输出必须为 16 bit signed、0 位小数。');
  }
  return {kind:'dds',moduleName:name,timing:'registered',inputs,output,output2,params:{waveform:p.waveform,tableLength,accWidth}};
 }
 if(value.kind==='offset'){
  const base=defaults('offset'),inputs=(value.inputs||[]).map(p=>port(p,'input')),output=port(value.output||base.output,'output');
  const mode=(value.params?.mode==='reverse')?'reverse':'forward';
  if(inputs.length!==1||inputs[0].name!=='data_in')throw Error('偏移二进制转换必须且只能有 data_in 一个输入。');
  if(inputs[0].width<2)throw Error('偏移二进制输入位宽至少为 2。');
  if(inputs[0].width!==output.width||inputs[0].fraction!==output.fraction)throw Error('输入输出位宽和小数位必须相同。');
  if(mode==='forward'&&(inputs[0].signed||!output.signed))throw Error('正向转换要求 unsigned 输入、signed 输出。');
  if(mode==='reverse'&&(!inputs[0].signed||output.signed))throw Error('逆向转换要求 signed 输入、unsigned 输出。');
  return {kind:'offset',moduleName:name,timing:'combinational',inputs,output,params:{mode,rounding:'floor',overflow:'wrap',gainInteger:1,gainFraction:0,stepShift:8}};
 }
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
function ddsVerilog(c){
 const N=c.params.tableLength,B=Math.round(Math.log2(N)),AW=c.params.accWidth,A=32767,Q=c.output2;
 const sample=i=>{
  if(c.params.waveform==='sine')return Math.round(A*Math.sin(2*Math.PI*i/N));
  if(c.params.waveform==='square')return i<N/2?A:-A;
  return Math.round(A*(i<N/2?(4*i/N-1):(3-4*i/N)));
 };
 const sv=v=>v<0?"-16'sd"+(-v):"16'sd"+v;
 const step=(50e6/2**AW).toFixed(3);
 const lines=['// DDS waveform generator; '+N+' x 16-bit ROM (BRAM), phase accumulator '+AW+'-bit.',
  '// freq_word +1 = fs / 2^'+AW+'; at 50 MHz = '+step+' Hz per LSB.',
  'module '+c.moduleName+'(','  input wire clk,','  input wire rst_n,','  input wire signed ['+(AW-1)+':0] freq_word,',
  '  output reg signed [15:0] data_out'+(Q?',':''),...(Q?['  output reg signed [15:0] '+Q.name]:[]),');',
  '  reg ['+(AW-1)+':0] phase;',
  '  wire ['+(AW-1)+':0] phase_next = phase + freq_word;',
  '  wire ['+(B-1)+':0] idx = phase_next['+(AW-1)+':'+(AW-B)+'];'];
 if(Q)lines.push('  wire ['+(B-1)+':0] idx_q = idx + '+(N/4)+';');
 lines.push('  (* rom_style = "block" *) reg signed [15:0] rom [0:'+(N-1)+'];','  initial begin');
 for(let i=0;i<N;i++)lines.push('    rom['+i+'] = '+sv(sample(i))+';');
 lines.push('  end','  always @(posedge clk) begin','    if (!rst_n) begin','      phase <= 0;','      data_out <= 0;');
 if(Q)lines.push('      '+Q.name+' <= 0;');
 lines.push('    end else begin','      phase <= phase_next;','      data_out <= rom[idx];');
 if(Q)lines.push('      '+Q.name+' <= rom[idx_q];');
 lines.push('    end','  end','endmodule','');
 return lines.join('\n');
}
function primitive(c){
 if(c.kind==='offset'){
  const w=c.output.width,rev=c.params.mode==='reverse';
  return ['// Offset binary <-> signed: flip the MSB.','module '+c.moduleName+'(','  input wire '+(rev?'signed ':'')+'['+(w-1)+':0] data_in,','  output wire '+(rev?'':'signed ')+'['+(w-1)+':0] data_out',');','  assign data_out = {~data_in['+(w-1)+'], data_in['+(w-2)+':0]};','endmodule',''].join('\n');
 }
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
 if(c.kind==='dds'){ports=c.inputs.concat(c.output,c.output2?[c.output2]:[]);verilog=ddsVerilog(c);clocked=true;latency=1;
 }else if(c.kind==='filter'){
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
 for(const c of s.connections){const a=endpoint(s,c.from,true),b=endpoint(s,c.to,false);if(!match(a,b))throw Error('接口不匹配：位宽必须相同。');if(driven.has(c.to))throw Error('一个输入只能连接一个驱动。');driven.add(c.to);
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
 const s={version:1,view:v.view,topName:id(v.topName),modules:v.modules.map(m=>({key:id(m.key),design:load(m.design)})),instances:v.instances.map(n=>({id:id(n.id),moduleKey:id(n.moduleKey)})),ports:v.ports.map(p=>{
  let q;
  if(p.direction==='constant')q=port({...p,direction:'input',constant:true},'input');
  else if(p.constant===true)q=port(p,'input');
  else{if(!['input','output'].includes(p.direction))throw Error('顶层端口方向无效。');q=port(p,p.direction);}
  if(q.constant){
   if(q.direction!=='input')throw Error('常数只能作为输入激励。');
   if(!['bin','dec','hex'].includes(q.format))throw Error('常数进制必须是 bin/dec/hex。');
   parseConstant(q);q.value=String(q.value);
  }else{delete q.constant;delete q.format;delete q.value;}
  return q;
 }),connections:v.connections.map(c=>({from:String(c.from),to:String(c.to)}))};
 if(new Set(s.modules.map(m=>m.key)).size!==s.modules.length||new Set(s.instances.map(m=>m.id)).size!==s.instances.length||new Set(s.ports.map(p=>p.name)).size!==s.ports.length||s.instances.some(n=>['in','out','clk','rst_n'].includes(n.id)||!s.modules.some(m=>m.key===n.moduleKey)))throw Error('模块或实例名称重复，或引用丢失。');
 if(v.layout!==undefined)s.layout=root.DigitalSystemLayout.validateLayout(v.layout,[...s.instances.map(n=>n.id),...s.ports.map(p=>(p.direction==='input'?'in:':'out:')+p.name)]);
 return check(s);
}
function connect(value,from,to){const s=validateState(value);s.connections.push({from,to});return check(s);}
function generateSystem(value){
 const s=check(validateState(value),true),clocked=s.instances.some(n=>s.modules.find(m=>m.key===n.moduleKey).design.clocked),ports=[...(clocked?['input wire clk','input wire rst_n']:[]),...s.ports.filter(p=>!p.constant).map(p=>decl(p))];
 const lines=['// AnalogStudio digital system. Module names and saved HDL are preserved.','// Common clock; synchronous active-low reset. Interfaces are never resized here.','module '+s.topName+'(',ports.map(p=>'  '+p).join(',\n'),');'];
 const signal=key=>{const e=endpoint(s,key,true);return e.owner==='in'?e.name:'n_'+e.owner+'_'+e.name;};
 // Declare all nets before any instance: feedback may reference a later instance.
  for(const p of s.ports.filter(p=>p.constant))lines.push('  localparam '+(p.signed?'signed ':'')+'['+(p.width-1)+':0] '+p.name+' = '+constLiteral(p)+';');
for(const n of s.instances)for(const o of s.modules.find(m=>m.key===n.moduleKey).design.ports.filter(o=>o.direction==='output'))lines.push('  '+decl({...o,name:'n_'+n.id+'_'+o.name},'wire').replace('wire wire','wire')+';');
 for(const n of s.instances){const p=s.modules.find(m=>m.key===n.moduleKey).design;
  const pins=[...(p.clocked?['.clk(clk)','.rst_n(rst_n)']:[]),...p.ports.map(o=>'.'+o.name+'('+(o.direction==='output'?'n_'+n.id+'_'+o.name:signal(s.connections.find(c=>c.to===n.id+':'+o.name).from))+')')];lines.push('  '+p.moduleName+' '+n.id+'('+pins.join(', ')+');');}
 for(const o of s.ports.filter(p=>p.direction==='output'))lines.push('  assign '+o.name+' = '+signal(s.connections.find(c=>c.to==='out:'+o.name).from)+';');
 lines.push('endmodule','',...definitions(s).values(),'');return lines.join('\n');
}
root.DigitalModules={types,defaults,config,create,load,fmt,match,describe,format:formatPort,id,empty,validateState,connect,check,endpoint,generateSystem};
if(typeof module!=='undefined'&&module.exports)module.exports=root.DigitalModules;
})(typeof window!=='undefined'?window:globalThis);
