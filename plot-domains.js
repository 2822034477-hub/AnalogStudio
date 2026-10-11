/* Independent data-coordinate views; zoom and pan never change model values. */
(function(root){
'use strict';
const views=new Map(),active=new Map(),observed=new WeakSet(),pendingViews=new Map();
const clamp=(n,a,b)=>Math.max(a,Math.min(b,n)),copy=value=>({...value});
function current(id){return views.get(active.get(id));}
function partOf(v,part){return v?.mode==='bode'?(part||v.part||'gain'):'main';}
function axes(v,part){return partOf(v,part)==='phase'?['px','p']:['x','y'];}
function logOf(v,part){return !!v?.meta.log&&(v.frequency?.[partOf(v,part)]||'log')==='log';}
function ratioOf(v,part){return !!v&&(v.mode==='bode'?partOf(v,part)==='gain':v.id==='expMagnitude')&&v.magnitude==='ratio';}
function scales(v,part){if(!v)return {x:1,y:1};const [x,y]=axes(v,part),ratio=a=>(v.auto[a+'max']-v.auto[a+'min'])/(v.domain[a+'max']-v.domain[a+'min']);return {x:ratio(x),y:ratio(y)};}
function scaleOf(v){return scales(v).x;}
function publish(v){
 const detail={id:v.id,mode:v.mode,scale:scaleOf(v),scales:scales(v),part:partOf(v),direction:v.direction,domain:copy(v.domain),log:logOf(v),equal:!!v.meta.equal&&!v.freeAspect};
 if(v.meta.log){detail.domain.frequencyMin=logOf(v,'gain')?10**v.domain.xmin:v.domain.xmin;detail.domain.frequencyMax=logOf(v,'gain')?10**v.domain.xmax:v.domain.xmax;if(v.mode==='bode'){detail.domain.phaseFrequencyMin=logOf(v,'phase')?10**v.domain.pxmin:v.domain.pxmin;detail.domain.phaseFrequencyMax=logOf(v,'phase')?10**v.domain.pxmax:v.domain.pxmax;}}
 const el=root.document?.getElementById(v.id);if(el){el.dataset.plotDomain=JSON.stringify(detail.domain);el.dataset.plotMode=v.mode;el.dataset.plotPart=detail.part;el.dataset.plotAspect=detail.equal?'equal':'independent';}
 const signature=JSON.stringify(detail);if(signature!==v.signature){v.signature=signature;if(root.dispatchEvent&&root.CustomEvent)root.dispatchEvent(new root.CustomEvent('analog:plot-view',{detail}));}
}
function use(id,mode,auto,redraw,meta={}){
 const key=id+':'+mode,changed=active.get(id)!==key;let v=views.get(key);
 if(!v){v={id,mode,auto:copy(auto),domain:copy(auto),manual:new Set(),part:'gain',direction:'both',freeAspect:false,frequency:{},magnitude:'db'};views.set(key,v);}
 const saved=pendingViews.get(key);if(saved){v.part=saved.part;v.direction=saved.direction;v.freeAspect=saved.freeAspect;v.frequency=copy(saved.frequency);v.magnitude=saved.magnitude;v.manual=new Set(Object.keys(saved.manual));Object.assign(v.domain,saved.manual);pendingViews.delete(key);}
 v.meta=meta;auto=copy(auto);
 for(const part of mode==='bode'?['gain','phase']:['main']){const [x,y]=axes(v,part);if(meta.log&&!logOf(v,part)){auto[x+'min']=10**auto[x+'min'];auto[x+'max']=10**auto[x+'max'];}if(ratioOf(v,part)){auto[y+'min']=0;auto[y+'max']=10**(auto[y+'max']/20);}}
 v.auto=copy(auto);v.redraw=redraw;
 for(const k of Object.keys(auto))if(!v.manual.has(k))v.domain[k]=auto[k];
 if(v.manual.size&&meta.equal&&!v.freeAspect&&meta.rect){const r=meta.rect,yc=(v.domain.ymin+v.domain.ymax)/2,half=(v.domain.xmax-v.domain.xmin)*(r.b-r.t)/(r.r-r.l)/2;v.domain.ymin=yc-half;v.domain.ymax=yc+half;}
 v.meta=meta;active.set(id,key);const surface=root.document?.getElementById(id);
 if(surface&&root.ResizeObserver&&!observed.has(surface)){observed.add(surface);let size='';new root.ResizeObserver(entries=>{const r=entries[0]?.contentRect;if(!r||r.width<1||r.height<1)return;const next=r.width+':'+r.height;if(next===size)return;size=next;current(id)?.redraw();}).observe(surface);}
 if(changed)v.signature=null;publish(v);return copy(v.domain);
}
function rectOf(v,part){const r=v.meta.rect||{l:0,r:1,t:0,b:1,w:1,h:1};return partOf(v,part)==='phase'?{...r,t:r.pt,b:r.pb}:r;}
function hit(id,anchor){const v=current(id);if(!v||!anchor)return null;const r=v.meta.rect,px=anchor.x*r.w,py=anchor.y*r.h;if(px<r.l||px>r.r)return null;for(const part of v.mode==='bode'?['gain','phase']:['main']){const a=rectOf(v,part);if(py>=a.t&&py<=a.b)return part;}return null;}
function select(id,part){const v=current(id);if(!v)return false;if(v.mode==='bode'&&['gain','phase'].includes(part))v.part=part;publish(v);return true;}
function direction(id,value){const v=current(id);if(!v||!['both','x','y'].includes(value))return false;v.direction=value;publish(v);return true;}
function anchorOf(v,anchor,part){const r=rectOf(v,part);if(!anchor)return {x:.5,y:.5};return {x:clamp((anchor.x*r.w-r.l)/(r.r-r.l),0,1),y:clamp(1-(anchor.y*r.h-r.t)/(r.b-r.t),0,1)};}
function guard(v,next,x,part){if(v.meta.log){const log=logOf(v,part),low=log?-6:1e-6,high=log?12:1e12,span=Math.min(high-low,next[x+'max']-next[x+'min']);next[x+'min']=clamp(next[x+'min'],low,high-span);next[x+'max']=next[x+'min']+span;}}
function zoom(id,factor,anchor,options={}){
 const v=current(id);if(!v||!Number.isFinite(factor)||factor<=0)return false;
 const part=options.part||partOf(v),direction=options.direction||v.direction,a=anchorOf(v,anchor,part),next=copy(v.domain),xy=axes(v,part);
 for(const [i,key]of xy.entries()){const axis=i?'y':'x';if(direction!=='both'&&direction!==axis)continue;const min=key+'min',max=key+'max',old=(v.auto[max]-v.auto[min])/(next[max]-next[min]),f=clamp(old*factor,.25,128)/old,at=next[min]+(next[max]-next[min])*a[axis],span=(next[max]-next[min])/f;next[min]=at-span*a[axis];next[max]=at+span*(1-a[axis]);v.manual.add(min);v.manual.add(max);}
 if(direction!=='y')guard(v,next,xy[0],part);if(v.meta.equal&&direction!=='both')v.freeAspect=true;
 v.domain=next;v.redraw();return true;
}
function pan(id,dx,dy,part){
 const v=current(id);if(!v||!Number.isFinite(dx)||!Number.isFinite(dy))return false;const next=copy(v.domain),[x,y]=axes(v,part),sx=dx*(next[x+'max']-next[x+'min']),sy=dy*(next[y+'max']-next[y+'min']);
 next[x+'min']-=sx;next[x+'max']-=sx;next[y+'min']+=sy;next[y+'max']+=sy;guard(v,next,x,part);
 for(const a of [x,y])for(const side of ['min','max'])v.manual.add(a+side);v.domain=next;v.redraw();return true;
}
function fit(id,part){const v=current(id);if(!v)return false;const keys=part?axes(v,part).flatMap(a=>[a+'min',a+'max']):Object.keys(v.auto);for(const k of keys){v.manual.delete(k);v.domain[k]=v.auto[k];}v.freeAspect=false;v.redraw();return true;}
function frequency(id,value){const v=current(id);if(!v?.meta.log||!['log','linear'].includes(value))return false;const part=partOf(v),[x]=axes(v,part);v.frequency[part]=value;for(const side of ['min','max'])v.manual.delete(x+side);v.redraw();return true;}
function magnitude(id,value){const v=current(id);if(!v||!['db','ratio'].includes(value)||!(v.mode==='bode'||id==='expMagnitude'))return false;v.magnitude=value;for(const side of ['min','max'])v.manual.delete('y'+side);v.redraw();return true;}
function clear(id){for(const [key,v]of pendingViews)if(v.id===id)pendingViews.delete(key);active.delete(id);for(const [key,v]of views)if(v.id===id)views.delete(key);const el=root.document?.getElementById(id);if(el){delete el.dataset.plotDomain;delete el.dataset.plotMode;delete el.dataset.plotPart;delete el.dataset.plotAspect;}if(root.dispatchEvent&&root.CustomEvent)root.dispatchEvent(new root.CustomEvent('analog:plot-view',{detail:{id,scale:1,domain:null,mode:null}}));}
  function ticks(min,max,log=false,target=6) {
    if(!Number.isFinite(min)||!Number.isFinite(max)||max<=min)return [];
    if(log && max-min>=1.5) {
      const out=[],span=max-min,stride=Math.max(1,Math.ceil(span/Math.max(2,target)));
      const multiples=span<=2.5?[1,2,5]:[1];
      for(let exponent=Math.floor(min);exponent<=Math.ceil(max);exponent++) {
        if(stride>1 && exponent%stride!==0)continue;
        for(const mult of multiples){const value=mult*10**exponent,pos=Math.log10(value);if(pos>=min-1e-10&&pos<=max+1e-10)out.push({pos,value});}
      }
      return out;
    }
    const lo=log?10**min:min,hi=log?10**max:max;
    const raw=(hi-lo)/Math.max(2,target), power=10**Math.floor(Math.log10(raw)), ratio=raw/power;
    const step=([1,2,2.5,5,10].find(x=>x>=ratio)||10)*power;
    const out=[];
    for(let i=Math.ceil((lo-step*1e-9)/step);i<=Math.floor((hi+step*1e-9)/step)&&out.length<100;i++){
      const value=Math.abs(i*step)<step*1e-10?0:Number((i*step).toPrecision(14));
      if(log&&value<=0)continue;out.push({pos:log?Math.log10(value):value,value});
    }
    return out;
  }
  function exportViews(){
    const out=new Map(pendingViews);
    for(const [key,v]of views){if(pendingViews.has(key))continue;const manual=Object.fromEntries([...v.manual].sort().map(k=>[k,v.domain[k]]));const frequency=Object.fromEntries(Object.entries(v.frequency).filter(([k,value])=>value!=='log').sort());
      if(Object.keys(manual).length||Object.keys(frequency).length||v.part!=='gain'||v.direction!=='both'||v.freeAspect||v.magnitude!=='db')out.set(key,{id:v.id,mode:v.mode,part:v.part,direction:v.direction,freeAspect:v.freeAspect,frequency,magnitude:v.magnitude,manual});else out.delete(key);
    }return [...out.entries()].sort(([a],[b])=>a.localeCompare(b)).map(([,v])=>v);
  }
  function importViews(values){pendingViews.clear();for(const value of values)pendingViews.set(value.id+':'+value.mode,JSON.parse(JSON.stringify(value)));for(const v of views.values()){v.part='gain';v.direction='both';v.freeAspect=false;v.frequency={};v.magnitude='db';v.manual.clear();v.domain=copy(v.auto);}for(const id of active.keys())current(id)?.redraw();}
  root.AnalogPlotView={exportViews,importViews,use,zoom,pan,fit,clear,ticks,hit,select,direction,frequency,magnitude,frequencyLog:(id,part)=>logOf(current(id),part),amplitudeRatio:(id,part)=>ratioOf(current(id),part),scale:id=>scaleOf(current(id)),scales:id=>scales(current(id)),
    info:id=>{const v=current(id);return v?{part:partOf(v),direction:v.direction,mode:v.mode,frequency:v.meta.log?(logOf(v)?'log':'linear'):null,magnitude:v.magnitude,equal:!!v.meta.equal&&!v.freeAspect,rect:copy(rectOf(v))}:null;},
    defer:(id,redraw)=>{const v=current(id);if(v)v.redraw=redraw;},
    domain:id=>{const v=current(id);return v?{...v.domain,mode:v.mode,log:logOf(v)}:null;},available:id=>!!current(id)};
  let pending=false;root.addEventListener?.('resize',()=>{if(pending)return;pending=true;(root.requestAnimationFrame||root.setTimeout)(()=>{pending=false;for(const id of active.keys())current(id)?.redraw();});});
})(typeof window!=='undefined'?window:globalThis);
