  // Embedded, complete s-domain SISO models. Every tree node owns its model copy.
  const BB=window.AnalogBlackbox;
  const bbPanel=document.createElement('section');bbPanel.className='blackbox-library';
  bbPanel.innerHTML='<div class="library-group-label">数学黑箱 · s 域 SISO</div><p class="blackbox-help">只接受可计算的完整有理传递函数；不导入测量曲线。</p><button class="button outline small" id="blackboxImport">↑ 导入黑箱并加入组合</button><button class="button outline small" id="blackboxExport">↓ 命名并保存完整响应</button><button class="button ghost small" id="blackboxExample">下载模型示例</button><input type="file" id="blackboxFile" accept=".json,application/json" multiple hidden><div id="blackboxLibraryItems"></div><p id="blackboxStatus" role="status" class="blackbox-help"></p>';
  $('libraryList').after(bbPanel);
  let bbReading=false;
  function bbStatus(message,error=false){$('blackboxStatus').textContent=message;$('blackboxStatus').classList.toggle('error',error);if(typeof hierarchyStatus==='function')hierarchyStatus(message,error);}
  function blackboxNodes(){const nodes=[];(function walk(n){if(n.kind==='blackbox')nodes.push(n);if(n.kind==='group')n.children.forEach(walk);})(state.workspace);return nodes;}
  function renderBlackboxLibrary(){if(!$('blackboxLibraryItems'))return;const nodes=blackboxNodes();$('blackboxLibraryItems').replaceChildren();for(const n of nodes){const row=document.createElement('button');row.className='library-item';row.dataset.blackboxNode=n.id;row.textContent=(n.name||n.model.name)+' · '+n.id.slice(-6);row.title='选择独立实例 '+n.id;row.addEventListener('click',()=>{state.selectedId=n.id;setView('compose');});$('blackboxLibraryItems').append(row);}}
  function blackboxParameterHTML(n){return '<div class="blackbox-editor"><p><strong>完整数学模型 · 连续 s 域 · 单入单出</strong></p><p class="parameter-help">实例 '+esc(n.id)+'。系数按 s 的升幂排列：[a₀, a₁, a₂] = a₀ + a₁s + a₂s²。编辑只影响此实例。</p><label>黑箱名称（此实例）<input id="blackboxModelName" maxlength="60" value="'+esc(n.name||n.model.name)+'"></label><label>分子系数（JSON 数组）<textarea id="blackboxNumerator" rows="2">'+esc(JSON.stringify(n.model.numerator))+'</textarea></label><label>分母系数（JSON 数组）<textarea id="blackboxDenominator" rows="2">'+esc(JSON.stringify(n.model.denominator))+'</textarea></label><button class="button primary small" id="blackboxApply">应用模型到此实例</button><button class="button outline small" id="blackboxExportSelected">保存此黑箱到工程目录</button><p class="parameter-help">保存会先应用上方名称与系数，并将此黑箱本体单独保存为 &lt;黑箱名称&gt;.blackbox.json；外部并联分支权重不写入模型。重命名不会删除旧文件。未约分多项式会保留；外部传递函数无法证明未知内部实现的稳定性，也不表示已实现硬件。复制后各实例独立。</p></div>';}
  function blackboxAddHTML(){const nodes=blackboxNodes();return '<div class="group-actions"><button class="button outline" data-import-blackbox>↑ 导入黑箱并加入</button></div>'+ (nodes.length?'<div class="dialog-copy"><p>复用当前工程中的黑箱（创建独立副本）</p></div><div class="dialog-grid">'+nodes.map(n=>'<button class="module-card" data-add-blackbox="'+esc(n.id)+'"><h3>'+esc(n.name||n.model.name)+'</h3><p>来源实例 '+esc(n.id)+' · 单入单出 s 域</p></button>').join('')+'</div>':'');}
  function blackboxTarget(target){return target&&typeof target==='object'?target:captureInsertionTarget(target===undefined?state.selectedId:target);}
  function commitBlackboxes(models,target){
    const destination=blackboxTarget(target);requireInsertionTarget(destination);
    const checked=models.map(v=>BB.makeNode(v)),group=destination.group,before=group.children.slice(),oldId=state.selectedId,oldView=state.view;
    try{for(const n of checked)insertIntoTarget(n,destination);state.view='compose';const totals=countNodes(state.workspace);if(totals.blocks+totals.groups>48||depthOf(state.workspace)>9)throw Error('最多 48 个节点、8 层嵌套。');C.transferRaw(state.workspace);render();persist();return checked.map(n=>n.id);}
    catch(error){group.children=before;state.selectedId=oldId;state.view=oldView;render();throw error;}
  }
  function addBlackboxCopy(id,target){const source=findNode(id)?.node;if(!source||source.kind!=='blackbox')return;try{commitBlackboxes([BB.validate({...source.model,name:nodeLabel(source)})],target);bbStatus('已向指定层添加独立黑箱副本。');}catch(error){bbStatus(error.message,true);}}
  async function importBlackboxFiles(files,target){
    if(bbReading||!files?.length)return false;
    let destination;try{destination=blackboxTarget(target);requireInsertionTarget(destination);}catch(error){bbStatus('黑箱导入未完成：'+error.message,true);return false;}
    bbReading=true;$('blackboxImport').disabled=true;$('layerImportBlackbox').disabled=true;
    try{if(files.length>24)throw Error('一次最多导入 24 个黑箱。');const values=[];
      for(const file of files){if(file.size>256*1024)throw Error('单个黑箱文件不能超过 256 KB。');const text=await file.text();requireInsertionTarget(destination);if(text.length>256*1024)throw Error('黑箱文件过大。');values.push(BB.validate(JSON.parse(text)));}
      requireInsertionTarget(destination);const ids=commitBlackboxes(values,destination);bbStatus('已向“'+nodeLabel(destination.group)+'”加入 '+ids.length+' 个独立黑箱实例；模型已嵌入工程。');return true;
    }catch(error){bbStatus('黑箱导入未完成：'+error.message+' 当前组合保持不变。',true);return false;}
    finally{bbReading=false;$('blackboxImport').disabled=false;$('layerImportBlackbox').disabled=false;}
  }
  let blackboxChooserSerial=0;
  function launchBlackboxImport(target){
    if(bbReading)return false;
    let destination;try{destination=blackboxTarget(target);requireInsertionTarget(destination);}catch(error){bbStatus(error.message,true);return false;}
    const serial=++blackboxChooserSerial,old=$('blackboxFile'),input=old.cloneNode(false);old.replaceWith(input);
    input.addEventListener('change',()=>{const files=Array.from(input.files||[]);input.value='';if(serial!==blackboxChooserSerial)return;importBlackboxFiles(files,destination);},{once:true});
    input.addEventListener('cancel',()=>{if(serial===blackboxChooserSerial)blackboxChooserSerial++;},{once:true});
    bbStatus('导入目标：'+hierarchyPath(destination.id).map(nodeLabel).join(' › '));input.click();return true;
  }
  function exportBlackbox(node=current()){const name=node.kind==='group'?state.projectName:nodeLabel(node);return BB.exportTransfer(C.transferRaw(node),{name:name||'响应黑箱',source:'Analog Studio · 未约分网络响应'});}
  function downloadBlackbox(model){let url,link;try{url=URL.createObjectURL(new Blob([JSON.stringify(model,null,2)],{type:'application/json'}));link=document.createElement('a');link.href=url;link.download=model.name.replace(/[<>:"/\\|?*\u0000-\u001f]/g,'_')+'.blackbox.json';document.body.append(link);link.click();link.remove();setTimeout(()=>URL.revokeObjectURL(url),30000);bbStatus('已请求下载黑箱模型；请检查浏览器下载位置。');}catch(e){link?.remove();if(url)URL.revokeObjectURL(url);bbStatus('导出未完成：'+e.message,true);}}
  $('blackboxImport').addEventListener('click',()=>launchBlackboxImport());
  $('blackboxExport').addEventListener('click',()=>{try{window.AnalogProject.saveBlackbox(exportBlackbox(),{askName:true});}catch(e){bbStatus(e.message,true);}});
  $('blackboxExample').addEventListener('click',()=>downloadBlackbox(BB.exportTransfer({num:[2],den:[1,.01],warnings:[]},{name:'一阶低通示例',source:'H(s)=2/(1+0.01s)'})));
  function applyBlackboxEditor(){const n=parameterTarget();if(n.kind!=='blackbox')return null;const model=BB.validate({...n.model,name:$('blackboxModelName').value.trim(),numerator:JSON.parse($('blackboxNumerator').value),denominator:JSON.parse($('blackboxDenominator').value)}),previous=n.model,oldName=n.name;n.model=model;delete n.name;try{C.transferRaw(state.workspace);}catch(error){n.model=previous;if(oldName===undefined)delete n.name;else n.name=oldName;throw error;}render();persist();bbStatus('已更新此实例，其他副本不变。');return BB.validate(model);}
  $('parameters').addEventListener('click',e=>{if(!['blackboxExportSelected','blackboxApply'].includes(e.target.id))return;try{const model=applyBlackboxEditor();if(model&&e.target.id==='blackboxExportSelected')window.AnalogProject.saveBlackbox(model);}catch(error){bbStatus('未应用：'+error.message,true);toast('黑箱模型未应用：'+error.message,true);}});
  window.AnalogBlackboxProject={importFiles:importBlackboxFiles,chooseImport:launchBlackboxImport,addModels:commitBlackboxes,exportCurrent:()=>exportBlackbox(),exportSelected:()=>exportBlackbox(parameterTarget()),list:()=>clone(blackboxNodes())};
