# Base clock, coming from crystal
create_clock -period 3.125 -name refClkGTX_320M_p [get_ports refClkGTX_320M_p]

# Generated clock for the RX Part
create_generated_clock -source [get_pins highSpeedSerialTXRX_i/GT0_RXUSRCLK_OUT] -divide_by 8 -name clk40MHz_RX [get_ports clk40MHz_RX]

# Constraints from Julien
set_multicycle_path 3 -from [get_pins {dpUpLink/uplinkFrame_pipelined_s_reg[*]/C}] -setup 
set_multicycle_path 2 -from [get_pins {dpUpLink/uplinkFrame_pipelined_s_reg[*]/C}] -hold 
set_multicycle_path 3 -from [get_pins -hierarchical -filter {NAME =~ dpUpLink*descrambledData_reg[*]/C}] -setup 
set_multicycle_path 2 -from [get_pins -hierarchical -filter {NAME =~ dpUpLink*descrambledData_reg[*]/C}] -hold

