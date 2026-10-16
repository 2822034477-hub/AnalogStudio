/* Actual viewport controllers with small event nodes; NOT native layout/screenshots. */
'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
let nextFrame=0;const frames=new Map(),observers=[],events={};
global.requestAnimationFrame=fn=>{frames.set(++nextFrame,fn);return nextFrame;};global.cancelAnimationFrame=id=>frames.delete(id);
global.addEventListener=(k,f)=>(events[k]??=[]).push(f);global.removeEventListener=(k,f)=>events[k]=events[k].filter(v=>v!==f);
global.ResizeObserver=class{constructor(fn){this.fn=fn;this.nodes=[];observers.push(this);}observe(node){this.nodes.push(node);}disconnect(){this.disconnected=true;}};
function flush(){const all=[...frames.values()];frames.clear();all.forEach(fn=>fn());}
class El{
 constructor(w=600,h=300){this.innerHTML='';this.textContent='';this.hidden=false;this.style={};this.attrs={};this.dataset={};this.events={};this.clientWidth=w;this.clientHeight=h;this.value='db';this.captured=null;}
 addEventListener(k,f){(this.events[k]??=[]).push(f);}removeEventListener(k,f){this.events[k]=this.events[k].filter(v=>v!==f);}
 setAttribute(k,v){this.attrs[k]=v;}focus(){}matches(){return false;}
 emit(k,extra={}){let prevented=false;for(const fn of this.events[k]||[])fn({button:0,pointerId:1,clientX:320,clientY:150,target:this,preventDefault(){prevented=true;},...extra});return prevented;}
 querySelector(){return this.innerHTML?{getBoundingClientRect:()=>({left:0,top:0,width:this.clientWidth,height:this.clientHeight})}:null;}
 setPointerCapture(id){this.captured=id;}hasPointerCapture(id){return this.captured===id;}releasePointerCapture(){this.captured=null;}
}
const P=require('../digital-response-plot'),D=require('../digital-design'),M=require('../digital-magnitude');
const first=new El(),second=new El(),firstFit=new El(),secondFit=new El();
const a=P.mount(first,firstFit),b=P.mount(second,secondFit),model=D.create({gain:.25,poles:[.75]}),original=D.serialize(model),rtl=D.generateVerilog(model);
const lines=[{color:'#2569a7',points:[{x:0,y:0},{x:1,y:1},{x:2,y:.5}]},{color:'#c16d24',dash:true,points:[{x:0,y:0},{x:1,y:.75},{x:2,y:.5}]}],lineCopy=JSON.stringify(lines),axes={xlabel:'样本 n / 拍',ylabel:'幅度'};
a.update(lines,axes);b.update(lines,axes);const va=a.getView(),vb=b.getView();
assert.equal((first.innerHTML.match(/clip-path=/g)||[]).length,2);assert(first.innerHTML.includes('stroke-dasharray="7 4"'));assert(first.innerHTML.includes('样本 n / 拍'));
assert.equal(first.emit('wheel',{deltaY:-100,ctrlKey:false}),false);assert.deepEqual(a.getView(),va);
assert.equal(first.emit('wheel',{deltaY:-100,ctrlKey:true}),true);assert(a.getView().xmax-a.getView().xmin<va.xmax-va.xmin);assert.deepEqual(b.getView(),vb);
const zoomed=a.getView();first.emit('pointerdown');first.emit('pointermove',{clientX:370});flush();assert.deepEqual(a.getView(),zoomed); // Space is required.
assert(first.emit('keydown',{code:'Space'}));first.emit('pointerdown');first.emit('pointermove',{clientX:370});flush();assert.notDeepEqual(a.getView(),zoomed);first.emit('pointercancel');assert.deepEqual(a.getView(),zoomed);assert.equal(first.captured,null);
first.emit('pointerdown');first.emit('pointermove',{clientY:180});flush();first.emit('pointerup');assert.notDeepEqual(a.getView(),zoomed);first.emit('keyup',{code:'Space'});
const panned=a.getView();first.emit('keydown',{code:'Space',target:{matches:()=>true}});first.emit('pointerdown');first.emit('pointermove',{clientX:400});flush();assert.deepEqual(a.getView(),panned); // Text editing must not arm pan.
first.emit('pointerenter');let prevented=false;events.keydown.forEach(fn=>fn({code:'Space',target:{matches:()=>false},preventDefault(){prevented=true;}}));assert(prevented);
first.emit('pointerdown');first.emit('pointermove',{clientY:170});flush();events.blur.forEach(fn=>fn());assert.deepEqual(a.getView(),panned);
first.clientWidth=920;first.clientHeight=460;first.style.height='460px';observers[0].fn();flush();assert(first.innerHTML.includes('viewBox="0 0 920 460"'));assert.deepEqual(a.getView(),panned);assert.deepEqual(b.getView(),vb);
firstFit.emit('click');assert.deepEqual(a.getView(),va);assert.equal(first.style.height,'');assert.deepEqual(b.getView(),vb);
const body=new El(),toggle=new El();let hiddenEvents=0;const panel=P.panel({body,toggle,onToggle(){hiddenEvents++;a.cancelDrag();}});toggle.emit('click');assert(body.hidden);assert.equal(toggle.attrs['aria-expanded'],'false');assert.equal(toggle.textContent,'显示');toggle.emit('click');assert(!body.hidden);assert.equal(toggle.attrs['aria-expanded'],'true');assert.equal(hiddenEvents,2);
const magNodes=Object.fromEntries(['main','inset','summary','scale','zoomIn','zoomOut','fit','range'].map(k=>[k,new El(k==='inset'?260:900,k==='inset'?240:400)])),mag=M.mount(magNodes,D.evaluate),magModel=D.create({b:[1,0,1],a:[1]}),magSeries=[{model:magModel,color:'#2569a7',label:'浮点',key:'F'},{model:D.quantize(magModel).model,color:'#c16d24',label:'量化定点',key:'Q',dash:true}];
mag.update(magSeries);assert(magNodes.main.innerHTML.includes('viewBox="0 0 900 400"'));assert(magNodes.inset.innerHTML.includes('viewBox="0 0 260 240"'));const roots=magNodes.summary.innerHTML,magView=mag.getView();magNodes.main.clientWidth=1200;magNodes.main.clientHeight=500;observers[2].fn();flush();assert(magNodes.main.innerHTML.includes('viewBox="0 0 1200 500"'));assert.equal(magNodes.summary.innerHTML,roots);assert.deepEqual(mag.getView(),magView);assert.equal(magNodes.main.dataset.frequencyMax,magNodes.inset.dataset.frequencyMax);
magNodes.main.emit('wheel',{ctrlKey:true,deltaY:-100,clientX:600,clientY:250});assert.equal(magNodes.main.dataset.frequencyMax,magNodes.inset.dataset.frequencyMax);assert(mag.getView().xmax-mag.getView().xmin<magView.xmax-magView.xmin);
assert.deepEqual(D.serialize(model),original);assert.equal(D.generateVerilog(model),rtl);assert.equal(JSON.stringify(lines),lineCopy);
a.clear();assert.equal(first.innerHTML,'');assert(second.innerHTML);a.destroy();b.destroy();panel.destroy();mag.destroy();assert(observers.every(o=>o.disconnected));assert(Object.values(events).every(v=>v.length===0));assert.equal(frames.size,0);
const css=fs.readFileSync(path.join(__dirname,'../digital-design.css'),'utf8'),design=fs.readFileSync(path.join(__dirname,'../digital-design.js'),'utf8'),editor=fs.readFileSync(path.join(__dirname,'../digital-root-editor.js'),'utf8');
assert(/\.dd-lower-layout\{[^}]*align-items:start/.test(css));assert(/\.dd-response-stack,\.dd-editor-stack\{[^}]*flex-direction:column/.test(css));assert(/\.digital-design \[hidden\]\{display:none!important\}/.test(css));assert(!/visibility:hidden/.test(css));assert(!/height:(60|64|66|78)px/.test(css));assert(css.includes('resize:vertical'));assert(css.includes('@media(max-width:760px)'));assert(css.includes('minmax(220px,300px)'));assert(design.indexOf('dd-response-stack')<design.indexOf('dd-editor-stack'));assert(design.includes('<details class="dd-controls">'));assert(design.includes('<details class="dd-data-details">'));assert(editor.indexOf('data-z="plot"')<editor.indexOf('data-z="error"'));assert(editor.indexOf('data-z="plot"')<editor.indexOf('data-z="mode-hint"'));assert(editor.includes('<details class="dd-root-coordinate">'));
console.log('PASS layout/viewport UI: independent columns and collapsed controls contract; two traces, Ctrl-only zoom, Space pan/text-input isolation, cancel/blur/capture, independent resize/hide/reset, resize-aware magnitude coordinates/shared inset, cleanup and no model/RTL mutation. Event stubs and source contracts only; no native viewport/screenshot claim.');
