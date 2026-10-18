'use strict';
const fs=require('node:fs'),path=require('node:path'),D=require('../digital-design'),S=(()=>{const box={};require('node:vm').runInNewContext(fs.readFileSync(path.join(__dirname,'fixtures/digital-sos-withdrawn.js'),'utf8'),box);return box.DigitalSOS;})();
const out=path.resolve(__dirname,'../test-results/retiming-equivalence');fs.mkdirSync(out,{recursive:true});
const cases=['lowpass','saturation','notch','delay','fir','floor','wide','edited','sos4','sos6','sos8','odd5','delay8','sos_delay','repeated8','sos_clip','width18','latency_fo','latency_so','odd3','odd5_fo','width8','width24','zero_gain'];
const code=[],tb=['`timescale 1ns/1ps'],testModules=[];let checks=0;
const hex=(n,w)=>w+"'h"+BigInt.asUintN(w,BigInt(n)).toString(16);
for(const [i,name]of cases.entries()){
 const dir=path.resolve(__dirname,'../examples/simulation',name),m=D.load(JSON.parse(fs.readFileSync(path.join(dir,'model.json'),'utf8'))),q=D.quantize(m),options=JSON.parse(fs.readFileSync(path.join(dir,'test-options.json'),'utf8')),g=JSON.parse(fs.readFileSync(path.join(dir,'golden.json'),'utf8'));
 const width=options.inputWidth??m.fixed.inputBits,after='case_'+i+'_after',before='case_'+i+'_before';
 code.push(S.verilog(m,q,after),S.legacyVerilog(m,q,before));
 const module='check_'+i;testModules.push(module);
 tb.push('module '+module+'(input clk,output reg done);','reg rst_n=0; reg signed ['+(width-1)+':0] x=0; wire signed ['+(width-1)+':0] y,old_y;',
  after+' #(.IN_WIDTH('+width+')) a(.clk(clk),.rst_n(rst_n),.data_in(x),.data_out(y));',
  before+' #(.IN_WIDTH('+width+')) b(.clk(clk),.rst_n(rst_n),.data_in(x),.data_out(old_y));','initial begin done=0;');
 for(let pass=0;pass<2;pass++){
  tb.push('@(negedge clk); rst_n=0; x=0; @(posedge clk); #1; if(y!==0 || old_y!==0) $fatal(1,"Reset '+name+'");');
  for(let n=0;n<g.inputs.length;n++){
   tb.push('@(negedge clk); rst_n=1; x='+hex(g.inputs[n],width)+'; @(posedge clk); #1;',
    'if(y !== '+hex(g.expected[n],width)+' || y !== old_y) $fatal(1,"Sequential '+name+' sample '+n+' got %h expected %h old %h",y,'+hex(g.expected[n],width)+',old_y);');checks++;
  }
 }
 tb.push('done=1; end endmodule');
}
// Standalone helpers: fixed-width modular accumulation and independent
// division/remainder quantization, including saturated/unstable recurrences.
const helperModel=D.create({poles:[.25,{re:.4,im:.2}],gain:.03,fixed:{sectionBits:20,accumulatorBits:44}}),hq=D.quantize(helperModel);
code.push(S.verilog(helperModel,hq,'helper_after'),S.legacyVerilog(helperModel,hq,'helper_before'));
const quant=(acc,cf,ow,near)=>{const div=1n<<BigInt(cf),neg=acc<0n,abs=neg?-acc:acc;let q=abs/div;const rem=abs%div;if(near?2n*rem>=div:neg&&rem>0n)q++;if(neg)q=-q;const min=-(1n<<BigInt(ow-1)),max=-min-1n;return q<min?min:q>max?max:q;};
let seed=19n,probe=0;const rand=w=>{seed=BigInt.asUintN(64,seed*6364136223846793005n+1n);return BigInt.asIntN(w,seed);};
for(const [iw,ow,cw,cf,aw]of [[8,8,8,0,20],[8,8,8,1,20],[12,16,12,6,32],[16,16,18,15,40],[24,32,30,28,64]])for(const order of [1,2])for(const near of [0,1]){
 const module='helper_check_'+probe++;testModules.push(module);const k=order===2?'so':'fo',limit=1n<<BigInt(cw-1),co=[limit-1n,-limit,limit/3n,-limit+1n,limit-3n];
 const params='.IW('+iw+'),.OW('+ow+'),.CW('+cw+'),.CF('+cf+'),.AW('+aw+'),.NEAREST('+near+'),'+['B0','B1','B2','A1','A2'].filter(t=>order===2||!t.endsWith('2')).map(t=>'.'+t+'('+hex(co[['B0','B1','B2','A1','A2'].indexOf(t)],cw)+')').join(',');
 tb.push('module '+module+'(input clk,output reg done);','reg rst_n=0;reg signed ['+(iw-1)+':0] x=0;wire signed ['+(ow-1)+':0] y,old_y;',
  'helper_after_'+k+' #('+params+') a(.clk(clk),.rst_n(rst_n),.data_in(x),.data_out(y));',
  'helper_before_'+k+' #('+params+') b(.clk(clk),.rst_n(rst_n),.data_in(x),.data_out(old_y));','initial begin done=0;');
 for(let pass=0;pass<2;pass++){
  let x1=0n,x2=0n,y1=0n,y2=0n;
  tb.push('@(negedge clk);rst_n=0;x=0;@(posedge clk);#1;if(y!==0 || old_y!==0)$fatal(1,"Helper reset");');
  for(let n=0;n<192;n++){
   const max=(1n<<BigInt(iw-1))-1n,min=-max-1n,x=n<5?[max,min,0n,1n,-1n][n]:rand(iw);
   const acc=BigInt.asIntN(aw,co[0]*x+co[1]*x1-co[3]*y1+(order===2?co[2]*x2-co[4]*y2:0n)),next=quant(acc,cf,ow,near),expected=order===2?y1:next;
   x2=x1;x1=x;y2=y1;y1=next;
   tb.push('@(negedge clk);rst_n=1;x='+hex(x,iw)+';@(posedge clk);#1;',
    'if(y!=='+hex(expected,ow)+' || y!==old_y)$fatal(1,"Helper '+(probe-1)+' sample '+n+' got %h expected %h old %h",y,'+hex(expected,ow)+',old_y);');checks++;
  }
 }
 tb.push('done=1;end endmodule');
}
tb.push('module retiming_tb;reg clk=0;always #5 clk=~clk;wire ['+(testModules.length-1)+':0] done;',...testModules.map((m,i)=>m+' t'+i+'(clk,done['+i+']);'),
 'initial begin wait(&done);$display("PASS: retiming '+cases.length+' complete filters, '+probe+' helper configurations, '+checks+' sequential mathematical/legacy checks");$finish;end',
 'initial begin #1000000;$fatal(1,"Timeout");end endmodule');
fs.writeFileSync(path.join(out,'filters.v'),code.join('\n'));fs.writeFileSync(path.join(out,'retiming_tb.sv'),tb.join('\n'));fs.writeFileSync(path.join(out,'run.tcl'),'run all\nquit\n');
fs.writeFileSync(path.join(out,'coverage.json'),JSON.stringify({filters:cases.length,helperConfigurations:probe,checks},null,2));console.log('Generated '+checks+' sequential equivalence checks.');
