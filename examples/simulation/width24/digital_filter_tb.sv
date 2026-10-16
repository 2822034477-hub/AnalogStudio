`timescale 1ns/1ps
// Golden vectors exercise 0 saturated outputs per run.
// Zero means this filter/vector pair does not test output clipping.
module digital_filter_tb;
  reg clk=0; always #5 clk=~clk;
  reg rst_n=0;
  reg signed [23:0] data_in=0;
  wire signed [23:0] data_out;
  integer errors=0;
  // Input before capture edge E0; compare after E0 + 5 edges (6 cycles, capture counts as 1).
  digital_filter #(.IN_WIDTH(24)) dut(.clk(clk),.rst_n(rst_n),.data_in(data_in),.data_out(data_out));
  initial begin
    @(posedge clk); #1; if(data_out !== 0) errors=errors+1;
    @(negedge clk); rst_n=1;
    data_in=24'sd8388607; @(posedge clk); #1;
    if(data_out !== 24'sd0) begin $display("Mismatch sample 0: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd8388608; @(posedge clk); #1;
    if(data_out !== 24'sd0) begin $display("Mismatch sample 1: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd0) begin $display("Mismatch sample 2: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1; @(posedge clk); #1;
    if(data_out !== 24'sd0) begin $display("Mismatch sample 3: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1; @(posedge clk); #1;
    if(data_out !== 24'sd0) begin $display("Mismatch sample 4: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4645820; @(posedge clk); #1;
    if(data_out !== 24'sd109051) begin $display("Mismatch sample 5: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4425005; @(posedge clk); #1;
    if(data_out !== 24'sd211551) begin $display("Mismatch sample 6: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd7585258; @(posedge clk); #1;
    if(data_out !== 24'sd185548) begin $display("Mismatch sample 7: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd594557; @(posedge clk); #1;
    if(data_out !== 24'sd52878) begin $display("Mismatch sample 8: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7844280; @(posedge clk); #1;
    if(data_out !== -24'sd78872) begin $display("Mismatch sample 9: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4868535; @(posedge clk); #1;
    if(data_out !== -24'sd201977) begin $display("Mismatch sample 10: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7510954; @(posedge clk); #1;
    if(data_out !== -24'sd371947) begin $display("Mismatch sample 11: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2058495; @(posedge clk); #1;
    if(data_out !== -24'sd647205) begin $display("Mismatch sample 12: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1705068; @(posedge clk); #1;
    if(data_out !== -24'sd917379) begin $display("Mismatch sample 13: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1062107; @(posedge clk); #1;
    if(data_out !== -24'sd922795) begin $display("Mismatch sample 14: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4987778; @(posedge clk); #1;
    if(data_out !== -24'sd559191) begin $display("Mismatch sample 15: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1457723; @(posedge clk); #1;
    if(data_out !== 24'sd68463) begin $display("Mismatch sample 16: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4241312; @(posedge clk); #1;
    if(data_out !== 24'sd640961) begin $display("Mismatch sample 17: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6021183; @(posedge clk); #1;
    if(data_out !== 24'sd933649) begin $display("Mismatch sample 18: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd6721390; @(posedge clk); #1;
    if(data_out !== 24'sd941097) begin $display("Mismatch sample 19: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd5625545; @(posedge clk); #1;
    if(data_out !== 24'sd714708) begin $display("Mismatch sample 20: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3692; @(posedge clk); #1;
    if(data_out !== 24'sd354891) begin $display("Mismatch sample 21: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd2306019; @(posedge clk); #1;
    if(data_out !== -24'sd45988) begin $display("Mismatch sample 22: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7853030; @(posedge clk); #1;
    if(data_out !== -24'sd290912) begin $display("Mismatch sample 23: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6838797; @(posedge clk); #1;
    if(data_out !== -24'sd384565) begin $display("Mismatch sample 24: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1985528; @(posedge clk); #1;
    if(data_out !== -24'sd336711) begin $display("Mismatch sample 25: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6834119; @(posedge clk); #1;
    if(data_out !== -24'sd190889) begin $display("Mismatch sample 26: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4005254; @(posedge clk); #1;
    if(data_out !== 24'sd4792) begin $display("Mismatch sample 27: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8064913; @(posedge clk); #1;
    if(data_out !== 24'sd278057) begin $display("Mismatch sample 28: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd754620; @(posedge clk); #1;
    if(data_out !== 24'sd654470) begin $display("Mismatch sample 29: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2257941; @(posedge clk); #1;
    if(data_out !== 24'sd974610) begin $display("Mismatch sample 30: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6402126; @(posedge clk); #1;
    if(data_out !== 24'sd1157296) begin $display("Mismatch sample 31: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4324181; @(posedge clk); #1;
    if(data_out !== 24'sd1130885) begin $display("Mismatch sample 32: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3773616; @(posedge clk); #1;
    if(data_out !== 24'sd1016240) begin $display("Mismatch sample 33: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3563441; @(posedge clk); #1;
    if(data_out !== 24'sd919249) begin $display("Mismatch sample 34: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4362594; @(posedge clk); #1;
    if(data_out !== 24'sd805063) begin $display("Mismatch sample 35: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd5202265; @(posedge clk); #1;
    if(data_out !== 24'sd707793) begin $display("Mismatch sample 36: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd959772; @(posedge clk); #1;
    if(data_out !== 24'sd705292) begin $display("Mismatch sample 37: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd2844915; @(posedge clk); #1;
    if(data_out !== 24'sd810241) begin $display("Mismatch sample 38: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3086774; @(posedge clk); #1;
    if(data_out !== 24'sd865303) begin $display("Mismatch sample 39: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2636387; @(posedge clk); #1;
    if(data_out !== 24'sd816994) begin $display("Mismatch sample 40: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7703128; @(posedge clk); #1;
    if(data_out !== 24'sd767572) begin $display("Mismatch sample 41: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1968599; @(posedge clk); #1;
    if(data_out !== 24'sd744462) begin $display("Mismatch sample 42: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2089654; @(posedge clk); #1;
    if(data_out !== 24'sd726992) begin $display("Mismatch sample 43: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4854751; @(posedge clk); #1;
    if(data_out !== 24'sd716098) begin $display("Mismatch sample 44: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd387316; @(posedge clk); #1;
    if(data_out !== 24'sd657778) begin $display("Mismatch sample 45: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8185595; @(posedge clk); #1;
    if(data_out !== 24'sd620742) begin $display("Mismatch sample 46: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd5353502; @(posedge clk); #1;
    if(data_out !== 24'sd658188) begin $display("Mismatch sample 47: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd5318427; @(posedge clk); #1;
    if(data_out !== 24'sd685911) begin $display("Mismatch sample 48: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1586432; @(posedge clk); #1;
    if(data_out !== 24'sd551775) begin $display("Mismatch sample 49: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3693473; @(posedge clk); #1;
    if(data_out !== 24'sd262907) begin $display("Mismatch sample 50: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd5711410; @(posedge clk); #1;
    if(data_out !== 24'sd71914) begin $display("Mismatch sample 51: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd667671; @(posedge clk); #1;
    if(data_out !== 24'sd168303) begin $display("Mismatch sample 52: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd8234956; @(posedge clk); #1;
    if(data_out !== 24'sd374557) begin $display("Mismatch sample 53: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4597251; @(posedge clk); #1;
    if(data_out !== 24'sd477604) begin $display("Mismatch sample 54: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7279494; @(posedge clk); #1;
    if(data_out !== 24'sd381300) begin $display("Mismatch sample 55: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1026771; @(posedge clk); #1;
    if(data_out !== 24'sd237319) begin $display("Mismatch sample 56: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd510808; @(posedge clk); #1;
    if(data_out !== 24'sd167115) begin $display("Mismatch sample 57: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7114727; @(posedge clk); #1;
    if(data_out !== 24'sd58249) begin $display("Mismatch sample 58: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2667494; @(posedge clk); #1;
    if(data_out !== -24'sd84852) begin $display("Mismatch sample 59: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3812529; @(posedge clk); #1;
    if(data_out !== -24'sd77490) begin $display("Mismatch sample 60: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8044124; @(posedge clk); #1;
    if(data_out !== 24'sd101669) begin $display("Mismatch sample 61: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8341003; @(posedge clk); #1;
    if(data_out !== 24'sd294316) begin $display("Mismatch sample 62: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2038802; @(posedge clk); #1;
    if(data_out !== 24'sd460977) begin $display("Mismatch sample 63: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1484171; @(posedge clk); #1;
    if(data_out !== 24'sd556956) begin $display("Mismatch sample 64: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4183728; @(posedge clk); #1;
    if(data_out !== 24'sd592821) begin $display("Mismatch sample 65: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7793775; @(posedge clk); #1;
    if(data_out !== 24'sd681935) begin $display("Mismatch sample 66: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd8114430; @(posedge clk); #1;
    if(data_out !== 24'sd928273) begin $display("Mismatch sample 67: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1188473; @(posedge clk); #1;
    if(data_out !== 24'sd1184262) begin $display("Mismatch sample 68: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1578620; @(posedge clk); #1;
    if(data_out !== 24'sd1227125) begin $display("Mismatch sample 69: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd2385683; @(posedge clk); #1;
    if(data_out !== 24'sd957681) begin $display("Mismatch sample 70: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3457366; @(posedge clk); #1;
    if(data_out !== 24'sd612711) begin $display("Mismatch sample 71: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd7665475; @(posedge clk); #1;
    if(data_out !== 24'sd298554) begin $display("Mismatch sample 72: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7254776; @(posedge clk); #1;
    if(data_out !== 24'sd45667) begin $display("Mismatch sample 73: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd7022089; @(posedge clk); #1;
    if(data_out !== -24'sd144578) begin $display("Mismatch sample 74: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd692502; @(posedge clk); #1;
    if(data_out !== -24'sd223186) begin $display("Mismatch sample 75: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd995007; @(posedge clk); #1;
    if(data_out !== -24'sd142079) begin $display("Mismatch sample 76: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6453676; @(posedge clk); #1;
    if(data_out !== -24'sd61568) begin $display("Mismatch sample 77: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4871909; @(posedge clk); #1;
    if(data_out !== -24'sd702) begin $display("Mismatch sample 78: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd5485634; @(posedge clk); #1;
    if(data_out !== -24'sd13040) begin $display("Mismatch sample 79: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1409019; @(posedge clk); #1;
    if(data_out !== -24'sd110771) begin $display("Mismatch sample 80: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2723424; @(posedge clk); #1;
    if(data_out !== -24'sd246048) begin $display("Mismatch sample 81: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3700863; @(posedge clk); #1;
    if(data_out !== -24'sd254811) begin $display("Mismatch sample 82: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4805678; @(posedge clk); #1;
    if(data_out !== -24'sd163936) begin $display("Mismatch sample 83: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd5416695; @(posedge clk); #1;
    if(data_out !== -24'sd154434) begin $display("Mismatch sample 84: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd6877484; @(posedge clk); #1;
    if(data_out !== -24'sd289582) begin $display("Mismatch sample 85: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4772829; @(posedge clk); #1;
    if(data_out !== -24'sd492345) begin $display("Mismatch sample 86: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4381914; @(posedge clk); #1;
    if(data_out !== -24'sd584373) begin $display("Mismatch sample 87: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4136883; @(posedge clk); #1;
    if(data_out !== -24'sd560379) begin $display("Mismatch sample 88: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1967432; @(posedge clk); #1;
    if(data_out !== -24'sd561501) begin $display("Mismatch sample 89: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1566727; @(posedge clk); #1;
    if(data_out !== -24'sd712148) begin $display("Mismatch sample 90: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3701318; @(posedge clk); #1;
    if(data_out !== -24'sd984790) begin $display("Mismatch sample 91: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd186833; @(posedge clk); #1;
    if(data_out !== -24'sd1258163) begin $display("Mismatch sample 92: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3782404; @(posedge clk); #1;
    if(data_out !== -24'sd1434820) begin $display("Mismatch sample 93: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3215403; @(posedge clk); #1;
    if(data_out !== -24'sd1416651) begin $display("Mismatch sample 94: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd7280754; @(posedge clk); #1;
    if(data_out !== -24'sd1171259) begin $display("Mismatch sample 95: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1357419; @(posedge clk); #1;
    if(data_out !== -24'sd838796) begin $display("Mismatch sample 96: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4197872; @(posedge clk); #1;
    if(data_out !== -24'sd560404) begin $display("Mismatch sample 97: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd5420913; @(posedge clk); #1;
    if(data_out !== -24'sd425867) begin $display("Mismatch sample 98: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1809570; @(posedge clk); #1;
    if(data_out !== -24'sd360998) begin $display("Mismatch sample 99: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1078169; @(posedge clk); #1;
    if(data_out !== -24'sd372458) begin $display("Mismatch sample 100: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4507684; @(posedge clk); #1;
    if(data_out !== -24'sd460525) begin $display("Mismatch sample 101: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3110195; @(posedge clk); #1;
    if(data_out !== -24'sd497783) begin $display("Mismatch sample 102: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd8046346; @(posedge clk); #1;
    if(data_out !== -24'sd474306) begin $display("Mismatch sample 103: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1385507; @(posedge clk); #1;
    if(data_out !== -24'sd410476) begin $display("Mismatch sample 104: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd7656552; @(posedge clk); #1;
    if(data_out !== -24'sd308403) begin $display("Mismatch sample 105: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4802025; @(posedge clk); #1;
    if(data_out !== -24'sd122982) begin $display("Mismatch sample 106: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1740938; @(posedge clk); #1;
    if(data_out !== 24'sd146234) begin $display("Mismatch sample 107: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2537887; @(posedge clk); #1;
    if(data_out !== 24'sd293795) begin $display("Mismatch sample 108: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd316340; @(posedge clk); #1;
    if(data_out !== 24'sd199870) begin $display("Mismatch sample 109: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4356923; @(posedge clk); #1;
    if(data_out !== -24'sd134629) begin $display("Mismatch sample 110: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd5523618; @(posedge clk); #1;
    if(data_out !== -24'sd587758) begin $display("Mismatch sample 111: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6600485; @(posedge clk); #1;
    if(data_out !== -24'sd926306) begin $display("Mismatch sample 112: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd2227776; @(posedge clk); #1;
    if(data_out !== -24'sd1033226) begin $display("Mismatch sample 113: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4825953; @(posedge clk); #1;
    if(data_out !== -24'sd939238) begin $display("Mismatch sample 114: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd2097522; @(posedge clk); #1;
    if(data_out !== -24'sd683021) begin $display("Mismatch sample 115: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3902935; @(posedge clk); #1;
    if(data_out !== -24'sd423626) begin $display("Mismatch sample 116: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1698444; @(posedge clk); #1;
    if(data_out !== -24'sd188467) begin $display("Mismatch sample 117: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd114109; @(posedge clk); #1;
    if(data_out !== 24'sd54436) begin $display("Mismatch sample 118: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4850374; @(posedge clk); #1;
    if(data_out !== 24'sd209823) begin $display("Mismatch sample 119: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd6161555; @(posedge clk); #1;
    if(data_out !== 24'sd236594) begin $display("Mismatch sample 120: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8070632; @(posedge clk); #1;
    if(data_out !== 24'sd131804) begin $display("Mismatch sample 121: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7491623; @(posedge clk); #1;
    if(data_out !== -24'sd55607) begin $display("Mismatch sample 122: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd290982; @(posedge clk); #1;
    if(data_out !== -24'sd234415) begin $display("Mismatch sample 123: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1906417; @(posedge clk); #1;
    if(data_out !== -24'sd264754) begin $display("Mismatch sample 124: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd6937700; @(posedge clk); #1;
    if(data_out !== -24'sd215387) begin $display("Mismatch sample 125: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8055371; @(posedge clk); #1;
    if(data_out !== -24'sd87390) begin $display("Mismatch sample 126: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd5880622; @(posedge clk); #1;
    if(data_out !== 24'sd195078) begin $display("Mismatch sample 127: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd546469) begin $display("Mismatch sample 128: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd803885) begin $display("Mismatch sample 129: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd777390) begin $display("Mismatch sample 130: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd595894) begin $display("Mismatch sample 131: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd522043) begin $display("Mismatch sample 132: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd601577) begin $display("Mismatch sample 133: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd689739) begin $display("Mismatch sample 134: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd666600) begin $display("Mismatch sample 135: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd532932) begin $display("Mismatch sample 136: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd358278) begin $display("Mismatch sample 137: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd205524) begin $display("Mismatch sample 138: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd100841) begin $display("Mismatch sample 139: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd41461) begin $display("Mismatch sample 140: %d",data_out); errors=errors+1; end
    @(negedge clk);
    rst_n=0; data_in=24'sd8388607; @(posedge clk); #1;
    if(data_out !== 0) errors=errors+1;
    @(negedge clk); rst_n=1;
    data_in=24'sd8388607; @(posedge clk); #1;
    if(data_out !== 24'sd0) begin $display("Mismatch post-reset sample 0: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd8388608; @(posedge clk); #1;
    if(data_out !== 24'sd0) begin $display("Mismatch post-reset sample 1: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd0) begin $display("Mismatch post-reset sample 2: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1; @(posedge clk); #1;
    if(data_out !== 24'sd0) begin $display("Mismatch post-reset sample 3: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1; @(posedge clk); #1;
    if(data_out !== 24'sd0) begin $display("Mismatch post-reset sample 4: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4645820; @(posedge clk); #1;
    if(data_out !== 24'sd109051) begin $display("Mismatch post-reset sample 5: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4425005; @(posedge clk); #1;
    if(data_out !== 24'sd211551) begin $display("Mismatch post-reset sample 6: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd7585258; @(posedge clk); #1;
    if(data_out !== 24'sd185548) begin $display("Mismatch post-reset sample 7: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd594557; @(posedge clk); #1;
    if(data_out !== 24'sd52878) begin $display("Mismatch post-reset sample 8: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7844280; @(posedge clk); #1;
    if(data_out !== -24'sd78872) begin $display("Mismatch post-reset sample 9: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4868535; @(posedge clk); #1;
    if(data_out !== -24'sd201977) begin $display("Mismatch post-reset sample 10: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7510954; @(posedge clk); #1;
    if(data_out !== -24'sd371947) begin $display("Mismatch post-reset sample 11: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2058495; @(posedge clk); #1;
    if(data_out !== -24'sd647205) begin $display("Mismatch post-reset sample 12: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1705068; @(posedge clk); #1;
    if(data_out !== -24'sd917379) begin $display("Mismatch post-reset sample 13: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1062107; @(posedge clk); #1;
    if(data_out !== -24'sd922795) begin $display("Mismatch post-reset sample 14: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4987778; @(posedge clk); #1;
    if(data_out !== -24'sd559191) begin $display("Mismatch post-reset sample 15: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1457723; @(posedge clk); #1;
    if(data_out !== 24'sd68463) begin $display("Mismatch post-reset sample 16: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4241312; @(posedge clk); #1;
    if(data_out !== 24'sd640961) begin $display("Mismatch post-reset sample 17: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6021183; @(posedge clk); #1;
    if(data_out !== 24'sd933649) begin $display("Mismatch post-reset sample 18: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd6721390; @(posedge clk); #1;
    if(data_out !== 24'sd941097) begin $display("Mismatch post-reset sample 19: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd5625545; @(posedge clk); #1;
    if(data_out !== 24'sd714708) begin $display("Mismatch post-reset sample 20: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3692; @(posedge clk); #1;
    if(data_out !== 24'sd354891) begin $display("Mismatch post-reset sample 21: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd2306019; @(posedge clk); #1;
    if(data_out !== -24'sd45988) begin $display("Mismatch post-reset sample 22: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7853030; @(posedge clk); #1;
    if(data_out !== -24'sd290912) begin $display("Mismatch post-reset sample 23: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6838797; @(posedge clk); #1;
    if(data_out !== -24'sd384565) begin $display("Mismatch post-reset sample 24: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1985528; @(posedge clk); #1;
    if(data_out !== -24'sd336711) begin $display("Mismatch post-reset sample 25: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6834119; @(posedge clk); #1;
    if(data_out !== -24'sd190889) begin $display("Mismatch post-reset sample 26: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4005254; @(posedge clk); #1;
    if(data_out !== 24'sd4792) begin $display("Mismatch post-reset sample 27: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8064913; @(posedge clk); #1;
    if(data_out !== 24'sd278057) begin $display("Mismatch post-reset sample 28: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd754620; @(posedge clk); #1;
    if(data_out !== 24'sd654470) begin $display("Mismatch post-reset sample 29: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2257941; @(posedge clk); #1;
    if(data_out !== 24'sd974610) begin $display("Mismatch post-reset sample 30: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6402126; @(posedge clk); #1;
    if(data_out !== 24'sd1157296) begin $display("Mismatch post-reset sample 31: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4324181; @(posedge clk); #1;
    if(data_out !== 24'sd1130885) begin $display("Mismatch post-reset sample 32: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3773616; @(posedge clk); #1;
    if(data_out !== 24'sd1016240) begin $display("Mismatch post-reset sample 33: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3563441; @(posedge clk); #1;
    if(data_out !== 24'sd919249) begin $display("Mismatch post-reset sample 34: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4362594; @(posedge clk); #1;
    if(data_out !== 24'sd805063) begin $display("Mismatch post-reset sample 35: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd5202265; @(posedge clk); #1;
    if(data_out !== 24'sd707793) begin $display("Mismatch post-reset sample 36: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd959772; @(posedge clk); #1;
    if(data_out !== 24'sd705292) begin $display("Mismatch post-reset sample 37: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd2844915; @(posedge clk); #1;
    if(data_out !== 24'sd810241) begin $display("Mismatch post-reset sample 38: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3086774; @(posedge clk); #1;
    if(data_out !== 24'sd865303) begin $display("Mismatch post-reset sample 39: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2636387; @(posedge clk); #1;
    if(data_out !== 24'sd816994) begin $display("Mismatch post-reset sample 40: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7703128; @(posedge clk); #1;
    if(data_out !== 24'sd767572) begin $display("Mismatch post-reset sample 41: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1968599; @(posedge clk); #1;
    if(data_out !== 24'sd744462) begin $display("Mismatch post-reset sample 42: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2089654; @(posedge clk); #1;
    if(data_out !== 24'sd726992) begin $display("Mismatch post-reset sample 43: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4854751; @(posedge clk); #1;
    if(data_out !== 24'sd716098) begin $display("Mismatch post-reset sample 44: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd387316; @(posedge clk); #1;
    if(data_out !== 24'sd657778) begin $display("Mismatch post-reset sample 45: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8185595; @(posedge clk); #1;
    if(data_out !== 24'sd620742) begin $display("Mismatch post-reset sample 46: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd5353502; @(posedge clk); #1;
    if(data_out !== 24'sd658188) begin $display("Mismatch post-reset sample 47: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd5318427; @(posedge clk); #1;
    if(data_out !== 24'sd685911) begin $display("Mismatch post-reset sample 48: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1586432; @(posedge clk); #1;
    if(data_out !== 24'sd551775) begin $display("Mismatch post-reset sample 49: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3693473; @(posedge clk); #1;
    if(data_out !== 24'sd262907) begin $display("Mismatch post-reset sample 50: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd5711410; @(posedge clk); #1;
    if(data_out !== 24'sd71914) begin $display("Mismatch post-reset sample 51: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd667671; @(posedge clk); #1;
    if(data_out !== 24'sd168303) begin $display("Mismatch post-reset sample 52: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd8234956; @(posedge clk); #1;
    if(data_out !== 24'sd374557) begin $display("Mismatch post-reset sample 53: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4597251; @(posedge clk); #1;
    if(data_out !== 24'sd477604) begin $display("Mismatch post-reset sample 54: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7279494; @(posedge clk); #1;
    if(data_out !== 24'sd381300) begin $display("Mismatch post-reset sample 55: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1026771; @(posedge clk); #1;
    if(data_out !== 24'sd237319) begin $display("Mismatch post-reset sample 56: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd510808; @(posedge clk); #1;
    if(data_out !== 24'sd167115) begin $display("Mismatch post-reset sample 57: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7114727; @(posedge clk); #1;
    if(data_out !== 24'sd58249) begin $display("Mismatch post-reset sample 58: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2667494; @(posedge clk); #1;
    if(data_out !== -24'sd84852) begin $display("Mismatch post-reset sample 59: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3812529; @(posedge clk); #1;
    if(data_out !== -24'sd77490) begin $display("Mismatch post-reset sample 60: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8044124; @(posedge clk); #1;
    if(data_out !== 24'sd101669) begin $display("Mismatch post-reset sample 61: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8341003; @(posedge clk); #1;
    if(data_out !== 24'sd294316) begin $display("Mismatch post-reset sample 62: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2038802; @(posedge clk); #1;
    if(data_out !== 24'sd460977) begin $display("Mismatch post-reset sample 63: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1484171; @(posedge clk); #1;
    if(data_out !== 24'sd556956) begin $display("Mismatch post-reset sample 64: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4183728; @(posedge clk); #1;
    if(data_out !== 24'sd592821) begin $display("Mismatch post-reset sample 65: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7793775; @(posedge clk); #1;
    if(data_out !== 24'sd681935) begin $display("Mismatch post-reset sample 66: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd8114430; @(posedge clk); #1;
    if(data_out !== 24'sd928273) begin $display("Mismatch post-reset sample 67: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1188473; @(posedge clk); #1;
    if(data_out !== 24'sd1184262) begin $display("Mismatch post-reset sample 68: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1578620; @(posedge clk); #1;
    if(data_out !== 24'sd1227125) begin $display("Mismatch post-reset sample 69: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd2385683; @(posedge clk); #1;
    if(data_out !== 24'sd957681) begin $display("Mismatch post-reset sample 70: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3457366; @(posedge clk); #1;
    if(data_out !== 24'sd612711) begin $display("Mismatch post-reset sample 71: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd7665475; @(posedge clk); #1;
    if(data_out !== 24'sd298554) begin $display("Mismatch post-reset sample 72: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7254776; @(posedge clk); #1;
    if(data_out !== 24'sd45667) begin $display("Mismatch post-reset sample 73: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd7022089; @(posedge clk); #1;
    if(data_out !== -24'sd144578) begin $display("Mismatch post-reset sample 74: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd692502; @(posedge clk); #1;
    if(data_out !== -24'sd223186) begin $display("Mismatch post-reset sample 75: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd995007; @(posedge clk); #1;
    if(data_out !== -24'sd142079) begin $display("Mismatch post-reset sample 76: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6453676; @(posedge clk); #1;
    if(data_out !== -24'sd61568) begin $display("Mismatch post-reset sample 77: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4871909; @(posedge clk); #1;
    if(data_out !== -24'sd702) begin $display("Mismatch post-reset sample 78: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd5485634; @(posedge clk); #1;
    if(data_out !== -24'sd13040) begin $display("Mismatch post-reset sample 79: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1409019; @(posedge clk); #1;
    if(data_out !== -24'sd110771) begin $display("Mismatch post-reset sample 80: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2723424; @(posedge clk); #1;
    if(data_out !== -24'sd246048) begin $display("Mismatch post-reset sample 81: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3700863; @(posedge clk); #1;
    if(data_out !== -24'sd254811) begin $display("Mismatch post-reset sample 82: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4805678; @(posedge clk); #1;
    if(data_out !== -24'sd163936) begin $display("Mismatch post-reset sample 83: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd5416695; @(posedge clk); #1;
    if(data_out !== -24'sd154434) begin $display("Mismatch post-reset sample 84: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd6877484; @(posedge clk); #1;
    if(data_out !== -24'sd289582) begin $display("Mismatch post-reset sample 85: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4772829; @(posedge clk); #1;
    if(data_out !== -24'sd492345) begin $display("Mismatch post-reset sample 86: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4381914; @(posedge clk); #1;
    if(data_out !== -24'sd584373) begin $display("Mismatch post-reset sample 87: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4136883; @(posedge clk); #1;
    if(data_out !== -24'sd560379) begin $display("Mismatch post-reset sample 88: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1967432; @(posedge clk); #1;
    if(data_out !== -24'sd561501) begin $display("Mismatch post-reset sample 89: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1566727; @(posedge clk); #1;
    if(data_out !== -24'sd712148) begin $display("Mismatch post-reset sample 90: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3701318; @(posedge clk); #1;
    if(data_out !== -24'sd984790) begin $display("Mismatch post-reset sample 91: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd186833; @(posedge clk); #1;
    if(data_out !== -24'sd1258163) begin $display("Mismatch post-reset sample 92: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3782404; @(posedge clk); #1;
    if(data_out !== -24'sd1434820) begin $display("Mismatch post-reset sample 93: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3215403; @(posedge clk); #1;
    if(data_out !== -24'sd1416651) begin $display("Mismatch post-reset sample 94: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd7280754; @(posedge clk); #1;
    if(data_out !== -24'sd1171259) begin $display("Mismatch post-reset sample 95: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1357419; @(posedge clk); #1;
    if(data_out !== -24'sd838796) begin $display("Mismatch post-reset sample 96: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4197872; @(posedge clk); #1;
    if(data_out !== -24'sd560404) begin $display("Mismatch post-reset sample 97: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd5420913; @(posedge clk); #1;
    if(data_out !== -24'sd425867) begin $display("Mismatch post-reset sample 98: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1809570; @(posedge clk); #1;
    if(data_out !== -24'sd360998) begin $display("Mismatch post-reset sample 99: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1078169; @(posedge clk); #1;
    if(data_out !== -24'sd372458) begin $display("Mismatch post-reset sample 100: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4507684; @(posedge clk); #1;
    if(data_out !== -24'sd460525) begin $display("Mismatch post-reset sample 101: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd3110195; @(posedge clk); #1;
    if(data_out !== -24'sd497783) begin $display("Mismatch post-reset sample 102: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd8046346; @(posedge clk); #1;
    if(data_out !== -24'sd474306) begin $display("Mismatch post-reset sample 103: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1385507; @(posedge clk); #1;
    if(data_out !== -24'sd410476) begin $display("Mismatch post-reset sample 104: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd7656552; @(posedge clk); #1;
    if(data_out !== -24'sd308403) begin $display("Mismatch post-reset sample 105: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4802025; @(posedge clk); #1;
    if(data_out !== -24'sd122982) begin $display("Mismatch post-reset sample 106: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1740938; @(posedge clk); #1;
    if(data_out !== 24'sd146234) begin $display("Mismatch post-reset sample 107: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd2537887; @(posedge clk); #1;
    if(data_out !== 24'sd293795) begin $display("Mismatch post-reset sample 108: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd316340; @(posedge clk); #1;
    if(data_out !== 24'sd199870) begin $display("Mismatch post-reset sample 109: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4356923; @(posedge clk); #1;
    if(data_out !== -24'sd134629) begin $display("Mismatch post-reset sample 110: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd5523618; @(posedge clk); #1;
    if(data_out !== -24'sd587758) begin $display("Mismatch post-reset sample 111: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd6600485; @(posedge clk); #1;
    if(data_out !== -24'sd926306) begin $display("Mismatch post-reset sample 112: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd2227776; @(posedge clk); #1;
    if(data_out !== -24'sd1033226) begin $display("Mismatch post-reset sample 113: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd4825953; @(posedge clk); #1;
    if(data_out !== -24'sd939238) begin $display("Mismatch post-reset sample 114: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd2097522; @(posedge clk); #1;
    if(data_out !== -24'sd683021) begin $display("Mismatch post-reset sample 115: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd3902935; @(posedge clk); #1;
    if(data_out !== -24'sd423626) begin $display("Mismatch post-reset sample 116: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd1698444; @(posedge clk); #1;
    if(data_out !== -24'sd188467) begin $display("Mismatch post-reset sample 117: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd114109; @(posedge clk); #1;
    if(data_out !== 24'sd54436) begin $display("Mismatch post-reset sample 118: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd4850374; @(posedge clk); #1;
    if(data_out !== 24'sd209823) begin $display("Mismatch post-reset sample 119: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd6161555; @(posedge clk); #1;
    if(data_out !== 24'sd236594) begin $display("Mismatch post-reset sample 120: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8070632; @(posedge clk); #1;
    if(data_out !== 24'sd131804) begin $display("Mismatch post-reset sample 121: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd7491623; @(posedge clk); #1;
    if(data_out !== -24'sd55607) begin $display("Mismatch post-reset sample 122: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd290982; @(posedge clk); #1;
    if(data_out !== -24'sd234415) begin $display("Mismatch post-reset sample 123: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd1906417; @(posedge clk); #1;
    if(data_out !== -24'sd264754) begin $display("Mismatch post-reset sample 124: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=-24'sd6937700; @(posedge clk); #1;
    if(data_out !== -24'sd215387) begin $display("Mismatch post-reset sample 125: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd8055371; @(posedge clk); #1;
    if(data_out !== -24'sd87390) begin $display("Mismatch post-reset sample 126: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd5880622; @(posedge clk); #1;
    if(data_out !== 24'sd195078) begin $display("Mismatch post-reset sample 127: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd546469) begin $display("Mismatch post-reset sample 128: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd803885) begin $display("Mismatch post-reset sample 129: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd777390) begin $display("Mismatch post-reset sample 130: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd595894) begin $display("Mismatch post-reset sample 131: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd522043) begin $display("Mismatch post-reset sample 132: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd601577) begin $display("Mismatch post-reset sample 133: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd689739) begin $display("Mismatch post-reset sample 134: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd666600) begin $display("Mismatch post-reset sample 135: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd532932) begin $display("Mismatch post-reset sample 136: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd358278) begin $display("Mismatch post-reset sample 137: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd205524) begin $display("Mismatch post-reset sample 138: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd100841) begin $display("Mismatch post-reset sample 139: %d",data_out); errors=errors+1; end
    @(negedge clk);
    data_in=24'sd0; @(posedge clk); #1;
    if(data_out !== 24'sd41461) begin $display("Mismatch post-reset sample 140: %d",data_out); errors=errors+1; end
    @(negedge clk);
    $display("TIMING: FO1/SO2, capture counts as cycle 1; total 6 cycles; edge offset 5; model delay 0");
    $display("Golden vector saturation count per run: 0");
    if(errors==0) $display("PASS: four-port SOS, continuous samples, reset, latency");
    else $fatal(1,"FAIL: %d mismatches",errors);
    $finish;
  end
endmodule
