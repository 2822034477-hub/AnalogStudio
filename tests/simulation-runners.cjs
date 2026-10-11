'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),os=require('node:os'),path=require('node:path'),cp=require('node:child_process');
const R=require('../simulation-runners.js'),D=require('../digital-design.js');
let checks=0;const ok=(v,msg)=>{assert(v,msg);checks++;};const rejects=f=>{assert.throws(f);checks++;};
const files=R.generate(),get=n=>files.find(f=>f.filename===n).content;
ok(files.length===5);ok(get('run_modelsim.do').includes('vlog -sv'));ok(get('run_modelsim.do').includes('{work.digital_filter_tb}'));ok(get('run_modelsim.bat').includes('findstr /L /C:"'+R.PASS+'"'));ok(get('run_xsim.bat').includes('call xvlog -sv'));ok(get('run_xsim.bat').includes('call xelab "work.digital_filter_tb"'));ok(get('run_xsim.bat').includes('-tclbatch "../run_xsim.tcl"'));ok(get('run_xsim.tcl').includes('run all\nquit'));
for(const name of ['run_modelsim.bat','run_xsim.bat']){ok(!/(?<!\r)\n/.test(get(name)),'Windows CRLF');ok(get(name).includes('setlocal DisableDelayedExpansion'));ok(get(name).includes('pushd "%~dp0"'));ok(get(name).includes('exit /b 1'));ok(get(name).includes('exit /b 2'));}
for(const o of [{moduleName:'foo;exit'},{testbenchName:'foo]'},{moduleName:'same',testbenchName:'same'},{rtlFilename:'../evil.v'},{rtlFilename:'x&whoami.v'},{rtlFilename:'x%PATH%.v'},{rtlFilename:'CON.v'},{rtlFilename:'a..v'},{rtlFilename:'a.v\n'},{testbenchFilename:'C:\\foo.sv'},{testbenchFilename:'x!.sv'},{passMarker:'PASS: %COMSPEC%'},{passMarker:'PASS: "hi"'},null])rejects(()=>R.generate(o));
const custom=R.generate({moduleName:'filter$custom',testbenchName:'bench$custom',rtlFilename:'design source.v',testbenchFilename:'test bench.sv'});ok(custom[1].content.includes('{work.bench$custom}'));ok(custom[1].content.includes('{design source.v}'));ok(custom[2].content.includes('"..\\design source.v"'));
const model=D.create(D.presets.lowpass),rtl=D.generateVerilog(model),testbench=D.generateTestbench(model);
const result=R.bundle({rtl,testbench});ok(result.content instanceof Uint8Array);ok(result.mime==='application/zip');ok(result.filename.endsWith('.zip'));
rejects(()=>R.bundle({rtl}));rejects(()=>R.zip([{filename:'../oops',content:'x'}]));rejects(()=>R.zip([{filename:'x',content:'a'},{filename:'X',content:'b'}]));rejects(()=>R.zip([{filename:'x',content:{}}]));
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'analogstudio runner checks ')),archive=path.join(dir,'bundle.zip');fs.writeFileSync(archive,result.content);
const zipReport=cp.execFileSync(process.env.ANALOG_TEST_PYTHON||'python3',['-c',`import zipfile,sys,json
with zipfile.ZipFile(sys.argv[1]) as z:
 assert z.testzip() is None
 assert len(z.namelist()) == 7
 assert z.read('digital_filter.v').decode() == open(sys.argv[2],encoding='utf-8').read()
 assert '本地仿真' in z.read('SIMULATION_README.txt').decode('utf-8')
 assert all(i.compress_type == zipfile.ZIP_STORED for i in z.infolist())
 z.extractall(sys.argv[3])
 print(json.dumps(z.namelist()))`,archive,(()=>{const p=path.join(dir,'expected.v');fs.writeFileSync(p,rtl);return p;})(),dir],{encoding:'utf8'});ok(JSON.parse(zipReport).length===7);
// Tcl command recording validates syntax/quoting only. This does NOT run an HDL simulator.
const tclPath=p=>'\"'+p.replace(/\\/g,'/').replace(/[$\[\]\"]/g,c=>'\\'+c)+'\"';
const calls=path.join(dir,'calls.txt'),harness=path.join(dir,'check.tcl');fs.writeFileSync(harness,`set log [open ${tclPath(calls)} w]
proc record {args} {global log; puts $log $args}
proc onerror {args} {record onerror {*}$args}
proc vlib {args} {record vlib {*}$args}
proc vmap {args} {record vmap {*}$args}
proc vlog {args} {record vlog {*}$args}
proc vsim {args} {record vsim {*}$args}
proc run {args} {record run {*}$args}
proc quit {args} {record quit {*}$args}
source ${tclPath(path.join(dir,'run_modelsim.do'))}
close $log
`);let tclStatus='verified';
try { cp.execFileSync('tclsh',[harness]); } catch(e) { if(e.code!=='ENOENT')throw e;tclStatus='SKIP (tclsh not installed)'; }
if(tclStatus==='verified'){const recorded=fs.readFileSync(calls,'utf8');ok(recorded.includes('vlog -work work'));ok(recorded.includes('vlog -sv -work work'));ok(recorded.includes('vsim -onfinish stop work.digital_filter_tb'));ok(recorded.includes('run -all'));ok(recorded.includes('quit -force -code 0'));ok(recorded.includes('analogstudio runner checks '));
fs.writeFileSync(path.join(dir,'run_modelsim.do'),custom[1].content);cp.execFileSync('tclsh',[harness]);const customRecorded=fs.readFileSync(calls,'utf8');ok(customRecorded.includes('work.bench$custom'));ok(customRecorded.includes('design source.v'));ok(!customRecorded.includes('work.benchundefined'));}
console.log(`PASS simulation runner generation: ${checks} checks; ZIP CRC/extraction verified; Tcl syntax/quoting: ${tclStatus}. Windows batch and vendor HDL tools NOT executed. Fixture: ${archive}`);
