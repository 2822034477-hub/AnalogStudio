param([Parameter(Mandatory=$true)][string]$VivadoBin)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
node tests\generate-module-hdl.cjs
if ($LASTEXITCODE -ne 0) { throw 'HDL generation failed' }
$caseDir = Join-Path $PSScriptRoot 'test-results\module-hdl'
Push-Location -LiteralPath $caseDir
try {
    & (Join-Path $VivadoBin 'xvlog.bat') --sv modules.v module_tb.sv *> compile.log
    if ($LASTEXITCODE -ne 0) { throw 'Compile failed; see test-results/module-hdl/compile.log' }
    & (Join-Path $VivadoBin 'xelab.bat') module_tb -s module_sim --timescale 1ns/1ps *> elaborate.log
    if ($LASTEXITCODE -ne 0) { throw 'Elaboration failed; see test-results/module-hdl/elaborate.log' }
    & (Join-Path $VivadoBin 'xsim.bat') module_sim -tclbatch run.tcl *> simulate.log
    $result = Get-Content -LiteralPath simulate.log -Raw
    if ($LASTEXITCODE -ne 0 -or $result -notmatch 'PASS: module arithmetic' -or $result -match 'Fatal:') { throw 'Simulation failed; see test-results/module-hdl/simulate.log' }
    Write-Output 'PASS XSim: signed/unsigned arithmetic, abs(-128), rounding/saturation, gain, registered timing, repeated saved filters, 4000-cycle DC feedback and reset.'
} finally { Pop-Location }
