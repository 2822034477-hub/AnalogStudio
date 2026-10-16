/* Bounded real SOS math and four-port, one-sample-per-clock RTL. No external dependencies. */
(function(root){
'use strict';
const MAX_ORDER=8,cache=new Map();
const mul=(a,b)=>{const c=Array(a.length+b.length-1).fill(0);a.forEach((x,i)=>b.forEach((y,j)=>c[i+j]+=x*y));return c;};
const trim=c=>{c=c.slice();while(c.length>1&&c.at(-1)===0)c.pop();return c;};
const cmul=(a,b)=>({re:a.re*b.re-a.im*b.im,im:a.re*b.im+a.im*b.re});
const sub=(a,b)=>({re:a.re-b.re,im:a.im-b.im});
const div=(a,b)=>{const q=b.re*b.re+b.im*b.im;return {re:(a.re*b.re+a.im*b.im)/q,im:(a.im*b.re-a.re*b.im)/q};};
const abs=z=>Math.hypot(z.re,z.im),clone=x=>JSON.parse(JSON.stringify(x));
function polynomial(groups){let c=[1];for(const r of groups)c=mul(c,r.im?[1,-2*r.re,r.re*r.re+r.im*r.im]:[1,-r.re]);return trim(c);}
function same(a,b,tol=1e-9){a=trim(a);b=trim(b);return a.length===b.length&&a.every((x,i)=>Math.abs(x-b[i])<=tol*Math.max(1,Math.abs(x),Math.abs(b[i])));}
function smallRoots(c){
 if(c.length<2)return [];
 if(c.length===2)return [{re:-c[1]/c[0],im:0}];
 const a=c[0],b=c[1],d=c[2],disc=b*b-4*a*d;
 if(disc<0)return [{re:-b/(2*a),im:Math.sqrt(-disc)/(2*Math.abs(a))},{re:-b/(2*a),im:-Math.sqrt(-disc)/(2*Math.abs(a))}];
 const q=-.5*(b+(b>=0?1:-1)*Math.sqrt(disc));return q===0?[{re:0,im:0},{re:0,im:0}]:[{re:q/a,im:0},{re:d/q,im:0}];
}
function roots(coefficients){
 let c=coefficients.slice();while(c.length&&c[0]===0)c.shift();if(c.length<2)return [];
 const key=JSON.stringify(c);if(cache.has(key))return clone(cache.get(key));
 const origins=[];while(c.length>1&&c.at(-1)===0){origins.push({re:0,im:0});c.pop();}
 if(c.length<=3)return smallRoots(c).concat(origins);
 if(c.length>MAX_ORDER+1)throw Error('Polynomial order exceeds '+MAX_ORDER+'.');
 const n=c.length-1,scale=Math.max(...c.slice(1).map((x,i)=>Math.abs(x/c[0])**(1/(i+1))));
 const a=c.map((x,i)=>x/c[0]/scale**i);
 function evaluate(z){let p={re:1,im:0},d={re:0,im:0};for(let i=1;i<=n;i++){d=cmul(d,z);d.re+=p.re;d.im+=p.im;p=cmul(p,z);p.re+=a[i];}return {p,d};}
 let answer=null;
 for(let attempt=0;attempt<3&&!answer;attempt++){
  let z=Array.from({length:n},(_,i)=>({re:1.25*Math.cos(2*Math.PI*(i+.27+attempt*.13)/n),im:1.25*Math.sin(2*Math.PI*(i+.27+attempt*.13)/n)}));
  for(let iter=0;iter<800;iter++){
   let largest=0;const next=z.map((x,i)=>{const {p,d}=evaluate(x),w=div(p,d);let sum={re:0,im:0};for(let j=0;j<n;j++)if(i!==j){const v=div({re:1,im:0},sub(x,z[j]));sum.re+=v.re;sum.im+=v.im;}const product=cmul(w,sum),delta=div(w,{re:1-product.re,im:-product.im});largest=Math.max(largest,abs(delta));return sub(x,delta);});z=next;
   if(z.some(x=>!Number.isFinite(x.re+x.im)))break;
   if(largest<2e-13){answer=z.map(x=>({re:x.re*scale,im:Math.abs(x.im)<1e-9?0:x.im*scale}));break;}
  }
 }
 if(!answer)throw Error('高阶传递函数求根未可靠收敛；请提供明确的零极点因子（重根优先使用 ZPK）。');
 // Near-coincident TF roots are ill-conditioned; do not invent a multiplicity or split a real root.
 for(let i=0;i<answer.length;i++)for(let j=0;j<i;j++)if(abs(sub(answer[i],answer[j]))<1e-6*Math.max(1,abs(answer[i])))throw Error('高阶传递函数含近重根，无法可靠判定；请使用带重数的零极点输入。');
 const groups=groupExpanded(answer),expanded=groups.flatMap(r=>r.im?[r,{re:r.re,im:-r.im}]:[r]);
 if(!same(polynomial(groups),c.map(x=>x/c[0]),1e-8))throw Error('高阶根重建校验失败；请使用零极点输入或改善系数精度。');
 const result=expanded.concat(origins);if(cache.size>64)cache.clear();cache.set(key,result);return clone(result);
}
function groupExpanded(values){
 const pending=values.map(r=>({...r})),out=[];
 while(pending.length){const r=pending.shift();if(!r.im){out.push({re:r.re,im:0});continue;}
  const j=pending.findIndex(x=>Math.abs(x.re-r.re)<2e-7*Math.max(1,abs(r))&&Math.abs(x.im+r.im)<2e-7*Math.max(1,abs(r)));
  if(j<0)throw Error('根无法配成实系数共轭对。');const q=pending.splice(j,1)[0];out.push({re:(r.re+q.re)/2,im:(Math.abs(r.im)+Math.abs(q.im))/2});
 }
 return out.sort((a,b)=>a.re-b.re||a.im-b.im);
}
function validateFactors(f,m){
 if(!f||typeof f!=='object'||Array.isArray(f))throw Error('Invalid factor metadata.');const out={};
 for(const kind of ['zeros','poles']){if(!Array.isArray(f[kind])||f[kind].length>MAX_ORDER)throw Error('Invalid factor metadata.');out[kind]=f[kind].map(r=>{if(!r||typeof r.re!=='number'||typeof r.im!=='number'||!Number.isFinite(r.re)||!Number.isFinite(r.im)||r.im<0||abs(r)>100)throw Error('Invalid factor coordinates.');return {re:r.re,im:r.im};}).filter(r=>r.re!==0||r.im!==0);if(out[kind].reduce((n,r)=>n+(r.im?2:1),0)>MAX_ORDER)throw Error('Factor order exceeds 8.');}
 let delay=m.b.findIndex(x=>x!==0);if(delay<0)delay=0;
 if(!same(polynomial(out.poles),m.a,1e-10)||(!m.b.every(x=>x===0)&&!same(polynomial(out.zeros).map(x=>x*m.b[delay]),m.b.slice(delay),1e-10)))throw Error('Factor metadata does not match coefficients.');
 if(m.b.every(x=>x===0)){const delay=f.delaySamples??0;if(!Number.isInteger(delay)||delay<0||delay>MAX_ORDER||out.zeros.reduce((n,r)=>n+(r.im?2:1),0)+delay>MAX_ORDER)throw Error('Invalid zero-gain shape delay.');out.delaySamples=delay;}return out;
}
function factorRoots(m){
 let delay=m.b.findIndex(x=>x!==0);if(delay<0)delay=0;
 const f=m.factors||{zeros:m.b.every(x=>x===0)?[]:groupExpanded(roots(m.b.slice(delay))),poles:groupExpanded(roots(m.a))};
 return {...clone(f),gain:m.b[delay],delaySamples:m.b.every(x=>x===0)?f.delaySamples??0:delay};
}
function reuseFactors(m,previous){
 if(previous.factors&&m.b.every(x=>x===0)&&previous.b.every(x=>x===0))return {...clone(previous.factors),poles:same(previous.a,m.a,1e-13)?clone(previous.factors.poles):groupExpanded(roots(m.a))};
 if(!previous.factors||Math.max(m.a.length,m.b.length)<=3)return undefined;
 let delay=m.b.findIndex(x=>x!==0);if(delay<0)delay=0;
 const numerator=m.b.slice(delay),gain=numerator[0];
 const poles=same(polynomial(previous.factors.poles),m.a,1e-13)?clone(previous.factors.poles):groupExpanded(roots(m.a));
 const zeros=gain===0?[]:same(polynomial(previous.factors.zeros).map(x=>x*gain),numerator,1e-13)?clone(previous.factors.zeros):groupExpanded(roots(numerator));
 return {zeros,poles};
}
function pack(groups){
 const real=groups.filter(r=>!r.im).sort((a,b)=>a.re-b.re),complex=groups.filter(r=>r.im).map(r=>({roots:[r],c:polynomial([r]),radius:abs(r)})),out=complex;
 while(real.length){const pair=real.splice(0,2);out.push({roots:pair,c:polynomial(pair),radius:Math.max(...pair.map(abs))});}
 return out.sort((a,b)=>a.radius-b.radius);
}
function peak(b,a){let p=0;for(let i=0;i<=1024;i++){const w=Math.PI*i/1024,sum=c=>c.reduce((v,x,j)=>({re:v.re+x*Math.cos(w*j),im:v.im-x*Math.sin(w*j)}),{re:0,im:0}),den=abs(sum(a));if(den<1e-13)throw Error('SOS 节在单位圆采样点奇异，无法可靠分配增益。');p=Math.max(p,abs(sum(b))/den);}return p;}
function timing(sections,delaySamples){
 const stages=sections.map(s=>({...s,order:Math.max(s.a.length,s.b.length)-1}));
 for(const s of stages)s.latency=Math.max(1,s.order); // A zero-order gain remains a sampled one-register interface.
 const filterLatency=stages.reduce((n,s)=>n+s.latency,0),latency=filterLatency+delaySamples;
 return {sections:stages,delaySamples,filterLatency,latency,edgeOffset:latency-1,pipelineDelay:filterLatency-1};
}
function sections(m){
 // Separate model z^-d from hardware register stages, also for low-order/pure-delay filters.
 const z=factorRoots(m);
 if(Math.max(m.a.length,m.b.length)<=3)return timing([{b:m.b.every(x=>x===0)?[0]:m.b.slice(z.delaySamples),a:m.a.slice()}],z.delaySamples);
 const ps=pack(z.poles),zs=pack(z.zeros),n=Math.max(1,ps.length,zs.length),out=[];
 for(let i=0;i<n;i++){
  const p=ps[i]||{c:[1],radius:0,roots:[]};let j=0;
  if(zs.length)for(let k=1;k<zs.length;k++)if(Math.abs(zs[k].radius-p.radius)<Math.abs(zs[j].radius-p.radius))j=k;
  out.push({a:p.c,b:zs.length?zs.splice(j,1)[0].c:[1]});
 }
 if(z.gain===0){out.forEach((s,i)=>s.b=s.b.map(x=>i?x:0));}
 else{
  const peaks=out.map(s=>peak(s.b,s.a));
  const target=Math.exp((Math.log(Math.abs(z.gain))+peaks.reduce((s,p)=>s+Math.log(p),0))/n);
  let product=1;out.forEach((s,i)=>{const g=i===n-1?z.gain/product:(i===0?Math.sign(z.gain):1)*target/peaks[i];product*=g;s.b=s.b.map(x=>x*g);});
 }
 const b=Array(z.delaySamples).fill(0).concat(out.reduce((p,s)=>mul(p,s.b),[1])),a=out.reduce((p,s)=>mul(p,s.a),[1]);
 if(!same(b,m.b,1e-8)||!same(a,m.a,1e-8))throw Error('SOS 重建与输入传递函数不一致，已停止导出。');
 return timing(out,z.delaySamples);
}
function evaluateFactors(m,w){
 const z=factorRoots(m),unit={re:Math.cos(w),im:-Math.sin(w)};
 let n={re:z.gain*Math.cos(w*z.delaySamples),im:-z.gain*Math.sin(w*z.delaySamples)},d={re:1,im:0};
 for(const kind of ['zeros','poles'])for(const r of z[kind])for(const sign of r.im?[1,-1]:[1]){const v=cmul({re:r.re,im:sign*r.im},unit),factor={re:1-v.re,im:-v.im};if(kind==='zeros')n=cmul(n,factor);else d=cmul(d,factor);}
 return {n,d};
}
function runFloat(m,inputs){
 const plan=sections(m);let signal=inputs.map((x,n)=>n>=plan.delaySamples?inputs[n-plan.delaySamples]:0);
 for(const section of plan.sections){const y=[];signal.forEach((x,n)=>{let v=0;section.b.forEach((b,k)=>{if(n>=k)v+=b*signal[n-k];});section.a.slice(1).forEach((a,k)=>{if(n>k)v-=a*y[n-k-1];});if(!Number.isFinite(v)||Math.abs(v)>1e12)throw Error('Response exceeded ±10^12; reduce duration, gain, or pole radius.');y.push(v);});signal=y;}return signal;
}
const round=x=>x<0?-Math.floor(-x+.5):Math.floor(x+.5);
function quantize(m){
 const f=m.fixed;
 if(f.inputBits!==f.outputBits)throw Error('四端口要求输入输出同位宽；旧工程请在输入位宽栏重新设置统一 IN_WIDTH。');
 const sos=sections(m),scale=2**f.coefficientFraction,min=-(2**(f.coefficientBits-1)),max=2**(f.coefficientBits-1)-1;
 let required=0;
 const quant=sos.sections.map((s,i)=>{
  const coefficient=x=>{const v=round(x*scale);if(v<min||v>max)throw Error('Coefficient '+x+' cannot fit signed '+f.coefficientBits+'-bit Q'+f.coefficientFraction+' (SOS '+(i+1)+').');return v;};
  const b=s.b.map(coefficient),a=[scale,...s.a.slice(1).map(coefficient)];
  if(s.b.some(x=>x!==0)&&b.every(x=>x===0))throw Error('SOS '+(i+1)+' 分子量化为全零；请提高系数精度或调整增益。');
  const inputBits=i?f.sectionBits:f.inputBits,outputBits=i===sos.sections.length-1?f.inputBits:f.sectionBits;
  const needed=Math.max(inputBits,outputBits)+f.coefficientBits+Math.ceil(Math.log2(b.length+a.length-1))+1;required=Math.max(required,needed);
  return {b,a,order:s.order,latency:s.latency,inputBits,outputBits,requiredAccumulatorBits:needed};
 });
 if(f.accumulatorBits<required)throw Error('Accumulator requires at least '+required+' bits (configured '+f.accumulatorBits+').');
 const floats=quant.map(s=>({b:s.b.map(x=>x/scale),a:s.a.map(x=>x/scale)}));
 const qm={...m,b:trim(Array(sos.delaySamples).fill(0).concat(floats.reduce((p,s)=>mul(p,s.b),[1]))),a:trim(floats.reduce((p,s)=>mul(p,s.a),[1]))};
 delete qm.factors;
 if(Math.max(qm.a.length,qm.b.length)>3){qm.factors={zeros:[],poles:[]};for(const s of floats){let start=s.b.findIndex(x=>x!==0);if(start<0)start=0;qm.factors.zeros.push(...groupExpanded(roots(trim(s.b.slice(start)))));qm.factors.poles.push(...groupExpanded(roots(trim(s.a))));}if(qm.b.every(x=>x===0))qm.factors.zeros=[];}
 return {...sos,sections:quant,scale,requiredAccumulatorBits:required,model:qm,b:quant.length===1?Array(sos.delaySamples).fill(0).concat(quant[0].b):null,a:quant.length===1?quant[0].a:null};
}
function runFixed(m,inputs){
 const q=quantize(m),f=m.fixed,lo=-(2**(f.inputBits-1)),hi=-lo-1;
 if(!Array.isArray(inputs)||inputs.length>100000||inputs.some(x=>!Number.isSafeInteger(x)||x<lo||x>hi))throw Error('Fixed inputs must be signed input-width integers.');
 let signal=inputs.map((x,n)=>n>=q.delaySamples?inputs[n-q.delaySamples]:0),sectionRuns=[];
 for(const s of q.sections){
  const y=[],accumulators=[],saturated=[],min=-(1n<<BigInt(s.outputBits-1)),max=-min-1n;
  signal.forEach((x,n)=>{let acc=0n;s.b.forEach((b,k)=>{if(n>=k)acc+=BigInt(b)*BigInt(signal[n-k]);});s.a.slice(1).forEach((a,k)=>{if(n>k)acc-=BigInt(a)*BigInt(y[n-k-1]);});let v;
   if(f.rounding==='nearest'&&f.coefficientFraction){const h=1n<<BigInt(f.coefficientFraction-1);v=((acc<0n?-acc:acc)+h)>>BigInt(f.coefficientFraction);if(acc<0n)v=-v;}else v=acc>>BigInt(f.coefficientFraction);
   const out=v<min?min:v>max?max:v;y.push(Number(out));accumulators.push(acc.toString());saturated.push(out!==v);
  });sectionRuns.push({raw:y,accumulators,saturated,saturationCount:saturated.filter(Boolean).length});signal=y;
 }
 const last=sectionRuns.at(-1),clockRaw=Array(q.pipelineDelay).fill(0).concat(signal).slice(0,inputs.length);
 return {...last,values:signal.map(x=>x/2**f.dataFraction),clockRaw,clockValues:clockRaw.map(x=>x/2**f.dataFraction),pipelineDelay:q.pipelineDelay,latency:q.latency,filterLatency:q.filterLatency,edgeOffset:q.edgeOffset,sections:sectionRuns,saturationCount:sectionRuns.reduce((s,r)=>s+r.saturationCount,0)};
}
const literal=(bits,n)=>n<0?'-'+bits+"'sd"+Math.abs(n):bits+"'sd"+n;
function verilog(m,q,name){
 const f=m.fixed,guard=f.sectionBits-f.inputBits,accGuard=f.accumulatorBits-f.inputBits;
 const lines=['`timescale 1ns/1ps','module '+name+' #(', '  parameter integer IN_WIDTH = '+f.inputBits,') (',
  '  input clk, // Sample clock: '+m.sampleRate+' Hz; one input per rising edge.',
  '  input rst_n,','  input signed [IN_WIDTH-1:0] data_in,','  output reg signed [IN_WIDTH-1:0] data_out',');',
  '  localparam integer COEFF_WIDTH = '+f.coefficientBits+', COEFF_FRAC = '+f.coefficientFraction+';',
  '  localparam integer DATA_FRAC = '+f.dataFraction+', SECTION_WIDTH = IN_WIDTH + '+guard+';',
  '  localparam integer ACC_WIDTH = IN_WIDTH + '+accGuard+';',
  '  localparam integer FILTER_CYCLES = '+q.filterLatency+', MODEL_DELAY = '+q.delaySamples+';',
  '  localparam integer LATENCY_CYCLES = '+q.latency+', EDGE_OFFSET = '+q.edgeOffset+';',
  '  // Capture edge is cycle 1; output follows at capture + EDGE_OFFSET edges.',
  '  generate if (IN_WIDTH < 8 || IN_WIDTH > 24 || DATA_FRAC > IN_WIDTH-2 || SECTION_WIDTH > 32 || ACC_WIDTH > 64) begin : bad_width',
  '    INVALID_IN_WIDTH_CONFIGURATION invalid_configuration();','  end endgenerate'];
 if(q.delaySamples)lines.push('  reg signed [IN_WIDTH-1:0] delay_line [0:MODEL_DELAY-1];','  integer d;',
  '  always @(posedge clk) begin','    if (!rst_n) for (d=0; d<MODEL_DELAY; d=d+1) delay_line[d] <= 0;',
  '    else begin','      delay_line[0] <= data_in;','      for (d=1; d<MODEL_DELAY; d=d+1) delay_line[d] <= delay_line[d-1];','    end','  end');
 const kinds=new Set();
 q.sections.forEach((s,i)=>{
  const kind=s.order===2?'so':'fo',iw=i?'SECTION_WIDTH':'IN_WIDTH',ow=i===q.sections.length-1?'IN_WIDTH':'SECTION_WIDTH',input=i?'s'+(i-1)+'_out':q.delaySamples?'delay_line[MODEL_DELAY-1]':'data_in';kinds.add(kind);
  const coefficients=[...Array.from({length:kind==='so'?3:2},(_,k)=>'.B'+k+'('+literal(f.coefficientBits,s.b[k]||0)+')'),...Array.from({length:kind==='so'?2:1},(_,k)=>'.A'+(k+1)+'('+literal(f.coefficientBits,s.a[k+1]||0)+')')];
  lines.push('  wire signed ['+ow+'-1:0] s'+i+'_out;',
   '  '+name+'_'+kind+' #(.IW('+iw+'), .OW('+ow+'), .CW(COEFF_WIDTH), .CF(COEFF_FRAC),',
   '    .AW(ACC_WIDTH), .NEAREST('+(f.rounding==='nearest'?1:0)+'), '+coefficients.join(', ')+')',
   '    s'+i+'(.clk(clk), .rst_n(rst_n), .data_in('+input+'), .data_out(s'+i+'_out));');
 });
 lines.push('  always @* data_out = s'+(q.sections.length-1)+'_out;','endmodule','');
 // Combinational datapath only: the original x/y state and cycle contract stay intact.
 // Rounded floor quotient + a guard/sticky increment equals nearest ties away from zero.
 // Parallel clamped floor/ceil branches avoid waiting for the sign before incrementing.
 for(const kind of kinds){
  const order=kind==='so'?2:1,terms=[],params=['B0','B1',...(order===2?['B2']:[]),'A1',...(order===2?['A2']:[])];
  lines.push('module '+name+'_'+kind+' #(',
   '  parameter integer IW=16, OW=16, CW=18, CF=15, AW=40, NEAREST=1,',
   '  parameter signed [CW-1:0] '+params.map(p=>p+'=0').join(', '),
   ') (input clk, input rst_n, input signed [IW-1:0] data_in, output wire signed [OW-1:0] data_out);',
   '  reg signed [IW-1:0] x1'+(order===2?', x2':'')+';',
   '  reg signed [OW-1:0] y1'+(order===2?', y2':'')+';',
   '  wire signed [AW-1:0] acc;',
   '  localparam integer RW = AW-CF+1;',
   '  wire signed [RW-1:0] integral = {acc[AW-1], acc[AW-1:CF]};',
   '  wire increment;',
   '  generate if (!NEAREST || CF==0) begin : truncation',
   "    assign increment = 1'b0;",
   '  end else if (CF==1) begin : one_fraction_bit',
   '    assign increment = acc[0] & ~acc[AW-1];',
   '  end else begin : rounding_bits',
   '    assign increment = acc[CF-1] & (~acc[AW-1] | (|acc[CF-2:0]));',
   '  end endgenerate',
   '  (* keep = "true" *) wire signed [RW-1:0] incremented = integral + 1\'b1;',
   '  wire over_floor = (integral[RW-1:OW-1] != {(RW-OW+1){integral[RW-1]}});',
   '  wire over_ceil = (incremented[RW-1:OW-1] != {(RW-OW+1){incremented[RW-1]}});',
   '  wire signed [OW-1:0] floor_y = over_floor ? {integral[RW-1], {(OW-1){~integral[RW-1]}}} : integral[OW-1:0];',
   '  wire signed [OW-1:0] ceil_y = over_ceil ? {incremented[RW-1], {(OW-1){~incremented[RW-1]}}} : incremented[OW-1:0];',
   '  wire signed [OW-1:0] next_y = increment ? ceil_y : floor_y;');
  for(const p of params){
   const feedback=p[0]==='A',k=Number(p[1]),width=feedback?'OW':'IW',signal=feedback?'y'+k:k?'x'+k:'data_in';
   lines.push('  (* use_dsp = "yes" *) wire signed ['+width+'+CW-1:0] P_'+p+' = $signed('+signal+') * $signed('+p+');',
    '  wire signed [AW-1:0] E_'+p+' = {{(AW-('+width+'+CW)){P_'+p+'['+width+'+CW-1]}}, P_'+p+'};');
   terms.push('E_'+p);
  }
  // Two's-complement subtraction in AW bits; one final carry-propagate adder.
  let operands=terms.map(t=>t.startsWith('E_A')?'~'+t:t);
  operands.push("{{(AW-2){1'b0}},2'd"+order+"}");
  let stage=0;
  while(operands.length>2){
   const next=[];
   for(let k=0;k<operands.length;k+=3){
    if(k+2>=operands.length){next.push(...operands.slice(k));break;}
    const [a,b,c]=operands.slice(k,k+3),s='sum'+stage,carry='carry'+stage++;
    lines.push('  wire [AW-1:0] '+s+' = ('+a+') ^ ('+b+') ^ ('+c+');',
     '  wire [AW-1:0] '+carry+' = ((('+a+') & ('+b+')) | (('+a+') & ('+c+')) | (('+b+') & ('+c+'))) << 1;');
    next.push(s,carry);
   }
   operands=next;
  }
  lines.push('  assign acc = $signed('+operands[0]+') + $signed('+operands[1]+');',
   '  always @(posedge clk) begin','    if (!rst_n) begin',
   '      x1 <= 0; y1 <= 0;'+(order===2?' x2 <= 0; y2 <= 0;':''),
   '    end else begin','      x1 <= data_in; y1 <= next_y;'+(order===2?' x2 <= x1; y2 <= y1;':''),
   '    end','  end',
   '  assign data_out = y'+order+'; // '+order+' registered cycle'+(order===2?'s':'')+'; feedback uses y1/y2 histories.',
   'endmodule','');
 }
 return lines.join('\n');
}
root.DigitalSOS={MAX_ORDER,roots,smallRoots,groupExpanded,polynomial,validateFactors,factorRoots,sections,quantize,runFixed,verilog,reuseFactors,evaluateFactors,runFloat,multiply:mul,same};
if(typeof module!=='undefined'&&module.exports)module.exports=root.DigitalSOS;
})(typeof window!=='undefined'?window:globalThis);
