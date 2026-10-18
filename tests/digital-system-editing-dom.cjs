'use strict';
const assert=require('node:assert/strict'),{boot,pause,js,file}=require('./projects.cjs');
(async()=>{
 const b=boot();try{
 await pause();b.P.newProject();b.$('#projectWizardDomain').value='digital';b.$('#projectWizardDomain').dispatchEvent(new b.w.Event('change',{bubbles:true}));b.click('#projectWizardCreate');
 const w=b.w,M=w.DigitalModules,D=w.DigitalDesign,L=w.DigitalSystemLayout,store='analog-studio.digital-modules.v1';
 w.SVGElement.prototype.getBoundingClientRect=w.HTMLElement.prototype.getBoundingClientRect;
 const $=k=>b.$('[data-ds="'+k+'"]'),snap=()=>js(w.AnalogDigitalProject.snapshot()),system=()=>snap().system;
 const key=(key,target=w.document,extra={})=>{const e=new w.KeyboardEvent('keydown',{key,bubbles:true,cancelable:true,...extra});target.dispatchEvent(e);return e;};
 function pointer(el,type='pointerdown'){const e=new w.MouseEvent(type,{bubbles:true,cancelable:true,button:0,clientX:100,clientY:100});Object.defineProperty(e,'pointerId',{value:7});el.dispatchEvent(e);}
 // The filter's primary action saves configuration and exact HDL before importing.
 const initial=snap();b.$('[data-ds="filter-name"]').value='designed_filter';b.click('[data-ds="filter-to-system"]');
 assert.equal(system().view,'system');assert.equal(system().instances[0].id,'u1');assert.equal(system().modules[0].design.moduleName,'designed_filter');assert.equal(system().modules[0].design.verilog,D.generateVerilog(initial.model,{moduleName:'designed_filter'}));
 const imported=system();b.click('[data-ds="undo"]');assert.equal(snap().system,initial.system);b.click('[data-ds="redo"]');assert.deepEqual(system(),imported);
 b.click('[data-import-design="0"]');assert.equal(system().instances[1].id,'u2');assert.equal(system().modules.length,1);b.click('[data-ds="undo"]');assert.deepEqual(system(),imported);
 // An existing complete system with saved positions and all five connections.
 const c=M.defaults('subtract');c.moduleName='saved_sub';c.timing='registered';const p=M.create(c),s=M.empty();s.view='system';s.modules=[{key:'m1',design:p}];s.instances=[{id:'u1',moduleKey:'m1'},{id:'u2',moduleKey:'m1'}];s.ports=[{name:'x',direction:'input',width:16,signed:true,fraction:8},{name:'y',direction:'output',width:16,signed:true,fraction:8}];s.connections=[{from:'in:x',to:'u1:a'},{from:'in:x',to:'u1:b'},{from:'u1:data_out',to:'u2:a'},{from:'in:x',to:'u2:b'},{from:'u2:data_out',to:'out:y'}];s.layout=L.capture(L.build(s).boxes);
 w.AnalogDigitalProject.replace({...D.defaults(),system:s});assert($('undo').disabled);const original=system(),hdl=M.generateSystem(original);
 $('from').value='in:x';$('from').dispatchEvent(new w.Event('change',{bubbles:true}));const stableCanvas=$('diagram');pointer(b.$('.ds-link'));
 assert(b.$('.ds-link.ds-selected'));assert.equal($('diagram'),stableCanvas);assert.equal($('from').value,'in:x');assert.equal(M.generateSystem(system()),hdl);
 assert(key('Delete').defaultPrevented);assert.equal(system().connections.length,4);assert(key('z',w.document,{ctrlKey:true}).defaultPrevented);assert.deepEqual(system(),original);assert(b.$('.ds-link.ds-selected'));
 key('y',w.document,{ctrlKey:true});assert.equal(system().connections.length,4);key('z',w.document,{ctrlKey:true});assert.deepEqual(system(),original);
 const text=$('port-name');text.focus();const before=system();assert(!key('Backspace',text).defaultPrevented);assert(!key('z',text,{ctrlKey:true}).defaultPrevented);assert.deepEqual(system(),before);
 // Deleting an instance or a port cleans every associated connection/layout key.
 b.click('[data-remove-instance="u1"]');assert.equal(system().instances.length,1);assert.equal(system().connections.length,2);assert.equal(system().layout.u1,undefined);b.click('[data-ds="undo"]');assert.deepEqual(system(),original);
 b.click('[data-remove-port="0"]');assert(!system().ports.some(p=>p.name==='x'));assert.equal(system().layout['in:x'],undefined);b.click('[data-ds="undo"]');assert.deepEqual(system(),original);
 // Library removal is exact-version deletion, including current-system uses.
 const other=M.create({...M.defaults('delay'),moduleName:'keep_other'});w.localStorage.setItem(store,JSON.stringify([p,other]));
 b.click('[data-delete-design="0"]');assert.equal(system().modules.length,0);assert.equal(system().instances.length,0);assert.equal(system().connections.length,0);assert.deepEqual(JSON.parse(w.localStorage.getItem(store)).map(p=>p.moduleName),['keep_other']);
 b.click('[data-ds="undo"]');assert.deepEqual(system(),original);assert(JSON.parse(w.localStorage.getItem(store)).some(p=>p.moduleName==='saved_sub'));assert.equal(M.generateSystem(system()),hdl);
 // Storage failure leaves graph and deletion history untouched.
 const setItem=w.Storage.prototype.setItem;w.Storage.prototype.setItem=function(k,v){if(k===store)throw Error('quota');return setItem.call(this,k,v);};
 const beforeFailure=system();b.click('[data-delete-design="0"]');assert.deepEqual(system(),beforeFailure);assert($('notice').textContent.includes('删除未完成'));w.Storage.prototype.setItem=setItem;
 // Add/connection errors are atomic and never create history entries.
 $('saved-select').value='0';$('instance-name').value='u1';const undoTitle=$('undo').title;b.click('[data-ds="add-instance"]');assert.deepEqual(system(),beforeFailure);assert.equal($('undo').title,undoTitle);
 // Filter model JSON gets an explicit HDL name, exact format and a saved design.
 $('import-filter-name').value='file_filter';$('import-filter-name').dispatchEvent(new w.Event('input',{bubbles:true}));b.click('[data-ds="import-filter-file"]');let picker=$('file');Object.defineProperty(picker,'files',{value:[file(D.serialize(D.create(D.presets.lowpass)))],configurable:true});picker.dispatchEvent(new w.Event('change',{bubbles:true}));await pause();
 assert(system().modules.some(m=>m.design.moduleName==='file_filter'));assert.equal(system().instances.length,3);assert(system().modules.find(m=>m.design.moduleName==='file_filter').design.ports.every(p=>p.width===16&&p.signed&&p.fraction===14));
 b.click('[data-ds="undo"]');assert.deepEqual(system(),original);
 // A late file read after a real edit is ignored; project replacement clears history.
 let resolve;const waiting={size:20,text:()=>new Promise(r=>resolve=r)};b.click('[data-ds="import-filter-file"]');picker=$('file');Object.defineProperty(picker,'files',{value:[waiting],configurable:true});picker.dispatchEvent(new w.Event('change',{bubbles:true}));
 b.click('[data-remove-link="0"]');const afterEdit=system();resolve(JSON.stringify(D.serialize(D.create(D.presets.lowpass))));await pause();assert.deepEqual(system(),afterEdit);
 w.AnalogDigitalProject.replace({...D.defaults(),system:s});assert($('undo').disabled&&$('redo').disabled);
 // History replay merges only affected library names; unrelated updates survive.
 b.click('[data-delete-design="0"]');const fresh=M.create({...M.defaults('gain'),moduleName:'unrelated_new'});w.localStorage.setItem(store,JSON.stringify(JSON.parse(w.localStorage.getItem(store)).concat(js(fresh))));b.click('[data-ds="undo"]');assert(JSON.parse(w.localStorage.getItem(store)).some(p=>p.moduleName==='unrelated_new'));assert.deepEqual(system(),original);
 // System JSON import is one reversible operation, including its embedded definitions.
 const empty=M.empty();empty.view='system';b.click('[data-ds="import-file"]');picker=$('file');Object.defineProperty(picker,'files',{value:[file({format:'analog-studio-digital-system',version:1,state:empty})],configurable:true});picker.dispatchEvent(new w.Event('change',{bubbles:true}));await pause();assert.equal(system().instances.length,0);b.click('[data-ds="undo"]');assert.deepEqual(system(),original);
 assert.deepEqual(b.errors,[]);console.log('PASS system editing DOM: filter save/import and raw JSON, exact interfaces and names, reversible instances/ports/wires/design-library deletion, graph/layout/HDL restoration, safe input shortcuts, atomic errors/storage failure, delayed import invalidation, scoped library replay and project history reset.');
 }finally{b.dom.window.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
