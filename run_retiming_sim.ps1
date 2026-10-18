param([Parameter(Mandatory=$true)][string]$VivadoBin)
$ErrorActionPreference='Stop'
Set-Location -LiteralPath $PSScriptRoot
node tests\generate-retiming-equivalence.cjs
if ($LASTEXITCODE -ne 0) { throw 'Generation failed' }
Push-Location -LiteralPath 'test-results\retiming-equivalence'
try {
    & (Join-Path $VivadoBin 'xvlog.bat') --sv filters.v retiming_tb.sv *> compile.log
    if ($LASTEXITCODE -ne 0) { throw 'Compile failed' }
    & (Join-Path $VivadoBin 'xelab.bat') retiming_tb -s retiming_sim --timescale 1ns/1ps *> elaborate.log
    if ($LASTEXITCODE -ne 0) { throw 'Elaboration failed' }
    & (Join-Path $VivadoBin 'xsim.bat') retiming_sim -tclbatch run.tcl *> simulate.log
    if ($LASTEXITCODE -ne 0 -or (Get-Content -LiteralPath simulate.log -Raw) -notmatch 'PASS: retiming ') { throw 'Simulation failed' }
    Get-Content -LiteralPath simulate.log | Select-String 'PASS:'
} finally { Pop-Location }
