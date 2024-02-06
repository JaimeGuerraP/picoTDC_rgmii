# XDC for the picoTDC Tester
# EDA-04186-v1.1 Generic BGA package
#IPBUS + VC707 SYSTEM

set_property IOSTANDARD LVDS [get_ports sysclk_p]
set_property PACKAGE_PIN E19 [get_ports sysclk_p]
set_property PACKAGE_PIN E18 [get_ports sysclk_n]
set_property IOSTANDARD LVDS [get_ports sysclk_n]

set_property IOSTANDARD LVCMOS18 [get_ports {leds[*]}]
set_property SLEW SLOW [get_ports {leds[*]}]
set_property PACKAGE_PIN AM39 [get_ports {leds[0]}]
set_property PACKAGE_PIN AN39 [get_ports {leds[1]}]
set_property PACKAGE_PIN AR37 [get_ports {leds[2]}]
set_property PACKAGE_PIN AT37 [get_ports {leds[3]}]
set_property PACKAGE_PIN AR35 [get_ports {leds[4]}]
set_property PACKAGE_PIN AP41 [get_ports {leds[5]}]
set_property PACKAGE_PIN AP42 [get_ports {leds[6]}]
set_property PACKAGE_PIN AU39 [get_ports {leds[7]}]

set_property IOSTANDARD LVCMOS18 [get_ports {dip_sw[*]}]
set_property PACKAGE_PIN AV30 [get_ports {dip_sw[0]}]
set_property PACKAGE_PIN AY33 [get_ports {dip_sw[1]}]
set_property PACKAGE_PIN BA31 [get_ports {dip_sw[2]}]
set_property PACKAGE_PIN BA32 [get_ports {dip_sw[3]}]

set_property PACKAGE_PIN AM7 [get_ports sgmii_rxn]
set_property PACKAGE_PIN AM8 [get_ports sgmii_rxp]
set_property PACKAGE_PIN AN1 [get_ports sgmii_txn]
set_property PACKAGE_PIN AN2 [get_ports sgmii_txp]

set_property PACKAGE_PIN AH8 [get_ports gtrefclk_p]
set_property PACKAGE_PIN AH7 [get_ports gtrefclk_n]

set_property PACKAGE_PIN AJ33 [get_ports phy_rst]
set_property IOSTANDARD LVCMOS18 [get_ports phy_rst]

set_property PACKAGE_PIN AK33 [get_ports phy_mdio]
set_property IOSTANDARD LVCMOS18 [get_ports phy_mdio]

set_property PACKAGE_PIN AH31 [get_ports phy_mdc]
set_property IOSTANDARD LVCMOS18 [get_ports phy_mdc]

#I2C VC707
set_property PACKAGE_PIN AT35 [get_ports SCL_VC707_CARRIER]
set_property IOSTANDARD LVCMOS18 [get_ports SCL_VC707_CARRIER]
set_property DRIVE 4 [get_ports SCL_VC707_CARRIER]
set_property PULLUP true [get_ports SCL_VC707_CARRIER]

set_property PACKAGE_PIN AU32 [get_ports SDA_VC707_CARRIER]
set_property IOSTANDARD LVCMOS18 [get_ports SDA_VC707_CARRIER]
set_property DRIVE 4 [get_ports SDA_VC707_CARRIER]
set_property PULLUP true [get_ports SDA_VC707_CARRIER]


#set_property DCI_CASCADE {35} [get_iobanks 34]
set_property DCI_CASCADE {17 18} [get_iobanks 19]
# set_property DCI_CASCADE {35 36} [get_iobanks 34 33] # DPo
set_property DCI_CASCADE {35 36} [get_iobanks 34]

set_property IOSTANDARD DIFF_SSTL12 [get_ports CLK_C2M_1_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports CLK_C2M_1_N]
set_property PACKAGE_PIN AB41 [get_ports CLK_C2M_1_P]
set_property PACKAGE_PIN AB42 [get_ports CLK_C2M_1_N]


set_property IOSTANDARD DIFF_SSTL12 [get_ports CLK_C2M_2_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports CLK_C2M_2_N]
set_property PACKAGE_PIN AB38 [get_ports CLK_C2M_2_P]
set_property PACKAGE_PIN AB39 [get_ports CLK_C2M_2_N]

#set_property IOSTANDARD LVDS [get_ports USER_SMA_GPIO_P]
#set_property IOSTANDARD LVDS [get_ports USER_SMA_GPIO_N]
#set_property PACKAGE_PIN AN31 [get_ports USER_SMA_GPIO_P]
#set_property PACKAGE_PIN AP31 [get_ports USER_SMA_GPIO_N]

#SMA input hits and FMC driver

set_property IOSTANDARD LVDS [get_ports USER_SMA_CLOCK_P]
set_property PACKAGE_PIN AJ32 [get_ports USER_SMA_CLOCK_P]
set_property PACKAGE_PIN AK32 [get_ports USER_SMA_CLOCK_N]
set_property IOSTANDARD LVDS [get_ports USER_SMA_CLOCK_N]

#set_property IOSTANDARD DIFF_SSTL12 [get_ports PAR_HIT_P]
#set_property IOSTANDARD DIFF_SSTL12 [get_ports PAR_HIT_N]
#set_property PACKAGE_PIN H33 [get_ports PAR_HIT_N]
#set_property PACKAGE_PIN G33 [get_ports PAR_HIT_P]

# Input clock for triggering
#set_property PACKAGE_PIN AP31 [get_ports USER_SMA_GPIO_N]
#set_property IOSTANDARD LVCMOS18 [get_ports USER_SMA_GPIO_N]

set_property IOSTANDARD LVDS [get_ports USER_SMA_GPIO_P]
set_property IOSTANDARD LVDS [get_ports USER_SMA_GPIO_N]
set_property PACKAGE_PIN AN31 [get_ports USER_SMA_GPIO_P]
set_property PACKAGE_PIN AP31 [get_ports USER_SMA_GPIO_N]
set_property DIFF_TERM TRUE [get_ports USER_SMA_GPIO_N]
set_property DIFF_TERM TRUE [get_ports USER_SMA_GPIO_P]


#Readout 1 pairs

#Readout pairs 0, 1, 3, 5, 7 are inverted on the FMC card!
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[0]}]
set_property PACKAGE_PIN A35 [get_ports {READOUT_P[0]}]
set_property PACKAGE_PIN A36 [get_ports {READOUT_N[0]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[0]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[1]}]
set_property PACKAGE_PIN D37 [get_ports {READOUT_P[1]}]
set_property PACKAGE_PIN D38 [get_ports {READOUT_N[1]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[1]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[2]}]
set_property PACKAGE_PIN F39 [get_ports {READOUT_P[2]}]
set_property PACKAGE_PIN E39 [get_ports {READOUT_N[2]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[2]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[3]}]
set_property PACKAGE_PIN E37 [get_ports {READOUT_P[3]}]
set_property PACKAGE_PIN E38 [get_ports {READOUT_N[3]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[3]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[4]}]
set_property PACKAGE_PIN C38 [get_ports {READOUT_P[4]}]
set_property PACKAGE_PIN C39 [get_ports {READOUT_N[4]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[4]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[5]}]
set_property PACKAGE_PIN H38 [get_ports {READOUT_P[5]}]
set_property PACKAGE_PIN G38 [get_ports {READOUT_N[5]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[5]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[6]}]
set_property PACKAGE_PIN G36 [get_ports {READOUT_P[6]}]
set_property PACKAGE_PIN G37 [get_ports {READOUT_N[6]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[6]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[7]}]
set_property PACKAGE_PIN J37 [get_ports {READOUT_P[7]}]
set_property PACKAGE_PIN J38 [get_ports {READOUT_N[7]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[7]}]


set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports SYNC_P]
set_property PACKAGE_PIN C35 [get_ports SYNC_P]
set_property PACKAGE_PIN C36 [get_ports SYNC_N]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports SYNC_N]



# I2C Master for PicoTDC control

set_property PACKAGE_PIN G26 [get_ports SCL_PICOTDC]
set_property IOSTANDARD LVCMOS12 [get_ports SCL_PICOTDC]
set_property DRIVE 4 [get_ports SCL_PICOTDC]

set_property PACKAGE_PIN G27 [get_ports SDA_PICOTDC]
set_property IOSTANDARD LVCMOS12 [get_ports SDA_PICOTDC]
set_property DRIVE 4 [get_ports SDA_PICOTDC]

#PicoTDC signals controller - PCB has swapped pairs

set_property IOSTANDARD DIFF_SSTL12 [get_ports RESET_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports RESET_N]
set_property PACKAGE_PIN K23 [get_ports RESET_P] 
set_property PACKAGE_PIN J23 [get_ports RESET_N] 


set_false_path -to [get_ports {leds[*]} -filter {direction != in}]
set_false_path -from [get_ports {dip_sw[*]} -filter {direction != out}]


# Common HIT HA03
set_property IOSTANDARD DIFF_SSTL12 [get_ports PAR_HIT_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports PAR_HIT_N]
set_property PACKAGE_PIN H33 [get_ports PAR_HIT_N]
set_property PACKAGE_PIN G33 [get_ports PAR_HIT_P]



# Not connect on PCB - just to compile the flow
set_property IOSTANDARD DIFF_SSTL12 [get_ports BX_RESET_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports BX_RESET_N]
set_property PACKAGE_PIN AL41 [get_ports BX_RESET_P]
set_property PACKAGE_PIN AL42 [get_ports BX_RESET_N]

set_property IOSTANDARD DIFF_SSTL12 [get_ports EID_RESET_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports EID_RESET_N]
set_property PACKAGE_PIN AC40 [get_ports EID_RESET_P]
set_property PACKAGE_PIN AC41 [get_ports EID_RESET_N]

set_property IOSTANDARD DIFF_SSTL12 [get_ports TRIGGER_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports TRIGGER_N]
set_property PACKAGE_PIN AJ42 [get_ports TRIGGER_P]
set_property PACKAGE_PIN AK42 [get_ports TRIGGER_N]

