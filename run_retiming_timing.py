from pathlib import Path
import argparse,concurrent.futures,json,subprocess,hashlib,time,shutil
root=Path(__file__).resolve().parent
parser=argparse.ArgumentParser()
parser.add_argument('--vivado',type=Path,required=True)
parser.add_argument('--period',type=float,default=20)
parser.add_argument('--names',nargs='+',default=['fo','so','sos8'])
parser.add_argument('--variants',nargs='+',default=['before','after'])
parser.add_argument('--jobs',type=int,default=2)
parser.add_argument('--tag',default='')
args=parser.parse_args()
cases=json.loads((root/'timing-retiming/cases.json').read_text())
cases=[c for c in cases if c['name'] in args.names and c['variant'] in args.variants]
def run(case):
    tag='-'+args.tag if args.tag else ''
    folder=root/'timing-retiming'/f"{case['name']}-{case['variant']}{tag}-{args.period:g}ns"
    folder.mkdir(exist_ok=False)
    source=(root/'timing-retiming'/case['rtl']).resolve()
    rtl=folder/'digital_filter.v';shutil.copyfile(source,rtl)
    xdc=folder/'timing.xdc'
    xdc.write_text(f'create_clock -name sample_clk -period {args.period:g} [get_ports clk]\nset_clock_uncertainty -setup 0.200 [get_clocks sample_clk]\nset_clock_uncertainty -hold 0.050 [get_clocks sample_clk]\n')
    script=r'''
set_param general.maxThreads 2
read_verilog {@RTL@}
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
'''.replace('@RTL@',rtl.as_posix())
    (folder/'run.tcl').write_text(script)
    start=time.time()
    with (folder/'wrapper.log').open('wb') as log:
        proc=subprocess.run([str(args.vivado),'-mode','batch','-source','run.tcl','-notrace'],cwd=folder,stdout=log,stderr=subprocess.STDOUT,timeout=900)
    result={**case,'period_ns':args.period,'folder':str(folder.relative_to(root)),'return_code':proc.returncode,'seconds':round(time.time()-start,1),'rtl_sha256':hashlib.sha256(rtl.read_bytes()).hexdigest()}
    if (folder/'metrics.tsv').exists():result['paths']=dict(line.split('\t',1) for line in (folder/'metrics.tsv').read_text().splitlines())
    (folder/'result.json').write_text(json.dumps(result,indent=2))
    print(json.dumps({k:result.get(k) for k in ['name','variant','period_ns','return_code','seconds','paths']}),flush=True)
    return result
with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
    results=list(pool.map(run,cases))
(root/'timing-retiming'/f'results-{args.period:g}ns{args.tag}.json').write_text(json.dumps(results,indent=2))
raise SystemExit(0 if all(r['return_code']==0 and 'paths' in r for r in results) else 1)
