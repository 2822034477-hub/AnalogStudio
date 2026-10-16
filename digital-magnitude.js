/* Digital magnitude display only. No model, quantizer or RTL mutation. */
(function(root){
'use strict';
const abs=x=>x<0n?-x:x,sign=x=>x<0n?-1:x>0n?1:0;
const gcd=(a,b)=>{a=abs(a);b=abs(b);while(b){const t=a%b;a=b;b=t;}return a;};
const trim=p=>{p=p.slice();while(p.length>1&&!p.at(-1))p.pop();return p;};
function primitive(p){p=trim(p);const g=p.reduce((g,v)=>gcd(g,v),0n);return g?p.map(v=>v/g):[0n];}
const zero=p=>p.length===1&&p[0]===0n;
function remainder(a,b){let r=a.slice();const s=sign(b.at(-1)),q=b.map(v=>v*BigInt(s)),lc=q.at(-1);while(!zero(r)&&r.length>=q.length){const k=r.length-q.length,t=r.at(-1);r=r.map(v=>v*lc);q.forEach((v,j)=>r[k+j]-=t*v);r=primitive(r);}return r;}
function quotient(a,b){let r=a.slice(),q=Array(Math.max(1,a.length-b.length+1)).fill(0n);const s=BigInt(sign(b.at(-1))),d=b.map(v=>v*s),lc=d.at(-1);while(!zero(r)&&r.length>=d.length){const k=r.length-d.length,t=r.at(-1);q=q.map(v=>v*lc);q[k]+=t;r=r.map(v=>v*lc);d.forEach((v,j)=>r[k+j]-=t*v);r=trim(r);}if(!zero(r))throw Error('Non-exact polynomial division.');return primitive(q);}
function polyGcd(a,b){while(!zero(b)){const r=remainder(a,b);a=b;b=r;}a=primitive(a);return a.at(-1)<0n?a.map(v=>-v):a;}
const derivative=p=>p.length>1?p.slice(1).map((v,i)=>v*BigInt(i+1)):[0n];
function sturm(p){const out=[p,derivative(p)];while(!zero(out.at(-1))){const r=remainder(out.at(-2),out.at(-1));if(zero(r))break;out.push(r.map(v=>-v));}return out.filter(p=>!zero(p));}
// Evaluate exactly at x=n/2^d: every operation remains an integer.
function at(p,n,d){const den=1n<<BigInt(d);let h=p.at(-1),power=den;for(let k=p.length-2;k>=0;k--){h=h*n+p[k]*power;power*=den;}return h;}
function variations(chain,n,d){let last=0,count=0;for(const p of chain){const s=sign(at(p,n,d));if(s){if(last&&s!==last)count++;last=s;}}return count;}
const middle=(a,b)=>{const d=Math.max(a.d,b.d);return {n:(a.n<<BigInt(d-a.d))+(b.n<<BigInt(d-b.d)),d:d+1};};
function frequency(x,fs){const den=2**x.d,n=Number(x.n),delta=Number((1n<<BigInt(x.d))-abs(x.n))/den;const w=2*Math.asin(Math.sqrt(Math.max(0,delta)/2));return (n<0?Math.PI-w:w)*fs/(2*Math.PI);}
function isolate(p,fs){
 p=primitive(p);if(p.length<2)return {roots:[],unresolved:0};
 p=quotient(p,polyGcd(p,derivative(p)));const roots=[];let unresolved=0;
 for(const x of [-1n,1n])if(at(p,x,0)===0n){roots.push({n:x,d:0});p=quotient(p,[-x,1n]);}
 while(p.length>1){const chain=sturm(p),found=[];let exact=null,budget=12000;
  function split(lo,hi,d,vl,vh){const count=vl-vh;if(!count||exact)return;if(--budget<0||d>160){unresolved+=count;return;}
   const mid={n:lo+hi,d:d+1};if(at(p,mid.n,mid.d)===0n){exact=mid;return;}
   const a={n:lo,d},b={n:hi,d};if(count===1&&Math.abs(frequency(a,fs)-frequency(b,fs))<=Math.max(1e-10,fs*1e-12)){found.push(mid);return;}
   const vm=variations(chain,mid.n,mid.d);split(lo*2n,mid.n,d+1,vl,vm);split(mid.n,hi*2n,d+1,vm,vh);
  }
  split(-1n,1n,0,variations(chain,-1n,0),variations(chain,1n,0));
  if(exact){roots.push(exact);p=quotient(p,[-exact.n,1n<<BigInt(exact.d)]);}else{roots.push(...found);break;}
 }
 return {roots:roots.sort((a,b)=>frequency(a,fs)-frequency(b,fs)),unresolved};
}
// Exact dyadic arithmetic prevents a nearly-flat response being called identically 0 dB.
function integers(a,b){const data=new DataView(new ArrayBuffer(8)),parts=[...a,...b].map(x=>{data.setFloat64(0,x);const bits=data.getBigUint64(0),exp=Number((bits>>52n)&2047n),frac=bits&((1n<<52n)-1n);return {n:(bits>>63n?-1n:1n)*(exp?(1n<<52n)|frac:frac),e:exp?exp-1075:-1074};});const e=Math.min(...parts.filter(x=>x.n).map(x=>x.e));const n=parts.map(x=>x.n?(x.n<<BigInt(x.e-e)):0n);return [n.slice(0,a.length),n.slice(a.length)];}
function powerPolynomial(a){const c=a.map((_,k)=>a.reduce((s,v,i)=>s+(i+k<a.length?v*a[i+k]:0n),0n)*(k?2n:1n));let previous=[1n],current=[0n,1n],out=Array(c.length).fill(0n);for(let k=0;k<c.length;k++){const t=k===0?previous:current;t.forEach((v,i)=>out[i]+=c[k]*v);if(k){const next=Array(current.length+1).fill(0n);current.forEach((v,i)=>next[i+1]+=2n*v);previous.forEach((v,i)=>next[i]-=v);previous=current;current=next;}}return trim(out);}
function crossings(model,evaluate){
 const fs=model.sampleRate,[b,a]=integers(model.b,model.a),bp=powerPolynomial(b),ap=powerPolynomial(a),p=primitive(Array.from({length:Math.max(bp.length,ap.length)},(_,i)=>(bp[i]||0n)-(ap[i]||0n))),den=isolate(ap,fs),undefinedFrequencies=den.roots.map(x=>frequency(x,fs));
 const result={status:'none',points:[],undefinedFrequencies,unresolved:den.unresolved,range:[0,fs/2]};
 if(zero(p)){result.status='flat';for(const f of [fs*.071,fs*.193,fs*.371]){const h=evaluate(model,f);if(!Number.isFinite(h.db)||Math.abs(h.db)>1e-7){result.status='uncertain';result.unresolved++;}}return result;}
 if(p.length===1)return result;
 const sf=quotient(p,polyGcd(p,derivative(p))),common=polyGcd(sf,ap),valid=quotient(sf,common),solved=isolate(valid,fs);result.unresolved+=solved.unresolved;
 const all=isolate(p,fs).roots;
 for(const x of solved.roots){let f=frequency(x,fs);const index=all.reduce((best,r,i)=>Math.abs(frequency(r,fs)-f)<Math.abs(frequency(all[best],fs)-f)?i:best,0),left=index?middle(all[index-1],x):middle({n:1n,d:0},x),right=index+1<all.length?middle(x,all[index+1]):middle(x,{n:-1n,d:0});
  const endpoint=f===0||f===fs/2,kind=endpoint?'endpoint':sign(at(p,left.n,left.d))!==sign(at(p,right.n,right.d))?'crossing':'touch';let h=evaluate(model,f);
  if(kind==='crossing'){
   const room=Math.min(f,fs/2-f,...all.filter(r=>r!==all[index]).map(r=>Math.abs(frequency(r,fs)-f)/3),...undefinedFrequencies.map(v=>Math.abs(v-f)/3));
   let radius=Math.min(room*.9,Math.max(fs*1e-10,1e-8));
   for(let attempt=0;attempt<6&&radius>0;attempt++,radius=Math.min(room*.9,radius*10)){
    let lo=f-radius,hi=f+radius,yl=evaluate(model,lo).db,yh=evaluate(model,hi).db;if(!Number.isFinite(yl)||!Number.isFinite(yh)||yl*yh>=0)continue;
    for(let i=0;i<80;i++){const mid=(lo+hi)/2,hm=evaluate(model,mid);if(!Number.isFinite(hm.db))break;if(Math.abs(hm.db)<Math.abs(h.db)){f=mid;h=hm;}if(Math.abs(hm.db)<1e-11||mid===lo||mid===hi)break;if(yl*hm.db<=0){hi=mid;yh=hm.db;}else{lo=mid;yl=hm.db;}}break;
   }
  }
  if(!Number.isFinite(h.db)||Math.abs(h.db)>1e-7){result.unresolved++;continue;}
  result.points.push({frequency:f,kind,residualDb:h.db});
 }
 result.points.sort((a,b)=>a.frequency-b.frequency);result.status=result.unresolved?'uncertain':result.points.length?'points':'none';return result;
}
const esc=x=>String(x).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const fmt=x=>Number.isFinite(x)?Number(x.toPrecision(7)).toString():'未定义';
const clamp=(x,a,b)=>Math.max(a,Math.min(b,x));
let instance=0;
function svg(series,view,{inset=false,ratio=false,id='magnitude',width,height}={}){
 const W=width||(inset?420:640),H=height||320,L=62,R=18,T=28,B=48,unit=ratio?1:0,x=f=>L+(f-view.xmin)/(view.xmax-view.xmin)*(W-L-R),y=v=>H-B-(v-view.ymin)/(view.ymax-view.ymin)*(H-T-B),clip=id+(inset?'-inset':'-main');
 let html='<svg viewBox="0 0 '+W+' '+H+'" role="img" aria-label="'+(inset?'单位增益附近放大图':'数字幅频图')+'" data-frequency-min="'+view.xmin+'" data-frequency-max="'+view.xmax+'"><defs><clipPath id="'+clip+'"><rect x="'+L+'" y="'+T+'" width="'+(W-L-R)+'" height="'+(H-T-B)+'"/></clipPath></defs>';
 for(let i=0;i<=4;i++){const f=view.xmin+(view.xmax-view.xmin)*i/4,v=view.ymin+(view.ymax-view.ymin)*i/4;html+='<path d="M'+x(f)+' '+T+'V'+(H-B)+'M'+L+' '+y(v)+'H'+(W-R)+'" stroke="#dce5ee" fill="none"/><text x="'+x(f)+'" y="'+(H-B+18)+'" text-anchor="middle">'+fmt(f)+'</text><text x="'+(L-7)+'" y="'+(y(v)+4)+'" text-anchor="end">'+fmt(v)+'</text>';}
 const visibleUnit=unit>=view.ymin&&unit<=view.ymax;
 if(visibleUnit)html+='<line data-unity-reference="'+unit+'" x1="'+L+'" y1="'+y(unit)+'" x2="'+(W-R)+'" y2="'+y(unit)+'" stroke="#34495e" stroke-width="1.6" stroke-dasharray="4 3"/>';
 for(const s of series){let d='',pen=false;for(const p of s.points){const v=ratio?p.magnitude:p.db;if(!Number.isFinite(v)){pen=false;continue;}d+=(pen?'L':'M')+x(p.frequency).toFixed(3)+' '+y(v).toFixed(3)+' ';pen=true;}html+='<path d="'+d+'" stroke="'+s.color+'" stroke-width="2" fill="none" clip-path="url(#'+clip+')"'+(s.dash?' stroke-dasharray="7 4"':'')+'/>';}
 if(visibleUnit){let occupied=[[],[]];series.forEach((s,row)=>s.crossings.points.forEach((p,i)=>{if(p.frequency<view.xmin||p.frequency>view.xmax)return;const xx=x(p.frequency),yy=y(unit),label=s.key+(i+1),title=label+' '+fmt(p.frequency)+' Hz · '+({crossing:'穿越',touch:'触碰',endpoint:'端点'}[p.kind]);html+='<g data-unity-point="'+esc(label)+'" data-frequency="'+p.frequency+'"><title>'+esc(title)+'</title>'+(s.dash?'<rect x="'+(xx-2.5)+'" y="'+(yy-2.5)+'" width="5" height="5" fill="'+s.color+'"/>':'<circle cx="'+xx+'" cy="'+yy+'" r="5" fill="white" stroke="'+s.color+'" stroke-width="1.8"/>');if(!occupied[row].some(v=>Math.abs(v-xx)<30)){const ly=yy<T+26?yy+14+row*15:yy>H-B-30?yy-27+row*15:yy+(row?19:-11);html+='<text x="'+clamp(xx+5,L+4,W-R-23)+'" y="'+ly+'" class="dd-mag-point-label" style="fill:'+s.color+'">'+label+'</text>';occupied[row].push(xx);}html+='</g>';}));}
 html+='<text x="'+L+'" y="16">'+(ratio?'|H|（倍）':'dB')+'</text><text x="'+(W-R)+'" y="'+(H-6)+'" text-anchor="end">频率 / Hz</text>';
 html+='<text class="dd-mag-reference-label" x="'+(W-R)+'" y="16" text-anchor="end">'+(ratio?(inset?'单位增益 1':'单位增益 = 1'):(inset?'0 dB':'0 dB = 单位增益'))+(visibleUnit?'':unit>view.ymax?' ↑':' ↓')+'</text></svg>';return html;
}
function mount(nodes,evaluate){
 const {main,inset,summary,scale,zoomIn,zoomOut,fit,range}=nodes,id='dd-magnitude-'+(++instance),listeners=[];
 let curves=[],view=null,auto=null,fs=48000,ratio=false,enabled=false,manual=false,drag=null,frame=null,destroyed=false,hover=false;
 const on=(el,event,fn,options)=>{el.addEventListener(event,fn,options);listeners.push(()=>el.removeEventListener(event,fn,options));};
 function bound(v){const full=fs/2,span=clamp(v.xmax-v.xmin,full/1e6,full),left=clamp(v.xmin,0,full-span);return {...v,xmin:left,xmax:left+span};}
 function sample(s,min,max){const frequencies=Array.from({length:513},(_,i)=>min+(max-min)*i/512);for(const p of s.crossings.points)if(p.frequency>=min&&p.frequency<=max)frequencies.push(p.frequency);const values=[...new Set(frequencies)].sort((a,b)=>a-b);if(s.cache.size>4096)s.cache.clear();return values.map(f=>{if(!s.cache.has(f))s.cache.set(f,evaluate(s.model,f));return {frequency:f,...s.cache.get(f)};});}
 function summaryHtml(){const kind={crossing:'穿越',touch:'触碰',endpoint:'端点'};return curves.map(s=>{const c=s.crossings;let detail;if(c.status==='flat')detail='整个频段为 0 dB（单位增益；响应有定义处）';else if(!c.points.length)detail=c.unresolved?'存在无法可靠确认的候选点，未标注':'没有 0 dB 交越或触碰';else detail=c.points.map((p,i)=>'<button type="button" data-mag-frequency="'+p.frequency+'" title="定位到此频率附近">'+s.key+(i+1)+' ≈ '+fmt(p.frequency)+' Hz · '+kind[p.kind]+(p.frequency<view.xmin||p.frequency>view.xmax?'（视窗外）':'')+'</button>').join(' ');if(c.unresolved&&c.points.length)detail+='；另有 '+c.unresolved+' 个候选未可靠确认';if(c.undefinedFrequencies.length)detail+='；未定义频率：'+c.undefinedFrequencies.map(f=>fmt(f)+' Hz').join('、');return '<div class="dd-mag-crossing-row"><strong style="color:'+s.color+'">'+s.label+'</strong><span>'+detail+'</span></div>';}).join('');}
 function draw(){cancelFrame();if(!enabled||destroyed)return;const series=curves.map(s=>({...s,points:sample(s,view.xmin,view.xmax)})),near={...view,ymin:ratio?10**(-1/20):-1,ymax:ratio?10**(1/20):1};main.innerHTML=svg(series,view,{ratio,id,width:main.clientWidth,height:main.clientHeight});inset.innerHTML=svg(series,near,{ratio,id,inset:true,width:inset.clientWidth,height:inset.clientHeight});main.dataset.frequencyMin=inset.dataset.frequencyMin=String(view.xmin);main.dataset.frequencyMax=inset.dataset.frequencyMax=String(view.xmax);range.textContent='共享频率范围 '+fmt(view.xmin)+'–'+fmt(view.xmax)+' Hz；小窗 '+(ratio?'单位增益附近（等效 ±1 dB）':'−1 至 +1 dB')+'。';summary.innerHTML=summaryHtml();}
 function schedule(){if(frame!==null)return;if(root.requestAnimationFrame)frame=root.requestAnimationFrame(draw);else draw();}
 function cancelFrame(){if(frame!==null&&root.cancelAnimationFrame)root.cancelAnimationFrame(frame);frame=null;}
 function defaults(){const points=curves.flatMap(s=>sample(s,0,fs/2)),values=points.map(p=>ratio?p.magnitude:p.db).filter(Number.isFinite),unit=ratio?1:0;let min=Math.min(unit,...values),max=Math.max(unit,...values);if(min===max){min-=ratio?.1:1;max+=ratio?.1:1;}const pad=(max-min)*.08;return {xmin:0,xmax:fs/2,ymin:ratio?Math.max(0,min-pad):min-pad,ymax:max+pad};}
 function zoom(factor,anchor={x:.5,y:.5}){if(!enabled)return;manual=true;const sx=(view.xmax-view.xmin)/factor,sy=clamp((view.ymax-view.ymin)/factor,1e-10,1e100),fx=view.xmin+(view.xmax-view.xmin)*anchor.x,fy=view.ymin+(view.ymax-view.ymin)*anchor.y;view=bound({xmin:fx-sx*anchor.x,xmax:fx+sx*(1-anchor.x),ymin:fy-sy*anchor.y,ymax:fy+sy*(1-anchor.y)});draw();}
 function pointer(e){const s=main.querySelector('svg'),r=s?.getBoundingClientRect?.();if(!r||!r.width||!r.height)return null;const W=main.clientWidth||640,H=main.clientHeight||320,k=Math.min(r.width/W,r.height/H),xx=(e.clientX-r.left-(r.width-W*k)/2)/k,yy=(e.clientY-r.top-(r.height-H*k)/2)/k;return {x:(xx-62)/(W-62-18),y:1-(yy-28)/(H-28-48)};}
 const inside=p=>p&&p.x>=0&&p.x<=1&&p.y>=0&&p.y<=1;
 function cancel(){if(drag){view=drag.view;manual=drag.manual;drag=null;cancelFrame();draw();}}
 on(main,'wheel',e=>{if(!e.ctrlKey||!enabled)return;const p=pointer(e);if(!inside(p))return;e.preventDefault();if(!drag&&e.deltaY)zoom(Math.exp(-clamp(e.deltaY,-120,120)*.002),p);},{passive:false});
 on(main,'pointerdown',e=>{const p=pointer(e);if(!enabled||e.button!==0||e.pointerType==='touch'||!inside(p))return;drag={point:p,view:{...view},manual,pointerId:e.pointerId};main.focus?.({preventScroll:true});main.setPointerCapture?.(e.pointerId);e.preventDefault();});
 on(main,'pointermove',e=>{if(!drag||drag.pointerId!==e.pointerId)return;const p=pointer(e);if(!p)return;manual=true;const v=drag.view,dx=(p.x-drag.point.x)*(v.xmax-v.xmin),dy=(p.y-drag.point.y)*(v.ymax-v.ymin);view=bound({xmin:v.xmin-dx,xmax:v.xmax-dx,ymin:v.ymin-dy,ymax:v.ymax-dy});schedule();});
 on(main,'pointerup',e=>{if(!drag||drag.pointerId!==e.pointerId)return;drag=null;cancelFrame();draw();if(main.hasPointerCapture?.(e.pointerId))main.releasePointerCapture?.(e.pointerId);});
 for(const event of ['pointercancel','lostpointercapture','blur'])on(main,event,cancel);if(root.addEventListener&&root.removeEventListener)on(root,'blur',cancel);
 const keydown=e=>{if((e.code==='Space'||e.key===' ')&&(hover||e.target===main)&&!e.target?.matches?.('input,textarea,select,button,[contenteditable=true]'))e.preventDefault();if(e.key==='Escape')cancel();};
 on(main,'pointerenter',()=>{hover=true;});on(main,'pointerleave',()=>{hover=false;});on(main,'keydown',keydown);if(root.addEventListener)on(root,'keydown',keydown);
 on(zoomIn,'click',()=>zoom(1.5));on(zoomOut,'click',()=>zoom(1/1.5));on(fit,'click',()=>{if(main.style)main.style.height='';if(inset.style)inset.style.height='';if(enabled){drag=null;manual=false;view={...auto};draw();}});
 on(scale,'change',()=>{ratio=scale.value==='ratio';if(enabled){auto=defaults();view={...view,ymin:auto.ymin,ymax:auto.ymax};draw();}});
 on(summary,'click',e=>{const f=Number(e.target.closest?.('[data-mag-frequency]')?.getAttribute('data-mag-frequency'));if(!enabled||!Number.isFinite(f)||f<0||f>fs/2)return;manual=true;const span=fs/24;view=bound({...view,xmin:f-span/2,xmax:f+span/2});draw();});
 const observer=root.ResizeObserver?new root.ResizeObserver(()=>{cancel();schedule();}):null;observer?.observe(main);observer?.observe(inset);
 return {cancelDrag:cancel,update(series){cancelFrame();if(drag){view=drag.view;manual=drag.manual;}drag=null;const changedRate=fs!==series[0].model.sampleRate;fs=series[0].model.sampleRate;curves=series.map(s=>{let c;try{c=crossings(s.model,evaluate);}catch(e){c={status:'uncertain',points:[],undefinedFrequencies:[],unresolved:1};}return {...s,crossings:c,cache:new Map()};});auto=defaults();view=!view||changedRate||!manual?{...auto}:bound(view);enabled=true;draw();},reset(){enabled=false;drag=null;cancelFrame();view=null;manual=false;ratio=false;scale.value='db';},clear(){enabled=false;drag=null;cancelFrame();main.innerHTML=inset.innerHTML=summary.innerHTML='';range.textContent='';},destroy(){observer?.disconnect();destroyed=true;enabled=false;cancelFrame();listeners.forEach(f=>f());},getView:()=>view?{...view,ratio}:null};
}
root.DigitalMagnitude={crossings,svg,mount};
if(typeof module!=='undefined'&&module.exports)module.exports=root.DigitalMagnitude;
})(typeof window!=='undefined'?window:globalThis);
