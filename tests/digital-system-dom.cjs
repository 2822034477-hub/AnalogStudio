'use strict';
const assert=require('node:assert/strict'),{boot,pause,js,file}=require('./projects.cjs');
(async()=>{
 const b=boot();try{
 await pause();b.P.newProject();b.$('#projectWizardDomain').value='digital';b.$('#projectWizardDomain').dispatchEvent(new b.w.Event('change',{bubbles:true}));b.click('#projectWizardCreate');
 const $=k=>b.$('[data-ds="'+k+'"]'),click=k=>$(k).click(),change=(el,value)=>{el.value=value;el.dispatchEvent(new b.w.Event('change',{bubbles:true}));};
 assert(b.$('[data-ds-tab="filter"]'));b.$('[data-ds="filter-name"]').value='my_filter';b.click('[data-ds="save-filter"]');
 let design=b.w.AnalogDigitalProject.snapshot();assert.equal(design.system.modules.length,1);assert.equal(design.system.modules[0].design.moduleName,'my_filter');assert(design.system.modules[0].design.verilog.includes('module my_filter'));
 b.click('[data-ds-tab="module"]');$('module-name').value='my_sub';change($('timing'),'registered');click('save-module');
 design=b.w.AnalogDigitalProject.snapshot();assert.equal(design.system.modules.length,2);assert.equal(design.system.modules[1].design.latency,1);assert($('source').textContent.includes('module my_sub'));
 b.click('[data-export-package="1"]');assert(b.$('[data-project="artifactDownload"]'));b.click('[data-project="artifactDownload"]');assert.equal(b.downloads.at(-1).filename,'my_sub.module.json');
 b.click('[data-export-zip="1"]');b.click('[data-project="artifactDownload"]');assert.equal(b.downloads.at(-1).filename,'my_sub.zip');
 b.click('[data-ds-tab="system"]');$('saved-select').value='1';$('instance-name').value='u_sub';click('add-instance');assert.equal(b.w.AnalogDigitalProject.snapshot().system.instances.length,1);
 for(const [name,direction]of [['x','input'],['y','output']]){$('port-name').value=name;$('port-direction').value=direction;click('add-port');}
 for(const [from,to]of [['in:x','u_sub:a'],['in:x','u_sub:b'],['u_sub:data_out','out:y']]){change($('from'),from);$('to').value=to;click('connect');}
 assert.equal(b.w.AnalogDigitalProject.snapshot().system.connections.length,3);assert(b.$('.ds-diagram svg'));assert(b.$('.ds-diagram path.ds-link'));
 click('export-system');assert($('system-source').textContent.includes('my_sub u_sub('));assert($('system-source').textContent.includes('.clk(clk)'));b.click('[data-project="artifactDownload"]');assert.equal(b.downloads.at(-1).filename,'digital_system.v');
 const saved=js(b.P.snapshot());assert.equal(saved.design.system.instances[0].id,'u_sub');
 b.P.save();b.click('[data-project="saved"]');assert(await b.P.importFile(file(saved)));if(b.$('[data-project="discard"]'))b.click('[data-project="discard"]');await pause();assert.deepEqual(js(b.P.snapshot()),saved);
 // Independent module packages survive the browser library, and new projects get no stale graph.
 b.P.newProject();if(b.$('[data-project="discard"]'))b.click('[data-project="discard"]');b.$('#projectWizardDomain').value='digital';b.$('#projectWizardDomain').dispatchEvent(new b.w.Event('change',{bubbles:true}));b.click('#projectWizardCreate');
 assert.equal(b.w.AnalogDigitalProject.snapshot().system,undefined);b.click('[data-ds-tab="system"]');assert.equal(b.w.AnalogDigitalProject.snapshot().system.instances.length,0);assert($('saved-select').textContent.includes('my_sub'));
 // Every fresh preview uses the concise generator embedded in the HTML.
 b.click('[data-ds-tab="module"]');
 for(const kind of ['delay','quantize','gain','subtract','multiply','absolute','integrator']){
  change($('kind'),kind);click('preview');const source=$('source').textContent;
  assert(!source.includes('wide_value')&&!source.includes('<<< 0')&&!source.includes('result_value'));
  assert.equal(source,b.w.DigitalModules.create(b.w.DigitalModules.defaults(kind)).verilog);
 }
 // Importing an old saved design retains its source. Preview/resave is an
 // explicit code-generation action, and leaves the imported package intact.
 const legacy=require('./fixtures/module-generator-v1'),c=legacy.defaults('delay');c.moduleName='legacy_delay';const old=legacy.create(c);
 const picker=$('file');Object.defineProperty(picker,'files',{value:[file(old)],configurable:true});picker.dispatchEvent(new b.w.Event('change',{bubbles:true}));await pause();
 assert.equal($('source').textContent,old.verilog);let imported=b.w.AnalogDigitalProject.snapshot().system.modules;assert.equal(imported.length,1);assert.equal(imported[0].design.verilog,old.verilog);
 click('preview');assert($('source').textContent.includes('assign data_out = data_in;'));assert(!$('source').textContent.includes('wide_value'));
 click('save-module');imported=b.w.AnalogDigitalProject.snapshot().system.modules;assert.equal(imported.length,2);assert.equal(imported[0].design.verilog,old.verilog);assert(imported[1].design.verilog.includes('assign data_out = data_in;'));
 assert.deepEqual(b.errors,[]);console.log('PASS digital system full DOM: integrated navigation, filter and registered primitive saves, design JSON/ZIP downloads, saved-only imports, port connections and graph, preserved module name in exported top, project save/restore, persistent module catalog and fresh graph per project. jsdom only.');
 }finally{b.dom.window.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
