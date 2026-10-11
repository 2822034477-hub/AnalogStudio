/* Runs the actual bench/editor controllers with a minimal DOM stub; no browser/layout claim. */
'use strict';
const assert=require('node:assert/strict');
class Element{
 set value(v){this._value=String(v);} get value(){return this._value;}
 constructor(tag='div',attrs='',html=''){this.tagName=tag.toUpperCase();this.attrs=attrs;this.value=(attrs.match(/value="([^"]*)"/)||[])[1]||'';this.hidden=/\bhidden\b/.test(attrs);this.disabled=/\bdisabled\b/.test(attrs);this.listeners={};this.children={};this.textContent='';this.classList={add(){}};this.dataset={};this.ownerDocument={createElement:()=>new Element()};this._html=html;}
 set innerHTML(html){this._html=html;this.children={};for(const match of html.matchAll(/<(input|textarea|select|div|button|p|pre|section)\b([^>]*data-(dd|z)="([^"]+)"[^>]*)>/g)){const [full,tag,attrs,prefix,key]=match;const tail=html.slice(match.index+full.length);const el=new Element(tag,attrs);el.parent=this;if(tag==='textarea')el.value=tail.split('</textarea>')[0];if(tag==='select')el.value=(tail.split('</select>')[0].match(/<option value="([^"]*)"/)||[])[1]||'';this.children[prefix+':'+key]=el;}}
 get innerHTML(){return this._html;}
 querySelector(s){if(s==='svg')return this._html.includes('<svg')?{getBoundingClientRect:()=>({left:0,top:0,width:600,height:360})}:null;const m=s.match(/\[data-(dd|z)="?([^"\]]+)"?\]/);return m?this.children[m[1]+':'+m[2]]||null:null;}
 addEventListener(t,f){(this.listeners[t]??=[]).push(f);}
 removeEventListener(t,f){this.listeners[t]=(this.listeners[t]||[]).filter(x=>x!==f);}
 emit(t,event={}){const e={target:this,button:0,preventDefault(){},...event};for(const f of this.listeners[t]||[])f(e);if(event.bubbles)this.parent?.emit(t,{...e,bubbles:true});}
 click(){if(!this.disabled)this.emit('click');}
 matches(s){return /input|textarea|select/.test(s)&&['INPUT','TEXTAREA','SELECT'].includes(this.tagName);}
 hasAttribute(k){return this.attrs.includes(k+'=');}
 focus(){} replaceChildren(){this.innerHTML='';} setPointerCapture(){} hasPointerCapture(){return false;}
}
require('../digital-root-editor');const D=require('../digital-design');
const root=new Element(),changes=[],downloads=[];const app=D.mount(root,{onChange:x=>changes.push(x),onDownload:x=>downloads.push(x)});
const $=k=>root.querySelector(`[data-dd="${k}"]`),host=$('roots'),z=k=>host.querySelector(`[data-z="${k}"]`);
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
setting('placement','pair');setting('tool','add');z('plot').emit('pointerdown',{...point(.3,.4),pointerId:1,target:{closest:()=>null}});close(app.getModel().b[1],-.24);close(app.getModel().b[2],.1);assert.equal($('mode').value,'coefficients');assert(D.generateVerilog(app.getModel()).includes('module digital_filter'));
// Drag lower conjugate across the axis, retaining two real repeated roots at the crossing.
setting('tool','select');z('plot').emit('pointerdown',{...point(.3,-.4),pointerId:2,target:hit('zeros',0,-1)});z('plot').emit('pointermove',{...point(.5,0),pointerId:2});close(app.getModel().b[2],.1);z('plot').emit('pointermove',{...point(.5,.2),pointerId:2});close(app.getModel().b[2],.116);z('plot').emit('pointerup',{pointerId:2});close(D.factorRoots(app.getModel()).zeros[0].im,.2);
z('re').value='0.7';z('im').value='0.25';z('move').click();close(D.factorRoots(app.getModel()).zeros[0].re,.7);close(D.factorRoots(app.getModel()).zeros[0].im,.25);
const saved=app.snapshot();app.replace(saved);assert.deepEqual(app.snapshot(),saved);$('apply').click();
// Bounds failure is atomic and explicit. Selected roots can be deleted even with empty coordinate fields.
z('plot').emit('pointerdown',{...point(.7,.25),pointerId:3,target:hit('zeros',0)});z('plot').emit('pointerup',{pointerId:3});const beforeBad=app.getModel();z('re').value='101';z('move').click();assert(!z('error').hidden);assert.deepEqual(app.getModel(),beforeBad);z('re').value='';z('im').value='';z('delete').click();assert.equal(app.getModel().b.length,1);
setting('kind','poles');setting('placement','real');const v0=app.snapshot().editor;z('in').click();assert(app.snapshot().editor.span<v0.span);setting('tool','pan');z('plot').emit('pointerdown',{...point(0,0),pointerId:4,target:{closest:()=>null}});z('plot').emit('pointermove',{clientX:360,clientY:200,pointerId:4});z('plot').emit('pointerup',{pointerId:4});assert.notEqual(app.snapshot().editor.centerRe,0);z('fit').click();assert.equal(app.snapshot().editor.centerRe,0);
// Real-axis drag locks Im to zero, mouse-wheel zoom persists, Delete handles the selected real root.
app.replace(D.defaults());$('apply').click();setting('tool','select');z('plot').emit('pointerdown',{...point(.8,0),pointerId:5,target:hit('poles',0)});z('plot').emit('pointermove',{...point(.7,.4),pointerId:5});z('plot').emit('pointercancel',{pointerId:5});close(D.factorRoots(app.getModel()).poles[0].re,.7);assert.equal(D.factorRoots(app.getModel()).poles[0].im,0);const wheelBefore=app.snapshot().editor.span;z('plot').emit('wheel',{...point(.2,.2),deltaY:-1});assert(app.snapshot().editor.span<wheelBefore);z('plot').emit('keydown',{key:'Delete'});assert.equal(app.getModel().a.length,1);
setting('placement','pair');z('re').value='.6';z('im').value='.2';z('add').click();const bounded=app.getModel();z('add').click();assert(!z('error').hidden);assert.deepEqual(app.getModel(),bounded);
assert(changes.length>10);$('verilog').click();assert(downloads.length);
// Restoring an unfinished draft must not leave a live editor for the stale model.
const unfinished=app.snapshot();unfinished.ui.b='unfinished';unfinished.ui.mode='coefficients';
app.replace(unfinished);const restored=app.snapshot();assert(z('add').disabled);assert($('verilog').disabled);
assert.equal($('equation').textContent,'');assert.equal(z('plot').innerHTML,'');
z('add').click();assert.deepEqual(app.snapshot(),restored);assert.equal($('b').value,'unfinished');
$('apply').click();assert(z('add').disabled);input('b','.3');assert(!z('add').disabled);
assert.equal(app.getModel().b[0],.3);assert.equal($('b').value,'.3');
app.destroy();assert.equal(root.innerHTML,'');
console.log('PASS digital controller events (minimal DOM stub): live coefficients/ZPK synchronization, switching, invalid drafts, numeric/click placement, lower-conjugate drag across axis, numeric update, bounds, pair deletion, zoom/pan and snapshot restore. Not native browser QA.');
