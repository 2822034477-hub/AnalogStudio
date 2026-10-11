"""Create the source ZIP reproducibly from the verified release manifest."""
from pathlib import Path
import argparse, json, subprocess, sys, zipfile, hashlib

root=Path(__file__).resolve().parent
parser=argparse.ArgumentParser()
parser.add_argument('--output',type=Path,default=root.parent/'AnalogStudio_Developer_20261011.zip')
args=parser.parse_args()
subprocess.run([sys.executable,str(root/'verify_release.py')],cwd=root,check=True)
manifest=json.loads((root/'delivery-manifest.json').read_text(encoding='utf-8'))
names=sorted([*manifest['files'],'delivery-manifest.json'])
output=args.output.resolve()
if output==root/'delivery-manifest.json' or output in {(root/n).resolve() for n in names}:
    raise SystemExit('Output must not overwrite a release source file.')
output.parent.mkdir(parents=True,exist_ok=True)
with zipfile.ZipFile(output,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as z:
    for name in names:
        info=zipfile.ZipInfo('AnalogStudio_Developer/'+name,date_time=(2026,10,11,0,0,0))
        info.create_system=3
        info.external_attr=0o100644 << 16
        info.compress_type=zipfile.ZIP_DEFLATED
        z.writestr(info,(root/name).read_bytes(),compresslevel=9)
print(json.dumps({'file':str(output),'bytes':output.stat().st_size,'sha256':hashlib.sha256(output.read_bytes()).hexdigest()},indent=2))
