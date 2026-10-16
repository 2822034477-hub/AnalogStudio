`timescale 1ns/1ps
module digital_filter #(
  parameter integer IN_WIDTH = 16
) (
  input clk, // Sample clock: 48000 Hz; one input per rising edge.
  input rst_n,
  input signed [IN_WIDTH-1:0] data_in,
  output reg signed [IN_WIDTH-1:0] data_out
);
  localparam integer COEFF_WIDTH = 18, COEFF_FRAC = 15;
  localparam integer DATA_FRAC = 14, SECTION_WIDTH = IN_WIDTH + 0;
  localparam integer ACC_WIDTH = IN_WIDTH + 24;
  localparam integer FILTER_CYCLES = 1, MODEL_DELAY = 8;
  localparam integer LATENCY_CYCLES = 9, EDGE_OFFSET = 8;
  // Capture edge is cycle 1; output follows at capture + EDGE_OFFSET edges.
  generate if (IN_WIDTH < 8 || IN_WIDTH > 24 || DATA_FRAC > IN_WIDTH-2 || SECTION_WIDTH > 32 || ACC_WIDTH > 64) begin : bad_width
    INVALID_IN_WIDTH_CONFIGURATION invalid_configuration();
  end endgenerate
  reg signed [IN_WIDTH-1:0] delay_line [0:MODEL_DELAY-1];
  integer d;
  always @(posedge clk) begin
    if (!rst_n) for (d=0; d<MODEL_DELAY; d=d+1) delay_line[d] <= 0;
    else begin
      delay_line[0] <= data_in;
      for (d=1; d<MODEL_DELAY; d=d+1) delay_line[d] <= delay_line[d-1];
    end
  end
  wire signed [IN_WIDTH-1:0] s0_out;
  digital_filter_fo #(.IW(IN_WIDTH), .OW(IN_WIDTH), .CW(COEFF_WIDTH), .CF(COEFF_FRAC),
    .AW(ACC_WIDTH), .NEAREST(1), .B0(18'sd24576), .B1(18'sd0), .A1(18'sd0))
    s0(.clk(clk), .rst_n(rst_n), .data_in(delay_line[MODEL_DELAY-1]), .data_out(s0_out));
  always @* data_out = s0_out;
endmodule

module digital_filter_fo #(
  parameter integer IW=16, OW=16, CW=18, CF=15, AW=40, NEAREST=1,
  parameter signed [CW-1:0] B0=0, B1=0, A1=0
) (input clk, input rst_n, input signed [IW-1:0] data_in, output wire signed [OW-1:0] data_out);
  reg signed [IW-1:0] x1;
  reg signed [OW-1:0] y1;
  wire signed [AW-1:0] acc;
  localparam integer RW = AW-CF+1;
  wire signed [RW-1:0] integral = {acc[AW-1], acc[AW-1:CF]};
  wire increment;
  generate if (!NEAREST || CF==0) begin : truncation
    assign increment = 1'b0;
  end else if (CF==1) begin : one_fraction_bit
    assign increment = acc[0] & ~acc[AW-1];
  end else begin : rounding_bits
    assign increment = acc[CF-1] & (~acc[AW-1] | (|acc[CF-2:0]));
  end endgenerate
  (* keep = "true" *) wire signed [RW-1:0] incremented = integral + 1'b1;
  wire over_floor = (integral[RW-1:OW-1] != {(RW-OW+1){integral[RW-1]}});
  wire over_ceil = (incremented[RW-1:OW-1] != {(RW-OW+1){incremented[RW-1]}});
  wire signed [OW-1:0] floor_y = over_floor ? {integral[RW-1], {(OW-1){~integral[RW-1]}}} : integral[OW-1:0];
  wire signed [OW-1:0] ceil_y = over_ceil ? {incremented[RW-1], {(OW-1){~incremented[RW-1]}}} : incremented[OW-1:0];
  wire signed [OW-1:0] next_y = increment ? ceil_y : floor_y;
  (* use_dsp = "yes" *) wire signed [IW+CW-1:0] P_B0 = $signed(data_in) * $signed(B0);
  wire signed [AW-1:0] E_B0 = {{(AW-(IW+CW)){P_B0[IW+CW-1]}}, P_B0};
  (* use_dsp = "yes" *) wire signed [IW+CW-1:0] P_B1 = $signed(x1) * $signed(B1);
  wire signed [AW-1:0] E_B1 = {{(AW-(IW+CW)){P_B1[IW+CW-1]}}, P_B1};
  (* use_dsp = "yes" *) wire signed [OW+CW-1:0] P_A1 = $signed(y1) * $signed(A1);
  wire signed [AW-1:0] E_A1 = {{(AW-(OW+CW)){P_A1[OW+CW-1]}}, P_A1};
  wire [AW-1:0] sum0 = (E_B0) ^ (E_B1) ^ (~E_A1);
  wire [AW-1:0] carry0 = (((E_B0) & (E_B1)) | ((E_B0) & (~E_A1)) | ((E_B1) & (~E_A1))) << 1;
  wire [AW-1:0] sum1 = (sum0) ^ (carry0) ^ ({{(AW-2){1'b0}},2'd1});
  wire [AW-1:0] carry1 = (((sum0) & (carry0)) | ((sum0) & ({{(AW-2){1'b0}},2'd1})) | ((carry0) & ({{(AW-2){1'b0}},2'd1}))) << 1;
  assign acc = $signed(sum1) + $signed(carry1);
  always @(posedge clk) begin
    if (!rst_n) begin
      x1 <= 0; y1 <= 0;
    end else begin
      x1 <= data_in; y1 <= next_y;
    end
  end
  assign data_out = y1; // 1 registered cycle; feedback uses y1/y2 histories.
endmodule
