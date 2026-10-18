// Numerical/vector-angle and real controller checks in jsdom; not native rendering QA.
'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),{JSDOM}=require('../testdeps/node_modules/jsdom');
const dom=new JSDOM('<!doctype html><main></main>',{runScripts:'outside-only',url:'https://analog.invalid/'}),w=dom.window;
for(const name of ['digital-sos','digital-root-editor','digital-width','digital-response-plot','digital-magnitude','digital-design'])w.eval(fs.readFileSync(require.resolve('../'+name+'.js'),'utf8'));
const captured={},originalMount=w.DigitalResponsePlot.mount;
w.DigitalResponsePlot.mount=(host,fit)=>{const p=originalMount(host,fit),update=p.update;p.update=(series,axes)=>{captured[host.getAttribute('data-dd')]=series;update(series,axes);};return p;};
const D=w.DigitalDesign,root=w.document.querySelector('main'),changes=[],app=D.mount(root,{onChange:x=>changes.push(x)}),$=k=>root.querySelector('[data-dd="'+k+'"]');
let checks=0;const near=(a,b,t=1e-9)=>{assert(Math.abs(a-b)<t,`${a} != ${b}`);checks++;};
const json=x=>JSON.parse(JSON.stringify(x)),wrap=x=>((x+180)%360+360)%360-180;
const angle=(a,b)=>Math.atan2(a,b)*180/Math.PI;
function geometry(poles,w){const x=Math.cos(w),y=Math.sin(w);return wrap(poles.length*angle(y,x)-poles.reduce((s,p)=>s+angle(y,x-p),0));}
function mode(value){$('responseMode').value=value;$('responseMode').dispatchEvent(new w.Event('input',{bubbles:true}));$('responseMode').dispatchEvent(new w.Event('change',{bubbles:true}));}
function point(id,index,line=0){return captured[id][line].points[index].y;}
const fo=D.create({poles:[.8593103],gain:.2}),so=D.create({poles:[.8593103,.4927693],gain:.2});
// Screenshot reproduction; the origin zeros are essential in the vector-angle proof.
for(const m of [fo,so]){
 app.replace(D.serialize(m));assert.equal($('responseMode').value,'model');assert($('response-note').textContent.includes('模型视图'));assert.equal(root.querySelectorAll('svg').length,5);
 const poles=D.factorRoots(m).poles.map(p=>p.re),rtl=D.generateVerilog(m),before=json(app.getModel()),source=json(D.serialize(m));
 for(let i=0;i<=512;i++)near(point('phase',i),geometry(poles,Math.PI*i/512),1e-8);
 near(point('phase',0),0);near(point('phase',512),0);const modelStep=point('step',0);assert(modelStep>0);
 const atQuarter=point('phase',256),mag=$('magnitude').innerHTML,n=changes.length;mode('implementation');assert.equal(changes.length,n+1);
 const delay=D.toSOS(m).pipelineDelay;near(point('phase',256),wrap(atQuarter-90*delay));near(Math.abs(point('phase',512)),180*delay);
 assert($('response-note').textContent.includes('附加 '+delay+' 拍'));assert($('response-legend').textContent.includes('实现延迟'));
 near(point('step',0),delay?0:modelStep);assert.equal($('magnitude').innerHTML,mag);assert.deepEqual(json(app.getModel()),before);assert.deepEqual(json(D.serialize(app.getModel())),source);assert.equal(D.generateVerilog(app.getModel()),rtl);
 const saved=json(app.snapshot());assert.equal(saved.ui.responseMode,'implementation');mode('model');app.replace(saved);assert.deepEqual(json(app.snapshot()),saved);
 // Missing fields in older UI snapshots and raw model imports always choose model view.
 delete saved.ui.responseMode;app.replace(saved);assert.equal($('responseMode').value,'model');near(point('phase',512),0);
 mode('implementation');app.replace(D.serialize(m));assert.equal($('responseMode').value,'model');near(point('phase',512),0);
}
near(D.evaluate(fo,4101.435814118451).phase,-59.23923139411162);
// A bilinear RC has the requested -90 degree LIMIT, with an actual Nyquist zero.
$('preset').value='rcLowpass';$('preset').dispatchEvent(new w.Event('change',{bubbles:true}));
const rc=app.getModel();assert.equal(D.analysis(rc).zeros[0].re,-1);near(D.evaluate(rc,0).re,1);
for(const fraction of [0,.1,.25,.4,.49,.4999]){const omega=2*Math.PI*fraction,want=-Math.atan(9*Math.tan(omega/2))*180/Math.PI;near(D.evaluate(rc,48000*fraction).phase,want,1e-8);}
for(const [m,f] of [[rc,24000],[D.create({zeros:[-1,-1,-1,-1],poles:[.4,.5,.6,.7],gain:.01}),24000],[D.create({b:[.1,-.1],a:[1,-.8]}),0],[D.create({zeros:[1,1,1,1],poles:[.4,.5,.6,.7],gain:.01}),0]]){
 const h=D.evaluate(m,f);assert.equal(h.magnitude,0);assert.equal(h.db,-Infinity);assert(Number.isNaN(h.phase));checks+=3;
}
assert(Number.isNaN(point('phase',512)));assert(point('phase',511)<-89);assert($('phase-body').textContent.includes('相位未定义'));
// Explicit z^-d is preserved once in both phase and step views.
app.replace(D.serialize(D.create({poles:[.4,.6],gain:.1,delaySamples:2})));const modelQuarter=point('phase',256),first=()=>captured.step[0].points.findIndex(p=>p.y!==0);
assert.equal(first(),2);mode('implementation');near(wrap(point('phase',256)-modelQuarter),-90);assert.equal(first(),3);
// Invalid view imports fail atomically; view controls do not unblock invalid drafts.
const valid=json(app.snapshot()),bad=json(valid);bad.ui.responseMode='arbitrary';assert.throws(()=>app.replace(bad));assert.deepEqual(json(app.snapshot()),valid);
$('b').value='bad';$('b').dispatchEvent(new w.Event('input',{bubbles:true}));mode('model');assert.equal(root.querySelectorAll('svg').length,0);assert.equal($('response-note').textContent,'');assert($('verilog').disabled);
app.destroy();dom.window.close();
console.log(`PASS phase view: ${checks} numeric/vector comparisons; screenshot FO/SO reproduction, model/RTL phase and step selection, one change event, persistent/legacy views, RC bilinear limit and undefined endpoint zeros (coefficients/factors), explicit delay once, atomic invalid import/draft; model/magnitude/RTL unchanged. jsdom only.`);
