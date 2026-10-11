"""Run generated Windows HDL self-checks with existing tools; never installs or changes licenses."""
from pathlib import Path
import argparse,json,os,subprocess,time,shutil
root=Path(__file__).resolve().parent
parser=argparse.ArgumentParser()
parser.add_argument('--modelsim-bin',type=Path)
parser.add_argument('--vivado-bin',type=Path)
parser.add_argument('--cases',nargs='+',default=['lowpass','saturation','notch','delay','fir','floor','wide','edited'])
args=parser.parse_args()
tools=[]
if args.modelsim_bin:tools.append(('modelsim',args.modelsim_bin))
if args.vivado_bin:tools.append(('xsim',args.vivado_bin))
if not tools:raise SystemExit('Specify --modelsim-bin and/or --vivado-bin for existing installations.')
out=root/'vendor-results';out.mkdir(exist_ok=True);results=[]
for case in args.cases:
 if case not in ['lowpass','saturation','notch','delay','fir','floor','wide','edited']:raise SystemExit('Unknown test case: '+case)
 for tool,binpath in tools:
  if not binpath.is_dir():raise SystemExit('Existing tool directory not found: '+str(binpath))
  env=os.environ.copy();env['PATH']=str(binpath)+';'+env['PATH'];cwd=root/'examples'/'simulation'/case
  command=['cmd.exe','/d','/c','run_'+tool+'.bat'];start=time.time()
  try:
   proc=subprocess.run(command,cwd=cwd,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=240)
   output=proc.stdout.decode('utf-8','replace');code=proc.returncode
  except subprocess.TimeoutExpired as exc:output=(exc.stdout or b'').decode('utf-8','replace')+'\nTIMEOUT';code=-1
  (out/(case+'-'+tool+'-wrapper.log')).write_text(output,encoding='utf-8')
  source=cwd/('modelsim_run.log' if tool=='modelsim' else 'analogstudio_xsim_build/xsim_run.log')
  raw=source.read_text(encoding='utf-8',errors='replace') if source.exists() else ''
  if source.exists():shutil.copy2(source,out/(case+'-'+tool+'.log'))
  marker='PASS: fixed-point vectors, valid gaps, reset'
  result={'case':case,'tool':tool,'tool_directory':str(binpath),'command':command,'return_code':code,'seconds':round(time.time()-start,2),'passed':code==0 and marker in raw}
  results.append(result);print(json.dumps(result),flush=True);(out/'results.json').write_text(json.dumps(results,indent=2),encoding='utf-8')
raise SystemExit(0 if all(r['passed'] for r in results) else 1)
