`timescale 1ns/1ps
// Golden vectors exercise 0 saturated outputs per run.
// Zero means this filter/vector pair does not test output clipping.
module digital_filter_tb;
  reg clk=0; always #5 clk=~clk;
  reg rst_n=0;
  reg signed [15:0] data_in=0;
  wire signed [15:0] data_out;
  integer errors=0;
  // Input before capture edge E0; compare after E0 + 7 edges (8 cycles, capture counts as 1).
  digital_filter dut(.clk(clk),.rst_n(rst_n),.data_in(data_in),.data_out(data_out));
  initial begin
    @(posedge clk); #1; if(data_out !== 0) errors=errors+1;
    @(negedge clk); rst_n=1;
    data_in=16'sd32767; @(posedge clk); #1;
    if(data_out !== 16'sd0) begin $display("Mismatch sample 0: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32768; @(posedge clk); #1;
    if(data_out !== 16'sd0) begin $display("Mismatch sample 1: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd0) begin $display("Mismatch sample 2: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd1; @(posedge clk); #1;
    if(data_out !== 16'sd0) begin $display("Mismatch sample 3: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1; @(posedge clk); #1;
    if(data_out !== 16'sd0) begin $display("Mismatch sample 4: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd25532; @(posedge clk); #1;
    if(data_out !== 16'sd0) begin $display("Mismatch sample 5: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1325; @(posedge clk); #1;
    if(data_out !== 16'sd0) begin $display("Mismatch sample 6: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd15850; @(posedge clk); #1;
    if(data_out !== 16'sd426) begin $display("Mismatch sample 7: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28035; @(posedge clk); #1;
    if(data_out !== 16'sd1312) begin $display("Mismatch sample 8: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12728; @(posedge clk); #1;
    if(data_out !== 16'sd2080) begin $display("Mismatch sample 9: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13897; @(posedge clk); #1;
    if(data_out !== 16'sd2094) begin $display("Mismatch sample 10: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd7082; @(posedge clk); #1;
    if(data_out !== 16'sd1266) begin $display("Mismatch sample 11: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5889; @(posedge clk); #1;
    if(data_out !== -16'sd288) begin $display("Mismatch sample 12: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd31636; @(posedge clk); #1;
    if(data_out !== -16'sd2379) begin $display("Mismatch sample 13: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19237; @(posedge clk); #1;
    if(data_out !== -16'sd4813) begin $display("Mismatch sample 14: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25726; @(posedge clk); #1;
    if(data_out !== -16'sd7571) begin $display("Mismatch sample 15: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd16837; @(posedge clk); #1;
    if(data_out !== -16'sd10317) begin $display("Mismatch sample 16: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14240; @(posedge clk); #1;
    if(data_out !== -16'sd12458) begin $display("Mismatch sample 17: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd24639; @(posedge clk); #1;
    if(data_out !== -16'sd13360) begin $display("Mismatch sample 18: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3950; @(posedge clk); #1;
    if(data_out !== -16'sd12642) begin $display("Mismatch sample 19: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22217; @(posedge clk); #1;
    if(data_out !== -16'sd10834) begin $display("Mismatch sample 20: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd29076; @(posedge clk); #1;
    if(data_out !== -16'sd9253) begin $display("Mismatch sample 21: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd20509; @(posedge clk); #1;
    if(data_out !== -16'sd8551) begin $display("Mismatch sample 22: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd21478; @(posedge clk); #1;
    if(data_out !== -16'sd8019) begin $display("Mismatch sample 23: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9715; @(posedge clk); #1;
    if(data_out !== -16'sd6736) begin $display("Mismatch sample 24: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd13320; @(posedge clk); #1;
    if(data_out !== -16'sd4297) begin $display("Mismatch sample 25: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14393; @(posedge clk); #1;
    if(data_out !== -16'sd1081) begin $display("Mismatch sample 26: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25210; @(posedge clk); #1;
    if(data_out !== 16'sd2344) begin $display("Mismatch sample 27: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28783; @(posedge clk); #1;
    if(data_out !== 16'sd5841) begin $display("Mismatch sample 28: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd956; @(posedge clk); #1;
    if(data_out !== 16'sd9078) begin $display("Mismatch sample 29: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd3051; @(posedge clk); #1;
    if(data_out !== 16'sd11553) begin $display("Mismatch sample 30: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12366; @(posedge clk); #1;
    if(data_out !== 16'sd12720) begin $display("Mismatch sample 31: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd31573; @(posedge clk); #1;
    if(data_out !== 16'sd12489) begin $display("Mismatch sample 32: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5296; @(posedge clk); #1;
    if(data_out !== 16'sd11052) begin $display("Mismatch sample 33: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd8271; @(posedge clk); #1;
    if(data_out !== 16'sd9063) begin $display("Mismatch sample 34: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4450; @(posedge clk); #1;
    if(data_out !== 16'sd6937) begin $display("Mismatch sample 35: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd7847; @(posedge clk); #1;
    if(data_out !== 16'sd4712) begin $display("Mismatch sample 36: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9500; @(posedge clk); #1;
    if(data_out !== 16'sd2422) begin $display("Mismatch sample 37: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd5901; @(posedge clk); #1;
    if(data_out !== 16'sd513) begin $display("Mismatch sample 38: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26186; @(posedge clk); #1;
    if(data_out !== -16'sd55) begin $display("Mismatch sample 39: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd17821; @(posedge clk); #1;
    if(data_out !== 16'sd1367) begin $display("Mismatch sample 40: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd2648; @(posedge clk); #1;
    if(data_out !== 16'sd4460) begin $display("Mismatch sample 41: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd30249; @(posedge clk); #1;
    if(data_out !== 16'sd8062) begin $display("Mismatch sample 42: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd25270; @(posedge clk); #1;
    if(data_out !== 16'sd10741) begin $display("Mismatch sample 43: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27681; @(posedge clk); #1;
    if(data_out !== 16'sd11420) begin $display("Mismatch sample 44: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26868; @(posedge clk); #1;
    if(data_out !== 16'sd9817) begin $display("Mismatch sample 45: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26363; @(posedge clk); #1;
    if(data_out !== 16'sd6213) begin $display("Mismatch sample 46: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12318; @(posedge clk); #1;
    if(data_out !== 16'sd1638) begin $display("Mismatch sample 47: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22757; @(posedge clk); #1;
    if(data_out !== -16'sd2416) begin $display("Mismatch sample 48: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19200; @(posedge clk); #1;
    if(data_out !== -16'sd5160) begin $display("Mismatch sample 49: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd9311; @(posedge clk); #1;
    if(data_out !== -16'sd7070) begin $display("Mismatch sample 50: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd22990; @(posedge clk); #1;
    if(data_out !== -16'sd8592) begin $display("Mismatch sample 51: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd20457; @(posedge clk); #1;
    if(data_out !== -16'sd9778) begin $display("Mismatch sample 52: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd10188; @(posedge clk); #1;
    if(data_out !== -16'sd10106) begin $display("Mismatch sample 53: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23037; @(posedge clk); #1;
    if(data_out !== -16'sd8898) begin $display("Mismatch sample 54: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd27770; @(posedge clk); #1;
    if(data_out !== -16'sd5736) begin $display("Mismatch sample 55: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd10963; @(posedge clk); #1;
    if(data_out !== -16'sd1286) begin $display("Mismatch sample 56: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19288; @(posedge clk); #1;
    if(data_out !== 16'sd3043) begin $display("Mismatch sample 57: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4071; @(posedge clk); #1;
    if(data_out !== 16'sd5700) begin $display("Mismatch sample 58: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13286; @(posedge clk); #1;
    if(data_out !== 16'sd6164) begin $display("Mismatch sample 59: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21327; @(posedge clk); #1;
    if(data_out !== 16'sd4963) begin $display("Mismatch sample 60: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd15964; @(posedge clk); #1;
    if(data_out !== 16'sd2762) begin $display("Mismatch sample 61: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14837; @(posedge clk); #1;
    if(data_out !== -16'sd330) begin $display("Mismatch sample 62: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25582; @(posedge clk); #1;
    if(data_out !== -16'sd4354) begin $display("Mismatch sample 63: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9611; @(posedge clk); #1;
    if(data_out !== -16'sd9000) begin $display("Mismatch sample 64: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd22192; @(posedge clk); #1;
    if(data_out !== -16'sd13320) begin $display("Mismatch sample 65: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27759; @(posedge clk); #1;
    if(data_out !== -16'sd16287) begin $display("Mismatch sample 66: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd20734; @(posedge clk); #1;
    if(data_out !== -16'sd17605) begin $display("Mismatch sample 67: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23943; @(posedge clk); #1;
    if(data_out !== -16'sd17397) begin $display("Mismatch sample 68: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27012; @(posedge clk); #1;
    if(data_out !== -16'sd16027) begin $display("Mismatch sample 69: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd6381; @(posedge clk); #1;
    if(data_out !== -16'sd13601) begin $display("Mismatch sample 70: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd16726; @(posedge clk); #1;
    if(data_out !== -16'sd10294) begin $display("Mismatch sample 71: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd30531; @(posedge clk); #1;
    if(data_out !== -16'sd6916) begin $display("Mismatch sample 72: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd13048; @(posedge clk); #1;
    if(data_out !== -16'sd4151) begin $display("Mismatch sample 73: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd23031; @(posedge clk); #1;
    if(data_out !== -16'sd2347) begin $display("Mismatch sample 74: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd4374; @(posedge clk); #1;
    if(data_out !== -16'sd1834) begin $display("Mismatch sample 75: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd20801; @(posedge clk); #1;
    if(data_out !== -16'sd2380) begin $display("Mismatch sample 76: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1620; @(posedge clk); #1;
    if(data_out !== -16'sd3223) begin $display("Mismatch sample 77: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd10523; @(posedge clk); #1;
    if(data_out !== -16'sd3394) begin $display("Mismatch sample 78: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13378; @(posedge clk); #1;
    if(data_out !== -16'sd2793) begin $display("Mismatch sample 79: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5; @(posedge clk); #1;
    if(data_out !== -16'sd1952) begin $display("Mismatch sample 80: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3680; @(posedge clk); #1;
    if(data_out !== -16'sd1048) begin $display("Mismatch sample 81: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1921; @(posedge clk); #1;
    if(data_out !== 16'sd120) begin $display("Mismatch sample 82: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd11218; @(posedge clk); #1;
    if(data_out !== 16'sd1852) begin $display("Mismatch sample 83: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9975; @(posedge clk); #1;
    if(data_out !== 16'sd4054) begin $display("Mismatch sample 84: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28972; @(posedge clk); #1;
    if(data_out !== 16'sd6297) begin $display("Mismatch sample 85: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21469; @(posedge clk); #1;
    if(data_out !== 16'sd7864) begin $display("Mismatch sample 86: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23770; @(posedge clk); #1;
    if(data_out !== 16'sd8152) begin $display("Mismatch sample 87: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd24653; @(posedge clk); #1;
    if(data_out !== 16'sd7021) begin $display("Mismatch sample 88: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd31416; @(posedge clk); #1;
    if(data_out !== 16'sd4867) begin $display("Mismatch sample 89: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26631; @(posedge clk); #1;
    if(data_out !== 16'sd2537) begin $display("Mismatch sample 90: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd1466; @(posedge clk); #1;
    if(data_out !== 16'sd729) begin $display("Mismatch sample 91: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22993; @(posedge clk); #1;
    if(data_out !== -16'sd724) begin $display("Mismatch sample 92: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14084; @(posedge clk); #1;
    if(data_out !== -16'sd2676) begin $display("Mismatch sample 93: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28629; @(posedge clk); #1;
    if(data_out !== -16'sd5879) begin $display("Mismatch sample 94: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26510; @(posedge clk); #1;
    if(data_out !== -16'sd9753) begin $display("Mismatch sample 95: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13931; @(posedge clk); #1;
    if(data_out !== -16'sd13095) begin $display("Mismatch sample 96: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd29200; @(posedge clk); #1;
    if(data_out !== -16'sd14670) begin $display("Mismatch sample 97: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14193; @(posedge clk); #1;
    if(data_out !== -16'sd13855) begin $display("Mismatch sample 98: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd7330; @(posedge clk); #1;
    if(data_out !== -16'sd10647) begin $display("Mismatch sample 99: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3175; @(posedge clk); #1;
    if(data_out !== -16'sd5948) begin $display("Mismatch sample 100: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd18468; @(posedge clk); #1;
    if(data_out !== -16'sd1627) begin $display("Mismatch sample 101: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd2765; @(posedge clk); #1;
    if(data_out !== 16'sd941) begin $display("Mismatch sample 102: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd18186; @(posedge clk); #1;
    if(data_out !== 16'sd1531) begin $display("Mismatch sample 103: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd23517; @(posedge clk); #1;
    if(data_out !== 16'sd424) begin $display("Mismatch sample 104: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21608; @(posedge clk); #1;
    if(data_out !== -16'sd2103) begin $display("Mismatch sample 105: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14871; @(posedge clk); #1;
    if(data_out !== -16'sd5410) begin $display("Mismatch sample 106: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4234; @(posedge clk); #1;
    if(data_out !== -16'sd8428) begin $display("Mismatch sample 107: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14751; @(posedge clk); #1;
    if(data_out !== -16'sd9913) begin $display("Mismatch sample 108: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21428; @(posedge clk); #1;
    if(data_out !== -16'sd9236) begin $display("Mismatch sample 109: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1221; @(posedge clk); #1;
    if(data_out !== -16'sd7022) begin $display("Mismatch sample 110: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14174; @(posedge clk); #1;
    if(data_out !== -16'sd4305) begin $display("Mismatch sample 111: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14117; @(posedge clk); #1;
    if(data_out !== -16'sd2053) begin $display("Mismatch sample 112: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd32320; @(posedge clk); #1;
    if(data_out !== -16'sd639) begin $display("Mismatch sample 113: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9057; @(posedge clk); #1;
    if(data_out !== 16'sd167) begin $display("Mismatch sample 114: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32398; @(posedge clk); #1;
    if(data_out !== 16'sd586) begin $display("Mismatch sample 115: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3543; @(posedge clk); #1;
    if(data_out !== 16'sd326) begin $display("Mismatch sample 116: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd27276; @(posedge clk); #1;
    if(data_out !== -16'sd964) begin $display("Mismatch sample 117: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd15805; @(posedge clk); #1;
    if(data_out !== -16'sd2875) begin $display("Mismatch sample 118: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32058; @(posedge clk); #1;
    if(data_out !== -16'sd4222) begin $display("Mismatch sample 119: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd31597; @(posedge clk); #1;
    if(data_out !== -16'sd3613) begin $display("Mismatch sample 120: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23064; @(posedge clk); #1;
    if(data_out !== -16'sd731) begin $display("Mismatch sample 121: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd12249; @(posedge clk); #1;
    if(data_out !== 16'sd2888) begin $display("Mismatch sample 122: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd3930; @(posedge clk); #1;
    if(data_out !== 16'sd5021) begin $display("Mismatch sample 123: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26895; @(posedge clk); #1;
    if(data_out !== 16'sd4183) begin $display("Mismatch sample 124: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23652; @(posedge clk); #1;
    if(data_out !== 16'sd368) begin $display("Mismatch sample 125: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27211; @(posedge clk); #1;
    if(data_out !== -16'sd5444) begin $display("Mismatch sample 126: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd15150; @(posedge clk); #1;
    if(data_out !== -16'sd11288) begin $display("Mismatch sample 127: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd15311) begin $display("Mismatch sample 128: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd16827) begin $display("Mismatch sample 129: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd16242) begin $display("Mismatch sample 130: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd14691) begin $display("Mismatch sample 131: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd13516) begin $display("Mismatch sample 132: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd13049) begin $display("Mismatch sample 133: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd12342) begin $display("Mismatch sample 134: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd10298) begin $display("Mismatch sample 135: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd6812) begin $display("Mismatch sample 136: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd2808) begin $display("Mismatch sample 137: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd541) begin $display("Mismatch sample 138: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd2541) begin $display("Mismatch sample 139: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd3170) begin $display("Mismatch sample 140: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd2847) begin $display("Mismatch sample 141: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd2092) begin $display("Mismatch sample 142: %d",data_out); errors=errors+1; end
    @(negedge clk);
    rst_n=0; data_in=16'sd32767; @(posedge clk); #1;
    if(data_out !== 0) errors=errors+1;
    @(negedge clk); rst_n=1;
    data_in=16'sd32767; @(posedge clk); #1;
    if(data_out !== 16'sd0) begin $display("Mismatch post-reset sample 0: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32768; @(posedge clk); #1;
    if(data_out !== 16'sd0) begin $display("Mismatch post-reset sample 1: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd0) begin $display("Mismatch post-reset sample 2: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd1; @(posedge clk); #1;
    if(data_out !== 16'sd0) begin $display("Mismatch post-reset sample 3: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1; @(posedge clk); #1;
    if(data_out !== 16'sd0) begin $display("Mismatch post-reset sample 4: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd25532; @(posedge clk); #1;
    if(data_out !== 16'sd0) begin $display("Mismatch post-reset sample 5: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1325; @(posedge clk); #1;
    if(data_out !== 16'sd0) begin $display("Mismatch post-reset sample 6: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd15850; @(posedge clk); #1;
    if(data_out !== 16'sd426) begin $display("Mismatch post-reset sample 7: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28035; @(posedge clk); #1;
    if(data_out !== 16'sd1312) begin $display("Mismatch post-reset sample 8: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12728; @(posedge clk); #1;
    if(data_out !== 16'sd2080) begin $display("Mismatch post-reset sample 9: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13897; @(posedge clk); #1;
    if(data_out !== 16'sd2094) begin $display("Mismatch post-reset sample 10: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd7082; @(posedge clk); #1;
    if(data_out !== 16'sd1266) begin $display("Mismatch post-reset sample 11: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5889; @(posedge clk); #1;
    if(data_out !== -16'sd288) begin $display("Mismatch post-reset sample 12: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd31636; @(posedge clk); #1;
    if(data_out !== -16'sd2379) begin $display("Mismatch post-reset sample 13: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19237; @(posedge clk); #1;
    if(data_out !== -16'sd4813) begin $display("Mismatch post-reset sample 14: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25726; @(posedge clk); #1;
    if(data_out !== -16'sd7571) begin $display("Mismatch post-reset sample 15: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd16837; @(posedge clk); #1;
    if(data_out !== -16'sd10317) begin $display("Mismatch post-reset sample 16: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14240; @(posedge clk); #1;
    if(data_out !== -16'sd12458) begin $display("Mismatch post-reset sample 17: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd24639; @(posedge clk); #1;
    if(data_out !== -16'sd13360) begin $display("Mismatch post-reset sample 18: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3950; @(posedge clk); #1;
    if(data_out !== -16'sd12642) begin $display("Mismatch post-reset sample 19: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22217; @(posedge clk); #1;
    if(data_out !== -16'sd10834) begin $display("Mismatch post-reset sample 20: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd29076; @(posedge clk); #1;
    if(data_out !== -16'sd9253) begin $display("Mismatch post-reset sample 21: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd20509; @(posedge clk); #1;
    if(data_out !== -16'sd8551) begin $display("Mismatch post-reset sample 22: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd21478; @(posedge clk); #1;
    if(data_out !== -16'sd8019) begin $display("Mismatch post-reset sample 23: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9715; @(posedge clk); #1;
    if(data_out !== -16'sd6736) begin $display("Mismatch post-reset sample 24: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd13320; @(posedge clk); #1;
    if(data_out !== -16'sd4297) begin $display("Mismatch post-reset sample 25: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14393; @(posedge clk); #1;
    if(data_out !== -16'sd1081) begin $display("Mismatch post-reset sample 26: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25210; @(posedge clk); #1;
    if(data_out !== 16'sd2344) begin $display("Mismatch post-reset sample 27: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28783; @(posedge clk); #1;
    if(data_out !== 16'sd5841) begin $display("Mismatch post-reset sample 28: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd956; @(posedge clk); #1;
    if(data_out !== 16'sd9078) begin $display("Mismatch post-reset sample 29: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd3051; @(posedge clk); #1;
    if(data_out !== 16'sd11553) begin $display("Mismatch post-reset sample 30: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12366; @(posedge clk); #1;
    if(data_out !== 16'sd12720) begin $display("Mismatch post-reset sample 31: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd31573; @(posedge clk); #1;
    if(data_out !== 16'sd12489) begin $display("Mismatch post-reset sample 32: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5296; @(posedge clk); #1;
    if(data_out !== 16'sd11052) begin $display("Mismatch post-reset sample 33: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd8271; @(posedge clk); #1;
    if(data_out !== 16'sd9063) begin $display("Mismatch post-reset sample 34: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4450; @(posedge clk); #1;
    if(data_out !== 16'sd6937) begin $display("Mismatch post-reset sample 35: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd7847; @(posedge clk); #1;
    if(data_out !== 16'sd4712) begin $display("Mismatch post-reset sample 36: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9500; @(posedge clk); #1;
    if(data_out !== 16'sd2422) begin $display("Mismatch post-reset sample 37: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd5901; @(posedge clk); #1;
    if(data_out !== 16'sd513) begin $display("Mismatch post-reset sample 38: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26186; @(posedge clk); #1;
    if(data_out !== -16'sd55) begin $display("Mismatch post-reset sample 39: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd17821; @(posedge clk); #1;
    if(data_out !== 16'sd1367) begin $display("Mismatch post-reset sample 40: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd2648; @(posedge clk); #1;
    if(data_out !== 16'sd4460) begin $display("Mismatch post-reset sample 41: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd30249; @(posedge clk); #1;
    if(data_out !== 16'sd8062) begin $display("Mismatch post-reset sample 42: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd25270; @(posedge clk); #1;
    if(data_out !== 16'sd10741) begin $display("Mismatch post-reset sample 43: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27681; @(posedge clk); #1;
    if(data_out !== 16'sd11420) begin $display("Mismatch post-reset sample 44: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26868; @(posedge clk); #1;
    if(data_out !== 16'sd9817) begin $display("Mismatch post-reset sample 45: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26363; @(posedge clk); #1;
    if(data_out !== 16'sd6213) begin $display("Mismatch post-reset sample 46: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12318; @(posedge clk); #1;
    if(data_out !== 16'sd1638) begin $display("Mismatch post-reset sample 47: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22757; @(posedge clk); #1;
    if(data_out !== -16'sd2416) begin $display("Mismatch post-reset sample 48: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19200; @(posedge clk); #1;
    if(data_out !== -16'sd5160) begin $display("Mismatch post-reset sample 49: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd9311; @(posedge clk); #1;
    if(data_out !== -16'sd7070) begin $display("Mismatch post-reset sample 50: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd22990; @(posedge clk); #1;
    if(data_out !== -16'sd8592) begin $display("Mismatch post-reset sample 51: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd20457; @(posedge clk); #1;
    if(data_out !== -16'sd9778) begin $display("Mismatch post-reset sample 52: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd10188; @(posedge clk); #1;
    if(data_out !== -16'sd10106) begin $display("Mismatch post-reset sample 53: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23037; @(posedge clk); #1;
    if(data_out !== -16'sd8898) begin $display("Mismatch post-reset sample 54: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd27770; @(posedge clk); #1;
    if(data_out !== -16'sd5736) begin $display("Mismatch post-reset sample 55: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd10963; @(posedge clk); #1;
    if(data_out !== -16'sd1286) begin $display("Mismatch post-reset sample 56: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19288; @(posedge clk); #1;
    if(data_out !== 16'sd3043) begin $display("Mismatch post-reset sample 57: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4071; @(posedge clk); #1;
    if(data_out !== 16'sd5700) begin $display("Mismatch post-reset sample 58: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13286; @(posedge clk); #1;
    if(data_out !== 16'sd6164) begin $display("Mismatch post-reset sample 59: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21327; @(posedge clk); #1;
    if(data_out !== 16'sd4963) begin $display("Mismatch post-reset sample 60: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd15964; @(posedge clk); #1;
    if(data_out !== 16'sd2762) begin $display("Mismatch post-reset sample 61: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14837; @(posedge clk); #1;
    if(data_out !== -16'sd330) begin $display("Mismatch post-reset sample 62: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25582; @(posedge clk); #1;
    if(data_out !== -16'sd4354) begin $display("Mismatch post-reset sample 63: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9611; @(posedge clk); #1;
    if(data_out !== -16'sd9000) begin $display("Mismatch post-reset sample 64: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd22192; @(posedge clk); #1;
    if(data_out !== -16'sd13320) begin $display("Mismatch post-reset sample 65: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27759; @(posedge clk); #1;
    if(data_out !== -16'sd16287) begin $display("Mismatch post-reset sample 66: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd20734; @(posedge clk); #1;
    if(data_out !== -16'sd17605) begin $display("Mismatch post-reset sample 67: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23943; @(posedge clk); #1;
    if(data_out !== -16'sd17397) begin $display("Mismatch post-reset sample 68: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27012; @(posedge clk); #1;
    if(data_out !== -16'sd16027) begin $display("Mismatch post-reset sample 69: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd6381; @(posedge clk); #1;
    if(data_out !== -16'sd13601) begin $display("Mismatch post-reset sample 70: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd16726; @(posedge clk); #1;
    if(data_out !== -16'sd10294) begin $display("Mismatch post-reset sample 71: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd30531; @(posedge clk); #1;
    if(data_out !== -16'sd6916) begin $display("Mismatch post-reset sample 72: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd13048; @(posedge clk); #1;
    if(data_out !== -16'sd4151) begin $display("Mismatch post-reset sample 73: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd23031; @(posedge clk); #1;
    if(data_out !== -16'sd2347) begin $display("Mismatch post-reset sample 74: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd4374; @(posedge clk); #1;
    if(data_out !== -16'sd1834) begin $display("Mismatch post-reset sample 75: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd20801; @(posedge clk); #1;
    if(data_out !== -16'sd2380) begin $display("Mismatch post-reset sample 76: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1620; @(posedge clk); #1;
    if(data_out !== -16'sd3223) begin $display("Mismatch post-reset sample 77: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd10523; @(posedge clk); #1;
    if(data_out !== -16'sd3394) begin $display("Mismatch post-reset sample 78: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13378; @(posedge clk); #1;
    if(data_out !== -16'sd2793) begin $display("Mismatch post-reset sample 79: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5; @(posedge clk); #1;
    if(data_out !== -16'sd1952) begin $display("Mismatch post-reset sample 80: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3680; @(posedge clk); #1;
    if(data_out !== -16'sd1048) begin $display("Mismatch post-reset sample 81: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1921; @(posedge clk); #1;
    if(data_out !== 16'sd120) begin $display("Mismatch post-reset sample 82: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd11218; @(posedge clk); #1;
    if(data_out !== 16'sd1852) begin $display("Mismatch post-reset sample 83: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9975; @(posedge clk); #1;
    if(data_out !== 16'sd4054) begin $display("Mismatch post-reset sample 84: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28972; @(posedge clk); #1;
    if(data_out !== 16'sd6297) begin $display("Mismatch post-reset sample 85: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21469; @(posedge clk); #1;
    if(data_out !== 16'sd7864) begin $display("Mismatch post-reset sample 86: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23770; @(posedge clk); #1;
    if(data_out !== 16'sd8152) begin $display("Mismatch post-reset sample 87: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd24653; @(posedge clk); #1;
    if(data_out !== 16'sd7021) begin $display("Mismatch post-reset sample 88: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd31416; @(posedge clk); #1;
    if(data_out !== 16'sd4867) begin $display("Mismatch post-reset sample 89: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26631; @(posedge clk); #1;
    if(data_out !== 16'sd2537) begin $display("Mismatch post-reset sample 90: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd1466; @(posedge clk); #1;
    if(data_out !== 16'sd729) begin $display("Mismatch post-reset sample 91: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22993; @(posedge clk); #1;
    if(data_out !== -16'sd724) begin $display("Mismatch post-reset sample 92: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14084; @(posedge clk); #1;
    if(data_out !== -16'sd2676) begin $display("Mismatch post-reset sample 93: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28629; @(posedge clk); #1;
    if(data_out !== -16'sd5879) begin $display("Mismatch post-reset sample 94: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26510; @(posedge clk); #1;
    if(data_out !== -16'sd9753) begin $display("Mismatch post-reset sample 95: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13931; @(posedge clk); #1;
    if(data_out !== -16'sd13095) begin $display("Mismatch post-reset sample 96: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd29200; @(posedge clk); #1;
    if(data_out !== -16'sd14670) begin $display("Mismatch post-reset sample 97: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14193; @(posedge clk); #1;
    if(data_out !== -16'sd13855) begin $display("Mismatch post-reset sample 98: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd7330; @(posedge clk); #1;
    if(data_out !== -16'sd10647) begin $display("Mismatch post-reset sample 99: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3175; @(posedge clk); #1;
    if(data_out !== -16'sd5948) begin $display("Mismatch post-reset sample 100: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd18468; @(posedge clk); #1;
    if(data_out !== -16'sd1627) begin $display("Mismatch post-reset sample 101: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd2765; @(posedge clk); #1;
    if(data_out !== 16'sd941) begin $display("Mismatch post-reset sample 102: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd18186; @(posedge clk); #1;
    if(data_out !== 16'sd1531) begin $display("Mismatch post-reset sample 103: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd23517; @(posedge clk); #1;
    if(data_out !== 16'sd424) begin $display("Mismatch post-reset sample 104: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21608; @(posedge clk); #1;
    if(data_out !== -16'sd2103) begin $display("Mismatch post-reset sample 105: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14871; @(posedge clk); #1;
    if(data_out !== -16'sd5410) begin $display("Mismatch post-reset sample 106: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4234; @(posedge clk); #1;
    if(data_out !== -16'sd8428) begin $display("Mismatch post-reset sample 107: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14751; @(posedge clk); #1;
    if(data_out !== -16'sd9913) begin $display("Mismatch post-reset sample 108: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21428; @(posedge clk); #1;
    if(data_out !== -16'sd9236) begin $display("Mismatch post-reset sample 109: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1221; @(posedge clk); #1;
    if(data_out !== -16'sd7022) begin $display("Mismatch post-reset sample 110: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14174; @(posedge clk); #1;
    if(data_out !== -16'sd4305) begin $display("Mismatch post-reset sample 111: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14117; @(posedge clk); #1;
    if(data_out !== -16'sd2053) begin $display("Mismatch post-reset sample 112: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd32320; @(posedge clk); #1;
    if(data_out !== -16'sd639) begin $display("Mismatch post-reset sample 113: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9057; @(posedge clk); #1;
    if(data_out !== 16'sd167) begin $display("Mismatch post-reset sample 114: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32398; @(posedge clk); #1;
    if(data_out !== 16'sd586) begin $display("Mismatch post-reset sample 115: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3543; @(posedge clk); #1;
    if(data_out !== 16'sd326) begin $display("Mismatch post-reset sample 116: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd27276; @(posedge clk); #1;
    if(data_out !== -16'sd964) begin $display("Mismatch post-reset sample 117: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd15805; @(posedge clk); #1;
    if(data_out !== -16'sd2875) begin $display("Mismatch post-reset sample 118: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32058; @(posedge clk); #1;
    if(data_out !== -16'sd4222) begin $display("Mismatch post-reset sample 119: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd31597; @(posedge clk); #1;
    if(data_out !== -16'sd3613) begin $display("Mismatch post-reset sample 120: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23064; @(posedge clk); #1;
    if(data_out !== -16'sd731) begin $display("Mismatch post-reset sample 121: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd12249; @(posedge clk); #1;
    if(data_out !== 16'sd2888) begin $display("Mismatch post-reset sample 122: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd3930; @(posedge clk); #1;
    if(data_out !== 16'sd5021) begin $display("Mismatch post-reset sample 123: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26895; @(posedge clk); #1;
    if(data_out !== 16'sd4183) begin $display("Mismatch post-reset sample 124: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23652; @(posedge clk); #1;
    if(data_out !== 16'sd368) begin $display("Mismatch post-reset sample 125: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27211; @(posedge clk); #1;
    if(data_out !== -16'sd5444) begin $display("Mismatch post-reset sample 126: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd15150; @(posedge clk); #1;
    if(data_out !== -16'sd11288) begin $display("Mismatch post-reset sample 127: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd15311) begin $display("Mismatch post-reset sample 128: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd16827) begin $display("Mismatch post-reset sample 129: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd16242) begin $display("Mismatch post-reset sample 130: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd14691) begin $display("Mismatch post-reset sample 131: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd13516) begin $display("Mismatch post-reset sample 132: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd13049) begin $display("Mismatch post-reset sample 133: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd12342) begin $display("Mismatch post-reset sample 134: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd10298) begin $display("Mismatch post-reset sample 135: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd6812) begin $display("Mismatch post-reset sample 136: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd2808) begin $display("Mismatch post-reset sample 137: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd541) begin $display("Mismatch post-reset sample 138: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd2541) begin $display("Mismatch post-reset sample 139: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd3170) begin $display("Mismatch post-reset sample 140: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd2847) begin $display("Mismatch post-reset sample 141: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd2092) begin $display("Mismatch post-reset sample 142: %d",data_out); errors=errors+1; end
    @(negedge clk);
    $display("TIMING: FO1/SO2, capture counts as cycle 1; total 8 cycles; edge offset 7; model delay 0");
    $display("Golden vector saturation count per run: 0");
    if(errors==0) $display("PASS: four-port SOS, continuous samples, reset, latency");
    else $fatal(1,"FAIL: %d mismatches",errors);
    $finish;
  end
endmodule
