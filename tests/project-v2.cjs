// v2 design architecture, creation wizard, session-only directories, and async save boundaries.
// Uses real controller/model integration; browser dialogs, canvas, layout and file handles are stubs.
const {JSDOM,VirtualConsole}=require('../testdeps/node_modules/jsdom');
const fs=require('fs'),assert=require('assert');
const base=fs.readFileSync(__dirname+'/../AnalogStudio.html','utf8');
const start=base.indexOf('/* Versioned standalone engineering projects.');
const html=base.slice(0,start)+fs.readFileSync(__dirname+'/../project-manager.js','utf8')+base.slice(base.indexOf('</script>',start));
const js=x=>JSON.parse(JSON.stringify(x)),file=x=>({size:JSON.stringify(x).length,text:async()=>JSON.stringify(x)}),pause=()=>new Promise(r=>setTimeout(r,80));
function boot({storage={},secure=false,picker}={}){const errors=[],downloads=[],vc=new VirtualConsole();vc.on('jsdomError',e=>{if(!e.message.includes('navigation'))errors.push(e.message)});const dom=new JSDOM(html,{url:'https://analog.test/',runScripts:'dangerously',pretendToBeVisual:true,virtualConsole:vc,beforeParse(w){Object.defineProperty(w,'isSecureContext',{value:secure});if(picker)w.showDirectoryPicker=picker;for(const [k,v]of Object.entries(storage))w.localStorage.setItem(k,v);w.ResizeObserver=class{observe(){}disconnect(){}};w.scrollTo=()=>{};w.HTMLElement.prototype.scrollIntoView=function(){};w.HTMLElement.prototype.getBoundingClientRect=function(){return {x:0,y:0,left:0,top:0,right:900,bottom:500,width:900,height:500}};w.HTMLCanvasElement.prototype.getContext=function(){return new Proxy({measureText:s=>({width:s.length*6})},{get:(o,k)=>k in o?o[k]:()=>{},set:(o,k,v)=>(o[k]=v,true)})};w.HTMLDialogElement.prototype.showModal=function(){this.open=true};w.HTMLDialogElement.prototype.close=function(){this.open=false;this.dispatchEvent(new w.Event('close'))};w.URL.createObjectURL=b=>{downloads.push(b);return 'blob:test'};w.URL.revokeObjectURL=()=>{};w.HTMLAnchorElement.prototype.click=function(){downloads.at(-1).filename=this.download;};}});const w=dom.window,d=w.document;return {dom,w,d,errors,downloads,$:s=>d.querySelector(s),click:s=>{const el=d.querySelector(s);assert(el,'Missing '+s);el.click();},P:w.AnalogProject};}
function set(b,id,value){b.$('#'+id).value=value;b.$('#'+id).dispatchEvent(new b.w.Event('change',{bubbles:true}));}
function create(b,name){b.P.newProject();if(b.$('[data-project=discard]'))b.click('[data-project=discard]');if(name)b.$('#projectWizardName').value=name;b.click('[data-project=create]');}
function storageOf(b){b.P.refresh();return Object.fromEntries(Object.keys(b.w.localStorage).map(k=>[k,b.w.localStorage.getItem(k)]));}
function namedError(name,message=name){return Object.assign(new Error(message),{name});}
function directory(){
 const state={calls:[],failure:null,release:null,delayClose:false};
 function folder(name,path=[]){
  const node={name,path,files:new Map(),directories:new Map()};
  node.handle={name,kind:'directory',async getDirectoryHandle(child,{create=false}={}){
   state.calls.push(['directory',child,create,path.join('/')]);
   if(state.failure==='permission')throw namedError('NotAllowedError');
   if(node.files.has(child))throw namedError('TypeMismatchError');
   if(!node.directories.has(child)&&!create)throw namedError('NotFoundError');
   if(!node.directories.has(child))node.directories.set(child,folder(child,[...path,child]));
   return node.directories.get(child).handle;
  },async getFileHandle(filename,{create=false}={}){
   state.calls.push(['get',filename,create,path.join('/')]);
   if(state.failure==='permission')throw namedError('NotAllowedError');
   if(node.directories.has(filename))throw namedError('TypeMismatchError');
   if(!node.files.has(filename)&&!create)throw namedError('NotFoundError');
   if(!node.files.has(filename))node.files.set(filename,'');
   return {async createWritable(){
    state.calls.push(['writable',path.join('/'),filename]);
    if(state.failure==='open')throw namedError('NotAllowedError');
    let content;
    return {async write(value){state.calls.push(['write',path.join('/'),filename]);if(state.failure==='write')throw Error('disk full');content=value;},
     async close(){state.calls.push(['close',path.join('/'),filename]);if(state.delayClose)await new Promise(r=>state.release=r);if(state.failure==='close')throw Error('close failed');node.files.set(filename,content);},
     async abort(){state.calls.push(['abort',path.join('/'),filename]);}};
   }};
  }};
  return node;
 }
 const root=folder('My designs');return {state,root,handle:root.handle};
}
(async()=>{
 let b=boot();await pause();assert.deepEqual(b.errors,[]);assert(b.P.isHome());const initial=js(b.P.snapshot());
 b.click('#projectHomeNew');assert(b.P.isHome());assert(b.$('#projectDialog').open);assert(b.$('#projectWizardDirectory').disabled);assert.equal(b.$('#projectWizardKind').value,'simulation');assert(!b.$('#projectWizardCreate').disabled);
 for(const [kind,domain,direction,allowed]of [['simulation','analog','forward',true],['simulation','analog','reverse',true],['simulation','digital','forward',true],['simulation','digital','reverse',true],['simulation','mixed','forward',true],['simulation','mixed','reverse',false],['board','analog','forward',false]]){for(const [id,value]of [['projectWizardKind',kind],['projectWizardDomain',domain],['projectWizardDirection',direction]])set(b,id,value);assert.equal(b.$('#projectWizardCreate').disabled,!allowed,kind+'/'+domain+'/'+direction);if(!allowed){b.click('[data-project=create]');assert(b.$('#projectWizardAvailability').textContent.includes('尚未实现'));}assert.deepEqual(js(b.P.snapshot()),initial);assert(b.P.isHome());}
 set(b,'projectWizardKind','simulation');set(b,'projectWizardDomain','analog');set(b,'projectWizardDirection','forward');
 b.click('[data-project=cancel]');assert(b.P.isHome());assert.deepEqual(js(b.P.snapshot()),initial);create(b,'Portable');assert(!b.P.isHome());assert(b.P.dirty());let design=js(b.P.snapshot());assert.equal(design.version,2);assert.deepEqual(design.classification,{kind:'simulation',domain:'analog',direction:'forward'});assert.deepEqual(Object.keys(design.circuit).sort(),['experiments','workspace']);assert.deepEqual(Object.keys(design.feedback.fields).sort(),['Beta','Gain','Poles','Sign','Zeros']);assert(!('ui'in design));
 b.P.save();b.click('[data-project=saved]');assert(!b.P.dirty());
 // UI-only and sweep changes cannot change portable bytes or dirty state.
 const circuit=b.w.AnalogCircuitProject.snapshot();circuit.view='lab';circuit.selectedType='gain';circuit.fMin=10;circuit.fMax=100000;circuit.chartMode='nyquist';circuit.trace.enabled=false;b.w.AnalogCircuitProject.replace(circuit);
 for(const [id,value]of [['expMin','20'],['expMax','200000'],['expTime','12']])set(b,id,value);
 b.w.AnalogPlotView.frequency('expMagnitude','linear');b.w.AnalogPlotView.zoom('expMagnitude',2);b.click('#dockCloseInspector');b.click('[data-dock-panel=expStep] [data-zoom=close]');b.P.refresh();assert.deepEqual(js(b.P.snapshot()),design);assert(!b.P.dirty());assert(b.w.localStorage.getItem('analog-studio.preferences.v1'));const preferences=b.w.localStorage.getItem('analog-studio.preferences.v1');
 set(b,'expGain','7');assert(b.P.dirty());set(b,'expGain','2');assert(!b.P.dirty());
 // v1 migration preserves circuit + feedback data, while even obsolete/broken UI is discarded.
 const legacy={format:b.P.format,version:1,name:'Migrated',circuit:{...b.w.AnalogCircuitProject.snapshot(),projectName:'Migrated'},feedback:b.w.AnalogFeedbackProject.snapshot(),ui:{obsolete:true}};legacy.feedback.fields.Gain='7';legacy.circuit.experiments.gain.params.Rf=3000;
 assert(b.P.validate(legacy).migrated);assert(await b.P.importFile(file(legacy)));assert(b.P.dirty());assert.equal(b.P.snapshot().name,'Migrated');assert.equal(b.P.snapshot().feedback.fields.Gain,'7');assert.equal(b.P.snapshot().circuit.experiments.gain.params.Rf,3000);assert(!b.P.snapshot().ui);assert.equal(b.w.localStorage.getItem('analog-studio.preferences.v1'),preferences);
 const migrated=js(b.P.snapshot());for(const mutate of [v=>v.version=99,v=>v.classification.kind='board',v=>v.circuit.workspace.id=v.circuit.experiments.gain.id,v=>delete v.circuit.experiments.gain,v=>v.feedback.fields.Sign='bad']){const bad=js(migrated);mutate(bad);assert.equal(await b.P.importFile(file(bad)),false);assert.deepEqual(js(b.P.snapshot()),migrated);}
 b.P.save();b.click('[data-project=saved]');assert(!b.P.dirty());const layoutReplace=b.w.AnalogWorkspaceProject.replace;let fail=true;b.w.AnalogWorkspaceProject.replace=v=>{if(fail){fail=false;throw Error('render failure')}layoutReplace(v)};assert.equal(await b.P.importFile(file({...migrated,name:'Should rollback'})),false);assert.deepEqual(js(b.P.snapshot()),migrated);assert(!b.P.dirty());b.w.AnalogWorkspaceProject.replace=layoutReplace;
 // Opening/canceling the wizard, including after discard confirmation, is nondestructive.
 set(b,'expGain','8');const draft=js(b.P.snapshot());b.P.returnHome();b.click('[data-project=preserveHome]');b.P.newProject();b.click('[data-project=discard]');b.click('[data-project=cancel]');assert(b.P.isHome());assert.deepEqual(js(b.P.snapshot()),draft);b.P.continueProject();
 const oldStore=JSON.stringify({project:legacy,baseline:JSON.stringify(legacy),lastFile:'old.analog.json'});const old=boot({storage:{'analog-studio.project.v1':oldStore}});await pause();assert.equal(old.w.localStorage.getItem('analog-studio.project.v1'),oldStore);old.P.continueProject();assert.equal(old.P.snapshot().feedback.fields.Gain,'7');assert(old.P.dirty());assert(old.w.localStorage.getItem('analog-studio.project.v2'));old.dom.window.close();assert.deepEqual(b.errors,[]);b.dom.window.close();
 // Directory choice itself never creates/replaces a project or file. Cancel and denial retain draft.
 const disk=directory();let pickerImpl=async()=>disk.handle,pickerCalls=0;b=boot({secure:true,picker:async options=>{pickerCalls++;assert.deepEqual(options,{mode:'readwrite'});return pickerImpl();}});await pause();const unopened=js(b.P.snapshot());b.P.newProject();pickerImpl=async()=>{throw namedError('AbortError')};b.click('[data-project=wizardDirectory]');await pause();assert.deepEqual(js(b.P.snapshot()),unopened);assert(b.P.isHome());assert(b.$('#projectWizardDirectoryStatus').textContent.includes('取消'));assert.equal(disk.state.calls.length,0);
 pickerImpl=async()=>{throw namedError('NotAllowedError')};b.click('[data-project=wizardDirectory]');await pause();assert(b.$('#projectWizardDirectoryStatus').textContent.includes('未获授权'));assert.deepEqual(js(b.P.snapshot()),unopened);
 let resolvePicker;pickerImpl=()=>new Promise(r=>resolvePicker=r);b.click('[data-project=wizardDirectory]');b.click('#projectClose');resolvePicker(disk.handle);await pause();assert(b.P.isHome());assert(!b.$('#projectDialog').open);assert.deepEqual(js(b.P.snapshot()),unopened);
 b.P.newProject();pickerImpl=async()=>disk.handle;b.click('[data-project=wizardDirectory]');await pause();assert.equal(disk.state.calls.length,0);assert(b.$('#projectWizardDirectoryStatus').textContent.includes('My designs'));b.$('#projectWizardName').value='Disk project';b.click('[data-project=create]');await pause();assert(!b.P.isHome());assert(b.P.dirty());
 const projectDirectory=disk.root.directories.get('Disk project');assert(projectDirectory,'Create establishes the project-named child directory');const blackboxDirectory=projectDirectory.directories.get('black box');assert(blackboxDirectory,'Create establishes the black box child directory');assert.equal(disk.root.files.size,0);assert.equal(projectDirectory.files.size,0);assert.equal(blackboxDirectory.files.size,0);assert(!disk.state.calls.some(call=>call[0]==='write'),'Create writes no project/model files');
 // Successful file close, rather than write acceptance, establishes the saved baseline.
 disk.state.delayClose=true;b.P.save();await pause();assert(disk.state.release);assert(b.P.dirty());assert(b.$('#exportButton').disabled);const count=disk.state.calls.length;b.P.save();assert.equal(disk.state.calls.length,count);disk.state.release();await pause();assert(!b.P.dirty());assert(b.$('#projectNotice').textContent.includes('已写入'));const written=projectDirectory.files.get('Disk project.analog.json');assert.deepEqual(JSON.parse(written),js(b.P.snapshot()));assert(!written.includes('fMin'));assert(!written.includes('plots'));assert.equal(disk.root.files.size,0,'Project JSON must not be written in the selected base directory');assert.equal(blackboxDirectory.files.size,0,'Project JSON must not be written in the black box directory');disk.state.delayClose=false;
 set(b,'expGain','9');b.P.save();await pause();assert(b.$('[data-project=overwrite]'));assert.equal(projectDirectory.files.get('Disk project.analog.json'),written);b.click('[data-project=cancel]');assert(b.P.dirty());assert.equal(projectDirectory.files.get('Disk project.analog.json'),written);
 b.P.save();await pause();disk.state.failure='write';b.click('[data-project=overwrite]');await pause();assert(b.P.dirty());assert.equal(projectDirectory.files.get('Disk project.analog.json'),written);assert(disk.state.calls.some(x=>x[0]==='abort'));assert(b.$('#projectNotice').textContent.includes('未完成'));
 // The download route remains available even after the directory loses access.
 disk.state.failure='permission';b.click('#projectDownload');assert.equal(b.downloads.length,1);b.click('[data-project=cancel]');assert(b.P.dirty());b.P.save();await pause();assert(b.P.dirty());assert(b.$('#projectNotice').textContent.includes('下载备份'));disk.state.failure=null;
 // A failed final close must not be confused with a successful write.
 disk.state.failure='close';b.P.save();await pause();b.click('[data-project=overwrite]');await pause();assert(b.P.dirty());assert.equal(projectDirectory.files.get('Disk project.analog.json'),written);disk.state.failure=null;
 b.P.save();await pause();b.click('[data-project=overwrite]');await pause();assert(!b.P.dirty());assert.equal(JSON.parse(projectDirectory.files.get('Disk project.analog.json')).feedback.fields.Gain,'9');
 // Changes made while bytes are in flight stay dirty against the exact saved snapshot.
 set(b,'expGain','10');disk.state.delayClose=true;b.P.save();await pause();b.click('[data-project=overwrite]');await pause();set(b,'expGain','11');disk.state.release();await pause();assert(b.P.dirty());assert.equal(JSON.parse(projectDirectory.files.get('Disk project.analog.json')).feedback.fields.Gain,'10');assert.equal(b.P.snapshot().feedback.fields.Gain,'11');disk.state.delayClose=false;
 b.P.save();await pause();b.click('[data-project=overwrite]');await pause();assert(!b.P.dirty());
 b.P.save(true);b.$('#projectSaveName').value='Renamed';disk.state.delayClose=true;b.click('[data-project=saveDirectoryAs]');await pause();assert.equal(b.P.snapshot().name,'Disk project');disk.state.release();await pause();assert.equal(b.P.snapshot().name,'Renamed');assert(!b.P.dirty());disk.state.delayClose=false;
 const renamedDirectory=disk.root.directories.get('Renamed');assert(renamedDirectory,'Save As establishes a separate project directory');assert(renamedDirectory.directories.has('black box'));assert.equal(JSON.parse(renamedDirectory.files.get('Renamed.analog.json')).name,'Renamed');assert.equal(JSON.parse(projectDirectory.files.get('Disk project.analog.json')).name,'Disk project','Save As leaves the previous project file in its original directory');assert(!projectDirectory.files.has('Renamed.analog.json'));assert.equal(disk.root.files.size,0);
 // Handles/paths never enter local storage or exported schema; recovery must choose a directory again.
 const store=storageOf(b);assert(!store['analog-studio.project.v2'].includes('My designs'));assert(!store['analog-studio.preferences.v1'].includes('My designs'));const reload=boot({storage:store,secure:true,picker:async()=>disk.handle});await pause();reload.P.continueProject();assert.equal(reload.P.snapshot().name,'Renamed');assert(!reload.P.dirty());reload.P.save();assert.equal(reload.downloads.length,1);assert(reload.$('[data-project=saved]'));reload.dom.window.close();assert.deepEqual(b.errors,[]);b.dom.window.close();
 console.log('PASS project-v2: portable design schema, UI exclusion/independent preferences, v1 migration, wizard capability gates, non-destructive cancel, atomic import, secure base-directory picking/cancel/denial/stale result, nested project/black box directories, separate Save As directory, overwrite, write/close failure, download fallback, session-only handles and exact save baselines. Browser API stubs; real filesystem permission UX not exercised.');
})().catch(e=>{console.error(e);process.exit(1)});
