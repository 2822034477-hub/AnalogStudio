/* Interactive real-coefficient z-plane. Root IDs belong to factors, never solver order. */
(function(root){
'use strict';
const W=600,H=360,L=48,R=18,T=24,B=40,PW=W-L-R,PH=H-T-B;
let mountSerial=0;
const esc=s=>String(s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const fmt=x=>Number(x.toPrecision(7)).toString();
const copy=x=>JSON.parse(JSON.stringify(x));
const defaults=()=>({centerRe:0,centerIm:0,span:1.3,kind:'poles',placement:'real',tool:'add'});
function validate(v){
 const d=defaults();if(v===undefined)return d;
 if(!v||typeof v!=='object'||Array.isArray(v))throw Error('Invalid z-plane view.');
 for(const k of ['centerRe','centerIm','span'])if(v[k]!==undefined){if(typeof v[k]!=='number'||!Number.isFinite(v[k])||Math.abs(v[k])>1e5||(k==='span'&&(v[k]<.01||v[k]>1e4)))throw Error('Invalid z-plane view range.');d[k]=v[k];}
 for(const [k,values]of Object.entries({kind:['zeros','poles'],placement:['real','pair'],tool:['select','add','pan']}))if(v[k]!==undefined){if(!values.includes(v[k]))throw Error('Invalid z-plane tool.');d[k]=v[k];}
 // Optional metadata in old v1 projects; coefficients remain authoritative.
 if(v.rootGroups!==undefined){
  if(!v.rootGroups||typeof v.rootGroups!=='object'||Array.isArray(v.rootGroups))throw Error('Invalid root identities.');
  const ids=new Set();d.rootGroups={};
  for(const kind of ['zeros','poles']){
   const list=v.rootGroups[kind];if(!Array.isArray(list)||list.length>root.DigitalDesign.MAX_ORDER)throw Error('Invalid root identities.');
   d.rootGroups[kind]=list.map(r=>{
    if(!r||typeof r.id!=='string'||!/^r[1-9]\d{0,8}$/.test(r.id)||ids.has(r.id)||typeof r.pair!=='boolean'||typeof r.re!=='number'||typeof r.im!=='number'||!Number.isFinite(r.re)||!Number.isFinite(r.im)||r.im<0||(r.re===0&&r.im===0)||Math.hypot(r.re,r.im)>100||(!r.pair&&r.im!==0))throw Error('Invalid root identity.');
    ids.add(r.id);return {id:r.id,re:r.re,im:r.im,pair:r.pair};
   });
   if(d.rootGroups[kind].reduce((n,r)=>n+(r.pair?2:1),0)>root.DigitalDesign.MAX_ORDER)throw Error('Too many root identities.');
  }
 }
 return d;
}
function mount(host,options={}){
 let W=600,H=360,PW=W-L-R,PH=H-T-B,space=false,hover=false;
 const D=root.DigitalDesign,clipId='dd-unit-clip-'+(++mountSerial);
 let state=defaults(),model,selected=null,drag=null,enabled=true,disposed=false;
 let factors={zeros:[],poles:[]},nextId=1,internalUpdate=false,suppressClick=false,frame=null;
 const raf=fn=>root.requestAnimationFrame?root.requestAnimationFrame(fn):root.setTimeout(fn,16);
 const caf=id=>root.cancelAnimationFrame?root.cancelAnimationFrame(id):root.clearTimeout(id);
 host.innerHTML=`<div class="dd-root-tools"><label>根类型<select data-z="kind"><option value="poles">极点 ×</option><option value="zeros">零点 ○</option></select></label><label>放置方式<select data-z="placement"><option value="real">实轴单点</option><option value="pair">共轭对 ±Im</option></select></label><label>鼠标工具<select data-z="tool"><option value="add">点击放置 / 拖动根</option><option value="select">仅选择 / 拖动根</option><option value="pan">平移视图</option></select></label></div><details class="dd-root-coordinate"><summary>坐标输入</summary><div class="dd-root-tools"><label>实部<input data-z="re" type="number" step="any" value="0.5"></label><label>虚部幅值<input data-z="im" type="number" step="any" min="0" value="0.25" disabled></label><div class="dd-root-actions"><button type="button" data-z="add">添加坐标</button><button type="button" data-z="move" disabled>更新选中根</button><button type="button" data-z="delete" disabled>删除选中根</button></div></div><div class="dd-gain-tools"><label>整体增益 K<input data-z="gain" type="number" step="any" value="0.2"></label><button type="button" data-z="gain-minus" aria-label="整体增益减 0.1">−0.1</button><button type="button" data-z="gain-plus" aria-label="整体增益加 0.1">+0.1</button><small>调节整体输出比例，零极点位置不变；K 改为原值的 2 倍，幅度随之乘 2。K=0 保留根布局。</small></div></details><p data-z="capacity" class="dd-note"></p><div class="dd-root-view-tools"><button type="button" data-z="out" aria-label="缩小 z 平面">−</button><button type="button" data-z="in" aria-label="放大 z 平面">+</button><button type="button" data-z="fit">适应 / 复位</button><span>Ctrl 缩放 · Space 拖动</span></div><div data-z="plot" class="dd-root-plot dd-resizable" tabindex="0" aria-label="可编辑 z 平面；空白处点击放置；删除键删除选中根"></div><p data-z="error" class="dd-error" role="alert" hidden></p><p data-z="mode-hint" class="dd-note" role="status"></p><p data-z="selection" class="dd-note" aria-live="polite"></p><div data-z="list" class="dd-root-list" aria-label="零极点统一列表"></div><details class="dd-inline-help"><summary>零极点编辑说明</summary><p>× 是极点，○ 是零点。列表中的每个点有独立编号；共轭组同步修改，删除按钮会明确标注“整对（2点）”。实轴单点可逐个删除，重复根用编号区分。共轭对拖到实轴保留两重根。橙色为量化根，灰色原点为阶次补齐（不可编辑，不列入因子列表）。编辑半径 ≤ 100；原点因子等于 1，纯延迟由“额外延迟”设置。</p></details>`;
 const gainHost=options.gainHost||host;
 if(options.gainHost)gainHost.replaceChildren(host.querySelector('.dd-gain-tools'));
 const $=k=>(['gain','gain-minus','gain-plus'].includes(k)?gainHost:host).querySelector('[data-z="'+k+'"]');
 const error=e=>{$('error').hidden=!e;$('error').textContent=e?.message||e||'';};
 const scale=()=>PH/(state.span*2);
 const pos=r=>({x:L+PW/2+(r.re-state.centerRe)*scale(),y:T+PH/2-(r.im-state.centerIm)*scale()});
 const coord=p=>({re:state.centerRe+(p.x-L-PW/2)/scale(),im:state.centerIm-(p.y-T-PH/2)/scale()});
 const inside=p=>p&&Number.isFinite(p.x)&&Number.isFinite(p.y)&&p.x>=L&&p.x<=W-R&&p.y>=T&&p.y<=H-B;
 const find=id=>{for(const kind of ['zeros','poles']){const index=factors[kind].findIndex(r=>r.id===id);if(index>=0)return {kind,index,...factors[kind][index]};}return null;};
 const active=()=>find(selected);
 const count=kind=>factors[kind].reduce((n,r)=>n+(r.pair?2:1),0);
 function pointer(e){
  const svg=$('plot').querySelector('svg');if(!svg)return null;
  // The screen CTM handles CSS transforms and non-default SVG aspect ratios.
  try{const matrix=svg.getScreenCTM?.();if(matrix&&svg.createSVGPoint){const p=svg.createSVGPoint();p.x=e.clientX;p.y=e.clientY;return p.matrixTransform(matrix.inverse());}}catch{}
  const box=svg.getBoundingClientRect();if(!box.width||!box.height)return null;
  const s=Math.min(box.width/W,box.height/H),ox=(box.width-W*s)/2,oy=(box.height-H*s)/2;
  return {x:(e.clientX-box.left-ox)/s,y:(e.clientY-box.top-oy)/s};
 }
 const expanded=list=>list.flatMap(r=>r.pair&&r.im===0?[{re:r.re,im:0},{re:r.re,im:0}]:[{re:r.re,im:r.im}]);
 function modelFor(list){const z=D.factorRoots(model);return D.create({...z,zeros:expanded(list.zeros),poles:expanded(list.poles),sampleRate:model.sampleRate,fixed:model.fixed});}
 function matches(a,b){return ['a','b'].every(k=>a[k].length===b[k].length&&a[k].every((x,i)=>Math.abs(x-b[k][i])<=1e-10*Math.max(1,Math.abs(x),Math.abs(b[k][i]))));}
 function reconcile(m){
  // Preserve IDs while matching unchanged roots; repeated roots consume distinct IDs.
  if(model&&matches(m,model))return;
  const z=D.factorRoots(m);
  for(const kind of ['zeros','poles']){
   const old=factors[kind].slice();
   factors[kind]=z[kind].map(r=>{const i=old.findIndex(p=>p.pair===!!r.im&&Math.abs(p.re-r.re)<1e-8&&Math.abs(p.im-r.im)<1e-8);return {...r,pair:!!r.im,id:i<0?'r'+nextId++:old.splice(i,1)[0].id};});
  }
  if(!active())selected=null;
 }
 function syncControls(){
  for(const k of ['kind','placement','tool'])$(k).value=state[k];
  $('gain').value=model?D.factorRoots(model).gain:0;for(const k of ['gain','gain-minus','gain-plus'])$(k).disabled=!enabled;
  const r=active();$('im').disabled=!enabled||state.placement==='real';$('re').disabled=!enabled;
  $('move').disabled=!r||!enabled;$('delete').disabled=!r||!enabled;$('add').disabled=!enabled;
  $('delete').textContent=r?.pair?'删除整对（2点）':'删除选中单点';
  $('plot').dataset.tool=state.tool;
  $('mode-hint').textContent=!enabled?'输入尚未有效，请展开参数并修正输入或点击“计算 / 更新”。':state.tool==='add'?'点击空白处添加'+(state.kind==='poles'?'极点 ×':'零点 ○')+' · '+(state.placement==='pair'?'共轭对（2点）':'实轴单点（虚部固定为0）')+'；已有点可直接拖动。':state.tool==='pan'?'当前是平移工具：拖动画布平移，切换“点击放置”可添加。':'当前仅选择 / 拖动：点击空白不添加，请切换“点击放置”。';
  const delay=model?D.factorRoots(model).delaySamples:0;
  $('capacity').textContent='当前零点 '+count('zeros')+' + 延迟 '+delay+' / '+D.MAX_ORDER+'；极点 '+count('poles')+' / '+D.MAX_ORDER+'。';
 }
 function select(id,light=false){
  selected=id;const r=active();
  if(r){state.kind=r.kind;state.placement=r.pair?'pair':'real';$('re').value=r.re;$('im').value=r.im;}
  syncControls();if(light)preview();else draw();
 }
 function drawList(){
  if(!enabled){$('list').replaceChildren();return;}
  let rows='';
  for(const kind of ['zeros','poles'])for(const r of factors[kind])for(const sign of r.pair?[1,-1]:[1]){
   const pid=r.id+(r.pair?(sign===1?'+':'-'):''),label=kind==='zeros'?'零点 ○':'极点 ×';
   rows+='<tr data-root-id="'+r.id+'" data-sign="'+sign+'"'+(selected===r.id?' class="dd-root-selected"':'')+'><td>'+label+'<small>'+pid+'</small></td><td><input data-field="re" aria-label="'+pid+' 实部" type="number" step="any" value="'+r.re+'"></td><td><input data-field="im" aria-label="'+pid+' 虚部" type="number" step="any" value="'+(sign*r.im)+'"'+(!r.pair?' readonly':'')+'></td><td>'+(r.pair?esc(r.id)+'（同步2点）':'单点')+'</td><td><button type="button" data-action="select">选择</button><button type="button" data-action="update">应用</button><button type="button" data-action="delete">'+(r.pair?'删除整对（2点）':'删除单点')+'</button></td></tr>';
  }
  $('list').innerHTML=rows?'<table><caption>零极点列表 · 修改后按“应用”或 Enter</caption><thead><tr><th>类型 / 编号</th><th>实部</th><th>虚部</th><th>共轭组</th><th>操作</th></tr></thead><tbody>'+rows+'</tbody></table>':'<p class="dd-note">尚无可编辑因子根。选择类型后点击上方 z 平面，或输入坐标添加。</p>';
 }
 function draw(){
  if(!model||!enabled){$('plot').replaceChildren();$('list').replaceChildren();$('selection').textContent='输入尚未有效；请修正输入后继续编辑。';return;}
  const a=D.analysis(model),mark=(r,kind,color,attrs='',size=6)=>{
   const p=pos(r);if(!inside(p))return '';
   return '<g '+attrs+'><circle cx="'+p.x+'" cy="'+p.y+'" r="12" fill="transparent"/>'+(kind==='zeros'?'<circle cx="'+p.x+'" cy="'+p.y+'" r="'+size+'" fill="white" stroke="'+color+'" stroke-width="2"/>':'<path d="M'+(p.x-size)+' '+(p.y-size)+'l'+size*2+' '+size*2+'m0 -'+size*2+'l-'+size*2+' '+size*2+'" fill="none" stroke="'+color+'" stroke-width="2"/>')+'</g>';
  };
  let svg='<svg viewBox="0 0 '+W+' '+H+'" preserveAspectRatio="xMidYMid meet" role="img" aria-label="z 平面，单位圆 |z|=1，蓝色因子根可编辑"><rect x="'+L+'" y="'+T+'" width="'+PW+'" height="'+PH+'" fill="#fcfdff" stroke="#dce5ee"/>';
  for(let i=0;i<=4;i++){const px=L+PW*i/4,py=T+PH*i/4;svg+='<path d="M'+px+' '+T+'V'+(H-B)+'M'+L+' '+py+'H'+(W-R)+'" stroke="#e2e9f0" pointer-events="none"/><text x="'+px+'" y="'+(H-B+18)+'" text-anchor="middle">'+fmt(coord({x:px,y:0}).re)+'</text><text x="'+(L-5)+'" y="'+(py+3)+'" text-anchor="end">'+fmt(coord({x:0,y:py}).im)+'</text>';}
  const o=pos({re:0,im:0});svg+='<defs><clipPath id="'+clipId+'"><rect x="'+L+'" y="'+T+'" width="'+PW+'" height="'+PH+'"/></clipPath></defs><g pointer-events="none" clip-path="url(#'+clipId+')"><circle cx="'+o.x+'" cy="'+o.y+'" r="'+scale()+'" fill="#dfeee755" stroke="#567a69" stroke-dasharray="6 4"/><path d="M'+L+' '+o.y+'H'+(W-R)+'M'+o.x+' '+T+'V'+(H-B)+'" stroke="#91a4b6"/></g>';
  for(const kind of ['zeros','poles'])for(let i=0;i<a[kind].length-count(kind);i++)svg+=mark({re:0,im:0},kind,'#9aabb9','data-implicit="true" pointer-events="none"',4+i*2);
  try{const q=D.analysis(D.quantize(model).model);for(const kind of ['zeros','poles'])for(const r of q[kind])svg+=mark(r,kind,'#c16d24','data-quantized="true" pointer-events="none"',4);}catch{}
  for(const kind of ['zeros','poles'])factors[kind].forEach((r,index)=>{for(const sign of r.pair?[1,-1]:[1])svg+=mark({re:r.re,im:sign*r.im},kind,selected===r.id?'#882b8a':'#2569a7','data-root-id="'+r.id+'" data-root-kind="'+kind+'" data-root-index="'+index+'" data-sign="'+sign+'" class="dd-edit-root"',selected===r.id?8:6);});
  svg+='<text x="'+L+'" y="15">Im(z) · 虚线单位圆 |z| = 1</text><text x="'+(W-R)+'" y="'+(H-4)+'" text-anchor="end">Re(z)</text></svg>';$('plot').innerHTML=svg;
  const r=active();$('selection').textContent=(r?'已选 '+r.id+' '+(r.kind==='poles'?'极点':'零点')+'：'+fmt(r.re)+(r.pair?' ± '+fmt(r.im)+'j；删除会移除整对（2点）。':'；可删除此单点。'):'点击已有根或列表中的“选择”可编辑。')+(a.zeroTransfer?'K=0：显示保留的因子布局；当前输出为零。':'')+(a.stable?'极点严格位于单位圆内。':a.marginal?'极点在单位圆上，非严格稳定。':'存在单位圆外极点，不稳定。');
  drawList();
 }
 // Preview mutates existing marks and inputs only. The model and expensive responses stay committed.
 function preview(){
  const current=drag?.rootId?find(drag.rootId):null;
  for(const kind of ['zeros','poles'])for(const r of factors[kind]){
   const point=current?.id===r.id?drag.point:r;
   for(const node of $('plot').querySelectorAll?.('[data-root-id="'+r.id+'"]')||[]){
    const sign=Number(node.dataset.sign)||1,a=pos({re:r.re,im:sign*r.im}),b=pos({re:point.re,im:sign*point.im});
    node.setAttribute('transform','translate('+(b.x-a.x)+' '+(b.y-a.y)+')');
    node.classList.toggle('dd-root-active',r.id===selected);
   }
   for(const row of $('list').querySelectorAll?.('[data-root-id="'+r.id+'"]')||[]){
    row.querySelector('[data-field="re"]').value=point.re;row.querySelector('[data-field="im"]').value=(Number(row.dataset.sign)||1)*point.im;
    row.classList.toggle('dd-root-selected',r.id===selected);
   }
  }
  const r=active(),point=current?drag.point:r;if(point){$('re').value=point.re;$('im').value=point.im;}
  $('selection').textContent=current?'拖动预览 '+current.id+'：'+fmt(point.re)+(current.pair?' ± '+fmt(point.im)+'j':'')+'；松手更新响应，Esc 取消。':r?'已选 '+r.id+'；坐标已提交。':'点击已有根或列表中的“选择”可编辑。';
 }
 function cancelDrag(){if(drag)end({pointerId:drag.id},true);}
 function gain(value){
  if(!enabled||disposed)return;cancelDrag();
  try{
   const k=numeric(value),z=D.factorRoots(model),next=D.create({...z,zeros:expanded(factors.zeros),poles:expanded(factors.poles),gain:k,sampleRate:model.sampleRate,fixed:model.fixed});
   model=next;internalUpdate=true;try{options.onModel?.(next);}finally{internalUpdate=false;}
   error(null);syncControls();draw();
  }catch(e){error(e);}
 }
 $('gain').addEventListener('change',()=>gain($('gain').value));
 $('gain').addEventListener('keydown',e=>{if(e.key==='Enter'){e.preventDefault();gain($('gain').value);}});
 for(const [key,step]of [['gain-minus',-.1],['gain-plus',.1]])$(key).addEventListener('click',()=>gain(Number((D.factorRoots(model).gain+step).toPrecision(14))));
 function numeric(value){const text=String(value).trim();if(!text||!Number.isFinite(Number(text)))throw Error('坐标必须是有限数字。');return Number(text);}
 function edit(action,point,identity){
  if(!enabled||disposed)return false;cancelDrag();
  try{
   const r=identity?find(identity):active(),kind=action==='add'?state.kind:r?.kind,pair=identity?r.pair:state.placement==='pair';
   if(!kind)throw Error('请先选择一个根。');
   const p=action==='delete'?{re:0,im:0}:point||{re:numeric($('re').value),im:pair?numeric($('im').value):0};
   const re=numeric(p.re),im=pair?Math.abs(numeric(p.im)):0;
   if(action!=='delete'){
    if(Math.hypot(re,im)>100)throw Error('编辑根的半径不能超过 100。');
    if(re===0&&im===0)throw Error('原点因子在 z⁻¹ 约定中等于 1，不能独立添加；纯延迟请设置“额外延迟”。');
    if(action==='add'&&pair&&im===0)throw Error('共轭对占用2个点，请点击实轴外；实轴单点请切换放置方式。');
    const delay=kind==='zeros'?D.factorRoots(model).delaySamples:0,used=count(kind)-(action==='move'?(r.pair?2:1):0),need=pair?2:1;
    if(used+need+delay>D.MAX_ORDER)throw Error((kind==='poles'?'极点':'零点')+'上限：当前 '+count(kind)+' 点'+(delay?' + '+delay+' 拍延迟':'')+'，本次需要 '+need+' 点；当前最多 '+D.MAX_ORDER+' 阶。请在下方列表删除或修改已有点。');
    if(kind==='zeros'&&D.factorRoots(model).gain===0)throw Error('零传递函数没有有限零点，请先设置非零增益。');
   }
   const nextFactors=copy(factors),id=action==='add'?'r'+nextId:r.id;
   if(action==='delete')nextFactors[kind].splice(r.index,1);
   else if(action==='add')nextFactors[kind].push({id,re,im,pair});
   else nextFactors[kind][r.index]={id,re,im,pair};
   const next=modelFor(nextFactors); // Validate completely before changing either model or identities.
   factors=nextFactors;model=next;selected=action==='delete'?null:id;if(action==='add')nextId++;
   const chosen=active();if(chosen){state.kind=chosen.kind;state.placement=chosen.pair?'pair':'real';$('re').value=chosen.re;$('im').value=chosen.im;}
   internalUpdate=true;try{options.onModel?.(next);}finally{internalUpdate=false;}
   error(null);
   syncControls();draw();return true;
  }catch(e){error(e);return false;}
 }
 function fit(){cancelDrag();if($('plot').style)$('plot').style.height='';if(model){const a=D.analysis(model);state.centerRe=0;state.centerIm=0;state.span=Math.min(1e4,Math.max(1.3,...a.zeros.concat(a.poles).map(p=>Math.max(Math.abs(p.re)/(PW/PH),Math.abs(p.im))*1.2).filter(Number.isFinite)));}syncControls();draw();}
 const changed=()=>options.onView?.();
 for(const k of ['kind','placement','tool'])$(k).addEventListener('change',()=>{cancelDrag();state[k]=$(k).value;if(k==='kind')selected=null;syncControls();draw();changed();});
 $('add').addEventListener('click',()=>edit('add'));$('move').addEventListener('click',()=>edit('move'));$('delete').addEventListener('click',()=>edit('delete'));
 function listAction(e,action){
  const row=e.target.closest?.('[data-root-id]');if(!row||!enabled)return;
  const id=row.dataset.rootId,r=find(id);if(!r)return;
  if(action==='select'){select(id);return;}
  if(action==='delete'){edit('delete',null,id);return;}
  try{const re=numeric(row.querySelector('[data-field="re"]').value),im=r.pair?numeric(row.querySelector('[data-field="im"]').value):0;edit('move',{re,im},id);}catch(err){error(err);}
 }
 $('list').addEventListener('click',e=>{const button=e.target.closest?.('[data-action]');if(button)listAction(e,button.dataset.action);});
 $('list').addEventListener('keydown',e=>{if(e.key==='Enter'&&e.target.matches('input')){e.preventDefault();listAction(e,'update');}});
 function zoom(f,p){cancelDrag();const before=coord(p);state.span=Math.max(.01,Math.min(1e4,state.span*f));const after=coord(p);state.centerRe=Math.max(-1e5,Math.min(1e5,state.centerRe+before.re-after.re));state.centerIm=Math.max(-1e5,Math.min(1e5,state.centerIm+before.im-after.im));draw();changed();}
 $('in').addEventListener('click',()=>zoom(.8,{x:L+PW/2,y:T+PH/2}));$('out').addEventListener('click',()=>zoom(1.25,{x:L+PW/2,y:T+PH/2}));$('fit').addEventListener('click',()=>{fit();changed();});
 const plot=$('plot');
 plot.addEventListener('wheel',e=>{if(!e.ctrlKey)return;if(drag){e.preventDefault();return;}const p=pointer(e);if(!enabled||!inside(p))return;e.preventDefault();zoom(e.deltaY>0?1.12:1/1.12,p);},{passive:false});
 function hit(e){const el=e.target.closest?.('[data-root-id]');return el?find(el.dataset.rootId)||find(factors[el.dataset.rootKind]?.[Number(el.dataset.rootIndex)]?.id):null;}
 function capture(e){try{plot.setPointerCapture?.(e.pointerId);}catch{} }
 plot.addEventListener('pointerdown',e=>{
  if(!enabled||e.button!==0||e.isPrimary===false)return;cancelDrag();
  suppressClick=false;const p=pointer(e);if(!inside(p))return;e.preventDefault();plot.focus({preventScroll:true});const r=hit(e);
  // Capture on the persistent plot host before replacing any SVG descendants.
  capture(e);
  if(space||state.tool==='pan')drag={id:e.pointerId,pan:true,start:p,centerRe:state.centerRe,centerIm:state.centerIm};
  else if(r){drag={id:e.pointerId,rootId:r.id,pair:r.pair,start:p,moved:false,point:{re:r.re,im:r.im}};plot.dataset.dragging='true';select(r.id,true);}
  else if(state.tool==='add')drag={id:e.pointerId,add:true,start:p,moved:false};
  else{select(null);error('当前为“仅选择 / 拖动”；要添加根，请切换“点击放置”。');}
 });
 plot.addEventListener('pointermove',e=>{
  if(!drag||drag.id!==e.pointerId)return;const p=pointer(e);if(!p)return;e.preventDefault();
  if(drag.pan){state.centerRe=Math.max(-1e5,Math.min(1e5,drag.centerRe-(p.x-drag.start.x)/scale()));state.centerIm=Math.max(-1e5,Math.min(1e5,drag.centerIm+(p.y-drag.start.y)/scale()));draw();}
  else{if(Math.hypot(p.x-drag.start.x,p.y-drag.start.y)>3)drag.moved=true;if(!drag.add&&drag.moved){const c=coord(p);drag.point={re:c.re,im:drag.pair?Math.abs(c.im):0};if(frame===null)frame=raf(()=>{frame=null;if(drag)preview();});}}
 });
 function end(e,cancel=false){
  if(drag?.id!==e.pointerId)return;const current=drag;drag=null;suppressClick=true;if(frame!==null){caf(frame);frame=null;}delete plot.dataset.dragging;
  try{if(plot.hasPointerCapture?.(e.pointerId))plot.releasePointerCapture(e.pointerId);}catch{}
  if(cancel){if(current.pan){state.centerRe=current.centerRe;state.centerIm=current.centerIm;draw();}else preview();return;}
  if(current.pan)changed();
  else if(current.rootId&&current.moved){if(!edit('move',current.point,current.rootId))preview();}
  else if(current.add&&!current.moved){const p=pointer(e);if(inside(p)){const c=coord(p);edit('add',{re:c.re,im:state.placement==='pair'?Math.abs(c.im):0});}}
 }
 plot.addEventListener('pointerup',e=>end(e));plot.addEventListener('pointercancel',e=>end(e,true));
 plot.addEventListener('lostpointercapture',()=>cancelDrag());
 const onBlur=()=>{space=false;delete plot.dataset.pan;cancelDrag();},onVisibility=()=>{if(root.document?.hidden)cancelDrag();};
 root.addEventListener?.('blur',onBlur);root.document?.addEventListener('visibilitychange',onVisibility);
 // Click-only input (including assistive activation) works; a pointer sequence never adds twice.
 plot.addEventListener('click',e=>{
  if(suppressClick){suppressClick=false;return;}if(!enabled||e.button!==0||space)return;
  const p=pointer(e);if(!inside(p))return;const r=hit(e);if(r){select(r.id);return;}
  if(state.tool==='add'){const c=coord(p);edit('add',{re:c.re,im:state.placement==='pair'?Math.abs(c.im):0});}
  else if(state.tool==='select')error('当前为“仅选择 / 拖动”；要添加根，请切换“点击放置”。');
 });
 const spaceDown=e=>{if((e.code==='Space'||e.key===' ')&&!e.target?.matches?.('input,textarea,select,button,[contenteditable=true]')){space=true;plot.dataset.pan='true';if(hover||e.target===plot)e.preventDefault();}};
 const spaceUp=e=>{if(e.code==='Space'||e.key===' '){space=false;delete plot.dataset.pan;}};
 plot.addEventListener('pointerenter',()=>{hover=true;});plot.addEventListener('pointerleave',()=>{hover=false;});
 root.addEventListener?.('keydown',spaceDown);root.addEventListener?.('keyup',spaceUp);
 plot.addEventListener('keydown',e=>{spaceDown(e);if(e.key==='Delete'&&selected){e.preventDefault();edit('delete');}if(e.key==='Escape'){cancelDrag();select(null,true);}});
 plot.addEventListener('keyup',e=>{if(e.code==='Space'||e.key===' '){space=false;delete plot.dataset.pan;}});
 plot.addEventListener('blur',onBlur);
 const resizeObserver=root.ResizeObserver?new root.ResizeObserver(()=>{const width=plot.clientWidth,height=plot.clientHeight;if(!width||!height)return;const w=Math.max(300,width),h=Math.max(220,height);if(w===W&&h===H)return;cancelDrag();W=w;H=h;PW=W-L-R;PH=H-T-B;draw();}):null;
 resizeObserver?.observe(plot);
 syncControls();
 return {
  setModel(m){const next=D.fromCoefficients(m);if(internalUpdate){model=next;return;}cancelDrag();reconcile(next);model=next;enabled=true;error(null);const r=active();if(r){$('re').value=r.re;$('im').value=r.im;}syncControls();draw();},
  setEnabled(v){cancelDrag();enabled=v;syncControls();draw();},
  snapshot:()=>({...state,rootGroups:copy(factors)}),
  replace(v){
   cancelDrag();const saved=validate(v);state={...saved};delete state.rootGroups;selected=null;drag=null;suppressClick=false;
   if(saved.rootGroups&&model){try{if(!matches(modelFor(saved.rootGroups),model))throw Error('stale');factors=copy(saved.rootGroups);}catch{factors={zeros:[],poles:[]};const m=model;model=null;reconcile(m);model=m;}}
   else if(model){factors={zeros:[],poles:[]};const m=model;model=null;reconcile(m);model=m;}
   nextId=Math.max(nextId,1,...Object.values(factors).flat().map(r=>Number(r.id.slice(1))+1));
   error(null);syncControls();draw();
  },
  fit,cancelDrag,destroy(){resizeObserver?.disconnect();cancelDrag();disposed=true;root.removeEventListener?.('blur',onBlur);root.removeEventListener?.('keydown',spaceDown);root.removeEventListener?.('keyup',spaceUp);root.document?.removeEventListener('visibilitychange',onVisibility);host.replaceChildren();if(options.gainHost)gainHost.replaceChildren();}
 };
}
root.DigitalRootEditor={mount,validate,defaults};
if(typeof module!=='undefined'&&module.exports)module.exports=root.DigitalRootEditor;
})(typeof window!=='undefined'?window:globalThis);
