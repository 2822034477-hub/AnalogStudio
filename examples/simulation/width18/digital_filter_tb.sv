`timescale 1ns/1ps
// Golden vectors exercise 0 saturated outputs per run.
// Zero means this filter/vector pair does not test output clipping.
module digital_filter_tb;
  reg clk=0; always #5 clk=~clk;
  reg rst_n=0;
  reg signed [17:0] data_in=0;
  wire signed [17:0] data_out;
  integer errors=0;
  // Input before capture edge E0; compare after E0 + 5 edges (6 cycles, capture counts as 1).
  digital_filter #(.IN_WIDTH(18)) dut(.clk(clk),.rst_n(rst_n),.data_in(data_in),.data_out(data_out));
  initial begin
    @(posedge clk); #1; if(data_out !== 0) errors=errors+1;
    @(negedge clk); rst_n=1;
    data_in=18'sd131071; @(posedge clk); #1;
    if(data_out !== 18'sd0) begin $display("Mismatch sample 0: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd131072; @(posedge clk); #1;
    if(data_out !== 18'sd0) begin $display("Mismatch sample 1: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd0) begin $display("Mismatch sample 2: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd1; @(posedge clk); #1;
    if(data_out !== 18'sd0) begin $display("Mismatch sample 3: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd1; @(posedge clk); #1;
    if(data_out !== 18'sd0) begin $display("Mismatch sample 4: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd58300; @(posedge clk); #1;
    if(data_out !== 18'sd1704) begin $display("Mismatch sample 5: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd99629; @(posedge clk); #1;
    if(data_out !== 18'sd3305) begin $display("Mismatch sample 6: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd114154; @(posedge clk); #1;
    if(data_out !== 18'sd2899) begin $display("Mismatch sample 7: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd60803; @(posedge clk); #1;
    if(data_out !== 18'sd826) begin $display("Mismatch sample 8: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd111032; @(posedge clk); #1;
    if(data_out !== -18'sd1233) begin $display("Mismatch sample 9: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd18871; @(posedge clk); #1;
    if(data_out !== -18'sd2971) begin $display("Mismatch sample 10: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd39850; @(posedge clk); #1;
    if(data_out !== -18'sd5663) begin $display("Mismatch sample 11: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd92415; @(posedge clk); #1;
    if(data_out !== -18'sd10360) begin $display("Mismatch sample 12: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd1132; @(posedge clk); #1;
    if(data_out !== -18'sd15966) begin $display("Mismatch sample 13: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd117541; @(posedge clk); #1;
    if(data_out !== -18'sd18198) begin $display("Mismatch sample 14: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd124030; @(posedge clk); #1;
    if(data_out !== -18'sd15028) begin $display("Mismatch sample 15: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd15931; @(posedge clk); #1;
    if(data_out !== -18'sd8128) begin $display("Mismatch sample 16: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd84064; @(posedge clk); #1;
    if(data_out !== -18'sd2345) begin $display("Mismatch sample 17: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd122943; @(posedge clk); #1;
    if(data_out !== -18'sd217) begin $display("Mismatch sample 18: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd36718; @(posedge clk); #1;
    if(data_out !== -18'sd2321) begin $display("Mismatch sample 19: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd10551; @(posedge clk); #1;
    if(data_out !== -18'sd4794) begin $display("Mismatch sample 20: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd127380; @(posedge clk); #1;
    if(data_out !== -18'sd4906) begin $display("Mismatch sample 21: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd77795; @(posedge clk); #1;
    if(data_out !== -18'sd1894) begin $display("Mismatch sample 22: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd119782; @(posedge clk); #1;
    if(data_out !== 18'sd4000) begin $display("Mismatch sample 23: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd108019; @(posedge clk); #1;
    if(data_out !== 18'sd9800) begin $display("Mismatch sample 24: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd19448; @(posedge clk); #1;
    if(data_out !== 18'sd12372) begin $display("Mismatch sample 25: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd112697; @(posedge clk); #1;
    if(data_out !== 18'sd12797) begin $display("Mismatch sample 26: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd57978; @(posedge clk); #1;
    if(data_out !== 18'sd13701) begin $display("Mismatch sample 27: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd69521; @(posedge clk); #1;
    if(data_out !== 18'sd16637) begin $display("Mismatch sample 28: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd99260; @(posedge clk); #1;
    if(data_out !== 18'sd18355) begin $display("Mismatch sample 29: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd29717; @(posedge clk); #1;
    if(data_out !== 18'sd15988) begin $display("Mismatch sample 30: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd20402; @(posedge clk); #1;
    if(data_out !== 18'sd8947) begin $display("Mismatch sample 31: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd1195; @(posedge clk); #1;
    if(data_out !== 18'sd1060) begin $display("Mismatch sample 32: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd27472; @(posedge clk); #1;
    if(data_out !== -18'sd2982) begin $display("Mismatch sample 33: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd24497; @(posedge clk); #1;
    if(data_out !== -18'sd1094) begin $display("Mismatch sample 34: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd37218; @(posedge clk); #1;
    if(data_out !== 18'sd3704) begin $display("Mismatch sample 35: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd90457; @(posedge clk); #1;
    if(data_out !== 18'sd7005) begin $display("Mismatch sample 36: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd42268; @(posedge clk); #1;
    if(data_out !== 18'sd7062) begin $display("Mismatch sample 37: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd92403; @(posedge clk); #1;
    if(data_out !== 18'sd4616) begin $display("Mismatch sample 38: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd72118; @(posedge clk); #1;
    if(data_out !== 18'sd1190) begin $display("Mismatch sample 39: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd116125; @(posedge clk); #1;
    if(data_out !== -18'sd1246) begin $display("Mismatch sample 40: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd30120; @(posedge clk); #1;
    if(data_out !== -18'sd679) begin $display("Mismatch sample 41: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd2519; @(posedge clk); #1;
    if(data_out !== 18'sd1724) begin $display("Mismatch sample 42: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd123574; @(posedge clk); #1;
    if(data_out !== 18'sd4796) begin $display("Mismatch sample 43: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd5087; @(posedge clk); #1;
    if(data_out !== 18'sd8289) begin $display("Mismatch sample 44: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd5900; @(posedge clk); #1;
    if(data_out !== 18'sd12709) begin $display("Mismatch sample 45: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd71941; @(posedge clk); #1;
    if(data_out !== 18'sd16210) begin $display("Mismatch sample 46: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd20450; @(posedge clk); #1;
    if(data_out !== 18'sd16721) begin $display("Mismatch sample 47: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd55525; @(posedge clk); #1;
    if(data_out !== 18'sd12498) begin $display("Mismatch sample 48: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd117504; @(posedge clk); #1;
    if(data_out !== 18'sd5153) begin $display("Mismatch sample 49: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd107615; @(posedge clk); #1;
    if(data_out !== -18'sd1619) begin $display("Mismatch sample 50: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd75314; @(posedge clk); #1;
    if(data_out !== -18'sd6203) begin $display("Mismatch sample 51: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd12311; @(posedge clk); #1;
    if(data_out !== -18'sd8755) begin $display("Mismatch sample 52: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd22580; @(posedge clk); #1;
    if(data_out !== -18'sd8834) begin $display("Mismatch sample 53: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd9731; @(posedge clk); #1;
    if(data_out !== -18'sd8177) begin $display("Mismatch sample 54: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd70534; @(posedge clk); #1;
    if(data_out !== -18'sd6634) begin $display("Mismatch sample 55: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd109267; @(posedge clk); #1;
    if(data_out !== -18'sd2973) begin $display("Mismatch sample 56: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd117592; @(posedge clk); #1;
    if(data_out !== 18'sd1805) begin $display("Mismatch sample 57: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd94233; @(posedge clk); #1;
    if(data_out !== 18'sd5646) begin $display("Mismatch sample 58: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd85018; @(posedge clk); #1;
    if(data_out !== 18'sd7403) begin $display("Mismatch sample 59: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd11441; @(posedge clk); #1;
    if(data_out !== 18'sd8121) begin $display("Mismatch sample 60: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd48732; @(posedge clk); #1;
    if(data_out !== 18'sd7093) begin $display("Mismatch sample 61: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd83467; @(posedge clk); #1;
    if(data_out !== 18'sd2608) begin $display("Mismatch sample 62: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd72722; @(posedge clk); #1;
    if(data_out !== -18'sd5131) begin $display("Mismatch sample 63: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd42379; @(posedge clk); #1;
    if(data_out !== -18'sd11502) begin $display("Mismatch sample 64: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd120496; @(posedge clk); #1;
    if(data_out !== -18'sd12907) begin $display("Mismatch sample 65: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd60527; @(posedge clk); #1;
    if(data_out !== -18'sd9277) begin $display("Mismatch sample 66: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd119038; @(posedge clk); #1;
    if(data_out !== -18'sd2527) begin $display("Mismatch sample 67: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd8825; @(posedge clk); #1;
    if(data_out !== 18'sd3226) begin $display("Mismatch sample 68: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd125316; @(posedge clk); #1;
    if(data_out !== 18'sd4882) begin $display("Mismatch sample 69: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd104685; @(posedge clk); #1;
    if(data_out !== 18'sd1339) begin $display("Mismatch sample 70: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd81578; @(posedge clk); #1;
    if(data_out !== -18'sd3916) begin $display("Mismatch sample 71: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd67773; @(posedge clk); #1;
    if(data_out !== -18'sd8580) begin $display("Mismatch sample 72: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd45816; @(posedge clk); #1;
    if(data_out !== -18'sd11378) begin $display("Mismatch sample 73: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd75273; @(posedge clk); #1;
    if(data_out !== -18'sd10182) begin $display("Mismatch sample 74: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd37142; @(posedge clk); #1;
    if(data_out !== -18'sd6729) begin $display("Mismatch sample 75: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd77503; @(posedge clk); #1;
    if(data_out !== -18'sd4909) begin $display("Mismatch sample 76: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd31148; @(posedge clk); #1;
    if(data_out !== -18'sd4846) begin $display("Mismatch sample 77: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd22245; @(posedge clk); #1;
    if(data_out !== -18'sd4055) begin $display("Mismatch sample 78: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd111682; @(posedge clk); #1;
    if(data_out !== -18'sd2677) begin $display("Mismatch sample 79: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd32773; @(posedge clk); #1;
    if(data_out !== -18'sd2410) begin $display("Mismatch sample 80: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd29088; @(posedge clk); #1;
    if(data_out !== -18'sd4441) begin $display("Mismatch sample 81: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd100225; @(posedge clk); #1;
    if(data_out !== -18'sd7052) begin $display("Mismatch sample 82: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd43986; @(posedge clk); #1;
    if(data_out !== -18'sd8385) begin $display("Mismatch sample 83: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd42743; @(posedge clk); #1;
    if(data_out !== -18'sd9373) begin $display("Mismatch sample 84: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd69332; @(posedge clk); #1;
    if(data_out !== -18'sd10122) begin $display("Mismatch sample 85: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd76835; @(posedge clk); #1;
    if(data_out !== -18'sd9423) begin $display("Mismatch sample 86: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd56538; @(posedge clk); #1;
    if(data_out !== -18'sd8268) begin $display("Mismatch sample 87: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd73651; @(posedge clk); #1;
    if(data_out !== -18'sd7110) begin $display("Mismatch sample 88: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd1352; @(posedge clk); #1;
    if(data_out !== -18'sd6271) begin $display("Mismatch sample 89: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd124935; @(posedge clk); #1;
    if(data_out !== -18'sd4717) begin $display("Mismatch sample 90: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd99770; @(posedge clk); #1;
    if(data_out !== -18'sd1221) begin $display("Mismatch sample 91: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd55761; @(posedge clk); #1;
    if(data_out !== 18'sd2511) begin $display("Mismatch sample 92: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd18684; @(posedge clk); #1;
    if(data_out !== 18'sd3392) begin $display("Mismatch sample 93: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd61397; @(posedge clk); #1;
    if(data_out !== 18'sd1165) begin $display("Mismatch sample 94: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd71794; @(posedge clk); #1;
    if(data_out !== -18'sd278) begin $display("Mismatch sample 95: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd84373; @(posedge clk); #1;
    if(data_out !== 18'sd2333) begin $display("Mismatch sample 96: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd127504; @(posedge clk); #1;
    if(data_out !== 18'sd8187) begin $display("Mismatch sample 97: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd46961; @(posedge clk); #1;
    if(data_out !== 18'sd13714) begin $display("Mismatch sample 98: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd105634; @(posedge clk); #1;
    if(data_out !== 18'sd15192) begin $display("Mismatch sample 99: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd101479; @(posedge clk); #1;
    if(data_out !== 18'sd11321) begin $display("Mismatch sample 100: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd79836; @(posedge clk); #1;
    if(data_out !== 18'sd5676) begin $display("Mismatch sample 101: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd95539; @(posedge clk); #1;
    if(data_out !== 18'sd234) begin $display("Mismatch sample 102: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd50954; @(posedge clk); #1;
    if(data_out !== -18'sd4758) begin $display("Mismatch sample 103: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd56285; @(posedge clk); #1;
    if(data_out !== -18'sd7200) begin $display("Mismatch sample 104: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd76696; @(posedge clk); #1;
    if(data_out !== -18'sd7403) begin $display("Mismatch sample 105: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd47639; @(posedge clk); #1;
    if(data_out !== -18'sd7810) begin $display("Mismatch sample 106: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd37002; @(posedge clk); #1;
    if(data_out !== -18'sd7864) begin $display("Mismatch sample 107: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd47519; @(posedge clk); #1;
    if(data_out !== -18'sd6981) begin $display("Mismatch sample 108: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd76876; @(posedge clk); #1;
    if(data_out !== -18'sd4737) begin $display("Mismatch sample 109: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd31547; @(posedge clk); #1;
    if(data_out !== -18'sd814) begin $display("Mismatch sample 110: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd112478; @(posedge clk); #1;
    if(data_out !== 18'sd4212) begin $display("Mismatch sample 111: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd84187; @(posedge clk); #1;
    if(data_out !== 18'sd8889) begin $display("Mismatch sample 112: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd448; @(posedge clk); #1;
    if(data_out !== 18'sd10915) begin $display("Mismatch sample 113: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd23711; @(posedge clk); #1;
    if(data_out !== 18'sd10653) begin $display("Mismatch sample 114: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd130702; @(posedge clk); #1;
    if(data_out !== 18'sd9830) begin $display("Mismatch sample 115: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd101847; @(posedge clk); #1;
    if(data_out !== 18'sd10590) begin $display("Mismatch sample 116: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd5492; @(posedge clk); #1;
    if(data_out !== 18'sd11341) begin $display("Mismatch sample 117: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd16963; @(posedge clk); #1;
    if(data_out !== 18'sd10114) begin $display("Mismatch sample 118: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd710; @(posedge clk); #1;
    if(data_out !== 18'sd7334) begin $display("Mismatch sample 119: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd1171; @(posedge clk); #1;
    if(data_out !== 18'sd2855) begin $display("Mismatch sample 120: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd75240; @(posedge clk); #1;
    if(data_out !== -18'sd3676) begin $display("Mismatch sample 121: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd20519; @(posedge clk); #1;
    if(data_out !== -18'sd10147) begin $display("Mismatch sample 122: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd102234; @(posedge clk); #1;
    if(data_out !== -18'sd13469) begin $display("Mismatch sample 123: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd59663; @(posedge clk); #1;
    if(data_out !== -18'sd12700) begin $display("Mismatch sample 124: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd9116; @(posedge clk); #1;
    if(data_out !== -18'sd9375) begin $display("Mismatch sample 125: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd59979; @(posedge clk); #1;
    if(data_out !== -18'sd4666) begin $display("Mismatch sample 126: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd17618; @(posedge clk); #1;
    if(data_out !== 18'sd338) begin $display("Mismatch sample 127: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd5529) begin $display("Mismatch sample 128: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd9061) begin $display("Mismatch sample 129: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd9658) begin $display("Mismatch sample 130: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd8603) begin $display("Mismatch sample 131: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd7173) begin $display("Mismatch sample 132: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd5705) begin $display("Mismatch sample 133: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd4164) begin $display("Mismatch sample 134: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd2688) begin $display("Mismatch sample 135: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd1503) begin $display("Mismatch sample 136: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd714) begin $display("Mismatch sample 137: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd276) begin $display("Mismatch sample 138: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd75) begin $display("Mismatch sample 139: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd2) begin $display("Mismatch sample 140: %d",data_out); errors=errors+1; end
    @(negedge clk);
    rst_n=0; data_in=18'sd131071; @(posedge clk); #1;
    if(data_out !== 0) errors=errors+1;
    @(negedge clk); rst_n=1;
    data_in=18'sd131071; @(posedge clk); #1;
    if(data_out !== 18'sd0) begin $display("Mismatch post-reset sample 0: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd131072; @(posedge clk); #1;
    if(data_out !== 18'sd0) begin $display("Mismatch post-reset sample 1: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd0) begin $display("Mismatch post-reset sample 2: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd1; @(posedge clk); #1;
    if(data_out !== 18'sd0) begin $display("Mismatch post-reset sample 3: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd1; @(posedge clk); #1;
    if(data_out !== 18'sd0) begin $display("Mismatch post-reset sample 4: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd58300; @(posedge clk); #1;
    if(data_out !== 18'sd1704) begin $display("Mismatch post-reset sample 5: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd99629; @(posedge clk); #1;
    if(data_out !== 18'sd3305) begin $display("Mismatch post-reset sample 6: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd114154; @(posedge clk); #1;
    if(data_out !== 18'sd2899) begin $display("Mismatch post-reset sample 7: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd60803; @(posedge clk); #1;
    if(data_out !== 18'sd826) begin $display("Mismatch post-reset sample 8: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd111032; @(posedge clk); #1;
    if(data_out !== -18'sd1233) begin $display("Mismatch post-reset sample 9: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd18871; @(posedge clk); #1;
    if(data_out !== -18'sd2971) begin $display("Mismatch post-reset sample 10: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd39850; @(posedge clk); #1;
    if(data_out !== -18'sd5663) begin $display("Mismatch post-reset sample 11: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd92415; @(posedge clk); #1;
    if(data_out !== -18'sd10360) begin $display("Mismatch post-reset sample 12: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd1132; @(posedge clk); #1;
    if(data_out !== -18'sd15966) begin $display("Mismatch post-reset sample 13: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd117541; @(posedge clk); #1;
    if(data_out !== -18'sd18198) begin $display("Mismatch post-reset sample 14: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd124030; @(posedge clk); #1;
    if(data_out !== -18'sd15028) begin $display("Mismatch post-reset sample 15: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd15931; @(posedge clk); #1;
    if(data_out !== -18'sd8128) begin $display("Mismatch post-reset sample 16: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd84064; @(posedge clk); #1;
    if(data_out !== -18'sd2345) begin $display("Mismatch post-reset sample 17: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd122943; @(posedge clk); #1;
    if(data_out !== -18'sd217) begin $display("Mismatch post-reset sample 18: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd36718; @(posedge clk); #1;
    if(data_out !== -18'sd2321) begin $display("Mismatch post-reset sample 19: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd10551; @(posedge clk); #1;
    if(data_out !== -18'sd4794) begin $display("Mismatch post-reset sample 20: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd127380; @(posedge clk); #1;
    if(data_out !== -18'sd4906) begin $display("Mismatch post-reset sample 21: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd77795; @(posedge clk); #1;
    if(data_out !== -18'sd1894) begin $display("Mismatch post-reset sample 22: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd119782; @(posedge clk); #1;
    if(data_out !== 18'sd4000) begin $display("Mismatch post-reset sample 23: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd108019; @(posedge clk); #1;
    if(data_out !== 18'sd9800) begin $display("Mismatch post-reset sample 24: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd19448; @(posedge clk); #1;
    if(data_out !== 18'sd12372) begin $display("Mismatch post-reset sample 25: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd112697; @(posedge clk); #1;
    if(data_out !== 18'sd12797) begin $display("Mismatch post-reset sample 26: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd57978; @(posedge clk); #1;
    if(data_out !== 18'sd13701) begin $display("Mismatch post-reset sample 27: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd69521; @(posedge clk); #1;
    if(data_out !== 18'sd16637) begin $display("Mismatch post-reset sample 28: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd99260; @(posedge clk); #1;
    if(data_out !== 18'sd18355) begin $display("Mismatch post-reset sample 29: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd29717; @(posedge clk); #1;
    if(data_out !== 18'sd15988) begin $display("Mismatch post-reset sample 30: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd20402; @(posedge clk); #1;
    if(data_out !== 18'sd8947) begin $display("Mismatch post-reset sample 31: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd1195; @(posedge clk); #1;
    if(data_out !== 18'sd1060) begin $display("Mismatch post-reset sample 32: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd27472; @(posedge clk); #1;
    if(data_out !== -18'sd2982) begin $display("Mismatch post-reset sample 33: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd24497; @(posedge clk); #1;
    if(data_out !== -18'sd1094) begin $display("Mismatch post-reset sample 34: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd37218; @(posedge clk); #1;
    if(data_out !== 18'sd3704) begin $display("Mismatch post-reset sample 35: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd90457; @(posedge clk); #1;
    if(data_out !== 18'sd7005) begin $display("Mismatch post-reset sample 36: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd42268; @(posedge clk); #1;
    if(data_out !== 18'sd7062) begin $display("Mismatch post-reset sample 37: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd92403; @(posedge clk); #1;
    if(data_out !== 18'sd4616) begin $display("Mismatch post-reset sample 38: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd72118; @(posedge clk); #1;
    if(data_out !== 18'sd1190) begin $display("Mismatch post-reset sample 39: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd116125; @(posedge clk); #1;
    if(data_out !== -18'sd1246) begin $display("Mismatch post-reset sample 40: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd30120; @(posedge clk); #1;
    if(data_out !== -18'sd679) begin $display("Mismatch post-reset sample 41: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd2519; @(posedge clk); #1;
    if(data_out !== 18'sd1724) begin $display("Mismatch post-reset sample 42: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd123574; @(posedge clk); #1;
    if(data_out !== 18'sd4796) begin $display("Mismatch post-reset sample 43: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd5087; @(posedge clk); #1;
    if(data_out !== 18'sd8289) begin $display("Mismatch post-reset sample 44: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd5900; @(posedge clk); #1;
    if(data_out !== 18'sd12709) begin $display("Mismatch post-reset sample 45: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd71941; @(posedge clk); #1;
    if(data_out !== 18'sd16210) begin $display("Mismatch post-reset sample 46: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd20450; @(posedge clk); #1;
    if(data_out !== 18'sd16721) begin $display("Mismatch post-reset sample 47: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd55525; @(posedge clk); #1;
    if(data_out !== 18'sd12498) begin $display("Mismatch post-reset sample 48: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd117504; @(posedge clk); #1;
    if(data_out !== 18'sd5153) begin $display("Mismatch post-reset sample 49: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd107615; @(posedge clk); #1;
    if(data_out !== -18'sd1619) begin $display("Mismatch post-reset sample 50: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd75314; @(posedge clk); #1;
    if(data_out !== -18'sd6203) begin $display("Mismatch post-reset sample 51: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd12311; @(posedge clk); #1;
    if(data_out !== -18'sd8755) begin $display("Mismatch post-reset sample 52: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd22580; @(posedge clk); #1;
    if(data_out !== -18'sd8834) begin $display("Mismatch post-reset sample 53: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd9731; @(posedge clk); #1;
    if(data_out !== -18'sd8177) begin $display("Mismatch post-reset sample 54: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd70534; @(posedge clk); #1;
    if(data_out !== -18'sd6634) begin $display("Mismatch post-reset sample 55: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd109267; @(posedge clk); #1;
    if(data_out !== -18'sd2973) begin $display("Mismatch post-reset sample 56: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd117592; @(posedge clk); #1;
    if(data_out !== 18'sd1805) begin $display("Mismatch post-reset sample 57: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd94233; @(posedge clk); #1;
    if(data_out !== 18'sd5646) begin $display("Mismatch post-reset sample 58: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd85018; @(posedge clk); #1;
    if(data_out !== 18'sd7403) begin $display("Mismatch post-reset sample 59: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd11441; @(posedge clk); #1;
    if(data_out !== 18'sd8121) begin $display("Mismatch post-reset sample 60: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd48732; @(posedge clk); #1;
    if(data_out !== 18'sd7093) begin $display("Mismatch post-reset sample 61: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd83467; @(posedge clk); #1;
    if(data_out !== 18'sd2608) begin $display("Mismatch post-reset sample 62: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd72722; @(posedge clk); #1;
    if(data_out !== -18'sd5131) begin $display("Mismatch post-reset sample 63: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd42379; @(posedge clk); #1;
    if(data_out !== -18'sd11502) begin $display("Mismatch post-reset sample 64: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd120496; @(posedge clk); #1;
    if(data_out !== -18'sd12907) begin $display("Mismatch post-reset sample 65: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd60527; @(posedge clk); #1;
    if(data_out !== -18'sd9277) begin $display("Mismatch post-reset sample 66: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd119038; @(posedge clk); #1;
    if(data_out !== -18'sd2527) begin $display("Mismatch post-reset sample 67: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd8825; @(posedge clk); #1;
    if(data_out !== 18'sd3226) begin $display("Mismatch post-reset sample 68: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd125316; @(posedge clk); #1;
    if(data_out !== 18'sd4882) begin $display("Mismatch post-reset sample 69: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd104685; @(posedge clk); #1;
    if(data_out !== 18'sd1339) begin $display("Mismatch post-reset sample 70: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd81578; @(posedge clk); #1;
    if(data_out !== -18'sd3916) begin $display("Mismatch post-reset sample 71: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd67773; @(posedge clk); #1;
    if(data_out !== -18'sd8580) begin $display("Mismatch post-reset sample 72: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd45816; @(posedge clk); #1;
    if(data_out !== -18'sd11378) begin $display("Mismatch post-reset sample 73: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd75273; @(posedge clk); #1;
    if(data_out !== -18'sd10182) begin $display("Mismatch post-reset sample 74: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd37142; @(posedge clk); #1;
    if(data_out !== -18'sd6729) begin $display("Mismatch post-reset sample 75: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd77503; @(posedge clk); #1;
    if(data_out !== -18'sd4909) begin $display("Mismatch post-reset sample 76: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd31148; @(posedge clk); #1;
    if(data_out !== -18'sd4846) begin $display("Mismatch post-reset sample 77: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd22245; @(posedge clk); #1;
    if(data_out !== -18'sd4055) begin $display("Mismatch post-reset sample 78: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd111682; @(posedge clk); #1;
    if(data_out !== -18'sd2677) begin $display("Mismatch post-reset sample 79: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd32773; @(posedge clk); #1;
    if(data_out !== -18'sd2410) begin $display("Mismatch post-reset sample 80: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd29088; @(posedge clk); #1;
    if(data_out !== -18'sd4441) begin $display("Mismatch post-reset sample 81: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd100225; @(posedge clk); #1;
    if(data_out !== -18'sd7052) begin $display("Mismatch post-reset sample 82: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd43986; @(posedge clk); #1;
    if(data_out !== -18'sd8385) begin $display("Mismatch post-reset sample 83: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd42743; @(posedge clk); #1;
    if(data_out !== -18'sd9373) begin $display("Mismatch post-reset sample 84: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd69332; @(posedge clk); #1;
    if(data_out !== -18'sd10122) begin $display("Mismatch post-reset sample 85: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd76835; @(posedge clk); #1;
    if(data_out !== -18'sd9423) begin $display("Mismatch post-reset sample 86: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd56538; @(posedge clk); #1;
    if(data_out !== -18'sd8268) begin $display("Mismatch post-reset sample 87: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd73651; @(posedge clk); #1;
    if(data_out !== -18'sd7110) begin $display("Mismatch post-reset sample 88: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd1352; @(posedge clk); #1;
    if(data_out !== -18'sd6271) begin $display("Mismatch post-reset sample 89: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd124935; @(posedge clk); #1;
    if(data_out !== -18'sd4717) begin $display("Mismatch post-reset sample 90: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd99770; @(posedge clk); #1;
    if(data_out !== -18'sd1221) begin $display("Mismatch post-reset sample 91: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd55761; @(posedge clk); #1;
    if(data_out !== 18'sd2511) begin $display("Mismatch post-reset sample 92: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd18684; @(posedge clk); #1;
    if(data_out !== 18'sd3392) begin $display("Mismatch post-reset sample 93: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd61397; @(posedge clk); #1;
    if(data_out !== 18'sd1165) begin $display("Mismatch post-reset sample 94: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd71794; @(posedge clk); #1;
    if(data_out !== -18'sd278) begin $display("Mismatch post-reset sample 95: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd84373; @(posedge clk); #1;
    if(data_out !== 18'sd2333) begin $display("Mismatch post-reset sample 96: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd127504; @(posedge clk); #1;
    if(data_out !== 18'sd8187) begin $display("Mismatch post-reset sample 97: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd46961; @(posedge clk); #1;
    if(data_out !== 18'sd13714) begin $display("Mismatch post-reset sample 98: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd105634; @(posedge clk); #1;
    if(data_out !== 18'sd15192) begin $display("Mismatch post-reset sample 99: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd101479; @(posedge clk); #1;
    if(data_out !== 18'sd11321) begin $display("Mismatch post-reset sample 100: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd79836; @(posedge clk); #1;
    if(data_out !== 18'sd5676) begin $display("Mismatch post-reset sample 101: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd95539; @(posedge clk); #1;
    if(data_out !== 18'sd234) begin $display("Mismatch post-reset sample 102: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd50954; @(posedge clk); #1;
    if(data_out !== -18'sd4758) begin $display("Mismatch post-reset sample 103: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd56285; @(posedge clk); #1;
    if(data_out !== -18'sd7200) begin $display("Mismatch post-reset sample 104: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd76696; @(posedge clk); #1;
    if(data_out !== -18'sd7403) begin $display("Mismatch post-reset sample 105: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd47639; @(posedge clk); #1;
    if(data_out !== -18'sd7810) begin $display("Mismatch post-reset sample 106: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd37002; @(posedge clk); #1;
    if(data_out !== -18'sd7864) begin $display("Mismatch post-reset sample 107: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd47519; @(posedge clk); #1;
    if(data_out !== -18'sd6981) begin $display("Mismatch post-reset sample 108: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd76876; @(posedge clk); #1;
    if(data_out !== -18'sd4737) begin $display("Mismatch post-reset sample 109: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd31547; @(posedge clk); #1;
    if(data_out !== -18'sd814) begin $display("Mismatch post-reset sample 110: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd112478; @(posedge clk); #1;
    if(data_out !== 18'sd4212) begin $display("Mismatch post-reset sample 111: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd84187; @(posedge clk); #1;
    if(data_out !== 18'sd8889) begin $display("Mismatch post-reset sample 112: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd448; @(posedge clk); #1;
    if(data_out !== 18'sd10915) begin $display("Mismatch post-reset sample 113: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd23711; @(posedge clk); #1;
    if(data_out !== 18'sd10653) begin $display("Mismatch post-reset sample 114: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd130702; @(posedge clk); #1;
    if(data_out !== 18'sd9830) begin $display("Mismatch post-reset sample 115: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd101847; @(posedge clk); #1;
    if(data_out !== 18'sd10590) begin $display("Mismatch post-reset sample 116: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd5492; @(posedge clk); #1;
    if(data_out !== 18'sd11341) begin $display("Mismatch post-reset sample 117: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd16963; @(posedge clk); #1;
    if(data_out !== 18'sd10114) begin $display("Mismatch post-reset sample 118: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd710; @(posedge clk); #1;
    if(data_out !== 18'sd7334) begin $display("Mismatch post-reset sample 119: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd1171; @(posedge clk); #1;
    if(data_out !== 18'sd2855) begin $display("Mismatch post-reset sample 120: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd75240; @(posedge clk); #1;
    if(data_out !== -18'sd3676) begin $display("Mismatch post-reset sample 121: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd20519; @(posedge clk); #1;
    if(data_out !== -18'sd10147) begin $display("Mismatch post-reset sample 122: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd102234; @(posedge clk); #1;
    if(data_out !== -18'sd13469) begin $display("Mismatch post-reset sample 123: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd59663; @(posedge clk); #1;
    if(data_out !== -18'sd12700) begin $display("Mismatch post-reset sample 124: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd9116; @(posedge clk); #1;
    if(data_out !== -18'sd9375) begin $display("Mismatch post-reset sample 125: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd59979; @(posedge clk); #1;
    if(data_out !== -18'sd4666) begin $display("Mismatch post-reset sample 126: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-18'sd17618; @(posedge clk); #1;
    if(data_out !== 18'sd338) begin $display("Mismatch post-reset sample 127: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd5529) begin $display("Mismatch post-reset sample 128: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd9061) begin $display("Mismatch post-reset sample 129: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd9658) begin $display("Mismatch post-reset sample 130: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd8603) begin $display("Mismatch post-reset sample 131: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd7173) begin $display("Mismatch post-reset sample 132: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd5705) begin $display("Mismatch post-reset sample 133: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd4164) begin $display("Mismatch post-reset sample 134: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd2688) begin $display("Mismatch post-reset sample 135: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd1503) begin $display("Mismatch post-reset sample 136: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd714) begin $display("Mismatch post-reset sample 137: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd276) begin $display("Mismatch post-reset sample 138: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd75) begin $display("Mismatch post-reset sample 139: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=18'sd0; @(posedge clk); #1;
    if(data_out !== 18'sd2) begin $display("Mismatch post-reset sample 140: %d",data_out); errors=errors+1; end
    @(negedge clk);
    $display("TIMING: FO1/SO2, capture counts as cycle 1; total 6 cycles; edge offset 5; model delay 0");
    $display("Golden vector saturation count per run: 0");
    if(errors==0) $display("PASS: four-port SOS, continuous samples, reset, latency");
    else $fatal(1,"FAIL: %d mismatches",errors);
    $finish;
  end
endmodule
