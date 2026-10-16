"""Run local Node tests. Does not install dependencies or download software."""
from pathlib import Path
import os,shutil,subprocess,sys,json,argparse
root=Path(__file__).resolve().parent
os.environ['ANALOG_TEST_PYTHON']=sys.executable
node=shutil.which('node')
if not node:raise SystemExit('Node.js is not installed/on PATH. Use Node 24.15+ (or compatible locked jsdom engine). No software was installed.')
parser=argparse.ArgumentParser();parser.add_argument('--allow-missing-dom',action='store_true');args=parser.parse_args()
missing_dom=not (root/'testdeps/node_modules/jsdom').exists()
if missing_dom and not args.allow_missing_dom:raise SystemExit('Test dependencies are absent. No software installed. Use --allow-missing-dom to run available tests and record explicit skips.')
logdir=root/'test-results';logdir.mkdir(exist_ok=True);results=[]
def run(path,label):
 text=path.read_text(encoding='utf-8')
 # These tests import jsdom directly or through a known full-application harness.
 needs_dom=any(t in text for t in ['node_modules/jsdom',"require('./projects.cjs')","require('./harness.cjs')","require('../tests/projects.cjs')"])
 if missing_dom and needs_dom:
  result={'test':label,'status':'SKIP','reason':'Existing jsdom dependency not installed; no installation authorized'};print(result,flush=True)
 else:
  proc=subprocess.run([node,str(path)],cwd=root,stdout=subprocess.PIPE,stderr=subprocess.STDOUT, timeout=60)
  output=proc.stdout.decode('utf-8','replace');(logdir/(label+'.log')).write_text(output,encoding='utf-8');print(output,flush=True)
  result={'test':label,'status':'PASS' if proc.returncode==0 else 'FAIL','return_code':proc.returncode}
 results.append(result)
 (logdir/'results.json').write_text(json.dumps(results,indent=2),encoding='utf-8')
tests=['numerical','dom','workspace','network-windows','plot-domains','projects','homepage','project-v2','blackbox-math','blackbox-projects','named-blackbox-save','folder-hierarchy','hierarchy','digital-design','digital-design-dom','digital-gain-placement','digital-root-math','digital-root-events','digital-sos','digital-latency','digital-display-timing','digital-magnitude','digital-layout','digital-rtl-arithmetic','digital-width','digital-project-migration','digital-unified-projects','inverse-mixed','inverse-mixed-races','inverse-mixed-drafts','audit-inverse-digital','expanded-projects','branch-races','branch-negative-flows','simulation-runners','build-consistency']
for name in tests:
 path=root/'tests'/f'{name}.cjs'
 if not path.exists():raise SystemExit('Missing test: '+str(path.name))
 print('\n== '+name+' ==',flush=True)
 run(path,name)
for name in ['integrated-qa','artifact-qa','import-race','export-controls','zip-export-qa']:
 path=root/'audit_expanded'/f'{name}.cjs'
 print('\n== independent '+name+' ==',flush=True)
 run(path,name)
print('Results:',{status:sum(r['status']==status for r in results) for status in ['PASS','FAIL','SKIP']})
print('Native browser UI/OS picker and vendor HDL simulation are separate checks.')
raise SystemExit(1 if any(r['status']=='FAIL' for r in results) else 2 if any(r['status']=='SKIP' for r in results) else 0)
