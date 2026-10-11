`timescale 1ns/1ps
// Golden vectors exercise 5 saturated outputs per 64-sample run.
// Zero means this filter/vector pair does not test output clipping.
module digital_filter_tb;
  reg clk=0; always #5 clk=~clk;
  reg rst=1, in_valid=0;
  reg signed [15:0] x_in=0;
  wire out_valid; wire signed [15:0] y_out;
  integer errors=0;
  digital_filter dut(.clk(clk),.rst(rst),.in_valid(in_valid),.x_in(x_in),.out_valid(out_valid),.y_out(y_out));
  initial begin
    @(posedge clk); #1; if (out_valid !== 0 || y_out !== 0) errors=errors+1;
    @(negedge clk); rst=0;
    in_valid=1; x_in=16'sd32767; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd31268) begin $display("Mismatch sample 0: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd32768; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd32768) begin $display("Mismatch sample 1: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd0; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd14383) begin $display("Mismatch sample 2: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd14383) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=16'sd1; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd7966) begin $display("Mismatch sample 3: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd1; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd3480) begin $display("Mismatch sample 4: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd25532; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd23551) begin $display("Mismatch sample 5: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd1325; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd3113) begin $display("Mismatch sample 6: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd15850; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd17699) begin $display("Mismatch sample 7: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd28035; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd29067) begin $display("Mismatch sample 8: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd12728; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd11004) begin $display("Mismatch sample 9: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd11004) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd13897; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd24577) begin $display("Mismatch sample 10: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd7082; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd170) begin $display("Mismatch sample 11: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd5889; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd3068) begin $display("Mismatch sample 12: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd31636; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd32768) begin $display("Mismatch sample 13: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd19237; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd9960) begin $display("Mismatch sample 14: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd25726; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd29801) begin $display("Mismatch sample 15: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd16837; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd8083) begin $display("Mismatch sample 16: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd8083) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd14240; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd20807) begin $display("Mismatch sample 17: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd24639; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd26042) begin $display("Mismatch sample 18: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd3950; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd6700) begin $display("Mismatch sample 19: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd22217; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd24834) begin $display("Mismatch sample 20: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd29076; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd27907) begin $display("Mismatch sample 21: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd20509; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd19730) begin $display("Mismatch sample 22: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd21478; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd32767) begin $display("Mismatch sample 23: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd32767) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd9715; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd4790) begin $display("Mismatch sample 24: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd13320; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd21265) begin $display("Mismatch sample 25: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd14393; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd10848) begin $display("Mismatch sample 26: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd25210; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd30689) begin $display("Mismatch sample 27: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd28783; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd29899) begin $display("Mismatch sample 28: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd956; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd8323) begin $display("Mismatch sample 29: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd3051; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd3929) begin $display("Mismatch sample 30: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd3929) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=16'sd12366; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd9598) begin $display("Mismatch sample 31: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd31573; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd25620) begin $display("Mismatch sample 32: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd5296; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd1705) begin $display("Mismatch sample 33: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd8271; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd10242) begin $display("Mismatch sample 34: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd4450; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd9947) begin $display("Mismatch sample 35: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd7847; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd17) begin $display("Mismatch sample 36: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd9500; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd378) begin $display("Mismatch sample 37: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd378) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd5901; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd1966) begin $display("Mismatch sample 38: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd26186; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd21613) begin $display("Mismatch sample 39: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd17821; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd21056) begin $display("Mismatch sample 40: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd2648; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd5374) begin $display("Mismatch sample 41: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd30249; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd32768) begin $display("Mismatch sample 42: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd25270; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd18884) begin $display("Mismatch sample 43: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd27681; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd29997) begin $display("Mismatch sample 44: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd29997) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd26868; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd32768) begin $display("Mismatch sample 45: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd26363; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd28603) begin $display("Mismatch sample 46: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd12318; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd5730) begin $display("Mismatch sample 47: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd22757; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd18667) begin $display("Mismatch sample 48: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd19200; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd20046) begin $display("Mismatch sample 49: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd9311; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd18663) begin $display("Mismatch sample 50: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd22990; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd17071) begin $display("Mismatch sample 51: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -16'sd17071) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=16'sd20457; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd28440) begin $display("Mismatch sample 52: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd10188; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd11946) begin $display("Mismatch sample 53: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd23037; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd20278) begin $display("Mismatch sample 54: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd27770; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd22204) begin $display("Mismatch sample 55: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd10963; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd7707) begin $display("Mismatch sample 56: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd19288; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd23237) begin $display("Mismatch sample 57: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd4071; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd2717) begin $display("Mismatch sample 58: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -16'sd2717) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd13286; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd25180) begin $display("Mismatch sample 59: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd21327; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd28795) begin $display("Mismatch sample 60: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd15964; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd10428) begin $display("Mismatch sample 61: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd14837; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd25866) begin $display("Mismatch sample 62: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd25582; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd20061) begin $display("Mismatch sample 63: %d",y_out); errors=errors+1; end
    @(negedge clk);
    rst=1; in_valid=1; @(posedge clk); #1;
    if(out_valid !== 0 || y_out !== 0) errors=errors+1;
    @(negedge clk); rst=0; in_valid=0; x_in=0; @(posedge clk); #1;
    if(out_valid !== 0 || y_out !== 0) errors=errors+1;
    @(negedge clk);
    in_valid=1; x_in=16'sd32767; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd31268) begin $display("Mismatch post-reset sample 0: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd32768; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd32768) begin $display("Mismatch post-reset sample 1: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd0; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd14383) begin $display("Mismatch post-reset sample 2: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd14383) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=16'sd1; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd7966) begin $display("Mismatch post-reset sample 3: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd1; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd3480) begin $display("Mismatch post-reset sample 4: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd25532; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd23551) begin $display("Mismatch post-reset sample 5: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd1325; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd3113) begin $display("Mismatch post-reset sample 6: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd15850; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd17699) begin $display("Mismatch post-reset sample 7: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd28035; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd29067) begin $display("Mismatch post-reset sample 8: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd12728; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd11004) begin $display("Mismatch post-reset sample 9: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd11004) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd13897; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd24577) begin $display("Mismatch post-reset sample 10: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd7082; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd170) begin $display("Mismatch post-reset sample 11: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd5889; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd3068) begin $display("Mismatch post-reset sample 12: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd31636; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd32768) begin $display("Mismatch post-reset sample 13: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd19237; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd9960) begin $display("Mismatch post-reset sample 14: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd25726; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd29801) begin $display("Mismatch post-reset sample 15: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd16837; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd8083) begin $display("Mismatch post-reset sample 16: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd8083) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd14240; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd20807) begin $display("Mismatch post-reset sample 17: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd24639; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd26042) begin $display("Mismatch post-reset sample 18: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd3950; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd6700) begin $display("Mismatch post-reset sample 19: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd22217; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd24834) begin $display("Mismatch post-reset sample 20: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd29076; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd27907) begin $display("Mismatch post-reset sample 21: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd20509; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd19730) begin $display("Mismatch post-reset sample 22: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd21478; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd32767) begin $display("Mismatch post-reset sample 23: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd32767) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd9715; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd4790) begin $display("Mismatch post-reset sample 24: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd13320; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd21265) begin $display("Mismatch post-reset sample 25: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd14393; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd10848) begin $display("Mismatch post-reset sample 26: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd25210; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd30689) begin $display("Mismatch post-reset sample 27: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd28783; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd29899) begin $display("Mismatch post-reset sample 28: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd956; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd8323) begin $display("Mismatch post-reset sample 29: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd3051; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd3929) begin $display("Mismatch post-reset sample 30: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd3929) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=16'sd12366; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd9598) begin $display("Mismatch post-reset sample 31: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd31573; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd25620) begin $display("Mismatch post-reset sample 32: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd5296; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd1705) begin $display("Mismatch post-reset sample 33: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd8271; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd10242) begin $display("Mismatch post-reset sample 34: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd4450; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd9947) begin $display("Mismatch post-reset sample 35: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd7847; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd17) begin $display("Mismatch post-reset sample 36: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd9500; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd378) begin $display("Mismatch post-reset sample 37: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd378) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd5901; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd1966) begin $display("Mismatch post-reset sample 38: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd26186; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd21613) begin $display("Mismatch post-reset sample 39: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd17821; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd21056) begin $display("Mismatch post-reset sample 40: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd2648; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd5374) begin $display("Mismatch post-reset sample 41: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd30249; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd32768) begin $display("Mismatch post-reset sample 42: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd25270; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd18884) begin $display("Mismatch post-reset sample 43: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd27681; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd29997) begin $display("Mismatch post-reset sample 44: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd29997) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd26868; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd32768) begin $display("Mismatch post-reset sample 45: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd26363; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd28603) begin $display("Mismatch post-reset sample 46: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd12318; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd5730) begin $display("Mismatch post-reset sample 47: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd22757; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd18667) begin $display("Mismatch post-reset sample 48: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd19200; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd20046) begin $display("Mismatch post-reset sample 49: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd9311; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd18663) begin $display("Mismatch post-reset sample 50: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd22990; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd17071) begin $display("Mismatch post-reset sample 51: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -16'sd17071) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=16'sd20457; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd28440) begin $display("Mismatch post-reset sample 52: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd10188; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd11946) begin $display("Mismatch post-reset sample 53: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd23037; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd20278) begin $display("Mismatch post-reset sample 54: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd27770; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd22204) begin $display("Mismatch post-reset sample 55: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd10963; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd7707) begin $display("Mismatch post-reset sample 56: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd19288; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd23237) begin $display("Mismatch post-reset sample 57: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd4071; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd2717) begin $display("Mismatch post-reset sample 58: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -16'sd2717) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd13286; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd25180) begin $display("Mismatch post-reset sample 59: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd21327; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd28795) begin $display("Mismatch post-reset sample 60: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd15964; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd10428) begin $display("Mismatch post-reset sample 61: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd14837; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd25866) begin $display("Mismatch post-reset sample 62: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd25582; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd20061) begin $display("Mismatch post-reset sample 63: %d",y_out); errors=errors+1; end
    @(negedge clk);
    $display("Golden vector saturation count per run: 5");
    if(errors==0) $display("PASS: fixed-point vectors, valid gaps, reset");
    else $fatal(1,"FAIL: %d mismatches",errors);
    $finish;
  end
endmodule
