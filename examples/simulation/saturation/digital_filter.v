`timescale 1ns/1ps
// AnalogStudio bounded direct-form-I filter. Generated Verilog-2001.
// H(z) = B(z^-1)/A(z^-1); coefficient arrays use ascending powers.
// b = [3]; a = [1]; sample rate = 48000 Hz.
// Quantized b integers = [6]; feedback a integers = [].
// Signed signals have 0 fractional bits; coefficients have 1.
// y[n] = 3 x[n]
// Synchronous active-high reset clears every delay and output, including out_valid.
// Assert reset before sending the first valid input sample.
// Each rising edge with in_valid accepts one sample; out_valid and y_out update
// immediately after that edge. A downstream clocked consumer sees it at the next edge.
// No ready/backpressure. Delays advance only on in_valid; gaps pause sample time.
// DFI feedback uses the saturated output, so clipping changes filter dynamics.
// Rounding: nearest, exact ties away from zero. Output saturates to its signed width.
// Accumulator bound: 17 bits required; 20 provided. No intermediate overflow.
// No FPGA timing, resource, synthesis, or hardware verification is claimed.
module digital_filter(
  input wire clk, input wire rst, input wire in_valid,
  input wire signed [7:0] x_in,
  output reg out_valid, output reg signed [7:0] y_out
);
  localparam signed [7:0] C_b0 = 8'sd6;
  wire signed [15:0] P_b0 = $signed(x_in) * $signed(C_b0);
  wire signed [19:0] E_b0 = {{4{P_b0[15]}}, P_b0};
  reg signed [19:0] acc;
  reg signed [20:0] ext, rounded;
  reg signed [7:0] next_y;
  always @* begin
    acc = E_b0;
    ext = {acc[19], acc};
    if (ext < 0) rounded = -(((-ext) + 21'sd1) >>> 1);
    else rounded = (ext + 21'sd1) >>> 1;
    if (rounded > 21'sd127) next_y = 8'sd127;
    else if (rounded < -21'sd128) next_y = -8'sd128;
    else next_y = rounded[7:0];
  end
  always @(posedge clk) begin
    if (rst) begin
      out_valid <= 1'b0; y_out <= 0;
    end else begin
      out_valid <= in_valid;
      if (in_valid) begin
        y_out <= next_y;
      end
    end
  end
endmodule
