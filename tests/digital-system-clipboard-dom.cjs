'use strict';
const assert=require('node:assert/strict'),{boot,pause,js}=require('./projects.cjs');
(async()=>{
 const b=boot();try{
 await pause();b.P.newProject();b.$('#projectWizardDomain').value='digital';b.$('#projectWizardDomain').dispatchEvent(new b.w.Event('change',{bubbles:true}));b.click('#projectWizardCreate');
 const w=b.w,M=w.DigitalModules,D=w.DigitalDesign,L=w.DigitalSystemLayout;w.SVGElement.prototype.getBoundingClientRect=w.HTMLElement.prototype.getBoundingClientRect;
 const c=M.defaults('subtract');c.timing='registered';c.moduleName='copy_cell';const design=M.create(c),s=M.empty();s.view='system';s.modules=[{key:'m1',design}];s.instances=[{id:'u1',moduleKey:'m1'}];s.ports=[{name:'x',direction:'input',width:16,signed:true,fraction:8},{name:'y',direction:'output',width:16,signed:true,fraction:8}];s.connections=[{from:'in:x',to:'u1:a'},{from:'in:x',to:'u1:b'},{from:'u1:data_out',to:'out:y'}];
 w.AnalogDigitalProject.replace({...D.defaults(),system:s});
 const $=k=>b.$('[data-ds="'+k+'"]'),snap=()=>js(w.AnalogDigitalProject.snapshot().system),node=id=>[...$('diagram').querySelectorAll('[data-ds-node]')].find(n=>n.dataset.dsNode===id);
 function screen(x,y){const svg=$('diagram').querySelector('svg'),r=svg.getBoundingClientRect(),v=svg.getAttribute('viewBox').split(' ').map(Number),k=Math.min(r.width/v[2],r.height/v[3]);return {x:r.left+(r.width-v[2]*k)/2+x*k,y:r.top+(r.height-v[3]*k)/2+y*k};}
 function context(el,x=100,y=100){const pt=screen(x,y),e=new w.MouseEvent('contextmenu',{bubbles:true,cancelable:true,button:2,clientX:pt.x,clientY:pt.y});el.dispatchEvent(e);assert(e.defaultPrevented);}
 const key=(key,target=w.document,extra={})=>{const e=new w.KeyboardEvent('keydown',{key,bubbles:true,cancelable:true,...extra});target.dispatchEvent(e);return e;};
 const original=snap(),originalHDL=M.generateSystem(original);
 context(node('u1').querySelector('rect'));assert(b.$('[data-context="copy"]')&&b.$('[data-context="delete"]'));b.click('[data-context="copy"]');assert.deepEqual(snap(),original);assert($('undo').disabled);
 context($('diagram').querySelector('svg > rect'),700,400);assert(!b.$('[data-context="paste"]').disabled);b.click('[data-context="paste"]');
 assert.equal(snap().instances[1].id,'u1_2');assert.equal(snap().instances[1].moduleKey,'m1');assert.equal(snap().modules.length,1);assert.equal(snap().modules[0].design.moduleName,'copy_cell');assert.equal(snap().modules[0].design.verilog,design.verilog);assert.equal(snap().connections.length,3);assert.equal(snap().layout.u1_2.x,700);assert.equal(snap().layout.u1_2.y,400);
 const pasted=snap();b.click('[data-ds="undo"]');assert.deepEqual(snap(),original);assert.equal(M.generateSystem(snap()),originalHDL);b.click('[data-ds="redo"]');assert.deepEqual(snap(),pasted);
 context($('diagram').querySelector('svg > rect'),700,600);b.click('[data-context="paste"]');assert.equal(snap().instances.at(-1).id,'u1_3');b.click('[data-ds="undo"]');assert.deepEqual(snap(),pasted);
 // Right-click delete restores all original wires and geometry in one undo.
 context(node('u1').querySelector('rect'));b.click('[data-context="delete"]');assert(!snap().instances.some(n=>n.id==='u1'));assert.equal(snap().connections.length,0);b.click('[data-ds="undo"]');assert.deepEqual(snap(),pasted);
 context(b.$('.ds-link'));assert(!b.$('[data-context="copy"]'));b.click('[data-context="delete"]');assert.equal(snap().connections.length,2);key('z',w.document,{ctrlKey:true});assert.deepEqual(snap(),pasted);
 context($('diagram').querySelector('svg > rect'));key('Escape');assert(!b.$('.ds-context-menu'));
 // Keyboard clipboard uses the same saved package and keeps text input native.
 node('u1').dispatchEvent(new w.KeyboardEvent('keydown',{key:'Enter',bubbles:true,cancelable:true}));assert(key('c',w.document,{ctrlKey:true}).defaultPrevented);assert(key('v',w.document,{ctrlKey:true}).defaultPrevented);assert.equal(snap().instances.at(-1).id,'u1_3');
 const input=$('instance-name'),beforeText=snap();input.focus();assert(!key('v',input,{ctrlKey:true}).defaultPrevented);assert.deepEqual(snap(),beforeText);
 // Clipboard can cross projects; undo history cannot cross the project boundary.
 const empty=M.empty();empty.view='system';w.AnalogDigitalProject.replace({...D.defaults(),system:empty});assert($('undo').disabled);context($('diagram').querySelector('svg > rect'),350,100);b.click('[data-context="paste"]');assert.equal(snap().instances[0].id,'u1_2');assert.equal(snap().modules[0].design.verilog,design.verilog);b.click('[data-ds="undo"]');assert.deepEqual(snap(),js(empty));
 // Same HDL module name with a different implementation is still rejected atomically.
 const other=M.defaults('subtract');other.moduleName='copy_cell';other.output.width=17;const conflict=M.empty();conflict.view='system';conflict.modules=[{key:'different',design:M.create(other)}];conflict.instances=[{id:'existing',moduleKey:'different'}];w.AnalogDigitalProject.replace({...D.defaults(),system:conflict});const beforeConflict=snap();context($('diagram').querySelector('svg > rect'),700,400);b.click('[data-context="paste"]');assert.deepEqual(snap(),beforeConflict);assert($('notice').textContent.includes('不同 Verilog'));assert($('undo').disabled);
 // Short literal 'u' and maximum-length user instance names retain legal suffixes.
 for(const id of ['u','a'.repeat(64)]){const edge=M.empty();edge.view='system';edge.modules=[{key:'m',design}];edge.instances=[{id,moduleKey:'m'}];w.AnalogDigitalProject.replace({...D.defaults(),system:edge});context(node(id).querySelector('rect'));b.click('[data-context="copy"]');context($('diagram').querySelector('svg > rect'),700,400);b.click('[data-context="paste"]');const name=snap().instances.at(-1).id;assert.equal(name,id.slice(0,62)+'_2');assert(name.length<=64);}
 assert.deepEqual(b.errors,[]);console.log('PASS diagram clipboard DOM: module/wire/blank right-click menus, copy then point-positioned paste, _2/_3 collision handling, immutable HDL/module-name reuse, links not duplicated, exact undo/redo, context deletion, keyboard and input guards, cross-project saved-package clipboard and atomic name-conflict rejection.');
 }finally{b.dom.window.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
