# Template for all targets, containing IP/RTL files
design_tpl = {
    'IPFiles': """ip/fifo_axi4_mac/fifo_axi4_mac.xci
                  ip/sgmii_eth_v7/sgmii_eth_v7.xci
                  ip/tri_eth_gmii_v7/tri_eth_gmii_v7.xci
                  ip/highSpeedSerialTXRX/highSpeedSerialTXRX.xci
                  ip/uplink_data_ila/uplink_data_ila.xci
                  ip/ipbus_intf_fifo/ipbus_intf_fifo.xci
               """,
    'SimLibs': 'unisim:simlibs/unisim,secureip:simlibs/secureip',
    'VRFFiles': 'vrf/tb_package.sv,vrf/tb_constants.sv',
    'TopRTLFile': 'components/lpgbt-tester/rtl/lpgbt-tester.vhd',
    'SynthMode': 'top',
    'TargetSynth': 'vivado',
    'TargetBoard': 'xilinx.com:vc707:part0:1.3',
    'DesignName': 'lpgbt_fpga_tester',
    'TargetCore': 'xc7vx485tffg1761-2',
    'TopVRFFile': 'vrf/tb_top_lpgbt_fpga_master.sv',
    'RTLFiles': """components/opencores_spi/rtl
                   components/ipbus-slave-ePortClkMon/rtl/
                   components/ipbus-slave-gpio/rtl
                   components/ipbus-slave-led/rtl
                   components/lpgbt-tester/rtl/
                   components/ipbus-slave-downlinkGenerator/rtl
                   components/ipbus-slave-datapath/rtl
                   ipbus-firmware/components/ipbus_util/firmware/hdl/ipbus_clock_div.vhd
                   ipbus-firmware/components/ipbus_util/firmware/hdl/led_stretcher.vhd
                   ipbus-firmware/components/ipbus_eth/firmware/hdl/emac_hostbus_decl.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/ipbus_trans_decl.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/trans_arb.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_build_resend.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_dualportram_rx.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_packet_parser.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_status_buffer.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/ipbus_ctrl.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/transactor_cfg.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_buffer_selector.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_build_status.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_dualportram_tx.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_rarp_block.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_tx_mux.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/ipbus_package.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/transactor_if.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_build_arp.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_byte_sum.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_dualportram.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_rxram_mux.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_txtransactor_if_simple.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/transactor_sm.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_build_payload.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_clock_crossing_if.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_if_flat.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_rxram_shim.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/transactor.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_build_ping.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_do_rx_reset.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_ipaddr_block.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/udp_rxtransactor_if_simple.vhd
                   ipbus-firmware/components/ipbus_slaves/firmware/hdl/ipbus_reg_types.vhd
                   ipbus-firmware/components/ipbus_core/firmware/hdl/ipbus_fabric_sel.vhd
                   components/lpgbt-fpga/
                   components/ipbus-slave-resetOutMonitor/rtl
                   components/reset_synch/rtl
                   components/prbs/rtl
                   components/ipbus-slave-ePortRxDriver/rtl
                   components/ipbus-slave-uplinkChecker/rtl
                   components/ipbus-i2c-master
                   components/ipbus-slave-ePortTxMon/rtl
                   components/ipbus_intf/rtl
                   components/ipbus-slave-daq/rtl
                   components/ipbus-slave-clkSEUMon/rtl
                   components/ipbus-slave-i2cslave/rtl
                   components/ipbus-slave-ic/rtl
                   components/gbt-sc/GBT-SC/IC
                   components/ipbus-slave-ec/rtl
                   components/ipbus-slave-freqCounter/rtl/ipbus_freqCounter.vhd
                """,
    'TargetLang': 'vhdl',
    'TargetSimul': 'questa'}

designs = {}
# generate targets for different mezzanine versions
for target_name, xdc_file in [
        ("lpgbt_tester_prod", "constr/pins_mezzanine_prod.xdc"),
        ("lpgbt_tester_v12", "constr/pins_mezzanine_v12.xdc")
    ]:
    designs[target_name] = design_tpl.copy()
    designs[target_name]["ConstrFiles"] = """%s
                      constr/timing.xdc
                      constr/timing_sc.xdc
                      constr/timing_datapath.xdc
                      constr/timing_ePortRxDriver.xdc
                      constr/timing_upChecker.xdc
                      constr/timing_eportTxMon.xdc
                      constr/timing_clkSEUMon.xdc
                      constr/timing_downlinkGenerator.xdc
                      constr/timing_ePortClkMon.xdc
                      constr/timing_freqCounter.xdc
                   """ % xdc_file
