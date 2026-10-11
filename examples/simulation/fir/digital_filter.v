`timescale 1ns/1ps
// AnalogStudio bounded direct-form-I filter. Generated Verilog-2001.
// H(z) = B(z^-1)/A(z^-1); coefficient arrays use ascending powers.
// b = [0.25,0.5,0.25]; a = [1]; sample rate = 48000 Hz.
// Quantized b integers = [8192,16384,8192]; feedback a integers = [].
// Signed signals have 14 fractional bits; coefficients have 15.
// y[n] = 0.25 x[n] + 0.5 x[n-1] + 0.25 x[n-2]
// Synchronous active-high reset clears every delay and output, including out_valid.
// Assert reset before sending the first valid input sample.
// Each rising edge with in_valid accepts one sample; out_valid and y_out update
// immediately after that edge. A downstream clocked consumer sees it at the next edge.
// No ready/backpressure. Delays advance only on in_valid; gaps pause sample time.
// DFI feedback uses the saturated output, so clipping changes filter dynamics.
// Rounding: nearest, exact ties away from zero. Output saturates to its signed width.
// Accumulator bound: 37 bits required; 40 provided. No intermediate overflow.
// No FPGA timing, resource, synthesis, or hardware verification is claimed.
module digital_filter(
  input wire clk, input wire rst, input wire in_valid,
  input wire signed [15:0] x_in,
  output reg out_valid, output reg signed [15:0] y_out
);
  reg signed [15:0] x1;
  reg signed [15:0] x2;
  localparam signed [17:0] C_b0 = 18'sd8192;
  wire signed [33:0] P_b0 = $signed(x_in) * $signed(C_b0);
  wire signed [39:0] E_b0 = {{6{P_b0[33]}}, P_b0};
  localparam signed [17:0] C_b1 = 18'sd16384;
  wire signed [33:0] P_b1 = $signed(x1) * $signed(C_b1);
  wire signed [39:0] E_b1 = {{6{P_b1[33]}}, P_b1};
  localparam signed [17:0] C_b2 = 18'sd8192;
  wire signed [33:0] P_b2 = $signed(x2) * $signed(C_b2);
  wire signed [39:0] E_b2 = {{6{P_b2[33]}}, P_b2};
  reg signed [39:0] acc;
  reg signed [40:0] ext, rounded;
  reg signed [15:0] next_y;
  always @* begin
    acc = E_b0 + E_b1 + E_b2;
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
    end else begin
      out_valid <= in_valid;
      if (in_valid) begin
        y_out <= next_y;
        x2 <= x1;
        x1 <= x_in;
      end
    end
  end
endmodule
