@echo off
setlocal DisableDelayedExpansion
pushd "%~dp0" || exit /b 1
where xvlog >nul 2>nul
if errorlevel 1 goto missing
where xelab >nul 2>nul
if errorlevel 1 goto missing
where xsim >nul 2>nul
if errorlevel 1 goto missing
if not exist "digital_filter.v" goto source_missing
if not exist "digital_filter_tb.sv" goto source_missing
if not exist "analogstudio_xsim_build" mkdir "analogstudio_xsim_build"
if errorlevel 1 goto failed_root
pushd "analogstudio_xsim_build" || goto failed_root
rem CALL is required because Vivado Windows tool launchers may be .bat files.
call xvlog -work work "..\digital_filter.v" > "xsim_run.log" 2>&1
if errorlevel 1 goto failed
call xvlog -sv -work work "..\digital_filter_tb.sv" >> "xsim_run.log" 2>&1
if errorlevel 1 goto failed
call xelab "work.digital_filter_tb" -s analogstudio_snapshot >> "xsim_run.log" 2>&1
if errorlevel 1 goto failed
call xsim analogstudio_snapshot -tclbatch "../run_xsim.tcl" >> "xsim_run.log" 2>&1
if errorlevel 1 goto failed
findstr /L /C:"PASS: four-port SOS, continuous samples, reset, latency" "xsim_run.log" >nul
if errorlevel 1 goto failed
echo PASS: Vivado XSim completed the generated self-checking testbench.
echo See analogstudio_xsim_build\xsim_run.log for this run.
popd
popd
exit /b 0
:failed
echo FAIL: compile, elaboration, simulation, or testbench PASS check failed.
type "xsim_run.log"
popd
popd
exit /b 1
:failed_root
echo ERROR: Cannot create or enter simulation build directory.
popd
exit /b 1
:missing
echo ERROR: xvlog, xelab, or xsim is not on PATH. Use your existing Vivado command prompt.
popd
exit /b 2
:source_missing
echo ERROR: Extract the entire ZIP into one directory before running.
popd
exit /b 2
