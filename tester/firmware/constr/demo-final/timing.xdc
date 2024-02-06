create_clock -period 5.000 -name sysclk [get_ports sysclk_p]
create_clock -period 12.500 -name syncclk [get_ports SYNC_P]
# create_clock -period 12.500 -name extrefclk [get_ports EXTREF_IN_P]
# create_clock -period 25.000 -name extref [get_ports EXTREF_OUT_P]

#DPo fix - forgot to assign SYNC on a CC pin
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets sync]
#end DPO fix


#set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins Infra/clocks/mmcm/CLKOUT1]] -group [get_clocks -of_objects [get_pins IPbus_slaves/TRIGGERING/BUFR_inst/O]]

set_false_path -from [get_pins Infra/clocks/rst_reg/C] -to [list [get_pins Infra/clocks/rst_ipb_reg/D] [get_pins Infra/clocks/rst_ipb_reg_replica/D]]
set_false_path -from [get_pins Infra/clocks/rst_reg/C] -to [get_pins Infra/clocks/rst_ipb_ctrl_reg/D]
set_false_path -from [get_pins Infra/clocks/rst_reg/C] -to [get_pins Infra/clocks/rst_125_reg/D]

#set_false_path -from [get_clocks -of_objects [get_pins Infra/clocks/mmcm/CLKOUT1]] -to [get_pins IPbus_slaves/DOUT4/rst_syn1_reg/D]
#set_false_path -from [get_clocks -of_objects [get_pins Infra/clocks/mmcm/CLKOUT1]] -to [get_clocks -of_objects [get_pins IPbus_slaves/TRIGGERING/BUFR_inst/O]]


# Input Delay Constraint 1
set_input_delay -clock syncclk -max 6.750 [get_ports {{READOUT_P[0]} {READOUT_P[1]} {READOUT_P[2]} {READOUT_P[3]} {READOUT_P[4]} {READOUT_P[5]} {READOUT_P[6]} {READOUT_P[7]}}]
set_input_delay -clock syncclk -min 5.750 [get_ports {{READOUT_P[0]} {READOUT_P[1]} {READOUT_P[2]} {READOUT_P[3]} {READOUT_P[4]} {READOUT_P[5]} {READOUT_P[6]} {READOUT_P[7]}}]
set_input_delay -clock syncclk -clock_fall -max -add_delay 6.750 [get_ports {{READOUT_P[0]} {READOUT_P[1]} {READOUT_P[2]} {READOUT_P[3]} {READOUT_P[4]} {READOUT_P[5]} {READOUT_P[6]} {READOUT_P[7]}}]
set_input_delay -clock syncclk -clock_fall -min -add_delay 5.750 [get_ports {{READOUT_P[0]} {READOUT_P[1]} {READOUT_P[2]} {READOUT_P[3]} {READOUT_P[4]} {READOUT_P[5]} {READOUT_P[6]} {READOUT_P[7]}}]


# Input Delay Constraint readout 2
set_input_delay -clock syncclk -max 6.750 [get_ports {{READOUT2_P[0]} {READOUT2_P[1]} {READOUT2_P[2]} {READOUT2_P[3]} {READOUT2_P[4]} {READOUT2_P[5]} {READOUT2_P[6]} {READOUT2_P[7]}}]
set_input_delay -clock syncclk -min 5.750 [get_ports {{READOUT2_P[0]} {READOUT2_P[1]} {READOUT2_P[2]} {READOUT2_P[3]} {READOUT2_P[4]} {READOUT2_P[5]} {READOUT2_P[6]} {READOUT2_P[7]}}]
set_input_delay -clock syncclk -clock_fall -max -add_delay 6.750 [get_ports {{READOUT2_P[0]} {READOUT2_P[1]} {READOUT2_P[2]} {READOUT2_P[3]} {READOUT2_P[4]} {READOUT2_P[5]} {READOUT2_P[6]} {READOUT2_P[7]}}]
set_input_delay -clock syncclk -clock_fall -min -add_delay 5.750 [get_ports {{READOUT2_P[0]} {READOUT2_P[1]} {READOUT2_P[2]} {READOUT2_P[3]} {READOUT2_P[4]} {READOUT2_P[5]} {READOUT2_P[6]} {READOUT2_P[7]}}]

# Input Delay Constraint readout 3
set_input_delay -clock syncclk -max 6.750 [get_ports {{READOUT3_P[0]} {READOUT3_P[1]} {READOUT3_P[2]} {READOUT3_P[3]} {READOUT3_P[4]} {READOUT3_P[5]} {READOUT3_P[6]} {READOUT3_P[7]}}]
set_input_delay -clock syncclk -min 5.750 [get_ports {{READOUT3_P[0]} {READOUT3_P[1]} {READOUT3_P[2]} {READOUT3_P[3]} {READOUT3_P[4]} {READOUT3_P[5]} {READOUT3_P[6]} {READOUT3_P[7]}}]
set_input_delay -clock syncclk -clock_fall -max -add_delay 6.750 [get_ports {{READOUT3_P[0]} {READOUT3_P[1]} {READOUT3_P[2]} {READOUT3_P[3]} {READOUT3_P[4]} {READOUT3_P[5]} {READOUT3_P[6]} {READOUT3_P[7]}}]
set_input_delay -clock syncclk -clock_fall -min -add_delay 5.750 [get_ports {{READOUT3_P[0]} {READOUT3_P[1]} {READOUT3_P[2]} {READOUT3_P[3]} {READOUT3_P[4]} {READOUT3_P[5]} {READOUT3_P[6]} {READOUT3_P[7]}}]

# Input Delay Constraint readout 4
set_input_delay -clock syncclk -max 6.750 [get_ports {{READOUT4_P[0]} {READOUT4_P[1]} {READOUT4_P[2]} {READOUT4_P[3]} {READOUT4_P[4]} {READOUT4_P[5]} {READOUT4_P[6]} {READOUT4_P[7]}}]
set_input_delay -clock syncclk -min 5.750 [get_ports {{READOUT4_P[0]} {READOUT4_P[1]} {READOUT4_P[2]} {READOUT4_P[3]} {READOUT4_P[4]} {READOUT4_P[5]} {READOUT4_P[6]} {READOUT4_P[7]}}]
set_input_delay -clock syncclk -clock_fall -max -add_delay 6.750 [get_ports {{READOUT4_P[0]} {READOUT4_P[1]} {READOUT4_P[2]} {READOUT4_P[3]} {READOUT4_P[4]} {READOUT4_P[5]} {READOUT4_P[6]} {READOUT4_P[7]}}]
set_input_delay -clock syncclk -clock_fall -min -add_delay 5.750 [get_ports {{READOUT4_P[0]} {READOUT4_P[1]} {READOUT4_P[2]} {READOUT4_P[3]} {READOUT4_P[4]} {READOUT4_P[5]} {READOUT4_P[6]} {READOUT4_P[7]}}]






