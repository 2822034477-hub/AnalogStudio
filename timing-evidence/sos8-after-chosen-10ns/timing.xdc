create_clock -name sample_clk -period 10 [get_ports clk]
set_clock_uncertainty -setup 0.200 [get_clocks sample_clk]
set_clock_uncertainty -hold 0.050 [get_clocks sample_clk]
