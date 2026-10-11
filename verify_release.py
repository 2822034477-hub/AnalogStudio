"""Verify every release file without modifying it; optionally rebuild the HTML first."""
from pathlib import Path
import argparse, hashlib, json, subprocess, sys

root = Path(__file__).resolve().parent
parser = argparse.ArgumentParser()
parser.add_argument('--rebuild', action='store_true')
args = parser.parse_args()
if args.rebuild:
    subprocess.run([sys.executable, str(root/'rebuild.py'), '--verify'], cwd=root, check=True)
manifest = json.loads((root/'delivery-manifest.json').read_text(encoding='utf-8'))
errors=[]
for name, expected in manifest['files'].items():
    path=(root/name).resolve()
    if not path.is_relative_to(root) or not path.is_file():
        errors.append({'file':name,'error':'missing or unsafe path'})
        continue
    actual=hashlib.sha256(path.read_bytes()).hexdigest()
    if actual != expected: errors.append({'file':name,'actual':actual,'expected':expected})
print(json.dumps({'verified_files':len(manifest['files'])-len(errors),'errors':errors,'html_sha256':manifest['html_sha256']},indent=2))
raise SystemExit(1 if errors else 0)
