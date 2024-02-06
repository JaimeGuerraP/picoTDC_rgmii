create_clock -period 25.000 -name 40mhz_clock -waveform {0.000 12.500} [get_ports clk]

set_false_path -from clk -to pll_clk640
# TODO this should have been replaced by the constraint before
# set_false_path -from [get_cells {gen_delaylines[*].line/gen_taps[*].tap/tap_fast_reg}] -to [get_cells {gen_delaylines[*].line/gen_taps[*].tap/tap_slow_reg}]
# set_false_path -from [get_cells {gen_delaylines[*].line/tap/tap_fast_reg}] -to [get_cells {gen_delaylines[*].line/tap/tap_slow_reg}]
