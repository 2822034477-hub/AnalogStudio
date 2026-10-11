`timescale 1ns/1ps
// AnalogStudio bounded direct-form-I filter. Generated Verilog-2001.
// H(z) = B(z^-1)/A(z^-1); coefficient arrays use ascending powers.
// b = [0.9542677669529664,-1.3495384181603733,0.9542677669529664]; a = [1,-1.3435028842544403,0.9024999999999999]; sample rate = 48000 Hz.
// Quantized b integers = [31269,-44222,31269]; feedback a integers = [-44024,29573].
// Signed signals have 14 fractional bits; coefficients have 15.
// y[n] = 0.95426777 x[n] − 1.3495384 x[n-1] + 0.95426777 x[n-2] + 1.3435029 y[n-1] − 0.9025 y[n-2]
// Synchronous active-high reset clears every delay and output, including out_valid.
// Assert reset before sending the first valid input sample.
// Each rising edge with in_valid accepts one sample; out_valid and y_out update
// immediately after that edge. A downstream clocked consumer sees it at the next edge.
// No ready/backpressure. Delays advance only on in_valid; gaps pause sample time.
// DFI feedback uses the saturated output, so clipping changes filter dynamics.
// Rounding: nearest, exact ties away from zero. Output saturates to its signed width.
// Accumulator bound: 38 bits required; 40 provided. No intermediate overflow.
// No FPGA timing, resource, synthesis, or hardware verification is claimed.
module digital_filter(
  input wire clk, input wire rst, input wire in_valid,
  input wire signed [15:0] x_in,
  output reg out_valid, output reg signed [15:0] y_out
);
  reg signed [15:0] x1;
  reg signed [15:0] x2;
  reg signed [15:0] y1;
  reg signed [15:0] y2;
  localparam signed [17:0] C_b0 = 18'sd31269;
  wire signed [33:0] P_b0 = $signed(x_in) * $signed(C_b0);
  wire signed [39:0] E_b0 = {{6{P_b0[33]}}, P_b0};
  localparam signed [17:0] C_b1 = -18'sd44222;
  wire signed [33:0] P_b1 = $signed(x1) * $signed(C_b1);
  wire signed [39:0] E_b1 = {{6{P_b1[33]}}, P_b1};
  localparam signed [17:0] C_b2 = 18'sd31269;
  wire signed [33:0] P_b2 = $signed(x2) * $signed(C_b2);
  wire signed [39:0] E_b2 = {{6{P_b2[33]}}, P_b2};
  localparam signed [17:0] C_a1 = -18'sd44024;
  wire signed [33:0] P_a1 = $signed(y1) * $signed(C_a1);
  wire signed [39:0] E_a1 = {{6{P_a1[33]}}, P_a1};
  localparam signed [17:0] C_a2 = 18'sd29573;
  wire signed [33:0] P_a2 = $signed(y2) * $signed(C_a2);
  wire signed [39:0] E_a2 = {{6{P_a2[33]}}, P_a2};
  reg signed [39:0] acc;
  reg signed [40:0] ext, rounded;
  reg signed [15:0] next_y;
  always @* begin
    acc = E_b0 + E_b1 + E_b2 - E_a1 - E_a2;
    ext = {acc[39], acc};
    if (ext < 0) rounded = -(((-ext) + 41'sd16384) >>> 15);
    else rounded = (ext + 41'sd16384) >>> 15;
    if (rounded > 41'sd32767) next_y = 16'sd32767;
    else if (rounded < -41'sd32768) next_y = -16'sd32768;
    else next_y = rounded[15:0];
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
