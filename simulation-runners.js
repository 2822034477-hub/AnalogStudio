/* AnalogStudio portable simulation export. No simulator is executed in the browser. */
(function(root){
'use strict';
const PASS='PASS: fixed-point vectors, valid gaps, reset';
const SOURCES=[
'https://docs.amd.com/r/2025.2-English/ug900-vivado-logic-simulation/xelab-xvhdl-and-xvlog-xsim-Command-Options',
'https://docs.amd.com/r/2023.2-English/ug900-vivado-logic-simulation/Using-a-tclbatch-File',
'https://www.intel.com/content/www/us/en/docs/programmable/691269/22-3-2-0-0/simulating-the-design-example-testbench.html',
'https://ww1.microchip.com/downloads/aemDocuments/documents/FPGA/swdocs/modelsim/modelsim_user_2024_2.pdf'
];
function identifier(value,label){if(typeof value!=='string'||!/^[A-Za-z_][A-Za-z0-9_$]{0,63}$/.test(value))throw Error('Invalid '+label+'.');return value;}
function filename(value,extension){if(typeof value!=='string'||value.length>100||!/^[A-Za-z0-9_][A-Za-z0-9_ .\-$]*$/.test(value)||value.includes('..')||value.endsWith(' ')||!value.toLowerCase().endsWith(extension)||/^(con|prn|aux|nul|com[1-9]|lpt[1-9])(?:\.|$)/i.test(value))throw Error('Unsafe simulation filename.');return value;}
function normalize(options={}){if(!options||typeof options!=='object'||Array.isArray(options))throw Error('Simulation options must be an object.');const moduleName=identifier(options.moduleName??'digital_filter','module name'),testbenchName=identifier(options.testbenchName??'digital_filter_tb','testbench name');if(moduleName===testbenchName)throw Error('DUT and testbench names must differ.');const rtlFilename=filename(options.rtlFilename??moduleName+'.v','.v'),testbenchFilename=filename(options.testbenchFilename??testbenchName+'.sv','.sv');const passMarker=options.passMarker??PASS;if(typeof passMarker!=='string'||passMarker.length>150||!/^[A-Za-z0-9 :,_().-]+$/.test(passMarker)||!passMarker.startsWith('PASS:'))throw Error('Invalid testbench pass marker.');return {moduleName,testbenchName,rtlFilename,testbenchFilename,passMarker};}
const file=(filename,content)=>({filename,content,mime:'text/plain;charset=utf-8'});
const bat=lines=>lines.join('\r\n')+'\r\n';
function generate(options={}){const o=normalize(options),{moduleName,testbenchName,rtlFilename,testbenchFilename,passMarker}=o;
const modelDo=[
'# Generated for ModelSim / Questa. Run via run_modelsim.bat for PASS/exit checks.',
'onerror {quit -force -code 1}',
'# ModelSim do macros do not guarantee Tcl info script is the macro path.',
'# The Windows wrapper starts in the extracted source directory.',
'set source_dir [pwd]',
'set build_dir [file join $source_dir analogstudio_modelsim_build]',
'file mkdir $build_dir','cd $build_dir',
'if {![file isdirectory work]} {vlib work}',
'# Use a private mapping file; do not change the installed tool configuration.',
'vmap -c','vmap work work',
'vlog -work work [file join $source_dir {'+rtlFilename+'}]',
'vlog -sv -work work [file join $source_dir {'+testbenchFilename+'}]',
'vsim -onfinish stop {work.'+testbenchName+'}',
'run -all',
'# The Windows wrapper also requires the testbench PASS marker in this run log.',
'quit -force -code 0',''].join('\n');
const modelBat=bat(['@echo off','setlocal DisableDelayedExpansion','pushd "%~dp0" || exit /b 1',
'where vsim >nul 2>nul','if errorlevel 1 goto missing',
'if not exist "'+rtlFilename+'" goto source_missing','if not exist "'+testbenchFilename+'" goto source_missing',
'vsim -c -do "do {run_modelsim.do}" > "modelsim_run.log" 2>&1','if errorlevel 1 goto failed',
'findstr /L /C:"'+passMarker+'" "modelsim_run.log" >nul','if errorlevel 1 goto failed',
'echo PASS: ModelSim / Questa completed the generated self-checking testbench.','echo See modelsim_run.log for this run.','popd','exit /b 0',
':missing','echo ERROR: vsim is not on PATH. Use your existing ModelSim or Questa command prompt.','popd','exit /b 2',
':source_missing','echo ERROR: Extract the entire ZIP into one directory before running.','popd','exit /b 2',
':failed','echo FAIL: compile, simulation, or testbench PASS check failed.','type "modelsim_run.log"','popd','exit /b 1']);
const xsimTcl='# Generated XSim batch commands. Compilation/elaboration are OS commands in run_xsim.bat.\nrun all\nquit\n';
const xsimBat=bat(['@echo off','setlocal DisableDelayedExpansion','pushd "%~dp0" || exit /b 1',
'where xvlog >nul 2>nul','if errorlevel 1 goto missing','where xelab >nul 2>nul','if errorlevel 1 goto missing','where xsim >nul 2>nul','if errorlevel 1 goto missing',
'if not exist "'+rtlFilename+'" goto source_missing','if not exist "'+testbenchFilename+'" goto source_missing',
'if not exist "analogstudio_xsim_build" mkdir "analogstudio_xsim_build"','if errorlevel 1 goto failed_root','pushd "analogstudio_xsim_build" || goto failed_root',
'rem CALL is required because Vivado Windows tool launchers may be .bat files.',
'call xvlog -work work "..\\'+rtlFilename+'" > "xsim_run.log" 2>&1','if errorlevel 1 goto failed',
'call xvlog -sv -work work "..\\'+testbenchFilename+'" >> "xsim_run.log" 2>&1','if errorlevel 1 goto failed',
'call xelab "work.'+testbenchName+'" -s analogstudio_snapshot >> "xsim_run.log" 2>&1','if errorlevel 1 goto failed',
'call xsim analogstudio_snapshot -tclbatch "../run_xsim.tcl" >> "xsim_run.log" 2>&1','if errorlevel 1 goto failed',
'findstr /L /C:"'+passMarker+'" "xsim_run.log" >nul','if errorlevel 1 goto failed',
'echo PASS: Vivado XSim completed the generated self-checking testbench.','echo See analogstudio_xsim_build\\xsim_run.log for this run.','popd','popd','exit /b 0',
':failed','echo FAIL: compile, elaboration, simulation, or testbench PASS check failed.','type "xsim_run.log"','popd','popd','exit /b 1',
':failed_root','echo ERROR: Cannot create or enter simulation build directory.','popd','exit /b 1',
':missing','echo ERROR: xvlog, xelab, or xsim is not on PATH. Use your existing Vivado command prompt.','popd','exit /b 2',
':source_missing','echo ERROR: Extract the entire ZIP into one directory before running.','popd','exit /b 2']);
const readme=[
'AnalogStudio 数字滤波器：本地仿真 / Codex 任务说明',
'================================================',
'', '此包只是生成的源码与运行脚本，不代表已在 ModelSim、Questa 或 Vivado 中仿真通过。',
'浏览器不会调用本机 EDA 软件；只有本机真正运行后，才能给出仿真结果。',
'', '文件与接口',
'- RTL：'+rtlFilename+'；顶层模块：'+moduleName,
'- 自检 testbench：'+testbenchFilename+'；顶层：'+testbenchName,
'- 时钟 10 ns；同步高有效复位；in_valid=1 的上升沿接收输入。',
'- 输出在该沿之后更新；无效周期保持数据并拉低 out_valid。',
'- TB 在下降沿驱动，在上升沿后 1 ns 检查，避免与非阻塞赋值竞争。',
'- 黄金输出来自导出模型的定点整数参考：包含满量程输入、符号、有效间隙和复位。',
'- 是否真正发生输出饱和取决于此模型的系数与位宽；不能把满量程输入等同于饱和覆盖。',
'', 'Windows 运行',
'1. 完整解压到一个可写目录，保持所有文件在同一级；不要直接在 ZIP 预览窗口中运行。',
'2. 使用已安装、已有合法许可的工具命令行。不会自动安装软件、修改许可或索取凭据。',
'3. ModelSim / Questa：确认 vsim 可用后，运行 run_modelsim.bat。',
'   日志：modelsim_run.log；编译库：analogstudio_modelsim_build。',
'4. Vivado XSim：使用现有 Vivado 命令提示符，确认 xvlog、xelab、xsim 可用，运行 run_xsim.bat。',
'   日志：analogstudio_xsim_build\\xsim_run.log；中间文件保存在该目录。',
'5. 通过条件：脚本退出码为 0，且本轮日志含以下精确文本：',
'   '+passMarker,
'   非零退出码、找不到 PASS、编译/展开失败或任一 mismatch 都不能报告通过。',
'   启动失败时日志可能尚未生成；请保留命令行错误。',
'6. 脚本复用专用构建目录并覆盖本轮日志；请勿在该目录放手工源码。并行运行请用不同解压目录。',
'', '交给本地 Codex 的任务（在解压目录中打开任务）',
'请先只读确认本机可用的 ModelSim/Questa 或 Vivado/XSim 路径与版本。',
'仅使用现有工具运行本包对应 .bat；不要安装工具、改变许可/权限或访问无关文件。',
'记录实际命令、工具版本、编译/展开/运行退出码及日志中的 PASS/FAIL。',
'如果工具不存在、不可用或许可受限，请准确报告阻塞，不要用浏览器/JavaScript 结果冒充 HDL 仿真。',
'若需改动，先说明问题；保留原源码与改动 diff，并在重新运行后附日志。',
'最终回复：实际仿真器与版本、测试模块、通过/失败/未运行、日志路径、发现的问题。',
'', '验证范围',
'这是 RTL 行为仿真，不等同于综合、时序收敛、FPGA 资源评估、CDC 或实物验证。',
'本包仅针对导出的模型；不是全部可能系数/位宽组合的形式验证。',
'无需 FPGA 器件库：导出 RTL 仅使用通用寄存器、算术及控制逻辑。',
'', '命令依据与版本说明',
'命令形式依据 AMD UG900 2025.2 / 2023.2，以及官方 ModelSim 文档和 Intel 示例。',
'尚未声称在任一厂商/版本上实测；本机以已安装版本的帮助及实际日志为准。',
...SOURCES,''].join('\r\n');
return [file('run_modelsim.bat',modelBat),file('run_modelsim.do',modelDo),file('run_xsim.bat',xsimBat),file('run_xsim.tcl',xsimTcl),file('SIMULATION_README.txt',readme)];
}
const encoder=new TextEncoder();
function crc32(bytes){let c=0xffffffff;for(const b of bytes){c^=b;for(let j=0;j<8;j++)c=(c>>>1)^((c&1)?0xedb88320:0);}return (c^0xffffffff)>>>0;}
function zip(files){if(!Array.isArray(files)||files.length>32)throw Error('Invalid ZIP file list.');let offset=0,centralSize=0;const items=[],seen=new Set();for(const f of files){if(!f||typeof f.filename!=='string'||!/^[A-Za-z0-9_][A-Za-z0-9_ .\-$]*$/.test(f.filename)||f.filename.includes('..')||seen.has(f.filename.toLowerCase()))throw Error('Unsafe or duplicate ZIP filename.');seen.add(f.filename.toLowerCase());const name=encoder.encode(f.filename),data=typeof f.content==='string'?encoder.encode(f.content):f.content;if(!(data instanceof Uint8Array)||data.length>4*1024*1024)throw Error('Invalid or oversized ZIP content.');items.push({name,data,crc:crc32(data),offset});offset+=30+name.length+data.length;centralSize+=46+name.length;}if(offset>16*1024*1024)throw Error('Simulation ZIP exceeds 16 MB.');const bytes=new Uint8Array(offset+centralSize+22),view=new DataView(bytes.buffer);const w16=(p,v)=>view.setUint16(p,v,true),w32=(p,v)=>view.setUint32(p,v,true);let p=0;for(const f of items){w32(p,0x04034b50);w16(p+4,20);w16(p+6,0x800);w16(p+12,33);w32(p+14,f.crc);w32(p+18,f.data.length);w32(p+22,f.data.length);w16(p+26,f.name.length);bytes.set(f.name,p+30);bytes.set(f.data,p+30+f.name.length);p+=30+f.name.length+f.data.length;}const centralOffset=p;for(const f of items){w32(p,0x02014b50);w16(p+4,20);w16(p+6,20);w16(p+8,0x800);w16(p+14,33);w32(p+16,f.crc);w32(p+20,f.data.length);w32(p+24,f.data.length);w16(p+28,f.name.length);w32(p+42,f.offset);bytes.set(f.name,p+46);p+=46+f.name.length;}w32(p,0x06054b50);w16(p+8,items.length);w16(p+10,items.length);w32(p+12,centralSize);w32(p+16,centralOffset);return bytes;}
function bundle(options={}){const o=normalize(options);if(typeof options.rtl!=='string'||!options.rtl.trim()||typeof options.testbench!=='string'||!options.testbench.trim())throw Error('Generated RTL and testbench are required.');const files=[file(o.rtlFilename,options.rtl),file(o.testbenchFilename,options.testbench),...generate(o)];return {filename:'AnalogStudio_Simulation.zip',content:zip(files),mime:'application/zip'};}
const api={generate,bundle,zip,normalize,PASS,SOURCES:SOURCES.slice()};root.AnalogSimulationRunners=api;if(typeof module!=='undefined'&&module.exports)module.exports=api;
})(typeof window!=='undefined'?window:globalThis);
