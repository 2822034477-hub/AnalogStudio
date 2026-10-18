/* Persistent block drag/resize with obstacle-routed SVG wires. */
(function(root){
'use strict';
const L=root.DigitalSystemLayout,esc=x=>String(x).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
let serial=0;
function newId(){return 'ds-canvas-'+(++serial);}
function markup(state,layout,id='ds-canvas',selected=null){
 const scene=L.build(state,layout),defs=['<pattern id="'+id+'-grid" width="20" height="20" patternUnits="userSpaceOnUse"><path d="M20 0 H0 V20" fill="none" stroke="#edf2f7" stroke-width="1"/></pattern>',
 '<marker id="'+id+'-arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto"><path d="M0 0 L10 5 L0 10 z" fill="#2569a7"/></marker>'];
 const blocks=scene.boxes.map((b,i)=>{
  const clip=id+'-clip-'+i;defs.push('<clipPath id="'+clip+'"><rect x="10" y="7" width="'+(b.w-20)+'" height="'+(b.h-14)+'"/></clipPath>');
  const subtitle=b.design?(root.DigitalModules.types[b.design.kind]+' · '+b.design.latency+' 拍'):b.subtitle;
  const ports=[...scene.anchors.entries()].filter(([_,p])=>p.owner===b.id).map(([key,p])=>{
   const x=p.x-b.x,y=p.y-b.y,label=b.kind==='module'?'<text x="'+(p.side==='left'?12:b.w-12)+'" y="'+(y+4)+'" text-anchor="'+(p.side==='left'?'start':'end')+'" clip-path="url(#'+clip+')">'+esc(p.label)+'</text>':'';
   return '<circle cx="'+x+'" cy="'+y+'" r="4" data-ds-anchor="'+esc(key)+'"/>'+label;
  }).join('');
  return '<g class="ds-block'+(selected?.kind==='node'&&selected.id===b.id?' ds-selected':'')+'" data-ds-node="'+esc(b.id)+'" transform="translate('+b.x+' '+b.y+')" tabindex="0" role="group" aria-label="'+esc(b.title+'；可拖动，右下角调整大小；Delete 删除，右键操作')+'"><title>'+esc(b.title+' · '+subtitle)+'</title><rect class="'+(b.kind==='module'?'ds-node':'ds-port')+'" width="'+b.w+'" height="'+b.h+'" rx="9"/><g clip-path="url(#'+clip+')"><text x="14" y="24" class="ds-svg-title">'+esc(b.title)+'</text><text x="14" y="44">'+esc(subtitle)+'</text></g>'+ports+'<g data-ds-resize="'+esc(b.id)+'" class="ds-resize-handle" aria-label="调整模块大小"><rect x="'+(b.w-23)+'" y="'+(b.h-23)+'" width="23" height="23" fill="transparent"/><path d="M'+(b.w-18)+' '+(b.h-5)+' L'+(b.w-5)+' '+(b.h-18)+' M'+(b.w-11)+' '+(b.h-5)+' L'+(b.w-5)+' '+(b.h-11)+'"/></g></g>';
 });
 const paths=scene.routes.filter(r=>r.points).map(r=>{const attrs=' data-ds-wire="'+esc(r.from+'>'+r.to)+'" data-ds-from="'+esc(r.from)+'" data-ds-to="'+esc(r.to)+'"',chosen=selected?.kind==='wire'&&selected.from===r.from&&selected.to===r.to;return '<path d="'+r.d+'" class="ds-wire-hit"'+attrs+' aria-hidden="true"/><path d="'+r.d+'" class="ds-link'+(chosen?' ds-selected':'')+'"'+attrs+' tabindex="0" role="button" aria-label="'+esc('连线 '+r.from+' → '+r.to+'；Delete 删除')+'" aria-pressed="'+chosen+'" marker-end="url(#'+id+'-arrow)"/>';}).join('');
 const failed=scene.routes.some(r=>!r.points)?'<text x="24" y="20" class="ds-route-warning">部分端口附近缺少布线空间，请移动模块。</text>':'';
 return '<svg width="'+scene.width+'" height="'+scene.height+'" viewBox="0 0 '+scene.width+' '+scene.height+'" style="width:'+scene.width+'px;height:'+scene.height+'px" role="group" aria-label="系统连接图；点击选择，拖动移动，右键复制粘贴"><defs>'+defs.join('')+'</defs><rect width="100%" height="100%" fill="url(#'+id+'-grid)"/>'+paths+blocks.join('')+failed+'</svg>';
}
function mount(element,options){
 const doc=element.ownerDocument,id=options.id||newId(),raf=root.requestAnimationFrame?.bind(root)||(fn=>root.setTimeout(fn,16)),caf=root.cancelAnimationFrame?.bind(root)||root.clearTimeout.bind(root);
 let drag=null,frame=null,disposed=false;
 const active=()=>!disposed&&options.isActive?.()!==false;
 function paint(layout){if(!disposed)element.innerHTML=markup(options.getState(),layout,id,options.getSelection?.());}
 function focusSelection(){const s=options.getSelection?.();if(!s)return;const node=s.kind==='wire'?[...element.querySelectorAll('.ds-link')].find(n=>n.dataset.dsFrom===s.from&&n.dataset.dsTo===s.to):[...element.querySelectorAll('[data-ds-node]')].find(n=>n.dataset.dsNode===s.id);node?.focus?.({preventScroll:true});}
 function target(e){const wire=e.target.closest?.('[data-ds-wire]');if(wire)return {kind:'wire',from:wire.dataset.dsFrom,to:wire.dataset.dsTo};const node=e.target.closest?.('[data-ds-node]');return node?{kind:'node',id:node.dataset.dsNode}:null;}
 function point(e){
  const svg=element.querySelector('svg');
  try{const matrix=svg.getScreenCTM?.();if(matrix&&svg.createSVGPoint){const p=svg.createSVGPoint();p.x=e.clientX;p.y=e.clientY;const q=p.matrixTransform(matrix.inverse());if(Number.isFinite(q.x)&&Number.isFinite(q.y))return q;}}catch{}
  const rect=svg.getBoundingClientRect(),view=svg.getAttribute('viewBox').split(/\s+/).map(Number),scale=Math.min(rect.width/view[2],rect.height/view[3]);
  if(!Number.isFinite(scale)||scale<=0)return null;
  return {x:(e.clientX-rect.left-(rect.width-view[2]*scale)/2)/scale+view[0],y:(e.clientY-rect.top-(rect.height-view[3]*scale)/2)/scale+view[1]};
 }
 function release(d){try{if(element.hasPointerCapture?.(d.pointerId))element.releasePointerCapture(d.pointerId);}catch{}}
 function cancel(repaint=true){if(!drag)return;const d=drag;drag=null;if(frame!==null){caf(frame);frame=null;}delete element.dataset.gesture;release(d);if(repaint)paint();}
 function down(e){
  if(!active()||e.button!==0||e.isPrimary===false||drag)return;const selection=target(e);options.onSelect?.(selection);
  if(selection?.kind!=='node'){paint();focusSelection();if(selection)e.preventDefault();return;}
  const node=e.target.closest?.('[data-ds-node]');if(!node||!element.contains(node))return;
  const p=point(e);if(!p)return;const scene=L.build(options.getState()),box=scene.boxes.find(b=>b.id===node.dataset.dsNode);if(!box)return;
  drag={pointerId:e.pointerId,id:box.id,box,boxes:scene.boxes,start:p,base:L.capture(scene.boxes),preview:L.capture(scene.boxes),resize:!!e.target.closest('[data-ds-resize]')};
  element.dataset.gesture=drag.resize?'resize':'move';node.focus?.({preventScroll:true});try{element.setPointerCapture?.(e.pointerId);}catch{}e.preventDefault();
 }
 function move(e){
  if(!drag||drag.pointerId!==e.pointerId)return;if(!active()){cancel();return;}const p=point(e);if(!p)return;
  const d=drag,dx=p.x-d.start.x,dy=p.y-d.start.y,candidate=d.resize?{...d.box,w:d.box.w+dx,h:d.box.h+dy}:{...d.box,x:d.box.x+dx,y:d.box.y+dy};
  const r=L.constrain(d.box,candidate,d.boxes);if(!r)return;
  d.preview={...d.base,[d.id]:r};if(frame===null)frame=raf(()=>{frame=null;if(drag===d)paint(d.preview);});e.preventDefault();
 }
 function up(e){
  if(!drag||drag.pointerId!==e.pointerId)return;move(e);if(!drag)return;const d=drag;drag=null;if(frame!==null){caf(frame);frame=null;}delete element.dataset.gesture;release(d);
  if(active()&&['x','y','w','h'].some(k=>d.preview[d.id][k]!==d.box[k]))options.onCommit(d.preview);paint();focusSelection();
 }
 function lost(e){if(drag&&drag.pointerId===e.pointerId)cancel();}
 function key(e){
  if(e.key==='Escape'&&drag){e.preventDefault();cancel();return;}
  if(active()&&['Enter',' '].includes(e.key)&&target(e)){e.preventDefault();options.onSelect?.(target(e));paint();focusSelection();return;}
  const node=e.target.closest?.('[data-ds-node]');if(!node||!active()||!['ArrowLeft','ArrowRight','ArrowUp','ArrowDown'].includes(e.key)||drag)return;
  const scene=L.build(options.getState()),box=scene.boxes.find(b=>b.id===node.dataset.dsNode);if(!box)return;const step=e.shiftKey?40:10,dx=e.key==='ArrowLeft'?-step:e.key==='ArrowRight'?step:0,dy=e.key==='ArrowUp'?-step:e.key==='ArrowDown'?step:0;
  const r=L.constrain(box,e.altKey?{...box,w:box.w+dx,h:box.h+dy}:{...box,x:box.x+dx,y:box.y+dy},scene.boxes);e.preventDefault();if(!r)return;
  options.onSelect?.({kind:'node',id:box.id});options.onCommit({...L.capture(scene.boxes),[box.id]:r});paint();[...element.querySelectorAll('[data-ds-node]')].find(n=>n.dataset.dsNode===box.id)?.focus({preventScroll:true});
 }
 function context(e){if(!active())return;e.preventDefault();const p=point(e);cancel(false);const s=target(e);options.onSelect?.(s);paint();options.onContextMenu?.(s,e,p);}
 const blur=()=>cancel(),visibility=()=>{if(doc.hidden)cancel();},escKey=e=>{if(e.key==='Escape'&&drag){e.preventDefault();cancel();}};
 element.addEventListener('pointerdown',down);element.addEventListener('pointermove',move);element.addEventListener('pointerup',up);element.addEventListener('pointercancel',lost);element.addEventListener('lostpointercapture',lost);element.addEventListener('keydown',key);element.addEventListener('contextmenu',context);
 root.addEventListener('blur',blur);root.addEventListener('keydown',escKey);doc.addEventListener('visibilitychange',visibility);
 return {draw:()=>paint(),cancel:()=>cancel(),reset(){cancel(false);options.onCommit(undefined);paint();},destroy(){cancel(false);disposed=true;element.removeEventListener('pointerdown',down);element.removeEventListener('pointermove',move);element.removeEventListener('pointerup',up);element.removeEventListener('pointercancel',lost);element.removeEventListener('lostpointercapture',lost);element.removeEventListener('keydown',key);element.removeEventListener('contextmenu',context);root.removeEventListener('blur',blur);root.removeEventListener('keydown',escKey);doc.removeEventListener('visibilitychange',visibility);}};
}
root.DigitalSystemCanvas={newId,markup,mount};
})(typeof window!=='undefined'?window:globalThis);
