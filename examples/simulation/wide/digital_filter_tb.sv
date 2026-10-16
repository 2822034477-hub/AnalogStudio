`timescale 1ns/1ps
// Golden vectors exercise 48 saturated outputs per run.
// Zero means this filter/vector pair does not test output clipping.
module digital_filter_tb;
  reg clk=0; always #5 clk=~clk;
  reg rst_n=0;
  reg signed [23:0] data_in=0;
  wire signed [23:0] data_out;
  integer errors=0;
  // Input before capture edge E0; compare after E0 + 1 edges (2 cycles, capture counts as 1).
  digital_filter dut(.clk(clk),.rst_n(rst_n),.data_in(data_in),.data_out(data_out));
  initial begin
    @(posedge clk); #1; if(data_out !== 0) errors=errors+1;
    @(negedge clk); rst_n=1;
    data_in=24'sd8388607; @(posedge clk); #1;
    if(data_out !== 24'sd0) begin $display("Mismatch sample 0: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd8388608; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 1: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 2: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1; @(posedge clk); #1;
    if(data_out !== 24'sd3355443) begin $display("Mismatch sample 3: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1; @(posedge clk); #1;
    if(data_out !== -24'sd419429) begin $display("Mismatch sample 4: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4645820; @(posedge clk); #1;
    if(data_out !== -24'sd440404) begin $display("Mismatch sample 5: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4425005; @(posedge clk); #1;
    if(data_out !== -24'sd8198342) begin $display("Mismatch sample 6: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd7585258; @(posedge clk); #1;
    if(data_out !== -24'sd7426394) begin $display("Mismatch sample 7: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd594557; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 8: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7844280; @(posedge clk); #1;
    if(data_out !== 24'sd2372340) begin $display("Mismatch sample 9: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4868535; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 10: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7510954; @(posedge clk); #1;
    if(data_out !== 24'sd6606353) begin $display("Mismatch sample 11: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2058495; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 12: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1705068; @(posedge clk); #1;
    if(data_out !== -24'sd4704193) begin $display("Mismatch sample 13: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1062107; @(posedge clk); #1;
    if(data_out !== 24'sd3875946) begin $display("Mismatch sample 14: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4987778; @(posedge clk); #1;
    if(data_out !== 24'sd1930935) begin $display("Mismatch sample 15: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1457723; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 16: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4241312; @(posedge clk); #1;
    if(data_out !== -24'sd2081845) begin $display("Mismatch sample 17: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6021183; @(posedge clk); #1;
    if(data_out !== -24'sd7621979) begin $display("Mismatch sample 18: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd6721390; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 19: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd5625545; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 20: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3692; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 21: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd2306019; @(posedge clk); #1;
    if(data_out !== -24'sd1563568) begin $display("Mismatch sample 22: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7853030; @(posedge clk); #1;
    if(data_out !== 24'sd4214013) begin $display("Mismatch sample 23: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6838797; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 24: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1985528; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 25: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6834119; @(posedge clk); #1;
    if(data_out !== -24'sd3672524) begin $display("Mismatch sample 26: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4005254; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 27: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8064913; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 28: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd754620; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 29: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2257941; @(posedge clk); #1;
    if(data_out !== -24'sd777172) begin $display("Mismatch sample 30: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6402126; @(posedge clk); #1;
    if(data_out !== -24'sd3345632) begin $display("Mismatch sample 31: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4324181; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 32: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3773616; @(posedge clk); #1;
    if(data_out !== 24'sd6233483) begin $display("Mismatch sample 33: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3563441; @(posedge clk); #1;
    if(data_out !== 24'sd6761779) begin $display("Mismatch sample 34: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4362594; @(posedge clk); #1;
    if(data_out !== -24'sd5974688) begin $display("Mismatch sample 35: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd5202265; @(posedge clk); #1;
    if(data_out !== 24'sd8189814) begin $display("Mismatch sample 36: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd959772; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 37: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd2844915; @(posedge clk); #1;
    if(data_out !== -24'sd1911915) begin $display("Mismatch sample 38: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3086774; @(posedge clk); #1;
    if(data_out !== 24'sd5442214) begin $display("Mismatch sample 39: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2636387; @(posedge clk); #1;
    if(data_out !== 24'sd5291199) begin $display("Mismatch sample 40: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7703128; @(posedge clk); #1;
    if(data_out !== -24'sd4667257) begin $display("Mismatch sample 41: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1968599; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 42: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2089654; @(posedge clk); #1;
    if(data_out !== 24'sd1498265) begin $display("Mismatch sample 43: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4854751; @(posedge clk); #1;
    if(data_out !== -24'sd3179706) begin $display("Mismatch sample 44: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd387316; @(posedge clk); #1;
    if(data_out !== -24'sd7903591) begin $display("Mismatch sample 45: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8185595; @(posedge clk); #1;
    if(data_out !== -24'sd430768) begin $display("Mismatch sample 46: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd5353502; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 47: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd5318427; @(posedge clk); #1;
    if(data_out !== 24'sd7319231) begin $display("Mismatch sample 48: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1586432; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 49: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3693473; @(posedge clk); #1;
    if(data_out !== 24'sd3944770) begin $display("Mismatch sample 50: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd5711410; @(posedge clk); #1;
    if(data_out !== -24'sd6761347) begin $display("Mismatch sample 51: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd667671; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 52: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd8234956; @(posedge clk); #1;
    if(data_out !== -24'sd2174211) begin $display("Mismatch sample 53: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4597251; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 54: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7279494; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 55: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1026771; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 56: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd510808; @(posedge clk); #1;
    if(data_out !== -24'sd3028992) begin $display("Mismatch sample 57: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7114727; @(posedge clk); #1;
    if(data_out !== -24'sd156764) begin $display("Mismatch sample 58: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2667494; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 59: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3812529; @(posedge clk); #1;
    if(data_out !== -24'sd6240352) begin $display("Mismatch sample 60: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8044124; @(posedge clk); #1;
    if(data_out !== 24'sd7385406) begin $display("Mismatch sample 61: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8341003; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 62: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2038802; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 63: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1484171; @(posedge clk); #1;
    if(data_out !== -24'sd4469083) begin $display("Mismatch sample 64: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4183728; @(posedge clk); #1;
    if(data_out !== -24'sd1448779) begin $display("Mismatch sample 65: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7793775; @(posedge clk); #1;
    if(data_out !== -24'sd7004425) begin $display("Mismatch sample 66: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd8114430; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 67: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1188473; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 68: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1578620; @(posedge clk); #1;
    if(data_out !== 24'sd5149474) begin $display("Mismatch sample 69: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd2385683; @(posedge clk); #1;
    if(data_out !== -24'sd3259200) begin $display("Mismatch sample 70: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3457366; @(posedge clk); #1;
    if(data_out !== 24'sd3931626) begin $display("Mismatch sample 71: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd7665475; @(posedge clk); #1;
    if(data_out !== 24'sd5771721) begin $display("Mismatch sample 72: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7254776; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 73: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd7022089; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 74: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd692502; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 75: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd995007; @(posedge clk); #1;
    if(data_out !== 24'sd1176847) begin $display("Mismatch sample 76: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6453676; @(posedge clk); #1;
    if(data_out !== -24'sd2017461) begin $display("Mismatch sample 77: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4871909; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 78: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd5485634; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 79: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1409019; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 80: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2723424; @(posedge clk); #1;
    if(data_out !== -24'sd2199235) begin $display("Mismatch sample 81: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3700863; @(posedge clk); #1;
    if(data_out !== -24'sd5143839) begin $display("Mismatch sample 82: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4805678; @(posedge clk); #1;
    if(data_out !== 24'sd6419931) begin $display("Mismatch sample 83: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd5416695; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 84: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd6877484; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 85: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4772829; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 86: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4381914; @(posedge clk); #1;
    if(data_out !== -24'sd7526174) begin $display("Mismatch sample 87: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4136883; @(posedge clk); #1;
    if(data_out !== -24'sd8043989) begin $display("Mismatch sample 88: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1967432; @(posedge clk); #1;
    if(data_out !== -24'sd7500175) begin $display("Mismatch sample 89: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1566727; @(posedge clk); #1;
    if(data_out !== 24'sd3345324) begin $display("Mismatch sample 90: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3701318; @(posedge clk); #1;
    if(data_out !== 24'sd2310184) begin $display("Mismatch sample 91: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd186833; @(posedge clk); #1;
    if(data_out !== -24'sd6525798) begin $display("Mismatch sample 92: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3782404; @(posedge clk); #1;
    if(data_out !== 24'sd706831) begin $display("Mismatch sample 93: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3215403; @(posedge clk); #1;
    if(data_out !== -24'sd6808665) begin $display("Mismatch sample 94: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd7280754; @(posedge clk); #1;
    if(data_out !== 24'sd5792016) begin $display("Mismatch sample 95: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1357419; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 96: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4197872; @(posedge clk); #1;
    if(data_out !== -24'sd607609) begin $display("Mismatch sample 97: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd5420913; @(posedge clk); #1;
    if(data_out !== 24'sd6891756) begin $display("Mismatch sample 98: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1809570; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 99: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1078169; @(posedge clk); #1;
    if(data_out !== 24'sd4140344) begin $display("Mismatch sample 100: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4507684; @(posedge clk); #1;
    if(data_out !== 24'sd1500729) begin $display("Mismatch sample 101: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3110195; @(posedge clk); #1;
    if(data_out !== 24'sd7762903) begin $display("Mismatch sample 102: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd8046346; @(posedge clk); #1;
    if(data_out !== 24'sd5249194) begin $display("Mismatch sample 103: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1385507; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 104: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd7656552; @(posedge clk); #1;
    if(data_out !== -24'sd245987) begin $display("Mismatch sample 105: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4802025; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 106: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1740938; @(posedge clk); #1;
    if(data_out !== -24'sd6994198) begin $display("Mismatch sample 107: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2537887; @(posedge clk); #1;
    if(data_out !== 24'sd2623827) begin $display("Mismatch sample 108: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd316340; @(posedge clk); #1;
    if(data_out !== -24'sd5156901) begin $display("Mismatch sample 109: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4356923; @(posedge clk); #1;
    if(data_out !== -24'sd401025) begin $display("Mismatch sample 110: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd5523618; @(posedge clk); #1;
    if(data_out !== 24'sd7563747) begin $display("Mismatch sample 111: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6600485; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 112: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd2227776; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 113: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4825953; @(posedge clk); #1;
    if(data_out !== 24'sd2153474) begin $display("Mismatch sample 114: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd2097522; @(posedge clk); #1;
    if(data_out !== -24'sd8209677) begin $display("Mismatch sample 115: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3902935; @(posedge clk); #1;
    if(data_out !== 24'sd4372817) begin $display("Mismatch sample 116: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1698444; @(posedge clk); #1;
    if(data_out !== -24'sd7171214) begin $display("Mismatch sample 117: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd114109; @(posedge clk); #1;
    if(data_out !== -24'sd2726514) begin $display("Mismatch sample 118: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4850374; @(posedge clk); #1;
    if(data_out !== -24'sd290710) begin $display("Mismatch sample 119: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd6161555; @(posedge clk); #1;
    if(data_out !== 24'sd8320572) begin $display("Mismatch sample 120: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8070632; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 121: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7491623; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 122: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd290982; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 123: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1906417; @(posedge clk); #1;
    if(data_out !== -24'sd979081) begin $display("Mismatch sample 124: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd6937700; @(posedge clk); #1;
    if(data_out !== 24'sd4270996) begin $display("Mismatch sample 125: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8055371; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch sample 126: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd5880622; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch sample 127: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd7464991) begin $display("Mismatch sample 128: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd100919) begin $display("Mismatch sample 129: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd748886) begin $display("Mismatch sample 130: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd177130) begin $display("Mismatch sample 131: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== -24'sd30606) begin $display("Mismatch sample 132: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== -24'sd25365) begin $display("Mismatch sample 133: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== -24'sd3281) begin $display("Mismatch sample 134: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd1716) begin $display("Mismatch sample 135: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd757) begin $display("Mismatch sample 136: %d",data_out); errors=errors+1; end
    @(negedge clk);
    rst_n=0; data_in=24'sd8388607; @(posedge clk); #1;
    if(data_out !== 0) errors=errors+1;
    @(negedge clk); rst_n=1;
    data_in=24'sd8388607; @(posedge clk); #1;
    if(data_out !== 24'sd0) begin $display("Mismatch post-reset sample 0: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd8388608; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 1: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 2: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1; @(posedge clk); #1;
    if(data_out !== 24'sd3355443) begin $display("Mismatch post-reset sample 3: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1; @(posedge clk); #1;
    if(data_out !== -24'sd419429) begin $display("Mismatch post-reset sample 4: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4645820; @(posedge clk); #1;
    if(data_out !== -24'sd440404) begin $display("Mismatch post-reset sample 5: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4425005; @(posedge clk); #1;
    if(data_out !== -24'sd8198342) begin $display("Mismatch post-reset sample 6: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd7585258; @(posedge clk); #1;
    if(data_out !== -24'sd7426394) begin $display("Mismatch post-reset sample 7: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd594557; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 8: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7844280; @(posedge clk); #1;
    if(data_out !== 24'sd2372340) begin $display("Mismatch post-reset sample 9: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4868535; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 10: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7510954; @(posedge clk); #1;
    if(data_out !== 24'sd6606353) begin $display("Mismatch post-reset sample 11: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2058495; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 12: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1705068; @(posedge clk); #1;
    if(data_out !== -24'sd4704193) begin $display("Mismatch post-reset sample 13: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1062107; @(posedge clk); #1;
    if(data_out !== 24'sd3875946) begin $display("Mismatch post-reset sample 14: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4987778; @(posedge clk); #1;
    if(data_out !== 24'sd1930935) begin $display("Mismatch post-reset sample 15: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1457723; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 16: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4241312; @(posedge clk); #1;
    if(data_out !== -24'sd2081845) begin $display("Mismatch post-reset sample 17: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6021183; @(posedge clk); #1;
    if(data_out !== -24'sd7621979) begin $display("Mismatch post-reset sample 18: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd6721390; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 19: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd5625545; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 20: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3692; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 21: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd2306019; @(posedge clk); #1;
    if(data_out !== -24'sd1563568) begin $display("Mismatch post-reset sample 22: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7853030; @(posedge clk); #1;
    if(data_out !== 24'sd4214013) begin $display("Mismatch post-reset sample 23: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6838797; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 24: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1985528; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 25: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6834119; @(posedge clk); #1;
    if(data_out !== -24'sd3672524) begin $display("Mismatch post-reset sample 26: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4005254; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 27: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8064913; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 28: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd754620; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 29: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2257941; @(posedge clk); #1;
    if(data_out !== -24'sd777172) begin $display("Mismatch post-reset sample 30: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6402126; @(posedge clk); #1;
    if(data_out !== -24'sd3345632) begin $display("Mismatch post-reset sample 31: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4324181; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 32: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3773616; @(posedge clk); #1;
    if(data_out !== 24'sd6233483) begin $display("Mismatch post-reset sample 33: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3563441; @(posedge clk); #1;
    if(data_out !== 24'sd6761779) begin $display("Mismatch post-reset sample 34: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4362594; @(posedge clk); #1;
    if(data_out !== -24'sd5974688) begin $display("Mismatch post-reset sample 35: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd5202265; @(posedge clk); #1;
    if(data_out !== 24'sd8189814) begin $display("Mismatch post-reset sample 36: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd959772; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 37: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd2844915; @(posedge clk); #1;
    if(data_out !== -24'sd1911915) begin $display("Mismatch post-reset sample 38: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3086774; @(posedge clk); #1;
    if(data_out !== 24'sd5442214) begin $display("Mismatch post-reset sample 39: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2636387; @(posedge clk); #1;
    if(data_out !== 24'sd5291199) begin $display("Mismatch post-reset sample 40: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7703128; @(posedge clk); #1;
    if(data_out !== -24'sd4667257) begin $display("Mismatch post-reset sample 41: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1968599; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 42: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2089654; @(posedge clk); #1;
    if(data_out !== 24'sd1498265) begin $display("Mismatch post-reset sample 43: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4854751; @(posedge clk); #1;
    if(data_out !== -24'sd3179706) begin $display("Mismatch post-reset sample 44: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd387316; @(posedge clk); #1;
    if(data_out !== -24'sd7903591) begin $display("Mismatch post-reset sample 45: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8185595; @(posedge clk); #1;
    if(data_out !== -24'sd430768) begin $display("Mismatch post-reset sample 46: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd5353502; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 47: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd5318427; @(posedge clk); #1;
    if(data_out !== 24'sd7319231) begin $display("Mismatch post-reset sample 48: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1586432; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 49: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3693473; @(posedge clk); #1;
    if(data_out !== 24'sd3944770) begin $display("Mismatch post-reset sample 50: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd5711410; @(posedge clk); #1;
    if(data_out !== -24'sd6761347) begin $display("Mismatch post-reset sample 51: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd667671; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 52: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd8234956; @(posedge clk); #1;
    if(data_out !== -24'sd2174211) begin $display("Mismatch post-reset sample 53: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4597251; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 54: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7279494; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 55: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1026771; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 56: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd510808; @(posedge clk); #1;
    if(data_out !== -24'sd3028992) begin $display("Mismatch post-reset sample 57: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7114727; @(posedge clk); #1;
    if(data_out !== -24'sd156764) begin $display("Mismatch post-reset sample 58: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2667494; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 59: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3812529; @(posedge clk); #1;
    if(data_out !== -24'sd6240352) begin $display("Mismatch post-reset sample 60: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8044124; @(posedge clk); #1;
    if(data_out !== 24'sd7385406) begin $display("Mismatch post-reset sample 61: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8341003; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 62: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2038802; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 63: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1484171; @(posedge clk); #1;
    if(data_out !== -24'sd4469083) begin $display("Mismatch post-reset sample 64: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4183728; @(posedge clk); #1;
    if(data_out !== -24'sd1448779) begin $display("Mismatch post-reset sample 65: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7793775; @(posedge clk); #1;
    if(data_out !== -24'sd7004425) begin $display("Mismatch post-reset sample 66: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd8114430; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 67: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1188473; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 68: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1578620; @(posedge clk); #1;
    if(data_out !== 24'sd5149474) begin $display("Mismatch post-reset sample 69: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd2385683; @(posedge clk); #1;
    if(data_out !== -24'sd3259200) begin $display("Mismatch post-reset sample 70: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3457366; @(posedge clk); #1;
    if(data_out !== 24'sd3931626) begin $display("Mismatch post-reset sample 71: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd7665475; @(posedge clk); #1;
    if(data_out !== 24'sd5771721) begin $display("Mismatch post-reset sample 72: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7254776; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 73: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd7022089; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 74: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd692502; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 75: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd995007; @(posedge clk); #1;
    if(data_out !== 24'sd1176847) begin $display("Mismatch post-reset sample 76: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6453676; @(posedge clk); #1;
    if(data_out !== -24'sd2017461) begin $display("Mismatch post-reset sample 77: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4871909; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 78: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd5485634; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 79: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1409019; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 80: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2723424; @(posedge clk); #1;
    if(data_out !== -24'sd2199235) begin $display("Mismatch post-reset sample 81: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3700863; @(posedge clk); #1;
    if(data_out !== -24'sd5143839) begin $display("Mismatch post-reset sample 82: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4805678; @(posedge clk); #1;
    if(data_out !== 24'sd6419931) begin $display("Mismatch post-reset sample 83: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd5416695; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 84: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd6877484; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 85: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4772829; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 86: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4381914; @(posedge clk); #1;
    if(data_out !== -24'sd7526174) begin $display("Mismatch post-reset sample 87: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4136883; @(posedge clk); #1;
    if(data_out !== -24'sd8043989) begin $display("Mismatch post-reset sample 88: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1967432; @(posedge clk); #1;
    if(data_out !== -24'sd7500175) begin $display("Mismatch post-reset sample 89: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1566727; @(posedge clk); #1;
    if(data_out !== 24'sd3345324) begin $display("Mismatch post-reset sample 90: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3701318; @(posedge clk); #1;
    if(data_out !== 24'sd2310184) begin $display("Mismatch post-reset sample 91: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd186833; @(posedge clk); #1;
    if(data_out !== -24'sd6525798) begin $display("Mismatch post-reset sample 92: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3782404; @(posedge clk); #1;
    if(data_out !== 24'sd706831) begin $display("Mismatch post-reset sample 93: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3215403; @(posedge clk); #1;
    if(data_out !== -24'sd6808665) begin $display("Mismatch post-reset sample 94: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd7280754; @(posedge clk); #1;
    if(data_out !== 24'sd5792016) begin $display("Mismatch post-reset sample 95: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1357419; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 96: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4197872; @(posedge clk); #1;
    if(data_out !== -24'sd607609) begin $display("Mismatch post-reset sample 97: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd5420913; @(posedge clk); #1;
    if(data_out !== 24'sd6891756) begin $display("Mismatch post-reset sample 98: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1809570; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 99: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1078169; @(posedge clk); #1;
    if(data_out !== 24'sd4140344) begin $display("Mismatch post-reset sample 100: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4507684; @(posedge clk); #1;
    if(data_out !== 24'sd1500729) begin $display("Mismatch post-reset sample 101: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3110195; @(posedge clk); #1;
    if(data_out !== 24'sd7762903) begin $display("Mismatch post-reset sample 102: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd8046346; @(posedge clk); #1;
    if(data_out !== 24'sd5249194) begin $display("Mismatch post-reset sample 103: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1385507; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 104: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd7656552; @(posedge clk); #1;
    if(data_out !== -24'sd245987) begin $display("Mismatch post-reset sample 105: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4802025; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 106: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1740938; @(posedge clk); #1;
    if(data_out !== -24'sd6994198) begin $display("Mismatch post-reset sample 107: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2537887; @(posedge clk); #1;
    if(data_out !== 24'sd2623827) begin $display("Mismatch post-reset sample 108: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd316340; @(posedge clk); #1;
    if(data_out !== -24'sd5156901) begin $display("Mismatch post-reset sample 109: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4356923; @(posedge clk); #1;
    if(data_out !== -24'sd401025) begin $display("Mismatch post-reset sample 110: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd5523618; @(posedge clk); #1;
    if(data_out !== 24'sd7563747) begin $display("Mismatch post-reset sample 111: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6600485; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 112: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd2227776; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 113: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4825953; @(posedge clk); #1;
    if(data_out !== 24'sd2153474) begin $display("Mismatch post-reset sample 114: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd2097522; @(posedge clk); #1;
    if(data_out !== -24'sd8209677) begin $display("Mismatch post-reset sample 115: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3902935; @(posedge clk); #1;
    if(data_out !== 24'sd4372817) begin $display("Mismatch post-reset sample 116: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1698444; @(posedge clk); #1;
    if(data_out !== -24'sd7171214) begin $display("Mismatch post-reset sample 117: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd114109; @(posedge clk); #1;
    if(data_out !== -24'sd2726514) begin $display("Mismatch post-reset sample 118: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4850374; @(posedge clk); #1;
    if(data_out !== -24'sd290710) begin $display("Mismatch post-reset sample 119: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd6161555; @(posedge clk); #1;
    if(data_out !== 24'sd8320572) begin $display("Mismatch post-reset sample 120: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8070632; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 121: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7491623; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 122: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd290982; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 123: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1906417; @(posedge clk); #1;
    if(data_out !== -24'sd979081) begin $display("Mismatch post-reset sample 124: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd6937700; @(posedge clk); #1;
    if(data_out !== 24'sd4270996) begin $display("Mismatch post-reset sample 125: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8055371; @(posedge clk); #1;
    if(data_out !== -24'sd8388608) begin $display("Mismatch post-reset sample 126: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd5880622; @(posedge clk); #1;
    if(data_out !== 24'sd8388607) begin $display("Mismatch post-reset sample 127: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd7464991) begin $display("Mismatch post-reset sample 128: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd100919) begin $display("Mismatch post-reset sample 129: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd748886) begin $display("Mismatch post-reset sample 130: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd177130) begin $display("Mismatch post-reset sample 131: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== -24'sd30606) begin $display("Mismatch post-reset sample 132: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== -24'sd25365) begin $display("Mismatch post-reset sample 133: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== -24'sd3281) begin $display("Mismatch post-reset sample 134: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd1716) begin $display("Mismatch post-reset sample 135: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd757) begin $display("Mismatch post-reset sample 136: %d",data_out); errors=errors+1; end
    @(negedge clk);
    $display("TIMING: FO1/SO2, capture counts as cycle 1; total 2 cycles; edge offset 1; model delay 0");
    $display("Golden vector saturation count per run: 48");
    if(errors==0) $display("PASS: four-port SOS, continuous samples, reset, latency");
    else $fatal(1,"FAIL: %d mismatches",errors);
    $finish;
  end
endmodule
