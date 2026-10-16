`timescale 1ns/1ps
// Golden vectors exercise 0 saturated outputs per run.
// Zero means this filter/vector pair does not test output clipping.
module digital_filter_tb;
  reg clk=0; always #5 clk=~clk;
  reg rst_n=0;
  reg signed [15:0] data_in=0;
  wire signed [15:0] data_out;
  integer errors=0;
  // Input before capture edge E0; compare after E0 + 0 edges (1 cycles, capture counts as 1).
  digital_filter dut(.clk(clk),.rst_n(rst_n),.data_in(data_in),.data_out(data_out));
  initial begin
    @(posedge clk); #1; if(data_out !== 0) errors=errors+1;
    @(negedge clk); rst_n=1;
    data_in=16'sd32767; @(posedge clk); #1;
    if(data_out !== 16'sd16384) begin $display("Mismatch sample 0: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32768; @(posedge clk); #1;
    if(data_out !== -16'sd12288) begin $display("Mismatch sample 1: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd3072) begin $display("Mismatch sample 2: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd1; @(posedge clk); #1;
    if(data_out !== -16'sd768) begin $display("Mismatch sample 3: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1; @(posedge clk); #1;
    if(data_out !== -16'sd193) begin $display("Mismatch sample 4: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd25532; @(posedge clk); #1;
    if(data_out !== -16'sd12814) begin $display("Mismatch sample 5: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1325; @(posedge clk); #1;
    if(data_out !== -16'sd3866) begin $display("Mismatch sample 6: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd15850; @(posedge clk); #1;
    if(data_out !== -16'sd8892) begin $display("Mismatch sample 7: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28035; @(posedge clk); #1;
    if(data_out !== -16'sd16241) begin $display("Mismatch sample 8: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12728; @(posedge clk); #1;
    if(data_out !== 16'sd2304) begin $display("Mismatch sample 9: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13897; @(posedge clk); #1;
    if(data_out !== -16'sd6373) begin $display("Mismatch sample 10: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd7082; @(posedge clk); #1;
    if(data_out !== 16'sd1948) begin $display("Mismatch sample 11: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5889; @(posedge clk); #1;
    if(data_out !== 16'sd3432) begin $display("Mismatch sample 12: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd31636; @(posedge clk); #1;
    if(data_out !== -16'sd14960) begin $display("Mismatch sample 13: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19237; @(posedge clk); #1;
    if(data_out !== -16'sd13359) begin $display("Mismatch sample 14: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25726; @(posedge clk); #1;
    if(data_out !== 16'sd9523) begin $display("Mismatch sample 15: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd16837; @(posedge clk); #1;
    if(data_out !== 16'sd10799) begin $display("Mismatch sample 16: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14240; @(posedge clk); #1;
    if(data_out !== -16'sd4420) begin $display("Mismatch sample 17: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd24639; @(posedge clk); #1;
    if(data_out !== 16'sd11215) begin $display("Mismatch sample 18: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3950; @(posedge clk); #1;
    if(data_out !== 16'sd829) begin $display("Mismatch sample 19: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22217; @(posedge clk); #1;
    if(data_out !== 16'sd11316) begin $display("Mismatch sample 20: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd29076; @(posedge clk); #1;
    if(data_out !== 16'sd17367) begin $display("Mismatch sample 21: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd20509; @(posedge clk); #1;
    if(data_out !== -16'sd5913) begin $display("Mismatch sample 22: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd21478; @(posedge clk); #1;
    if(data_out !== 16'sd9261) begin $display("Mismatch sample 23: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9715; @(posedge clk); #1;
    if(data_out !== -16'sd2542) begin $display("Mismatch sample 24: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd13320; @(posedge clk); #1;
    if(data_out !== 16'sd6025) begin $display("Mismatch sample 25: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14393; @(posedge clk); #1;
    if(data_out !== -16'sd5690) begin $display("Mismatch sample 26: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25210; @(posedge clk); #1;
    if(data_out !== 16'sd11183) begin $display("Mismatch sample 27: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28783; @(posedge clk); #1;
    if(data_out !== -16'sd11596) begin $display("Mismatch sample 28: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd956; @(posedge clk); #1;
    if(data_out !== -16'sd2421) begin $display("Mismatch sample 29: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd3051; @(posedge clk); #1;
    if(data_out !== 16'sd920) begin $display("Mismatch sample 30: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12366; @(posedge clk); #1;
    if(data_out !== 16'sd6413) begin $display("Mismatch sample 31: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd31573; @(posedge clk); #1;
    if(data_out !== 16'sd17390) begin $display("Mismatch sample 32: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5296; @(posedge clk); #1;
    if(data_out !== 16'sd6996) begin $display("Mismatch sample 33: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd8271; @(posedge clk); #1;
    if(data_out !== 16'sd5885) begin $display("Mismatch sample 34: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4450; @(posedge clk); #1;
    if(data_out !== 16'sd3696) begin $display("Mismatch sample 35: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd7847; @(posedge clk); #1;
    if(data_out !== -16'sd3000) begin $display("Mismatch sample 36: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9500; @(posedge clk); #1;
    if(data_out !== -16'sd5500) begin $display("Mismatch sample 37: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd5901; @(posedge clk); #1;
    if(data_out !== -16'sd4326) begin $display("Mismatch sample 38: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26186; @(posedge clk); #1;
    if(data_out !== -16'sd14175) begin $display("Mismatch sample 39: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd17821; @(posedge clk); #1;
    if(data_out !== 16'sd5367) begin $display("Mismatch sample 40: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd2648; @(posedge clk); #1;
    if(data_out !== 16'sd2666) begin $display("Mismatch sample 41: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd30249; @(posedge clk); #1;
    if(data_out !== -16'sd14458) begin $display("Mismatch sample 42: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd25270; @(posedge clk); #1;
    if(data_out !== -16'sd16250) begin $display("Mismatch sample 43: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27681; @(posedge clk); #1;
    if(data_out !== 16'sd9778) begin $display("Mismatch sample 44: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26868; @(posedge clk); #1;
    if(data_out !== -16'sd10990) begin $display("Mismatch sample 45: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26363; @(posedge clk); #1;
    if(data_out !== 16'sd10434) begin $display("Mismatch sample 46: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12318; @(posedge clk); #1;
    if(data_out !== 16'sd8768) begin $display("Mismatch sample 47: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22757; @(posedge clk); #1;
    if(data_out !== 16'sd13571) begin $display("Mismatch sample 48: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19200; @(posedge clk); #1;
    if(data_out !== -16'sd6207) begin $display("Mismatch sample 49: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd9311; @(posedge clk); #1;
    if(data_out !== 16'sd3104) begin $display("Mismatch sample 50: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd22990; @(posedge clk); #1;
    if(data_out !== -16'sd10719) begin $display("Mismatch sample 51: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd20457; @(posedge clk); #1;
    if(data_out !== 16'sd7549) begin $display("Mismatch sample 52: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd10188; @(posedge clk); #1;
    if(data_out !== -16'sd3207) begin $display("Mismatch sample 53: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23037; @(posedge clk); #1;
    if(data_out !== -16'sd12320) begin $display("Mismatch sample 54: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd27770; @(posedge clk); #1;
    if(data_out !== -16'sd16965) begin $display("Mismatch sample 55: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd10963; @(posedge clk); #1;
    if(data_out !== -16'sd9723) begin $display("Mismatch sample 56: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19288; @(posedge clk); #1;
    if(data_out !== -16'sd12075) begin $display("Mismatch sample 57: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4071; @(posedge clk); #1;
    if(data_out !== -16'sd983) begin $display("Mismatch sample 58: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13286; @(posedge clk); #1;
    if(data_out !== -16'sd6889) begin $display("Mismatch sample 59: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21327; @(posedge clk); #1;
    if(data_out !== -16'sd12386) begin $display("Mismatch sample 60: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd15964; @(posedge clk); #1;
    if(data_out !== 16'sd4886) begin $display("Mismatch sample 61: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14837; @(posedge clk); #1;
    if(data_out !== -16'sd6197) begin $display("Mismatch sample 62: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25582; @(posedge clk); #1;
    if(data_out !== 16'sd11242) begin $display("Mismatch sample 63: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9611; @(posedge clk); #1;
    if(data_out !== -16'sd1995) begin $display("Mismatch sample 64: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd22192; @(posedge clk); #1;
    if(data_out !== -16'sd11595) begin $display("Mismatch sample 65: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27759; @(posedge clk); #1;
    if(data_out !== 16'sd10981) begin $display("Mismatch sample 66: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd20734; @(posedge clk); #1;
    if(data_out !== -16'sd7622) begin $display("Mismatch sample 67: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23943; @(posedge clk); #1;
    if(data_out !== -16'sd13877) begin $display("Mismatch sample 68: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27012; @(posedge clk); #1;
    if(data_out !== 16'sd10037) begin $display("Mismatch sample 69: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd6381; @(posedge clk); #1;
    if(data_out !== -16'sd681) begin $display("Mismatch sample 70: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd16726; @(posedge clk); #1;
    if(data_out !== 16'sd8193) begin $display("Mismatch sample 71: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd30531; @(posedge clk); #1;
    if(data_out !== -16'sd13217) begin $display("Mismatch sample 72: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd13048; @(posedge clk); #1;
    if(data_out !== 16'sd3220) begin $display("Mismatch sample 73: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd23031; @(posedge clk); #1;
    if(data_out !== 16'sd12321) begin $display("Mismatch sample 74: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd4374; @(posedge clk); #1;
    if(data_out !== 16'sd893) begin $display("Mismatch sample 75: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd20801; @(posedge clk); #1;
    if(data_out !== 16'sd10624) begin $display("Mismatch sample 76: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1620; @(posedge clk); #1;
    if(data_out !== 16'sd1846) begin $display("Mismatch sample 77: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd10523; @(posedge clk); #1;
    if(data_out !== 16'sd5723) begin $display("Mismatch sample 78: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13378; @(posedge clk); #1;
    if(data_out !== -16'sd5258) begin $display("Mismatch sample 79: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5; @(posedge clk); #1;
    if(data_out !== -16'sd1312) begin $display("Mismatch sample 80: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3680; @(posedge clk); #1;
    if(data_out !== -16'sd2168) begin $display("Mismatch sample 81: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1921; @(posedge clk); #1;
    if(data_out !== -16'sd1503) begin $display("Mismatch sample 82: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd11218; @(posedge clk); #1;
    if(data_out !== 16'sd5233) begin $display("Mismatch sample 83: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9975; @(posedge clk); #1;
    if(data_out !== -16'sd3679) begin $display("Mismatch sample 84: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28972; @(posedge clk); #1;
    if(data_out !== -16'sd15406) begin $display("Mismatch sample 85: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21469; @(posedge clk); #1;
    if(data_out !== -16'sd14586) begin $display("Mismatch sample 86: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23770; @(posedge clk); #1;
    if(data_out !== -16'sd15532) begin $display("Mismatch sample 87: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd24653; @(posedge clk); #1;
    if(data_out !== 16'sd8444) begin $display("Mismatch sample 88: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd31416; @(posedge clk); #1;
    if(data_out !== -16'sd13597) begin $display("Mismatch sample 89: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26631; @(posedge clk); #1;
    if(data_out !== 16'sd9916) begin $display("Mismatch sample 90: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd1466; @(posedge clk); #1;
    if(data_out !== 16'sd3212) begin $display("Mismatch sample 91: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22993; @(posedge clk); #1;
    if(data_out !== 16'sd12300) begin $display("Mismatch sample 92: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14084; @(posedge clk); #1;
    if(data_out !== -16'sd3967) begin $display("Mismatch sample 93: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28629; @(posedge clk); #1;
    if(data_out !== -16'sd15306) begin $display("Mismatch sample 94: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26510; @(posedge clk); #1;
    if(data_out !== 16'sd9429) begin $display("Mismatch sample 95: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13931; @(posedge clk); #1;
    if(data_out !== -16'sd4608) begin $display("Mismatch sample 96: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd29200; @(posedge clk); #1;
    if(data_out !== -16'sd15752) begin $display("Mismatch sample 97: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14193; @(posedge clk); #1;
    if(data_out !== -16'sd11035) begin $display("Mismatch sample 98: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd7330; @(posedge clk); #1;
    if(data_out !== 16'sd906) begin $display("Mismatch sample 99: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3175; @(posedge clk); #1;
    if(data_out !== -16'sd1361) begin $display("Mismatch sample 100: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd18468; @(posedge clk); #1;
    if(data_out !== 16'sd8894) begin $display("Mismatch sample 101: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd2765; @(posedge clk); #1;
    if(data_out !== 16'sd841) begin $display("Mismatch sample 102: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd18186; @(posedge clk); #1;
    if(data_out !== -16'sd8883) begin $display("Mismatch sample 103: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd23517; @(posedge clk); #1;
    if(data_out !== 16'sd9538) begin $display("Mismatch sample 104: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21608; @(posedge clk); #1;
    if(data_out !== -16'sd8420) begin $display("Mismatch sample 105: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14871; @(posedge clk); #1;
    if(data_out !== 16'sd5331) begin $display("Mismatch sample 106: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4234; @(posedge clk); #1;
    if(data_out !== 16'sd3450) begin $display("Mismatch sample 107: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14751; @(posedge clk); #1;
    if(data_out !== -16'sd6513) begin $display("Mismatch sample 108: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21428; @(posedge clk); #1;
    if(data_out !== -16'sd12342) begin $display("Mismatch sample 109: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1221; @(posedge clk); #1;
    if(data_out !== -16'sd3696) begin $display("Mismatch sample 110: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14174; @(posedge clk); #1;
    if(data_out !== 16'sd6163) begin $display("Mismatch sample 111: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14117; @(posedge clk); #1;
    if(data_out !== 16'sd8599) begin $display("Mismatch sample 112: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd32320; @(posedge clk); #1;
    if(data_out !== 16'sd18310) begin $display("Mismatch sample 113: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9057; @(posedge clk); #1;
    if(data_out !== 16'sd49) begin $display("Mismatch sample 114: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32398; @(posedge clk); #1;
    if(data_out !== -16'sd16187) begin $display("Mismatch sample 115: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3543; @(posedge clk); #1;
    if(data_out !== -16'sd5818) begin $display("Mismatch sample 116: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd27276; @(posedge clk); #1;
    if(data_out !== -16'sd15093) begin $display("Mismatch sample 117: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd15805; @(posedge clk); #1;
    if(data_out !== -16'sd11676) begin $display("Mismatch sample 118: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32058; @(posedge clk); #1;
    if(data_out !== -16'sd18948) begin $display("Mismatch sample 119: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd31597; @(posedge clk); #1;
    if(data_out !== 16'sd11062) begin $display("Mismatch sample 120: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23064; @(posedge clk); #1;
    if(data_out !== -16'sd8767) begin $display("Mismatch sample 121: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd12249; @(posedge clk); #1;
    if(data_out !== -16'sd8316) begin $display("Mismatch sample 122: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd3930; @(posedge clk); #1;
    if(data_out !== -16'sd114) begin $display("Mismatch sample 123: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26895; @(posedge clk); #1;
    if(data_out !== -16'sd13476) begin $display("Mismatch sample 124: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23652; @(posedge clk); #1;
    if(data_out !== -16'sd15195) begin $display("Mismatch sample 125: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27211; @(posedge clk); #1;
    if(data_out !== 16'sd9807) begin $display("Mismatch sample 126: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd15150; @(posedge clk); #1;
    if(data_out !== 16'sd10027) begin $display("Mismatch sample 127: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd2507) begin $display("Mismatch sample 128: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd627) begin $display("Mismatch sample 129: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd157) begin $display("Mismatch sample 130: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd39) begin $display("Mismatch sample 131: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd10) begin $display("Mismatch sample 132: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd3) begin $display("Mismatch sample 133: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd1) begin $display("Mismatch sample 134: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd0) begin $display("Mismatch sample 135: %d",data_out); errors=errors+1; end
    @(negedge clk);
    rst_n=0; data_in=16'sd32767; @(posedge clk); #1;
    if(data_out !== 0) errors=errors+1;
    @(negedge clk); rst_n=1;
    data_in=16'sd32767; @(posedge clk); #1;
    if(data_out !== 16'sd16384) begin $display("Mismatch post-reset sample 0: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32768; @(posedge clk); #1;
    if(data_out !== -16'sd12288) begin $display("Mismatch post-reset sample 1: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== -16'sd3072) begin $display("Mismatch post-reset sample 2: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd1; @(posedge clk); #1;
    if(data_out !== -16'sd768) begin $display("Mismatch post-reset sample 3: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1; @(posedge clk); #1;
    if(data_out !== -16'sd193) begin $display("Mismatch post-reset sample 4: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd25532; @(posedge clk); #1;
    if(data_out !== -16'sd12814) begin $display("Mismatch post-reset sample 5: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1325; @(posedge clk); #1;
    if(data_out !== -16'sd3866) begin $display("Mismatch post-reset sample 6: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd15850; @(posedge clk); #1;
    if(data_out !== -16'sd8892) begin $display("Mismatch post-reset sample 7: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28035; @(posedge clk); #1;
    if(data_out !== -16'sd16241) begin $display("Mismatch post-reset sample 8: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12728; @(posedge clk); #1;
    if(data_out !== 16'sd2304) begin $display("Mismatch post-reset sample 9: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13897; @(posedge clk); #1;
    if(data_out !== -16'sd6373) begin $display("Mismatch post-reset sample 10: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd7082; @(posedge clk); #1;
    if(data_out !== 16'sd1948) begin $display("Mismatch post-reset sample 11: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5889; @(posedge clk); #1;
    if(data_out !== 16'sd3432) begin $display("Mismatch post-reset sample 12: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd31636; @(posedge clk); #1;
    if(data_out !== -16'sd14960) begin $display("Mismatch post-reset sample 13: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19237; @(posedge clk); #1;
    if(data_out !== -16'sd13359) begin $display("Mismatch post-reset sample 14: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25726; @(posedge clk); #1;
    if(data_out !== 16'sd9523) begin $display("Mismatch post-reset sample 15: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd16837; @(posedge clk); #1;
    if(data_out !== 16'sd10799) begin $display("Mismatch post-reset sample 16: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14240; @(posedge clk); #1;
    if(data_out !== -16'sd4420) begin $display("Mismatch post-reset sample 17: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd24639; @(posedge clk); #1;
    if(data_out !== 16'sd11215) begin $display("Mismatch post-reset sample 18: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3950; @(posedge clk); #1;
    if(data_out !== 16'sd829) begin $display("Mismatch post-reset sample 19: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22217; @(posedge clk); #1;
    if(data_out !== 16'sd11316) begin $display("Mismatch post-reset sample 20: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd29076; @(posedge clk); #1;
    if(data_out !== 16'sd17367) begin $display("Mismatch post-reset sample 21: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd20509; @(posedge clk); #1;
    if(data_out !== -16'sd5913) begin $display("Mismatch post-reset sample 22: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd21478; @(posedge clk); #1;
    if(data_out !== 16'sd9261) begin $display("Mismatch post-reset sample 23: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9715; @(posedge clk); #1;
    if(data_out !== -16'sd2542) begin $display("Mismatch post-reset sample 24: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd13320; @(posedge clk); #1;
    if(data_out !== 16'sd6025) begin $display("Mismatch post-reset sample 25: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14393; @(posedge clk); #1;
    if(data_out !== -16'sd5690) begin $display("Mismatch post-reset sample 26: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25210; @(posedge clk); #1;
    if(data_out !== 16'sd11183) begin $display("Mismatch post-reset sample 27: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28783; @(posedge clk); #1;
    if(data_out !== -16'sd11596) begin $display("Mismatch post-reset sample 28: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd956; @(posedge clk); #1;
    if(data_out !== -16'sd2421) begin $display("Mismatch post-reset sample 29: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd3051; @(posedge clk); #1;
    if(data_out !== 16'sd920) begin $display("Mismatch post-reset sample 30: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12366; @(posedge clk); #1;
    if(data_out !== 16'sd6413) begin $display("Mismatch post-reset sample 31: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd31573; @(posedge clk); #1;
    if(data_out !== 16'sd17390) begin $display("Mismatch post-reset sample 32: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5296; @(posedge clk); #1;
    if(data_out !== 16'sd6996) begin $display("Mismatch post-reset sample 33: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd8271; @(posedge clk); #1;
    if(data_out !== 16'sd5885) begin $display("Mismatch post-reset sample 34: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4450; @(posedge clk); #1;
    if(data_out !== 16'sd3696) begin $display("Mismatch post-reset sample 35: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd7847; @(posedge clk); #1;
    if(data_out !== -16'sd3000) begin $display("Mismatch post-reset sample 36: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9500; @(posedge clk); #1;
    if(data_out !== -16'sd5500) begin $display("Mismatch post-reset sample 37: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd5901; @(posedge clk); #1;
    if(data_out !== -16'sd4326) begin $display("Mismatch post-reset sample 38: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26186; @(posedge clk); #1;
    if(data_out !== -16'sd14175) begin $display("Mismatch post-reset sample 39: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd17821; @(posedge clk); #1;
    if(data_out !== 16'sd5367) begin $display("Mismatch post-reset sample 40: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd2648; @(posedge clk); #1;
    if(data_out !== 16'sd2666) begin $display("Mismatch post-reset sample 41: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd30249; @(posedge clk); #1;
    if(data_out !== -16'sd14458) begin $display("Mismatch post-reset sample 42: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd25270; @(posedge clk); #1;
    if(data_out !== -16'sd16250) begin $display("Mismatch post-reset sample 43: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27681; @(posedge clk); #1;
    if(data_out !== 16'sd9778) begin $display("Mismatch post-reset sample 44: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26868; @(posedge clk); #1;
    if(data_out !== -16'sd10990) begin $display("Mismatch post-reset sample 45: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26363; @(posedge clk); #1;
    if(data_out !== 16'sd10434) begin $display("Mismatch post-reset sample 46: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd12318; @(posedge clk); #1;
    if(data_out !== 16'sd8768) begin $display("Mismatch post-reset sample 47: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22757; @(posedge clk); #1;
    if(data_out !== 16'sd13571) begin $display("Mismatch post-reset sample 48: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19200; @(posedge clk); #1;
    if(data_out !== -16'sd6207) begin $display("Mismatch post-reset sample 49: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd9311; @(posedge clk); #1;
    if(data_out !== 16'sd3104) begin $display("Mismatch post-reset sample 50: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd22990; @(posedge clk); #1;
    if(data_out !== -16'sd10719) begin $display("Mismatch post-reset sample 51: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd20457; @(posedge clk); #1;
    if(data_out !== 16'sd7549) begin $display("Mismatch post-reset sample 52: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd10188; @(posedge clk); #1;
    if(data_out !== -16'sd3207) begin $display("Mismatch post-reset sample 53: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23037; @(posedge clk); #1;
    if(data_out !== -16'sd12320) begin $display("Mismatch post-reset sample 54: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd27770; @(posedge clk); #1;
    if(data_out !== -16'sd16965) begin $display("Mismatch post-reset sample 55: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd10963; @(posedge clk); #1;
    if(data_out !== -16'sd9723) begin $display("Mismatch post-reset sample 56: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd19288; @(posedge clk); #1;
    if(data_out !== -16'sd12075) begin $display("Mismatch post-reset sample 57: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4071; @(posedge clk); #1;
    if(data_out !== -16'sd983) begin $display("Mismatch post-reset sample 58: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13286; @(posedge clk); #1;
    if(data_out !== -16'sd6889) begin $display("Mismatch post-reset sample 59: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21327; @(posedge clk); #1;
    if(data_out !== -16'sd12386) begin $display("Mismatch post-reset sample 60: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd15964; @(posedge clk); #1;
    if(data_out !== 16'sd4886) begin $display("Mismatch post-reset sample 61: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14837; @(posedge clk); #1;
    if(data_out !== -16'sd6197) begin $display("Mismatch post-reset sample 62: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd25582; @(posedge clk); #1;
    if(data_out !== 16'sd11242) begin $display("Mismatch post-reset sample 63: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9611; @(posedge clk); #1;
    if(data_out !== -16'sd1995) begin $display("Mismatch post-reset sample 64: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd22192; @(posedge clk); #1;
    if(data_out !== -16'sd11595) begin $display("Mismatch post-reset sample 65: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27759; @(posedge clk); #1;
    if(data_out !== 16'sd10981) begin $display("Mismatch post-reset sample 66: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd20734; @(posedge clk); #1;
    if(data_out !== -16'sd7622) begin $display("Mismatch post-reset sample 67: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23943; @(posedge clk); #1;
    if(data_out !== -16'sd13877) begin $display("Mismatch post-reset sample 68: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27012; @(posedge clk); #1;
    if(data_out !== 16'sd10037) begin $display("Mismatch post-reset sample 69: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd6381; @(posedge clk); #1;
    if(data_out !== -16'sd681) begin $display("Mismatch post-reset sample 70: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd16726; @(posedge clk); #1;
    if(data_out !== 16'sd8193) begin $display("Mismatch post-reset sample 71: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd30531; @(posedge clk); #1;
    if(data_out !== -16'sd13217) begin $display("Mismatch post-reset sample 72: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd13048; @(posedge clk); #1;
    if(data_out !== 16'sd3220) begin $display("Mismatch post-reset sample 73: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd23031; @(posedge clk); #1;
    if(data_out !== 16'sd12321) begin $display("Mismatch post-reset sample 74: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd4374; @(posedge clk); #1;
    if(data_out !== 16'sd893) begin $display("Mismatch post-reset sample 75: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd20801; @(posedge clk); #1;
    if(data_out !== 16'sd10624) begin $display("Mismatch post-reset sample 76: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1620; @(posedge clk); #1;
    if(data_out !== 16'sd1846) begin $display("Mismatch post-reset sample 77: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd10523; @(posedge clk); #1;
    if(data_out !== 16'sd5723) begin $display("Mismatch post-reset sample 78: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13378; @(posedge clk); #1;
    if(data_out !== -16'sd5258) begin $display("Mismatch post-reset sample 79: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd5; @(posedge clk); #1;
    if(data_out !== -16'sd1312) begin $display("Mismatch post-reset sample 80: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3680; @(posedge clk); #1;
    if(data_out !== -16'sd2168) begin $display("Mismatch post-reset sample 81: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1921; @(posedge clk); #1;
    if(data_out !== -16'sd1503) begin $display("Mismatch post-reset sample 82: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd11218; @(posedge clk); #1;
    if(data_out !== 16'sd5233) begin $display("Mismatch post-reset sample 83: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9975; @(posedge clk); #1;
    if(data_out !== -16'sd3679) begin $display("Mismatch post-reset sample 84: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28972; @(posedge clk); #1;
    if(data_out !== -16'sd15406) begin $display("Mismatch post-reset sample 85: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21469; @(posedge clk); #1;
    if(data_out !== -16'sd14586) begin $display("Mismatch post-reset sample 86: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23770; @(posedge clk); #1;
    if(data_out !== -16'sd15532) begin $display("Mismatch post-reset sample 87: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd24653; @(posedge clk); #1;
    if(data_out !== 16'sd8444) begin $display("Mismatch post-reset sample 88: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd31416; @(posedge clk); #1;
    if(data_out !== -16'sd13597) begin $display("Mismatch post-reset sample 89: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26631; @(posedge clk); #1;
    if(data_out !== 16'sd9916) begin $display("Mismatch post-reset sample 90: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd1466; @(posedge clk); #1;
    if(data_out !== 16'sd3212) begin $display("Mismatch post-reset sample 91: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd22993; @(posedge clk); #1;
    if(data_out !== 16'sd12300) begin $display("Mismatch post-reset sample 92: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14084; @(posedge clk); #1;
    if(data_out !== -16'sd3967) begin $display("Mismatch post-reset sample 93: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd28629; @(posedge clk); #1;
    if(data_out !== -16'sd15306) begin $display("Mismatch post-reset sample 94: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd26510; @(posedge clk); #1;
    if(data_out !== 16'sd9429) begin $display("Mismatch post-reset sample 95: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd13931; @(posedge clk); #1;
    if(data_out !== -16'sd4608) begin $display("Mismatch post-reset sample 96: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd29200; @(posedge clk); #1;
    if(data_out !== -16'sd15752) begin $display("Mismatch post-reset sample 97: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14193; @(posedge clk); #1;
    if(data_out !== -16'sd11035) begin $display("Mismatch post-reset sample 98: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd7330; @(posedge clk); #1;
    if(data_out !== 16'sd906) begin $display("Mismatch post-reset sample 99: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3175; @(posedge clk); #1;
    if(data_out !== -16'sd1361) begin $display("Mismatch post-reset sample 100: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd18468; @(posedge clk); #1;
    if(data_out !== 16'sd8894) begin $display("Mismatch post-reset sample 101: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd2765; @(posedge clk); #1;
    if(data_out !== 16'sd841) begin $display("Mismatch post-reset sample 102: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd18186; @(posedge clk); #1;
    if(data_out !== -16'sd8883) begin $display("Mismatch post-reset sample 103: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd23517; @(posedge clk); #1;
    if(data_out !== 16'sd9538) begin $display("Mismatch post-reset sample 104: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21608; @(posedge clk); #1;
    if(data_out !== -16'sd8420) begin $display("Mismatch post-reset sample 105: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14871; @(posedge clk); #1;
    if(data_out !== 16'sd5331) begin $display("Mismatch post-reset sample 106: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd4234; @(posedge clk); #1;
    if(data_out !== 16'sd3450) begin $display("Mismatch post-reset sample 107: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd14751; @(posedge clk); #1;
    if(data_out !== -16'sd6513) begin $display("Mismatch post-reset sample 108: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd21428; @(posedge clk); #1;
    if(data_out !== -16'sd12342) begin $display("Mismatch post-reset sample 109: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd1221; @(posedge clk); #1;
    if(data_out !== -16'sd3696) begin $display("Mismatch post-reset sample 110: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14174; @(posedge clk); #1;
    if(data_out !== 16'sd6163) begin $display("Mismatch post-reset sample 111: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd14117; @(posedge clk); #1;
    if(data_out !== 16'sd8599) begin $display("Mismatch post-reset sample 112: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd32320; @(posedge clk); #1;
    if(data_out !== 16'sd18310) begin $display("Mismatch post-reset sample 113: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd9057; @(posedge clk); #1;
    if(data_out !== 16'sd49) begin $display("Mismatch post-reset sample 114: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32398; @(posedge clk); #1;
    if(data_out !== -16'sd16187) begin $display("Mismatch post-reset sample 115: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd3543; @(posedge clk); #1;
    if(data_out !== -16'sd5818) begin $display("Mismatch post-reset sample 116: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd27276; @(posedge clk); #1;
    if(data_out !== -16'sd15093) begin $display("Mismatch post-reset sample 117: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd15805; @(posedge clk); #1;
    if(data_out !== -16'sd11676) begin $display("Mismatch post-reset sample 118: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd32058; @(posedge clk); #1;
    if(data_out !== -16'sd18948) begin $display("Mismatch post-reset sample 119: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd31597; @(posedge clk); #1;
    if(data_out !== 16'sd11062) begin $display("Mismatch post-reset sample 120: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23064; @(posedge clk); #1;
    if(data_out !== -16'sd8767) begin $display("Mismatch post-reset sample 121: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd12249; @(posedge clk); #1;
    if(data_out !== -16'sd8316) begin $display("Mismatch post-reset sample 122: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd3930; @(posedge clk); #1;
    if(data_out !== -16'sd114) begin $display("Mismatch post-reset sample 123: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd26895; @(posedge clk); #1;
    if(data_out !== -16'sd13476) begin $display("Mismatch post-reset sample 124: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-16'sd23652; @(posedge clk); #1;
    if(data_out !== -16'sd15195) begin $display("Mismatch post-reset sample 125: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd27211; @(posedge clk); #1;
    if(data_out !== 16'sd9807) begin $display("Mismatch post-reset sample 126: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd15150; @(posedge clk); #1;
    if(data_out !== 16'sd10027) begin $display("Mismatch post-reset sample 127: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd2507) begin $display("Mismatch post-reset sample 128: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd627) begin $display("Mismatch post-reset sample 129: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd157) begin $display("Mismatch post-reset sample 130: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd39) begin $display("Mismatch post-reset sample 131: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd10) begin $display("Mismatch post-reset sample 132: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd3) begin $display("Mismatch post-reset sample 133: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd1) begin $display("Mismatch post-reset sample 134: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=16'sd0; @(posedge clk); #1;
    if(data_out !== 16'sd0) begin $display("Mismatch post-reset sample 135: %d",data_out); errors=errors+1; end
    @(negedge clk);
    $display("TIMING: FO1/SO2, capture counts as cycle 1; total 1 cycles; edge offset 0; model delay 0");
    $display("Golden vector saturation count per run: 0");
    if(errors==0) $display("PASS: four-port SOS, continuous samples, reset, latency");
    else $fatal(1,"FAIL: %d mismatches",errors);
    $finish;
  end
endmodule
