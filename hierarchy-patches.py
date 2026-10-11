"""Topology-adjacent layer editor. Apply to the complete, previously built HTML."""
from pathlib import Path
p = Path(__file__).parent

def patch(s):
    if '/* Analog hierarchy editor v1 */' in s:
        raise RuntimeError('Hierarchy patch has already been applied')
    def sub(a, b):
        nonlocal s
        if a not in s:
            raise RuntimeError('Missing hierarchy patch target: ' + a[:140])
        s = s.replace(a, b, 1)
    def section(start, end, value):
        nonlocal s
        a=s.index(start);b=s.index(end,a)
        s=s[:a]+value+s[b:]

    sub('</style>', '\n'+(p/'hierarchy.css').read_text()+'\n</style>')
    sub('<div class="composer-hint">点击任意单元调参；在选中位置添加、嵌套或调整顺序。</div><div id="compositionTree" class="composition-tree"></div><details class="topology-detail" open>', '''<div class="composer-hint">先选择层级，再向该层添加系统、黑箱或子层。点击拓扑中的模块也可选中并调参。</div><div class="composition-workbench" id="compositionWorkbench"><details class="hierarchy-panel" id="hierarchyPanel" open><summary><strong>层级与插入位置</strong><span>展开 / 收起</span></summary><div class="hierarchy-content"><div class="insertion-context"><span class="layer-kicker">当前插入层</span><nav id="insertionBreadcrumb" aria-label="当前插入层路径"></nav><p id="insertionHint"></p></div><div class="hierarchy-quick-actions" aria-label="向当前层添加"><button class="button primary small" id="layerAddSystem">＋ 系统</button><button class="button outline small" id="layerImportBlackbox">↑ 黑箱</button><button class="button outline small" data-layer-create="cascade">＋ 串联层</button><button class="button outline small" data-layer-create="sum">＋ 并联层</button></div><div class="hierarchy-layer-settings"><label>本层连接<select id="layerMode"><option value="cascade">串联 · 依次相乘</option><option value="sum">并联 · 分支求和</option></select></label><p id="layerEquation"></p></div><div id="compositionTree" class="composition-tree" role="tree" aria-label="组合系统层级"></div><p id="hierarchyStatus" class="hierarchy-status" role="status" aria-live="polite"></p></div></details><details class="topology-detail" open>''')
    sub('<div id="compositionSchematic" class="composition-schematic"></div></details><div class="compose-footer">', '<div id="compositionSchematic" class="composition-schematic"></div></details></div><div class="compose-footer">')
    sub('id="addBlockButton">+ 添加模块', 'id="addBlockButton">＋ 添加到当前层')
    sub("  function insertNode(node, anchorId = state.selectedId) { const a = findNode(anchorId) || selected(); if (a.node.kind === 'group') a.node.children.push(node); else a.parent.children.splice(a.index+1,0,node); state.selectedId = node.id; }", r'''  /* Analog hierarchy editor v1 */
  const collapsedLayers=new Set();
  let addDialogTarget=null;
  function insertionLayer(anchorId=state.selectedId){
    const match=findNode(anchorId);
    if(!match)throw Error('所选层级已不存在，请重新选择。');
    return match.node.kind==='group'?match.node:match.parent;
  }
  // References distinguish a reopened project from its prior copy, even with identical IDs.
  function captureInsertionTarget(anchorId=state.selectedId){
    if(window.AnalogProjectAtHome)throw Error('请先打开工程。');
    const group=insertionLayer(anchorId);
    return Object.freeze({root:state.workspace,group,id:group.id});
  }
  function requireInsertionTarget(target){
    const match=target&&findNode(target.id);
    if(window.AnalogProjectAtHome||!target||target.root!==state.workspace||!match||match.node!==target.group||match.node.kind!=='group')throw Error('原工程或目标层级已更改，请重新选择目标层。');
    return match.node;
  }
  function insertIntoTarget(node,target){const group=requireInsertionTarget(target);group.children.push(node);collapsedLayers.delete(group.id);state.selectedId=node.id;}
  function insertNode(node,anchorId=state.selectedId){insertIntoTarget(node,captureInsertionTarget(anchorId));}
  function hierarchyPath(id){
    const path=[];let found=findNode(id);
    while(found){path.unshift(found.node);found=found.parent?findNode(found.parent.id):null;}
    return path;
  }
  function selectHierarchyNode(id){if(!findNode(id))return false;state.selectedId=id;hierarchyPath(id).slice(0,-1).forEach(n=>collapsedLayers.delete(n.id));state.view='compose';render();persist();return true;}
  function hierarchyStatus(message,error=false){const el=$('hierarchyStatus');if(el){el.textContent=message;el.classList.toggle('error',error);}}
  function renderHierarchyContext(){
    const target=insertionLayer(selected().node.id),path=hierarchyPath(target.id);
    $('insertionBreadcrumb').innerHTML=path.map((n,i)=>'<button type="button" data-layer-select="'+esc(n.id)+'" '+(i===path.length-1?'aria-current="location"':'')+'>'+esc(n.name||(i===0?'根层':n.mode==='sum'?'并联层':'串联层'))+'</button>').join('<span aria-hidden="true">›</span>');
    $('insertionHint').textContent=selected().node.kind==='group'?'新内容将加入本层末尾；子层内部独立连接。':'已选中“'+nodeLabel(selected().node)+'”；新内容加入其所属层，不会加入叶节点。';
    $('layerMode').value=target.mode;$('layerMode').dataset.target=target.id;
    $('layerEquation').textContent=target.mode==='sum'?'本层 H(s) = Σ aᵢHᵢ(s) · 点击分支可编辑权重':'本层 H(s) = H₁(s) × H₂(s) × …';
    $('compositionWorkbench').dataset.insertionLayer=target.id;
  }
  function renderCompositionTopology(){
    $('compositionSchematic').innerHTML=S.topology(state.workspace);
    for(const el of $('compositionSchematic').querySelectorAll('[data-topology-node]')){
      const id=el.dataset.topologyNode,n=findNode(id)?.node;if(!n)continue;
      const active=id===state.selectedId;el.setAttribute('aria-label','选择 '+nodeLabel(n));el.setAttribute('aria-pressed',String(active));el.classList.toggle('topology-selected',active);
    }
  }
  function createHierarchyGroup(mode,anchorId=state.selectedId){
    let target;try{target=captureInsertionTarget(anchorId);}catch(error){hierarchyStatus(error.message,true);return;}
    changeTree(()=>{const node=C.makeGroup(mode);node.name=mode==='sum'?'并联层':'串联层';insertIntoTarget(node,target);state.view='compose';});
  }
''')
    section('  function treeHTML(node,parent = null) {','  function displayUnit(spec) {',r'''  function treeHTML(node,parent=null,level=1,path='1') {
    const group=node.kind==='group',active=state.selectedId===node.id,target=insertionLayer(selected().node.id).id,open=!collapsedLayers.has(node.id);
    const mode=group?(node.mode==='cascade'?'串联':'并联 Σ'):node.kind==='blackbox'?'黑箱 H(s)':'系统';
    const index=parent?parent.children.indexOf(node):-1;
    let buttons='<button data-action="add" title="向所属层添加系统" aria-label="向'+esc(nodeLabel(group?node:parent))+'添加系统">＋</button>';
    if(parent)buttons+='<button data-action="up" '+(index===0?'disabled':'')+' title="上移" aria-label="上移">↑</button><button data-action="down" '+(index===parent.children.length-1?'disabled':'')+' title="下移" aria-label="下移">↓</button><button data-action="copy" title="复制独立实例" aria-label="复制">⧉</button><button data-action="remove" title="删除" aria-label="删除">×</button>';
    const tools=group?'<div class="layer-node-tools" aria-label="向'+esc(nodeLabel(node))+'添加"><button data-layer-system="'+node.id+'">＋ 系统</button><button data-layer-import="'+node.id+'">↑ 黑箱</button><button data-layer-subgroup="cascade" data-layer-target="'+node.id+'">＋ 串联</button><button data-layer-subgroup="sum" data-layer-target="'+node.id+'">＋ 并联</button></div>':'';
    return '<div class="tree-node '+(group?'group-node ':'')+(active?'selected ':'')+(target===node.id?'is-insertion':'')+'" data-node="'+node.id+'" role="treeitem" aria-level="'+level+'" aria-selected="'+active+'" '+(group?'aria-expanded="'+open+'"':'')+'><div class="tree-node-header" data-select="'+node.id+'" tabindex="0" role="button" aria-label="选择 '+esc(nodeLabel(node))+'"><button class="layer-toggle" data-layer-toggle="'+node.id+'" '+(!group?'disabled aria-hidden="true" tabindex="-1"':'aria-label="'+(open?'收起':'展开')+esc(nodeLabel(node))+'" aria-expanded="'+open+'"')+'>'+ (group?(open?'▾':'▸'):'·')+'</button><span class="tree-icon">'+(group?(node.mode==='cascade'?'→':'Σ'):node.kind==='blackbox'?'▣':esc(icons[node.type]))+'</span><span class="tree-node-label"><span class="tree-name">'+esc(nodeLabel(node))+'</span><span class="tree-meta">'+path+' · '+esc(mode)+(group?' · '+node.children.length+' 项':'')+'</span></span>'+(parent?.mode==='sum'?'<span class="tree-weight">×'+fmt(node.weight)+'</span>':'')+'<span class="tree-node-actions">'+buttons+'</span></div>'+tools+(group?'<div class="tree-children" role="group" '+(!open?'hidden':'')+'>'+(node.children.length?node.children.map((n,i)=>treeHTML(n,node,level+1,path+'.'+(i+1))).join(''):'<div class="tree-empty">空'+(node.mode==='cascade'?'串联层 · H(s)=1':'并联层 · H(s)=0')+'<br>使用上方按钮向此层添加内容</div>')+'</div>':'')+'</div>';
  }
''')
    sub("      $('compositionTree').innerHTML = treeHTML(state.workspace);\n      $('compositionSchematic').innerHTML = S.topology(state.workspace);", "      hierarchyPath(selected().node.id).slice(0,-1).forEach(n=>collapsedLayers.delete(n.id));\n      $('compositionTree').innerHTML=treeHTML(state.workspace);renderHierarchyContext();renderCompositionTopology();")
    sub("if(label)label.textContent='×'+fmt(v);$('compositionSchematic').innerHTML=S.topology(state.workspace);", "if(label)label.textContent='×'+fmt(v);renderCompositionTopology();")
    sub('选中单元后点 + 在其后插入；选中组后点 + 在组内追加。', '选中单元时向其所属层追加；选中层时向该层追加。插入路径显示在拓扑旁。')
    section('  function showAdd(anchorId=state.selectedId) {','  function showModels() {',r'''  function showAdd(anchorId=state.selectedId) {
    try{addDialogTarget=captureInsertionTarget(anchorId);}catch(error){hierarchyStatus(error.message,true);return;}
    state.selectedId=anchorId;state.view='compose';render();
    const group=addDialogTarget.group,path=hierarchyPath(group.id).map(nodeLabel).join(' › ');
    const cards=C.catalog.map(entry=>'<button class="module-card" data-add-type="'+entry.type+'"><span class="card-icon">'+esc(icons[entry.type])+'</span><h3>'+esc(entry.name)+'</h3><p>'+esc(entry.description)+'</p></button>').join('');
    modal('向当前层添加系统','<div class="dialog-copy"><p>目标层：<strong>'+esc(path)+'</strong></p><p>系统将添加到此层末尾，层级内可独立加入黑箱或继续创建子层。</p></div><div class="dialog-grid">'+cards+'</div>'+blackboxAddHTML()+'<div class="group-actions"><button class="button outline" data-add-group="cascade">＋ 串联子层</button><button class="button outline" data-add-group="sum">＋ 并联子层</button></div>','ADD TO SELECTED LAYER');
  }
''')
    sub("  $('compositionTree').addEventListener('click',e=>{", r'''  $('layerAddSystem').addEventListener('click',()=>showAdd());
  $('layerImportBlackbox').addEventListener('click',()=>launchBlackboxImport());
  $('hierarchyPanel').addEventListener('click',e=>{
    const choose=e.target.closest('[data-layer-select]');if(choose){selectHierarchyNode(choose.dataset.layerSelect);return;}
    const create=e.target.closest('[data-layer-create]');if(create)createHierarchyGroup(create.dataset.layerCreate);
  });
  $('layerMode').addEventListener('change',e=>{const id=e.target.dataset.target;changeTree(()=>{const group=insertionLayer(id);group.mode=e.target.value;if(group.mode==='cascade')group.children.forEach(child=>{child.weight=1;});});});
  $('compositionSchematic').addEventListener('click',e=>{const item=e.target.closest('[data-topology-node]');if(item)selectHierarchyNode(item.dataset.topologyNode);});
  $('compositionSchematic').addEventListener('keydown',e=>{const item=e.target.closest('[data-topology-node]');if(item&&(e.key==='Enter'||e.key===' ')){e.preventDefault();selectHierarchyNode(item.dataset.topologyNode);$('compositionSchematic').querySelector('[data-topology-node="'+item.dataset.topologyNode+'"]')?.focus();}});
  if(window.matchMedia?.('(max-width: 1250px)').matches)$('hierarchyPanel').open=false;
  $('compositionTree').addEventListener('click',e=>{
    const toggle=e.target.closest('[data-layer-toggle]');if(toggle){const id=toggle.dataset.layerToggle;if(collapsedLayers.has(id))collapsedLayers.delete(id);else collapsedLayers.add(id);$('compositionTree').innerHTML=treeHTML(state.workspace);$('compositionTree').querySelector('[data-layer-toggle="'+id+'"]')?.focus();return;}
    const system=e.target.closest('[data-layer-system]');if(system){showAdd(system.dataset.layerSystem);return;}
    const imported=e.target.closest('[data-layer-import]');if(imported){launchBlackboxImport(imported.dataset.layerImport);return;}
    const group=e.target.closest('[data-layer-subgroup]');if(group){createHierarchyGroup(group.dataset.layerSubgroup,group.dataset.layerTarget);return;}
''')
    sub("}else if(header){state.selectedId=header.dataset.select;render();persist();}", "}else if(header){selectHierarchyNode(header.dataset.select);}")
    sub("  $('compositionTree').addEventListener('keydown',e=>{if((e.key==='Enter'||e.key===' ')&&e.target.matches('[data-select]')){e.preventDefault();state.selectedId=e.target.dataset.select;render();persist();}});", r'''  $('compositionTree').addEventListener('keydown',e=>{
    if(!e.target.matches('[data-select]'))return;
    const id=e.target.dataset.select,match=findNode(id);if(!match)return;
    if(e.key==='Enter'||e.key===' '){e.preventDefault();selectHierarchyNode(id);$('compositionTree').querySelector('[data-select="'+id+'"]')?.focus();return;}
    if(e.key==='ArrowRight'&&match.node.kind==='group'){e.preventDefault();collapsedLayers.delete(id);$('compositionTree').innerHTML=treeHTML(state.workspace);$('compositionTree').querySelector('[data-select="'+(match.node.children[0]?.id||id)+'"]')?.focus();}
    if(e.key==='ArrowLeft'){e.preventDefault();if(match.node.kind==='group'&&!collapsedLayers.has(id)){collapsedLayers.add(id);$('compositionTree').innerHTML=treeHTML(state.workspace);$('compositionTree').querySelector('[data-select="'+id+'"]')?.focus();}else if(match.parent)$('compositionTree').querySelector('[data-select="'+match.parent.id+'"]')?.focus();}
    if(e.key==='ArrowDown'||e.key==='ArrowUp'){e.preventDefault();const rows=Array.from($('compositionTree').querySelectorAll('[data-select]')).filter(el=>!el.closest('[hidden]')),index=rows.indexOf(e.target);rows[Math.max(0,Math.min(rows.length-1,index+(e.key==='ArrowDown'?1:-1)))]?.focus();}
  });''')
    sub("addBlackboxCopy(bb.dataset.addBlackbox);", "addBlackboxCopy(bb.dataset.addBlackbox,addDialogTarget);")
    sub("if(e.target.closest('[data-import-blackbox]')){$('dialog').close();$('blackboxFile').click();return;}", "if(e.target.closest('[data-import-blackbox]')){const target=addDialogTarget;$('dialog').close();launchBlackboxImport(target);return;}")
    sub("insertNode(C.makeBlock(add.dataset.addType));", "insertIntoTarget(C.makeBlock(add.dataset.addType),addDialogTarget);")
    sub("insertNode(C.makeGroup(group.dataset.addGroup));", "insertIntoTarget(C.makeGroup(group.dataset.addGroup),addDialogTarget);")
    # Wrap each SVG layout item, so both containers and leaves remain independently selectable.
    sub('  function layout(node, depth, budget) {', r'''  function layout(node,depth,budget){
    const item=layoutItem(node,depth,budget),draw=item.draw;
    if(node?.id)item.draw=(x,y)=>'<g data-topology-node="'+escapeXML(node.id)+'" tabindex="0" role="button">'+draw(x,y)+'</g>';
    return item;
  }
  function layoutItem(node, depth, budget) {''')
    # The SVG module's existing XML escaper is named esc.
    sub("escapeXML(node.id)", "esc(node.id)")
    # Give the adjacent graph available space instead of sizing to the full dock center.
    sub("function resetSize(){outer.style.width=Math.max(640,Math.min(1200,(center.clientWidth||920)-24))+'px';", "function resetSize(){const available=id==='compositionSchematic'?Math.max(640,(center.clientWidth||920)-330):(center.clientWidth||920)-24;outer.style.width=Math.max(640,Math.min(1200,available))+'px';")
    return s
