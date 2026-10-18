/* Canvas geometry and rectilinear obstacle-avoiding routing; no HDL changes. */
(function(root){
'use strict';
const GAP=36,CLEAR=12,STUB=16,MIN=24,MAX=20000;
const clamp=(n,a,b)=>Math.max(a,Math.min(b,Math.round(n)));
function validateLayout(value,keys){
 if(!value||typeof value!=='object'||Array.isArray(value)||Object.keys(value).length>64)throw Error('模块布局数据无效。');
 const allowed=new Set(keys),out={};
 for(const [key,r]of Object.entries(value)){
  if(!allowed.has(key)||!r||typeof r!=='object'||['x','y','w','h'].some(k=>!Number.isFinite(r[k])))throw Error('布局引用了不存在的模块，或坐标无效。');
  if(r.x<MIN||r.y<MIN||r.x>MAX||r.y>MAX||r.w<80||r.h<40||r.w>1600||r.h>1000)throw Error('模块布局超出可用范围。');
  out[key]={x:Math.round(r.x),y:Math.round(r.y),w:Math.round(r.w),h:Math.round(r.h)};
 }
 return out;
}
const overlap=(a,b,gap=GAP)=>a.x<b.x+b.w+gap&&a.x+a.w+gap>b.x&&a.y<b.y+b.h+gap&&a.y+a.h+gap>b.y;
function constrain(box,rect,others){
 const r={x:clamp(rect.x,MIN,MAX),y:clamp(rect.y,MIN,MAX),w:clamp(rect.w,box.minW,1600),h:clamp(rect.h,box.minH,1000)};
 return others.some(b=>b.id!==box.id&&overlap(r,b))?null:r;
}
function place(box,others){
 let r=constrain(box,box,others);if(r)return {...box,...r};
 const xs=[box.x,MIN,...others.map(b=>b.x+b.w+GAP)].filter(x=>x<=MAX),ys=[box.y,MIN,...others.map(b=>b.y+b.h+GAP)].filter(y=>y<=MAX);let best=null,cost=Infinity;
 for(const x of xs)for(const y of ys){const d=Math.abs(x-box.x)+Math.abs(y-box.y);if(d>=cost)continue;const candidate=constrain(box,{...box,x,y},others);if(candidate){best=candidate;cost=d;}}
 if(!best)throw Error('当前画布没有足够的模块间距，请重新排列。');return {...box,...best};
}
function capture(boxes){return Object.fromEntries(boxes.map(b=>[b.id,{x:b.x,y:b.y,w:b.w,h:b.h}]));}
function inside(p,r){return p.x>r.x&&p.x<r.x+r.w&&p.y>r.y&&p.y<r.y+r.h;}
function hit(a,b,r){
 if(a.x===b.x)return a.x>r.x&&a.x<r.x+r.w&&Math.max(Math.min(a.y,b.y),r.y)<Math.min(Math.max(a.y,b.y),r.y+r.h);
 if(a.y===b.y)return a.y>r.y&&a.y<r.y+r.h&&Math.max(Math.min(a.x,b.x),r.x)<Math.min(Math.max(a.x,b.x),r.x+r.w);
 return true;
}
class Heap{
 constructor(){this.a=[];}
 less(a,b){return a.f<b.f||(a.f===b.f&&a.g>b.g);}
 push(v){let i=this.a.length;this.a.push(v);while(i){const p=(i-1)>>1;if(!this.less(v,this.a[p]))break;this.a[i]=this.a[p];i=p;}this.a[i]=v;}
 pop(){const first=this.a[0],last=this.a.pop();if(this.a.length){let i=0;while(i*2+1<this.a.length){let k=i*2+1;if(k+1<this.a.length&&this.less(this.a[k+1],this.a[k]))k++;if(!this.less(this.a[k],last))break;this.a[i]=this.a[k];i=k;}this.a[i]=last;}return first;}
}
function simplify(points){
 const out=[];for(const p of points){if(out.length&&out.at(-1).x===p.x&&out.at(-1).y===p.y)continue;
  while(out.length>=2){const a=out.at(-2),b=out.at(-1);if((a.x===b.x&&b.x===p.x&&(b.y-a.y)*(p.y-b.y)>=0)||(a.y===b.y&&b.y===p.y&&(b.x-a.x)*(p.x-b.x)>=0))out.pop();else break;}out.push(p);}
 return out;
}
function route(a,b,boxes){
 const start={x:a.x+STUB,y:a.y},end={x:b.x-STUB,y:b.y};
 const obstacles=boxes.map(r=>({x:r.x-CLEAR,y:r.y-CLEAR,w:r.w+2*CLEAR,h:r.h+2*CLEAR}));
 if(obstacles.some(r=>inside(start,r)||inside(end,r)))return null;
 const right=Math.max(start.x,end.x,...obstacles.map(r=>r.x+r.w))+40,bottom=Math.max(start.y,end.y,...obstacles.map(r=>r.y+r.h))+40;
 const unique=a=>[...new Set(a)].sort((a,b)=>a-b);
 const xs=unique([8,right,start.x,end.x,...obstacles.flatMap(r=>[r.x,r.x+r.w])]),ys=unique([8,bottom,start.y,end.y,...obstacles.flatMap(r=>[r.y,r.y+r.h])]);
 const nx=xs.length,n=nx*ys.length,startV=ys.indexOf(start.y)*nx+xs.indexOf(start.x),endV=ys.indexOf(end.y)*nx+xs.indexOf(end.x);
 const point=v=>({x:xs[v%nx],y:ys[Math.floor(v/nx)]}),cost=new Float64Array(n*3).fill(Infinity),previous=new Int32Array(n*3).fill(-1),usable=new Int8Array(n),heap=new Heap();
 const h=p=>Math.abs(p.x-end.x)+Math.abs(p.y-end.y);cost[startV*3+2]=0;heap.push({k:startV*3+2,g:0,f:h(start)});let found=-1;
 while(heap.a.length){const current=heap.pop();if(current.g!==cost[current.k])continue;const v=Math.floor(current.k/3),dir=current.k%3,p=point(v);if(v===endV){found=current.k;break;}
  const ix=v%nx,iy=Math.floor(v/nx),adj=[];if(ix)adj.push([v-1,0]);if(ix<nx-1)adj.push([v+1,0]);if(iy)adj.push([v-nx,1]);if(iy<ys.length-1)adj.push([v+nx,1]);
  for(const [next,d]of adj){const q=point(next);if(!usable[next])usable[next]=obstacles.some(r=>inside(q,r))?-1:1;if(usable[next]<0||obstacles.some(r=>hit(p,q,r)))continue;
   const g=current.g+Math.abs(q.x-p.x)+Math.abs(q.y-p.y)+(dir!==2&&dir!==d?22:0),k=next*3+d;if(g>=cost[k])continue;cost[k]=g;previous[k]=current.k;heap.push({k,g,f:g+h(q)});}
 }
 if(found<0)return null;
 const points=[];for(let k=found;k>=0;k=previous[k])points.push(point(Math.floor(k/3)));points.reverse();
 return simplify([{x:a.x,y:a.y},...points,{x:b.x,y:b.y}]);
}
function build(state,override){
 const saved=override||state.layout||{},pending=[];
 for(const [i,n]of state.instances.entries()){
  const d=state.modules.find(m=>m.key===n.moduleKey).design,inputs=d.ports.filter(p=>p.direction==='input'),outputs=d.ports.filter(p=>p.direction==='output');
  pending.push({id:n.id,kind:'module',title:n.id+' · '+d.moduleName,subtitle:d.kind+' · '+d.latency+' 拍',design:d,inputs,outputs,minW:220,minH:Math.max(108,68+22*Math.max(inputs.length,outputs.length)),x:350,y:32+i*180,w:330,h:128});
 }
 let l=0,r=0;for(const p of state.ports){const input=p.direction==='input';pending.push({id:(input?'in:':'out:')+p.name,kind:p.direction,title:p.name+' · '+p.direction,subtitle:p.width+' 位 · '+(p.signed?'signed':'unsigned')+' · F='+p.fraction,port:p,minW:180,minH:66,x:input?24:900,y:40+(input?l++:r++)*112,w:210,h:72});}
 // Honor existing positions first; find clear space for newly imported blocks.
 const order=pending.slice().sort((a,b)=>Number(!!saved[b.id])-Number(!!saved[a.id])),placed=[];
 for(const b of order)placed.push(place({...b,...saved[b.id]},placed));
 const boxes=pending.map(b=>placed.find(p=>p.id===b.id)),anchors=new Map();
 for(const box of boxes){
  if(box.kind==='module'){
   for(const [ports,input]of [[box.inputs,true],[box.outputs,false]])ports.forEach((p,i)=>anchors.set(box.id+':'+p.name,{owner:box.id,x:input?box.x:box.x+box.w,y:box.y+60+Math.round(i*Math.max(22,(box.h-80)/Math.max(1,ports.length-1))),side:input?'left':'right',label:p.name}));
  }else anchors.set(box.id,{owner:box.id,x:box.kind==='input'?box.x+box.w:box.x,y:box.y+Math.round(box.h/2),side:box.kind==='input'?'right':'left',label:box.port.name});
 }
 const routes=state.connections.map(c=>{const a=anchors.get(c.from),b=anchors.get(c.to),points=a&&b?route(a,b,boxes):null;return {...c,points,d:points?points.map((p,i)=>(i?'L':'M')+p.x+' '+p.y).join(' '):''};});
 return {boxes,anchors,routes,width:Math.max(1160,...boxes.map(b=>b.x+b.w+80)),height:Math.max(390,...boxes.map(b=>b.y+b.h+80))};
}
root.DigitalSystemLayout={validateLayout,build,route,capture,constrain,overlap,GAP};
if(typeof module!=='undefined'&&module.exports)module.exports=root.DigitalSystemLayout;
})(typeof window!=='undefined'?window:globalThis);
