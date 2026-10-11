`timescale 1ns/1ps
// Golden vectors exercise 0 saturated outputs per 64-sample run.
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
    if(out_valid !== 1 || y_out !== 16'sd6554) begin $display("Mismatch sample 0: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd32768; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd1311) begin $display("Mismatch sample 1: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd0; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd1049) begin $display("Mismatch sample 2: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -16'sd1049) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=16'sd1; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd839) begin $display("Mismatch sample 3: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd1; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd671) begin $display("Mismatch sample 4: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd25532; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd5644) begin $display("Mismatch sample 5: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd1325; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd4780) begin $display("Mismatch sample 6: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd15850; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd6994) begin $display("Mismatch sample 7: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd28035; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd11202) begin $display("Mismatch sample 8: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd12728; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd6416) begin $display("Mismatch sample 9: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -16'sd6416) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd13897; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd7912) begin $display("Mismatch sample 10: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd7082; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd4913) begin $display("Mismatch sample 11: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd5889; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd2752) begin $display("Mismatch sample 12: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd31636; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd8529) begin $display("Mismatch sample 13: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd19237; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd10671) begin $display("Mismatch sample 14: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd25726; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd3391) begin $display("Mismatch sample 15: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd16837; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd655) begin $display("Mismatch sample 16: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd655) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd14240; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd2324) begin $display("Mismatch sample 17: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd24639; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd3069) begin $display("Mismatch sample 18: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd3950; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd1665) begin $display("Mismatch sample 19: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd22217; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd5776) begin $display("Mismatch sample 20: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd29076; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd10436) begin $display("Mismatch sample 21: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd20509; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd4247) begin $display("Mismatch sample 22: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd21478; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd7693) begin $display("Mismatch sample 23: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd7693) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd9715; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd4211) begin $display("Mismatch sample 24: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd13320; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd6033) begin $display("Mismatch sample 25: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd14393; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd1948) begin $display("Mismatch sample 26: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd25210; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd6601) begin $display("Mismatch sample 27: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd28783; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd476) begin $display("Mismatch sample 28: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd956; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd190) begin $display("Mismatch sample 29: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd3051; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd458) begin $display("Mismatch sample 30: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd458) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=16'sd12366; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd2840) begin $display("Mismatch sample 31: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd31573; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd8587) begin $display("Mismatch sample 32: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd5296; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd7929) begin $display("Mismatch sample 33: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd8271; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd7997) begin $display("Mismatch sample 34: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd4450; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd7288) begin $display("Mismatch sample 35: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd7847; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd4261) begin $display("Mismatch sample 36: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd9500; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd1509) begin $display("Mismatch sample 37: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd1509) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd5901; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd27) begin $display("Mismatch sample 38: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd26186; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd5216) begin $display("Mismatch sample 39: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd17821; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd608) begin $display("Mismatch sample 40: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd2648; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd43) begin $display("Mismatch sample 41: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd30249; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd6016) begin $display("Mismatch sample 42: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd25270; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd9867) begin $display("Mismatch sample 43: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd27681; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd2357) begin $display("Mismatch sample 44: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -16'sd2357) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd26868; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd7259) begin $display("Mismatch sample 45: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd26363; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd534) begin $display("Mismatch sample 46: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd12318; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd2037) begin $display("Mismatch sample 47: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd22757; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd6181) begin $display("Mismatch sample 48: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd19200; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd1104) begin $display("Mismatch sample 49: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd9311; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd2746) begin $display("Mismatch sample 50: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd22990; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd2402) begin $display("Mismatch sample 51: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -16'sd2402) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=16'sd20457; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd2170) begin $display("Mismatch sample 52: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd10188; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd302) begin $display("Mismatch sample 53: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd23037; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd4849) begin $display("Mismatch sample 54: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd27770; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd9433) begin $display("Mismatch sample 55: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd10963; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd9739) begin $display("Mismatch sample 56: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd19288; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd11649) begin $display("Mismatch sample 57: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd4071; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd8505) begin $display("Mismatch sample 58: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -16'sd8505) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd13286; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd9461) begin $display("Mismatch sample 59: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd21327; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd11834) begin $display("Mismatch sample 60: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd15964; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd6274) begin $display("Mismatch sample 61: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd14837; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd7987) begin $display("Mismatch sample 62: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd25582; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd1273) begin $display("Mismatch sample 63: %d",y_out); errors=errors+1; end
    @(negedge clk);
    rst=1; in_valid=1; @(posedge clk); #1;
    if(out_valid !== 0 || y_out !== 0) errors=errors+1;
    @(negedge clk); rst=0; in_valid=0; x_in=0; @(posedge clk); #1;
    if(out_valid !== 0 || y_out !== 0) errors=errors+1;
    @(negedge clk);
    in_valid=1; x_in=16'sd32767; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd6554) begin $display("Mismatch post-reset sample 0: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd32768; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd1311) begin $display("Mismatch post-reset sample 1: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd0; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd1049) begin $display("Mismatch post-reset sample 2: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -16'sd1049) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=16'sd1; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd839) begin $display("Mismatch post-reset sample 3: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd1; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd671) begin $display("Mismatch post-reset sample 4: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd25532; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd5644) begin $display("Mismatch post-reset sample 5: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd1325; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd4780) begin $display("Mismatch post-reset sample 6: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd15850; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd6994) begin $display("Mismatch post-reset sample 7: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd28035; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd11202) begin $display("Mismatch post-reset sample 8: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd12728; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd6416) begin $display("Mismatch post-reset sample 9: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -16'sd6416) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd13897; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd7912) begin $display("Mismatch post-reset sample 10: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd7082; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd4913) begin $display("Mismatch post-reset sample 11: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd5889; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd2752) begin $display("Mismatch post-reset sample 12: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd31636; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd8529) begin $display("Mismatch post-reset sample 13: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd19237; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd10671) begin $display("Mismatch post-reset sample 14: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd25726; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd3391) begin $display("Mismatch post-reset sample 15: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd16837; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd655) begin $display("Mismatch post-reset sample 16: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd655) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd14240; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd2324) begin $display("Mismatch post-reset sample 17: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd24639; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd3069) begin $display("Mismatch post-reset sample 18: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd3950; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd1665) begin $display("Mismatch post-reset sample 19: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd22217; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd5776) begin $display("Mismatch post-reset sample 20: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd29076; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd10436) begin $display("Mismatch post-reset sample 21: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd20509; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd4247) begin $display("Mismatch post-reset sample 22: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd21478; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd7693) begin $display("Mismatch post-reset sample 23: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd7693) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd9715; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd4211) begin $display("Mismatch post-reset sample 24: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd13320; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd6033) begin $display("Mismatch post-reset sample 25: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd14393; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd1948) begin $display("Mismatch post-reset sample 26: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd25210; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd6601) begin $display("Mismatch post-reset sample 27: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd28783; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd476) begin $display("Mismatch post-reset sample 28: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd956; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd190) begin $display("Mismatch post-reset sample 29: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd3051; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd458) begin $display("Mismatch post-reset sample 30: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd458) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=16'sd12366; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd2840) begin $display("Mismatch post-reset sample 31: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd31573; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd8587) begin $display("Mismatch post-reset sample 32: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd5296; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd7929) begin $display("Mismatch post-reset sample 33: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd8271; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd7997) begin $display("Mismatch post-reset sample 34: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd4450; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd7288) begin $display("Mismatch post-reset sample 35: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd7847; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd4261) begin $display("Mismatch post-reset sample 36: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd9500; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd1509) begin $display("Mismatch post-reset sample 37: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 16'sd1509) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd5901; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd27) begin $display("Mismatch post-reset sample 38: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd26186; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd5216) begin $display("Mismatch post-reset sample 39: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd17821; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd608) begin $display("Mismatch post-reset sample 40: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd2648; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd43) begin $display("Mismatch post-reset sample 41: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd30249; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd6016) begin $display("Mismatch post-reset sample 42: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd25270; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd9867) begin $display("Mismatch post-reset sample 43: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd27681; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd2357) begin $display("Mismatch post-reset sample 44: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -16'sd2357) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd26868; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd7259) begin $display("Mismatch post-reset sample 45: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd26363; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd534) begin $display("Mismatch post-reset sample 46: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd12318; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd2037) begin $display("Mismatch post-reset sample 47: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd22757; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd6181) begin $display("Mismatch post-reset sample 48: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd19200; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd1104) begin $display("Mismatch post-reset sample 49: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd9311; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd2746) begin $display("Mismatch post-reset sample 50: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd22990; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd2402) begin $display("Mismatch post-reset sample 51: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -16'sd2402) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=16'sd20457; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 16'sd2170) begin $display("Mismatch post-reset sample 52: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd10188; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd302) begin $display("Mismatch post-reset sample 53: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd23037; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd4849) begin $display("Mismatch post-reset sample 54: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd27770; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd9433) begin $display("Mismatch post-reset sample 55: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd10963; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd9739) begin $display("Mismatch post-reset sample 56: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd19288; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd11649) begin $display("Mismatch post-reset sample 57: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd4071; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd8505) begin $display("Mismatch post-reset sample 58: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -16'sd8505) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-16'sd13286; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd9461) begin $display("Mismatch post-reset sample 59: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd21327; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd11834) begin $display("Mismatch post-reset sample 60: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd15964; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd6274) begin $display("Mismatch post-reset sample 61: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-16'sd14837; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd7987) begin $display("Mismatch post-reset sample 62: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=16'sd25582; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -16'sd1273) begin $display("Mismatch post-reset sample 63: %d",y_out); errors=errors+1; end
    @(negedge clk);
    $display("Golden vector saturation count per run: 0");
    if(errors==0) $display("PASS: fixed-point vectors, valid gaps, reset");
    else $fatal(1,"FAIL: %d mismatches",errors);
    $finish;
  end
endmodule
