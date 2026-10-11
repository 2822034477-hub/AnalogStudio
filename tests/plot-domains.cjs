// Full DOM/data-coordinate regression with programmable layout and recording canvas.
// These are numerical/interaction tests, not screenshot or browser-layout validation.
const {JSDOM,VirtualConsole}=require('../testdeps/node_modules/jsdom');
const fs=require('fs'),assert=require('assert');
const html=fs.readFileSync(__dirname+'/../AnalogStudio.html','utf8');
const errors=[],observers=[],contexts=new Map(),zeroSize=new Set(),vc=new VirtualConsole();
vc.on('jsdomError',e=>{if(!e.message.includes('navigation'))errors.push(e.message);});
function canvasContext(canvas){
  if(contexts.has(canvas))return contexts.get(canvas);
  let path=[],stack=[];
  const ctx={calls:{text:[],strokes:[],arcs:[]},strokeStyle:'#000',fillStyle:'#000',lineWidth:1,
    measureText:s=>({width:String(s).length*6}),
    clearRect(){this.calls={text:[],strokes:[],arcs:[]};},
    beginPath(){path=[];},moveTo(...p){path.push(['M',...p]);},lineTo(...p){path.push(['L',...p]);},
    rect(...p){path.push(['R',...p]);},closePath(){path.push(['Z']);},
    arc(...p){path.push(['A',...p]);this.calls.arcs.push(p);},
    stroke(){this.calls.strokes.push({color:this.strokeStyle,width:this.lineWidth,path:JSON.parse(JSON.stringify(path))});},
    fillText(...p){this.calls.text.push(p);},
    save(){stack.push({strokeStyle:this.strokeStyle,fillStyle:this.fillStyle,lineWidth:this.lineWidth});},
    restore(){Object.assign(this,stack.pop()||{});}
  };
  const proxy=new Proxy(ctx,{get:(o,k)=>k in o?o[k]:()=>{},set:(o,k,v)=>(o[k]=v,true)});
  contexts.set(canvas,proxy);return proxy;
}
const dom=new JSDOM(html,{
  url:'http://localhost/AnalogStudio.html',runScripts:'dangerously',pretendToBeVisual:true,virtualConsole:vc,
  beforeParse(w){
    w.ResizeObserver=class{constructor(cb){this.cb=cb;this.targets=[];observers.push(this);}observe(n){this.targets.push(n);}disconnect(){this.targets=[];}};
    w.scrollTo=()=>{};w.HTMLElement.prototype.scrollIntoView=function(){};
    w.HTMLElement.prototype.setPointerCapture=function(){};
    w.HTMLElement.prototype.getBoundingClientRect=function(){
      const frame=this.closest('[data-dock-panel]'),id=frame?.dataset.dockPanel;
      let width=600,height=300;
      if(frame){width=parseFloat(frame.style.width)||896;height=parseFloat(frame.style.height)||560;
        if(this!==frame){width-=24;height-=140;}}
      if(zeroSize.has(this.id)||zeroSize.has(id)){width=0;height=0;}
      return {x:0,y:0,left:0,top:0,right:width,bottom:height,width,height};
    };
    w.HTMLCanvasElement.prototype.getContext=function(){return canvasContext(this);};
    w.HTMLDialogElement.prototype.showModal=function(){this.open=true;};w.HTMLDialogElement.prototype.close=function(){this.open=false;};
  }
});
const w=dom.window,d=w.document,$=s=>d.querySelector(s),all=s=>[...d.querySelectorAll(s)];
const sleep=ms=>new Promise(r=>setTimeout(r,ms)),plain=x=>JSON.parse(JSON.stringify(x));
const click=s=>{assert($(s),`missing ${s}`);$(s).click();};
const change=(s,v)=>{$(s).value=v;$(s).dispatchEvent(new w.Event('change',{bubbles:true}));};
const domain=id=>plain(w.AnalogPlotView.domain(id));
const span=(v,a='x')=>v[a+'max']-v[a+'min'];
const near=(a,b,label,tolerance=1e-8)=>assert(Math.abs(a-b)<=tolerance*Math.max(1,Math.abs(a),Math.abs(b)),`${label}: ${a} != ${b}`);
const view=id=>$(`[data-viewport="${id}"]`),frame=id=>$(`[data-dock-panel="${id}"]`);
const surfaceSize=id=>{const n=d.getElementById(id),r=n.getBoundingClientRect();return {width:r.width,height:r.height,styleWidth:n.style.width,styleHeight:n.style.height,transform:n.style.transform};};
const canvases={bodeContainer:'bodeCanvas',polePlot:'poleCanvas'};
function ticks(id){return canvases[id]?contexts.get(d.getElementById(canvases[id])).calls.text.map(p=>p[0]):all(`#${id} .plot-x-tick, #${id} .plot-y-tick`).map(n=>[n.getAttribute('class'),n.dataset.value]);}
function series(id){
  if(!canvases[id])return $(`#${id} .plot-series`)?.innerHTML;
  const colors=['#5269d4','#16a295','#2bafa1','#536cd6','#8acfc6','#a2b0ed','#159d91'];
  return JSON.stringify(contexts.get(d.getElementById(canvases[id])).calls.strokes.filter(p=>colors.includes(p.color)));
}
function wheel(id,delta=-100,ctrl=true,x=.37,y=.39){const r=view(id).getBoundingClientRect(),e=new w.WheelEvent('wheel',{deltaY:delta,ctrlKey:ctrl,clientX:r.width*x,clientY:r.height*y,bubbles:true,cancelable:true});view(id).dispatchEvent(e);return e;}
function flushResize(){for(const observer of observers)if(observer.targets.length)observer.cb(observer.targets.map(target=>({target,contentRect:target.getBoundingClientRect()})),observer);}
async function redraw(){flushResize();w.dispatchEvent(new w.Event('resize'));await sleep(35);}
function resizeFrame(id,dx,dy){const h=frame(id).querySelector('.dock-resize-se');for(const [type,x,y]of[['pointerdown',100,100],['pointermove',100+dx,100+dy],['pointerup',100+dx,100+dy]]){const e=new w.MouseEvent(type,{button:0,clientX:x,clientY:y,bubbles:true,cancelable:true});Object.defineProperty(e,'pointerId',{value:1});h.dispatchEvent(e);}}
const modelFields=()=>Object.fromEntries(all('#parameters input,#parameters select,#fMin,#fMax,#expZeros,#expPoles,#expGain,#expBeta,#expSign,#expTime,#expMin,#expMax').map(n=>[n.id||n.dataset.number||n.dataset.slider,n.value]));
const checks=[];async function test(name,fn){try{await fn();console.log('PASS:',name);}catch(e){checks.push({name,error:e});console.error('FAIL:',name,'\n'+e.stack);}}
function assertEqualAxes(id){
  const v=domain(id);let width,height;
  if(canvases[id]){const r=d.getElementById(canvases[id]).getBoundingClientRect();width=r.width-91;height=r.height-67;}
  else{const rect=$(`#${id} clipPath rect`);width=+rect.getAttribute('width');height=+rect.getAttribute('height');}
  near(span(v)/width,span(v,'y')/height,id+' equal coordinate units per pixel');
}

(async()=>{const entry=JSON.stringify(w.AnalogProject.snapshot());await w.AnalogProject.importFile({size:entry.length,text:async()=>entry});
  await sleep(100);await redraw();assert.deepEqual(errors,[],'startup errors');assert(w.AnalogPlotView,'missing plot domain API');
  const ids=['bodeContainer','polePlot','expMagnitude','expPhase','expRoots','expStep'];
  await test('every plot zoom changes numeric domains, axis labels and reprojected data without enlarging the surface',()=>{
    const modelBefore=modelFields(),transfer=JSON.stringify(w.analogCurrentTransfer());
    for(const id of ids){
      assert(w.AnalogPlotView.available(id),`${id}: domain unavailable`);w.AnalogPlotView.fit(id);
      const before=domain(id),box=surfaceSize(id),labels=plain(ticks(id)),drawn=series(id);
      const others=new Map(ids.filter(n=>n!==id).map(n=>[n,domain(n)]));
      assert(!wheel(id,-100,false).defaultPrevented);assert.deepEqual(domain(id),before,`${id}: plain wheel changed coordinates`);
      assert(wheel(id,-100,true).defaultPrevented);const after=domain(id);
      assert(span(after)<span(before),`${id}: x range did not zoom`);assert(span(after,'y')<span(before,'y'),`${id}: y range did not zoom`);
      if(id==='bodeContainer')assert.equal(span(after,'p'),span(before,'p'),'Gain zoom changed independent phase axis');
      assert.notDeepEqual(ticks(id),labels,`${id}: tick values did not update`);
      assert.notEqual(series(id),drawn,`${id}: plotted series was not reprojected`);
      assert.deepEqual(surfaceSize(id),box,`${id}: CSS/image enlargement substituted for coordinate zoom`);
      for(const [other,old]of others)assert.deepEqual(domain(other),old,`${id}: changed independent ${other}`);
      click(`[data-dock-panel="${id}"] [data-zoom="fit"]`);assert.deepEqual(domain(id),before,`${id}: fit failed to restore automatic range`);
    }
    const pageWheel=new w.WheelEvent('wheel',{ctrlKey:true,deltaY:-100,bubbles:true,cancelable:true});d.body.dispatchEvent(pageWheel);assert(!pageWheel.defaultPrevented,'page zoom intercepted outside plots');
    assert.deepEqual(modelFields(),modelBefore,'plot interaction changed model control values');assert.equal(JSON.stringify(w.analogCurrentTransfer()),transfer,'plot interaction changed transfer function');
  });

  await test('log-frequency zoom preserves the cursor frequency, with log10 domain math',()=>{
    for(const id of ['bodeContainer','expMagnitude','expPhase']){
      w.AnalogPlotView.fit(id);const before=domain(id);assert(before.log);
      const r=d.getElementById(canvases[id]||id).getBoundingClientRect(),x=.31;
      const a=(x*r.width-(id==='bodeContainer'?59:82))/(r.width-(id==='bodeContainer'?81:107));
      const cursorLog=before.xmin+span(before)*a;
      assert(w.AnalogPlotView.zoom(id,2,{x,y:.4}));const after=domain(id);
      near(span(after),span(before)/2,id+' log span');near(after.xmin+span(after)*a,cursorLog,id+' cursor log frequency');
      near(10**(after.xmin+span(after)*a),10**cursorLog,id+' cursor frequency');w.AnalogPlotView.fit(id);
    }
  });

  await test('frequency plots resample the displayed range, including zoom-out and deep zoom',()=>{
    for(const id of ['bodeContainer','expMagnitude','expPhase']){
      w.AnalogPlotView.fit(id);
      for(const factor of [.5,256]){
        w.AnalogPlotView.zoom(id,factor);
        let points,left,right;
        if(id==='bodeContainer'){
          const drawn=contexts.get($('#bodeCanvas')).calls.strokes.find(p=>p.color==='#5269d4'&&p.width===2);
          assert(drawn,'missing Bode magnitude series');points=drawn.path.filter(p=>p[0]==='M'||p[0]==='L').map(p=>[p[1],p[2]]);
          left=59;right=$('#bodeCanvas').getBoundingClientRect().width-22;
        }else{
          const path=$(`#${id} .plot-series path`).getAttribute('d');
          points=[...path.matchAll(/[ML](-?[\d.e+]+)\s+(-?[\d.e+]+)/g)].map(m=>[+m[1],+m[2]]);
          const clip=$(`#${id} clipPath rect`);left=+clip.getAttribute('x');right=left+ +clip.getAttribute('width');
        }
        assert(points.length>100,`${id}: insufficient response samples`);
        near(points[0][0],left,id+' samples start at visible frequency minimum',1e-4);
        near(points.at(-1)[0],right,id+' samples end at visible frequency maximum',1e-4);
        assert(points.filter(p=>p[0]>=left-.02&&p[0]<=right+.02).length>100,`${id}: deep zoom reused a sparse original sweep`);
      }
      w.AnalogPlotView.fit(id);
    }
  });

  await test('Bode/Nyquist and trajectory/poles remember independent domain settings',()=>{
    w.AnalogPlotView.fit('bodeContainer');const bodeAuto=domain('bodeContainer');w.AnalogPlotView.zoom('bodeContainer',2);const bode=domain('bodeContainer');
    click('[data-chart="nyquist"]');assert.equal(domain('bodeContainer').mode,'nyquist');w.AnalogPlotView.fit('bodeContainer');const nyquistAuto=domain('bodeContainer');
    w.AnalogPlotView.zoom('bodeContainer',3);const nyquist=domain('bodeContainer');
    click('[data-chart="bode"]');assert.deepEqual(domain('bodeContainer'),bode);
    click('[data-chart="nyquist"]');assert.deepEqual(domain('bodeContainer'),nyquist);w.AnalogPlotView.fit('bodeContainer');assert.deepEqual(domain('bodeContainer'),nyquistAuto);
    click('[data-chart="bode"]');w.AnalogPlotView.fit('bodeContainer');assert.deepEqual(domain('bodeContainer'),bodeAuto);
    assert($('#traceEnabled').checked);w.AnalogPlotView.fit('polePlot');w.AnalogPlotView.zoom('polePlot',2);const trajectory=domain('polePlot');assert.equal(trajectory.mode,'trajectory');
    $('#traceEnabled').checked=false;$('#traceEnabled').dispatchEvent(new w.Event('change',{bubbles:true}));assert.equal(domain('polePlot').mode,'poles');
    w.AnalogPlotView.fit('polePlot');w.AnalogPlotView.zoom('polePlot',3);const poles=domain('polePlot');
    $('#traceEnabled').checked=true;$('#traceEnabled').dispatchEvent(new w.Event('change',{bubbles:true}));assert.deepEqual(domain('polePlot'),trajectory);
    $('#traceEnabled').checked=false;$('#traceEnabled').dispatchEvent(new w.Event('change',{bubbles:true}));assert.deepEqual(domain('polePlot'),poles);
    $('#traceEnabled').checked=true;$('#traceEnabled').dispatchEvent(new w.Event('change',{bubbles:true}));w.AnalogPlotView.fit('polePlot');
  });

  await test('zoom limits are 0.25–128 with the global 1e-6–1e12 Hz guard',()=>{
    for(const id of ids){
      w.AnalogPlotView.fit(id);const auto=domain(id),autoSpan=span(auto);
      w.AnalogPlotView.zoom(id,1e20);near(w.AnalogPlotView.scale(id),128,id+' upper scale');
      w.AnalogPlotView.zoom(id,1e-20);const low=domain(id),expected=auto.log?Math.max(.25,autoSpan/18):.25;
      near(w.AnalogPlotView.scale(id),expected,id+' lower scale');
      if(auto.log){assert(low.xmin>=-6-1e-9&&low.xmax<=12+1e-9);assert(span(low)<=18+1e-9);
        w.AnalogPlotView.pan(id,1e6,0);assert(domain(id).xmin>=-6-1e-9);w.AnalogPlotView.pan(id,-1e6,0);assert(domain(id).xmax<=12+1e-9);}
      const valid=domain(id);for(const factor of [0,-1,NaN,Infinity])assert.equal(w.AnalogPlotView.zoom(id,factor),false);assert.deepEqual(domain(id),valid,'invalid zoom changed domain');
      w.AnalogPlotView.fit(id);
    }
    assert.equal(w.AnalogPlotView.zoom('missing',2),false);
  });

  await test('SVG plots resize their coordinate viewBox to measured window dimensions',async()=>{
    for(const id of ['expMagnitude','expPhase','expRoots','expStep']){
      const before=$(`#${id} svg`).getAttribute('viewBox');resizeFrame(id,173,71);await redraw();
      const svg=$(`#${id} svg`),box=svg.getAttribute('viewBox').split(/\s+/).map(Number),r=d.getElementById(id).getBoundingClientRect();
      assert.notEqual(svg.getAttribute('viewBox'),before,`${id}: viewBox did not react to resize`);
      near(box[2],r.width,id+' SVG viewport width');near(box[3],r.height,id+' SVG viewport height');
    }
  });

  await test('complex-plane axes retain equal units per pixel after zoom and nonuniform resize',async()=>{
    click('[data-chart="nyquist"]');
    for(const id of ['bodeContainer','polePlot','expRoots']){
      w.AnalogPlotView.fit(id);assertEqualAxes(id);w.AnalogPlotView.zoom(id,2);assertEqualAxes(id);
      const before=domain(id);resizeFrame(id,239,67);await redraw();assertEqualAxes(id);
      near(span(domain(id)),span(before),id+' resize must preserve manual horizontal span');
    }
    click('[data-chart="bode"]');
  });

  await test('hidden zero-size redraw preserves saved domains and zoom',async()=>{
    for(const id of ids){
      w.AnalogPlotView.fit(id);w.AnalogPlotView.zoom(id,2);const before=domain(id),scale=w.AnalogPlotView.scale(id);
      zeroSize.add(id);click(`[data-dock-panel="${id}"] [data-zoom="close"]`);await redraw();
      assert.deepEqual(domain(id),before,`${id}: zero-size redraw corrupted saved domain`);near(w.AnalogPlotView.scale(id),scale,id+' zero-size redraw changed zoom');
      zeroSize.delete(id);const check=$(`[data-open-panel="${id}"]`);check.checked=true;check.dispatchEvent(new w.Event('change',{bubbles:true}));await redraw();
      assert.deepEqual(domain(id),before,`${id}: reopen lost previous domain`);w.AnalogPlotView.fit(id);
    }
  });

  await test('parameter edits preserve manual views and later zoom redraws the current model',async()=>{
    w.AnalogPlotView.fit('bodeContainer');w.AnalogPlotView.zoom('bodeContainer',2);const circuitDomain=domain('bodeContainer'),circuitBefore=series('bodeContainer');
    change('#number-Rf',String(Number($('#number-Rf').value)+10));await sleep(40);
    assert.deepEqual(domain('bodeContainer'),circuitDomain,'same circuit parameter edit reset manual view');
    assert.notEqual(series('bodeContainer'),circuitBefore,'circuit edit did not redraw series');
    w.AnalogPlotView.zoom('bodeContainer',2);const circuit=domain('bodeContainer');
    const path=contexts.get($('#bodeCanvas')).calls.strokes.find(p=>p.color==='#5269d4'&&p.width===2).path;
    const first=path.find(p=>p[0]==='M'),response=w.AnalogCore.evaluate(w.analogCurrentTransfer(),10**circuit.xmin);
    const h=$('#bodeCanvas').getBoundingClientRect().height,plotHeight=(h-25-46-35)/2;
    near(first[2],25+plotHeight*(circuit.ymax-response.db)/span(circuit,'y'),'Bode redraw uses changed circuit');

    change('#expPreset','first');w.AnalogPlotView.zoom('expMagnitude',2);const feedbackDomain=domain('expMagnitude'),feedbackBefore=series('expMagnitude');
    $('#expGain').value='7';click('#expApply');assert.deepEqual(domain('expMagnitude'),feedbackDomain,'same feedback model edit reset manual view');
    assert.notEqual(series('expMagnitude'),feedbackBefore,'feedback model edit did not redraw series');
    w.AnalogPlotView.zoom('expMagnitude',2);const v=domain('expMagnitude'),clip=$('#expMagnitude clipPath rect');
    const firstPoint=$('#expMagnitude .plot-series path').getAttribute('d').match(/^M(-?[\d.e+]+)\s+(-?[\d.e+]+)/);
    const updated=w.AnalogExperiment.zpk('','-1',7),db=w.AnalogCore.evaluate(updated,10**v.xmin).db;
    near(+firstPoint[2],+clip.getAttribute('y')+ +clip.getAttribute('height')*(v.ymax-db)/span(v,'y'),'SVG redraw uses changed feedback model',1e-4);
  });

  await test('network changes reset plot sources while compose target changes reset only the parameter plot',()=>{
    w.AnalogPlotView.zoom('bodeContainer',2);w.AnalogPlotView.zoom('polePlot',2);
    change('#dockNetworkSelect','lab:gain');near(w.AnalogPlotView.scale('bodeContainer'),1,'new lab response source');near(w.AnalogPlotView.scale('polePlot'),1,'new lab pole source');
    const nodes=plain(w.AnalogNetworks.list()).filter(n=>n.key.startsWith('node:')),root=nodes.find(n=>n.kind==='group'),leaf=nodes.find(n=>n.kind==='block');
    change('#dockNetworkSelect',root.key);w.AnalogPlotView.zoom('bodeContainer',2);w.AnalogPlotView.zoom('polePlot',2);const whole=domain('bodeContainer');
    change('#dockNetworkSelect',leaf.key);assert.deepEqual(domain('bodeContainer'),whole,'compose target selection reset whole-network response');
    near(w.AnalogPlotView.scale('polePlot'),1,'new compose parameter target');
    change('#dockNetworkSelect','lab:activeLP');
  });

  await test('invalid feedback clears stale domains; recovery, preset and snapshot sources start fitted',()=>{
    const feedback=['expMagnitude','expPhase','expRoots','expStep'];
    for(const id of feedback)w.AnalogPlotView.zoom(id,3);
    $('#expPoles').value='bad';click('#expApply');assert(!$('#expError').hidden);
    for(const id of feedback){assert.equal(w.AnalogPlotView.available(id),false,`${id}: invalid result retained active view`);assert.equal(w.AnalogPlotView.domain(id),null);assert.equal(w.AnalogPlotView.zoom(id,2),false);assert(!$(`#${id} svg`));}
    $('#expPoles').value='-1';click('#expApply');
    for(const id of feedback){assert(w.AnalogPlotView.available(id));near(w.AnalogPlotView.scale(id),1,id+' recovered view');w.AnalogPlotView.zoom(id,3);}
    change('#expPreset','osc');for(const id of feedback){near(w.AnalogPlotView.scale(id),1,id+' new preset');w.AnalogPlotView.zoom(id,2);}
    click('#expUseCurrent');assert($('#expGain').disabled);for(const id of feedback)if(w.AnalogPlotView.available(id))near(w.AnalogPlotView.scale(id),1,id+' circuit snapshot source');
    change('#expPreset','first');assert(!$('#expGain').disabled);for(const id of feedback)near(w.AnalogPlotView.scale(id),1,id+' restored editable source');
  });

  await test('independent Bode subplots each keep their own frequency, amplitude and phase domains',()=>{
    const V=w.AnalogPlotView,id='bodeContainer';V.select(id,'gain');V.direction(id,'both');V.fit(id);const initial=domain(id);
    V.zoom(id,2);const gain=domain(id);for(const key of ['pxmin','pxmax','pmin','pmax'])assert.equal(gain[key],initial[key]);
    V.select(id,'phase');V.zoom(id,3);const phase=domain(id);for(const key of ['xmin','xmax','ymin','ymax'])assert.equal(phase[key],gain[key]);near(span(phase,'px'),span(initial,'px')/3,'phase frequency span');near(span(phase,'p'),span(initial,'p')/3,'phase range');
    click('[data-dock-panel="bodeContainer"] [data-zoom="fit"]');const fitted=domain(id);for(const key of ['xmin','xmax','ymin','ymax'])assert.equal(fitted[key],gain[key]);for(const key of ['pxmin','pxmax','pmin','pmax'])assert.equal(fitted[key],initial[key]);
    V.select(id,'gain');V.fit(id);
  });
  await test('directional zoom changes only the requested axis, with truthful independent complex-plane scales',async()=>{
    const V=w.AnalogPlotView;click('[data-chart="nyquist"]');
    for(const id of ids){for(const dir of ['x','y','both']){V.fit(id);V.direction(id,dir);const before=domain(id);V.zoom(id,2);const after=domain(id);near(span(after),span(before)/(dir==='y'?1:2),id+' '+dir+' X');near(span(after,'y'),span(before,'y')/(dir==='x'?1:2),id+' '+dir+' Y');if(dir!=='both'&&['bodeContainer','polePlot','expRoots'].includes(id)){assert(!V.info(id).equal);const saved=domain(id);await redraw();near(span(domain(id)),span(saved),id+' free X survives redraw');near(span(domain(id),'y'),span(saved,'y'),id+' free Y survives redraw');}}V.fit(id);V.direction(id,'both');}
    click('[data-chart="bode"]');V.select('bodeContainer','phase');for(const dir of ['x','y']){V.fit('bodeContainer');V.direction('bodeContainer',dir);const before=domain('bodeContainer');V.zoom('bodeContainer',2);const after=domain('bodeContainer');near(span(after,'px'),span(before,'px')/(dir==='y'?1:2),'phase direction X');near(span(after,'p'),span(before,'p')/(dir==='x'?1:2),'phase direction Y');for(const key of ['xmin','xmax','ymin','ymax'])assert.equal(after[key],before[key]);}V.select('bodeContainer','gain');V.direction('bodeContainer','both');V.fit('bodeContainer');
  });
  await test('linear/log Hz switches fit only that frequency axis; anchors and signed pan are mathematically correct',()=>{
    const V=w.AnalogPlotView;
    for(const [id,part]of [['bodeContainer','gain'],['bodeContainer','phase'],['expMagnitude','main'],['expPhase','main']]){
      V.select(id,part);V.fit(id);V.direction(id,'both');const x=part==='phase'?'px':'x',y=part==='phase'?'p':'y';
      for(const mode of ['linear','log']){
        const other=domain(id);assert(V.frequency(id,mode));assert.equal(V.info(id).frequency,mode);const before=domain(id);near(span(before,y),span(other,y),'switch preserves vertical view');
        if(id==='bodeContainer'){const sibling=part==='phase'?['xmin','xmax','ymin','ymax']:['pxmin','pxmax','pmin','pmax'];for(const key of sibling)assert.equal(before[key],other[key],'switch changed sibling '+key);}
        const r=V.info(id).rect,a={x:(r.l+.3*(r.r-r.l))/r.w,y:(r.t+.6*(r.b-r.t))/r.h};const at=before[x+'min']+.3*span(before,x);V.zoom(id,2,a);const after=domain(id);near(after[x+'min']+.3*span(after,x),at,'Hz cursor coordinate anchor');
        V.pan(id,.1,.2);const moved=domain(id);near(moved[x+'min'],after[x+'min']-.1*span(after,x),'pan right shifts domain left');near(moved[y+'min'],after[y+'min']+.2*span(after,y),'pan down shifts domain up');
        V.pan(id,1e9,0);assert(domain(id)[x+'min']>=(mode==='log'?-6:1e-6)-1e-10);V.pan(id,-1e9,0);assert(domain(id)[x+'max']<=(mode==='log'?12:1e12)+1e-9);V.fit(id);
      }
    }
    V.select('bodeContainer','gain');V.fit('bodeContainer');
  });
  await test('linear amplitude is the analytic V/V ratio, distinct from dB and frequency log scaling',()=>{
    const V=w.AnalogPlotView;
    for(const id of ['bodeContainer','expMagnitude']){
      V.select(id,'gain');V.fit(id);const before=domain(id);assert(V.magnitude(id,'ratio'));const range=domain(id);near(range.xmin,before.xmin,'amplitude switch preserves X');near(range.ymax,10**(before.ymax/20),'dB to ratio upper bound');
      if(id==='bodeContainer'){
        const line=contexts.get($('#bodeCanvas')).calls.strokes.find(p=>p.color==='#5269d4'&&p.width===2),first=line.path.find(p=>p[0]==='M'),r=V.info(id).rect,value=w.AnalogCore.evaluate(w.analogCurrentTransfer(),10**range.xmin).mag;
        near(first[2],r.t+(range.ymax-value)/span(range,'y')*(r.b-r.t),'circuit ratio projection');assert(contexts.get($('#bodeCanvas')).calls.text.some(t=>t[0].includes('Magnitude / V/V')));
      }else{
        const first=$('#expMagnitude .plot-series path').getAttribute('d').match(/^M(-?[\d.e+]+)\s+(-?[\d.e+]+)/),r=V.info(id).rect,tf=w.AnalogExperiment.zpk($('#expZeros').value,$('#expPoles').value,Number($('#expGain').value)),value=w.AnalogCore.evaluate(tf,10**range.xmin).mag;
        near(+first[2],r.t+(range.ymax-value)/span(range,'y')*(r.b-r.t),'feedback ratio projection',1e-4);assert($('#expMagnitude svg').textContent.includes('Magnitude / V/V'));
      }
      V.magnitude(id,'db');V.fit(id);
    }
  });
  await test('zero amplitude remains selectable and plots zero V/V without inventing finite dB',()=>{
    const V=w.AnalogPlotView;change('#expPreset','first');V.magnitude('expMagnitude','ratio');$('#expGain').value='0';click('#expApply');assert(V.available('expMagnitude'),'zero magnitude lost viewport');assert(V.amplitudeRatio('expMagnitude'));const r=V.info('expMagnitude').rect,range=domain('expMagnitude'),expected=r.b-(0-range.ymin)/span(range,'y')*(r.b-r.t),path=$('#expMagnitude .plot-series path').getAttribute('d'),points=[...path.matchAll(/[ML](-?[\d.e+]+)\s+(-?[\d.e+]+)/g)];assert(points.length>100);for(const point of points)near(+point[2],expected,'zero ratio path',1e-4);V.magnitude('expMagnitude','db');assert(V.available('expMagnitude'));assert($('#expMagnitude svg').textContent.includes('−∞ dB'));assert.equal($('#expMagnitude .plot-series path').getAttribute('d'),'');V.magnitude('expMagnitude','ratio');assert($('#expMagnitude .plot-series path').getAttribute('d').length>0);change('#expPreset','first');
  });
  await test('visible selectors and pointer-targeted wheel apply to the intended subplot only',()=>{
    const V=w.AnalogPlotView,id='bodeContainer',prefix='[data-dock-panel="bodeContainer"] ';
    V.select(id,'gain');V.fit(id);change(prefix+'.dock-part-select','phase');assert.equal(V.info(id).part,'phase');assert($(prefix+'.dock-amplitude-select').hidden);
    change(prefix+'.dock-frequency-select','linear');assert(!V.frequencyLog(id,'phase'));assert(V.frequencyLog(id,'gain'));
    change(prefix+'.dock-axis-select','y');const before=domain(id);wheel(id,-100,true,.4,.76);const after=domain(id);assert(span(after,'p')<span(before,'p'));assert.equal(after.pxmin,before.pxmin);assert.equal(after.xmin,before.xmin);assert.equal(after.ymin,before.ymin);
    change(prefix+'.dock-frequency-select','log');change(prefix+'.dock-axis-select','both');change(prefix+'.dock-part-select','gain');change(prefix+'.dock-amplitude-select','ratio');assert(V.amplitudeRatio(id,'gain'));assert.equal($(prefix+'.dock-amplitude-select').hidden,false);change(prefix+'.dock-amplitude-select','db');V.fit(id);
    click('[data-chart="nyquist"]');assert($(prefix+'.dock-frequency-select').hidden);assert($(prefix+'.dock-part-select').hidden);assert($(prefix+'.dock-amplitude-select').hidden);click('[data-chart="bode"]');
  });
  await test('Space drag captures pointers, pans independently, and interrupts safely without hijacking editing or resizing',()=>{
    const V=w.AnalogPlotView,id='bodeContainer',vp=view(id),canvas=$('#bodeCanvas');V.select(id,'gain');V.fit(id);
    const captures=new Set();vp.setPointerCapture=i=>captures.add(i);vp.hasPointerCapture=i=>captures.has(i);vp.releasePointerCapture=i=>captures.delete(i);
    const pointer=(type,x,y,target=canvas,buttons=1)=>{const e=new w.MouseEvent(type,{button:0,buttons,clientX:x,clientY:y,bubbles:true,cancelable:true});Object.defineProperty(e,'pointerId',{value:42});target.dispatchEvent(e);return e;};
    const key=(type,target=d.body)=>{const e=new w.KeyboardEvent(type,{key:' ',code:'Space',bubbles:true,cancelable:true});target.dispatchEvent(e);return e;};
    vp.focus();assert(key('keydown',vp).defaultPrevented);const r=V.info(id).rect,x=r.l+.5*(r.r-r.l),y=r.t+.5*(r.b-r.t),before=domain(id);pointer('pointerdown',x,y);assert(captures.has(42));assert(vp.classList.contains('plot-panning'));pointer('pointermove',x+30,y+20);const moved=domain(id);assert(moved.xmin<before.xmin&&moved.ymin>before.ymin);for(const k of ['pxmin','pxmax','pmin','pmax'])assert.equal(moved[k],before[k]);
    pointer('pointerup',9999,9999,d.body,0);assert(!vp.classList.contains('plot-panning'));assert.equal(captures.size,0);key('keyup');assert(!vp.classList.contains('plot-pan-ready'));
    for(const interruption of ['keyup','blur','pointercancel','lostpointercapture']){vp.focus();key('keydown',vp);pointer('pointerdown',x,y);assert(vp.classList.contains('plot-panning'));if(interruption==='keyup')key('keyup');else if(interruption==='blur')w.dispatchEvent(new w.Event('blur'));else pointer(interruption,x,y,vp);assert(!vp.classList.contains('plot-panning'),interruption);const saved=domain(id);pointer('pointermove',x+40,y+40);assert.deepEqual(domain(id),saved);key('keyup');}
    const editable=d.createElement('div');editable.contentEditable='true';editable.setAttribute('contenteditable','true');editable.tabIndex=0;d.body.append(editable);
    for(const target of [$('#expZeros'),$('#expSign'),$('#number-Rf'),editable]){target.focus();assert(!key('keydown',target).defaultPrevented);assert(!vp.classList.contains('plot-pan-ready'));pointer('pointerdown',x,y);assert(!vp.classList.contains('plot-panning'));key('keyup',target);}
    editable.remove();vp.blur();pointer('pointerleave',0,0,vp);assert(!key('keydown',d.body).defaultPrevented,'space outside active plot scroll blocked');key('keyup');
    vp.focus();key('keydown',vp);const oldSize=frame(id).style.width;resizeFrame(id,30,20);assert.notEqual(frame(id).style.width,oldSize);assert(!vp.classList.contains('plot-panning'));key('keyup');V.fit(id);
    // Phase pointer determines independent target even while gain is selected in toolbar.
    V.select(id,'gain');const rect=V.info(id).rect,phaseY=rect.pt+.5*(rect.pb-rect.pt),gainBefore=domain(id);vp.focus();key('keydown',vp);pointer('pointerdown',x,phaseY);assert.equal(V.info(id).part,'phase');pointer('pointermove',x-25,phaseY-18);const phaseAfter=domain(id);for(const k of ['xmin','xmax','ymin','ymax'])assert.equal(phaseAfter[k],gainBefore[k]);assert(phaseAfter.pxmin>gainBefore.pxmin&&phaseAfter.pmin<gainBefore.pmin);key('keyup');V.select(id,'gain');V.fit(id);
  });

  await sleep(100);if(errors.length)checks.push({name:'runtime errors',error:new Error(errors.join('\n'))});
  dom.window.close();
  if(checks.length){console.error(`${checks.length} plot-domain regression group(s) failed.`);process.exit(1);}
  console.log('PASS: full DOM data-coordinate plot regressions. Numerical geometry and rendering commands checked; no visual browser claim.');
})().catch(e=>{console.error(e);dom.window.close();process.exit(1);});
