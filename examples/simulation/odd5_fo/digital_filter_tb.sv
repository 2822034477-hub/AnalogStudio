`timescale 1ns/1ps
// Golden vectors exercise 0 saturated outputs per run.
// Zero means this filter/vector pair does not test output clipping.
module digital_filter_tb;
  reg clk=0; always #5 clk=~clk;
  reg rst_n=0;
  reg signed [15:0] data_in=0;
  wire signed [15:0] data_out;
  integer errors=0;
  // Input before capture edge E0; compare after E0 + 4 edges (5 cycles, capture counts as 1).
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
    if(data_out !== 16'sd983) begin $display("Mismatch sample 4: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd25532; @(posedge clk); #1;
    if(data_out !== 16'sd1229) begin $display("Mismatch sample 5: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1325; @(posedge clk); #1;
    if(data_out !== 16'sd770) begin $display("Mismatch sample 6: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd15850; @(posedge clk); #1;
    if(data_out !== 16'sd140) begin $display("Mismatch sample 7: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28035; @(posedge clk); #1;
    if(data_out !== -16'sd323) begin $display("Mismatch sample 8: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12728; @(posedge clk); #1;
    if(data_out !== -16'sd1307) begin $display("Mismatch sample 9: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13897; @(posedge clk); #1;
    if(data_out !== -16'sd2334) begin $display("Mismatch sample 10: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd7082; @(posedge clk); #1;
    if(data_out !== -16'sd3385) begin $display("Mismatch sample 11: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5889; @(posedge clk); #1;
    if(data_out !== -16'sd4850) begin $display("Mismatch sample 12: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd31636; @(posedge clk); #1;
    if(data_out !== -16'sd5537) begin $display("Mismatch sample 13: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19237; @(posedge clk); #1;
    if(data_out !== -16'sd5677) begin $display("Mismatch sample 14: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25726; @(posedge clk); #1;
    if(data_out !== -16'sd5115) begin $display("Mismatch sample 15: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd16837; @(posedge clk); #1;
    if(data_out !== -16'sd3947) begin $display("Mismatch sample 16: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14240; @(posedge clk); #1;
    if(data_out !== -16'sd3599) begin $display("Mismatch sample 17: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd24639; @(posedge clk); #1;
    if(data_out !== -16'sd4282) begin $display("Mismatch sample 18: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3950; @(posedge clk); #1;
    if(data_out !== -16'sd4223) begin $display("Mismatch sample 19: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22217; @(posedge clk); #1;
    if(data_out !== -16'sd2884) begin $display("Mismatch sample 20: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd29076; @(posedge clk); #1;
    if(data_out !== -16'sd1601) begin $display("Mismatch sample 21: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd20509; @(posedge clk); #1;
    if(data_out !== -16'sd63) begin $display("Mismatch sample 22: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd21478; @(posedge clk); #1;
    if(data_out !== 16'sd1140) begin $display("Mismatch sample 23: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9715; @(posedge clk); #1;
    if(data_out !== 16'sd2410) begin $display("Mismatch sample 24: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd13320; @(posedge clk); #1;
    if(data_out !== 16'sd4203) begin $display("Mismatch sample 25: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14393; @(posedge clk); #1;
    if(data_out !== 16'sd4979) begin $display("Mismatch sample 26: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25210; @(posedge clk); #1;
    if(data_out !== 16'sd5291) begin $display("Mismatch sample 27: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28783; @(posedge clk); #1;
    if(data_out !== 16'sd4886) begin $display("Mismatch sample 28: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd956; @(posedge clk); #1;
    if(data_out !== 16'sd4396) begin $display("Mismatch sample 29: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd3051; @(posedge clk); #1;
    if(data_out !== 16'sd3443) begin $display("Mismatch sample 30: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12366; @(posedge clk); #1;
    if(data_out !== 16'sd3058) begin $display("Mismatch sample 31: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd31573; @(posedge clk); #1;
    if(data_out !== 16'sd2147) begin $display("Mismatch sample 32: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5296; @(posedge clk); #1;
    if(data_out !== 16'sd991) begin $display("Mismatch sample 33: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd8271; @(posedge clk); #1;
    if(data_out !== 16'sd136) begin $display("Mismatch sample 34: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4450; @(posedge clk); #1;
    if(data_out !== 16'sd65) begin $display("Mismatch sample 35: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd7847; @(posedge clk); #1;
    if(data_out !== 16'sd1338) begin $display("Mismatch sample 36: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9500; @(posedge clk); #1;
    if(data_out !== 16'sd2995) begin $display("Mismatch sample 37: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd5901; @(posedge clk); #1;
    if(data_out !== 16'sd4321) begin $display("Mismatch sample 38: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26186; @(posedge clk); #1;
    if(data_out !== 16'sd4994) begin $display("Mismatch sample 39: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd17821; @(posedge clk); #1;
    if(data_out !== 16'sd4703) begin $display("Mismatch sample 40: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd2648; @(posedge clk); #1;
    if(data_out !== 16'sd3530) begin $display("Mismatch sample 41: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd30249; @(posedge clk); #1;
    if(data_out !== 16'sd1962) begin $display("Mismatch sample 42: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd25270; @(posedge clk); #1;
    if(data_out !== -16'sd176) begin $display("Mismatch sample 43: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27681; @(posedge clk); #1;
    if(data_out !== -16'sd1488) begin $display("Mismatch sample 44: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26868; @(posedge clk); #1;
    if(data_out !== -16'sd1756) begin $display("Mismatch sample 45: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26363; @(posedge clk); #1;
    if(data_out !== -16'sd2343) begin $display("Mismatch sample 46: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12318; @(posedge clk); #1;
    if(data_out !== -16'sd3758) begin $display("Mismatch sample 47: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22757; @(posedge clk); #1;
    if(data_out !== -16'sd4176) begin $display("Mismatch sample 48: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19200; @(posedge clk); #1;
    if(data_out !== -16'sd4387) begin $display("Mismatch sample 49: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd9311; @(posedge clk); #1;
    if(data_out !== -16'sd3600) begin $display("Mismatch sample 50: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd22990; @(posedge clk); #1;
    if(data_out !== -16'sd1922) begin $display("Mismatch sample 51: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd20457; @(posedge clk); #1;
    if(data_out !== 16'sd436) begin $display("Mismatch sample 52: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd10188; @(posedge clk); #1;
    if(data_out !== 16'sd1835) begin $display("Mismatch sample 53: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23037; @(posedge clk); #1;
    if(data_out !== 16'sd2425) begin $display("Mismatch sample 54: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd27770; @(posedge clk); #1;
    if(data_out !== 16'sd1776) begin $display("Mismatch sample 55: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd10963; @(posedge clk); #1;
    if(data_out !== 16'sd1246) begin $display("Mismatch sample 56: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19288; @(posedge clk); #1;
    if(data_out !== 16'sd746) begin $display("Mismatch sample 57: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4071; @(posedge clk); #1;
    if(data_out !== -16'sd381) begin $display("Mismatch sample 58: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13286; @(posedge clk); #1;
    if(data_out !== -16'sd2385) begin $display("Mismatch sample 59: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21327; @(posedge clk); #1;
    if(data_out !== -16'sd4462) begin $display("Mismatch sample 60: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd15964; @(posedge clk); #1;
    if(data_out !== -16'sd6259) begin $display("Mismatch sample 61: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14837; @(posedge clk); #1;
    if(data_out !== -16'sd7000) begin $display("Mismatch sample 62: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25582; @(posedge clk); #1;
    if(data_out !== -16'sd7052) begin $display("Mismatch sample 63: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9611; @(posedge clk); #1;
    if(data_out !== -16'sd7162) begin $display("Mismatch sample 64: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd22192; @(posedge clk); #1;
    if(data_out !== -16'sd6530) begin $display("Mismatch sample 65: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27759; @(posedge clk); #1;
    if(data_out !== -16'sd5736) begin $display("Mismatch sample 66: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd20734; @(posedge clk); #1;
    if(data_out !== -16'sd4124) begin $display("Mismatch sample 67: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23943; @(posedge clk); #1;
    if(data_out !== -16'sd2562) begin $display("Mismatch sample 68: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27012; @(posedge clk); #1;
    if(data_out !== -16'sd2101) begin $display("Mismatch sample 69: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd6381; @(posedge clk); #1;
    if(data_out !== -16'sd1409) begin $display("Mismatch sample 70: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd16726; @(posedge clk); #1;
    if(data_out !== -16'sd1129) begin $display("Mismatch sample 71: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd30531; @(posedge clk); #1;
    if(data_out !== -16'sd1871) begin $display("Mismatch sample 72: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd13048; @(posedge clk); #1;
    if(data_out !== -16'sd2013) begin $display("Mismatch sample 73: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd23031; @(posedge clk); #1;
    if(data_out !== -16'sd1705) begin $display("Mismatch sample 74: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd4374; @(posedge clk); #1;
    if(data_out !== -16'sd758) begin $display("Mismatch sample 75: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd20801; @(posedge clk); #1;
    if(data_out !== -16'sd641) begin $display("Mismatch sample 76: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1620; @(posedge clk); #1;
    if(data_out !== -16'sd694) begin $display("Mismatch sample 77: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd10523; @(posedge clk); #1;
    if(data_out !== 16'sd52) begin $display("Mismatch sample 78: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13378; @(posedge clk); #1;
    if(data_out !== 16'sd932) begin $display("Mismatch sample 79: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5; @(posedge clk); #1;
    if(data_out !== 16'sd2097) begin $display("Mismatch sample 80: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3680; @(posedge clk); #1;
    if(data_out !== 16'sd2958) begin $display("Mismatch sample 81: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1921; @(posedge clk); #1;
    if(data_out !== 16'sd3547) begin $display("Mismatch sample 82: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd11218; @(posedge clk); #1;
    if(data_out !== 16'sd3308) begin $display("Mismatch sample 83: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9975; @(posedge clk); #1;
    if(data_out !== 16'sd2540) begin $display("Mismatch sample 84: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28972; @(posedge clk); #1;
    if(data_out !== 16'sd1571) begin $display("Mismatch sample 85: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21469; @(posedge clk); #1;
    if(data_out !== 16'sd677) begin $display("Mismatch sample 86: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23770; @(posedge clk); #1;
    if(data_out !== 16'sd381) begin $display("Mismatch sample 87: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd24653; @(posedge clk); #1;
    if(data_out !== 16'sd159) begin $display("Mismatch sample 88: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd31416; @(posedge clk); #1;
    if(data_out !== -16'sd942) begin $display("Mismatch sample 89: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26631; @(posedge clk); #1;
    if(data_out !== -16'sd2848) begin $display("Mismatch sample 90: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd1466; @(posedge clk); #1;
    if(data_out !== -16'sd5130) begin $display("Mismatch sample 91: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22993; @(posedge clk); #1;
    if(data_out !== -16'sd5912) begin $display("Mismatch sample 92: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14084; @(posedge clk); #1;
    if(data_out !== -16'sd6248) begin $display("Mismatch sample 93: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28629; @(posedge clk); #1;
    if(data_out !== -16'sd5395) begin $display("Mismatch sample 94: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26510; @(posedge clk); #1;
    if(data_out !== -16'sd3827) begin $display("Mismatch sample 95: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13931; @(posedge clk); #1;
    if(data_out !== -16'sd1573) begin $display("Mismatch sample 96: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd29200; @(posedge clk); #1;
    if(data_out !== 16'sd42) begin $display("Mismatch sample 97: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14193; @(posedge clk); #1;
    if(data_out !== -16'sd80) begin $display("Mismatch sample 98: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd7330; @(posedge clk); #1;
    if(data_out !== -16'sd218) begin $display("Mismatch sample 99: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3175; @(posedge clk); #1;
    if(data_out !== -16'sd451) begin $display("Mismatch sample 100: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd18468; @(posedge clk); #1;
    if(data_out !== -16'sd1560) begin $display("Mismatch sample 101: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd2765; @(posedge clk); #1;
    if(data_out !== -16'sd3203) begin $display("Mismatch sample 102: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd18186; @(posedge clk); #1;
    if(data_out !== -16'sd4190) begin $display("Mismatch sample 103: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd23517; @(posedge clk); #1;
    if(data_out !== -16'sd4364) begin $display("Mismatch sample 104: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21608; @(posedge clk); #1;
    if(data_out !== -16'sd3385) begin $display("Mismatch sample 105: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14871; @(posedge clk); #1;
    if(data_out !== -16'sd2052) begin $display("Mismatch sample 106: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4234; @(posedge clk); #1;
    if(data_out !== -16'sd1487) begin $display("Mismatch sample 107: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14751; @(posedge clk); #1;
    if(data_out !== -16'sd753) begin $display("Mismatch sample 108: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21428; @(posedge clk); #1;
    if(data_out !== -16'sd586) begin $display("Mismatch sample 109: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1221; @(posedge clk); #1;
    if(data_out !== -16'sd345) begin $display("Mismatch sample 110: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14174; @(posedge clk); #1;
    if(data_out !== 16'sd120) begin $display("Mismatch sample 111: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14117; @(posedge clk); #1;
    if(data_out !== 16'sd119) begin $display("Mismatch sample 112: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd32320; @(posedge clk); #1;
    if(data_out !== -16'sd828) begin $display("Mismatch sample 113: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9057; @(posedge clk); #1;
    if(data_out !== -16'sd1970) begin $display("Mismatch sample 114: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32398; @(posedge clk); #1;
    if(data_out !== -16'sd2248) begin $display("Mismatch sample 115: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3543; @(posedge clk); #1;
    if(data_out !== -16'sd1419) begin $display("Mismatch sample 116: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd27276; @(posedge clk); #1;
    if(data_out !== 16'sd705) begin $display("Mismatch sample 117: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd15805; @(posedge clk); #1;
    if(data_out !== 16'sd2525) begin $display("Mismatch sample 118: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32058; @(posedge clk); #1;
    if(data_out !== 16'sd2406) begin $display("Mismatch sample 119: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd31597; @(posedge clk); #1;
    if(data_out !== 16'sd1083) begin $display("Mismatch sample 120: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23064; @(posedge clk); #1;
    if(data_out !== -16'sd1120) begin $display("Mismatch sample 121: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd12249; @(posedge clk); #1;
    if(data_out !== -16'sd3494) begin $display("Mismatch sample 122: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd3930; @(posedge clk); #1;
    if(data_out !== -16'sd6009) begin $display("Mismatch sample 123: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26895; @(posedge clk); #1;
    if(data_out !== -16'sd6689) begin $display("Mismatch sample 124: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23652; @(posedge clk); #1;
    if(data_out !== -16'sd6500) begin $display("Mismatch sample 125: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27211; @(posedge clk); #1;
    if(data_out !== -16'sd6227) begin $display("Mismatch sample 126: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd15150; @(posedge clk); #1;
    if(data_out !== -16'sd5656) begin $display("Mismatch sample 127: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd5583) begin $display("Mismatch sample 128: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd6280) begin $display("Mismatch sample 129: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd6001) begin $display("Mismatch sample 130: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd4366) begin $display("Mismatch sample 131: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd2353) begin $display("Mismatch sample 132: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd740) begin $display("Mismatch sample 133: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd233) begin $display("Mismatch sample 134: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd663) begin $display("Mismatch sample 135: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd747) begin $display("Mismatch sample 136: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd660) begin $display("Mismatch sample 137: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd515) begin $display("Mismatch sample 138: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd372) begin $display("Mismatch sample 139: %d",data_out); errors=errors+1; end
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
    if(data_out !== 16'sd983) begin $display("Mismatch post-reset sample 4: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd25532; @(posedge clk); #1;
    if(data_out !== 16'sd1229) begin $display("Mismatch post-reset sample 5: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1325; @(posedge clk); #1;
    if(data_out !== 16'sd770) begin $display("Mismatch post-reset sample 6: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd15850; @(posedge clk); #1;
    if(data_out !== 16'sd140) begin $display("Mismatch post-reset sample 7: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28035; @(posedge clk); #1;
    if(data_out !== -16'sd323) begin $display("Mismatch post-reset sample 8: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12728; @(posedge clk); #1;
    if(data_out !== -16'sd1307) begin $display("Mismatch post-reset sample 9: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13897; @(posedge clk); #1;
    if(data_out !== -16'sd2334) begin $display("Mismatch post-reset sample 10: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd7082; @(posedge clk); #1;
    if(data_out !== -16'sd3385) begin $display("Mismatch post-reset sample 11: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5889; @(posedge clk); #1;
    if(data_out !== -16'sd4850) begin $display("Mismatch post-reset sample 12: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd31636; @(posedge clk); #1;
    if(data_out !== -16'sd5537) begin $display("Mismatch post-reset sample 13: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19237; @(posedge clk); #1;
    if(data_out !== -16'sd5677) begin $display("Mismatch post-reset sample 14: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25726; @(posedge clk); #1;
    if(data_out !== -16'sd5115) begin $display("Mismatch post-reset sample 15: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd16837; @(posedge clk); #1;
    if(data_out !== -16'sd3947) begin $display("Mismatch post-reset sample 16: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14240; @(posedge clk); #1;
    if(data_out !== -16'sd3599) begin $display("Mismatch post-reset sample 17: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd24639; @(posedge clk); #1;
    if(data_out !== -16'sd4282) begin $display("Mismatch post-reset sample 18: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3950; @(posedge clk); #1;
    if(data_out !== -16'sd4223) begin $display("Mismatch post-reset sample 19: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22217; @(posedge clk); #1;
    if(data_out !== -16'sd2884) begin $display("Mismatch post-reset sample 20: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd29076; @(posedge clk); #1;
    if(data_out !== -16'sd1601) begin $display("Mismatch post-reset sample 21: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd20509; @(posedge clk); #1;
    if(data_out !== -16'sd63) begin $display("Mismatch post-reset sample 22: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd21478; @(posedge clk); #1;
    if(data_out !== 16'sd1140) begin $display("Mismatch post-reset sample 23: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9715; @(posedge clk); #1;
    if(data_out !== 16'sd2410) begin $display("Mismatch post-reset sample 24: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd13320; @(posedge clk); #1;
    if(data_out !== 16'sd4203) begin $display("Mismatch post-reset sample 25: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14393; @(posedge clk); #1;
    if(data_out !== 16'sd4979) begin $display("Mismatch post-reset sample 26: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25210; @(posedge clk); #1;
    if(data_out !== 16'sd5291) begin $display("Mismatch post-reset sample 27: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28783; @(posedge clk); #1;
    if(data_out !== 16'sd4886) begin $display("Mismatch post-reset sample 28: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd956; @(posedge clk); #1;
    if(data_out !== 16'sd4396) begin $display("Mismatch post-reset sample 29: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd3051; @(posedge clk); #1;
    if(data_out !== 16'sd3443) begin $display("Mismatch post-reset sample 30: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12366; @(posedge clk); #1;
    if(data_out !== 16'sd3058) begin $display("Mismatch post-reset sample 31: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd31573; @(posedge clk); #1;
    if(data_out !== 16'sd2147) begin $display("Mismatch post-reset sample 32: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5296; @(posedge clk); #1;
    if(data_out !== 16'sd991) begin $display("Mismatch post-reset sample 33: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd8271; @(posedge clk); #1;
    if(data_out !== 16'sd136) begin $display("Mismatch post-reset sample 34: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4450; @(posedge clk); #1;
    if(data_out !== 16'sd65) begin $display("Mismatch post-reset sample 35: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd7847; @(posedge clk); #1;
    if(data_out !== 16'sd1338) begin $display("Mismatch post-reset sample 36: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9500; @(posedge clk); #1;
    if(data_out !== 16'sd2995) begin $display("Mismatch post-reset sample 37: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd5901; @(posedge clk); #1;
    if(data_out !== 16'sd4321) begin $display("Mismatch post-reset sample 38: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26186; @(posedge clk); #1;
    if(data_out !== 16'sd4994) begin $display("Mismatch post-reset sample 39: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd17821; @(posedge clk); #1;
    if(data_out !== 16'sd4703) begin $display("Mismatch post-reset sample 40: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd2648; @(posedge clk); #1;
    if(data_out !== 16'sd3530) begin $display("Mismatch post-reset sample 41: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd30249; @(posedge clk); #1;
    if(data_out !== 16'sd1962) begin $display("Mismatch post-reset sample 42: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd25270; @(posedge clk); #1;
    if(data_out !== -16'sd176) begin $display("Mismatch post-reset sample 43: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27681; @(posedge clk); #1;
    if(data_out !== -16'sd1488) begin $display("Mismatch post-reset sample 44: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26868; @(posedge clk); #1;
    if(data_out !== -16'sd1756) begin $display("Mismatch post-reset sample 45: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26363; @(posedge clk); #1;
    if(data_out !== -16'sd2343) begin $display("Mismatch post-reset sample 46: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12318; @(posedge clk); #1;
    if(data_out !== -16'sd3758) begin $display("Mismatch post-reset sample 47: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22757; @(posedge clk); #1;
    if(data_out !== -16'sd4176) begin $display("Mismatch post-reset sample 48: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19200; @(posedge clk); #1;
    if(data_out !== -16'sd4387) begin $display("Mismatch post-reset sample 49: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd9311; @(posedge clk); #1;
    if(data_out !== -16'sd3600) begin $display("Mismatch post-reset sample 50: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd22990; @(posedge clk); #1;
    if(data_out !== -16'sd1922) begin $display("Mismatch post-reset sample 51: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd20457; @(posedge clk); #1;
    if(data_out !== 16'sd436) begin $display("Mismatch post-reset sample 52: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd10188; @(posedge clk); #1;
    if(data_out !== 16'sd1835) begin $display("Mismatch post-reset sample 53: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23037; @(posedge clk); #1;
    if(data_out !== 16'sd2425) begin $display("Mismatch post-reset sample 54: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd27770; @(posedge clk); #1;
    if(data_out !== 16'sd1776) begin $display("Mismatch post-reset sample 55: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd10963; @(posedge clk); #1;
    if(data_out !== 16'sd1246) begin $display("Mismatch post-reset sample 56: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19288; @(posedge clk); #1;
    if(data_out !== 16'sd746) begin $display("Mismatch post-reset sample 57: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4071; @(posedge clk); #1;
    if(data_out !== -16'sd381) begin $display("Mismatch post-reset sample 58: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13286; @(posedge clk); #1;
    if(data_out !== -16'sd2385) begin $display("Mismatch post-reset sample 59: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21327; @(posedge clk); #1;
    if(data_out !== -16'sd4462) begin $display("Mismatch post-reset sample 60: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd15964; @(posedge clk); #1;
    if(data_out !== -16'sd6259) begin $display("Mismatch post-reset sample 61: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14837; @(posedge clk); #1;
    if(data_out !== -16'sd7000) begin $display("Mismatch post-reset sample 62: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25582; @(posedge clk); #1;
    if(data_out !== -16'sd7052) begin $display("Mismatch post-reset sample 63: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9611; @(posedge clk); #1;
    if(data_out !== -16'sd7162) begin $display("Mismatch post-reset sample 64: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd22192; @(posedge clk); #1;
    if(data_out !== -16'sd6530) begin $display("Mismatch post-reset sample 65: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27759; @(posedge clk); #1;
    if(data_out !== -16'sd5736) begin $display("Mismatch post-reset sample 66: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd20734; @(posedge clk); #1;
    if(data_out !== -16'sd4124) begin $display("Mismatch post-reset sample 67: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23943; @(posedge clk); #1;
    if(data_out !== -16'sd2562) begin $display("Mismatch post-reset sample 68: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27012; @(posedge clk); #1;
    if(data_out !== -16'sd2101) begin $display("Mismatch post-reset sample 69: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd6381; @(posedge clk); #1;
    if(data_out !== -16'sd1409) begin $display("Mismatch post-reset sample 70: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd16726; @(posedge clk); #1;
    if(data_out !== -16'sd1129) begin $display("Mismatch post-reset sample 71: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd30531; @(posedge clk); #1;
    if(data_out !== -16'sd1871) begin $display("Mismatch post-reset sample 72: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd13048; @(posedge clk); #1;
    if(data_out !== -16'sd2013) begin $display("Mismatch post-reset sample 73: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd23031; @(posedge clk); #1;
    if(data_out !== -16'sd1705) begin $display("Mismatch post-reset sample 74: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd4374; @(posedge clk); #1;
    if(data_out !== -16'sd758) begin $display("Mismatch post-reset sample 75: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd20801; @(posedge clk); #1;
    if(data_out !== -16'sd641) begin $display("Mismatch post-reset sample 76: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1620; @(posedge clk); #1;
    if(data_out !== -16'sd694) begin $display("Mismatch post-reset sample 77: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd10523; @(posedge clk); #1;
    if(data_out !== 16'sd52) begin $display("Mismatch post-reset sample 78: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13378; @(posedge clk); #1;
    if(data_out !== 16'sd932) begin $display("Mismatch post-reset sample 79: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5; @(posedge clk); #1;
    if(data_out !== 16'sd2097) begin $display("Mismatch post-reset sample 80: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3680; @(posedge clk); #1;
    if(data_out !== 16'sd2958) begin $display("Mismatch post-reset sample 81: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1921; @(posedge clk); #1;
    if(data_out !== 16'sd3547) begin $display("Mismatch post-reset sample 82: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd11218; @(posedge clk); #1;
    if(data_out !== 16'sd3308) begin $display("Mismatch post-reset sample 83: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9975; @(posedge clk); #1;
    if(data_out !== 16'sd2540) begin $display("Mismatch post-reset sample 84: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28972; @(posedge clk); #1;
    if(data_out !== 16'sd1571) begin $display("Mismatch post-reset sample 85: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21469; @(posedge clk); #1;
    if(data_out !== 16'sd677) begin $display("Mismatch post-reset sample 86: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23770; @(posedge clk); #1;
    if(data_out !== 16'sd381) begin $display("Mismatch post-reset sample 87: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd24653; @(posedge clk); #1;
    if(data_out !== 16'sd159) begin $display("Mismatch post-reset sample 88: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd31416; @(posedge clk); #1;
    if(data_out !== -16'sd942) begin $display("Mismatch post-reset sample 89: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26631; @(posedge clk); #1;
    if(data_out !== -16'sd2848) begin $display("Mismatch post-reset sample 90: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd1466; @(posedge clk); #1;
    if(data_out !== -16'sd5130) begin $display("Mismatch post-reset sample 91: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22993; @(posedge clk); #1;
    if(data_out !== -16'sd5912) begin $display("Mismatch post-reset sample 92: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14084; @(posedge clk); #1;
    if(data_out !== -16'sd6248) begin $display("Mismatch post-reset sample 93: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28629; @(posedge clk); #1;
    if(data_out !== -16'sd5395) begin $display("Mismatch post-reset sample 94: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26510; @(posedge clk); #1;
    if(data_out !== -16'sd3827) begin $display("Mismatch post-reset sample 95: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13931; @(posedge clk); #1;
    if(data_out !== -16'sd1573) begin $display("Mismatch post-reset sample 96: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd29200; @(posedge clk); #1;
    if(data_out !== 16'sd42) begin $display("Mismatch post-reset sample 97: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14193; @(posedge clk); #1;
    if(data_out !== -16'sd80) begin $display("Mismatch post-reset sample 98: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd7330; @(posedge clk); #1;
    if(data_out !== -16'sd218) begin $display("Mismatch post-reset sample 99: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3175; @(posedge clk); #1;
    if(data_out !== -16'sd451) begin $display("Mismatch post-reset sample 100: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd18468; @(posedge clk); #1;
    if(data_out !== -16'sd1560) begin $display("Mismatch post-reset sample 101: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd2765; @(posedge clk); #1;
    if(data_out !== -16'sd3203) begin $display("Mismatch post-reset sample 102: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd18186; @(posedge clk); #1;
    if(data_out !== -16'sd4190) begin $display("Mismatch post-reset sample 103: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd23517; @(posedge clk); #1;
    if(data_out !== -16'sd4364) begin $display("Mismatch post-reset sample 104: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21608; @(posedge clk); #1;
    if(data_out !== -16'sd3385) begin $display("Mismatch post-reset sample 105: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14871; @(posedge clk); #1;
    if(data_out !== -16'sd2052) begin $display("Mismatch post-reset sample 106: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4234; @(posedge clk); #1;
    if(data_out !== -16'sd1487) begin $display("Mismatch post-reset sample 107: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14751; @(posedge clk); #1;
    if(data_out !== -16'sd753) begin $display("Mismatch post-reset sample 108: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21428; @(posedge clk); #1;
    if(data_out !== -16'sd586) begin $display("Mismatch post-reset sample 109: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1221; @(posedge clk); #1;
    if(data_out !== -16'sd345) begin $display("Mismatch post-reset sample 110: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14174; @(posedge clk); #1;
    if(data_out !== 16'sd120) begin $display("Mismatch post-reset sample 111: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14117; @(posedge clk); #1;
    if(data_out !== 16'sd119) begin $display("Mismatch post-reset sample 112: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd32320; @(posedge clk); #1;
    if(data_out !== -16'sd828) begin $display("Mismatch post-reset sample 113: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9057; @(posedge clk); #1;
    if(data_out !== -16'sd1970) begin $display("Mismatch post-reset sample 114: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32398; @(posedge clk); #1;
    if(data_out !== -16'sd2248) begin $display("Mismatch post-reset sample 115: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3543; @(posedge clk); #1;
    if(data_out !== -16'sd1419) begin $display("Mismatch post-reset sample 116: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd27276; @(posedge clk); #1;
    if(data_out !== 16'sd705) begin $display("Mismatch post-reset sample 117: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd15805; @(posedge clk); #1;
    if(data_out !== 16'sd2525) begin $display("Mismatch post-reset sample 118: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32058; @(posedge clk); #1;
    if(data_out !== 16'sd2406) begin $display("Mismatch post-reset sample 119: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd31597; @(posedge clk); #1;
    if(data_out !== 16'sd1083) begin $display("Mismatch post-reset sample 120: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23064; @(posedge clk); #1;
    if(data_out !== -16'sd1120) begin $display("Mismatch post-reset sample 121: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd12249; @(posedge clk); #1;
    if(data_out !== -16'sd3494) begin $display("Mismatch post-reset sample 122: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd3930; @(posedge clk); #1;
    if(data_out !== -16'sd6009) begin $display("Mismatch post-reset sample 123: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26895; @(posedge clk); #1;
    if(data_out !== -16'sd6689) begin $display("Mismatch post-reset sample 124: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23652; @(posedge clk); #1;
    if(data_out !== -16'sd6500) begin $display("Mismatch post-reset sample 125: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27211; @(posedge clk); #1;
    if(data_out !== -16'sd6227) begin $display("Mismatch post-reset sample 126: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd15150; @(posedge clk); #1;
    if(data_out !== -16'sd5656) begin $display("Mismatch post-reset sample 127: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd5583) begin $display("Mismatch post-reset sample 128: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd6280) begin $display("Mismatch post-reset sample 129: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd6001) begin $display("Mismatch post-reset sample 130: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd4366) begin $display("Mismatch post-reset sample 131: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd2353) begin $display("Mismatch post-reset sample 132: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd740) begin $display("Mismatch post-reset sample 133: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd233) begin $display("Mismatch post-reset sample 134: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd663) begin $display("Mismatch post-reset sample 135: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd747) begin $display("Mismatch post-reset sample 136: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd660) begin $display("Mismatch post-reset sample 137: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd515) begin $display("Mismatch post-reset sample 138: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd372) begin $display("Mismatch post-reset sample 139: %d",data_out); errors=errors+1; end
    @(negedge clk);
    $display("TIMING: FO1/SO2, capture counts as cycle 1; total 5 cycles; edge offset 4; model delay 0");
    $display("Golden vector saturation count per run: 0");
    if(errors==0) $display("PASS: four-port SOS, continuous samples, reset, latency");
    else $fatal(1,"FAIL: %d mismatches",errors);
    $finish;
  end
endmodule
