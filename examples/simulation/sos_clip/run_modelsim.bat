@echo off
setlocal DisableDelayedExpansion
pushd "%~dp0" || exit /b 1
where vsim >nul 2>nul
if errorlevel 1 goto missing
if not exist "digital_filter.v" goto source_missing
if not exist "digital_filter_tb.sv" goto source_missing
vsim -c -do "do {run_modelsim.do}" > "modelsim_run.log" 2>&1
if errorlevel 1 goto failed
findstr /L /C:"PASS: four-port SOS, continuous samples, reset, latency" "modelsim_run.log" >nul
if errorlevel 1 goto failed
echo PASS: ModelSim / Questa completed the generated self-checking testbench.
echo See modelsim_run.log for this run.
popd
exit /b 0
:missing
echo ERROR: vsim is not on PATH. Use your existing ModelSim or Questa command prompt.
popd
exit /b 2
:source_missing
echo ERROR: Extract the entire ZIP into one directory before running.
popd
exit /b 2
:failed
echo FAIL: compile, simulation, or testbench PASS check failed.
type "modelsim_run.log"
popd
exit /b 1
