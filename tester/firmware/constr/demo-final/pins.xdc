# XDC for the picoTDC Demo board EDA-04186-v2
# DPo
# 09.05.20222

# ------------------------
# VC707 BOARD CONNECTIONS
# ------------------------

# IPBUS + VC707 SYSTEM
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

set_false_path -to [get_ports {leds[*]} -filter {direction != in}]
set_false_path -from [get_ports {dip_sw[*]} -filter {direction != out}]

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

#set_property DCI_CASCADE {35} [get_iobanks 34]
set_property DCI_CASCADE {17 18} [get_iobanks 19]
# set_property DCI_CASCADE {35 36} [get_iobanks 34 33] # DPo
set_property DCI_CASCADE {35 36} [get_iobanks 34]

# SMA input hits and FMC driver
set_property IOSTANDARD LVDS [get_ports USER_SMA_CLOCK_P]
set_property PACKAGE_PIN AJ32 [get_ports USER_SMA_CLOCK_P]
set_property PACKAGE_PIN AK32 [get_ports USER_SMA_CLOCK_N]
set_property IOSTANDARD LVDS [get_ports USER_SMA_CLOCK_N]

set_property IOSTANDARD LVDS [get_ports USER_SMA_GPIO_P]
set_property IOSTANDARD LVDS [get_ports USER_SMA_GPIO_N]
set_property PACKAGE_PIN AN31 [get_ports USER_SMA_GPIO_P]
set_property PACKAGE_PIN AP31 [get_ports USER_SMA_GPIO_N]
set_property DIFF_TERM TRUE [get_ports USER_SMA_GPIO_N]
set_property DIFF_TERM TRUE [get_ports USER_SMA_GPIO_P]

# -----------------------------
# VC707 FMC CONNECTIONS
# -----------------------------

# I2C Board Control *
set_property PACKAGE_PIN AT35 [get_ports SCL_VC707_CARRIER]
set_property IOSTANDARD LVCMOS18 [get_ports SCL_VC707_CARRIER]
set_property DRIVE 4 [get_ports SCL_VC707_CARRIER]
set_property PULLUP true [get_ports SCL_VC707_CARRIER]

set_property PACKAGE_PIN AU32 [get_ports SDA_VC707_CARRIER]
set_property IOSTANDARD LVCMOS18 [get_ports SDA_VC707_CARRIER]
set_property DRIVE 4 [get_ports SDA_VC707_CARRIER]
set_property PULLUP true [get_ports SDA_VC707_CARRIER]


# Readout Sync *
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports SYNC_P]
set_property PACKAGE_PIN AD40 [get_ports SYNC_P]
set_property PACKAGE_PIN AD41 [get_ports SYNC_N]
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

set_property PACKAGE_PIN Y39 [get_ports {READOUT_P[0]}]
set_property PACKAGE_PIN AA39 [get_ports {READOUT_N[0]}]
set_property PACKAGE_PIN AJ40 [get_ports {READOUT_P[1]}]
set_property PACKAGE_PIN AJ41 [get_ports {READOUT_N[1]}]
set_property PACKAGE_PIN AF41 [get_ports {READOUT_P[2]}]
set_property PACKAGE_PIN AG41 [get_ports {READOUT_N[2]}]
set_property PACKAGE_PIN V33  [get_ports {READOUT_P[3]}]
set_property PACKAGE_PIN V34  [get_ports {READOUT_N[3]}]
set_property PACKAGE_PIN AF42 [get_ports {READOUT_P[4]}]
set_property PACKAGE_PIN AG42 [get_ports {READOUT_N[4]}]
set_property PACKAGE_PIN AJ38 [get_ports {READOUT_P[5]}]
set_property PACKAGE_PIN AK38 [get_ports {READOUT_N[5]}]
set_property PACKAGE_PIN U32 [get_ports {READOUT_P[6]}]
set_property PACKAGE_PIN U33 [get_ports {READOUT_N[6]}]
set_property PACKAGE_PIN AD38 [get_ports {READOUT_P[7]}]
set_property PACKAGE_PIN AE38 [get_ports {READOUT_N[7]}]

set_property PACKAGE_PIN R38 [get_ports {READOUT2_P[0]}]
set_property PACKAGE_PIN R39 [get_ports {READOUT2_N[0]}]
set_property PACKAGE_PIN Y42 [get_ports {READOUT2_P[1]}]
set_property PACKAGE_PIN AA42 [get_ports {READOUT2_N[1]}]
set_property PACKAGE_PIN W40 [get_ports {READOUT2_P[2]}]
set_property PACKAGE_PIN Y40 [get_ports {READOUT2_N[2]}]
set_property PACKAGE_PIN AC38 [get_ports {READOUT2_P[3]}]
set_property PACKAGE_PIN AC39 [get_ports {READOUT2_N[3]}]
set_property PACKAGE_PIN U37 [get_ports {READOUT2_P[4]}]
set_property PACKAGE_PIN U38 [get_ports {READOUT2_N[4]}]
set_property PACKAGE_PIN U36 [get_ports {READOUT2_P[5]}]
set_property PACKAGE_PIN T37 [get_ports {READOUT2_N[5]}]
set_property PACKAGE_PIN P32 [get_ports {READOUT2_P[6]}]
set_property PACKAGE_PIN P33 [get_ports {READOUT2_N[6]}]
set_property PACKAGE_PIN W32 [get_ports {READOUT2_P[7]}]
set_property PACKAGE_PIN W33 [get_ports {READOUT2_N[7]}]

set_property PACKAGE_PIN P35 [get_ports {READOUT3_P[0]}]
set_property PACKAGE_PIN P36 [get_ports {READOUT3_N[0]}]
set_property PACKAGE_PIN N33 [get_ports {READOUT3_P[1]}]
set_property PACKAGE_PIN N34 [get_ports {READOUT3_N[1]}]
set_property PACKAGE_PIN R33 [get_ports {READOUT3_P[2]}]
set_property PACKAGE_PIN R34 [get_ports {READOUT3_N[2]}]
set_property PACKAGE_PIN U34 [get_ports {READOUT3_P[3]}]
set_property PACKAGE_PIN T35 [get_ports {READOUT3_N[3]}]
set_property PACKAGE_PIN V39 [get_ports {READOUT3_P[4]}]
set_property PACKAGE_PIN V40 [get_ports {READOUT3_N[4]}]
set_property PACKAGE_PIN V35 [get_ports {READOUT3_P[5]}]
set_property PACKAGE_PIN V36 [get_ports {READOUT3_N[5]}]
set_property PACKAGE_PIN T32 [get_ports {READOUT3_P[6]}]
set_property PACKAGE_PIN R32 [get_ports {READOUT3_N[6]}]
set_property PACKAGE_PIN W36 [get_ports {READOUT3_P[7]}]
set_property PACKAGE_PIN W37 [get_ports {READOUT3_N[7]}]

set_property PACKAGE_PIN AC30 [get_ports {READOUT4_P[0]}]
set_property PACKAGE_PIN AD30 [get_ports {READOUT4_N[0]}]
set_property PACKAGE_PIN AB36 [get_ports {READOUT4_P[1]}]
set_property PACKAGE_PIN AB37 [get_ports {READOUT4_N[1]}]
set_property PACKAGE_PIN AB31 [get_ports {READOUT4_P[2]}]
set_property PACKAGE_PIN AB32 [get_ports {READOUT4_N[2]}]
set_property PACKAGE_PIN AC34 [get_ports {READOUT4_P[3]}]
set_property PACKAGE_PIN AD35 [get_ports {READOUT4_N[3]}]
set_property PACKAGE_PIN AF31 [get_ports {READOUT4_P[4]}]
set_property PACKAGE_PIN AF32 [get_ports {READOUT4_N[4]}]
set_property PACKAGE_PIN AA34 [get_ports {READOUT4_P[5]}]
set_property PACKAGE_PIN AA35 [get_ports {READOUT4_N[5]}]
set_property PACKAGE_PIN Y35  [get_ports {READOUT4_P[6]}]
set_property PACKAGE_PIN AA36 [get_ports {READOUT4_N[6]}]
set_property PACKAGE_PIN Y37  [get_ports {READOUT4_P[7]}]
set_property PACKAGE_PIN AA37 [get_ports {READOUT4_N[7]}]

# I2C PicoTDC *
set_property PACKAGE_PIN P38 [get_ports SCL_PICOTDC]
set_property IOSTANDARD LVCMOS12 [get_ports SCL_PICOTDC]
set_property DRIVE 4 [get_ports SCL_PICOTDC]

set_property PACKAGE_PIN P37 [get_ports SDA_PICOTDC]
set_property IOSTANDARD LVCMOS12 [get_ports SDA_PICOTDC]
set_property DRIVE 4 [get_ports SDA_PICOTDC]

# PicoTDC Resets *
set_property IOSTANDARD DIFF_SSTL12 [get_ports RESET_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports RESET_N]
set_property PACKAGE_PIN AL41 [get_ports RESET_P]
set_property PACKAGE_PIN AL42 [get_ports RESET_N]

set_property IOSTANDARD DIFF_SSTL12 [get_ports BX_RESET_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports BX_RESET_N]
set_property PACKAGE_PIN AK39 [get_ports BX_RESET_P]
set_property PACKAGE_PIN AL39 [get_ports BX_RESET_N]

set_property IOSTANDARD DIFF_SSTL12 [get_ports EID_RESET_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports EID_RESET_N]
set_property PACKAGE_PIN AC40 [get_ports EID_RESET_P]
set_property PACKAGE_PIN AC41 [get_ports EID_RESET_N]

# PicoTDC Trigger *
set_property IOSTANDARD DIFF_SSTL12 [get_ports TRIGGER_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports TRIGGER_N]
set_property PACKAGE_PIN AJ42 [get_ports TRIGGER_P]
set_property PACKAGE_PIN AK42 [get_ports TRIGGER_N]

# TEST1
set_property IOSTANDARD DIFF_SSTL12 [get_ports TEST1_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports TEST1_N]
set_property PACKAGE_PIN AB41 [get_ports TEST1_P]
set_property PACKAGE_PIN AB42 [get_ports TEST1_N]

# TEST2
set_property IOSTANDARD DIFF_SSTL12 [get_ports TEST2_P]
set_property IOSTANDARD DIFF_SSTL12 [get_ports TEST2_N]
set_property PACKAGE_PIN AF39 [get_ports TEST2_P]
set_property PACKAGE_PIN AF40 [get_ports TEST2_N]
