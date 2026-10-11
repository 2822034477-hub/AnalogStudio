// Real app/controller integration with mocked filesystem handles. No browser permission or visual claims.
const assert=require('assert');const {boot,pause,js,file}=require('./projects.cjs');
const error=(name,message=name)=>Object.assign(new Error(message),{name});
function disk(){
 const d={calls:[],permission:'granted',grant:'granted',failure:'',hold:null,release:null};
 function folder(name,path=[]){
  const node={name,path,files:new Map(),directories:new Map()};
  node.handle={name,kind:'directory',queryPermission:async()=>d.permission,requestPermission:async()=>{d.calls.push('reauthorize');d.permission=d.grant;return d.grant;},
   async getDirectoryHandle(child,{create=false}={}){
    d.calls.push(['directory',child,create,path.join('/')]);
    if(d.failure==='lookup')throw error('NotAllowedError');
    if(node.files.has(child))throw error('TypeMismatchError');
    if(!node.directories.has(child)&&!create)throw error('NotFoundError');
    if(!node.directories.has(child))node.directories.set(child,folder(child,[...path,child]));
    return node.directories.get(child).handle;
   },async getFileHandle(filename,{create=false}={}){
    d.calls.push(['get',filename,create,path.join('/')]);
    if(d.failure==='lookup')throw error('NotAllowedError');
    if(d.hold==='lookup'){d.hold=null;await new Promise(r=>d.release=r);}
    if(node.directories.has(filename))throw error('TypeMismatchError');
    if(!node.files.has(filename)&&!create)throw error('NotFoundError');
    if(!node.files.has(filename))node.files.set(filename,'');
    return {async createWritable(){
     if(d.failure==='open')throw Error('open failed');let text;
     return {async write(s){d.calls.push('write');if(d.failure==='write')throw Error('disk full');text=s;},
      async close(){d.calls.push('close');if(d.hold==='close'){d.hold=null;await new Promise(r=>d.release=r);}if(d.failure==='close')throw Error('close failed');node.files.set(filename,text);},
      async abort(){d.calls.push('abort');}};
    }};
   }};
  return node;
 }
 d.root=folder('工程目录');d.handle=d.root.handle;return d;
}
async function setup(withDirectory=true){const b=boot(),d=disk();await pause();if(withDirectory){Object.defineProperty(b.w,'isSecureContext',{value:true,configurable:true});b.w.showDirectoryPicker=async()=>d.handle;}b.P.newProject();if(withDirectory){b.click('[data-project=wizardDirectory]');await pause();}b.$('#projectWizardName').value='命名测试';b.click('[data-project=create]');await pause();const projectDirectory=withDirectory?d.root.directories.get('命名测试'):null;const modelDirectory=projectDirectory?.directories.get('black box');if(withDirectory){assert(projectDirectory,'Create establishes a project-named directory');assert(modelDirectory,'Create establishes the black box child directory');assert.equal(d.root.files.size,0);assert.equal(projectDirectory.files.size,0);assert.equal(modelDirectory.files.size,0);}const model=b.w.AnalogBlackbox.exportTransfer({num:[2],den:[1,.01]},{name:'初始模型'});const ids=b.w.AnalogBlackboxProject.addModels([model,model]);b.w.AnalogNetworks.select('node:'+ids[0]);return {...b,d,ids,projectDirectory,modelDirectory};}
function rename(b,name){b.$('#blackboxModelName').value=name;b.click('#blackboxApply');}
function status(b){return b.$('#blackboxStatus').textContent;}
(async()=>{let b=await setup(),{d,projectDirectory,modelDirectory}=b;const A=b.w.AnalogBlackboxProject;assert(!b.$('#nodeDisplayName'),'blackbox has one authoritative name editor');
rename(b,'中文滤波器');assert.equal(A.list()[0].model.name,'中文滤波器');assert.equal(A.list()[1].model.name,'初始模型');assert(b.$('#dockNetworkSelect').textContent.includes('中文滤波器'));assert(b.$('[data-node="'+b.ids[0]+'"] .tree-name').textContent.includes('中文滤波器'));assert.equal(b.P.validate(js(b.P.snapshot())).project.circuit.workspace.children[0].model.name,'中文滤波器');
b.$('#blackboxModelName').value='输入后直接保存';b.$('#blackboxNumerator').value='[7]';b.click('#blackboxExportSelected');await pause();assert.equal(JSON.parse(modelDirectory.files.get('输入后直接保存.blackbox.json')).numerator[0],7);assert.equal(A.list()[0].model.name,'输入后直接保存');assert.equal(b.downloads.length,0);assert(b.P.dirty());assert(status(b).includes('已写入'));assert.equal(d.root.files.size,0,'Models must not be saved in the selected base directory');assert.equal(projectDirectory.files.size,0,'Models must not be saved beside the project JSON');
// Independent file has the model's intrinsic transfer, not its external branch weight.
let s=b.w.AnalogCircuitProject.snapshot();s.workspace.mode='sum';s.workspace.children[0].weight=-3;b.w.AnalogCircuitProject.replace(s);b.w.AnalogNetworks.select('node:'+b.ids[0]);b.click('#blackboxExportSelected');await pause();assert(b.$('[data-project=modelOverwrite]'));const original=modelDirectory.files.get('输入后直接保存.blackbox.json');b.click('[data-project=cancel]');assert.equal(modelDirectory.files.get('输入后直接保存.blackbox.json'),original);assert(status(b).includes('取消'));b.click('#blackboxExportSelected');await pause();b.click('[data-project=modelOverwrite]');await pause();assert.equal(JSON.parse(modelDirectory.files.get('输入后直接保存.blackbox.json')).numerator[0],7);
// Rename retains old file; sanitized traversal + Windows device names stay within directory.
rename(b,'../新模型/..');b.click('#blackboxExportSelected');await pause();assert(modelDirectory.files.has('输入后直接保存.blackbox.json'));assert(modelDirectory.files.has('__新模型_.blackbox.json'));assert.equal(JSON.parse(modelDirectory.files.get('__新模型_.blackbox.json')).name,'../新模型/..');rename(b,'CON');b.click('#blackboxExportSelected');await pause();assert(modelDirectory.files.has('_CON.blackbox.json'));
// Explicit reauthorization; denial/cancellation never downloads or marks project clean.
rename(b,'权限测试');d.permission='denied';b.click('#blackboxExportSelected');await pause();assert(b.$('[data-project=modelAuthorize]'));assert(!d.calls.includes('reauthorize'));b.click('[data-project=cancel]');assert(!modelDirectory.files.has('权限测试.blackbox.json'));b.click('#blackboxExportSelected');await pause();d.grant='denied';b.click('[data-project=modelAuthorize]');await pause();assert(!modelDirectory.files.has('权限测试.blackbox.json'));assert(status(b).includes('未保存'));assert.equal(b.downloads.length,0);b.click('#blackboxExportSelected');await pause();d.grant='granted';b.click('[data-project=modelAuthorize]');await pause();assert(modelDirectory.files.has('权限测试.blackbox.json'));
for(const failure of ['lookup','open','write','close']){rename(b,'失败-'+failure);d.failure=failure;b.click('#blackboxExportSelected');await pause();assert(!status(b).includes('已写入'),failure);assert.equal(b.downloads.length,0);assert(b.P.dirty());d.failure='';}
// Immutable snapshot, duplicate-click suppression and honest status after mid-write edits.
rename(b,'并发快照');d.hold='close';b.click('#blackboxExportSelected');await pause();const writes=d.calls.filter(c=>c==='write').length;b.click('#blackboxExportSelected');assert.equal(d.calls.filter(c=>c==='write').length,writes);rename(b,'稍后修改');assert.equal(await b.P.importFile(file(js(b.P.snapshot()))),false,'project switch blocked while writer active');d.release();await pause();assert.equal(JSON.parse(modelDirectory.files.get('并发快照.blackbox.json')).name,'并发快照');assert.equal(A.list()[0].model.name,'稍后修改');assert(status(b).includes('不包含之后的修改'));
// Cancel while awaiting filesystem lookup stops before create/write.
rename(b,'取消读取');d.hold='lookup';b.click('#blackboxExportSelected');await pause();b.click('#projectClose');d.release();await pause();assert(!modelDirectory.files.has('取消读取.blackbox.json'));assert(!status(b).includes('已写入'));
// Composite explicitly named; full cascade/sum response snapshot in the black box child directory.
b.click('#blackboxExport');b.$('#projectModelName').value='总响应';b.click('[data-project=modelNamed]');await pause();assert(modelDirectory.files.has('总响应.blackbox.json'));assert.equal(JSON.parse(modelDirectory.files.get('总响应.blackbox.json')).numerator[0],A.exportCurrent().numerator[0]);assert.equal(A.list()[0].model.name,'取消读取');
// Legacy projects may have a display alias: reuse must retain the visible name.
let legacyState=b.w.AnalogCircuitProject.snapshot();legacyState.workspace.children[0].name='历史显示别名';b.w.AnalogCircuitProject.replace(legacyState);b.w.AnalogNetworks.select('node:'+b.ids[0]);assert(!b.$('#nodeDisplayName'));assert.equal(b.$('#blackboxModelName').value,'历史显示别名');const count=A.list().length;b.click('[data-node="'+b.ids[0]+'"] [data-action=add]');const reuse=b.$('[data-add-blackbox="'+b.ids[0]+'"]');assert(reuse.textContent.includes('历史显示别名'));reuse.click();assert.equal(A.list().length,count+1);const newest=A.list().find(n=>!b.ids.includes(n.id));assert.equal(newest.model.name,'历史显示别名');assert.equal(A.list()[0].model.name,'取消读取','source model remains independent');b.w.AnalogNetworks.select('node:'+newest.id);rename(b,'复用后的独立名称');assert.equal(A.list()[0].name,'历史显示别名');assert.equal(A.list().find(n=>n.id===newest.id).model.name,'复用后的独立名称');
// Switching project clears directory, then explicit download only.
const portable=js(b.P.snapshot());b.P.save();await pause();if(b.$('[data-project=overwrite]')){b.click('[data-project=overwrite]');await pause();}assert(projectDirectory.files.has('命名测试.analog.json'),'Project JSON belongs directly in the project directory');assert(!modelDirectory.files.has('命名测试.analog.json'));assert.equal(d.root.files.size,0);assert(await b.P.importFile(file(portable)));assert(!b.P.dirty());b.w.AnalogNetworks.select('node:'+b.ids[0]);b.click('#blackboxExportSelected');await pause();assert(b.$('[data-project=modelDownload]'));assert.equal(b.downloads.length,0);b.click('[data-project=cancel]');assert.equal(b.downloads.length,0);assert.deepEqual(b.errors,[]);b.dom.window.close();
// Unsupported environment is visibly download-only and waits for explicit choice.
b=await setup(false);b.click('#blackboxExportSelected');await pause();assert(b.$('#projectDialogBody').textContent.includes('不支持'));assert.equal(b.downloads.length,0);b.click('[data-project=modelDownload]');assert.equal(b.downloads.length,1);assert.equal(b.downloads[0].filename,'初始模型.blackbox.json');assert(status(b).includes('尚未确认写入磁盘'));assert.deepEqual(b.errors,[]);b.dom.window.close();
console.log('PASS named blackbox saves: independent names/roundtrip, nested project/black box directory separation, save editor values, intrinsic models, overwrite cancel/approve, safe filenames, explicit permission renewal/denial, all write failures, snapshot edits/repeated clicks, cancelled lookup, composite naming, project switch, explicit download fallback. Filesystem/layout mocked.');
})().catch(e=>{console.error(e);process.exit(1)});
