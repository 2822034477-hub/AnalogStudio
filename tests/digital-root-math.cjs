'use strict';
const assert=require('node:assert/strict'),D=require('../digital-design.js');
const near=(a,b)=>assert(Math.abs(a-b)<1e-8,`${a} != ${b}`);
function same(a,b){for(const key of ['a','b']){assert.equal(a[key].length,b[key].length);a[key].forEach((x,i)=>near(x,b[key][i]));}}
for(const p of Object.values(D.presets)){const m=D.create(p);same(D.create({...D.factorRoots(m),sampleRate:m.sampleRate,fixed:m.fixed}),m);}
for(const m of [D.create({b:[0,0,.3],a:[1]}),D.create({b:[0,.4,-.1],a:[1,-.7]}),D.create({b:[0],a:[1,-.5]}),D.create({b:[1,-.3,.02],a:[1,-.9,.14]})])same(D.create({...D.factorRoots(m),sampleRate:m.sampleRate,fixed:m.fixed}),m);
let m=D.create({poles:[],gain:1});
m=D.editRoot(m,{action:'add',kind:'poles',re:.6,im:.3,pair:true});assert.equal(D.factorRoots(m).poles.length,1);near(m.a[1],-1.2);near(m.a[2],.45);assert(D.analysis(m).stable);
m=D.editRoot(m,{action:'move',kind:'poles',index:0,re:.8,im:.2,pair:true,sourcePair:true});near(m.a[1],-1.6);near(m.a[2],.68);
m=D.editRoot(m,{action:'move',kind:'poles',index:0,re:.5,im:0,pair:true,sourcePair:true});assert.equal(D.factorRoots(m).poles.length,2);near(m.a[2],.25);
m=D.editRoot(m,{action:'move',kind:'poles',index:0,re:.4,im:.2,pair:true,sourcePair:true});assert.equal(D.factorRoots(m).poles.length,1);near(m.a[2],.2);
m=D.editRoot(m,{action:'delete',kind:'poles',index:0,sourcePair:true});assert.deepEqual(m.a,[1]);
m=D.editRoot(m,{action:'add',kind:'zeros',re:.2,im:0});m=D.editRoot(m,{action:'add',kind:'zeros',re:-.5,im:0});near(m.b[1],.3);near(m.b[2],-.1);
assert.throws(()=>D.editRoot(m,{action:'add',kind:'zeros',re:0,im:0}));
const frozen=JSON.stringify(m);for(const o of [{action:'move',kind:'zeros',index:0,re:Infinity},{action:'move',kind:'zeros',index:8,re:0},{action:'add',kind:'poles',re:101},{action:'add',kind:'poles',re:0,im:.2,pair:false},{action:'delete',kind:'bad',index:0}])assert.throws(()=>D.editRoot(m,o));assert.equal(JSON.stringify(m),frozen);
assert.throws(()=>D.editRoot(D.create({b:[0,0,1],a:[1]}),{action:'add',kind:'zeros',re:.5}));
let delay=D.create({b:[0,.2],a:[1,-.8]});delay=D.editRoot(delay,{action:'move',kind:'poles',index:0,re:1,im:0});assert(D.analysis(delay).marginal);assert.equal(delay.b[0],0);near(delay.b[1],.2);
delay=D.editRoot(delay,{action:'move',kind:'poles',index:0,re:1.2,im:0});assert(!D.analysis(delay).stable);near(delay.a[1],-1.2);
const pair=D.create({poles:[{re:.6,im:.2}],gain:.1});const real=D.editRoot(pair,{action:'move',kind:'poles',index:0,re:.7,im:0,pair:false});assert.equal(real.a.length,2);
console.log('PASS digital root math: coefficient/factor round trips, explicit delay, conjugate movement/axis degeneracy/deletion, real roots, atomic bounds, two-order limit, stable/marginal/unstable.');
