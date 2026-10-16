`timescale 1ns/1ps
// Golden vectors exercise 86 saturated outputs per run.
// Zero means this filter/vector pair does not test output clipping.
module digital_filter_tb;
  reg clk=0; always #5 clk=~clk;
  reg rst_n=0;
  reg signed [7:0] data_in=0;
  wire signed [7:0] data_out;
  integer errors=0;
  // Input before capture edge E0; compare after E0 + 0 edges (1 cycles, capture counts as 1).
  digital_filter dut(.clk(clk),.rst_n(rst_n),.data_in(data_in),.data_out(data_out));
  initial begin
    @(posedge clk); #1; if(data_out !== 0) errors=errors+1;
    @(negedge clk); rst_n=1;
    data_in=8'sd127; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 0: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd128; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 1: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd0; @(posedge clk); #1;
    if(data_out !== 8'sd0) begin $display("Mismatch sample 2: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd1; @(posedge clk); #1;
    if(data_out !== 8'sd3) begin $display("Mismatch sample 3: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd1; @(posedge clk); #1;
    if(data_out !== -8'sd3) begin $display("Mismatch sample 4: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd60; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 5: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd83; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 6: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd106; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 7: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd3; @(posedge clk); #1;
    if(data_out !== -8'sd9) begin $display("Mismatch sample 8: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd56; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 9: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd55; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 10: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd42; @(posedge clk); #1;
    if(data_out !== 8'sd126) begin $display("Mismatch sample 11: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd127; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 12: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd20; @(posedge clk); #1;
    if(data_out !== -8'sd60) begin $display("Mismatch sample 13: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd91; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 14: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd2; @(posedge clk); #1;
    if(data_out !== -8'sd6) begin $display("Mismatch sample 15: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd69; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 16: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd32; @(posedge clk); #1;
    if(data_out !== -8'sd96) begin $display("Mismatch sample 17: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd65; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 18: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd18; @(posedge clk); #1;
    if(data_out !== 8'sd54) begin $display("Mismatch sample 19: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd73; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 20: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd20; @(posedge clk); #1;
    if(data_out !== 8'sd60) begin $display("Mismatch sample 21: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd99; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 22: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd102; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 23: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd115; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 24: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd120; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 25: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd71; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 26: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd6; @(posedge clk); #1;
    if(data_out !== -8'sd18) begin $display("Mismatch sample 27: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd17; @(posedge clk); #1;
    if(data_out !== 8'sd51) begin $display("Mismatch sample 28: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd60; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 29: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd107; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 30: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd50; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 31: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd43; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 32: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd48; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 33: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd49; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 34: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd30; @(posedge clk); #1;
    if(data_out !== -8'sd90) begin $display("Mismatch sample 35: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd39; @(posedge clk); #1;
    if(data_out !== -8'sd117) begin $display("Mismatch sample 36: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd100; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 37: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd115; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 38: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd54; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 39: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd29; @(posedge clk); #1;
    if(data_out !== 8'sd87) begin $display("Mismatch sample 40: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd40; @(posedge clk); #1;
    if(data_out !== -8'sd120) begin $display("Mismatch sample 41: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd87; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 42: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd54; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 43: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd95; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 44: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd116; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 45: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd123; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 46: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd98; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 47: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd101; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 48: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd128; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 49: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd33; @(posedge clk); #1;
    if(data_out !== -8'sd99) begin $display("Mismatch sample 50: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd78; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 51: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd105; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 52: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd76; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 53: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd125; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 54: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd6; @(posedge clk); #1;
    if(data_out !== 8'sd18) begin $display("Mismatch sample 55: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd83; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 56: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd40; @(posedge clk); #1;
    if(data_out !== 8'sd120) begin $display("Mismatch sample 57: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd103; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 58: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd102; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 59: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd49; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 60: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd36; @(posedge clk); #1;
    if(data_out !== -8'sd108) begin $display("Mismatch sample 61: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd117; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 62: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd110; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 63: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd11; @(posedge clk); #1;
    if(data_out !== -8'sd33) begin $display("Mismatch sample 64: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd48; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 65: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd17; @(posedge clk); #1;
    if(data_out !== -8'sd51) begin $display("Mismatch sample 66: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd126; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 67: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd7; @(posedge clk); #1;
    if(data_out !== -8'sd21) begin $display("Mismatch sample 68: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd4; @(posedge clk); #1;
    if(data_out !== 8'sd12) begin $display("Mismatch sample 69: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd109; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 70: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd42; @(posedge clk); #1;
    if(data_out !== -8'sd126) begin $display("Mismatch sample 71: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd61; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 72: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd120; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 73: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd119; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 74: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd106; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 75: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd63; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 76: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd44; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 77: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd101; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 78: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd62; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 79: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd123; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 80: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd32; @(posedge clk); #1;
    if(data_out !== 8'sd96) begin $display("Mismatch sample 81: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd1; @(posedge clk); #1;
    if(data_out !== -8'sd3) begin $display("Mismatch sample 82: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd82; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 83: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd119; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 84: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd84; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 85: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd93; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 86: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd90; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 87: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd51; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 88: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd56; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 89: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd121; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 90: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd58; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 91: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd81; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 92: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd124; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 93: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd85; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 94: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd14; @(posedge clk); #1;
    if(data_out !== 8'sd42) begin $display("Mismatch sample 95: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd21; @(posedge clk); #1;
    if(data_out !== 8'sd63) begin $display("Mismatch sample 96: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd112; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 97: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd15; @(posedge clk); #1;
    if(data_out !== 8'sd45) begin $display("Mismatch sample 98: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd34; @(posedge clk); #1;
    if(data_out !== 8'sd102) begin $display("Mismatch sample 99: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd25; @(posedge clk); #1;
    if(data_out !== 8'sd75) begin $display("Mismatch sample 100: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd92; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 101: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd77; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 102: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd118; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 103: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd93; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 104: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd24; @(posedge clk); #1;
    if(data_out !== 8'sd72) begin $display("Mismatch sample 105: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd105; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 106: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd10; @(posedge clk); #1;
    if(data_out !== 8'sd30) begin $display("Mismatch sample 107: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd31; @(posedge clk); #1;
    if(data_out !== -8'sd93) begin $display("Mismatch sample 108: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd52; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 109: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd69; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 110: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd34; @(posedge clk); #1;
    if(data_out !== -8'sd102) begin $display("Mismatch sample 111: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd91; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 112: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd64; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 113: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd31; @(posedge clk); #1;
    if(data_out !== 8'sd93) begin $display("Mismatch sample 114: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd14; @(posedge clk); #1;
    if(data_out !== -8'sd42) begin $display("Mismatch sample 115: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd87; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 116: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd12; @(posedge clk); #1;
    if(data_out !== -8'sd36) begin $display("Mismatch sample 117: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd61; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 118: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd70; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 119: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd19; @(posedge clk); #1;
    if(data_out !== -8'sd57) begin $display("Mismatch sample 120: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd104; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 121: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd89; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 122: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd38; @(posedge clk); #1;
    if(data_out !== -8'sd114) begin $display("Mismatch sample 123: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd113; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch sample 124: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd28; @(posedge clk); #1;
    if(data_out !== 8'sd84) begin $display("Mismatch sample 125: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd53; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 126: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd82; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch sample 127: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd0; @(posedge clk); #1;
    if(data_out !== 8'sd0) begin $display("Mismatch sample 128: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd0; @(posedge clk); #1;
    if(data_out !== 8'sd0) begin $display("Mismatch sample 129: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd0; @(posedge clk); #1;
    if(data_out !== 8'sd0) begin $display("Mismatch sample 130: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd0; @(posedge clk); #1;
    if(data_out !== 8'sd0) begin $display("Mismatch sample 131: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd0; @(posedge clk); #1;
    if(data_out !== 8'sd0) begin $display("Mismatch sample 132: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd0; @(posedge clk); #1;
    if(data_out !== 8'sd0) begin $display("Mismatch sample 133: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd0; @(posedge clk); #1;
    if(data_out !== 8'sd0) begin $display("Mismatch sample 134: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd0; @(posedge clk); #1;
    if(data_out !== 8'sd0) begin $display("Mismatch sample 135: %d",data_out); errors=errors+1; end
    @(negedge clk);
    rst_n=0; data_in=8'sd127; @(posedge clk); #1;
    if(data_out !== 0) errors=errors+1;
    @(negedge clk); rst_n=1;
    data_in=8'sd127; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 0: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd128; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 1: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd0; @(posedge clk); #1;
    if(data_out !== 8'sd0) begin $display("Mismatch post-reset sample 2: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd1; @(posedge clk); #1;
    if(data_out !== 8'sd3) begin $display("Mismatch post-reset sample 3: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd1; @(posedge clk); #1;
    if(data_out !== -8'sd3) begin $display("Mismatch post-reset sample 4: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd60; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 5: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd83; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 6: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd106; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 7: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd3; @(posedge clk); #1;
    if(data_out !== -8'sd9) begin $display("Mismatch post-reset sample 8: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd56; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 9: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd55; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 10: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd42; @(posedge clk); #1;
    if(data_out !== 8'sd126) begin $display("Mismatch post-reset sample 11: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd127; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 12: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd20; @(posedge clk); #1;
    if(data_out !== -8'sd60) begin $display("Mismatch post-reset sample 13: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd91; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 14: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd2; @(posedge clk); #1;
    if(data_out !== -8'sd6) begin $display("Mismatch post-reset sample 15: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd69; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 16: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd32; @(posedge clk); #1;
    if(data_out !== -8'sd96) begin $display("Mismatch post-reset sample 17: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd65; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 18: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd18; @(posedge clk); #1;
    if(data_out !== 8'sd54) begin $display("Mismatch post-reset sample 19: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd73; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 20: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd20; @(posedge clk); #1;
    if(data_out !== 8'sd60) begin $display("Mismatch post-reset sample 21: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd99; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 22: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd102; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 23: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd115; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 24: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd120; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 25: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd71; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 26: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd6; @(posedge clk); #1;
    if(data_out !== -8'sd18) begin $display("Mismatch post-reset sample 27: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd17; @(posedge clk); #1;
    if(data_out !== 8'sd51) begin $display("Mismatch post-reset sample 28: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd60; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 29: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd107; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 30: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd50; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 31: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd43; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 32: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd48; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 33: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd49; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 34: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd30; @(posedge clk); #1;
    if(data_out !== -8'sd90) begin $display("Mismatch post-reset sample 35: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd39; @(posedge clk); #1;
    if(data_out !== -8'sd117) begin $display("Mismatch post-reset sample 36: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd100; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 37: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd115; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 38: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd54; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 39: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd29; @(posedge clk); #1;
    if(data_out !== 8'sd87) begin $display("Mismatch post-reset sample 40: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd40; @(posedge clk); #1;
    if(data_out !== -8'sd120) begin $display("Mismatch post-reset sample 41: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd87; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 42: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd54; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 43: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd95; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 44: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd116; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 45: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd123; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 46: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd98; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 47: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd101; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 48: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd128; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 49: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd33; @(posedge clk); #1;
    if(data_out !== -8'sd99) begin $display("Mismatch post-reset sample 50: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd78; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 51: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd105; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 52: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd76; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 53: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd125; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 54: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd6; @(posedge clk); #1;
    if(data_out !== 8'sd18) begin $display("Mismatch post-reset sample 55: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd83; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 56: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd40; @(posedge clk); #1;
    if(data_out !== 8'sd120) begin $display("Mismatch post-reset sample 57: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd103; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 58: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd102; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 59: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd49; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 60: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd36; @(posedge clk); #1;
    if(data_out !== -8'sd108) begin $display("Mismatch post-reset sample 61: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd117; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 62: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd110; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 63: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd11; @(posedge clk); #1;
    if(data_out !== -8'sd33) begin $display("Mismatch post-reset sample 64: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd48; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 65: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd17; @(posedge clk); #1;
    if(data_out !== -8'sd51) begin $display("Mismatch post-reset sample 66: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd126; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 67: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd7; @(posedge clk); #1;
    if(data_out !== -8'sd21) begin $display("Mismatch post-reset sample 68: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd4; @(posedge clk); #1;
    if(data_out !== 8'sd12) begin $display("Mismatch post-reset sample 69: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd109; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 70: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd42; @(posedge clk); #1;
    if(data_out !== -8'sd126) begin $display("Mismatch post-reset sample 71: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd61; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 72: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd120; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 73: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd119; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 74: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd106; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 75: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd63; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 76: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd44; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 77: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd101; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 78: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd62; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 79: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd123; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 80: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd32; @(posedge clk); #1;
    if(data_out !== 8'sd96) begin $display("Mismatch post-reset sample 81: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd1; @(posedge clk); #1;
    if(data_out !== -8'sd3) begin $display("Mismatch post-reset sample 82: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd82; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 83: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd119; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 84: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd84; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 85: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd93; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 86: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd90; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 87: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd51; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 88: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd56; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 89: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd121; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 90: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd58; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 91: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd81; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 92: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd124; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 93: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd85; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 94: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd14; @(posedge clk); #1;
    if(data_out !== 8'sd42) begin $display("Mismatch post-reset sample 95: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd21; @(posedge clk); #1;
    if(data_out !== 8'sd63) begin $display("Mismatch post-reset sample 96: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd112; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 97: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd15; @(posedge clk); #1;
    if(data_out !== 8'sd45) begin $display("Mismatch post-reset sample 98: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd34; @(posedge clk); #1;
    if(data_out !== 8'sd102) begin $display("Mismatch post-reset sample 99: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd25; @(posedge clk); #1;
    if(data_out !== 8'sd75) begin $display("Mismatch post-reset sample 100: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd92; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 101: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd77; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 102: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd118; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 103: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd93; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 104: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd24; @(posedge clk); #1;
    if(data_out !== 8'sd72) begin $display("Mismatch post-reset sample 105: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd105; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 106: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd10; @(posedge clk); #1;
    if(data_out !== 8'sd30) begin $display("Mismatch post-reset sample 107: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd31; @(posedge clk); #1;
    if(data_out !== -8'sd93) begin $display("Mismatch post-reset sample 108: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd52; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 109: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd69; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 110: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd34; @(posedge clk); #1;
    if(data_out !== -8'sd102) begin $display("Mismatch post-reset sample 111: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd91; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 112: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd64; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 113: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd31; @(posedge clk); #1;
    if(data_out !== 8'sd93) begin $display("Mismatch post-reset sample 114: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd14; @(posedge clk); #1;
    if(data_out !== -8'sd42) begin $display("Mismatch post-reset sample 115: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd87; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 116: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd12; @(posedge clk); #1;
    if(data_out !== -8'sd36) begin $display("Mismatch post-reset sample 117: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd61; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 118: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd70; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 119: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd19; @(posedge clk); #1;
    if(data_out !== -8'sd57) begin $display("Mismatch post-reset sample 120: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd104; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 121: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd89; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 122: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd38; @(posedge clk); #1;
    if(data_out !== -8'sd114) begin $display("Mismatch post-reset sample 123: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd113; @(posedge clk); #1;
    if(data_out !== 8'sd127) begin $display("Mismatch post-reset sample 124: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd28; @(posedge clk); #1;
    if(data_out !== 8'sd84) begin $display("Mismatch post-reset sample 125: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd53; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 126: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-8'sd82; @(posedge clk); #1;
    if(data_out !== -8'sd128) begin $display("Mismatch post-reset sample 127: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd0; @(posedge clk); #1;
    if(data_out !== 8'sd0) begin $display("Mismatch post-reset sample 128: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd0; @(posedge clk); #1;
    if(data_out !== 8'sd0) begin $display("Mismatch post-reset sample 129: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd0; @(posedge clk); #1;
    if(data_out !== 8'sd0) begin $display("Mismatch post-reset sample 130: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd0; @(posedge clk); #1;
    if(data_out !== 8'sd0) begin $display("Mismatch post-reset sample 131: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd0; @(posedge clk); #1;
    if(data_out !== 8'sd0) begin $display("Mismatch post-reset sample 132: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd0; @(posedge clk); #1;
    if(data_out !== 8'sd0) begin $display("Mismatch post-reset sample 133: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd0; @(posedge clk); #1;
    if(data_out !== 8'sd0) begin $display("Mismatch post-reset sample 134: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=8'sd0; @(posedge clk); #1;
    if(data_out !== 8'sd0) begin $display("Mismatch post-reset sample 135: %d",data_out); errors=errors+1; end
    @(negedge clk);
    $display("TIMING: FO1/SO2, capture counts as cycle 1; total 1 cycles; edge offset 0; model delay 0");
    $display("Golden vector saturation count per run: 86");
    if(errors==0) $display("PASS: four-port SOS, continuous samples, reset, latency");
    else $fatal(1,"FAIL: %d mismatches",errors);
    $finish;
  end
endmodule
