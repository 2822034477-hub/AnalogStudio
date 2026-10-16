# Generated for ModelSim / Questa. Run via run_modelsim.bat for PASS/exit checks.
onerror {quit -force -code 1}
# ModelSim do macros do not guarantee Tcl info script is the macro path.
# The Windows wrapper starts in the extracted source directory.
set source_dir [pwd]
set build_dir [file join $source_dir analogstudio_modelsim_build]
file mkdir $build_dir
cd $build_dir
if {![file isdirectory work]} {vlib work}
# Use a private mapping file; do not change the installed tool configuration.
vmap -c
vmap work work
vlog -work work [file join $source_dir {digital_filter.v}]
vlog -sv -work work [file join $source_dir {digital_filter_tb.sv}]
vsim -onfinish stop {work.digital_filter_tb}
run -all
# The Windows wrapper also requires the testbench PASS marker in this run log.
quit -force -code 0
