`timescale 1ns/1ps
// Golden vectors exercise 0 saturated outputs per run.
// Zero means this filter/vector pair does not test output clipping.
module digital_filter_tb;
  reg clk=0; always #5 clk=~clk;
  reg rst_n=0;
  reg signed [15:0] data_in=0;
  wire signed [15:0] data_out;
  integer errors=0;
  // Input before capture edge E0; compare after E0 + 1 edges (2 cycles, capture counts as 1).
  digital_filter dut(.clk(clk),.rst_n(rst_n),.data_in(data_in),.data_out(data_out));
  initial begin
    @(posedge clk); #1; if(data_out !== 0) errors=errors+1;
    @(negedge clk); rst_n=1;
    data_in=16'sd32767; @(posedge clk); #1;
    if(data_out !== 16'sd0) begin $display("Mismatch sample 0: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32768; @(posedge clk); #1;
    if(data_out !== 16'sd16384) begin $display("Mismatch sample 1: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd8192) begin $display("Mismatch sample 2: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd1; @(posedge clk); #1;
    if(data_out !== -16'sd6144) begin $display("Mismatch sample 3: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1; @(posedge clk); #1;
    if(data_out !== -16'sd2048) begin $display("Mismatch sample 4: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd25532; @(posedge clk); #1;
    if(data_out !== -16'sd257) begin $display("Mismatch sample 5: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1325; @(posedge clk); #1;
    if(data_out !== -16'sd12639) begin $display("Mismatch sample 6: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd15850; @(posedge clk); #1;
    if(data_out !== -16'sd6950) begin $display("Mismatch sample 7: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28035; @(posedge clk); #1;
    if(data_out !== -16'sd9820) begin $display("Mismatch sample 8: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12728; @(posedge clk); #1;
    if(data_out !== -16'sd18059) begin $display("Mismatch sample 9: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13897; @(posedge clk); #1;
    if(data_out !== -16'sd1438) begin $display("Mismatch sample 10: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd7082; @(posedge clk); #1;
    if(data_out !== -16'sd5410) begin $display("Mismatch sample 11: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5889; @(posedge clk); #1;
    if(data_out !== 16'sd1016) begin $display("Mismatch sample 12: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd31636; @(posedge clk); #1;
    if(data_out !== 16'sd4129) begin $display("Mismatch sample 13: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19237; @(posedge clk); #1;
    if(data_out !== -16'sd13881) begin $display("Mismatch sample 14: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25726; @(posedge clk); #1;
    if(data_out !== -16'sd17075) begin $display("Mismatch sample 15: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd16837; @(posedge clk); #1;
    if(data_out !== 16'sd6061) begin $display("Mismatch sample 16: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14240; @(posedge clk); #1;
    if(data_out !== 16'sd13583) begin $display("Mismatch sample 17: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd24639; @(posedge clk); #1;
    if(data_out !== -16'sd1086) begin $display("Mismatch sample 18: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3950; @(posedge clk); #1;
    if(data_out !== 16'sd10079) begin $display("Mismatch sample 19: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22217; @(posedge clk); #1;
    if(data_out !== 16'sd3200) begin $display("Mismatch sample 20: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd29076; @(posedge clk); #1;
    if(data_out !== 16'sd11449) begin $display("Mismatch sample 21: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd20509; @(posedge clk); #1;
    if(data_out !== 16'sd19863) begin $display("Mismatch sample 22: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd21478; @(posedge clk); #1;
    if(data_out !== -16'sd1754) begin $display("Mismatch sample 23: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9715; @(posedge clk); #1;
    if(data_out !== 16'sd7379) begin $display("Mismatch sample 24: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd13320; @(posedge clk); #1;
    if(data_out !== -16'sd949) begin $display("Mismatch sample 25: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14393; @(posedge clk); #1;
    if(data_out !== 16'sd5263) begin $display("Mismatch sample 26: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25210; @(posedge clk); #1;
    if(data_out !== -16'sd4446) begin $display("Mismatch sample 27: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28783; @(posedge clk); #1;
    if(data_out !== 16'sd9724) begin $display("Mismatch sample 28: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd956; @(posedge clk); #1;
    if(data_out !== -16'sd8974) begin $display("Mismatch sample 29: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd3051; @(posedge clk); #1;
    if(data_out !== -16'sd5225) begin $display("Mismatch sample 30: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12366; @(posedge clk); #1;
    if(data_out !== 16'sd35) begin $display("Mismatch sample 31: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd31573; @(posedge clk); #1;
    if(data_out !== 16'sd6854) begin $display("Mismatch sample 32: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5296; @(posedge clk); #1;
    if(data_out !== 16'sd19209) begin $display("Mismatch sample 33: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd8271; @(posedge clk); #1;
    if(data_out !== 16'sd11396) begin $display("Mismatch sample 34: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4450; @(posedge clk); #1;
    if(data_out !== 16'sd7432) begin $display("Mismatch sample 35: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd7847; @(posedge clk); #1;
    if(data_out !== 16'sd4517) begin $display("Mismatch sample 36: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9500; @(posedge clk); #1;
    if(data_out !== -16'sd2594) begin $display("Mismatch sample 37: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd5901; @(posedge clk); #1;
    if(data_out !== -16'sd6612) begin $display("Mismatch sample 38: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26186; @(posedge clk); #1;
    if(data_out !== -16'sd5932) begin $display("Mismatch sample 39: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd17821; @(posedge clk); #1;
    if(data_out !== -16'sd15233) begin $display("Mismatch sample 40: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd2648; @(posedge clk); #1;
    if(data_out !== 16'sd2036) begin $display("Mismatch sample 41: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd30249; @(posedge clk); #1;
    if(data_out !== 16'sd4246) begin $display("Mismatch sample 42: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd25270; @(posedge clk); #1;
    if(data_out !== -16'sd13256) begin $display("Mismatch sample 43: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27681; @(posedge clk); #1;
    if(data_out !== -16'sd19794) begin $display("Mismatch sample 44: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26868; @(posedge clk); #1;
    if(data_out !== 16'sd5601) begin $display("Mismatch sample 45: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26363; @(posedge clk); #1;
    if(data_out !== -16'sd8159) begin $display("Mismatch sample 46: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12318; @(posedge clk); #1;
    if(data_out !== 16'sd8402) begin $display("Mismatch sample 47: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22757; @(posedge clk); #1;
    if(data_out !== 16'sd11380) begin $display("Mismatch sample 48: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19200; @(posedge clk); #1;
    if(data_out !== 16'sd16018) begin $display("Mismatch sample 49: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd9311; @(posedge clk); #1;
    if(data_out !== -16'sd3014) begin $display("Mismatch sample 50: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd22990; @(posedge clk); #1;
    if(data_out !== 16'sd1146) begin $display("Mismatch sample 51: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd20457; @(posedge clk); #1;
    if(data_out !== -16'sd10545) begin $display("Mismatch sample 52: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd10188; @(posedge clk); #1;
    if(data_out !== 16'sd4813) begin $display("Mismatch sample 53: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23037; @(posedge clk); #1;
    if(data_out !== -16'sd1369) begin $display("Mismatch sample 54: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd27770; @(posedge clk); #1;
    if(data_out !== -16'sd12805) begin $display("Mismatch sample 55: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd10963; @(posedge clk); #1;
    if(data_out !== -16'sd20116) begin $display("Mismatch sample 56: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19288; @(posedge clk); #1;
    if(data_out !== -16'sd13939) begin $display("Mismatch sample 57: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4071; @(posedge clk); #1;
    if(data_out !== -16'sd14099) begin $display("Mismatch sample 58: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13286; @(posedge clk); #1;
    if(data_out !== -16'sd3272) begin $display("Mismatch sample 59: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21327; @(posedge clk); #1;
    if(data_out !== -16'sd6517) begin $display("Mismatch sample 60: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd15964; @(posedge clk); #1;
    if(data_out !== -16'sd13513) begin $display("Mismatch sample 61: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14837; @(posedge clk); #1;
    if(data_out !== 16'sd2040) begin $display("Mismatch sample 62: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25582; @(posedge clk); #1;
    if(data_out !== -16'sd4709) begin $display("Mismatch sample 63: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9611; @(posedge clk); #1;
    if(data_out !== 16'sd10182) begin $display("Mismatch sample 64: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd22192; @(posedge clk); #1;
    if(data_out !== 16'sd874) begin $display("Mismatch sample 65: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27759; @(posedge clk); #1;
    if(data_out !== -16'sd11932) begin $display("Mismatch sample 66: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd20734; @(posedge clk); #1;
    if(data_out !== 16'sd7804) begin $display("Mismatch sample 67: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23943; @(posedge clk); #1;
    if(data_out !== -16'sd4974) begin $display("Mismatch sample 68: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27012; @(posedge clk); #1;
    if(data_out !== -16'sd15434) begin $display("Mismatch sample 69: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd6381; @(posedge clk); #1;
    if(data_out !== 16'sd6411) begin $display("Mismatch sample 70: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd16726; @(posedge clk); #1;
    if(data_out !== 16'sd1944) begin $display("Mismatch sample 71: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd30531; @(posedge clk); #1;
    if(data_out !== 16'sd8534) begin $display("Mismatch sample 72: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd13048; @(posedge clk); #1;
    if(data_out !== -16'sd11242) begin $display("Mismatch sample 73: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd23031; @(posedge clk); #1;
    if(data_out !== -16'sd164) begin $display("Mismatch sample 74: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd4374; @(posedge clk); #1;
    if(data_out !== 16'sd12839) begin $display("Mismatch sample 75: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd20801; @(posedge clk); #1;
    if(data_out !== 16'sd4253) begin $display("Mismatch sample 76: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1620; @(posedge clk); #1;
    if(data_out !== 16'sd10922) begin $display("Mismatch sample 77: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd10523; @(posedge clk); #1;
    if(data_out !== 16'sd4119) begin $display("Mismatch sample 78: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13378; @(posedge clk); #1;
    if(data_out !== 16'sd5956) begin $display("Mismatch sample 79: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5; @(posedge clk); #1;
    if(data_out !== -16'sd4226) begin $display("Mismatch sample 80: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3680; @(posedge clk); #1;
    if(data_out !== -16'sd2855) begin $display("Mismatch sample 81: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1921; @(posedge clk); #1;
    if(data_out !== -16'sd2739) begin $display("Mismatch sample 82: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd11218; @(posedge clk); #1;
    if(data_out !== -16'sd1973) begin $display("Mismatch sample 83: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9975; @(posedge clk); #1;
    if(data_out !== 16'sd4965) begin $display("Mismatch sample 84: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28972; @(posedge clk); #1;
    if(data_out !== -16'sd2258) begin $display("Mismatch sample 85: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21469; @(posedge clk); #1;
    if(data_out !== -16'sd16236) begin $display("Mismatch sample 86: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23770; @(posedge clk); #1;
    if(data_out !== -16'sd18570) begin $display("Mismatch sample 87: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd24653; @(posedge clk); #1;
    if(data_out !== -16'sd19141) begin $display("Mismatch sample 88: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd31416; @(posedge clk); #1;
    if(data_out !== 16'sd5077) begin $display("Mismatch sample 89: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26631; @(posedge clk); #1;
    if(data_out !== -16'sd10777) begin $display("Mismatch sample 90: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd1466; @(posedge clk); #1;
    if(data_out !== 16'sd7292) begin $display("Mismatch sample 91: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22993; @(posedge clk); #1;
    if(data_out !== 16'sd5726) begin $display("Mismatch sample 92: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14084; @(posedge clk); #1;
    if(data_out !== 16'sd13448) begin $display("Mismatch sample 93: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28629; @(posedge clk); #1;
    if(data_out !== -16'sd1034) begin $display("Mismatch sample 94: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26510; @(posedge clk); #1;
    if(data_out !== -16'sd16513) begin $display("Mismatch sample 95: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13931; @(posedge clk); #1;
    if(data_out !== 16'sd5128) begin $display("Mismatch sample 96: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd29200; @(posedge clk); #1;
    if(data_out !== -16'sd2337) begin $display("Mismatch sample 97: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14193; @(posedge clk); #1;
    if(data_out !== -16'sd16410) begin $display("Mismatch sample 98: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd7330; @(posedge clk); #1;
    if(data_out !== -16'sd15009) begin $display("Mismatch sample 99: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3175; @(posedge clk); #1;
    if(data_out !== -16'sd1788) begin $display("Mismatch sample 100: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd18468; @(posedge clk); #1;
    if(data_out !== -16'sd605) begin $display("Mismatch sample 101: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd2765; @(posedge clk); #1;
    if(data_out !== 16'sd9155) begin $display("Mismatch sample 102: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd18186; @(posedge clk); #1;
    if(data_out !== 16'sd3271) begin $display("Mismatch sample 103: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd23517; @(posedge clk); #1;
    if(data_out !== -16'sd8602) begin $display("Mismatch sample 104: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21608; @(posedge clk); #1;
    if(data_out !== 16'sd7049) begin $display("Mismatch sample 105: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14871; @(posedge clk); #1;
    if(data_out !== -16'sd6204) begin $display("Mismatch sample 106: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4234; @(posedge clk); #1;
    if(data_out !== 16'sd3452) begin $display("Mismatch sample 107: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14751; @(posedge clk); #1;
    if(data_out !== 16'sd4619) begin $display("Mismatch sample 108: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21428; @(posedge clk); #1;
    if(data_out !== -16'sd5498) begin $display("Mismatch sample 109: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1221; @(posedge clk); #1;
    if(data_out !== -16'sd14040) begin $display("Mismatch sample 110: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14174; @(posedge clk); #1;
    if(data_out !== -16'sd6943) begin $display("Mismatch sample 111: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14117; @(posedge clk); #1;
    if(data_out !== 16'sd5371) begin $display("Mismatch sample 112: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd32320; @(posedge clk); #1;
    if(data_out !== 16'sd10612) begin $display("Mismatch sample 113: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9057; @(posedge clk); #1;
    if(data_out !== 16'sd20795) begin $display("Mismatch sample 114: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32398; @(posedge clk); #1;
    if(data_out !== 16'sd4543) begin $display("Mismatch sample 115: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3543; @(posedge clk); #1;
    if(data_out !== -16'sd16527) begin $display("Mismatch sample 116: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd27276; @(posedge clk); #1;
    if(data_out !== -16'sd10603) begin $display("Mismatch sample 117: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd15805; @(posedge clk); #1;
    if(data_out !== -16'sd16874) begin $display("Mismatch sample 118: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32058; @(posedge clk); #1;
    if(data_out !== -16'sd15014) begin $display("Mismatch sample 119: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd31597; @(posedge clk); #1;
    if(data_out !== -16'sd21427) begin $display("Mismatch sample 120: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23064; @(posedge clk); #1;
    if(data_out !== 16'sd6962) begin $display("Mismatch sample 121: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd12249; @(posedge clk); #1;
    if(data_out !== -16'sd5373) begin $display("Mismatch sample 122: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd3930; @(posedge clk); #1;
    if(data_out !== -16'sd9681) begin $display("Mismatch sample 123: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26895; @(posedge clk); #1;
    if(data_out !== -16'sd2204) begin $display("Mismatch sample 124: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23652; @(posedge clk); #1;
    if(data_out !== -16'sd13339) begin $display("Mismatch sample 125: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27211; @(posedge clk); #1;
    if(data_out !== -16'sd18220) begin $display("Mismatch sample 126: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd15150; @(posedge clk); #1;
    if(data_out !== 16'sd6163) begin $display("Mismatch sample 127: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd12934) begin $display("Mismatch sample 128: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd5697) begin $display("Mismatch sample 129: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd1232) begin $display("Mismatch sample 130: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd96) begin $display("Mismatch sample 131: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd202) begin $display("Mismatch sample 132: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd89) begin $display("Mismatch sample 133: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd19) begin $display("Mismatch sample 134: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd2) begin $display("Mismatch sample 135: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd3) begin $display("Mismatch sample 136: %d",data_out); errors=errors+1; end
    @(negedge clk);
    rst_n=0; data_in=16'sd32767; @(posedge clk); #1;
    if(data_out !== 0) errors=errors+1;
    @(negedge clk); rst_n=1;
    data_in=16'sd32767; @(posedge clk); #1;
    if(data_out !== 16'sd0) begin $display("Mismatch post-reset sample 0: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32768; @(posedge clk); #1;
    if(data_out !== 16'sd16384) begin $display("Mismatch post-reset sample 1: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd8192) begin $display("Mismatch post-reset sample 2: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd1; @(posedge clk); #1;
    if(data_out !== -16'sd6144) begin $display("Mismatch post-reset sample 3: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1; @(posedge clk); #1;
    if(data_out !== -16'sd2048) begin $display("Mismatch post-reset sample 4: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd25532; @(posedge clk); #1;
    if(data_out !== -16'sd257) begin $display("Mismatch post-reset sample 5: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1325; @(posedge clk); #1;
    if(data_out !== -16'sd12639) begin $display("Mismatch post-reset sample 6: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd15850; @(posedge clk); #1;
    if(data_out !== -16'sd6950) begin $display("Mismatch post-reset sample 7: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28035; @(posedge clk); #1;
    if(data_out !== -16'sd9820) begin $display("Mismatch post-reset sample 8: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12728; @(posedge clk); #1;
    if(data_out !== -16'sd18059) begin $display("Mismatch post-reset sample 9: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13897; @(posedge clk); #1;
    if(data_out !== -16'sd1438) begin $display("Mismatch post-reset sample 10: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd7082; @(posedge clk); #1;
    if(data_out !== -16'sd5410) begin $display("Mismatch post-reset sample 11: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5889; @(posedge clk); #1;
    if(data_out !== 16'sd1016) begin $display("Mismatch post-reset sample 12: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd31636; @(posedge clk); #1;
    if(data_out !== 16'sd4129) begin $display("Mismatch post-reset sample 13: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19237; @(posedge clk); #1;
    if(data_out !== -16'sd13881) begin $display("Mismatch post-reset sample 14: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25726; @(posedge clk); #1;
    if(data_out !== -16'sd17075) begin $display("Mismatch post-reset sample 15: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd16837; @(posedge clk); #1;
    if(data_out !== 16'sd6061) begin $display("Mismatch post-reset sample 16: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14240; @(posedge clk); #1;
    if(data_out !== 16'sd13583) begin $display("Mismatch post-reset sample 17: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd24639; @(posedge clk); #1;
    if(data_out !== -16'sd1086) begin $display("Mismatch post-reset sample 18: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3950; @(posedge clk); #1;
    if(data_out !== 16'sd10079) begin $display("Mismatch post-reset sample 19: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22217; @(posedge clk); #1;
    if(data_out !== 16'sd3200) begin $display("Mismatch post-reset sample 20: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd29076; @(posedge clk); #1;
    if(data_out !== 16'sd11449) begin $display("Mismatch post-reset sample 21: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd20509; @(posedge clk); #1;
    if(data_out !== 16'sd19863) begin $display("Mismatch post-reset sample 22: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd21478; @(posedge clk); #1;
    if(data_out !== -16'sd1754) begin $display("Mismatch post-reset sample 23: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9715; @(posedge clk); #1;
    if(data_out !== 16'sd7379) begin $display("Mismatch post-reset sample 24: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd13320; @(posedge clk); #1;
    if(data_out !== -16'sd949) begin $display("Mismatch post-reset sample 25: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14393; @(posedge clk); #1;
    if(data_out !== 16'sd5263) begin $display("Mismatch post-reset sample 26: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25210; @(posedge clk); #1;
    if(data_out !== -16'sd4446) begin $display("Mismatch post-reset sample 27: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28783; @(posedge clk); #1;
    if(data_out !== 16'sd9724) begin $display("Mismatch post-reset sample 28: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd956; @(posedge clk); #1;
    if(data_out !== -16'sd8974) begin $display("Mismatch post-reset sample 29: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd3051; @(posedge clk); #1;
    if(data_out !== -16'sd5225) begin $display("Mismatch post-reset sample 30: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12366; @(posedge clk); #1;
    if(data_out !== 16'sd35) begin $display("Mismatch post-reset sample 31: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd31573; @(posedge clk); #1;
    if(data_out !== 16'sd6854) begin $display("Mismatch post-reset sample 32: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5296; @(posedge clk); #1;
    if(data_out !== 16'sd19209) begin $display("Mismatch post-reset sample 33: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd8271; @(posedge clk); #1;
    if(data_out !== 16'sd11396) begin $display("Mismatch post-reset sample 34: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4450; @(posedge clk); #1;
    if(data_out !== 16'sd7432) begin $display("Mismatch post-reset sample 35: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd7847; @(posedge clk); #1;
    if(data_out !== 16'sd4517) begin $display("Mismatch post-reset sample 36: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9500; @(posedge clk); #1;
    if(data_out !== -16'sd2594) begin $display("Mismatch post-reset sample 37: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd5901; @(posedge clk); #1;
    if(data_out !== -16'sd6612) begin $display("Mismatch post-reset sample 38: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26186; @(posedge clk); #1;
    if(data_out !== -16'sd5932) begin $display("Mismatch post-reset sample 39: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd17821; @(posedge clk); #1;
    if(data_out !== -16'sd15233) begin $display("Mismatch post-reset sample 40: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd2648; @(posedge clk); #1;
    if(data_out !== 16'sd2036) begin $display("Mismatch post-reset sample 41: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd30249; @(posedge clk); #1;
    if(data_out !== 16'sd4246) begin $display("Mismatch post-reset sample 42: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd25270; @(posedge clk); #1;
    if(data_out !== -16'sd13256) begin $display("Mismatch post-reset sample 43: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27681; @(posedge clk); #1;
    if(data_out !== -16'sd19794) begin $display("Mismatch post-reset sample 44: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26868; @(posedge clk); #1;
    if(data_out !== 16'sd5601) begin $display("Mismatch post-reset sample 45: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26363; @(posedge clk); #1;
    if(data_out !== -16'sd8159) begin $display("Mismatch post-reset sample 46: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12318; @(posedge clk); #1;
    if(data_out !== 16'sd8402) begin $display("Mismatch post-reset sample 47: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22757; @(posedge clk); #1;
    if(data_out !== 16'sd11380) begin $display("Mismatch post-reset sample 48: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19200; @(posedge clk); #1;
    if(data_out !== 16'sd16018) begin $display("Mismatch post-reset sample 49: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd9311; @(posedge clk); #1;
    if(data_out !== -16'sd3014) begin $display("Mismatch post-reset sample 50: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd22990; @(posedge clk); #1;
    if(data_out !== 16'sd1146) begin $display("Mismatch post-reset sample 51: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd20457; @(posedge clk); #1;
    if(data_out !== -16'sd10545) begin $display("Mismatch post-reset sample 52: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd10188; @(posedge clk); #1;
    if(data_out !== 16'sd4813) begin $display("Mismatch post-reset sample 53: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23037; @(posedge clk); #1;
    if(data_out !== -16'sd1369) begin $display("Mismatch post-reset sample 54: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd27770; @(posedge clk); #1;
    if(data_out !== -16'sd12805) begin $display("Mismatch post-reset sample 55: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd10963; @(posedge clk); #1;
    if(data_out !== -16'sd20116) begin $display("Mismatch post-reset sample 56: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19288; @(posedge clk); #1;
    if(data_out !== -16'sd13939) begin $display("Mismatch post-reset sample 57: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4071; @(posedge clk); #1;
    if(data_out !== -16'sd14099) begin $display("Mismatch post-reset sample 58: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13286; @(posedge clk); #1;
    if(data_out !== -16'sd3272) begin $display("Mismatch post-reset sample 59: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21327; @(posedge clk); #1;
    if(data_out !== -16'sd6517) begin $display("Mismatch post-reset sample 60: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd15964; @(posedge clk); #1;
    if(data_out !== -16'sd13513) begin $display("Mismatch post-reset sample 61: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14837; @(posedge clk); #1;
    if(data_out !== 16'sd2040) begin $display("Mismatch post-reset sample 62: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25582; @(posedge clk); #1;
    if(data_out !== -16'sd4709) begin $display("Mismatch post-reset sample 63: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9611; @(posedge clk); #1;
    if(data_out !== 16'sd10182) begin $display("Mismatch post-reset sample 64: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd22192; @(posedge clk); #1;
    if(data_out !== 16'sd874) begin $display("Mismatch post-reset sample 65: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27759; @(posedge clk); #1;
    if(data_out !== -16'sd11932) begin $display("Mismatch post-reset sample 66: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd20734; @(posedge clk); #1;
    if(data_out !== 16'sd7804) begin $display("Mismatch post-reset sample 67: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23943; @(posedge clk); #1;
    if(data_out !== -16'sd4974) begin $display("Mismatch post-reset sample 68: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27012; @(posedge clk); #1;
    if(data_out !== -16'sd15434) begin $display("Mismatch post-reset sample 69: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd6381; @(posedge clk); #1;
    if(data_out !== 16'sd6411) begin $display("Mismatch post-reset sample 70: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd16726; @(posedge clk); #1;
    if(data_out !== 16'sd1944) begin $display("Mismatch post-reset sample 71: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd30531; @(posedge clk); #1;
    if(data_out !== 16'sd8534) begin $display("Mismatch post-reset sample 72: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd13048; @(posedge clk); #1;
    if(data_out !== -16'sd11242) begin $display("Mismatch post-reset sample 73: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd23031; @(posedge clk); #1;
    if(data_out !== -16'sd164) begin $display("Mismatch post-reset sample 74: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd4374; @(posedge clk); #1;
    if(data_out !== 16'sd12839) begin $display("Mismatch post-reset sample 75: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd20801; @(posedge clk); #1;
    if(data_out !== 16'sd4253) begin $display("Mismatch post-reset sample 76: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1620; @(posedge clk); #1;
    if(data_out !== 16'sd10922) begin $display("Mismatch post-reset sample 77: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd10523; @(posedge clk); #1;
    if(data_out !== 16'sd4119) begin $display("Mismatch post-reset sample 78: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13378; @(posedge clk); #1;
    if(data_out !== 16'sd5956) begin $display("Mismatch post-reset sample 79: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5; @(posedge clk); #1;
    if(data_out !== -16'sd4226) begin $display("Mismatch post-reset sample 80: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3680; @(posedge clk); #1;
    if(data_out !== -16'sd2855) begin $display("Mismatch post-reset sample 81: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1921; @(posedge clk); #1;
    if(data_out !== -16'sd2739) begin $display("Mismatch post-reset sample 82: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd11218; @(posedge clk); #1;
    if(data_out !== -16'sd1973) begin $display("Mismatch post-reset sample 83: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9975; @(posedge clk); #1;
    if(data_out !== 16'sd4965) begin $display("Mismatch post-reset sample 84: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28972; @(posedge clk); #1;
    if(data_out !== -16'sd2258) begin $display("Mismatch post-reset sample 85: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21469; @(posedge clk); #1;
    if(data_out !== -16'sd16236) begin $display("Mismatch post-reset sample 86: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23770; @(posedge clk); #1;
    if(data_out !== -16'sd18570) begin $display("Mismatch post-reset sample 87: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd24653; @(posedge clk); #1;
    if(data_out !== -16'sd19141) begin $display("Mismatch post-reset sample 88: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd31416; @(posedge clk); #1;
    if(data_out !== 16'sd5077) begin $display("Mismatch post-reset sample 89: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26631; @(posedge clk); #1;
    if(data_out !== -16'sd10777) begin $display("Mismatch post-reset sample 90: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd1466; @(posedge clk); #1;
    if(data_out !== 16'sd7292) begin $display("Mismatch post-reset sample 91: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22993; @(posedge clk); #1;
    if(data_out !== 16'sd5726) begin $display("Mismatch post-reset sample 92: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14084; @(posedge clk); #1;
    if(data_out !== 16'sd13448) begin $display("Mismatch post-reset sample 93: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28629; @(posedge clk); #1;
    if(data_out !== -16'sd1034) begin $display("Mismatch post-reset sample 94: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26510; @(posedge clk); #1;
    if(data_out !== -16'sd16513) begin $display("Mismatch post-reset sample 95: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13931; @(posedge clk); #1;
    if(data_out !== 16'sd5128) begin $display("Mismatch post-reset sample 96: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd29200; @(posedge clk); #1;
    if(data_out !== -16'sd2337) begin $display("Mismatch post-reset sample 97: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14193; @(posedge clk); #1;
    if(data_out !== -16'sd16410) begin $display("Mismatch post-reset sample 98: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd7330; @(posedge clk); #1;
    if(data_out !== -16'sd15009) begin $display("Mismatch post-reset sample 99: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3175; @(posedge clk); #1;
    if(data_out !== -16'sd1788) begin $display("Mismatch post-reset sample 100: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd18468; @(posedge clk); #1;
    if(data_out !== -16'sd605) begin $display("Mismatch post-reset sample 101: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd2765; @(posedge clk); #1;
    if(data_out !== 16'sd9155) begin $display("Mismatch post-reset sample 102: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd18186; @(posedge clk); #1;
    if(data_out !== 16'sd3271) begin $display("Mismatch post-reset sample 103: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd23517; @(posedge clk); #1;
    if(data_out !== -16'sd8602) begin $display("Mismatch post-reset sample 104: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21608; @(posedge clk); #1;
    if(data_out !== 16'sd7049) begin $display("Mismatch post-reset sample 105: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14871; @(posedge clk); #1;
    if(data_out !== -16'sd6204) begin $display("Mismatch post-reset sample 106: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4234; @(posedge clk); #1;
    if(data_out !== 16'sd3452) begin $display("Mismatch post-reset sample 107: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14751; @(posedge clk); #1;
    if(data_out !== 16'sd4619) begin $display("Mismatch post-reset sample 108: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21428; @(posedge clk); #1;
    if(data_out !== -16'sd5498) begin $display("Mismatch post-reset sample 109: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1221; @(posedge clk); #1;
    if(data_out !== -16'sd14040) begin $display("Mismatch post-reset sample 110: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14174; @(posedge clk); #1;
    if(data_out !== -16'sd6943) begin $display("Mismatch post-reset sample 111: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14117; @(posedge clk); #1;
    if(data_out !== 16'sd5371) begin $display("Mismatch post-reset sample 112: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd32320; @(posedge clk); #1;
    if(data_out !== 16'sd10612) begin $display("Mismatch post-reset sample 113: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9057; @(posedge clk); #1;
    if(data_out !== 16'sd20795) begin $display("Mismatch post-reset sample 114: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32398; @(posedge clk); #1;
    if(data_out !== 16'sd4543) begin $display("Mismatch post-reset sample 115: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3543; @(posedge clk); #1;
    if(data_out !== -16'sd16527) begin $display("Mismatch post-reset sample 116: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd27276; @(posedge clk); #1;
    if(data_out !== -16'sd10603) begin $display("Mismatch post-reset sample 117: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd15805; @(posedge clk); #1;
    if(data_out !== -16'sd16874) begin $display("Mismatch post-reset sample 118: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32058; @(posedge clk); #1;
    if(data_out !== -16'sd15014) begin $display("Mismatch post-reset sample 119: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd31597; @(posedge clk); #1;
    if(data_out !== -16'sd21427) begin $display("Mismatch post-reset sample 120: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23064; @(posedge clk); #1;
    if(data_out !== 16'sd6962) begin $display("Mismatch post-reset sample 121: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd12249; @(posedge clk); #1;
    if(data_out !== -16'sd5373) begin $display("Mismatch post-reset sample 122: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd3930; @(posedge clk); #1;
    if(data_out !== -16'sd9681) begin $display("Mismatch post-reset sample 123: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26895; @(posedge clk); #1;
    if(data_out !== -16'sd2204) begin $display("Mismatch post-reset sample 124: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23652; @(posedge clk); #1;
    if(data_out !== -16'sd13339) begin $display("Mismatch post-reset sample 125: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27211; @(posedge clk); #1;
    if(data_out !== -16'sd18220) begin $display("Mismatch post-reset sample 126: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd15150; @(posedge clk); #1;
    if(data_out !== 16'sd6163) begin $display("Mismatch post-reset sample 127: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd12934) begin $display("Mismatch post-reset sample 128: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd5697) begin $display("Mismatch post-reset sample 129: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd1232) begin $display("Mismatch post-reset sample 130: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd96) begin $display("Mismatch post-reset sample 131: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd202) begin $display("Mismatch post-reset sample 132: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd89) begin $display("Mismatch post-reset sample 133: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd19) begin $display("Mismatch post-reset sample 134: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd2) begin $display("Mismatch post-reset sample 135: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd3) begin $display("Mismatch post-reset sample 136: %d",data_out); errors=errors+1; end
    @(negedge clk);
    $display("TIMING: FO1/SO2, capture counts as cycle 1; total 2 cycles; edge offset 1; model delay 0");
    $display("Golden vector saturation count per run: 0");
    if(errors==0) $display("PASS: four-port SOS, continuous samples, reset, latency");
    else $fatal(1,"FAIL: %d mismatches",errors);
    $finish;
  end
endmodule
