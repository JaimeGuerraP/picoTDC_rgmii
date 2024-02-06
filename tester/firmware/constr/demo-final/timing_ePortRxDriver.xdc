create_clock -period 25.000 -name clk40MHzIn  [get_ports clk40MHzIn]

# Constraining the False paths between the 40MHz clock and the SERDES and ODELAY clocks
set_false_path -from clk40MHz_toBuf -to clk300MHz_toBuf

