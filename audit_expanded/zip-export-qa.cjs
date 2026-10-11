process.env.ANALOG_TEST_HTML=require('path').resolve(__dirname,'../AnalogStudio.html');process.env.ANALOG_TEST_MANAGER=require('path').resolve(__dirname,'../project-manager.js');
const assert=require('assert'),fs=require('fs'),path=require('path'),cp=require('child_process'),{boot,disk,pause,wizard,end,js}=require('./harness.cjs');
async function setup(){const d=disk('ZIPRoot'),b=boot({picker:async()=>d.root});await pause();await wizard(b,'ZIP_Project');b.$('#projectWizardDomain').value='digital';b.$('#projectWizardDomain').dispatchEvent(new b.w.Event('change',{bubbles:true}));b.click('[data-project=create]');await pause();b.P.save();await pause();assert(!b.P.dirty());return {b,d};}
(async()=>{const {b,d}=await setup(),p='ZIP_Project/AnalogStudio_Simulation.zip',button='[data-dd=simulation]';assert(!b.$(button).disabled);
// End-to-end actual control with denied permission; repeated actions cannot replace pending bytes/project.
d.permission='denied';const before=js(b.P.snapshot());b.click(button);await pause();assert(b.$('[data-project=directoryAuthorize]'));assert(b.$('#projectFolderPath').textContent.includes('ZIPRoot / ZIP_Project / AnalogStudio_Simulation.zip'));assert(!b.$('#projectFolderPath').textContent.includes('black box'));b.click(button);b.P.newProject();assert(b.$('[data-project=directoryAuthorize]'));assert.deepEqual(js(b.P.snapshot()),before);assert(!b.P.dirty());assert(!d.files.has(p));assert.equal(b.downloads.length,0);b.click('[data-project=cancel]');
b.click(button);await pause();d.grant='granted';b.click('[data-project=directoryAuthorize]');await pause();assert(d.files.has(p));assert(!d.files.has('ZIP_Project/black box/AnalogStudio_Simulation.zip'));assert(!b.P.dirty());const bytes=Buffer.from(d.files.get(p));assert.equal(bytes.readUInt32LE(0),0x04034b50);
const output=path.join(__dirname,'actual-control-simulation.zip');fs.writeFileSync(output,bytes);const report=cp.execFileSync(process.env.ANALOG_TEST_PYTHON||'python3',['-c',`import sys,zipfile,json
with zipfile.ZipFile(sys.argv[1]) as z:
 assert z.testzip() is None
 expected={'digital_filter.v','digital_filter_tb.sv','run_modelsim.bat','run_modelsim.do','run_xsim.bat','run_xsim.tcl','SIMULATION_README.txt'}
 assert set(z.namelist())==expected
 assert b'module digital_filter' in z.read('digital_filter.v')
 assert b'PASS: fixed-point vectors, valid gaps, reset' in z.read('digital_filter_tb.sv')
 assert '此包只是生成的源码与运行脚本'.encode() in z.read('SIMULATION_README.txt')
 assert all(i.compress_type==zipfile.ZIP_STORED for i in z.infolist())
 print(json.dumps({'files':z.namelist(),'bytes':sum(i.file_size for i in z.infolist())}))`,output],{encoding:'utf8'});console.log(report.trim());
// Existing archive is protected by pending overwrite and cancellation.
b.click(button);await pause();assert(b.$('[data-project=artifactOverwrite]'));b.P.save();b.P.newProject();assert(b.$('[data-project=artifactOverwrite]'));b.click('[data-project=cancel]');assert(Buffer.from(d.files.get(p)).equals(bytes));assert(!b.P.dirty());
// Binary record snapshots its input before asynchronous permission approval.
d.permission='denied';const input=new b.w.Uint8Array([80,75,3,4,0,255]);await b.P.saveGenerated({filename:'copy.zip',content:input,mime:'application/zip'});input.fill(17);b.click('[data-project=directoryAuthorize]');await pause();assert.deepEqual([...d.files.get('ZIP_Project/copy.zip')],[80,75,3,4,0,255]);assert(!b.P.dirty());
// Write failure must neither replace existing archive nor mark a changed project clean.
const dir=d.root.directories.get('ZIP_Project'),get=dir.getFileHandle;dir.getFileHandle=async function(n,opt){const h=await get.call(this,n,opt);if(n==='AnalogStudio_Simulation.zip')h.createWritable=async()=>({write:async()=>{throw Error('ZIP disk full')},close:async()=>{throw Error('must not close')},abort:async()=>d.calls.push(['zipAbort'])});return h;};
b.$('[data-dd=b]').value='0.3';b.$('[data-dd=b]').dispatchEvent(new b.w.Event('input',{bubbles:true}));b.click('[data-dd=apply]');assert(b.P.dirty());b.click(button);await pause();b.click('[data-project=artifactOverwrite]');await pause();assert(b.P.dirty());assert(Buffer.from(d.files.get(p)).equals(bytes));assert(d.calls.some(c=>c[0]==='zipAbort'));assert(b.P.directoryStatus().issue.includes('ZIP disk full'));assert.equal(b.downloads.length,0);
end(b);console.log('PASS independent ZIP export UI: real generated ZIP CRC/extraction/7 files; project path; permission/repeated-action/overwrite guards; immutable binary snapshot; disk failure abort, prior archive and dirty state preserved. No vendor simulator executed.');
})().catch(e=>{console.error(e);process.exit(1)});
