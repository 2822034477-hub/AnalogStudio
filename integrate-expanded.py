from pathlib import Path
p=Path(__file__).parent
s=(p/'AnalogStudio.folder-hierarchy.html').read_text(encoding='utf-8')
old=(p/'project-manager.folder-hierarchy.js').read_text(encoding='utf-8');assert s.count(old)==1
modules=['simulation-runners.js','digital-root-editor.js','digital-design.js','inverse-mixed.js','engineering-branches.js','project-manager.js']
s=s.replace(old,'\n'.join((p/f).read_text(encoding='utf-8') for f in modules),1)
for f in ['digital-design.css','inverse-mixed.css','engineering-branches.css']:
 s=s.replace('</style>','\n'+(p/f).read_text(encoding='utf-8')+'\n</style>',1)
(p/'AnalogStudio.html').write_text(s,encoding='utf-8',newline='\n')
print('Integrated expanded',len(s),'characters')
