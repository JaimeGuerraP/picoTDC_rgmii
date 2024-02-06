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

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[0]}]
set_property PACKAGE_PIN W40 [get_ports {READOUT_P[0]}]
set_property PACKAGE_PIN Y40 [get_ports {READOUT_N[0]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[0]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[1]}]
set_property PACKAGE_PIN AF41 [get_ports {READOUT_P[1]}]
set_property PACKAGE_PIN AG41 [get_ports {READOUT_N[1]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[1]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[2]}]
set_property PACKAGE_PIN AD38 [get_ports {READOUT_P[2]}]
set_property PACKAGE_PIN AE38 [get_ports {READOUT_N[2]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[2]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[3]}]
set_property PACKAGE_PIN AF42 [get_ports {READOUT_P[3]}]
set_property PACKAGE_PIN AG42 [get_ports {READOUT_N[3]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[3]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[4]}]
set_property PACKAGE_PIN AJ38 [get_ports {READOUT_P[4]}]
set_property PACKAGE_PIN AK38 [get_ports {READOUT_N[4]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[4]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[5]}]
set_property PACKAGE_PIN U37 [get_ports {READOUT_P[5]}]
set_property PACKAGE_PIN U38 [get_ports {READOUT_N[5]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[5]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[6]}]
set_property PACKAGE_PIN R38 [get_ports {READOUT_P[6]}]
set_property PACKAGE_PIN R39 [get_ports {READOUT_N[6]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[6]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[7]}]
set_property PACKAGE_PIN N33 [get_ports {READOUT_P[7]}]
set_property PACKAGE_PIN N34 [get_ports {READOUT_N[7]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[7]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports SYNC_P]
set_property PACKAGE_PIN U36 [get_ports SYNC_P]
set_property PACKAGE_PIN T37 [get_ports SYNC_N]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports SYNC_N]

#Readout 2 pairs

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_P[0]}]
set_property PACKAGE_PIN Y39 [get_ports {READOUT2_P[0]}]
set_property PACKAGE_PIN AA39 [get_ports {READOUT2_N[0]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_N[0]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_P[1]}]
set_property PACKAGE_PIN AJ40 [get_ports {READOUT2_P[1]}]
set_property PACKAGE_PIN AJ41 [get_ports {READOUT2_N[1]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_N[1]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_P[2]}]
set_property PACKAGE_PIN V33 [get_ports {READOUT2_P[2]}]
set_property PACKAGE_PIN V34 [get_ports {READOUT2_N[2]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_N[2]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_P[3]}]
set_property PACKAGE_PIN W32 [get_ports {READOUT2_P[3]}]
set_property PACKAGE_PIN W33 [get_ports {READOUT2_N[3]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_N[3]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_P[4]}]
set_property PACKAGE_PIN R33 [get_ports {READOUT2_P[4]}]
set_property PACKAGE_PIN R34 [get_ports {READOUT2_N[4]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_N[4]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_P[5]}]
set_property PACKAGE_PIN W36 [get_ports {READOUT2_P[5]}]
set_property PACKAGE_PIN W37 [get_ports {READOUT2_N[5]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_N[5]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_P[6]}]
set_property PACKAGE_PIN V39 [get_ports {READOUT2_P[6]}]
set_property PACKAGE_PIN V40 [get_ports {READOUT2_N[6]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_N[6]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_P[7]}]
set_property PACKAGE_PIN T36 [get_ports {READOUT2_P[7]}]
set_property PACKAGE_PIN R37 [get_ports {READOUT2_N[7]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_N[7]}]

#Readout 3 pairs

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_P[0]}]
set_property PACKAGE_PIN Y42 [get_ports {READOUT3_P[0]}]
set_property PACKAGE_PIN AA42 [get_ports {READOUT3_N[0]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_N[0]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_P[1]}]
set_property PACKAGE_PIN AC38 [get_ports {READOUT3_P[1]}]
set_property PACKAGE_PIN AC39 [get_ports {READOUT3_N[1]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_N[1]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_P[2]}]
set_property PACKAGE_PIN U32 [get_ports {READOUT3_P[2]}]
set_property PACKAGE_PIN U33 [get_ports {READOUT3_N[2]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_N[2]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_P[3]}]
set_property PACKAGE_PIN P35 [get_ports {READOUT3_P[3]}]
set_property PACKAGE_PIN P36 [get_ports {READOUT3_N[3]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_N[3]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_P[4]}]
set_property PACKAGE_PIN U34 [get_ports {READOUT3_P[4]}]
set_property PACKAGE_PIN T35 [get_ports {READOUT3_N[4]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_N[4]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_P[5]}]
set_property PACKAGE_PIN V35 [get_ports {READOUT3_P[5]}]
set_property PACKAGE_PIN V36 [get_ports {READOUT3_N[5]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_N[5]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_P[6]}]
set_property PACKAGE_PIN T32 [get_ports {READOUT3_P[6]}]
set_property PACKAGE_PIN R32 [get_ports {READOUT3_N[6]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_N[6]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_P[7]}]
set_property PACKAGE_PIN P37 [get_ports {READOUT3_P[7]}]
set_property PACKAGE_PIN P38 [get_ports {READOUT3_N[7]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_N[7]}]

#Readout 4 pairs

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_P[0]}]
set_property PACKAGE_PIN AC30 [get_ports {READOUT4_P[0]}]
set_property PACKAGE_PIN AD30 [get_ports {READOUT4_N[0]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_N[0]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_P[1]}]
set_property PACKAGE_PIN AB31 [get_ports {READOUT4_P[1]}]
set_property PACKAGE_PIN AB32 [get_ports {READOUT4_N[1]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_N[1]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_P[2]}]
set_property PACKAGE_PIN AF31 [get_ports {READOUT4_P[2]}]
set_property PACKAGE_PIN AF32 [get_ports {READOUT4_N[2]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_N[2]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_P[3]}]
set_property PACKAGE_PIN AC34 [get_ports {READOUT4_P[3]}]
set_property PACKAGE_PIN AD35 [get_ports {READOUT4_N[3]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_N[3]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_P[4]}]
set_property PACKAGE_PIN AA34 [get_ports {READOUT4_P[4]}]
set_property PACKAGE_PIN AA35 [get_ports {READOUT4_N[4]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_N[4]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_P[5]}]
set_property PACKAGE_PIN Y37 [get_ports {READOUT4_P[5]}]
set_property PACKAGE_PIN AA37 [get_ports {READOUT4_N[5]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_N[5]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_P[6]}]
set_property PACKAGE_PIN AB36 [get_ports {READOUT4_P[6]}]
set_property PACKAGE_PIN AB37 [get_ports {READOUT4_N[6]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_N[6]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_P[7]}]
set_property PACKAGE_PIN Y35 [get_ports {READOUT4_P[7]}]
set_property PACKAGE_PIN AA36 [get_ports {READOUT4_N[7]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_N[7]}]

# I2C Master for PicoTDC control

set_property PACKAGE_PIN P33 [get_ports SCL_PICOTDC]
set_property IOSTANDARD LVCMOS12 [get_ports SCL_PICOTDC]
set_property DRIVE 4 [get_ports SCL_PICOTDC]

set_property PACKAGE_PIN P32 [get_ports SDA_PICOTDC]
set_property IOSTANDARD LVCMOS12 [get_ports SDA_PICOTDC]
set_property DRIVE 4 [get_ports SDA_PICOTDC]

#PicoTDC signals controller - PCB has swapped pairs

set_property IOSTANDARD DIFF_SSTL12 [get_ports RESET_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports RESET_N]
set_property PACKAGE_PIN AK39 [get_ports RESET_P] 
set_property PACKAGE_PIN AL39 [get_ports RESET_N] 

#PicoTDC signals controller

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[0]}]
set_property PACKAGE_PIN N30 [get_ports {HTRX_P[0]}]
set_property PACKAGE_PIN M31 [get_ports {HTRX_N[0]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[0]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[1]}]
set_property PACKAGE_PIN E34 [get_ports {HTRX_P[1]}]
set_property PACKAGE_PIN E35 [get_ports {HTRX_N[1]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[1]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[2]}]
set_property PACKAGE_PIN G32 [get_ports {HTRX_P[2]}]
set_property PACKAGE_PIN F32 [get_ports {HTRX_N[2]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[2]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[3]}]
set_property PACKAGE_PIN H33 [get_ports {HTRX_P[3]}]
set_property PACKAGE_PIN G33 [get_ports {HTRX_N[3]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[3]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[4]}]
set_property PACKAGE_PIN K39 [get_ports {HTRX_P[4]}]
set_property PACKAGE_PIN K40 [get_ports {HTRX_N[4]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[4]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[5]}]
set_property PACKAGE_PIN F34 [get_ports {HTRX_P[5]}]
set_property PACKAGE_PIN F35 [get_ports {HTRX_N[5]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[5]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[6]}]
set_property PACKAGE_PIN P41 [get_ports {HTRX_P[6]}]
set_property PACKAGE_PIN N41 [get_ports {HTRX_N[6]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[6]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[7]}]
set_property PACKAGE_PIN E32 [get_ports {HTRX_P[7]}]
set_property PACKAGE_PIN D32 [get_ports {HTRX_N[7]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[7]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[8]}]
set_property PACKAGE_PIN E33 [get_ports {HTRX_P[8]}]
set_property PACKAGE_PIN D33 [get_ports {HTRX_N[8]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[8]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[9]}]
set_property PACKAGE_PIN M42 [get_ports {HTRX_P[9]}]
set_property PACKAGE_PIN L42 [get_ports {HTRX_N[9]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[9]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[10]}]
set_property PACKAGE_PIN B36 [get_ports {HTRX_P[10]}]
set_property PACKAGE_PIN A37 [get_ports {HTRX_N[10]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[10]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[11]}]
set_property PACKAGE_PIN H40 [get_ports {HTRX_P[11]}]
set_property PACKAGE_PIN H41 [get_ports {HTRX_N[11]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[11]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[12]}]
set_property PACKAGE_PIN C38 [get_ports {HTRX_P[12]}]
set_property PACKAGE_PIN C39 [get_ports {HTRX_N[12]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[12]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[13]}]
set_property PACKAGE_PIN J37 [get_ports {HTRX_P[13]}]
set_property PACKAGE_PIN J38 [get_ports {HTRX_N[13]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[13]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[14]}]
set_property PACKAGE_PIN J36 [get_ports {HTRX_P[14]}]
set_property PACKAGE_PIN H36 [get_ports {HTRX_N[14]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[14]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[15]}]
set_property PACKAGE_PIN G36 [get_ports {HTRX_P[15]}]
set_property PACKAGE_PIN G37 [get_ports {HTRX_N[15]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[15]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[16]}]
set_property PACKAGE_PIN M37 [get_ports {HTRX_P[16]}]
set_property PACKAGE_PIN M38 [get_ports {HTRX_N[16]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[16]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[17]}]
set_property PACKAGE_PIN H38 [get_ports {HTRX_P[17]}]
set_property PACKAGE_PIN G38 [get_ports {HTRX_N[17]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[17]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[18]}]
set_property PACKAGE_PIN G41 [get_ports {HTRX_P[18]}]
set_property PACKAGE_PIN G42 [get_ports {HTRX_N[18]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[18]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[19]}]
set_property PACKAGE_PIN B37 [get_ports {HTRX_P[19]}]
set_property PACKAGE_PIN B38 [get_ports {HTRX_N[19]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[19]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[20]}]
set_property PACKAGE_PIN E37 [get_ports {HTRX_P[20]}]
set_property PACKAGE_PIN E38 [get_ports {HTRX_N[20]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[20]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[21]}]
set_property PACKAGE_PIN R40 [get_ports {HTRX_P[21]}]
set_property PACKAGE_PIN P40 [get_ports {HTRX_N[21]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[21]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[22]}]
set_property PACKAGE_PIN C35 [get_ports {HTRX_P[22]}]
set_property PACKAGE_PIN C36 [get_ports {HTRX_N[22]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[22]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[23]}]
set_property PACKAGE_PIN F40 [get_ports {HTRX_P[23]}]
set_property PACKAGE_PIN F41 [get_ports {HTRX_N[23]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[23]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[24]}]
set_property PACKAGE_PIN F39 [get_ports {HTRX_P[24]}]
set_property PACKAGE_PIN E39 [get_ports {HTRX_N[24]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[24]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[25]}]
set_property PACKAGE_PIN K37 [get_ports {HTRX_P[25]}]
set_property PACKAGE_PIN K38 [get_ports {HTRX_N[25]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[25]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[26]}]
set_property PACKAGE_PIN D37 [get_ports {HTRX_P[26]}]
set_property PACKAGE_PIN D38 [get_ports {HTRX_N[26]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[26]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[27]}]
set_property PACKAGE_PIN M36 [get_ports {HTRX_P[27]}]
set_property PACKAGE_PIN L37 [get_ports {HTRX_N[27]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[27]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[28]}]
set_property PACKAGE_PIN F36 [get_ports {HTRX_P[28]}]
set_property PACKAGE_PIN F37 [get_ports {HTRX_N[28]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[28]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[29]}]
set_property PACKAGE_PIN Y29 [get_ports {HTRX_P[29]}]
set_property PACKAGE_PIN Y30 [get_ports {HTRX_N[29]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[29]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[30]}]
set_property PACKAGE_PIN G28 [get_ports {HTRX_P[30]}]
set_property PACKAGE_PIN G29 [get_ports {HTRX_N[30]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[30]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[31]}]
set_property PACKAGE_PIN A35 [get_ports {HTRX_P[31]}]
set_property PACKAGE_PIN A36 [get_ports {HTRX_N[31]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[31]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[32]}]
set_property PACKAGE_PIN W30 [get_ports {HTRX_P[32]}]
set_property PACKAGE_PIN W31 [get_ports {HTRX_N[32]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[32]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[33]}]
set_property PACKAGE_PIN K28 [get_ports {HTRX_P[33]}]
set_property PACKAGE_PIN J28 [get_ports {HTRX_N[33]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[33]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[34]}]
set_property PACKAGE_PIN H28 [get_ports {HTRX_P[34]}]
set_property PACKAGE_PIN H29 [get_ports {HTRX_N[34]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[34]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[35]}]
set_property PACKAGE_PIN R28 [get_ports {HTRX_P[35]}]
set_property PACKAGE_PIN P28 [get_ports {HTRX_N[35]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[35]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[36]}]
set_property PACKAGE_PIN K27 [get_ports {HTRX_P[36]}]
set_property PACKAGE_PIN J27 [get_ports {HTRX_N[36]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[36]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[37]}]
set_property PACKAGE_PIN J25 [get_ports {HTRX_P[37]}]
set_property PACKAGE_PIN J26 [get_ports {HTRX_N[37]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[37]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[38]}]
set_property PACKAGE_PIN N28 [get_ports {HTRX_P[38]}]
set_property PACKAGE_PIN N29 [get_ports {HTRX_N[38]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[38]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[39]}]
set_property PACKAGE_PIN H24 [get_ports {HTRX_P[39]}]
set_property PACKAGE_PIN G24 [get_ports {HTRX_N[39]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[39]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[40]}]
set_property PACKAGE_PIN G26 [get_ports {HTRX_P[40]}]
set_property PACKAGE_PIN G27 [get_ports {HTRX_N[40]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[40]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[41]}]
set_property PACKAGE_PIN K29 [get_ports {HTRX_P[41]}]
set_property PACKAGE_PIN K30 [get_ports {HTRX_N[41]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[41]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[42]}]
set_property PACKAGE_PIN H23 [get_ports {HTRX_P[42]}]
set_property PACKAGE_PIN G23 [get_ports {HTRX_N[42]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[42]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[43]}]
set_property PACKAGE_PIN K23 [get_ports {HTRX_P[43]}]
set_property PACKAGE_PIN J23 [get_ports {HTRX_N[43]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[43]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[44]}]
set_property PACKAGE_PIN R30 [get_ports {HTRX_P[44]}]
set_property PACKAGE_PIN P31 [get_ports {HTRX_N[44]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[44]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[45]}]
set_property PACKAGE_PIN H25 [get_ports {HTRX_P[45]}]
set_property PACKAGE_PIN H26 [get_ports {HTRX_N[45]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[45]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[46]}]
set_property PACKAGE_PIN K22 [get_ports {HTRX_P[46]}]
set_property PACKAGE_PIN J22 [get_ports {HTRX_N[46]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[46]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[47]}]
set_property PACKAGE_PIN P25 [get_ports {HTRX_P[47]}]
set_property PACKAGE_PIN P26 [get_ports {HTRX_N[47]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[47]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[48]}]
set_property PACKAGE_PIN T29 [get_ports {HTRX_P[48]}]
set_property PACKAGE_PIN T30 [get_ports {HTRX_N[48]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[48]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[49]}]
set_property PACKAGE_PIN M22 [get_ports {HTRX_P[49]}]
set_property PACKAGE_PIN L22 [get_ports {HTRX_N[49]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[49]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[50]}]
set_property PACKAGE_PIN L29 [get_ports {HTRX_P[50]}]
set_property PACKAGE_PIN L30 [get_ports {HTRX_N[50]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[50]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[51]}]
set_property PACKAGE_PIN K24 [get_ports {HTRX_P[51]}]
set_property PACKAGE_PIN K25 [get_ports {HTRX_N[51]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[51]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[52]}]
set_property PACKAGE_PIN M28 [get_ports {HTRX_P[52]}]
set_property PACKAGE_PIN M29 [get_ports {HTRX_N[52]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[52]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[53]}]
set_property PACKAGE_PIN M21 [get_ports {HTRX_P[53]}]
set_property PACKAGE_PIN L21 [get_ports {HTRX_N[53]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[53]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[54]}]
set_property PACKAGE_PIN J21 [get_ports {HTRX_P[54]}]
set_property PACKAGE_PIN H21 [get_ports {HTRX_N[54]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[54]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[55]}]
set_property PACKAGE_PIN L25 [get_ports {HTRX_P[55]}]
set_property PACKAGE_PIN L26 [get_ports {HTRX_N[55]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[55]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[56]}]
set_property PACKAGE_PIN V30 [get_ports {HTRX_P[56]}]
set_property PACKAGE_PIN V31 [get_ports {HTRX_N[56]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[56]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[57]}]
set_property PACKAGE_PIN N25 [get_ports {HTRX_P[57]}]
set_property PACKAGE_PIN N26 [get_ports {HTRX_N[57]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[57]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[58]}]
set_property PACKAGE_PIN U31 [get_ports {HTRX_P[58]}]
set_property PACKAGE_PIN T31 [get_ports {HTRX_N[58]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[58]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[59]}]
set_property PACKAGE_PIN G21 [get_ports {HTRX_P[59]}]
set_property PACKAGE_PIN G22 [get_ports {HTRX_N[59]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[59]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[60]}]
set_property PACKAGE_PIN P22 [get_ports {HTRX_P[60]}]
set_property PACKAGE_PIN P23 [get_ports {HTRX_N[60]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[60]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[61]}]
set_property PACKAGE_PIN M24 [get_ports {HTRX_P[61]}]
set_property PACKAGE_PIN L24 [get_ports {HTRX_N[61]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[61]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[62]}]
set_property PACKAGE_PIN V29 [get_ports {HTRX_P[62]}]
set_property PACKAGE_PIN U29 [get_ports {HTRX_N[62]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[62]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_P[63]}]
set_property PACKAGE_PIN P21 [get_ports {HTRX_P[63]}]
set_property PACKAGE_PIN N21 [get_ports {HTRX_N[63]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {HTRX_N[63]}]

set_false_path -to [get_ports {leds[*]} -filter {direction != in}]
set_false_path -from [get_ports {dip_sw[*]} -filter {direction != out}]


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

