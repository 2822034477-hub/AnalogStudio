// DOM integration regression. Layout, pointer capture, and canvas are stubbed;
// these checks prove control/model behavior, not visual browser layout.
const {JSDOM,VirtualConsole}=require('../testdeps/node_modules/jsdom');
const fs=require('fs'),assert=require('assert');
const html=fs.readFileSync(__dirname+'/../AnalogStudio.html','utf8');
const errors=[],vc=new VirtualConsole();
vc.on('jsdomError',e=>{if(!e.message.includes('navigation'))errors.push(e.message);});
const dom=new JSDOM(html,{
  url:'http://localhost/AnalogStudio.html',runScripts:'dangerously',pretendToBeVisual:true,virtualConsole:vc,
  beforeParse(w){
    w.ResizeObserver=class{observe(){}disconnect(){}};
    w.scrollTo=()=>{};
    w.HTMLElement.prototype.scrollIntoView=function(){};
    w.HTMLElement.prototype.setPointerCapture=function(){};
    w.HTMLElement.prototype.getBoundingClientRect=function(){
      const width=this.classList.contains('dock-window')?parseFloat(this.style.width)||600:600;
      const height=this.classList.contains('dock-window')?parseFloat(this.style.height)||300:300;
      return {x:0,y:0,left:0,top:0,right:width,bottom:height,width,height};
    };
    w.HTMLDialogElement.prototype.showModal=function(){this.open=true;};
    w.HTMLDialogElement.prototype.close=function(){this.open=false;};
    w.HTMLCanvasElement.prototype.getContext=function(){return new Proxy({measureText:s=>({width:s.length*6})},{get:(o,k)=>k in o?o[k]:()=>{},set:(o,k,v)=>(o[k]=v,true)});};
  }
});
const w=dom.window,d=w.document,$=s=>d.querySelector(s),all=s=>[...d.querySelectorAll(s)];
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
const click=s=>{assert($(s),`missing click target ${s}`);$(s).click();};
const change=(s,value)=>{assert($(s),`missing change target ${s}`);$(s).value=value;$(s).dispatchEvent(new w.Event('change',{bubbles:true}));};
const plain=value=>JSON.parse(JSON.stringify(value));
const options=()=>all('#dockNetworkSelect option').map(n=>({key:n.value,label:n.textContent}));
const pick=key=>{change('#dockNetworkSelect',key);assert.equal(w.AnalogNetworks.selected(),key);assert.equal($('#dockNetworkSelect').value,key);};
const readState=async()=>{await sleep(270);const raw=w.localStorage.getItem('analog-studio.workspace.v2');assert(raw,'state did not persist');return JSON.parse(raw);};
const find=(node,id)=>node.id===id?node:(node.children||[]).map(n=>find(n,id)).find(Boolean);
async function importState(state){
  const text=JSON.stringify({format:'analog-studio',schemaVersion:2,state});
  Object.defineProperty($('#importFile'),'files',{configurable:true,value:[{size:text.length,text:async()=>text}]});
  $('#importFile').dispatchEvent(new w.Event('change',{bubbles:true}));
  await sleep(30);
  const discard=$('#projectDialog[open] [data-project=discard]');if(discard){discard.click();await sleep(30);}
  assert(!$('#toast').classList.contains('error'),$('#toast').textContent);
}
function pointer(handle,type,x,y){
  const e=new w.MouseEvent(type,{clientX:x,clientY:y,button:0,bubbles:true,cancelable:true});
  Object.defineProperty(e,'pointerId',{value:1});handle.dispatchEvent(e);return e;
}
function drag(handle,dx,dy,end='pointerup'){
  assert(pointer(handle,'pointerdown',100,100).defaultPrevented,'resize start did not prevent default');
  pointer(handle,'pointermove',100+dx,100+dy);pointer(handle,end,100+dx,100+dy);
}
function key(handle,key,shiftKey=false){const e=new w.KeyboardEvent('keydown',{key,shiftKey,bubbles:true,cancelable:true});handle.dispatchEvent(e);assert(e.defaultPrevented);}
const size=frame=>({width:parseFloat(frame.style.width),height:parseFloat(frame.style.height)});

(async()=>{const entry=JSON.stringify(w.AnalogProject.snapshot());await w.AnalogProject.importFile({size:entry.length,text:async()=>entry});
  await sleep(100);assert.deepEqual(errors,[],'startup errors');
  assert(w.AnalogNetworks,'missing network instance API');
  assert($('#dockNetworkSelect').closest('#dockInspector'),'network picker must live with numerical controls');
  assert.deepEqual(options().map(n=>n.key),plain(w.AnalogNetworks.list()).map(n=>n.key));
  assert.equal(options().filter(n=>n.key.startsWith('lab:')).length,11);

  // Import actual duplicate instances in two differently nested positions.
  const C=w.AnalogCore;
  const a=C.makeBlock('gain'),b=C.makeBlock('gain'),c=C.makeBlock('gain');
  a.id='test_gain_a';b.id='test_gain_b';c.id='test_gain_c';
  a.name=b.name=c.name='Duplicate gain';
  a.params.Rf=10000;b.params.Rf=20000;c.params.Rf=30000;
  const nested=C.makeGroup('sum',[b,c]);nested.id='test_nested';nested.name='Nested group';
  const root=C.makeGroup('cascade',[a,nested]);root.id='test_root';root.name='Imported root';
  await importState({version:2,view:'compose',selectedType:'gain',selectedId:root.id,workspace:root,projectName:'Selector regression'});
  assert.equal($('#dockNetworkSelect').value,w.AnalogNetworks.selected(),'import must synchronize the locally selected view');
  pick('node:test_root');assert.equal($('#dockNetworkSelect').value,'node:test_root');
  const nodes=options().filter(n=>n.key.startsWith('node:'));
  assert.equal(nodes.length,5);
  assert.equal(new Set(nodes.map(n=>n.key)).size,5);
  const duplicates=nodes.filter(n=>n.label.includes('Duplicate gain'));
  assert.equal(duplicates.length,3);
  assert.equal(new Set(duplicates.map(n=>n.label)).size,3,'duplicate names require distinguishable labels');
  assert.deepEqual(duplicates.map(n=>n.label.split(' · ')[0]),['1.1','1.2.1','1.2.2']);

  // Close both diagrams before selecting or editing: no diagram click is needed.
  for(const id of ['schematic','compositionSchematic'])click(`[data-dock-panel="${id}"] [data-zoom="close"]`);
  pick('node:test_gain_b');
  assert($('#labEditor').hidden);assert(!$('#composeEditor').hidden);
  assert.equal($('#number-Rf').value,'20');
  change('#number-Rf','47');
  let state=await readState();
  assert.equal(find(state.workspace,'test_gain_b').params.Rf,47000);
  assert.equal(find(state.workspace,'test_gain_a').params.Rf,10000);
  assert.equal(find(state.workspace,'test_gain_c').params.Rf,30000);
  assert.notEqual(state.experiments.gain.params.Rf,47000,'composed edit leaked into lab prototype');
  change('#branchWeight','-2');state=await readState();
  assert.equal(find(state.workspace,'test_gain_b').weight,-2);
  assert.equal(find(state.workspace,'test_gain_c').weight,1);

  pick('node:test_nested');assert.equal($('#groupMode').value,'sum');
  change('#groupMode','cascade');state=await readState();
  assert.equal(find(state.workspace,'test_nested').mode,'cascade');
  assert.equal(state.workspace.mode,'cascade');
  assert.equal(find(state.workspace,'test_gain_b').weight,1,'cascade conversion must reset branch weights');
  change('#nodeDisplayName','Renamed subgroup');
  assert(options().find(n=>n.key==='node:test_nested').label.includes('Renamed subgroup'),'rename must refresh selector');
  change('#groupMode','sum');state=await readState();
  assert.equal(find(state.workspace,'test_nested').mode,'sum');
  assert.equal(state.workspace.mode,'cascade','editing nested group changed root group');

  pick('lab:gain');assert(!$('#labEditor').hidden);assert($('#composeEditor').hidden);
  change('#number-Rf','62');state=await readState();
  assert.equal(state.experiments.gain.params.Rf,62000);
  assert.equal(find(state.workspace,'test_gain_b').params.Rf,47000,'lab edit leaked into composed instance');
  for(const id of ['schematic','compositionSchematic'])assert($(`[data-dock-panel="${id}"]`).hidden,'selection reopened a closed diagram');

  // Invalid keys fail atomically; DOM invalid values resynchronize to the model.
  const beforeInvalid=await readState(),selectedBefore=w.AnalogNetworks.selected(),optionsBefore=options();
  for(const invalid of ['node:missing','lab:missing','','arbitrary:gain'])assert.equal(w.AnalogNetworks.select(invalid),false);
  change('#dockNetworkSelect','node:missing');
  assert.equal(w.AnalogNetworks.selected(),selectedBefore);
  assert.equal($('#dockNetworkSelect').value,selectedBefore);
  assert.deepEqual(options(),optionsBefore);
  assert.deepEqual(await readState(),beforeInvalid,'invalid selection changed persisted model');

  // Add clones a real instance; deleting it removes the precise option.
  const beforeAdd=new Set(options().map(n=>n.key));click('#addCurrentButton');
  const added=options().filter(n=>!beforeAdd.has(n.key));assert.equal(added.length,1);
  assert(added[0].key.startsWith('node:'));assert.equal($('#dockNetworkSelect').value,added[0].key);
  state=await readState();const addedId=added[0].key.slice(5);
  assert.equal(find(state.workspace,addedId).params.Rf,62000);
  change('#number-Rf','73');state=await readState();
  assert.equal(find(state.workspace,addedId).params.Rf,73000);
  assert.equal(state.experiments.gain.params.Rf,62000,'clone must not alias lab model');
  click(`#compositionTree [data-node="${addedId}"] > .tree-node-header [data-action="remove"]`);
  assert(!options().some(n=>n.key===added[0].key));assert.equal(options().length,beforeAdd.size);
  assert.equal($('#dockNetworkSelect').value,w.AnalogNetworks.selected());

  // A replacement design discards stale options; missing local selection falls back to its root.
  const replacementLeaf=C.makeBlock('gain');replacementLeaf.id='imported_replacement_leaf';replacementLeaf.params.Rf=18000;
  const replacement=C.makeGroup('cascade',[replacementLeaf]);replacement.id='imported_replacement_root';
  await importState({version:2,view:'compose',selectedId:replacementLeaf.id,workspace:replacement,projectName:'Replacement'});
  assert.deepEqual(options().filter(n=>n.key.startsWith('node:')).map(n=>n.key),['node:imported_replacement_root','node:imported_replacement_leaf']);
  assert.equal($('#dockNetworkSelect').value,'node:imported_replacement_root');pick('node:imported_replacement_leaf');assert.equal($('#number-Rf').value,'18');
  assert.deepEqual(errors,[],'network controls emitted runtime errors');
  console.log('PASS: network selector enumerates 11 lab modules and real duplicate/nested instances; hidden-diagram selection; isolated leaf/lab/group/weight edits; rename, add, delete, replacement import; atomic invalid selection.');

  const frames=all('[data-dock-panel]');assert.equal(frames.length,8);
  const defaults=new Map(frames.map(f=>[f.dataset.dockPanel,size(f)]));
  for(const frame of frames){
    const id=frame.dataset.dockPanel,isPlot=frame.dataset.plot==='true',initial=size(frame);
    assert(initial.width>=640,`${id}: default width below 640`);
    assert.equal(initial.height,isPlot?(id==='bodeContainer'?660:560):360,`${id}: default height`);
    assert.equal(frame.querySelectorAll('.dock-resize').length,3,`${id}: missing resize edges`);
    for(const edge of ['e','s','se']){
      const handle=frame.querySelector('.dock-resize-'+edge),before=size(frame);
      const others=new Map(frames.filter(n=>n!==frame).map(n=>[n,size(n)]));
      assert.equal(handle.tabIndex,0);assert.equal(handle.getAttribute('role'),'separator');assert(handle.getAttribute('aria-label'));
      drag(handle,83,59);
      assert.deepEqual(size(frame),{width:before.width+(edge.includes('e')?83:0),height:before.height+(edge.includes('s')?59:0)},`${id}: ${edge} pointer resize axis`);
      for(const [other,old] of others)assert.deepEqual(size(other),old,`${id}: resize changed another window`);
      assert(!frame.classList.contains('dock-resizing'));
      const beforeKey=size(frame);key(handle,edge==='s'?'ArrowDown':'ArrowRight');
      assert.equal(size(frame).width,beforeKey.width+(edge==='s'?0:10));
      assert.equal(size(frame).height,beforeKey.height+(edge==='s'?10:0));
      const afterKey=size(frame);key(handle,edge==='s'?'ArrowUp':'ArrowLeft',true);
      assert.equal(size(frame).width,afterKey.width-(edge==='s'?0:50));
      assert.equal(size(frame).height,afterKey.height-(edge==='s'?50:0));
    }
    // Enforce both dimensions with the corner; cancel ends the drag.
    const corner=frame.querySelector('.dock-resize-se');drag(corner,-10000,-10000,'pointercancel');
    assert.deepEqual(size(frame),{width:640,height:isPlot?400:260},`${id}: minimum bounds`);
    const cancelled=size(frame);pointer(corner,'pointermove',9999,9999);assert.deepEqual(size(frame),cancelled,`${id}: cancelled drag continued`);
    drag(corner,211,157);const customized=size(frame);
    frame.querySelector('[data-zoom="close"]').click();assert(frame.hidden);
    const check=$(`[data-open-panel="${id}"]`);check.checked=true;check.dispatchEvent(new w.Event('change',{bubbles:true}));
    assert(!frame.hidden);assert.deepEqual(size(frame),customized,`${id}: close/reopen lost custom size`);
  }
  click('#dockRestore');
  for(const frame of frames){assert(!frame.hidden);assert.deepEqual(size(frame),defaults.get(frame.dataset.dockPanel),`${frame.dataset.dockPanel}: Restore did not reset dimensions`);}
  await sleep(100);assert.deepEqual(errors,[],'runtime errors');
  console.log('PASS: all 8 windows have large defaults and keyboard-accessible east/south/corner resize controls; axis-only resizing, independent dimensions, minimum bounds, cancel, preserved close/reopen sizes, and Restore defaults. Layout/canvas stubbed; no visual verification claim.');
  dom.window.close();
})().catch(e=>{console.error(e);dom.window.close();process.exit(1);});
