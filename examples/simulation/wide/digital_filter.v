`timescale 1ns/1ps
// AnalogStudio bounded direct-form-I filter. Generated Verilog-2001.
// H(z) = B(z^-1)/A(z^-1); coefficient arrays use ascending powers.
// b = [1.75,-0.5,0.25]; a = [1,-0.25,0.1]; sample rate = 48000 Hz.
// Quantized b integers = [234881024,-67108864,33554432]; feedback a integers = [-33554432,13421773].
// Signed signals have 20 fractional bits; coefficients have 27.
// y[n] = 1.75 x[n] − 0.5 x[n-1] + 0.25 x[n-2] + 0.25 y[n-1] − 0.1 y[n-2]
// Synchronous active-high reset clears every delay and output, including out_valid.
// Assert reset before sending the first valid input sample.
// Each rising edge with in_valid accepts one sample; out_valid and y_out update
// immediately after that edge. A downstream clocked consumer sees it at the next edge.
// No ready/backpressure. Delays advance only on in_valid; gaps pause sample time.
// DFI feedback uses the saturated output, so clipping changes filter dynamics.
// Rounding: nearest, exact ties away from zero. Output saturates to its signed width.
// Accumulator bound: 58 bits required; 58 provided. No intermediate overflow.
// No FPGA timing, resource, synthesis, or hardware verification is claimed.
module digital_filter(
  input wire clk, input wire rst, input wire in_valid,
  input wire signed [23:0] x_in,
  output reg out_valid, output reg signed [23:0] y_out
);
  reg signed [23:0] x1;
  reg signed [23:0] x2;
  reg signed [23:0] y1;
  reg signed [23:0] y2;
  localparam signed [29:0] C_b0 = 30'sd234881024;
  wire signed [53:0] P_b0 = $signed(x_in) * $signed(C_b0);
  wire signed [57:0] E_b0 = {{4{P_b0[53]}}, P_b0};
  localparam signed [29:0] C_b1 = -30'sd67108864;
  wire signed [53:0] P_b1 = $signed(x1) * $signed(C_b1);
  wire signed [57:0] E_b1 = {{4{P_b1[53]}}, P_b1};
  localparam signed [29:0] C_b2 = 30'sd33554432;
  wire signed [53:0] P_b2 = $signed(x2) * $signed(C_b2);
  wire signed [57:0] E_b2 = {{4{P_b2[53]}}, P_b2};
  localparam signed [29:0] C_a1 = -30'sd33554432;
  wire signed [53:0] P_a1 = $signed(y1) * $signed(C_a1);
  wire signed [57:0] E_a1 = {{4{P_a1[53]}}, P_a1};
  localparam signed [29:0] C_a2 = 30'sd13421773;
  wire signed [53:0] P_a2 = $signed(y2) * $signed(C_a2);
  wire signed [57:0] E_a2 = {{4{P_a2[53]}}, P_a2};
  reg signed [57:0] acc;
  reg signed [58:0] ext, rounded;
  reg signed [23:0] next_y;
  always @* begin
    acc = E_b0 + E_b1 + E_b2 - E_a1 - E_a2;
    ext = {acc[57], acc};
    if (ext < 0) rounded = -(((-ext) + 59'sd67108864) >>> 27);
    else rounded = (ext + 59'sd67108864) >>> 27;
    if (rounded > 59'sd8388607) next_y = 24'sd8388607;
    else if (rounded < -59'sd8388608) next_y = -24'sd8388608;
    else next_y = rounded[23:0];
  end
  always @(posedge clk) begin
    if (rst) begin
      out_valid <= 1'b0; y_out <= 0;
      x1 <= 0;
      x2 <= 0;
      y1 <= 0;
      y2 <= 0;
    end else begin
      out_valid <= in_valid;
      if (in_valid) begin
        y_out <= next_y;
        x2 <= x1;
        x1 <= x_in;
        y2 <= y1;
        y1 <= next_y;
      end
    end
  end
endmodule
