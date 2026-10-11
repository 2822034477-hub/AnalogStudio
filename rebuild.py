"""Rebuild the standalone HTML from the included baseline and source modules."""
from pathlib import Path
import argparse,hashlib,json,subprocess,sys
root=Path(__file__).resolve().parent
parser=argparse.ArgumentParser();parser.add_argument('--verify',action='store_true');args=parser.parse_args()
for script in ['branch-manager-patches.py','integrate-expanded.py']:
 subprocess.run([sys.executable,str(root/script)],cwd=root,check=True)
actual=hashlib.sha256((root/'AnalogStudio.html').read_bytes()).hexdigest()
print('AnalogStudio.html SHA-256:',actual)
if args.verify:
 manifest=json.loads((root/'delivery-manifest.json').read_text(encoding='utf-8'))
 if actual!=manifest['html_sha256']:
  raise SystemExit('Verification failed: rebuilt HTML differs from this release. If you intentionally changed source, rebuild without --verify.')
 print('Verified: rebuilt HTML exactly matches the included release.')
