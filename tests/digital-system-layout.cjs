'use strict';
const assert=require('node:assert/strict'),L=require('../digital-system-layout'),M=require('../digital-modules');
const c=M.defaults('subtract');c.timing='registered';const p=M.create(c),f={width:16,signed:true,fraction:8};
function state(count=3){const s=M.empty();s.view='system';s.modules=[{key:'m',design:p}];s.instances=Array.from({length:count},(_,i)=>({id:'u'+i,moduleKey:'m'}));s.ports=[{name:'x',direction:'input',...f},{name:'y',direction:'output',...f}];s.connections=[{from:'in:x',to:'u0:a'},{from:'in:x',to:'u0:b'}];for(let i=1;i<count;i++){s.connections.push({from:'u'+(i-1)+':data_out',to:'u'+i+':a'},{from:'u'+i+':data_out',to:'u'+i+':b'});}s.connections.push({from:'u'+(count-1)+':data_out',to:'out:y'});return s;}
let segments=0,routes=0;
function inspect(s){const scene=L.build(s);for(const a of scene.boxes)for(const b of scene.boxes)if(a!==b)assert(!L.overlap(a,b),'blocks must leave routing space');
 for(const r of scene.routes){assert(r.points&&r.points.length>=2,JSON.stringify(r));routes++;const a=scene.anchors.get(r.from),b=scene.anchors.get(r.to);assert.deepEqual(r.points[0],{x:a.x,y:a.y});assert.deepEqual(r.points.at(-1),{x:b.x,y:b.y});
  for(let i=1;i<r.points.length;i++){const u=r.points[i-1],v=r.points[i];assert(u.x===v.x||u.y===v.y);segments++;
   // Independent open-interior intersection check, including source/destination blocks.
   for(const box of scene.boxes){if(u.y===v.y)assert(!(u.y>box.y&&u.y<box.y+box.h&&Math.min(u.x,v.x)<box.x+box.w&&Math.max(u.x,v.x)>box.x));else assert(!(u.x>box.x&&u.x<box.x+box.w&&Math.min(u.y,v.y)<box.y+box.h&&Math.max(u.y,v.y)>box.y));}
  }
 }return scene;}
const s=state(),original=M.generateSystem(s),scene=inspect(s),layout=L.capture(scene.boxes);
s.layout=layout;assert.deepEqual(M.validateState(s).layout,layout);assert.equal(M.generateSystem(s),original);
const box=scene.boxes[0];assert.equal(L.constrain(box,{...box,x:scene.boxes[1].x,y:scene.boxes[1].y},scene.boxes),null);
assert.equal(L.constrain(box,{...box,w:1,h:1},scene.boxes).w,box.minW);
const bad=JSON.parse(JSON.stringify(s));bad.layout.missing={x:24,y:24,w:220,h:110};assert.throws(()=>M.validateState(bad),/布局引用/);
const badNumber=JSON.parse(JSON.stringify(s));badNumber.layout.u0.x=Infinity;assert.throws(()=>M.validateState(badNumber));
// Existing project files without layout continue to use a deterministic clear layout.
assert.deepEqual(L.capture(L.build(state()).boxes),L.capture(L.build(state()).boxes));
let seed=1234567;const rnd=()=>((seed=(Math.imul(seed,1664525)+1013904223)>>>0)/4294967296);
for(let trial=0;trial<28;trial++){
 const t=state(4+Math.floor(rnd()*13));t.layout={};for(const [i,n]of t.instances.entries())t.layout[n.id]={x:300+(i%4)*550,y:32+Math.floor(i/4)*280,w:220+Math.floor(rnd()*180),h:112+Math.floor(rnd()*80)};
 t.layout['in:x']={x:24,y:32,w:180,h:72};t.layout['out:y']={x:2600,y:32,w:210,h:72};
 // Include long backward and self feedback wires, and obstacles that have no edge.
 for(let i=1;i<t.instances.length;i++)t.connections.find(c=>c.to==='u'+i+':b').from='u'+Math.floor(rnd()*t.instances.length)+':data_out';
 inspect(t);assert.equal(M.generateSystem(t),M.generateSystem({...t,layout:undefined}));
}
// Imported overlapping coordinates are displayed with separation, never hidden routing.
const overlapping=state(6);overlapping.layout=Object.fromEntries(overlapping.instances.map(n=>[n.id,{x:350,y:32,w:330,h:128}]));inspect(overlapping);
console.log('PASS system layout: '+routes+' routes / '+segments+' orthogonal segments avoid all block interiors; randomized resized layouts, backward/self feedback, overlap resolution, collision/min-size bounds, persistence, legacy migration and byte-identical HDL.');
