'use strict';
const assert=require('assert'),fs=require('fs'),vm=require('vm');
const I=require('../inverse-mixed.js');let checks=0;
const near=(a,b,tol=1e-9)=>{checks++;assert(Math.abs(a-b)<=tol*Math.max(1,Math.abs(a),Math.abs(b)),`${a} ≠ ${b}`);};
const real=(re)=>({re,im:0,pair:false}),pair=(re,im)=>({re,im,pair:true});
const target=(poles,zeros=[],gain=1)=>({poles,zeros,gain});
const lp=target([real(-1000)],[],1000),hp=target([real(-1000)],[real(0)],1);
assert.deepStrictEqual(I.transfer(lp),{num:[1000],den:[1000,1]});checks++;
near(I.evaluate(I.transfer(lp),0).re,1);near(I.evaluate(I.transfer(lp),1000).db,-3.010299956639812);
near(I.evaluate(I.transfer(hp),1000).db,-3.010299956639812);near(I.evaluate(I.transfer(hp),0).re,0);
assert.equal(I.stability(lp),'stable');assert.equal(I.stability(target([real(0)])),'marginal');assert.equal(I.stability(target([real(1)])),'unstable');checks+=3;
const p=I.transfer(target([pair(-3,4)],[],25));assert.deepStrictEqual(p,{num:[25],den:[25,6,1]});checks++;
assert.throws(()=>I.transfer(target([{re:-1,im:1,pair:false}])));assert.throws(()=>I.transfer(target(Array(9).fill(real(-1)))));checks+=2;
let r=I.realize(lp);assert(r.candidates.some(c=>c.kind==='rc-lowpass'));for(const c of r.candidates){assert(c.relativeError<1e-12);near(c.components.find(v=>v.name==='R').value,100000);}checks++;
r=I.realize(hp);assert.equal(r.candidates[0].kind,'rc-highpass');near(r.candidates[0].relativeError,0,1e-10);checks++;
r=I.realize(target([real(-1000)],[],-2000));assert.equal(r.candidates[0].kind,'inverting-lowpass');near(r.candidates[0].components.find(c=>c.name==='Rin').value,50000);near(r.candidates[0].relativeError,0,1e-10);checks++;
const sk=target([pair(-500,Math.sqrt(750000))],[],2e6);r=I.realize(sk);assert.equal(r.candidates[0].kind,'sallen-key-lowpass');near(r.candidates[0].relativeError,0,1e-10);near(r.candidates[0].components.find(c=>c.name==='Rf').value,10000);checks++;
for(const unsupported of [target([real(1)]),target([real(0)]),target([real(-1)],[],.5),target([real(-1)],[pair(0,1)]),target([pair(-1,1)],[],1),target([real(-1),real(-2),real(-3)]),target([real(-1)],[],0)]){r=I.realize(unsupported);assert.equal(r.candidates.length,0);assert(r.reason.startsWith('No '));checks++;}
const T=.001,b=I.bilinear(lp,T);near(b.b[0],1/3);near(b.b[1],1/3);near(b.a[0],1);near(b.a[1],-1/3);
const first=I.simulate(b,[1,1,1,1]);[1/3,7/9,25/27,79/81].forEach((v,i)=>near(first[i],v));
for(const omega of [.01,.2,1,2.9]){const a=I.evaluate(I.transfer(lp),2/T*Math.tan(omega/2)),d=I.digitalResponse(b,omega);near(a.re,d.re);near(a.im,d.im);}
const c=I.cascade(lp,{b:[.5,.5],a:[1]},T);assert.equal(c.b.length,3);near(c.b[0],1/6);near(c.b[1],1/3);near(c.b[2],1/6);checks++;
near(I.digitalResponse(c,0).re,1);near(I.digitalResponse(c,Math.PI).re,0);
assert.throws(()=>I.bilinear(lp,0));assert.throws(()=>I.bilinear(target([real(-1)],[pair(-1,1)]),T));assert.throws(()=>I.cascade(lp,{b:[1],a:[0]},T));checks+=3;
let s=I.defaults();assert.deepStrictEqual(I.validate(s),s);const saved=JSON.parse(JSON.stringify(s));s.target.poles[0].re=-7;assert.equal(saved.target.poles[0].re,-1000);checks+=2;
assert.throws(()=>I.validate({...saved,span:0}));assert.throws(()=>I.validate({...saved,samplePeriod:NaN}));assert.throws(()=>I.validate({...saved,frequencyMin:100,frequencyMax:10}));checks+=3;
// Generated component networks independently solve to the target across diverse scales.
for(let n=0;n<30;n++){
 const omega=10**(-1+n/29*6),Q=.5+n/29*19.5,K=3-1/Q,re=-omega/(2*Q),im=Math.sqrt(Math.max(0,omega*omega-re*re));
 const t=target([pair(re,im)],[],K*omega*omega),candidate=I.realize(t).candidates[0];assert(candidate);assert(candidate.circuitRelativeError<1e-8);checks+=2;
 for(const factor of [.1,1,10]){const expected=I.evaluate(I.transfer(t),omega*factor),actual=I.circuitResponse(candidate.circuit,omega*factor);near(actual.re,expected.re,1e-8);near(actual.im,expected.im,1e-8);}
}
for(const t of [lp,hp,target([real(-1000)],[],-2000),target([real(-1000)],[],4000)])for(const candidate of I.realize(t).candidates){assert(candidate.circuitRelativeError<1e-9);assert(candidate.circuit.elements.length>=2);checks+=2;}
// jsdom interaction tests: pointer coordinate mapping, conjugacy, numeric edits, import validation, serialization.
const {JSDOM}=require('../testdeps/node_modules/jsdom');
const dom=new JSDOM('<!doctype html><div id="host"></div>',{runScripts:'outside-only'}),w=dom.window;
const scripts=[...fs.readFileSync(__dirname+'/../AnalogStudio.html','utf8').matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m=>m[1]);const core=scripts.find(s=>s.includes('root.AnalogCore ='));assert(core);w.eval(core);w.eval(fs.readFileSync(__dirname+'/../lti-core.js','utf8'));w.eval(fs.readFileSync(__dirname+'/../inverse-mixed.js','utf8'));
let changes=0,downloads=[];const api=w.InverseMixed.mount(w.document.querySelector('#host'),{mode:'mixed',onChange:()=>changes++,onDownload:v=>downloads.push(v)}),q=s=>w.document.querySelector(s);
const bounds={left:0,top:0,width:520,height:360};Object.defineProperty(w.SVGElement.prototype,'getBoundingClientRect',{value:()=>bounds});
const pointer=(el,type,x,y)=>el.dispatchEvent(new w.MouseEvent(type,{bubbles:true,clientX:x,clientY:y,button:0}));
q('[data-tool="zeros"]').click();q('[data-pair]').checked=true;q('[data-pair]').dispatchEvent(new w.Event('change',{bubbles:true}));pointer(q('[data-plane] svg'),'pointerdown',190,100);
let st=api.snapshot();near(st.target.zeros[0].re,-1000);near(st.target.zeros[0].im,1000);assert(st.target.zeros[0].pair);assert.equal(w.InverseMixed.expanded(st.target.zeros).length,2);checks+=2;
q('[data-tool="select"]').click();pointer(q('[data-hit="zeros:0"]'),'pointerdown',190,100);pointer(w.document,'pointermove',225,240);pointer(w.document,'pointerup',225,240);st=api.snapshot();near(st.target.zeros[0].re,-500);near(st.target.zeros[0].im,1000);assert.equal(w.InverseMixed.expanded(st.target.zeros)[1].im,-1000);checks++;
// Single real pole always remains on real axis on drag.
pointer(q('[data-hit="poles:0"]'),'pointerdown',190,170);pointer(w.document,'pointermove',120,70);pointer(w.document,'pointerup',120,70);st=api.snapshot();near(st.target.poles[0].re,-2000);near(st.target.poles[0].im,0);
const input=q('[data-kind="zeros"] [data-coordinate="re"]');input.value='-250';input.dispatchEvent(new w.Event('change',{bubbles:true}));near(api.snapshot().target.zeros[0].re,-250);
q('[data-kind="zeros"] [data-root-pair]').checked=false;q('[data-kind="zeros"] [data-root-pair]').dispatchEvent(new w.Event('change',{bubbles:true}));near(api.snapshot().target.zeros[0].im,0);assert(!api.snapshot().target.zeros[0].pair);checks++;
q('[data-act="export"]').click();assert.equal(downloads.length,1);assert.equal(downloads[0].category,'project');assert.equal(JSON.parse(downloads[0].content).format,'analog-studio-inverse-mixed');checks+=3;
const before=JSON.stringify(api.snapshot());assert.throws(()=>api.load({...api.snapshot(),samplePeriod:0}));assert.equal(JSON.stringify(api.snapshot()),before);checks+=2;
api.load(saved);assert(!q('[data-mixed]').hidden);assert(q('[data-mixed-coefficients]').textContent.includes('Cascade'));assert(q('[data-step] svg'));checks+=3;
api.activate('analog');assert(q('[data-mixed]').hidden);api.activate('mixed');assert(!q('[data-mixed]').hidden);checks+=2;
api.setDigital({b:[.5,.5],a:[1],sampleRate:10000});near(api.snapshot().samplePeriod,.0001);assert.equal(api.getMixed().b.length,3);checks++;
const bad=q('[data-field="gain"]');bad.value='';bad.dispatchEvent(new w.Event('input',{bubbles:true}));bad.dispatchEvent(new w.Event('change',{bubbles:true}));assert.equal(api.snapshot().draft['field:gain'],'');const pending=api.snapshot();api.load(pending);assert.equal(q('[data-field="gain"]').value,'');assert(!q('[data-error]').hidden);q('[data-act="export"]').click();assert.equal(downloads.length,1);checks+=4;
assert(changes>=6);checks++;api.destroy();dom.window.close();
console.log(`InverseMixed: ${checks} numeric, realization, discretization, serialization and DOM checks passed.`);
