'use strict';
const assert=require('node:assert/strict'),{boot,pause,js}=require('./projects.cjs');
(async()=>{
 const b=boot();try{
 await pause();b.P.newProject();b.$('#projectWizardDomain').value='digital';b.$('#projectWizardDomain').dispatchEvent(new b.w.Event('change',{bubbles:true}));b.click('#projectWizardCreate');
 const w=b.w,M=w.DigitalModules,L=w.DigitalSystemLayout,c=M.defaults('subtract');c.timing='registered';
 w.SVGElement.prototype.getBoundingClientRect=w.HTMLElement.prototype.getBoundingClientRect;
 const state=M.empty();state.view='system';state.modules=[{key:'m',design:M.create(c)}];state.instances=[{id:'u1',moduleKey:'m'},{id:'u2',moduleKey:'m'}];state.ports=[{name:'x',direction:'input',width:16,signed:true,fraction:8},{name:'y',direction:'output',width:16,signed:true,fraction:8}];state.connections=[{from:'in:x',to:'u1:a'},{from:'in:x',to:'u1:b'},{from:'u1:data_out',to:'u2:a'},{from:'in:x',to:'u2:b'},{from:'u2:data_out',to:'out:y'}];
 const initial={...w.DigitalDesign.defaults(),system:state};w.AnalogDigitalProject.replace(initial);
 const snapshot=()=>w.AnalogDigitalProject.snapshot(),scene=()=>L.build(snapshot().system),canvas=()=>b.$('[data-ds="diagram"]');
 const event=(target,type,point,id=1)=>{const e=new w.MouseEvent(type,{bubbles:true,cancelable:true,button:0,clientX:point.x,clientY:point.y});Object.defineProperty(e,'pointerId',{value:id});target.dispatchEvent(e);};
 function screen(x,y){const svg=canvas().querySelector('svg'),rect=svg.getBoundingClientRect(),v=svg.getAttribute('viewBox').split(' ').map(Number),k=Math.min(rect.width/v[2],rect.height/v[3]);return {x:rect.left+(rect.width-v[2]*k)/2+x*k,y:rect.top+(rect.height-v[3]*k)/2+y*k};}
 const node=id=>[...canvas().querySelectorAll('[data-ds-node]')].find(n=>n.dataset.dsNode===id),rect=id=>scene().boxes.find(n=>n.id===id);
 let changes=0;w.addEventListener('analog:design-change',()=>changes++);
 const originalHDL=M.generateSystem(snapshot().system),a=rect('u1'),start=screen(a.x+20,a.y+20),end=screen(a.x+140,a.y+20);
 const driven=b.$('[data-ds="from"]');driven.value='in:x';driven.dispatchEvent(new w.Event('change',{bubbles:true}));
 const stableCanvas=canvas();event(node('u1').querySelector('rect'),'pointerdown',start);event(canvas(),'pointermove',end);await pause();
 assert.equal(snapshot().system.layout,undefined);assert.equal(changes,0);assert.equal(canvas(),stableCanvas);assert.equal(b.$('[data-ds="from"]').value,'in:x');
 event(canvas(),'pointerup',end);assert.equal(changes,1);assert.equal(snapshot().system.layout.u1.x,a.x+120);assert.equal(M.generateSystem(snapshot().system),originalHDL);
 const moved=rect('u1'),resizeStart=screen(moved.x+moved.w-6,moved.y+moved.h-6),resizeEnd=screen(moved.x+moved.w+34,moved.y+moved.h+2);
 event(node('u1').querySelector('[data-ds-resize] rect'),'pointerdown',resizeStart,2);event(canvas(),'pointermove',resizeEnd,2);await pause();event(canvas(),'pointerup',resizeEnd,2);
 assert.equal(changes,2);assert.equal(snapshot().system.layout.u1.w,moved.w+40);assert.equal(snapshot().system.layout.u1.h,moved.h+8);
 const committed=js(snapshot()),other=rect('u2'),os=screen(other.x+20,other.y+20),oe=screen(other.x+80,other.y+20);
 event(node('u2').querySelector('rect'),'pointerdown',os,3);event(canvas(),'pointermove',oe,3);await pause();w.dispatchEvent(new w.KeyboardEvent('keydown',{key:'Escape',cancelable:true}));
 assert.deepEqual(js(snapshot()),committed);assert.equal(changes,2);
 event(node('u2').querySelector('rect'),'pointerdown',os,4);event(canvas(),'pointermove',oe,4);event(canvas(),'pointercancel',oe,4);assert.deepEqual(js(snapshot()),committed);
 event(node('u2').querySelector('rect'),'pointerdown',os,5);event(canvas(),'pointermove',oe,5);w.dispatchEvent(new w.Event('blur'));assert.deepEqual(js(snapshot()),committed);
 // Snapshot save/restore keeps positions and sizes without altering HDL or names.
 const project=js(b.P.snapshot());w.AnalogDigitalProject.replace(w.DigitalDesign.defaults());w.AnalogDigitalProject.replace(project.design);assert.deepEqual(js(snapshot().system.layout),committed.system.layout);assert.equal(M.generateSystem(snapshot().system),originalHDL);
 // A project change cancels the drag; late pointer events cannot move the new project.
 const old=canvas(),r=rect('u2'),rs=screen(r.x+15,r.y+15),re=screen(r.x+70,r.y+15);event(node('u2').querySelector('rect'),'pointerdown',rs,6);event(old,'pointermove',re,6);w.AnalogDigitalProject.replace(initial);event(old,'pointerup',re,6);assert.equal(snapshot().system.layout,undefined);
 // Resize/move keyboard access and explicit auto-layout reset.
 const before=rect('u1');node('u1').dispatchEvent(new w.KeyboardEvent('keydown',{key:'ArrowRight',bubbles:true,cancelable:true}));assert.equal(snapshot().system.layout.u1.x,before.x+10);
 b.click('[data-ds="reset-layout"]');assert.equal(snapshot().system.layout,undefined);assert.equal(rect('u1').x,before.x);
 // Native SVG transform path: CSS transforms/zoom take precedence over the fallback rectangle.
 w.SVGSVGElement.prototype.getScreenCTM=function(){return {inverse:()=>({})};};
 w.SVGSVGElement.prototype.createSVGPoint=function(){return {x:0,y:0,matrixTransform(){return {x:(this.x-40)/2,y:(this.y-30)/2};}};};
 const ct=rect('u1'),cs={x:2*(ct.x+20)+40,y:2*(ct.y+20)+30},ce={x:cs.x+80,y:cs.y};
 let captured=null;canvas().setPointerCapture=id=>{captured=id;};canvas().hasPointerCapture=id=>captured===id;canvas().releasePointerCapture=()=>{captured=null;};
 event(node('u1').querySelector('rect'),'pointerdown',cs,7);assert.equal(captured,7);event(canvas(),'pointermove',ce,7);event(canvas(),'pointerup',ce,7);assert.equal(captured,null);assert.equal(snapshot().system.layout.u1.x,ct.x+40);assert.equal(M.generateSystem(snapshot().system),originalHDL);
 // Deleted blocks and ports leave no stale layout keys in engineering-project saves.
 b.click('[data-remove-instance="u1"]');assert.equal(snapshot().system.layout.u1,undefined);assert.doesNotThrow(()=>M.validateState(snapshot().system));
 b.click('[data-remove-port="0"]');assert.equal(snapshot().system.layout['in:x'],undefined);assert.doesNotThrow(()=>b.P.snapshot());
 // Moving and resizing each produce one reversible command, including full layout.
 const beforeKey=js(snapshot());node('u2').dispatchEvent(new w.KeyboardEvent('keydown',{key:'ArrowRight',bubbles:true,cancelable:true}));const afterKey=js(snapshot());assert.notDeepEqual(afterKey,beforeKey);b.click('[data-ds="undo"]');assert.deepEqual(js(snapshot()),beforeKey);b.click('[data-ds="redo"]');assert.deepEqual(js(snapshot()),afterKey);
 const rr=rect('u2'),rstart={x:2*(rr.x+rr.w-6)+40,y:2*(rr.y+rr.h-6)+30},rend={x:2*(rr.x+rr.w+14)+40,y:rstart.y};event(node('u2').querySelector('[data-ds-resize] rect'),'pointerdown',rstart,8);event(canvas(),'pointermove',rend,8);event(canvas(),'pointerup',rend,8);const afterResize=js(snapshot());assert.equal(rect('u2').w,rr.w+20);b.click('[data-ds="undo"]');assert.deepEqual(js(snapshot()),afterKey);b.click('[data-ds="redo"]');assert.deepEqual(js(snapshot()),afterResize);
 assert.deepEqual(b.errors,[]);console.log('PASS system canvas DOM: scaled fallback and SVG CTM coordinates, capture release, stable host, drag/resize previews, one commit, untouched connection controls, cancel/blur/project rollback, saved layout, keyboard/reset, deletion cleanup and unchanged HDL. jsdom only; no native pointer/layout claim.');
 }finally{b.dom.window.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
