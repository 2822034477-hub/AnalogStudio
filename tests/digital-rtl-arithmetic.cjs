'use strict';
// Independent division/remainder oracle; exercise the generated combinational
// datapath directly, including AW wrapping, ties and signed saturation boundaries.
const fs=require('fs'),path=require('path'),assert=require('node:assert/strict');
const D=require('../digital-design'),R=require('../simulation-runners');
const wrap=(v,w)=>BigInt.asIntN(w,v);
function oracle(acc,cf,ow,nearest){
 const scale=1n<<BigInt(cf),negative=acc<0n,magnitude=negative?-acc:acc;
 let q=magnitude/scale;
 if(nearest ? magnitude%scale*2n>=scale : negative&&magnitude%scale!==0n)q++;
 if(negative)q=-q;
 const min=-(1n<<BigInt(ow-1)),max=-min-1n;
 return q<min?min:q>max?max:q;
}
let checks=0;
for(let cf=0;cf<=10;cf++)for(let n=-2048;n<2048;n++)for(const nearest of [0,1]){
 const v=BigInt(n),floor=v>>BigInt(cf),scale=1n<<BigInt(cf);
 const inc=nearest&&cf>0&&(v&(scale>>1n))!==0n&&(v>=0n||(v&((scale>>1n)-1n))!==0n)?1n:0n;
 const rounded=floor+inc,min=-128n,max=127n;
 assert.equal(rounded<min?min:rounded>max?max:rounded,oracle(v,cf,8,nearest));checks++;
}
console.log('PASS arithmetic identities: '+checks+' exhaustive signed rounding/saturation checks. HDL execution is separate.');
if(!process.argv[2])process.exit(0);
const out=path.resolve(process.argv[2]);fs.mkdirSync(out,{recursive:true});
const model=D.create({poles:[.25,{re:.4,im:.2}],gain:.03,fixed:{sectionBits:20,accumulatorBits:44}});
fs.writeFileSync(path.join(out,'digital_filter.v'),D.generateVerilog(model));
const tb=['`timescale 1ns/1ps'],instances=[];let total=0,seed=1234567n;
const random=w=>{seed=BigInt.asUintN(64,seed*6364136223846793005n+1442695040888963407n);return wrap(seed,w);};
const literal=(v,w)=>w+"'h"+BigInt.asUintN(w,v).toString(16);
for(const [aw,cf,ow] of [[20,0,8],[20,1,8],[24,6,12],[40,15,16],[64,28,32]])for(const order of [1,2])for(const nearest of [0,1]){
 const id=instances.length,kind=order===1?'fo':'so',terms=order===1?['B0','B1','A1']:['B0','B1','B2','A1','A2'];
 const moduleName='probe'+id;instances.push(moduleName+' p'+id+'(.done(done['+id+']));');
 tb.push('module '+moduleName+'(output reg done=0);',...terms.map(t=>'reg signed ['+(aw-1)+':0] e'+t+'=0;'),
  'wire signed ['+(ow-1)+':0] unused;',
  'digital_filter_'+kind+' #(.IW(8),.OW('+ow+'),.CW(8),.CF('+cf+'),.AW('+aw+'),.NEAREST('+nearest+')) dut(.clk(1\'b0),.rst_n(1\'b0),.data_in(8\'sd0),.data_out(unused));',
  'task check;',...terms.map(t=>'input signed ['+(aw-1)+':0] v'+t+';'),'input signed ['+(ow-1)+':0] expected;','begin',...terms.map(t=>'e'+t+'=v'+t+';'),'#1; if(dut.next_y !== expected) begin $display("FAIL arithmetic probe '+id+' got %d expected %d",dut.next_y,expected); $fatal(1); end','end endtask','initial begin',...terms.map(t=>'force dut.E_'+t+' = e'+t+';'));
 const values=new Set([0n,1n,-1n,-(1n<<BigInt(aw-1)),(1n<<BigInt(aw-1))-1n]);
 const scale=1n<<BigInt(cf),half=scale>>1n;
 for(const q of [-((1n<<BigInt(ow-1))+1n),-(1n<<BigInt(ow-1)),-2n,-1n,0n,1n,2n,(1n<<BigInt(ow-1))-1n,1n<<BigInt(ow-1)])for(const offset of [-half-1n,-half,-half+1n,-1n,0n,1n,half-1n,half,half+1n])values.add(wrap(q*scale+offset,aw));
 const samples=[...values].map(v=>[v,...Array(terms.length-1).fill(0n)]);
 for(let i=0;i<256;i++)samples.push(terms.map(()=>random(aw)));
 for(const values of samples){const raw=wrap(values.reduce((s,v,i)=>s+(terms[i][0]==='A'?-v:v),0n),aw),expected=oracle(raw,cf,ow,nearest);tb.push('check('+values.map(v=>literal(v,aw)).concat(literal(expected,ow)).join(',')+');');total++;}
 tb.push('done=1; end','endmodule');
}
tb.push('module digital_filter_tb;','wire ['+(instances.length-1)+':0] done;',...instances,'initial begin wait(&done); $display("PASS: combinational arithmetic probes '+total+'"); $display("SCOPE: combinational probes only; sequential timing checked by vendor fixtures"); $finish; end','initial begin #100000; $fatal(1,"arithmetic timeout"); end','endmodule');
fs.writeFileSync(path.join(out,'digital_filter_tb.sv'),tb.join('\n'));
for(const f of R.generate({passMarker:'PASS: combinational arithmetic probes'}))fs.writeFileSync(path.join(out,f.filename),f.content);
fs.writeFileSync(path.join(out,'arithmetic-coverage.json'),JSON.stringify({identityChecks:checks,rtlChecks:total,configurations:instances.length,scope:'Generated FO/SO CSA + rounding + saturation; forced extended products. Sequential multiplication/reset/latency tested separately.'},null,2));
console.log('Generated '+total+' RTL probes in '+instances.length+' configurations at '+out);
