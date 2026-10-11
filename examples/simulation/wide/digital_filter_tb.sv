`timescale 1ns/1ps
// Golden vectors exercise 26 saturated outputs per 64-sample run.
// Zero means this filter/vector pair does not test output clipping.
module digital_filter_tb;
  reg clk=0; always #5 clk=~clk;
  reg rst=1, in_valid=0;
  reg signed [23:0] x_in=0;
  wire out_valid; wire signed [23:0] y_out;
  integer errors=0;
  digital_filter dut(.clk(clk),.rst(rst),.in_valid(in_valid),.x_in(x_in),.out_valid(out_valid),.y_out(y_out));
  initial begin
    @(posedge clk); #1; if (out_valid !== 0 || y_out !== 0) errors=errors+1;
    @(negedge clk); rst=0;
    in_valid=1; x_in=24'sd8388607; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch sample 0: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd8388608; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd8388608) begin $display("Mismatch sample 1: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd0; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd3355443) begin $display("Mismatch sample 2: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 24'sd3355443) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=24'sd1; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd419429) begin $display("Mismatch sample 3: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd1; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd440404) begin $display("Mismatch sample 4: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd4645820; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd8198342) begin $display("Mismatch sample 5: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd4425005; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd7426394) begin $display("Mismatch sample 6: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd7585258; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd8388608) begin $display("Mismatch sample 7: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd594557; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd2372340) begin $display("Mismatch sample 8: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd7844280; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch sample 9: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 24'sd8388607) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=24'sd4868535; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd6606353) begin $display("Mismatch sample 10: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd7510954; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch sample 11: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd2058495; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd4704193) begin $display("Mismatch sample 12: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd1705068; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd3875946) begin $display("Mismatch sample 13: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd1062107; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd1930935) begin $display("Mismatch sample 14: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd4987778; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd8388608) begin $display("Mismatch sample 15: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd1457723; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd2081845) begin $display("Mismatch sample 16: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -24'sd2081845) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-24'sd4241312; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd7621979) begin $display("Mismatch sample 17: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd6021183; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch sample 18: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd6721390; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd8388608) begin $display("Mismatch sample 19: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd5625545; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch sample 20: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd3692; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd1563568) begin $display("Mismatch sample 21: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd2306019; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd4214013) begin $display("Mismatch sample 22: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd7853030; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch sample 23: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 24'sd8388607) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=24'sd6838797; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch sample 24: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd1985528; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd3672524) begin $display("Mismatch sample 25: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd6834119; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch sample 26: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd4005254; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd8388608) begin $display("Mismatch sample 27: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd8064913; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch sample 28: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd754620; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd777172) begin $display("Mismatch sample 29: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd2257941; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd3345632) begin $display("Mismatch sample 30: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -24'sd3345632) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=24'sd6402126; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch sample 31: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd4324181; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd6233483) begin $display("Mismatch sample 32: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd3773616; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd6761779) begin $display("Mismatch sample 33: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd3563441; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd5974688) begin $display("Mismatch sample 34: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd4362594; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8189814) begin $display("Mismatch sample 35: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd5202265; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch sample 36: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd959772; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd1911915) begin $display("Mismatch sample 37: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -24'sd1911915) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=24'sd2844915; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd5442214) begin $display("Mismatch sample 38: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd3086774; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd5291199) begin $display("Mismatch sample 39: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd2636387; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd4667257) begin $display("Mismatch sample 40: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd7703128; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch sample 41: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd1968599; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd1498265) begin $display("Mismatch sample 42: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd2089654; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd3179706) begin $display("Mismatch sample 43: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd4854751; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd7903591) begin $display("Mismatch sample 44: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -24'sd7903591) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-24'sd387316; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd430768) begin $display("Mismatch sample 45: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd8185595; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch sample 46: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd5353502; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd7319231) begin $display("Mismatch sample 47: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd5318427; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd8388608) begin $display("Mismatch sample 48: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd1586432; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd3944770) begin $display("Mismatch sample 49: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd3693473; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd6761347) begin $display("Mismatch sample 50: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd5711410; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch sample 51: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 24'sd8388607) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-24'sd667671; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd2174211) begin $display("Mismatch sample 52: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd8234956; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd8388608) begin $display("Mismatch sample 53: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd4597251; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch sample 54: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd7279494; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch sample 55: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd1026771; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd3028992) begin $display("Mismatch sample 56: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd510808; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd156764) begin $display("Mismatch sample 57: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd7114727; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch sample 58: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 24'sd8388607) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-24'sd2667494; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd6240352) begin $display("Mismatch sample 59: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd3812529; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd7385406) begin $display("Mismatch sample 60: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd8044124; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch sample 61: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd8341003; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch sample 62: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd2038802; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd4469083) begin $display("Mismatch sample 63: %d",y_out); errors=errors+1; end
    @(negedge clk);
    rst=1; in_valid=1; @(posedge clk); #1;
    if(out_valid !== 0 || y_out !== 0) errors=errors+1;
    @(negedge clk); rst=0; in_valid=0; x_in=0; @(posedge clk); #1;
    if(out_valid !== 0 || y_out !== 0) errors=errors+1;
    @(negedge clk);
    in_valid=1; x_in=24'sd8388607; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 0: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd8388608; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 1: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd0; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd3355443) begin $display("Mismatch post-reset sample 2: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 24'sd3355443) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=24'sd1; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd419429) begin $display("Mismatch post-reset sample 3: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd1; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd440404) begin $display("Mismatch post-reset sample 4: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd4645820; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd8198342) begin $display("Mismatch post-reset sample 5: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd4425005; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd7426394) begin $display("Mismatch post-reset sample 6: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd7585258; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 7: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd594557; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd2372340) begin $display("Mismatch post-reset sample 8: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd7844280; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 9: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 24'sd8388607) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=24'sd4868535; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd6606353) begin $display("Mismatch post-reset sample 10: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd7510954; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 11: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd2058495; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd4704193) begin $display("Mismatch post-reset sample 12: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd1705068; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd3875946) begin $display("Mismatch post-reset sample 13: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd1062107; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd1930935) begin $display("Mismatch post-reset sample 14: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd4987778; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 15: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd1457723; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd2081845) begin $display("Mismatch post-reset sample 16: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -24'sd2081845) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-24'sd4241312; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd7621979) begin $display("Mismatch post-reset sample 17: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd6021183; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 18: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd6721390; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 19: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd5625545; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 20: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd3692; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd1563568) begin $display("Mismatch post-reset sample 21: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd2306019; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd4214013) begin $display("Mismatch post-reset sample 22: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd7853030; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 23: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 24'sd8388607) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=24'sd6838797; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 24: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd1985528; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd3672524) begin $display("Mismatch post-reset sample 25: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd6834119; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 26: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd4005254; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 27: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd8064913; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 28: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd754620; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd777172) begin $display("Mismatch post-reset sample 29: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd2257941; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd3345632) begin $display("Mismatch post-reset sample 30: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -24'sd3345632) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=24'sd6402126; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 31: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd4324181; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd6233483) begin $display("Mismatch post-reset sample 32: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd3773616; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd6761779) begin $display("Mismatch post-reset sample 33: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd3563441; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd5974688) begin $display("Mismatch post-reset sample 34: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd4362594; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8189814) begin $display("Mismatch post-reset sample 35: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd5202265; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 36: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd959772; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd1911915) begin $display("Mismatch post-reset sample 37: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -24'sd1911915) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=24'sd2844915; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd5442214) begin $display("Mismatch post-reset sample 38: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd3086774; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd5291199) begin $display("Mismatch post-reset sample 39: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd2636387; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd4667257) begin $display("Mismatch post-reset sample 40: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd7703128; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 41: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd1968599; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd1498265) begin $display("Mismatch post-reset sample 42: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd2089654; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd3179706) begin $display("Mismatch post-reset sample 43: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd4854751; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd7903591) begin $display("Mismatch post-reset sample 44: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -24'sd7903591) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-24'sd387316; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd430768) begin $display("Mismatch post-reset sample 45: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd8185595; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 46: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd5353502; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd7319231) begin $display("Mismatch post-reset sample 47: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd5318427; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 48: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd1586432; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd3944770) begin $display("Mismatch post-reset sample 49: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd3693473; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd6761347) begin $display("Mismatch post-reset sample 50: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd5711410; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 51: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 24'sd8388607) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-24'sd667671; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd2174211) begin $display("Mismatch post-reset sample 52: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd8234956; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 53: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd4597251; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 54: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd7279494; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 55: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd1026771; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd3028992) begin $display("Mismatch post-reset sample 56: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd510808; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd156764) begin $display("Mismatch post-reset sample 57: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd7114727; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 58: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 24'sd8388607) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-24'sd2667494; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd6240352) begin $display("Mismatch post-reset sample 59: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd3812529; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd7385406) begin $display("Mismatch post-reset sample 60: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd8044124; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 61: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=24'sd8341003; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 62: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-24'sd2038802; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -24'sd4469083) begin $display("Mismatch post-reset sample 63: %d",y_out); errors=errors+1; end
    @(negedge clk);
    $display("Golden vector saturation count per run: 26");
    if(errors==0) $display("PASS: fixed-point vectors, valid gaps, reset");
    else $fatal(1,"FAIL: %d mismatches",errors);
    $finish;
  end
endmodule
