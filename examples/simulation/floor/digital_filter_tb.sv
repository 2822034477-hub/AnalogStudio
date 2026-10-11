`timescale 1ns/1ps
// Golden vectors exercise 0 saturated outputs per 64-sample run.
// Zero means this filter/vector pair does not test output clipping.
module digital_filter_tb;
  reg clk=0; always #5 clk=~clk;
  reg rst=1, in_valid=0;
  reg signed [7:0] x_in=0;
  wire out_valid; wire signed [7:0] y_out;
  integer errors=0;
  digital_filter dut(.clk(clk),.rst(rst),.in_valid(in_valid),.x_in(x_in),.out_valid(out_valid),.y_out(y_out));
  initial begin
    @(posedge clk); #1; if (out_valid !== 0 || y_out !== 0) errors=errors+1;
    @(negedge clk); rst=0;
    in_valid=1; x_in=8'sd127; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd63) begin $display("Mismatch sample 0: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd128; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd64) begin $display("Mismatch sample 1: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd0; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd0) begin $display("Mismatch sample 2: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 8'sd0) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=8'sd1; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd0) begin $display("Mismatch sample 3: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd1; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd1) begin $display("Mismatch sample 4: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd60; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd30) begin $display("Mismatch sample 5: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd83; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd41) begin $display("Mismatch sample 6: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd106; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd53) begin $display("Mismatch sample 7: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd3; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd2) begin $display("Mismatch sample 8: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd56; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd28) begin $display("Mismatch sample 9: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 8'sd28) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=8'sd55; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd27) begin $display("Mismatch sample 10: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd42; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd21) begin $display("Mismatch sample 11: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd127; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd64) begin $display("Mismatch sample 12: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd20; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd10) begin $display("Mismatch sample 13: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd91; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd45) begin $display("Mismatch sample 14: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd2; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd1) begin $display("Mismatch sample 15: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd69; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd34) begin $display("Mismatch sample 16: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 8'sd34) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-8'sd32; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd16) begin $display("Mismatch sample 17: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd65; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd33) begin $display("Mismatch sample 18: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd18; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd9) begin $display("Mismatch sample 19: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd73; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd36) begin $display("Mismatch sample 20: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd20; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd10) begin $display("Mismatch sample 21: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd99; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd49) begin $display("Mismatch sample 22: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd102; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd51) begin $display("Mismatch sample 23: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 8'sd51) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-8'sd115; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd58) begin $display("Mismatch sample 24: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd120; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd60) begin $display("Mismatch sample 25: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd71; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd35) begin $display("Mismatch sample 26: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd6; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd3) begin $display("Mismatch sample 27: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd17; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd8) begin $display("Mismatch sample 28: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd60; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd30) begin $display("Mismatch sample 29: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd107; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd53) begin $display("Mismatch sample 30: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 8'sd53) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-8'sd50; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd25) begin $display("Mismatch sample 31: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd43; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd22) begin $display("Mismatch sample 32: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd48; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd24) begin $display("Mismatch sample 33: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd49; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd25) begin $display("Mismatch sample 34: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd30; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd15) begin $display("Mismatch sample 35: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd39; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd20) begin $display("Mismatch sample 36: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd100; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd50) begin $display("Mismatch sample 37: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 8'sd50) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=8'sd115; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd57) begin $display("Mismatch sample 38: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd54; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd27) begin $display("Mismatch sample 39: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd29; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd14) begin $display("Mismatch sample 40: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd40; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd20) begin $display("Mismatch sample 41: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd87; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd43) begin $display("Mismatch sample 42: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd54; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd27) begin $display("Mismatch sample 43: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd95; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd48) begin $display("Mismatch sample 44: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -8'sd48) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-8'sd116; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd58) begin $display("Mismatch sample 45: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd123; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd61) begin $display("Mismatch sample 46: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd98; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd49) begin $display("Mismatch sample 47: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd101; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd50) begin $display("Mismatch sample 48: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd128; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd64) begin $display("Mismatch sample 49: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd33; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd17) begin $display("Mismatch sample 50: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd78; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd39) begin $display("Mismatch sample 51: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -8'sd39) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=8'sd105; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd52) begin $display("Mismatch sample 52: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd76; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd38) begin $display("Mismatch sample 53: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd125; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd63) begin $display("Mismatch sample 54: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd6; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd3) begin $display("Mismatch sample 55: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd83; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd42) begin $display("Mismatch sample 56: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd40; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd20) begin $display("Mismatch sample 57: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd103; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd51) begin $display("Mismatch sample 58: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 8'sd51) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-8'sd102; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd51) begin $display("Mismatch sample 59: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd49; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd24) begin $display("Mismatch sample 60: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd36; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd18) begin $display("Mismatch sample 61: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd117; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd59) begin $display("Mismatch sample 62: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd110; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd55) begin $display("Mismatch sample 63: %d",y_out); errors=errors+1; end
    @(negedge clk);
    rst=1; in_valid=1; @(posedge clk); #1;
    if(out_valid !== 0 || y_out !== 0) errors=errors+1;
    @(negedge clk); rst=0; in_valid=0; x_in=0; @(posedge clk); #1;
    if(out_valid !== 0 || y_out !== 0) errors=errors+1;
    @(negedge clk);
    in_valid=1; x_in=8'sd127; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd63) begin $display("Mismatch post-reset sample 0: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd128; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd64) begin $display("Mismatch post-reset sample 1: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd0; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd0) begin $display("Mismatch post-reset sample 2: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 8'sd0) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=8'sd1; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd0) begin $display("Mismatch post-reset sample 3: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd1; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd1) begin $display("Mismatch post-reset sample 4: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd60; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd30) begin $display("Mismatch post-reset sample 5: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd83; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd41) begin $display("Mismatch post-reset sample 6: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd106; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd53) begin $display("Mismatch post-reset sample 7: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd3; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd2) begin $display("Mismatch post-reset sample 8: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd56; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd28) begin $display("Mismatch post-reset sample 9: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 8'sd28) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=8'sd55; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd27) begin $display("Mismatch post-reset sample 10: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd42; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd21) begin $display("Mismatch post-reset sample 11: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd127; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd64) begin $display("Mismatch post-reset sample 12: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd20; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd10) begin $display("Mismatch post-reset sample 13: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd91; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd45) begin $display("Mismatch post-reset sample 14: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd2; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd1) begin $display("Mismatch post-reset sample 15: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd69; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd34) begin $display("Mismatch post-reset sample 16: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 8'sd34) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-8'sd32; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd16) begin $display("Mismatch post-reset sample 17: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd65; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd33) begin $display("Mismatch post-reset sample 18: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd18; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd9) begin $display("Mismatch post-reset sample 19: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd73; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd36) begin $display("Mismatch post-reset sample 20: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd20; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd10) begin $display("Mismatch post-reset sample 21: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd99; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd49) begin $display("Mismatch post-reset sample 22: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd102; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd51) begin $display("Mismatch post-reset sample 23: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 8'sd51) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-8'sd115; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd58) begin $display("Mismatch post-reset sample 24: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd120; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd60) begin $display("Mismatch post-reset sample 25: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd71; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd35) begin $display("Mismatch post-reset sample 26: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd6; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd3) begin $display("Mismatch post-reset sample 27: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd17; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd8) begin $display("Mismatch post-reset sample 28: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd60; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd30) begin $display("Mismatch post-reset sample 29: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd107; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd53) begin $display("Mismatch post-reset sample 30: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 8'sd53) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-8'sd50; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd25) begin $display("Mismatch post-reset sample 31: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd43; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd22) begin $display("Mismatch post-reset sample 32: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd48; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd24) begin $display("Mismatch post-reset sample 33: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd49; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd25) begin $display("Mismatch post-reset sample 34: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd30; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd15) begin $display("Mismatch post-reset sample 35: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd39; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd20) begin $display("Mismatch post-reset sample 36: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd100; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd50) begin $display("Mismatch post-reset sample 37: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 8'sd50) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=8'sd115; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd57) begin $display("Mismatch post-reset sample 38: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd54; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd27) begin $display("Mismatch post-reset sample 39: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd29; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd14) begin $display("Mismatch post-reset sample 40: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd40; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd20) begin $display("Mismatch post-reset sample 41: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd87; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd43) begin $display("Mismatch post-reset sample 42: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd54; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd27) begin $display("Mismatch post-reset sample 43: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd95; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd48) begin $display("Mismatch post-reset sample 44: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -8'sd48) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-8'sd116; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd58) begin $display("Mismatch post-reset sample 45: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd123; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd61) begin $display("Mismatch post-reset sample 46: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd98; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd49) begin $display("Mismatch post-reset sample 47: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd101; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd50) begin $display("Mismatch post-reset sample 48: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd128; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd64) begin $display("Mismatch post-reset sample 49: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd33; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd17) begin $display("Mismatch post-reset sample 50: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd78; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd39) begin $display("Mismatch post-reset sample 51: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== -8'sd39) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=8'sd105; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd52) begin $display("Mismatch post-reset sample 52: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd76; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd38) begin $display("Mismatch post-reset sample 53: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd125; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd63) begin $display("Mismatch post-reset sample 54: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd6; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd3) begin $display("Mismatch post-reset sample 55: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd83; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd42) begin $display("Mismatch post-reset sample 56: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd40; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd20) begin $display("Mismatch post-reset sample 57: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd103; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd51) begin $display("Mismatch post-reset sample 58: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=0; x_in=0; @(posedge clk); #1; if(out_valid !== 0 || y_out !== 8'sd51) errors=errors+1; @(negedge clk);
    in_valid=1; x_in=-8'sd102; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd51) begin $display("Mismatch post-reset sample 59: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd49; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd24) begin $display("Mismatch post-reset sample 60: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd36; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd18) begin $display("Mismatch post-reset sample 61: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=-8'sd117; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== -8'sd59) begin $display("Mismatch post-reset sample 62: %d",y_out); errors=errors+1; end
    @(negedge clk);
    in_valid=1; x_in=8'sd110; @(posedge clk); #1;
    if(out_valid !== 1 || y_out !== 8'sd55) begin $display("Mismatch post-reset sample 63: %d",y_out); errors=errors+1; end
    @(negedge clk);
    $display("Golden vector saturation count per run: 0");
    if(errors==0) $display("PASS: fixed-point vectors, valid gaps, reset");
    else $fatal(1,"FAIL: %d mismatches",errors);
    $finish;
  end
endmodule
