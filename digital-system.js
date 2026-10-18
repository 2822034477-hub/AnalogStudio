/* Saved-design authoring, reversible system edits and diagram clipboard. */
(function(root){
'use strict';
const M=root.DigitalModules,L=root.DigitalSystemLayout,copy=x=>JSON.parse(JSON.stringify(x)),esc=x=>String(x).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const STORE='analog-studio.digital-modules.v1',same=(a,b)=>a.moduleName===b.moduleName&&a.verilog===b.verilog;
function attach(container,options={}){
 const doc=container.ownerDocument,nav=doc.createElement('nav'),host=doc.createElement('section'),filterSave=doc.createElement('div');
 nav.className='ds-nav';nav.setAttribute('aria-label','数字设计工作区');
 nav.innerHTML='<button type="button" data-ds-tab="filter">滤波器设计</button><button type="button" data-ds-tab="module">基础模块设计</button><button type="button" data-ds-tab="system">系统工作台</button><span class="ds-history"><button type="button" data-ds="undo" disabled>撤销</button><button type="button" data-ds="redo" disabled>重做</button></span>';
 host.className='ds-host';filterSave.className='ds-filter-save';
 filterSave.innerHTML='<label>Verilog 模块名<input data-ds="filter-name" value="digital_filter" maxlength="64"></label><button type="button" data-ds="save-filter">保存当前滤波器设计</button><button type="button" class="dd-primary" data-ds="filter-to-system">保存并导入系统工作台</button><span>配置、接口与 Verilog 一起保存；导入后填写系统端口并连接。</span>';
 const header=container.querySelector('.dd-header');header.querySelector('h2').textContent='数字系统设计平台';header.querySelector('p').textContent='独立模块设计 · 保存并组合 · Verilog 生成';header.after(nav);nav.after(filterSave);filterSave.after(host);
 const canvasId=root.DigitalSystemCanvas.newId();
 let state=M.empty(),draft=M.defaults(),catalog=[],revision=0,disposed=false,choosing=null,canvasView=null,selected=null,clipboard=null,menu=null,menuPoint=null,importName='digital_filter';
 const undo=[],redo=[],$=k=>host.querySelector('[data-ds="'+k+'"]');
 function readLibrary(){const values=JSON.parse(root.localStorage.getItem(STORE)||'[]');if(!Array.isArray(values)||values.length>40)throw Error('浏览器模块库无效，原数据未覆盖。');return values.map(M.load);}
 function stored(){try{return readLibrary();}catch{return [];}}
 function refreshCatalog(){catalog=state.modules.map(m=>m.design);for(const p of stored())if(!catalog.some(v=>same(v,p)))catalog.push(p);}
 function notify(text,error=false){const el=$('notice');if(!el)return;el.textContent=text;el.className=error?'ds-notice ds-error':'ds-notice';el.setAttribute('role',error?'alert':'status');}
 function emit(){revision++;options.onChange?.();}
 function updateHistory(){for(const [key,stack]of [['undo',undo],['redo',redo]]){const button=nav.querySelector('[data-ds="'+key+'"]');button.disabled=!stack.length;button.title=(key==='undo'?'撤销':'重做')+(stack.length?'：'+stack.at(-1).label:'')+(key==='undo'?'（Ctrl+Z）':'（Ctrl+Shift+Z / Ctrl+Y）');}}
 function put(p,next){p=M.load(p);let entry=next.modules.find(m=>same(m.design,p));if(!entry){if(next.modules.length>=40)throw Error('当前工程最多保存 40 个模块设计。');let n=1;while(next.modules.some(m=>m.key==='m'+n))n++;entry={key:'m'+n,design:p};next.modules.push(entry);}return entry;}
 function nextId(base=null){if(base!==null){let n=2,id;do{const suffix='_'+n++;id=base.slice(0,64-suffix.length)+suffix;}while(state.instances.some(i=>i.id===id));return M.id(id);}let n=1;while(state.instances.some(i=>i.id==='u'+n))n++;return 'u'+n;}
 function validSelection(value,next=state){if(!value)return null;if(value.kind==='wire')return next.connections.some(c=>c.from===value.from&&c.to===value.to)?copy(value):null;return next.instances.some(n=>n.id===value.id)||next.ports.some(p=>(p.direction==='input'?'in:':'out:')+p.name===value.id)?copy(value):null;}
 function captureDraft(){if(state.view==='module')try{draft=readDraft();}catch{}}
 function libraryEdit(transform,required){
  if(!transform)return {patch:null,warning:''};
  try{const before=readLibrary(),after=transform(copy(before));if(JSON.stringify(before)===JSON.stringify(after))return {patch:null,warning:''};
   root.localStorage.setItem(STORE,JSON.stringify(after));const names=[...new Set([...before,...after].map(p=>p.moduleName))].filter(name=>JSON.stringify(before.filter(p=>p.moduleName===name))!==JSON.stringify(after.filter(p=>p.moduleName===name)));
   return {patch:{names,before:before.filter(p=>names.includes(p.moduleName)),after:after.filter(p=>names.includes(p.moduleName))},warning:''};
  }catch(error){if(required)throw Error('删除未完成：无法更新浏览器模块库，工程保持原样。'+error.message);return {patch:null,warning:' 浏览器模块库未更新，请保存工程或导出设计包。'};}
 }
 function replayLibrary(patch,back){
  if(!patch)return '';try{let values=readLibrary();const expected=back?patch.after:patch.before,target=back?patch.before:patch.after;let changed=false,conflict=false;
   for(const name of patch.names){if(JSON.stringify(values.filter(p=>p.moduleName===name))!==JSON.stringify(expected.filter(p=>p.moduleName===name))){conflict=true;continue;}values=values.filter(p=>p.moduleName!==name).concat(target.filter(p=>p.moduleName===name));changed=true;}
   if(values.length>40)throw Error('模块库容量不足。');if(changed)root.localStorage.setItem(STORE,JSON.stringify(values));return conflict?' 模块库存在后续修改，已保留；当前工程已恢复。':'';
  }catch{return ' 当前工程已恢复，浏览器模块库未能同步恢复，请保存工程。';}
 }
 function change(label,edit,settings={}){
  canvasView?.cancel();closeMenu();captureDraft();const before=copy(state),beforeDraft=copy(draft),beforeSelection=copy(selected);
  let next=copy(state);next=edit(next)||next;next=M.validateState(next);
  const library=libraryEdit(settings.library,settings.libraryRequired);
  const nextSelection=validSelection(settings.selection===undefined?selected:settings.selection,next);
  if(JSON.stringify(before)===JSON.stringify(next)&&!library.patch)return false;
  state=next;selected=nextSelection;if(settings.draft)draft=copy(settings.draft);
  const entry={label,before,after:copy(state),beforeDraft,afterDraft:copy(draft),beforeSelection,afterSelection:copy(selected),library:library.patch};entry.bytes=JSON.stringify(entry).length;
  undo.push(entry);redo.length=0;while(undo.length>50||undo.length>1&&undo.reduce((n,e)=>n+e.bytes,0)>8000000)undo.shift();
  if(settings.render!==false)render();else{updateHistory();updateSelection();}emit();notify(label+'。'+library.warning);return true;
 }
 function travel(back){const from=back?undo:redo,to=back?redo:undo;if(!from.length)return;canvasView?.cancel();closeMenu();const entry=from.at(-1),next=M.validateState(back?entry.before:entry.after),warning=replayLibrary(entry.library,back);from.pop();to.push(entry);state=next;draft=copy(back?entry.beforeDraft:entry.afterDraft);selected=validSelection(back?entry.beforeSelection:entry.afterSelection);render();emit();notify((back?'已撤销：':'已重做：')+entry.label+'。'+warning);}
 const persist=p=>values=>values.filter(v=>v.moduleName!==p.moduleName).concat(p).slice(-40);
 function save(p,importIntoSystem=false){p=M.load(p);const id=importIntoSystem?nextId():null;change(importIntoSystem?'保存并导入 '+p.moduleName:'保存 '+p.moduleName,next=>{const key=put(p,next).key;if(id){next.instances.push({id,moduleKey:key});next.view='system';}}, {library:persist(p),draft:p.kind==='filter'?undefined:p.config,selection:id?{kind:'node',id}:undefined});if($('source'))$('source').textContent=p.verilog;}
 function addInstance(p,id=nextId(),point){p=M.load(p);change('导入实例 '+id,next=>{const key=put(p,next).key;next.instances.push({id:M.id(id),moduleKey:key});next.view='system';if(point){next.layout=L.capture(L.build(next).boxes);next.layout[id]={x:Math.max(24,Math.min(20000,Math.round(point.x))),y:Math.max(24,Math.min(20000,Math.round(point.y))),w:point.w||330,h:point.h||128};next.layout=L.capture(L.build(next).boxes);}}, {selection:{kind:'node',id}});}
 function removeInstance(next,id){if(next.layout)delete next.layout[id];next.instances=next.instances.filter(n=>n.id!==id);next.connections=next.connections.filter(c=>!c.from.startsWith(id+':')&&!c.to.startsWith(id+':'));}
 function removePort(next,key){if(next.layout)delete next.layout[key];next.ports=next.ports.filter(p=>(p.direction==='input'?'in:':'out:')+p.name!==key);next.connections=next.connections.filter(c=>c.from!==key&&c.to!==key);}
 function deleteSelected(){if(!selected)return;const item=copy(selected);if(item.kind==='wire')change('删除连线 '+item.from+' → '+item.to,next=>{next.connections=next.connections.filter(c=>c.from!==item.from||c.to!==item.to);},{selection:null});else change('删除 '+item.id,next=>{if(item.id.includes(':'))removePort(next,item.id);else removeInstance(next,item.id);},{selection:null});}
 function deleteDesign(p){const entries=state.modules.filter(m=>same(m.design,p)),keys=new Set(entries.map(m=>m.key)),count=state.instances.filter(n=>keys.has(n.moduleKey)).length;
  change('删除设计 '+p.moduleName+(count?'及 '+count+' 个实例':''),next=>{for(const n of next.instances.filter(n=>keys.has(n.moduleKey)))removeInstance(next,n.id);next.modules=next.modules.filter(m=>!same(m.design,p));},{library:values=>values.filter(v=>!same(v,p)),libraryRequired:true});
 }
 function updateSelection(){const label=$('selection'),button=$('delete-selected');if(label)label.textContent=selected?(selected.kind==='wire'?'已选连线：'+selected.from+' → '+selected.to:'已选模块 / 端口：'+selected.id):'点击模块或连线选择；Delete 删除，Ctrl+Z 撤销';if(button)button.disabled=!selected;}
 function select(value){selected=validSelection(value);updateSelection();}
 function copySelected(){if(selected?.kind!=='node')return;const node=state.instances.find(n=>n.id===selected.id);if(!node)return;const box=L.build(state).boxes.find(b=>b.id===node.id);clipboard={id:node.id,design:copy(state.modules.find(m=>m.key===node.moduleKey).design),x:box.x,y:box.y,w:box.w,h:box.h};notify('已复制 '+node.id+'；在画布空白处右键粘贴，实例名默认追加 _2。');}
 function paste(point){if(!clipboard)return;const p=clipboard;addInstance(p.design,nextId(p.id),{x:point?.x??p.x+40,y:point?.y??p.y+40,w:p.w,h:p.h});}
 function closeMenu(){if(menu){menu.remove();menu=null;}}
 function openMenu(value,event,point){closeMenu();select(value);menuPoint=point;menu=doc.createElement('div');menu.className='ds-context-menu';menu.setAttribute('role','menu');menu.setAttribute('aria-label','系统图操作');
  const module=value?.kind==='node'&&state.instances.some(n=>n.id===value.id);
  menu.innerHTML=(module?'<button type="button" role="menuitem" data-context="copy">复制</button>':'')+(value?'<button type="button" role="menuitem" data-context="delete">删除</button>':'<button type="button" role="menuitem" data-context="paste"'+(!clipboard?' disabled':'')+'>粘贴</button>');
  menu.style.left=Math.max(0,Math.min(event.clientX,(root.innerWidth||1200)-190))+'px';menu.style.top=Math.max(0,Math.min(event.clientY,(root.innerHeight||800)-100))+'px';doc.body.append(menu);
  menu.addEventListener('click',e=>{const action=e.target.closest('[data-context]')?.dataset.context;if(!action)return;act(()=>{if(action==='copy'){copySelected();closeMenu();}if(action==='delete')deleteSelected();if(action==='paste')paste(menuPoint);});});menu.querySelector('button:not(:disabled)')?.focus({preventScroll:true});
 }
 const numeric=(el,label)=>{if(!el.value.trim())throw Error(label+' 不能为空。');const x=Number(el.value);if(!Number.isFinite(x))throw Error(label+' 不是有效数字。');return x;};
 function formatFields(p,key){return '<label>位宽<input type="number" min="1" max="128" data-ds-field="'+key+'.width" value="'+p.width+'"></label><label>符号<select data-ds-field="'+key+'.signed"><option value="true"'+(p.signed?' selected':'')+'>signed</option><option value="false"'+(!p.signed?' selected':'')+'>unsigned</option></select></label><label>小数位 F<input type="number" min="0" max="127" data-ds-field="'+key+'.fraction" value="'+p.fraction+'"></label>';}
 function readDraft(){const c=copy(draft);c.kind=$('kind').value;c.moduleName=$('module-name').value;c.timing=$('timing').value;for(const field of host.querySelectorAll('[data-ds-field]')){const keys=field.dataset.dsField.split('.');let target=c;for(const k of keys.slice(0,-1))target=target[k];const k=keys.at(-1);target[k]=k==='signed'?field.value==='true':numeric(field,k);}c.params.rounding=$('rounding').value;c.params.overflow=$('overflow').value;return M.config(c);}
 function endpoints(source){const out=[];for(const p of state.ports.filter(p=>p.direction===(source?'input':'output')))out.push({key:(source?'in:':'out:')+p.name,p,label:'系统 '+p.name});for(const n of state.instances){const d=state.modules.find(m=>m.key===n.moduleKey).design;for(const p of d.ports.filter(p=>p.direction===(source?'output':'input')))out.push({key:n.id+':'+p.name,p,label:n.id+'.'+p.name});}return out;}
 function refreshDest(){const selected=$('to').value,a=endpoints(true).find(e=>e.key===$('from').value);$('to').innerHTML='<option value="">选择接收端</option>'+endpoints(false).map(e=>{const occupied=state.connections.some(c=>c.to===e.key),ok=a&&M.match(a.p,e.p)&&!occupied;return '<option value="'+esc(e.key)+'"'+(!ok?' disabled':'')+'>'+esc(e.label+' · '+M.describe(e.p)+(occupied?' · 已连接':!ok?' · 格式不同':''))+'</option>';}).join('');if([...$('to').options].some(o=>o.value===selected&&!o.disabled))$('to').value=selected;}
 function libraryCard(p,i){const keys=new Set(state.modules.filter(m=>same(m.design,p)).map(m=>m.key)),count=state.instances.filter(n=>keys.has(n.moduleKey)).length;return `<article><div><strong>${esc(p.moduleName)}</strong><p>${esc(M.types[p.kind]+' · '+p.latency+'拍')}</p><small>${p.ports.map(x=>esc(x.name+': '+M.describe(x))).join('<br>')}</small></div><div class="ds-actions"><button type="button" data-import-design="${i}">导入工作台</button><button type="button" data-edit="${i}">编辑配置</button><button type="button" data-export-package="${i}">导出设计 JSON</button><button type="button" data-export-v="${i}">导出 .v</button><button type="button" data-export-zip="${i}">配置 + Verilog ZIP</button><button type="button" class="ds-delete" data-delete-design="${i}">${count?'删除设计及 '+count+' 个实例':'删除设计'}</button></div></article>`;}
 function render(){
  closeMenu();canvasView?.destroy();canvasView=null;refreshCatalog();selected=validSelection(selected);container.dataset.dsView=state.view;host.hidden=false;filterSave.hidden=state.view!=='filter';
  for(const b of nav.querySelectorAll('[data-ds-tab]')){b.classList.toggle('active',b.dataset.dsTab===state.view);b.setAttribute('aria-pressed',String(b.dataset.dsTab===state.view));}updateHistory();
  host.innerHTML=`<p data-ds="notice" class="ds-notice" role="status"></p>
  <section data-ds="module-panel"${state.view!=='module'?' hidden':''}>
   <div class="ds-heading"><div><h3>独立模块设计</h3><p>定义接口与参数，保存后即可导入系统。</p></div><button type="button" data-ds="import-file">导入模块设计包</button></div>
   <div class="ds-grid"><section class="ds-card"><div class="ds-fields">
    <label>模块类型<select data-ds="kind">${Object.entries(M.types).filter(([k])=>k!=='filter').map(([k,v])=>'<option value="'+k+'"'+(k===draft.kind?' selected':'')+'>'+v+'</option>').join('')}</select></label>
    <label>Verilog 模块名<input data-ds="module-name" value="${esc(draft.moduleName)}" maxlength="64"></label>
    <label>实现形式<select data-ds="timing"${draft.kind==='integrator'?' disabled':''}><option value="combinational"${draft.timing==='combinational'?' selected':''}>组合逻辑 · 0 拍</option><option value="registered"${draft.timing==='registered'?' selected':''}>寄存输出 · 1 拍</option></select></label></div>
    ${draft.inputs.map((p,i)=>'<fieldset><legend>输入 '+esc(p.name)+'</legend><div class="ds-fields">'+formatFields(p,'inputs.'+i)+'</div></fieldset>').join('')}
    <fieldset><legend>输出 ${esc(draft.output.name)}</legend><div class="ds-fields">${formatFields(draft.output,'output')}</div></fieldset><div class="ds-fields">
    ${draft.kind==='gain'?'<label>增益整数<input type="number" data-ds-field="params.gainInteger" value="'+draft.params.gainInteger+'"></label><label>增益小数位<input type="number" data-ds-field="params.gainFraction" value="'+draft.params.gainFraction+'"></label>':''}
    ${draft.kind==='integrator'?'<label>积分步长 μ = 2⁻ˢ<input type="number" min="0" max="127" data-ds-field="params.stepShift" value="'+draft.params.stepShift+'"></label>':''}
    <label>舍入<select data-ds="rounding"><option value="floor"${draft.params.rounding==='floor'?' selected':''}>向负无穷取整</option><option value="nearest"${draft.params.rounding==='nearest'?' selected':''}>最近值，半值远离零</option></select></label>
    <label>超范围处理<select data-ds="overflow"><option value="wrap"${draft.params.overflow==='wrap'?' selected':''}>按输出位宽取位</option><option value="saturate"${draft.params.overflow==='saturate'?' selected':''}>饱和</option></select></label></div>
    <p class="ds-help">接口由你定义；系统仅连接位宽、符号和小数位完全相同的接口。寄存输出统一使用 clk 和同步低有效 rst_n。</p>
    <div class="ds-actions"><button type="button" class="dd-primary" data-ds="save-module">保存模块设计</button><button type="button" data-ds="preview">预览 Verilog</button></div></section>
    <section class="ds-card"><h4>对应 Verilog</h4><pre data-ds="source" class="ds-source">先设计模块，再预览或保存。</pre></section></div>
  </section>
  <section data-ds="system-panel"${state.view!=='system'?' hidden':''}>
   <div class="ds-heading"><div><h3>数字系统工作台</h3><p>从已保存设计导入；模块名保持不变，多次使用生成独立实例。</p></div><div class="ds-actions"><button type="button" data-ds="import-file">导入设计 / 系统 JSON</button><button type="button" data-ds="export-system-json">导出系统配置</button><button type="button" data-ds="export-system">生成系统 Verilog</button></div></div>
   <div class="ds-card ds-fields"><label>滤波器 JSON 的 Verilog 模块名<input data-ds="import-filter-name" value="${esc(importName)}" maxlength="64"></label><button type="button" data-ds="import-filter-file">导入滤波器模型 JSON</button><span class="ds-help">支持滤波器页导出的模型 JSON，保存为模块后自动加入工作台。</span></div>
   <div class="ds-fields ds-card"><label>系统顶层模块名<input data-ds="top-name" value="${esc(state.topName)}"></label><label>已保存模块<select data-ds="saved-select"><option value="">选择一个已有设计</option>${catalog.map((p,i)=>'<option value="'+i+'">'+esc(p.moduleName+' · '+M.types[p.kind]+' · '+p.latency+'拍')+'</option>').join('')}</select></label><label>实例名<input data-ds="instance-name" value="${nextId()}"></label><button type="button" data-ds="add-instance">导入到工作台</button></div>
   <div class="ds-grid"><section class="ds-card"><h4>系统端口</h4><div class="ds-fields"><label>名称<input data-ds="port-name" value="x"></label><label>方向<select data-ds="port-direction"><option value="input">input</option><option value="output">output</option></select></label><label>位宽<input type="number" data-ds="port-width" value="16"></label><label>符号<select data-ds="port-signed"><option value="true">signed</option><option value="false">unsigned</option></select></label><label>小数位 F<input type="number" data-ds="port-fraction" value="8"></label><button type="button" data-ds="add-port">添加端口</button></div>
   <ul class="ds-list">${state.ports.map((p,i)=>'<li><span>'+esc(p.direction+' '+p.name+' · '+M.describe(p))+'</span><button type="button" data-remove-port="'+i+'">删除</button></li>').join('')}</ul></section>
   <section class="ds-card"><h4>连接</h4><label>驱动端<select data-ds="from"><option value="">选择驱动端</option>${endpoints(true).map(e=>'<option value="'+esc(e.key)+'">'+esc(e.label+' · '+M.describe(e.p))+'</option>').join('')}</select></label><label>接收端<select data-ds="to"><option value="">先选择驱动端</option></select></label><button type="button" data-ds="connect">连接相同接口</button><ul class="ds-list">${state.connections.map((c,i)=>'<li><code>'+esc(c.from+' → '+c.to)+'</code><button type="button" data-remove-link="'+i+'">断开</button></li>').join('')}</ul></section></div>
   <div class="ds-diagram-tools"><span>拖动 / 缩放 · 右键复制 / 粘贴 · Delete 删除 · Ctrl+Z 撤销</span><button type="button" data-ds="reset-layout">重新排列</button></div>
   <div class="ds-selection"><span data-ds="selection"></span><button type="button" data-ds="delete-selected" disabled>删除选中项</button></div>
   <section class="ds-card ds-diagram" data-ds="diagram" tabindex="0">${root.DigitalSystemCanvas.markup(state,undefined,canvasId,selected)}</section>
   <ul class="ds-list">${state.instances.map(n=>{const p=state.modules.find(m=>m.key===n.moduleKey).design;return '<li><span><strong>'+esc(n.id)+'</strong> · '+esc(p.moduleName)+' · '+p.latency+'拍</span><button type="button" data-remove-instance="'+esc(n.id)+'">删除实例</button></li>';}).join('')}</ul><pre data-ds="system-source" class="ds-source" hidden></pre>
  </section>
  <details class="ds-card ds-library"${state.view!=='filter'?' open':''}><summary>已保存模块设计（${catalog.length}）</summary><p>每个设计包含配置、接口和 Verilog。删除已使用的设计也会移除当前系统的对应实例与连线，可撤销恢复。</p><div class="ds-library-list">${catalog.map(libraryCard).join('')||'<p class="ds-empty">尚无模块。先保存基础模块，或在滤波器页保存并导入。</p>'}</div></details>
  <input type="file" data-ds="file" accept=".json,application/json" hidden>`;
  $('from').addEventListener('change',refreshDest);$('kind').addEventListener('change',()=>{draft=M.defaults($('kind').value);render();});
  $('top-name').addEventListener('change',()=>act(()=>change('修改顶层名称',next=>{next.topName=M.id($('top-name').value);},{render:false})));
  $('import-filter-name').addEventListener('input',()=>{importName=$('import-filter-name').value;});$('file').addEventListener('change',readFile);
  canvasView=root.DigitalSystemCanvas.mount($('diagram'),{id:canvasId,getState:()=>state,getSelection:()=>selected,isActive:()=>state.view==='system'&&options.isActive?.()!==false,onSelect:select,onContextMenu:openMenu,onCommit(layout){change(layout?'调整画布布局':'重新排列',next=>{if(layout)next.layout=layout;else delete next.layout;},{render:false});}});updateSelection();
 }
 function act(fn){try{fn();}catch(error){notify(error.message,true);}}
 function send(filename,content,mime='text/plain'){return Promise.resolve(options.onDownload(filename,content,mime)).catch(e=>{if(!disposed)notify(e.message,true);return false;});}
 async function readFile(e){const f=e.target.files[0],stamp=choosing||{revision,context:options.getContextToken?.(),filterName:importName};choosing=null;e.target.value='';if(!f)return;
  try{if(f.size>1900000)throw Error('设计文件超过容量。');const data=JSON.parse(await f.text());if(disposed||stamp.revision!==revision||stamp.context!==options.getContextToken?.())return;
   if(data.format==='analog-studio-digital-system'){const imported=M.validateState(data.state);imported.view='system';change('导入系统',()=>imported);}
   else if(data.format==='analog-studio-digital'){const model=root.DigitalDesign.load(data);save(M.create({kind:'filter',moduleName:M.id(stamp.filterName),model}),true);}
   else save(M.load(data));
  }catch(error){if(!disposed&&stamp.revision===revision&&stamp.context===options.getContextToken?.())notify('导入未完成：'+error.message,true);}
 }
 function click(e){const b=e.target.closest('button');if(!b)return;act(()=>{const action=b.dataset.ds;
  if(action==='save-module')save(M.create(readDraft()));
  if(action==='preview')$('source').textContent=M.create(readDraft()).verilog;
  if(action==='import-file'||action==='import-filter-file'){choosing={revision,context:options.getContextToken?.(),filterName:state.view==='module'?$('module-name').value:importName};$('file').click();}
  if(action==='add-instance'){if($('saved-select').value==='')throw Error('请先选择一个已保存的模块。');addInstance(catalog[Number($('saved-select').value)],$('instance-name').value);}
  if(action==='add-port'){const p={name:M.id($('port-name').value),direction:$('port-direction').value,width:numeric($('port-width'),'位宽'),signed:$('port-signed').value==='true',fraction:numeric($('port-fraction'),'小数位')};change('添加端口 '+p.name,next=>{next.ports.push(p);});}
  if(action==='connect'){const from=$('from').value,to=$('to').value;change('连接 '+from+' → '+to,next=>M.connect(next,from,to));}
  if(action==='reset-layout')canvasView?.reset();if(action==='delete-selected')deleteSelected();
  if(action==='export-system'){const code=M.generateSystem(state);$('system-source').hidden=false;$('system-source').textContent=code;send(state.topName+'.v',code);}
  if(action==='export-system-json')send(state.topName+'.system.json',JSON.stringify({format:'analog-studio-digital-system',version:1,state},null,2),'application/json');
  if(b.dataset.removeLink!==undefined){const c=state.connections[Number(b.dataset.removeLink)];change('删除连线 '+c.from+' → '+c.to,next=>{next.connections.splice(Number(b.dataset.removeLink),1);});}
  if(b.dataset.removeInstance)change('删除实例 '+b.dataset.removeInstance,next=>removeInstance(next,b.dataset.removeInstance));
  if(b.dataset.removePort!==undefined){const p=state.ports[Number(b.dataset.removePort)],key=(p.direction==='input'?'in:':'out:')+p.name;change('删除端口 '+p.name,next=>removePort(next,key));}
  if(b.dataset.importDesign!==undefined)addInstance(catalog[Number(b.dataset.importDesign)]);
  if(b.dataset.deleteDesign!==undefined)deleteDesign(catalog[Number(b.dataset.deleteDesign)]);
  for(const k of ['exportPackage','exportV','exportZip'])if(b.dataset[k]!==undefined){const p=catalog[Number(b.dataset[k])];if(k==='exportPackage')send(p.moduleName+'.module.json',JSON.stringify(p,null,2),'application/json');if(k==='exportV')send(p.moduleName+'.v',p.verilog);if(k==='exportZip')send(p.moduleName+'.zip',root.AnalogSimulationRunners.zip([{filename:p.moduleName+'.module.json',content:JSON.stringify(p,null,2)},{filename:p.moduleName+'.v',content:p.verilog}]),'application/zip');}
  if(b.dataset.edit!==undefined){captureDraft();const p=catalog[Number(b.dataset.edit)];if(p.kind==='filter'){options.loadFilter(p.config.model);state.view='filter';filterSave.querySelector('input').value=p.moduleName;}else{draft=copy(p.config);state.view='module';}render();emit();}
 });}
 function shortcut(e){if(disposed||options.isActive?.()===false||container.closest('[hidden]')||doc.querySelector('dialog[open]')||e.target.closest?.('input,textarea,select,[contenteditable]:not([contenteditable="false"])'))return;
  if(e.key==='Escape'&&menu){e.preventDefault();closeMenu();$('diagram')?.focus();return;}
  if(menu&&['ArrowDown','ArrowUp','Home','End'].includes(e.key)){const buttons=[...menu.querySelectorAll('button:not(:disabled)')],i=buttons.indexOf(doc.activeElement),n=e.key==='Home'?0:e.key==='End'?buttons.length-1:(i+(e.key==='ArrowDown'?1:-1)+buttons.length)%buttons.length;e.preventDefault();buttons[n]?.focus();return;}
  if(e.repeat)return;const key=e.key.toLowerCase(),control=(e.ctrlKey||e.metaKey)&&!e.altKey;
  if(control&&(key==='z'||key==='y')){const back=key==='z'&&!e.shiftKey;if((back?undo:redo).length){e.preventDefault();act(()=>travel(back));}return;}
  if(state.view!=='system')return;
  if(control&&key==='c'&&selected?.kind==='node'&&!root.getSelection?.()?.toString()){e.preventDefault();copySelected();return;}
  if(control&&key==='v'&&clipboard){e.preventDefault();act(()=>paste());return;}
  if(!e.ctrlKey&&!e.metaKey&&!e.altKey&&['Delete','Backspace'].includes(e.key)&&selected){e.preventDefault();act(deleteSelected);}
 }
 function outside(e){if(menu&&!menu.contains(e.target))closeMenu();}
 nav.addEventListener('click',e=>{const b=e.target.closest('button');if(!b)return;if(b.dataset.ds==='undo'||b.dataset.ds==='redo'){act(()=>travel(b.dataset.ds==='undo'));return;}if(!b.dataset.dsTab)return;captureDraft();state.view=b.dataset.dsTab;render();emit();});
 filterSave.addEventListener('click',e=>{const action=e.target.closest('button')?.dataset.ds;if(!['save-filter','filter-to-system'].includes(action))return;act(()=>save(M.create({kind:'filter',moduleName:filterSave.querySelector('input').value,model:options.getFilter()}),action==='filter-to-system'));});
 host.addEventListener('click',click);doc.addEventListener('keydown',shortcut);doc.addEventListener('pointerdown',outside,true);root.addEventListener('blur',closeMenu);root.addEventListener('scroll',closeMenu,true);render();
 return {snapshot(){return !state.modules.length&&!state.instances.length&&!state.ports.length&&state.view==='filter'&&state.topName==='digital_system'?null:copy(state);},deactivate(){canvasView?.cancel();closeMenu();},replace(value){canvasView?.destroy();canvasView=null;closeMenu();state=M.validateState(value);undo.length=redo.length=0;selected=null;revision++;draft=M.defaults();render();},destroy(){disposed=true;revision++;canvasView?.destroy();closeMenu();doc.removeEventListener('keydown',shortcut);doc.removeEventListener('pointerdown',outside,true);root.removeEventListener('blur',closeMenu);root.removeEventListener('scroll',closeMenu,true);nav.remove();host.remove();filterSave.remove();delete container.dataset.dsView;}};
}
root.DigitalSystem={attach};
})(typeof window!=='undefined'?window:globalThis);
