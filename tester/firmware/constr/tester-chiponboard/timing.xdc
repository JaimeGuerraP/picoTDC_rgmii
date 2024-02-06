create_clock -period 5.000 -name sysclk [get_ports sysclk_p]

create_clock -period 12.500 -name syncclk [get_ports SYNC_P]

#set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins Infra/clocks/mmcm/CLKOUT1]] -group [get_clocks -of_objects [get_pins IPbus_slaves/TRIGGERING/BUFR_inst/O]]

set_false_path -from [get_pins Infra/clocks/rst_reg/C] -to [get_pins Infra/clocks/rst_ipb_reg/D]
set_false_path -from [get_pins Infra/clocks/rst_reg/C] -to [get_pins Infra/clocks/rst_ipb_ctrl_reg/D]
set_false_path -from [get_pins Infra/clocks/rst_reg/C] -to [get_pins Infra/clocks/rst_125_reg/D]

#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets USER_SMA_GPIO_N_IBUF]

#set_false_path -from [get_clocks -of_objects [get_pins Infra/clocks/mmcm/CLKOUT1]] -to [get_pins IPbus_slaves/DOUT4/rst_syn1_reg/D]
#set_false_path -from [get_clocks -of_objects [get_pins Infra/clocks/mmcm/CLKOUT1]] -to [get_clocks -of_objects [get_pins IPbus_slaves/TRIGGERING/BUFR_inst/O]]


# Input Delay Constraint 1
set_input_delay -clock syncclk -max 6.750 [get_ports {{READOUT_P[0]} {READOUT_P[1]} {READOUT_P[2]} {READOUT_P[3]} {READOUT_P[4]} {READOUT_P[5]} {READOUT_P[6]} {READOUT_P[7]}}]
set_input_delay -clock syncclk -min 5.750 [get_ports {{READOUT_P[0]} {READOUT_P[1]} {READOUT_P[2]} {READOUT_P[3]} {READOUT_P[4]} {READOUT_P[5]} {READOUT_P[6]} {READOUT_P[7]}}]
set_input_delay -clock syncclk -clock_fall -max -add_delay 6.750 [get_ports {{READOUT_P[0]} {READOUT_P[1]} {READOUT_P[2]} {READOUT_P[3]} {READOUT_P[4]} {READOUT_P[5]} {READOUT_P[6]} {READOUT_P[7]}}]
set_input_delay -clock syncclk -clock_fall -min -add_delay 5.750 [get_ports {{READOUT_P[0]} {READOUT_P[1]} {READOUT_P[2]} {READOUT_P[3]} {READOUT_P[4]} {READOUT_P[5]} {READOUT_P[6]} {READOUT_P[7]}}]


