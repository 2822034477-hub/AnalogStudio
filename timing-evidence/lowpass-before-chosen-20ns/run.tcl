
set_param general.maxThreads 2
read_verilog {C:/Users/28220/Documents/ChatGPT/FPGA_/output/analogstudio-filter-retiming-local/timing-retiming/lowpass-before-chosen-20ns/digital_filter.v}
read_xdc timing.xdc
synth_design -top digital_filter -part xc7a50tfgg484-1 -mode out_of_context
opt_design
place_design
phys_opt_design
route_design
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -file timing_summary.rpt
report_timing -delay_type max -from [all_registers] -to [all_registers] -max_paths 10 -file internal_setup.rpt
report_timing -delay_type min -from [all_registers] -to [all_registers] -max_paths 10 -file internal_hold.rpt
report_utilization -file utilization_routed.rpt
report_route_status -file route_status.rpt
check_timing -verbose -file check_timing.rpt
set setup [get_timing_paths -delay_type max -max_paths 1 -from [all_registers] -to [all_registers]]
set hold [get_timing_paths -delay_type min -max_paths 1 -from [all_registers] -to [all_registers]]
set f [open metrics.tsv w]
foreach {prefix paths} [list setup $setup hold $hold] {
 foreach property {SLACK DATAPATH_DELAY LOGIC_LEVELS STARTPOINT_PIN ENDPOINT_PIN} {
  puts $f "$prefix.$property\t[get_property $property $paths]"
 }
}
close $f
write_checkpoint -force routed.dcp
exit
