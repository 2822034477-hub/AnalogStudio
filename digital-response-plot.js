/* Response viewport UI only; all points are supplied by the digital model. */
(function(root){
'use strict';
const clamp=(v,a,b)=>Math.max(a,Math.min(b,v));
const fmt=v=>Number(v.toPrecision(6)).toString();
const esc=v=>String(v).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
let serial=0;
function panel({body,toggle,onToggle}){
 const click=()=>{body.hidden=!body.hidden;toggle.textContent=body.hidden?'显示':'收起';toggle.setAttribute('aria-expanded',String(!body.hidden));onToggle?.(!body.hidden);};
 toggle.addEventListener('click',click);
 return {destroy(){toggle.removeEventListener('click',click);}};
}
function mount(host,fit){
 const id='dd-response-'+(++serial),listeners=[];
 let series=[],labels={},view=null,initial=null,manual=false,space=false,drag=null,frame=null,enabled=false,disposed=false,hover=false;
 const on=(el,type,fn,opts)=>{el.addEventListener(type,fn,opts);listeners.push(()=>el.removeEventListener(type,fn,opts));};
 const dimensions=()=>({w:Math.max(300,host.clientWidth||600),h:Math.max(220,host.clientHeight||300)});
 const cancelFrame=()=>{if(frame!==null)root.cancelAnimationFrame?.(frame);frame=null;};
 function draw(){
  cancelFrame();if(!enabled||disposed)return;
  const {w,h}=dimensions(),L=64,R=20,T=28,B=48,x=v=>L+(v-view.xmin)/(view.xmax-view.xmin)*(w-L-R),y=v=>h-B-(v-view.ymin)/(view.ymax-view.ymin)*(h-T-B);
  let svg='<svg viewBox="0 0 '+w+' '+h+'" role="img" aria-label="'+esc(labels.ylabel)+'"><defs><clipPath id="'+id+'"><rect x="'+L+'" y="'+T+'" width="'+(w-L-R)+'" height="'+(h-T-B)+'"/></clipPath></defs>';
  for(let i=0;i<=4;i++){const xx=view.xmin+(view.xmax-view.xmin)*i/4,yy=view.ymin+(view.ymax-view.ymin)*i/4;svg+='<path d="M'+x(xx)+' '+T+'V'+(h-B)+'M'+L+' '+y(yy)+'H'+(w-R)+'" stroke="#dce5ee" fill="none"/><text x="'+x(xx)+'" y="'+(h-B+19)+'" text-anchor="middle">'+fmt(xx)+'</text><text x="'+(L-7)+'" y="'+(y(yy)+4)+'" text-anchor="end">'+fmt(yy)+'</text>';}
  for(const s of series){let d='',pen=false;for(const p of s.points){if(!Number.isFinite(p.x)||!Number.isFinite(p.y)){pen=false;continue;}d+=(pen?'L':'M')+x(p.x).toFixed(3)+' '+y(p.y).toFixed(3)+' ';pen=true;}svg+='<path d="'+d+'" stroke="'+s.color+'" stroke-width="2" fill="none" clip-path="url(#'+id+')"'+(s.dash?' stroke-dasharray="7 4"':'')+'/>';}
  host.innerHTML=svg+'<text x="'+L+'" y="17">'+esc(labels.ylabel)+'</text><text x="'+(w-R)+'" y="'+(h-6)+'" text-anchor="end">'+esc(labels.xlabel)+'</text></svg>';
 }
 function schedule(){if(frame===null){if(root.requestAnimationFrame)frame=root.requestAnimationFrame(draw);else draw();}}
 function pointer(e){const box=host.querySelector('svg')?.getBoundingClientRect?.();if(!box?.width||!box.height)return null;const {w,h}=dimensions(),k=Math.min(box.width/w,box.height/h),px=(e.clientX-box.left-(box.width-w*k)/2)/k,py=(e.clientY-box.top-(box.height-h*k)/2)/k;return {x:(px-64)/(w-84),y:1-(py-28)/(h-76)};}
 const inside=p=>p&&p.x>=0&&p.x<=1&&p.y>=0&&p.y<=1;
 function release(id){try{if(host.hasPointerCapture?.(id))host.releasePointerCapture(id);}catch{}}
 function cancel(){if(drag){const previous=drag;drag=null;view=previous.view;manual=previous.manual;release(previous.id);draw();}}
 function reset(){cancel();manual=false;if(host.style)host.style.height='';if(enabled){view={...initial};draw();}}
 on(fit,'click',reset);
 on(host,'wheel',e=>{if(!enabled||!e.ctrlKey)return;const p=pointer(e);if(!inside(p))return;e.preventDefault();if(drag||!e.deltaY)return;manual=true;const f=Math.exp(clamp(e.deltaY,-120,120)*.002),sx=clamp((view.xmax-view.xmin)*f,1e-10,1e100),sy=clamp((view.ymax-view.ymin)*f,1e-10,1e100),cx=view.xmin+(view.xmax-view.xmin)*p.x,cy=view.ymin+(view.ymax-view.ymin)*p.y;view={xmin:cx-sx*p.x,xmax:cx+sx*(1-p.x),ymin:cy-sy*p.y,ymax:cy+sy*(1-p.y)};draw();},{passive:false});
 const keydown=e=>{if((e.code==='Space'||e.key===' ')&&!e.target?.matches?.('input,textarea,select,button,[contenteditable=true]')){space=true;host.dataset.pan='true';if(hover||e.target===host)e.preventDefault();}if(e.key==='Escape')cancel();};
 const keyup=e=>{if(e.code==='Space'||e.key===' '){space=false;delete host.dataset.pan;}};
 on(host,'keydown',keydown);on(host,'keyup',keyup);on(host,'pointerenter',()=>{hover=true;});on(host,'pointerleave',()=>{hover=false;});
 if(root.addEventListener){on(root,'keydown',keydown);on(root,'keyup',keyup);}
 on(host,'pointerdown',e=>{host.focus?.({preventScroll:true});const p=pointer(e);if(!enabled||!space||e.button!==0||!inside(p))return;drag={id:e.pointerId,point:p,view:{...view},manual};try{host.setPointerCapture?.(e.pointerId);}catch{}e.preventDefault();});
 on(host,'pointermove',e=>{if(!drag||drag.id!==e.pointerId)return;const p=pointer(e);if(!p)return;const v=drag.view,dx=(p.x-drag.point.x)*(v.xmax-v.xmin),dy=(p.y-drag.point.y)*(v.ymax-v.ymin);manual=true;view={xmin:v.xmin-dx,xmax:v.xmax-dx,ymin:v.ymin-dy,ymax:v.ymax-dy};schedule();});
 on(host,'pointerup',e=>{if(drag?.id!==e.pointerId)return;drag=null;release(e.pointerId);draw();});
 for(const type of ['pointercancel','lostpointercapture'])on(host,type,cancel);
 const blur=()=>{space=false;delete host.dataset.pan;cancel();};on(host,'blur',blur);if(root.addEventListener)on(root,'blur',blur);
 const observer=root.ResizeObserver?new root.ResizeObserver(()=>{cancel();schedule();}):null;observer?.observe(host);
 return {update(lines,axes){cancel();series=lines;labels=axes;const p=series.flatMap(s=>s.points).filter(p=>Number.isFinite(p.x)&&Number.isFinite(p.y));let xmin=0,xmax=1,ymin=-1,ymax=1;if(p.length){xmin=Math.min(...p.map(p=>p.x));xmax=Math.max(...p.map(p=>p.x));ymin=Math.min(0,...p.map(p=>p.y));ymax=Math.max(0,...p.map(p=>p.y));}if(xmax===xmin)xmax=xmin+1;if(ymin===ymax){ymin-=1;ymax+=1;}const pad=(ymax-ymin)*.08;initial={xmin,xmax,ymin:ymin-pad,ymax:ymax+pad};if(!manual||!view)view={...initial};enabled=true;draw();},clear(){cancel();enabled=false;cancelFrame();host.innerHTML='';},reset,cancelDrag:cancel,destroy(){disposed=true;cancelFrame();observer?.disconnect();listeners.forEach(fn=>fn());},getView:()=>view?{...view}:null};
}
root.DigitalResponsePlot={mount,panel};if(typeof module!=='undefined'&&module.exports)module.exports=root.DigitalResponsePlot;
})(typeof window!=='undefined'?window:globalThis);
