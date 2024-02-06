# XDC for the picoTDC Demo board EDA-04186-v2
# DPo
# Adpated by: Jaime Octavio Guerra Pulido
# Date: november 17, 2023

# ------------------------
# AXKU040 BOARD CONNECTIONS
# ------------------------

# IPBUS + AXKU040 SYSTEM
set_property IOSTANDARD LVDS [get_ports sysclk_p]
set_property PACKAGE_PIN AK17 [get_ports sysclk_p] #modified  
set_property PACKAGE_PIN AK16 [get_ports sysclk_n] #modified 
set_property IOSTANDARD LVDS [get_ports sysclk_n]

## Due to there is not enough LEDs in the AXKU040 board,
## they are rooted to FMC1 pins which has level of 1.8V
## and it cannot be modified. 

set_property IOSTANDARD LVCMOS18 [get_ports {leds[*]}] # modified
set_property SLEW SLOW [get_ports {leds[*]}] # modified
set_property PACKAGE_PIN AA24 [get_ports {leds[0]}] # modified
set_property PACKAGE_PIN AA25 [get_ports {leds[1]}] # modified
set_property PACKAGE_PIN W32 [get_ports {leds[2]}] # modified
set_property PACKAGE_PIN W24 [get_ports {leds[3]}] # modified
set_property PACKAGE_PIN AB21 [get_ports {leds[4]}] # modified
set_property PACKAGE_PIN AC21 [get_ports {leds[5]}] # modified
set_property PACKAGE_PIN AC22 [get_ports {leds[6]}] # modified
set_property PACKAGE_PIN AC23 [get_ports {leds[7]}] # modified

## In VHDL code some leds outputs are moved to 
## actual leds of the board.  

set_property PACKAGE_PIN L20 [get_ports LED1]
set_property IOSTANDARD LVCMOS18 [get_ports LED1] #IO_L22N_T3U_N7_DBC_AD0N_D05_65
set_property PACKAGE_PIN M20 [get_ports LED2]
set_property IOSTANDARD LVCMOS18 [get_ports LED2] #IO_L22P_T3U_N6_DBC_AD0P_D04_65
set_property PACKAGE_PIN M21 [get_ports LED3]
set_property IOSTANDARD LVCMOS18 [get_ports LED3] #IO_L23N_T3U_N9_I2C_SDA_65
set_property PACKAGE_PIN N21 [get_ports LED3]
set_property IOSTANDARD LVCMOS18 [get_ports LED3] #IO_L23P_T3U_N8_I2C_SCLK_65

## Due to there is not enough SWs in the AXKU040 board,
## they are rooted to FMC1 pins which has voltage level of 1.8V
## and it cannot be modified. 

set_property IOSTANDARD LVCMOS18 [get_ports {dip_sw[*]}]
set_property PACKAGE_PIN AA22 [get_ports {dip_sw[0]}] # modified
set_property PACKAGE_PIN AB22 [get_ports {dip_sw[1]}] # modified
set_property PACKAGE_PIN AD25 [get_ports {dip_sw[2]}] # modified
set_property PACKAGE_PIN AD26 [get_ports {dip_sw[3]}] # modified

set_false_path -to [get_ports {leds[*]} -filter {direction != in}]
set_false_path -from [get_ports {dip_sw[*]} -filter {direction != out}]

# Ethernet
# AXKU040 board has a rgmii interface, unlike VC707 that has a sgmii
# this fact makes that new constraints must defined.

# set_property PACKAGE_PIN AM7 [get_ports sgmii_rxn]
# set_property PACKAGE_PIN AM8 [get_ports sgmii_rxp]
# set_property PACKAGE_PIN AN1 [get_ports sgmii_txn]
# set_property PACKAGE_PIN AN2 [get_ports sgmii_txp]

set_property PACKAGE_PIN AF6 [get_ports gtrefclk_p] # modified
set_property PACKAGE_PIN AF5 [get_ports gtrefclk_n] # modified
 
# set_property PACKAGE_PIN AK17 [get_ports sys_clk_p]
# set_property IOSTANDARD DIFF_SSTL12 [get_ports sys_clk_p]
# create_clock -period 5.000 -name sys_clk_p -waveform {0.000 2.500} [get_ports sys_clk_p]

set_property PACKAGE_PIN AK8 [get_ports rst_n]
set_property IOSTANDARD LVCMOS18 [get_ports rst_n]

# set_property PACKAGE_PIN A23 [get_ports e_mdc]
# set_property PACKAGE_PIN A22 [get_ports e_mdio]
# set_property PACKAGE_PIN H22 [get_ports e_reset]

set_property PACKAGE_PIN D23 [get_ports rgmii_rxc]
set_property PACKAGE_PIN A29 [get_ports rgmii_rxctl]
set_property PACKAGE_PIN B29 [get_ports {rgmii_rxd[0]}]
set_property PACKAGE_PIN A28 [get_ports {rgmii_rxd[1]}]
set_property PACKAGE_PIN A27 [get_ports {rgmii_rxd[2]}]
set_property PACKAGE_PIN C23 [get_ports {rgmii_rxd[3]}]
set_property PACKAGE_PIN B24 [get_ports rgmii_txc]
set_property PACKAGE_PIN A24 [get_ports rgmii_txctl]
set_property PACKAGE_PIN B20 [get_ports {rgmii_txd[0]}]
set_property PACKAGE_PIN A20 [get_ports {rgmii_txd[1]}]
set_property PACKAGE_PIN B21 [get_ports {rgmii_txd[2]}]
set_property PACKAGE_PIN B22 [get_ports {rgmii_txd[3]}]

# set_property IOSTANDARD LVCMOS18 [get_ports e_mdc]
# set_property IOSTANDARD LVCMOS18 [get_ports e_mdio]
# set_property IOSTANDARD LVCMOS18 [get_ports e_reset]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_rxc]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_rxctl]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_rxd[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_rxd[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_rxd[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_rxd[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_txc]
set_property IOSTANDARD LVCMOS18 [get_ports rgmii_txctl]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_txd[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_txd[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_txd[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_txd[3]}]


 
set_property PACKAGE_PIN L9 [get_ports phy_rst] #modified
set_property IOSTANDARD LVCMOS18 [get_ports phy_rst]
 
set_property PACKAGE_PIN E12 [get_ports phy_mdio] #modified
set_property IOSTANDARD LVCMOS18 [get_ports phy_mdio]
 
set_property PACKAGE_PIN F12 [get_ports phy_mdc] #modified
set_property IOSTANDARD LVCMOS18 [get_ports phy_mdc]

#set_property DCI_CASCADE {35} [get_iobanks 34]
set_property DCI_CASCADE {17 18} [get_iobanks 19]
# set_property DCI_CASCADE {35 36} [get_iobanks 34 33] # DPo
set_property DCI_CASCADE {35 36} [get_iobanks 34]

# SMA input hits and FMC driver
set_property IOSTANDARD LVDS [get_ports USER_SMA_CLOCK_P]
set_property PACKAGE_PIN Y6 [get_ports USER_SMA_CLOCK_P] # modified
set_property PACKAGE_PIN Y5 [get_ports USER_SMA_CLOCK_N] # modified
set_property IOSTANDARD LVDS [get_ports USER_SMA_CLOCK_N]

set_property IOSTANDARD LVDS [get_ports USER_SMA_GPIO_P]
set_property IOSTANDARD LVDS [get_ports USER_SMA_GPIO_N]
set_property PACKAGE_PIN AB2 [get_ports USER_SMA_GPIO_P] # modified
set_property PACKAGE_PIN AB1 [get_ports USER_SMA_GPIO_N] # modified
set_property DIFF_TERM TRUE [get_ports USER_SMA_GPIO_N]
set_property DIFF_TERM TRUE [get_ports USER_SMA_GPIO_P]

# -----------------------------
# VC707 FMC CONNECTIONS
# -----------------------------

# I2C Board Control *
set_property PACKAGE_PIN P24 [get_ports SCL_VC707_CARRIER] # modified
set_property IOSTANDARD LVCMOS18 [get_ports SCL_VC707_CARRIER]
set_property DRIVE 4 [get_ports SCL_VC707_CARRIER]
set_property PULLUP true [get_ports SCL_VC707_CARRIER]

set_property PACKAGE_PIN P25 [get_ports SDA_VC707_CARRIER] # modified
set_property IOSTANDARD LVCMOS18 [get_ports SDA_VC707_CARRIER]
set_property DRIVE 4 [get_ports SDA_VC707_CARRIER]
set_property PULLUP true [get_ports SDA_VC707_CARRIER]


# Readout Sync *
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports SYNC_P]
set_property PACKAGE_PIN D24 [get_ports SYNC_P] # modified
set_property PACKAGE_PIN C24 [get_ports SYNC_N] # modified
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports SYNC_N]

# Readout 1 pairs *

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[0]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[0]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[1]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[1]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[2]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[2]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[3]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[3]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[4]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[4]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[5]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[5]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[6]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[6]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_P[7]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT_N[7]}]

# Readout 2 pairs *

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_P[0]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_N[0]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_P[1]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_N[1]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_P[2]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_N[2]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_P[3]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_N[3]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_P[4]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_N[4]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_P[5]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_N[5]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_P[6]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_N[6]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_P[7]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT2_N[7]}]

# Readout 3 pairs *

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_P[0]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_N[0]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_P[1]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_N[1]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_P[2]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_N[2]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_P[3]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_N[3]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_P[4]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_N[4]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_P[5]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_N[5]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_P[6]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_N[6]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_P[7]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT3_N[7]}]


# Readout 4 pairs *

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_P[0]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_N[0]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_P[1]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_N[1]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_P[2]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_N[2]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_P[3]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_N[3]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_P[4]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_N[4]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_P[5]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_N[5]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_P[6]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_N[6]}]

set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_P[7]}]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports {READOUT4_N[7]}]

set_property PACKAGE_PIN C21 [get_ports {READOUT_P[0]}] # modified
set_property PACKAGE_PIN C22 [get_ports {READOUT_N[0]}] # modified
set_property PACKAGE_PIN G20 [get_ports {READOUT_P[1]}] # modified
set_property PACKAGE_PIN F20 [get_ports {READOUT_N[1]}] # modified
set_property PACKAGE_PIN E23 [get_ports {READOUT_P[2]}] # modified
set_property PACKAGE_PIN E22 [get_ports {READOUT_N[2]}] # modified
set_property PACKAGE_PIN D13 [get_ports {READOUT_P[3]}] # modified
set_property PACKAGE_PIN C13 [get_ports {READOUT_N[3]}] # modified
set_property PACKAGE_PIN B25 [get_ports {READOUT_P[4]}] # modified
set_property PACKAGE_PIN A25 [get_ports {READOUT_N[4]}] # modified
set_property PACKAGE_PIN G24 [get_ports {READOUT_P[5]}] # modified
set_property PACKAGE_PIN F25 [get_ports {READOUT_N[5]}] # modified
set_property PACKAGE_PIN F13 [get_ports {READOUT_P[6]}] # modified
set_property PACKAGE_PIN E13 [get_ports {READOUT_N[6]}] # modified
set_property PACKAGE_PIN C26 [get_ports {READOUT_P[7]}] # modified
set_property PACKAGE_PIN B26 [get_ports {READOUT_N[7]}] # modified

set_property PACKAGE_PIN E11 [get_ports {READOUT2_P[0]}] # modified
set_property PACKAGE_PIN D11 [get_ports {READOUT2_N[0]}] # modified
set_property PACKAGE_PIN D20 [get_ports {READOUT2_P[1]}] # modified
set_property PACKAGE_PIN D21 [get_ports {READOUT2_N[1]}] # modified
set_property PACKAGE_PIN E20 [get_ports {READOUT2_P[2]}] # modified
set_property PACKAGE_PIN E21 [get_ports {READOUT2_N[2]}] # modified
set_property PACKAGE_PIN H21 [get_ports {READOUT2_P[3]}] # modified
set_property PACKAGE_PIN G21 [get_ports {READOUT2_N[3]}] # modified
set_property PACKAGE_PIN G9  [get_ports {READOUT2_P[4]}] # modified
set_property PACKAGE_PIN F9  [get_ports {READOUT2_N[4]}] # modified
set_property PACKAGE_PIN H11 [get_ports {READOUT2_P[5]}] # modified
set_property PACKAGE_PIN G11 [get_ports {READOUT2_N[5]}] # modified
set_property PACKAGE_PIN D8  [get_ports {READOUT2_P[6]}] # modified
set_property PACKAGE_PIN C8  [get_ports {READOUT2_N[6]}] # modified
set_property PACKAGE_PIN E10 [get_ports {READOUT2_P[7]}] # modified
set_property PACKAGE_PIN D10 [get_ports {READOUT2_N[7]}] # modified

set_property PACKAGE_PIN D9  [get_ports {READOUT3_P[0]}] # modified
set_property PACKAGE_PIN C9  [get_ports {READOUT3_N[0]}] # modified
set_property PACKAGE_PIN J13 [get_ports {READOUT3_P[1]}] # modified
set_property PACKAGE_PIN H13 [get_ports {READOUT3_N[1]}] # modified
set_property PACKAGE_PIN F8  [get_ports {READOUT3_P[2]}] # modified
set_property PACKAGE_PIN E8  [get_ports {READOUT3_N[2]}] # modified
set_property PACKAGE_PIN K11 [get_ports {READOUT3_P[3]}] # modified
set_property PACKAGE_PIN J11 [get_ports {READOUT3_N[3]}] # modified
set_property PACKAGE_PIN K10 [get_ports {READOUT3_P[4]}] # modified
set_property PACKAGE_PIN J10 [get_ports {READOUT3_N[4]}] # modified
set_property PACKAGE_PIN J8  [get_ports {READOUT3_P[5]}] # modified
set_property PACKAGE_PIN H8  [get_ports {READOUT3_N[5]}] # modified
set_property PACKAGE_PIN L8  [get_ports {READOUT3_P[6]}] # modified
set_property PACKAGE_PIN K8  [get_ports {READOUT3_N[6]}] # modified
set_property PACKAGE_PIN J9  [get_ports {READOUT3_P[7]}] # modified
set_property PACKAGE_PIN H9  [get_ports {READOUT3_N[7]}] # modified

set_property PACKAGE_PIN H19 [get_ports {READOUT4_P[0]}] # modified
set_property PACKAGE_PIN H18 [get_ports {READOUT4_N[0]}] # modified
set_property PACKAGE_PIN H17 [get_ports {READOUT4_P[1]}] # modified
set_property PACKAGE_PIN H16 [get_ports {READOUT4_N[1]}] # modified
set_property PACKAGE_PIN K16 [get_ports {READOUT4_P[2]}] # modified
set_property PACKAGE_PIN J16 [get_ports {READOUT4_N[2]}] # modified
set_property PACKAGE_PIN G17 [get_ports {READOUT4_P[3]}] # modified
set_property PACKAGE_PIN G16 [get_ports {READOUT4_N[3]}] # modified
set_property PACKAGE_PIN F15 [get_ports {READOUT4_P[4]}] # modified
set_property PACKAGE_PIN F14 [get_ports {READOUT4_N[4]}] # modified
set_property PACKAGE_PIN E15 [get_ports {READOUT4_P[5]}] # modified
set_property PACKAGE_PIN D15 [get_ports {READOUT4_N[5]}] # modified
set_property PACKAGE_PIN D14 [get_ports {READOUT4_P[6]}] # modified
set_property PACKAGE_PIN C14 [get_ports {READOUT4_N[6]}] # modified
set_property PACKAGE_PIN G15 [get_ports {READOUT4_P[7]}] # modified
set_property PACKAGE_PIN G14 [get_ports {READOUT4_N[7]}] # modified

# I2C PicoTDC *
set_property PACKAGE_PIN K13 [get_ports SCL_PICOTDC] # modified
set_property IOSTANDARD LVCMOS12 [get_ports SCL_PICOTDC]
set_property DRIVE 4 [get_ports SCL_PICOTDC]

set_property PACKAGE_PIN L13 [get_ports SDA_PICOTDC] # modified
set_property IOSTANDARD LVCMOS12 [get_ports SDA_PICOTDC]
set_property DRIVE 4 [get_ports SDA_PICOTDC]

# PicoTDC Resets *
set_property IOSTANDARD DIFF_SSTL12 [get_ports RESET_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports RESET_N]
set_property PACKAGE_PIN C27 [get_ports RESET_P] # modified
set_property PACKAGE_PIN B27 [get_ports RESET_N] # modified

set_property IOSTANDARD DIFF_SSTL12 [get_ports BX_RESET_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports BX_RESET_N]
set_property PACKAGE_PIN E28 [get_ports BX_RESET_P] # modified
set_property PACKAGE_PIN D29 [get_ports BX_RESET_N] # modified

set_property IOSTANDARD DIFF_SSTL12 [get_ports EID_RESET_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports EID_RESET_N]
set_property PACKAGE_PIN F27 [get_ports EID_RESET_P] # modified
set_property PACKAGE_PIN E27 [get_ports EID_RESET_N] # modified

# PicoTDC Trigger *
set_property IOSTANDARD DIFF_SSTL12 [get_ports TRIGGER_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports TRIGGER_N]
set_property PACKAGE_PIN D28 [get_ports TRIGGER_P] # modified
set_property PACKAGE_PIN C28 [get_ports TRIGGER_N] # modified

# TEST1
set_property IOSTANDARD DIFF_SSTL12 [get_ports TEST1_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports TEST1_N]
set_property PACKAGE_PIN F23 [get_ports TEST1_P] # modified
set_property PACKAGE_PIN F24 [get_ports TEST1_N] # modified

# TEST2
set_property IOSTANDARD DIFF_SSTL12 [get_ports TEST2_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports TEST2_N]
set_property PACKAGE_PIN E25 [get_ports TEST2_P] # modified
set_property PACKAGE_PIN D25 [get_ports TEST2_N] # modified
