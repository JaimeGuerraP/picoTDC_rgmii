
# PART is xc7vx485tffg1761-1

############################################################
# Clock Period Constraints                                 #
############################################################

#
####
#######
##########
#############
#################
#BLOCK CONSTRAINTS

############################################################
# None
############################################################


#
####
#######
##########
#############
#################
#CORE CONSTRAINTS



############################################################
# Crossing of Clock Domain Constraints: please do not edit #
############################################################

# control signal is synced separately so we want a max delay to ensure the signal has settled by the time the control signal has passed through the synch
set_max_delay -from [get_cells {tri_eth_gmii_v7_core/flow/rx_pause/pause*to_tx_reg[*]}] -to [get_cells {tri_eth_gmii_v7_core/flow/tx_pause/count_set*reg}] 32 -datapath_only
set_max_delay -from [get_cells {tri_eth_gmii_v7_core/flow/rx_pause/pause*to_tx_reg[*]}] -to [get_cells {tri_eth_gmii_v7_core/flow/tx_pause/pause_count*reg[*]}] 32 -datapath_only
set_max_delay -from [get_cells {tri_eth_gmii_v7_core/flow/rx_pause/pause_req_to_tx_int_reg}] -to [get_cells {tri_eth_gmii_v7_core/flow/tx_pause/sync_good_rx/data_sync_reg0}] 6 -datapath_only



# false path due to synced control path
set_max_delay -from [get_cells {tri_eth_gmii_v7_core/*statistics_counters/rd_data_ref_reg[*]}] -to [get_cells {tri_eth_gmii_v7_core/*statistics_counters/ip2bus_data_reg[*]}] 6 -datapath_only
set_max_delay -from [get_cells {tri_eth_gmii_v7_core/*statistics_counters/response_toggle_reg}] -to [get_cells {tri_eth_gmii_v7_core/*statistics_counters/sync_response/data_sync_reg0}] 6 -datapath_only
set_max_delay -from [get_cells {tri_eth_gmii_v7_core/*statistics_counters/request_toggle_reg}] -to [get_cells {tri_eth_gmii_v7_core/*statistics_counters/sync_request/data_sync_reg0}] 6 -datapath_only


############################################################
# Ignore paths to resync flops
############################################################
set_false_path -to [get_pins -hier -filter {NAME =~ */async_rst*/PRE}]
set_false_path -to [get_pins -hier -filter {NAME =~ */async_rst*/CLR}]

set_max_delay -from [get_cells {tri_eth_gmii_v7_core/addr_filter_top/addr_regs.promiscuous_mode_reg_reg}] -to [get_cells {tri_eth_gmii_v7_core/addr_filter_top/address_filter_inst/resync_promiscuous_mode/data_sync_reg0}] 6 -datapath_only
set_max_delay -from [get_cells {tri_eth_gmii_v7_core/*managen/conf/update_pause_ad_int_reg}] -to [get_cells {tri_eth_gmii_v7_core/addr_filter_top/address_filter_inst/sync_update/data_sync_reg0}] 6 -datapath_only

# the mdio interface is clocked from the axi clock but the clock is so slow is can be considered to be data
# the data related outputs are output on the falling edge of the MDC output so both can simply be considered to be multicycle paths
set_multicycle_path 10 -setup -from [get_cells {tri_eth_gmii_v7_core/*managen/mdio_enabled.miim_clk_int_reg}  ] -throu [get_ports mdc]
set_multicycle_path 9 -hold -from   [get_cells {tri_eth_gmii_v7_core/*managen/mdio_enabled.miim_clk_int_reg}  ] -throu [get_ports mdc]
set_multicycle_path 10 -setup -from [get_cells {tri_eth_gmii_v7_core/*managen/mdio_enabled.phy/enable_reg_reg}] -throu [get_ports mdc]
set_multicycle_path 9 -hold -from   [get_cells {tri_eth_gmii_v7_core/*managen/mdio_enabled.phy/enable_reg_reg}] -throu [get_ports mdc]
set_multicycle_path 10 -setup -from [get_cells {tri_eth_gmii_v7_core/*managen/mdio_enabled.phy/mdio*reg}      ] -throu [get_ports mdio]
set_multicycle_path 9 -hold -from   [get_cells {tri_eth_gmii_v7_core/*managen/mdio_enabled.phy/mdio*reg}      ] -throu [get_ports mdio]
# mdio has timing implications but slow interface so relaxed
set_false_path  -to [get_cells -hier -filter {NAME =~ *managen/mdio_enabled.phy/mdio_in_reg1_reg}]


