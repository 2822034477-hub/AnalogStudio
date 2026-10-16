const fs=require('fs'),assert=require('assert');
const {JSDOM}=require('../testdeps/node_modules/jsdom');
const wait=()=>new Promise(r=>setTimeout(r,20));
(async()=>{
for(const name of ['digital-design','inverse-mixed']){
const d=new JSDOM('<div id="mount"></div>',{runScripts:'dangerously',pretendToBeVisual:true});const w=d.window;if(name==='digital-design')for(const dependency of ['digital-sos','digital-width'])w.eval(fs.readFileSync(__dirname+'/../'+dependency+'.js','utf8'));w.eval(fs.readFileSync(__dirname+'/../'+name+'.js','utf8'));
const api=name==='digital-design'?w.DigitalDesign:w.InverseMixed,root=w.document.querySelector('#mount'),adapter=api.mount(root),f=root.querySelector('input[type=file]');
let release;const old=api.defaults(),newer=api.defaults();if(name==='digital-design'){old.model.b=[.333];newer.model.b=[.777];}else{old.target.gain=333;newer.target.gain=777;}
Object.defineProperty(f,'files',{configurable:true,value:[{size:300,text:()=>new Promise(r=>release=r)}]});f.dispatchEvent(new w.Event('change',{bubbles:true}));adapter.replace(newer);release(JSON.stringify(old));await wait();
const s=adapter.snapshot();if(name==='digital-design')assert.deepEqual(Array.from(s.model.b),[.777],'Late digital read must preserve newer project');else assert.equal(s.target.gain,777,'Late inverse read must preserve newer project');console.log('PASS '+name+': late read cannot overwrite a newer project.');d.window.close();}
})().catch(e=>{console.error(e);process.exit(1)});
