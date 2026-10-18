/* Runs the actual bench/editor controllers with a minimal DOM stub; no browser/layout claim. */
'use strict';
const assert=require('node:assert/strict');
let writes=0,lastFocus=null,rafId=0;const frames=new Map(),globalListeners={};
global.requestAnimationFrame=fn=>{frames.set(++rafId,fn);return rafId;};global.cancelAnimationFrame=id=>frames.delete(id);
global.addEventListener=(k,fn)=>(globalListeners[k]??=[]).push(fn);global.removeEventListener=(k,fn)=>globalListeners[k]=globalListeners[k].filter(x=>x!==fn);
function flushFrames(){const pending=[...frames.values()];frames.clear();pending.forEach(fn=>fn());}
let bounds={left:0,top:0,width:600,height:360},screenMatrix=null,captures=0;
class Element{
 set value(v){this._value=String(v);} get value(){return this._value;}
 constructor(tag='div',attrs='',html=''){this.tagName=tag.toUpperCase();this.attrs=attrs;this.value=(attrs.match(/value="([^"]*)"/)||[])[1]||'';this.hidden=/\bhidden\b/.test(attrs);this.disabled=/\bdisabled\b/.test(attrs);this.listeners={};this.children={};this.textContent='';this.classList={add(){},toggle(){}};this.dataset={};this.ownerDocument={createElement:()=>new Element()};this._html=html;}
 set innerHTML(html){writes++;this.nodes=null;this._html=html;this.children={};for(const match of html.matchAll(/<(input|textarea|select|div|button|p|pre|section)\b([^>]*data-(dd|z)="([^"]+)"[^>]*)>/g)){const [full,tag,attrs,prefix,key]=match;const tail=html.slice(match.index+full.length);const el=new Element(tag,attrs);el.parent=this;if(tag==='textarea')el.value=tail.split('</textarea>')[0];if(tag==='select')el.value=(tail.split('</select>')[0].match(/<option value="([^"]*)"/)||[])[1]||'';this.children[prefix+':'+key]=el;}}
 get innerHTML(){return this._html;}
 querySelector(s){if(s==='.dd-gain-tools'){const group=new Element();for(const key of ['gain','gain-minus','gain-plus']){group.children['z:'+key]=this.children['z:'+key];delete this.children['z:'+key];}return group;}if(s==='svg')return this._html.includes('<svg')?{getBoundingClientRect:()=>bounds,getScreenCTM:()=>screenMatrix,createSVGPoint:()=>({matrixTransform(m){return m(this);}})}:null;const m=s.match(/\[data-(dd|z)="?([^"\]]+)"?\]/);return m?this.children[m[1]+':'+m[2]]||null:null;}
 querySelectorAll(s){
  const wanted=s.match(/data-root-id="([^"]+)"/);if(!wanted)return [];
  if(!this.nodes)this.nodes=[...this._html.matchAll(/<(g|tr) ([^>]*data-root-id="([^"]+)"[^>]*)>/g)].map(m=>{
   const e=new Element(m[1],m[2]);e.dataset={rootId:m[3],sign:(m[2].match(/data-sign="([^"]+)"/)||[])[1]||'1'};e.fields={re:{value:0},im:{value:0}};e.querySelector=key=>e.fields[key.includes('"re"')?'re':'im'];return e;
  });return this.nodes.filter(x=>x.dataset.rootId===wanted[1]);
 }
 setAttribute(k,v){this[k]=v;}
 addEventListener(t,f){(this.listeners[t]??=[]).push(f);}
 removeEventListener(t,f){this.listeners[t]=(this.listeners[t]||[]).filter(x=>x!==f);}
 emit(t,event={}){const e={target:this,button:0,preventDefault(){},...event};for(const f of this.listeners[t]||[])f(e);if(event.bubbles)this.parent?.emit(t,{...e,bubbles:true});}
 click(){if(!this.disabled)this.emit('click');}
 matches(s){return /input|textarea|select/.test(s)&&['INPUT','TEXTAREA','SELECT'].includes(this.tagName);}
 hasAttribute(k){return this.attrs.includes(k+'=');}
 focus(options){lastFocus=options;} replaceChildren(node){this.innerHTML='';if(node)this.children={...node.children};} setPointerCapture(){captures++;} hasPointerCapture(){return false;}
}
require('../digital-root-editor');const D=require('../digital-design');
const root=new Element(),changes=[],downloads=[];const app=D.mount(root,{onChange:x=>changes.push(x),onDownload:x=>downloads.push(x)});
const $=k=>root.querySelector(`[data-dd="${k}"]`),host=$('roots'),z=k=>(['gain','gain-minus','gain-plus'].includes(k)?$('gain-controls'):host).querySelector(`[data-z="${k}"]`);
function input(k,v){$(k).value=String(v);$(k).emit('input',{bubbles:true});}
function mode(v){$('mode').value=v;$('mode').emit('change');}
function setting(k,v){z(k).value=v;z(k).emit('change');}
function point(re,im){const view=app.snapshot().editor,scale=296/(view.span*2);return {clientX:315+(re-view.centerRe)*scale,clientY:172-(im-view.centerIm)*scale};}
function hit(kind,index,sign=1){return {closest:()=>({dataset:{rootKind:kind,rootIndex:String(index),sign:String(sign)}})};}
const close=(a,b)=>assert(Math.abs(a-b)<1e-7,`${a} != ${b}`);
assert($('status').textContent.includes('稳定'));input('b','0.4, 0.1');assert.equal(app.getModel().b[0],.4);mode('zpk');close(Number($('gain').value),.4);assert.equal(app.getModel().b.length,2);input('poles','.6 .2');close(app.getModel().a[2],.4);mode('coefficients');close(Number($('a').value.split(',')[2]),.4);for(let i=0;i<8;i++){mode('zpk');mode('coefficients');}close(app.getModel().a[2],.4);
// Invalid draft blocks controls/code and cannot be silently discarded by switching input form.
input('b','bad');const before=app.getModel();mode('zpk');assert.equal($('mode').value,'coefficients');assert($('verilog').disabled);assert(z('add').disabled);assert.deepEqual(app.getModel(),before);input('b','.4');assert(!z('add').disabled);
setting('kind','zeros');setting('placement','real');z('re').value='-.5';z('add').click();close(app.getModel().b[1],.2);assert(!z('delete').disabled);z('delete').click();assert.equal(app.getModel().b.length,1);
// Click adds an actual conjugate pair and updates coefficient form and generator input.
setting('placement','pair');setting('tool','add');z('plot').emit('pointerdown',{...point(.3,.4),pointerId:1,target:{closest:()=>null}});assert.equal(app.getModel().b.length,1);z('plot').emit('pointerup',{...point(.3,.4),pointerId:1});z('plot').emit('click',{...point(.3,.4),target:{closest:()=>null}});close(app.getModel().b[1],-.24);close(app.getModel().b[2],.1);assert.equal($('mode').value,'coefficients');assert(D.generateVerilog(app.getModel()).includes('module digital_filter'));
// Drag lower conjugate across the axis, retaining two real repeated roots at the crossing.
setting('tool','select');z('plot').emit('pointerdown',{...point(.3,-.4),pointerId:2,target:hit('zeros',0,-1)});z('plot').emit('pointermove',{...point(.5,0),pointerId:2});close(app.getModel().b[2],.1);z('plot').emit('pointermove',{...point(.5,.2),pointerId:2});close(app.getModel().b[2],.1);z('plot').emit('pointerup',{pointerId:2});close(D.factorRoots(app.getModel()).zeros[0].im,.2);
z('re').value='0.7';z('im').value='0.25';z('move').click();close(D.factorRoots(app.getModel()).zeros[0].re,.7);close(D.factorRoots(app.getModel()).zeros[0].im,.25);
const saved=app.snapshot();app.replace(saved);assert.deepEqual(app.snapshot(),saved);assert(!z('add').disabled);assert(z('plot').innerHTML.includes('<svg'));assert(z('list').innerHTML.includes('删除整对（2点）'));assert(!$('verilog').disabled);$('apply').click();
// Bounds failure is atomic and explicit. Selected roots can be deleted even with empty coordinate fields.
z('plot').emit('pointerdown',{...point(.7,.25),pointerId:3,target:hit('zeros',0)});z('plot').emit('pointerup',{pointerId:3});const beforeBad=app.getModel();z('re').value='101';z('move').click();assert(!z('error').hidden);assert.deepEqual(app.getModel(),beforeBad);z('re').value='';z('im').value='';z('delete').click();assert.equal(app.getModel().b.length,1);
setting('kind','poles');setting('placement','real');const v0=app.snapshot().editor;z('in').click();assert(app.snapshot().editor.span<v0.span);setting('tool','pan');z('plot').emit('pointerdown',{...point(0,0),pointerId:4,target:{closest:()=>null}});z('plot').emit('pointermove',{clientX:360,clientY:200,pointerId:4});z('plot').emit('pointerup',{pointerId:4});assert.notEqual(app.snapshot().editor.centerRe,0);z('fit').click();assert.equal(app.snapshot().editor.centerRe,0);
// Real-axis drag locks Im to zero, mouse-wheel zoom persists, Delete handles the selected real root.
app.replace(D.defaults());$('apply').click();setting('tool','select');z('plot').emit('pointerdown',{...point(.8,0),pointerId:5,target:hit('poles',0)});z('plot').emit('pointermove',{...point(.7,.4),pointerId:5});z('plot').emit('pointercancel',{pointerId:5});close(D.factorRoots(app.getModel()).poles[0].re,.8);assert.equal(D.factorRoots(app.getModel()).poles[0].im,0);const wheelBefore=app.snapshot().editor.span;z('plot').emit('wheel',{...point(.2,.2),deltaY:-1,ctrlKey:true});assert(app.snapshot().editor.span<wheelBefore);z('plot').emit('keydown',{key:'Delete'});assert.equal(app.getModel().a.length,1);
setting('placement','pair');z('re').value='.6';z('im').value='.2';z('add').click();for(let i=0;i<3;i++)z('add').click();const bounded=app.getModel();z('add').click();assert(!z('error').hidden);assert.deepEqual(app.getModel(),bounded);
assert(changes.length>10);$('verilog').click();assert(downloads.length);
// Restoring an unfinished draft must not leave a live editor for the stale model.
const unfinished=app.snapshot();unfinished.ui.b='unfinished';unfinished.ui.mode='coefficients';
app.replace(unfinished);const restored=app.snapshot();assert(z('add').disabled);assert($('verilog').disabled);
assert.equal($('equation').textContent,'');assert.equal(z('plot').innerHTML,'');
z('add').click();assert.deepEqual(app.snapshot(),restored);assert.equal($('b').value,'unfinished');
$('apply').click();assert(z('add').disabled);input('b','.3');assert(!z('add').disabled);
assert.equal(app.getModel().b[0],.3);assert.equal($('b').value,'.3');

// Default tool actually adds; full pointer sequences commit only once, and cancel/drag do not add.
app.replace(D.defaults());assert.equal(z('tool').value,'add');
const emptyTarget={closest:()=>null},poleBefore=D.factorRoots(app.getModel()).poles.length;
z('plot').emit('pointerdown',{...point(.4,0),pointerId:10,target:emptyTarget});
z('plot').emit('pointercancel',{pointerId:10});assert.equal(D.factorRoots(app.getModel()).poles.length,poleBefore);
z('plot').emit('pointerdown',{...point(.4,0),pointerId:11,target:emptyTarget});
z('plot').emit('pointermove',{...point(.5,0),pointerId:11});z('plot').emit('pointerup',{...point(.5,0),pointerId:11});
assert.equal(D.factorRoots(app.getModel()).poles.length,poleBefore);
z('plot').emit('pointerdown',{...point(.4,.3),pointerId:12,target:emptyTarget});
z('plot').emit('pointerup',{...point(.4,.3),pointerId:12});z('plot').emit('click',{...point(.4,.3),target:emptyTarget});
assert.equal(D.factorRoots(app.getModel()).poles.length,2);assert.equal(app.getModel().a.length,3);assert(z('error').hidden);
assert(z('capacity').textContent.includes('极点 2 / 8'));z('re').value='.2';for(let i=0;i<6;i++)z('add').click();const full=app.getModel();assert.equal(D.analysis(full).order,8);
z('plot').emit('pointerdown',{...point(.3,0),pointerId:13,target:emptyTarget});z('plot').emit('pointerup',{...point(.3,0),pointerId:13});
assert(z('error').textContent.includes('上限'));assert.deepEqual(app.getModel(),full);
// Click-only dispatch also works; letterboxed coordinate fallback respects CSS size and offset.
app.replace(D.serialize(D.create({gain:.2,poles:[]})));bounds={left:120,top:70,width:900,height:360};
const q=point(.6,.5);z('plot').emit('click',{clientX:q.clientX+270,clientY:q.clientY+70,target:emptyTarget});
close(D.factorRoots(app.getModel()).poles[0].re,.6);assert.equal(D.factorRoots(app.getModel()).poles[0].im,0);
const boxState=app.getModel();z('plot').emit('click',{clientX:125,clientY:75,target:emptyTarget});assert.deepEqual(app.getModel(),boxState);
bounds={left:0,top:0,width:600,height:360};
// getScreenCTM takes precedence and supports transformed SVGs.
setting('kind','zeros');screenMatrix={inverse:()=>p=>({x:(p.x-40)/2,y:(p.y-20)/2})};
const transformed=point(-.4,.2);z('plot').emit('click',{clientX:transformed.clientX*2+40,clientY:transformed.clientY*2+20,target:emptyTarget});
close(D.factorRoots(app.getModel()).zeros[0].re,-.4);screenMatrix=null;
assert(z('plot').innerHTML.includes('pointer-events="none"'));assert(captures>0);
// Delegated list actions: row fields are independent from the toolbar and identify roots by ID.
function rowAction(id,action,re,im,key){
 const row={dataset:{rootId:id},querySelector:s=>({value:s.includes('"re"')?String(re):String(im)})};
 const target={dataset:{action},closest:s=>s==='[data-action]'?target:row,matches:()=>true};
 z('list').emit(key?'keydown':'click',{target,key});
}
app.replace(D.serialize(D.create({gain:1,poles:[.5,.5]})));
let groups=app.snapshot().editor.rootGroups.poles;assert.equal(groups.length,2);assert.notEqual(groups[0].id,groups[1].id);
const firstId=groups[0].id,secondId=groups[1].id;
rowAction(secondId,'update',.7,0);groups=app.snapshot().editor.rootGroups.poles;
assert.equal(groups[1].id,secondId);close(groups[1].re,.7);close(groups[0].re,.5);assert.deepEqual(changes.at(-1),app.snapshot());
rowAction(secondId,'update',.2,0,'Enter');groups=app.snapshot().editor.rootGroups.poles;
assert.equal(groups[1].id,secondId);close(groups[1].re,.2);close(groups[0].re,.5);
const idsSaved=app.snapshot();app.replace(idsSaved);assert.deepEqual(app.snapshot(),idsSaved);assert(!z('add').disabled);
rowAction(firstId,'delete');groups=app.snapshot().editor.rootGroups.poles;assert.equal(groups.length,1);assert.equal(groups[0].id,secondId);close(groups[0].re,.2);
assert($('a').value.includes('-0.2'));assert($('equation').textContent.includes('0.2 y[n-1]'));assert(D.generateVerilog(app.getModel()).includes('.A1('));
app.replace(D.serialize(D.create({gain:.2,poles:[{re:.6,im:.2}]})));groups=app.snapshot().editor.rootGroups.poles;
const pairId=groups[0].id;assert.equal((z('list').innerHTML.match(/<tr data-root-id=/g)||[]).length,2);
rowAction(pairId,'update',.4,-.3);groups=app.snapshot().editor.rootGroups.poles;close(groups[0].im,.3);close(app.getModel().a[2],.25);
assert(z('list').innerHTML.includes('value="-0.3"'));assert(z('list').innerHTML.includes('value="0.3"'));
rowAction(pairId,'update',.4,0);groups=app.snapshot().editor.rootGroups.poles;assert(groups[0].pair);assert.equal(groups[0].id,pairId);
const collapsed=app.snapshot();app.replace(collapsed);assert.deepEqual(app.snapshot(),collapsed);
rowAction(pairId,'update',.4,.1);close(D.factorRoots(app.getModel()).poles[0].im,.1);
const goodList=app.snapshot();rowAction(pairId,'update','',.3);assert(!z('error').hidden);assert.deepEqual(app.snapshot(),goodList);
rowAction(pairId,'delete');assert.equal(app.getModel().a.length,1);assert.equal(app.snapshot().editor.rootGroups.poles.length,0);
// Stale/forged identity metadata never overrides authoritative coefficients.
const stale=idsSaved;stale.editor.rootGroups.poles[0].re=.99;app.replace(stale);assert(D.factorRoots(app.getModel()).poles.some(r=>Math.abs(r.re-.5)<1e-8));
const malformed=app.snapshot();malformed.editor.rootGroups.poles[1].id=malformed.editor.rootGroups.poles[0].id;
assert.throws(()=>app.replace(malformed));
// Valid-but-unapplied legacy drafts remain blocked until Apply, unlike saved valid projects.
const pending=app.snapshot();pending.ui.a='1,-.9';app.replace(pending);assert(z('add').disabled);assert.equal($('a').value,'1,-.9');$('apply').click();assert(!z('add').disabled);close(app.getModel().a[1],-.9);

// High-order coefficient/ZPK/list/response/export round trip, including repeated factors.
app.replace(D.defaults());mode('zpk');input('poles','.2 .11\n.3 .16\n.4 .21\n.5 .26');input('zeros','-.2\n-.3');input('gain','.01');
assert.equal(app.getModel().a.length,9);assert.equal(app.snapshot().editor.rootGroups.poles.length,4);assert($('sos-text').textContent.includes('SOS 4 节'));assert(! $('verilog').disabled);
const highGroups=app.snapshot().editor.rootGroups.poles;rowAction(highGroups[2].id,'update',.43,.19);assert.equal(app.getModel().a.length,9);assert($('poles').value.includes('0.43 0.19'));assert($('equation').textContent.includes('y[n-8]'));
mode('coefficients');const highSaved=app.snapshot();app.replace(highSaved);assert(!z('add').disabled);assert.deepEqual(app.snapshot(),highSaved);mode('zpk');assert.equal(app.getModel().a.length,9);
rowAction(highGroups[0].id,'delete');assert.equal(app.getModel().a.length,7);assert($('sos-text').textContent.includes('SOS 3 节'));
input('inputBits','18');assert.equal($('outputBits').value,'18');assert.equal(app.getModel().fixed.inputBits,18);assert.equal(app.getModel().fixed.outputBits,18);
// Normal wheel bubbles without preventDefault; Ctrl zoom consumes it.
app.replace(D.defaults());let prevented=0;const initialSpan=app.snapshot().editor.span;
z('plot').emit('wheel',{...point(.2,.2),deltaY:-1,preventDefault(){prevented++;}});
assert.equal(prevented,0);assert.equal(app.snapshot().editor.span,initialSpan);
z('plot').emit('wheel',{...point(.2,.2),deltaY:-1,ctrlKey:true,preventDefault(){prevented++;}});
assert.equal(prevented,1);assert(app.snapshot().editor.span<initialSpan);
// Pointer moves use one RAF and existing nodes: no model publish, response calculation or DOM replacement.
const original=D.serialize(app.getModel()),originalGroups=app.snapshot().editor.rootGroups,eventsBefore=changes.length;
let analyses=0,quantizations=0;const originalAnalysis=D.analysis,originalQuantize=D.quantize;
D.analysis=(...a)=>{analyses++;return originalAnalysis(...a);};D.quantize=(...a)=>{quantizations++;return originalQuantize(...a);};
z('plot').emit('pointerdown',{...point(.8,0),pointerId:60,target:hit('poles',0)});
assert.deepEqual(lastFocus,{preventScroll:true});const writesBefore=writes;
z('plot').emit('pointermove',{...point(.6,.3),pointerId:60});z('plot').emit('pointermove',{...point(.55,.4),pointerId:60});
assert.equal(frames.size,1);flushFrames();assert.equal(writes,writesBefore);assert.equal(analyses,0);assert.equal(quantizations,0);assert.equal(changes.length,eventsBefore);
assert.deepEqual(D.serialize(app.getModel()),original);assert.deepEqual(app.snapshot().editor.rootGroups,originalGroups);
const row=z('list').querySelectorAll('[data-root-id="'+originalGroups.poles[0].id+'"]')[0];close(Number(row.fields.re.value),.55);assert.equal(Number(row.fields.im.value),0);
const mark=z('plot').querySelectorAll('[data-root-id="'+originalGroups.poles[0].id+'"]')[0];assert.notEqual(mark.transform,'translate(0 0)');
z('plot').emit('pointerup',{pointerId:60});close(D.factorRoots(app.getModel()).poles[0].re,.55);assert.equal(changes.length,eventsBefore+1);assert.equal(analyses,2);assert.equal(quantizations,1);
D.analysis=originalAnalysis;D.quantize=originalQuantize;
// All cancellation paths restore the committed coordinates and discard scheduled work.
for(const cancel of ['pointercancel','lostpointercapture','Escape','blur','replace']){
 const start=app.snapshot();z('plot').emit('pointerdown',{...point(.55,0),pointerId:61,target:hit('poles',0)});z('plot').emit('pointermove',{...point(.3,0),pointerId:61});flushFrames();
 if(cancel==='Escape')z('plot').emit('keydown',{key:'Escape'});else if(cancel==='blur')globalListeners.blur.forEach(fn=>fn());else if(cancel==='replace')app.replace(start);else z('plot').emit(cancel,{pointerId:61});
 flushFrames();assert.deepEqual(app.getModel(),D.load(start));close(app.snapshot().editor.rootGroups.poles[0].re,.55);assert.equal(frames.size,0);
}
// Both conjugate marks/list rows update together without replacing their DOM nodes.
app.replace(D.serialize(D.create({gain:.2,poles:[{re:.4,im:.3}]})));const pairGroup=app.snapshot().editor.rootGroups.poles[0];
z('plot').emit('pointerdown',{...point(.4,-.3),pointerId:62,target:hit('poles',0,-1)});z('plot').emit('pointermove',{...point(.6,-.2),pointerId:62});flushFrames();
const pairRows=z('list').querySelectorAll('[data-root-id="'+pairGroup.id+'"]');assert.equal(pairRows.length,2);close(Number(pairRows[0].fields.im.value),.2);close(Number(pairRows[1].fields.im.value),-.2);
z('plot').emit('pointercancel',{pointerId:62});close(Number(pairRows[0].fields.im.value),.3);close(Number(pairRows[1].fields.im.value),-.3);
// Shared K: nonzero -> zero -> serialized project -> negative keeps roots, IDs, view and explicit delay.
app.replace(D.serialize(D.create({gain:.2,zeros:[{re:.3,im:.2}],poles:[.5,.5],delaySamples:2})));
z('in').click();const shape=app.snapshot().editor,originalA=app.getModel().a;
z('gain').value='0';z('gain').emit('change');assert(app.getModel().b.every(v=>v===0));assert.equal($('gain').value,'0');
assert.deepEqual(app.snapshot().editor,shape);assert.equal(D.factorRoots(app.getModel()).delaySamples,2);
const zeroSaved=app.snapshot();app.replace(zeroSaved);assert.deepEqual(app.snapshot(),zeroSaved);assert(!z('gain').disabled);
mode('zpk');mode('coefficients');z('gain').value='-.5';z('gain').emit('change');
assert.deepEqual(app.snapshot().editor,shape);assert.deepEqual(app.getModel().a,originalA);assert.equal(D.factorRoots(app.getModel()).gain,-.5);assert.equal(D.factorRoots(app.getModel()).delaySamples,2);
close(app.getModel().b[2],-.5);close(app.getModel().b[3],.3);assert.equal($('gain').value,'-0.5');
z('gain-plus').click();close(D.factorRoots(app.getModel()).gain,-.4);z('gain-minus').click();close(D.factorRoots(app.getModel()).gain,-.5);
const gainGood=app.snapshot();z('gain').value='bad';z('gain').emit('change');assert(!z('error').hidden);assert.deepEqual(app.snapshot(),gainGood);
assert($('width-advice').innerHTML.includes('未自动修改'));const fixedBefore=app.getModel().fixed;input('marginDb','12');assert.deepEqual(app.getModel().fixed,fixedBefore);assert($('width-advice').innerHTML.includes('12 dB'));
input('marginDb','-1');assert($('width-advice').textContent.includes('0–60'));input('marginDb','6');
// Actual controller SVG output: two colored traces, synchronized clock alignment.
// This is still the minimal DOM stub, not browser rendering or layout evidence.
const responsePaths=id=>[...$(id).innerHTML.matchAll(/<path d="([^"]*)" stroke="(#2569a7|#c16d24)"[^>]*>/g)].map(m=>({d:m[1],color:m[2],tag:m[0]}));
app.replace(D.serialize(D.create({b:[0,0,.5],a:[1,-.5,.125]})));
assert.equal($('responseMode').value,'model');$('responseMode').value='implementation';$('responseMode').emit('change');
for(const id of ['magnitude','phase','step']){const paths=responsePaths(id);assert.equal(paths.length,2,id);assert.equal(paths[0].color,'#2569a7');assert.equal(paths[1].color,'#c16d24');assert(paths[1].tag.includes('stroke-dasharray="7 4"'));assert(!$(id).innerHTML.includes('#26815e'));}
assert($('response-legend').innerHTML.includes('浮点＋实现延迟'));assert($('response-legend').innerHTML.includes('定点＋实现延迟'));assert($('response-note').textContent.includes('附加 1 拍'));assert(!root.innerHTML.includes('绿色曲线'));
assert.equal(responsePaths('phase')[0].d,responsePaths('phase')[1].d); // exactly representable coefficients
for(const path of responsePaths('step')){const xy=[...path.d.matchAll(/[ML]([-\d.]+) ([-\d.]+)/g)];assert.equal(xy.length,128);for(let n=1;n<3;n++)assert.equal(xy[n][2],xy[0][2]);assert.notEqual(xy[3][2],xy[0][2]);} // explicit 2 + SO extra 1, not 2 + total edgeOffset
app.replace(D.serialize(D.create({gain:0,poles:[{re:.4,im:.2}],delaySamples:2})));
assert(responsePaths('phase').every(p=>p.d===''));assert.equal(responsePaths('step').length,2);assert.equal(responsePaths('step')[0].d,responsePaths('step')[1].d);
// Magnitude integration: linked inset, no model mutation, atomic failed import.
app.replace(D.serialize(D.create({b:[1,0,1],a:[1]})));
assert($('magnitude-crossings').innerHTML.includes('F1'));assert($('magnitude-crossings').innerHTML.includes('Q2'));
const magnitudeModel=JSON.stringify(app.getModel());$('magnitude-in').click();const zoomedRange=$('magnitude').dataset.frequencyMax;
assert.equal(zoomedRange,$('magnitude-inset').dataset.frequencyMax);assert.throws(()=>app.replace({format:'wrong'}));$('magnitude-out').click();
assert.equal(JSON.stringify(app.getModel()),magnitudeModel);assert.equal($('magnitude').dataset.frequencyMax,$('magnitude-inset').dataset.frequencyMax);
$('magnitude-scale').value='ratio';$('magnitude-scale').emit('change');assert($('magnitude-inset').innerHTML.includes('data-unity-reference="1"'));assert.equal(JSON.stringify(app.getModel()),magnitudeModel);
// Independent collapse/restore is view-only. Space pans the z view even in add mode.
const uiModel=JSON.stringify(app.getModel()),uiSnapshot=app.snapshot();
for(const key of ['magnitude','phase','step','roots','inset']){const other=key==='phase'?'step':'phase';assert(!$(other+'-body').hidden);$(key+'-toggle').click();assert($(key+'-body').hidden);assert(!$(other+'-body').hidden);$(key+'-toggle').click();assert(!$(key+'-body').hidden);assert.equal(JSON.stringify(app.getModel()),uiModel);}
setting('tool','add');const panBefore=app.snapshot().editor,numberBefore=D.factorRoots(app.getModel()).zeros.length;
z('plot').emit('keydown',{code:'Space'});z('plot').emit('pointerdown',{...point(.3,0),pointerId:70,target:emptyTarget});z('plot').emit('pointermove',{...point(.5,.1),pointerId:70});z('plot').emit('pointerup',{pointerId:70});z('plot').emit('click',{...point(.5,.1),target:emptyTarget});z('plot').emit('keyup',{code:'Space'});
assert.notEqual(app.snapshot().editor.centerRe,panBefore.centerRe);assert.equal(D.factorRoots(app.getModel()).zeros.length,numberBefore);assert.equal(JSON.stringify(app.getModel()),uiModel);app.replace(uiSnapshot);
input('b','');assert.equal($('magnitude-inset').innerHTML,'');assert.equal($('magnitude-crossings').innerHTML,'');
app.destroy();assert.equal(root.innerHTML,'');
console.log('PASS digital controller events (minimal DOM stub): live coefficients/ZPK synchronization, switching, invalid drafts, numeric/click placement, lower-conjugate drag across axis, numeric update, bounds, pair deletion, zoom/pan and snapshot restore. Default placement, pointer/click deduplication, cancel, CTM/letterbox mapping, persisted stable IDs, per-point list edits/deletes and conjugate synchronization also covered. RAF previews perform no model publish, root analysis or HTML replacement; release commits once; Ctrl-only wheel, blur/Escape/capture/project cancellation, zero/negative K with saved roots/delay and advisory no-mutation tested. Two-curve SVG count/colors, explicit-delay alignment and zero-gain undefined phase checked. Not native browser QA.');
