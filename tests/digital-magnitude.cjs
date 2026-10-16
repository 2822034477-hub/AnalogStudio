'use strict';
const assert=require('node:assert/strict'),D=require('../digital-design'),M=require('../digital-magnitude');
let checks=0;const near=(a,b,t=1e-5)=>{assert(Math.abs(a-b)<=t,`${a} != ${b}`);checks++;};
const fs=48000,analyze=v=>{const m=D.create({...v,sampleRate:fs}),original=JSON.stringify(m),rtl=(()=>{try{return D.generateVerilog(m);}catch{return null;}})(),r=M.crossings(m,D.evaluate);assert.equal(JSON.stringify(m),original);if(rtl)assert.equal(D.generateVerilog(m),rtl);r.points.forEach(p=>assert(Math.abs(D.evaluate(m,p.frequency).db)<=1e-7));checks+=3;return r;};
let r=analyze({b:[1,0,1],a:[1]});assert.equal(r.points.length,2);near(r.points[0].frequency,fs/6);near(r.points[1].frequency,fs/3);assert(r.points.every(p=>p.kind==='crossing'));
r=analyze({b:[1,0,0,0,0,0,0,0,1],a:[1]});assert.equal(r.points.length,8);for(const [i,f] of [2000,4000,8000,10000,14000,16000,20000,22000].entries())near(r.points[i].frequency,f);
// Exactly representable zero-phase FIR envelope: 1 - (cos(w)-1/4)^2/4.
const tangent=[-1/16,1/16,55/64,1/16,-1/16],fTouch=Math.acos(.25)*fs/(2*Math.PI);
r=analyze({b:tangent,a:[1]});assert.equal(r.points.length,1);assert.equal(r.points[0].kind,'touch');near(r.points[0].frequency,fTouch);
// Both true crossings are between the SAME adjacent 513-point scan samples.
const eps=2**-30;r=analyze({b:tangent.map(v=>v*(1+eps)),a:[1]});assert.equal(r.points.length,2);assert(r.points.every(p=>p.kind==='crossing'));assert.equal(Math.floor(r.points[0].frequency/(fs/1024)),Math.floor(r.points[1].frequency/(fs/1024)));assert(r.points[0].frequency<fTouch&&r.points[1].frequency>fTouch);
const missed=analyze({b:tangent.map(v=>v*(1-eps)),a:[1]});assert.equal(missed.status,'none');assert.equal(missed.points.length,0);
for(const v of [{b:[1],a:[1]},{b:[0,0,1],a:[1]},{b:[.25,1],a:[1,.25]},{b:[-1],a:[1]}]){r=analyze(v);assert.equal(r.status,'flat');assert.equal(r.points.length,0);checks+=2;}
for(const gain of [0,.5,1+2**-40,1-2**-40]){r=analyze({b:[gain],a:[1]});assert.equal(r.status,'none');assert.equal(r.points.length,0);checks+=2;}
r=analyze({b:[.25],a:[1,-.75]});assert.equal(r.points.length,1);assert.equal(r.points[0].kind,'endpoint');assert.equal(r.points[0].frequency,0);
r=analyze({b:[.5,0,.5],a:[1]});assert.equal(r.points.length,2);assert(r.points.every(p=>p.kind==='endpoint'));near(r.points[1].frequency,fs/2);
r=analyze({b:[1,-1],a:[1,-1]});assert.equal(r.status,'flat');assert.deepEqual(r.undefinedFrequencies,[0]);assert.equal(r.points.length,0);
r=analyze({b:[1,-1],a:[1,0,-1]});assert(!r.points.some(p=>p.frequency===0||p.frequency===fs/2));assert.equal(r.undefinedFrequencies.length,2);
const quantModel=D.create({b:[.3333333,0,.8],a:[1,-.2]});const f=M.crossings(quantModel,D.evaluate),q=M.crossings(D.quantize(quantModel).model,D.evaluate);assert.equal(f.points.length,q.points.length);assert(f.points.some((p,i)=>Math.abs(p.frequency-q.points[i].frequency)>1e-5));
// Test the actual magnitude controller without claiming a browser or layout test.
let callback=null;
global.requestAnimationFrame=fn=>{callback=fn;return 1;};global.cancelAnimationFrame=()=>{callback=null;};
class El{constructor(){this.innerHTML='';this.textContent='';this.dataset={};this.value='db';this.events={};}addEventListener(k,f){(this.events[k]??=[]).push(f);}removeEventListener(k,f){this.events[k]=this.events[k].filter(x=>x!==f);}emit(k,e={}){let prevented=false;for(const fn of this.events[k]||[])fn({button:0,pointerId:1,clientX:320,clientY:160,target:this,preventDefault(){prevented=true;},...e});return prevented;}querySelector(){return {getBoundingClientRect:()=>({left:0,top:0,width:640,height:320})};}setPointerCapture(){}hasPointerCapture(){return false;}}
const nodes=Object.fromEntries(['main','inset','summary','scale','zoomIn','zoomOut','fit','range'].map(k=>[k,new El()]));
const controller=M.mount(nodes,D.evaluate),model=D.create({b:[1,0,1],a:[1]}),series=[{model,color:'#2569a7',label:'浮点',key:'F'},{model:D.quantize(model).model,color:'#c16d24',label:'量化定点',key:'Q',dash:true}];
controller.update(series);let view=controller.getView();assert(nodes.main.innerHTML.includes('data-unity-reference="0"'));assert(nodes.inset.innerHTML.includes('data-unity-reference="0"'));assert(nodes.summary.innerHTML.includes('F1'));assert(nodes.summary.innerHTML.includes('Q2'));assert(nodes.summary.innerHTML.includes('Hz'));assert.equal(nodes.main.dataset.frequencyMin,nodes.inset.dataset.frequencyMin);checks+=6;
assert.equal(nodes.main.emit('wheel',{deltaY:100,ctrlKey:false}),false);assert.deepEqual(controller.getView(),view);assert.equal(nodes.inset.emit('wheel',{deltaY:100}),false);assert.deepEqual(controller.getView(),view);
assert.equal(nodes.main.emit('wheel',{deltaY:-100,ctrlKey:true}),true);assert(controller.getView().xmax-controller.getView().xmin<view.xmax-view.xmin);assert.equal(nodes.main.dataset.frequencyMax,nodes.inset.dataset.frequencyMax);checks+=7;
view=controller.getView();nodes.main.emit('pointerdown');nodes.main.emit('pointermove',{clientX:350,clientY:180});assert(callback);callback();assert.notDeepEqual(controller.getView(),view);assert.equal(nodes.main.dataset.frequencyMin,nodes.inset.dataset.frequencyMin);nodes.main.emit('pointercancel');assert.deepEqual(controller.getView(),view);checks+=4;
nodes.scale.value='ratio';nodes.scale.emit('change');assert(nodes.main.innerHTML.includes('data-unity-reference="1"'));assert(nodes.inset.innerHTML.includes('data-unity-reference="1"'));assert(!nodes.inset.innerHTML.includes('data-unity-reference="0"'));assert(nodes.range.textContent.includes('±1 dB'));checks+=4;
nodes.summary.emit('click',{target:{closest:()=>({getAttribute:()=>String(fs/6)})}});assert(controller.getView().xmin<fs/6&&controller.getView().xmax>fs/6);assert.equal(nodes.main.dataset.frequencyMax,nodes.inset.dataset.frequencyMax);checks+=2;
nodes.fit.emit('click');assert.equal(controller.getView().xmin,0);assert.equal(controller.getView().xmax,fs/2);checks+=2;
controller.reset();controller.update([{...series[0],model:D.create({gain:1,poles:[]})}]);assert(nodes.summary.innerHTML.includes('整个频段为 0 dB'));assert.equal(controller.getView().ratio,false);
controller.update([{...series[0],model:D.create({gain:.5,poles:[]})}]);assert(nodes.summary.innerHTML.includes('没有 0 dB'));
controller.clear();assert.equal(nodes.main.innerHTML,'');assert.equal(nodes.inset.innerHTML,'');controller.destroy();assert(Object.values(nodes.main.events).every(list=>list.length===0));checks+=6;
console.log(`PASS unity-gain math/controller: ${checks} groups/checks; exact dyadic polynomial/Sturm isolation, multiple/narrow/tangent/flat/near-miss/endpoint/singular cases; real-response residuals, separate quantized roots, db/unity=1, linked inset, Ctrl-only zoom/pan/cancel and cleanup. No native browser/layout claim.`);
