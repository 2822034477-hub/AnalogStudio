process.env.ANALOG_TEST_HTML=require('path').resolve(__dirname,'../AnalogStudio.html');process.env.ANALOG_TEST_MANAGER=require('path').resolve(__dirname,'../project-manager.js');
const assert=require('assert'),{boot,disk,pause,wizard,end}=require('./harness.cjs');
(async()=>{const d=disk('DiskRoot'),b=boot({picker:async()=>d.root});await pause();await wizard(b,'Artifacts');b.$('#projectWizardDomain').value='digital';b.$('#projectWizardDomain').dispatchEvent(new b.w.Event('change',{bubbles:true}));b.click('[data-project=create]');await pause();b.P.save();await pause();assert(!b.P.dirty());
// Reject unbound/denied writes without inventing a download or changing baseline.
d.permission='denied';await b.P.saveGenerated({filename:'digital.json',content:'first',category:'blackbox'});assert(b.$('[data-project=directoryAuthorize]'));assert(b.$('#projectFolderPath').textContent.includes('DiskRoot / Artifacts / black box / digital.json'));b.click('[data-project=cancel]');assert.equal(b.downloads.length,0);assert(!b.P.dirty());assert(!d.files.has('Artifacts/black box/digital.json'));
d.grant='granted';await b.P.saveGenerated({filename:'digital.json',content:'first',category:'blackbox'});b.click('[data-project=directoryAuthorize]');await pause();assert.equal(d.files.get('Artifacts/black box/digital.json'),'first');assert(!b.P.dirty());
// Overwrite owns immutable bytes and cancel preserves old file.
await b.P.saveGenerated({filename:'digital.json',content:'second',category:'blackbox'});assert(b.$('[data-project=artifactOverwrite]'));b.click('[data-project=cancel]');assert.equal(d.files.get('Artifacts/black box/digital.json'),'first');assert(!b.P.dirty());
// Failure after file open still preserves project baseline, records visible directory issue, and aborts.
const dir=d.root.directories.get('Artifacts'),original=dir.getFileHandle;
dir.getFileHandle=async function(name,opt){const h=await original.call(this,name,opt);if(name==='fail.v')h.createWritable=async()=>({write:async()=>{throw Error('Injected disk full')},close:async()=>{throw Error('must not close')},abort:async()=>d.calls.push(['independentAbort'])});return h;};
assert.equal(await b.P.saveGenerated({filename:'fail.v',content:'data'}),false);assert(!b.P.dirty());assert(b.P.directoryStatus().issue.includes('Injected disk full'));assert(d.calls.some(c=>c[0]==='independentAbort'));assert.equal(b.downloads.length,0);
// A safe project rename resolves a fresh subtree; prior exports and project JSON remain.
b.w.AnalogCircuitProject.rename('New / Folder');b.P.refresh();await b.P.saveGenerated({filename:'../CON.v',content:'safe'});assert(d.files.has('New _ Folder/__CON.v'));assert(d.files.has('Artifacts/Artifacts.analog.json'));assert(b.P.dirty());assert(b.P.directoryStatus().projectPath.includes('New _ Folder'));
end(b);console.log('PASS independent artifact QA: revoked permission shows black box target, explicit renewal/cancel, immutable overwrite cancel, writer failure/abort/visible issue, baseline preservation, sanitized rename and old files retained. Mock filesystem only.');
})().catch(e=>{console.error(e);process.exit(1)});
