# False path between clock domains
set_false_path -from [get_clocks -of_objects [get_pins IPbus_slaves/FREQ_COUNTER/clk320MHzIn]] -to   [get_clocks -of_objects [get_pins IPbus_slaves/FREQ_COUNTER/clkIPBus]]
set_false_path -from [get_clocks -of_objects [get_pins IPbus_slaves/FREQ_COUNTER/clkIPBus]] -to   [get_clocks -of_objects [get_pins IPbus_slaves/FREQ_COUNTER/clk320MHzIn]]

# False path for the clock input
set_false_path -through [get_pins IPbus_slaves/FREQ_COUNTER/clkMon] -to [get_clocks -of_objects [get_pins IPbus_slaves/FREQ_COUNTER/clk320MHzIn]]


