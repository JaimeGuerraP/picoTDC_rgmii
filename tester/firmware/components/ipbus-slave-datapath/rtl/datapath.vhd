-----------------------------------------------------------------------------------------------------------------
--                                                                                                             --
--                                                                                                             --
--  Module that implements the complimentary Datapath and Gigabit interfaces for multigigabit comm. with lpgbt --
--                                                                                                             --
--  Jose Pedro Castro Fonseca, CERN, EP-ESE-ME, October 2018                                                    --
--                                                                                                             --
--                                                                                                             --
-----------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

--! Include the LpGBT-FPGA specific package
use work.lpgbtfpga_package.all;

-- For simulation of Xilinx models of GTXE2
library UNISIM;
use UNISIM.vcomponents.all;

entity datapath is
    port (
        signal refClkGTX_320M_n : in  std_logic;
        signal refClkGTX_320M_p : in  std_logic;
        signal clk40MHz_TX      : out std_logic;
        signal clk40MHz_RX      : out std_logic;
        signal hsUpLink_p_i     : in  std_logic;
        signal hsUpLink_n_i     : in  std_logic;
        signal hsDnLink_p_o     : out std_logic;     
        signal hsDnLink_n_o     : out std_logic;      

        -- Data TO the Downlink Tx
        signal userDataDnLink   : in  std_logic_vector(31 downto 0);
        signal icDataDnLink     : in  std_logic_vector(1  downto 0); 
        signal ecDataDnLink     : in  std_logic_vector(1  downto 0); 
        
        -- Data FROM the Uplink Rx
        signal userDataUpLink   : out std_logic_vector(229 downto 0);
        signal icDataUpLink     : out std_logic_vector(1   downto 0); 
        signal ecDataUpLink     : out std_logic_vector(1   downto 0); 

        -- Register interface
        signal statusBus        : out std_logic_vector(31 downto 0);
        signal controlBus       : in  std_logic_vector(31 downto 0);
        signal controlBusDnLink : in  std_logic_vector(31 downto 0);
        signal controlBusUpLink : in  std_logic_vector(31 downto 0)
    );
end datapath;

architecture rtl of datapath is

    component highSpeedSerialTXRX
        port
        (
            SOFT_RESET_TX_IN                        : in   std_logic;
            SOFT_RESET_RX_IN                        : in   std_logic;
            DONT_RESET_ON_DATA_ERROR_IN             : in   std_logic;
            Q0_CLK1_GTREFCLK_PAD_N_IN               : in   std_logic;
            Q0_CLK1_GTREFCLK_PAD_P_IN               : in   std_logic;

            GT0_TX_FSM_RESET_DONE_OUT               : out  std_logic;
            GT0_RX_FSM_RESET_DONE_OUT               : out  std_logic;
            GT0_DATA_VALID_IN                       : in   std_logic;
            GT0_TX_MMCM_LOCK_OUT                    : out  std_logic;
         
            GT0_TXUSRCLK_OUT                        : out  std_logic;
            GT0_TXUSRCLK2_OUT                       : out  std_logic;
            GT0_RXUSRCLK_OUT                        : out  std_logic;
            GT0_RXUSRCLK2_OUT                       : out  std_logic;

            --_________________________________________________________________________
            --GT0  (X0Y0)
            --____________________________CHANNEL PORTS________________________________
            ---------------------------- Channel - DRP Ports  --------------------------
            gt0_drpaddr_in                          : in   std_logic_vector(8 downto 0);
            gt0_drpdi_in                            : in   std_logic_vector(15 downto 0);
            gt0_drpdo_out                           : out  std_logic_vector(15 downto 0);
            gt0_drpen_in                            : in   std_logic;
            gt0_drprdy_out                          : out  std_logic;
            gt0_drpwe_in                            : in   std_logic;
            --------------------------- Digital Monitor Ports --------------------------
            gt0_dmonitorout_out                     : out  std_logic_vector(7 downto 0);
            --------------------- RX Initialization and Reset Ports --------------------
            gt0_eyescanreset_in                     : in   std_logic;
            gt0_rxuserrdy_in                        : in   std_logic;
            -------------------------- RX Margin Analysis Ports ------------------------
            gt0_eyescandataerror_out                : out  std_logic;
            gt0_eyescantrigger_in                   : in   std_logic;
            ------------------ Receive Ports - FPGA RX interface Ports -----------------
            gt0_rxdata_out                          : out  std_logic_vector(31 downto 0);
            --------------------------- Receive Ports - RX AFE -------------------------
            gt0_gtxrxp_in                           : in   std_logic;
            ------------------------ Receive Ports - RX AFE Ports ----------------------
            gt0_gtxrxn_in                           : in   std_logic;
            --------------------- Receive Ports - RX Equalizer Ports -------------------
            gt0_rxdfelpmreset_in                    : in   std_logic;
            gt0_rxmonitorout_out                    : out  std_logic_vector(6 downto 0);
            gt0_rxmonitorsel_in                     : in   std_logic_vector(1 downto 0);
            --------------- Receive Ports - RX Fabric Output Control Ports -------------
            gt0_rxoutclkfabric_out                  : out  std_logic;
            ------------- Receive Ports - RX Initialization and Reset Ports ------------
            gt0_gtrxreset_in                        : in   std_logic;
            gt0_rxpmareset_in                       : in   std_logic;
            gt0_rxslide_in                          : in   std_logic;
            -------------- Receive Ports -RX Initialization and Reset Ports ------------
            gt0_rxresetdone_out                     : out  std_logic;
            --------------------- TX Initialization and Reset Ports --------------------
            gt0_gttxreset_in                        : in   std_logic;
            gt0_txuserrdy_in                        : in   std_logic;
            ------------------ Transmit Ports - TX Data Path interface -----------------
            gt0_txdata_in                           : in   std_logic_vector(63 downto 0);
            ---------------- Transmit Ports - TX Driver and OOB signaling --------------
            gt0_gtxtxn_out                          : out  std_logic;
            gt0_gtxtxp_out                          : out  std_logic;
            ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
            gt0_txoutclkfabric_out                  : out  std_logic;
            gt0_txoutclkpcs_out                     : out  std_logic;
            ------------- Transmit Ports - TX Initialization and Reset Ports -----------
            gt0_txresetdone_out                     : out  std_logic;

            --____________________________COMMON PORTS________________________________
            GT0_QPLLLOCK_OUT        : out std_logic;
            GT0_QPLLREFCLKLOST_OUT  : out std_logic;
            GT0_QPLLOUTCLK_OUT      : out std_logic;
            GT0_QPLLOUTREFCLK_OUT   : out std_logic;

            -- Clock for internal state machines TODO what value should be used?
            sysclk_in                               : in   std_logic

        );
    end component;

    -- Connection signals to the Multi-Gigabit Transceiver
    signal SOFT_RESET_TX_IN : std_logic;
    signal hsUpLink_p       : std_logic;
    signal hsUpLink_n       : std_logic;
    signal hsDnLink_p       : std_logic;
    signal hsDnLink_n       : std_logic;
    signal txRefClk_qPLL    : std_logic;
    signal rxRefClk_qPLL    : std_logic;
    signal rxuserrdy        : std_logic;
    signal txuserrdy        : std_logic;
    signal gtrxreset        : std_logic;
    signal gttxreset        : std_logic;
    signal rxresetdone      : std_logic;
    signal txresetdone      : std_logic;
    signal rxpmareset       : std_logic;
    signal rxdfelpmreset    : std_logic;
    signal eyescanreset     : std_logic;

    signal rx_softreset          : std_logic;
    signal tx_softreset          : std_logic;
    signal tx_fsm_reset_done_out : std_logic;
    signal rx_fsm_reset_done_out : std_logic;
    signal rx_data_valid         : std_logic;
    signal mmcmLock              : std_logic_vector(1 downto 0);
    signal qPLLstatus            : std_logic_vector(3 downto 0);
    signal rxslide_in            : std_logic;
    signal clk40MHz              : std_logic;
    signal clk80MHz              : std_logic;
    signal clk320MHz             : std_logic;

    signal refClkGTX_320M_n_buf : std_logic;
    signal refClkGTX_320M_p_buf : std_logic;

    -- Connections to the Donwlink Data Path
    signal enableDnLink      : std_logic;
    signal resetDnLink       : std_logic;
    signal data_to_fpga_tx   : std_logic_vector(63 downto 0);
    signal bypassIntlvDnLink : std_logic;
    signal bypassFecCdDnLink : std_logic;
    signal bypassScramDnLink : std_logic;   
    signal readyDnLink       : std_logic;

    -- Connections to the Uplink Data Path
    signal enableUpLink         : std_logic;
    signal resetUpLink          : std_logic;
    signal resetRxGearbox       : std_logic;
    signal upLinkFrame          : std_logic_vector(255 downto 0);
    signal upLinkFrame5G        : std_logic_vector(255 downto 0);
    signal upLinkFrame10G       : std_logic_vector(255 downto 0);
    signal bypassIntlvUpLink    : std_logic;
    signal bypassFecCdUpLink    : std_logic;
    signal bypassScramUpLink    : std_logic;   
    signal dataRateUpLink       : std_logic;
    signal fecModeUpLink        : std_logic;
    signal data_fr_fpga_rx      : std_logic_vector(31 downto 0);
    signal readyUpLink          : std_logic;
    signal resetFrameAligner    : std_logic;
    signal rxGbReady5G          : std_logic;
    signal rxGbReady10G         : std_logic;
    signal rxSlide              : std_logic;
    signal rxSlideSync          : std_logic;
    signal rxSlide5G            : std_logic;
    signal rxSlide10G           : std_logic;
    signal rxFALocked           : std_logic;
    signal rxFALocked5G         : std_logic;
    signal rxFALocked10G        : std_logic;
    signal clk_dataFlag_rxgb5G  : std_logic;
    signal clk_dataFlag_rxgb10G : std_logic;
    signal gbDataFlag           : std_logic;
    signal sta_headerFlag_10g24 : std_logic;
    signal headerAt10G          : std_logic_vector(1 downto 0);
    signal headerAt5G           : std_logic_vector(3 downto 0);

    -- Signals for the Rx 40MHz clock generator
    type SM is (IDLE, LOW, HIGH);
    signal stateClkGen      : SM;
    signal next_stateClkGen : SM;
    signal counter          : unsigned (2 downto 0);
    signal nextcounter      : unsigned (2 downto 0);
    signal upLinkClkOutEn   : std_logic;
    signal clk40MHz_RX_o    : std_logic;
    signal clk40MHz_RX_buf    : std_logic;
    
    begin
        -- The serial links
        hsDnLink_p_o <= hsDnLink_p;
        hsDnLink_n_o <= hsDnLink_n;
        hsUpLink_p   <= hsUpLink_p_i;
        hsUpLink_n   <= hsUpLink_n_i;

        -- The clocks coming from the module
        clk40MHz_TX   <= clk40MHz;

        -- The Reset signals TODO currently all merged in a single one
        tx_softReset  <= controlBus(0);
        gttxreset     <= controlBus(1);
        rx_softReset  <= controlBus(2);
        gtrxreset     <= controlBus(3);
        rxuserrdy     <= controlBus(4);
        rxpmareset    <= controlBus(5);
        rxdfelpmreset <= controlBus(6);
        eyescanreset  <= controlBus(7);   

        -- The status register
        statusBus(0)  <= tx_fsm_reset_done_out;
        statusBus(1)  <= txresetdone;
        statusBus(2)  <= mmcmLock(0);   -- Tx MMCM
        statusBus(3)  <= rx_fsm_reset_done_out;
        statusBus(4)  <= rxresetdone;
        statusBus(5)  <= '1';   -- RX MMCM
        statusBus(6)  <= qPLLstatus(0); -- QPLL Locked
        statusBus(7)  <= qPLLstatus(1); -- QPLL Reference Clock Lost
        statusBus(8)  <= readyDnLink;
        statusBus(9)  <= readyUpLink;
        statusBus(10) <= rxGbReady5G;
        statusBus(11) <= rxGbReady10G;
        statusBus(12) <= rxFALocked5G;
        statusBus(13) <= rxFALocked10G;
        statusBus(14) <= rxSlide5G;
        statusBus(15) <= rxSlide10G;
        statusBus(31 downto 16) <= (others => '0');

        -- Downlink Control Bus
        enableDnLink      <= controlBusDnLink(0);
        resetDnLink       <= controlBusDnLink(1);
        bypassIntlvDnLink <= controlBusDnLink(2);
        bypassFecCdDnLink <= controlBusDnLink(3);
        bypassScramDnLink <= controlBusDnLink(4);

        -- Uplink Control Bus
        enableUpLink      <= controlBusUpLink(0);
        resetUpLink       <= controlBusUpLink(1);
        bypassIntlvUpLink <= controlBusUpLink(2);
        bypassFecCdUpLink <= controlBusUpLink(3);
        bypassScramUpLink <= controlBusUpLink(4);
        dataRateUpLink    <= controlBusUpLink(5);
        fecModeUpLink     <= controlBusUpLink(6);
        resetRxGearbox    <= controlBusUpLink(7);
        resetRxGearbox    <= controlBusUpLink(8);
        resetFrameAligner <= controlBusUpLink(9);

        -- IBUFs for IBUFDS
        IBUF_refclk_p : IBUF
            port map (
                I => refClkGTX_320M_p,
                O => refClkGTX_320M_p_buf
            );
        IBUF_refclk_n : IBUF
            port map (
                I => refClkGTX_320M_n,
                O => refClkGTX_320M_n_buf
            );


        --_________________________ The Multi-Gigabit Transceiver Instantiation -- Config Generated by the Xilinx's Core Wizard _________________________--
        highSpeedSerialTXRX_i : highSpeedSerialTXRX 
            port map
            (   
                -- User Reset for the Tx part of Transceiver
                SOFT_RESET_TX_IN => tx_softReset,                        

                -- User Reset for the Rx part of Transceiver
                SOFT_RESET_RX_IN => rx_softReset,

                -- Prevents the Rx to reset when there is an error in incoming data
                DONT_RESET_ON_DATA_ERROR_IN => '1',
                
                -- TODO check: Reference clock to then be used by the MMCM clock. This is actually unused, so left open
                Q0_CLK1_GTREFCLK_PAD_N_IN => refClkGTX_320M_n_buf,
                Q0_CLK1_GTREFCLK_PAD_P_IN => refClkGTX_320M_p_buf,

                -- State-machine reset done signal
                GT0_TX_FSM_RESET_DONE_OUT => tx_fsm_reset_done_out,
                GT0_RX_FSM_RESET_DONE_OUT => rx_fsm_reset_done_out,

                -- Data valid signal
                GT0_DATA_VALID_IN => '1', --rx_data_valid,

                -- Lock signals from MMCM blocks
                GT0_TX_MMCM_LOCK_OUT => mmcmLock(0),

                -- 80MHz clock
                GT0_TXUSRCLK_OUT => clk80MHz,

                -- 40MHz clock
                GT0_TXUSRCLK2_OUT => clk40MHz,

                -- 320MHz clock
                GT0_RXUSRCLK_OUT => clk320MHz,

                -- Same as above...
                GT0_RXUSRCLK2_OUT => open,

                ---------------------------- Channel - DRP Ports  --------------------------
                    gt0_drpaddr_in                  =>      B"000000000",
                    gt0_drpdi_in                    =>      X"0000",
                    gt0_drpdo_out                   =>      open,
                    gt0_drpen_in                    =>      '0',
                    gt0_drprdy_out                  =>      open,
                    gt0_drpwe_in                    =>      '0',
                --------------------------- Digital Monitor Ports -------------------------- we might use them in the future
                    gt0_dmonitorout_out             =>      open,
                --------------------- RX Initialization and Reset Ports --------------------
                    gt0_eyescanreset_in             =>      eyescanreset,
                    gt0_rxuserrdy_in                =>      rxuserrdy,                   -- TODO 
                -------------------------- RX Margin Analysis Ports ------------------------
                    gt0_eyescandataerror_out        =>      open,
                    gt0_eyescantrigger_in           =>      '0',                                -- TODO TODO TODO
                ------------------ Receive Ports - FPGA RX interface Ports -----------------
                    gt0_rxdata_out                  =>      data_fr_fpga_rx,
                --------------------------- Receive Ports - RX AFE -------------------------
                    gt0_gtxrxp_in                   =>      hsUpLink_p,                 
                    gt0_gtxrxn_in                   =>      hsUpLink_n,
                --------------------- Receive Ports - RX Equalizer Ports -------------------
                    gt0_rxdfelpmreset_in            =>      rxdfelpmreset,                                
                    gt0_rxmonitorout_out            =>      open,
                    gt0_rxmonitorsel_in             =>      B"00",
                --------------- Receive Ports - RX Fabric Output Control Ports -------------
                    gt0_rxoutclkfabric_out          =>      rxRefClk_qPLL,
                ------------- Receive Ports - RX Initialization and Reset Ports ------------
                    gt0_gtrxreset_in                =>      gtrxreset,
                    gt0_rxpmareset_in               =>      rxpmareset,
                    gt0_rxslide_in                  =>      rxSlide,
                -------------- Receive Ports -RX Initialization and Reset Ports ------------
                    gt0_rxresetdone_out             =>      rxresetdone,
                --------------------- TX Initialization and Reset Ports --------------------
                    gt0_gttxreset_in                =>      gttxreset,
                    gt0_txuserrdy_in                =>      '1',
                ------------------ Transmit Ports - TX Data Path interface -----------------
                    gt0_txdata_in                   =>      data_to_fpga_tx,
                ---------------- Transmit Ports - TX Driver and OOB signaling --------------
                    gt0_gtxtxn_out                  =>      hsDnLink_n,
                    gt0_gtxtxp_out                  =>      hsDnLink_p,
                ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
                    gt0_txoutclkfabric_out          =>      txRefClk_qPLL,
                    gt0_txoutclkpcs_out             =>      open,
                ------------- Transmit Ports - TX Initialization and Reset Ports -----------
                    gt0_txresetdone_out             =>      txresetdone,

                --____________________________COMMON PORTS________________________________
                GT0_QPLLLOCK_OUT        => qPLLstatus(0),
                GT0_QPLLREFCLKLOST_OUT  => qPLLstatus(1),
                GT0_QPLLOUTCLK_OUT      => qPLLstatus(2),
                GT0_QPLLOUTREFCLK_OUT   => qPLLstatus(3),

                sysclk_in => qPLLstatus(3)

            );
        --_______________________________________________________________________________________________________________________________________________--

    -- Gearbox for 5G12 Mode
    rxGearboxAt5G : entity work.rxGearbox
        generic map (
            c_clockRatio       =>  8,
            c_inputWidth       =>  32,
            c_outputWidth      =>  128,
            c_counterInitValue =>  3
        )
        port map (
            -- Clocking
            clk_inClk_i     => clk320MHz,
            clk_clkEn_i     => '1', 
            clk_dataFlag_o  => clk_dataFlag_rxgb5G,
            
            -- Reset
            rst_gearbox_i   => resetRxGearbox,

            -- Data
            dat_inFrame_i   => data_fr_fpga_rx, 
            dat_outFrame_o  => upLinkFrame5G, 

            -- Status
            sta_gbRdy_o     =>  rxGbReady5G

        );
        
    -- Gearbox for 10G24 Mode
    rxGearboxAt10G : entity work.rxGearbox
        generic map (
            c_clockRatio       =>  8,
            c_inputWidth       =>  32,
            c_outputWidth      =>  256,
            c_counterInitValue =>  3
        )
        port map (
            -- Clocking
            clk_inClk_i     => clk320MHz,
            clk_clkEn_i     => '1',
            clk_dataFlag_o  => clk_dataFlag_rxgb10G,
            
            -- Reset
            rst_gearbox_i   => resetRxGearbox,

            -- Data
            dat_inFrame_i   => data_fr_fpga_rx, 
            dat_outFrame_o  => upLinkFrame10G, 

            -- Status
            sta_gbRdy_o     => rxGbReady10G

        );


    -- Downlink Datapath (to the FPGA Tx)
    dpDownLink : entity work.LpGBT_FPGA_Downlink_datapath
       port map (
            -- Clocks
            donwlinkClk_i                => clk40MHz,
            downlinkClkEn_i              => enableDnLink,     
            downlinkRst_i                => resetDnLink,
            
            -- Downlink
            downlinkUserData_i           => userDataDnLink,
            downlinkEcData_i             => ecDataDnLink,
            downlinkIcData_i             => icDataDnLink,
           
            -- Output
            downLinkFrame_o              => data_to_fpga_tx,
            
            -- Configuration
            downLinkBypassInterleaver_i  => bypassIntlvDnLink,
            downLinkBypassFECEncoder_i   => bypassFecCdDnLink,
            downLinkBypassScrambler_i    => bypassScramDnLink,
            
            -- Status
            downlinkReady_o              => readyDnLink
       );   

    -- Frame Aligner
    frameAligner5G : entity work.mgt_frameAligner
        generic map (
            c_wordRatio               => 8,
            c_headerPattern           => "1010",
            c_wordSize                => 32,
            c_allowedFalseHeader      => 2,
            c_allowedFalseHeaderOverN => 2,
            c_requiredTrueHeader      => 32,
            c_bitslip_mindly          => 32 
        )
        port map (
            -- Clocks
            clk_pcsRx_i          => clk320MHz,
            clk_freeRunningClk_i => '0',

            -- Reset
            rst_pattsearch_i     => resetFrameAligner,
            rst_mgtctrler_i      => '0',
            rst_rstoneven_o      => open,

            -- Control
            cmd_bitslipCtrl_o       => rxSlide5G,
            cmd_rstonevenoroddsel_i => '0',

            -- Status
            sta_headerLocked_o      => rxFALocked5G,

            -- Data
            dat_word_i => headerAt5G
        );

    frameAligner10G : entity work.mgt_frameAligner
        generic map (
            c_wordRatio               => 8,
            c_headerPattern           => "10",
            c_wordSize                => 32,
            c_allowedFalseHeader      => 2,
            c_allowedFalseHeaderOverN => 2,
            c_requiredTrueHeader      => 32,
            c_bitslip_mindly          => 32
        )
        port map (
            -- Clocks
            clk_pcsRx_i          => clk320MHz,
            clk_freeRunningClk_i => '0',

            -- Reset
            rst_pattsearch_i     => resetFrameAligner,
            rst_mgtctrler_i      => '0',
            rst_rstoneven_o      => open,

            -- Control
            cmd_bitslipCtrl_o       => rxSlide10G,
            cmd_rstonevenoroddsel_i => '0',

            -- Status
            sta_headerLocked_o      => rxFALocked10G,
            sta_headerFlag_o        => sta_headerFlag_10g24,

            -- Data
            dat_word_i => headerAt10G
        );
    
    headerAt10G <= upLinkFrame(255 downto 254);
    headerAt5G  <= upLinkFrame(255 downto 254) & upLinkFrame(127 downto 126);

    -- Selecting the correct frame source according to the datarate mode
    upLinkFrame <= upLinkFrame10G       when dataRateUpLink = '1' else upLinkFrame5G;
    rxSlide     <= rxSlide10G           when dataRateUpLink = '1' else rxSlide5G;
    rxFALocked  <= rxFALocked10G        when dataRateUpLink = '1' else rxFALocked5G;
    gbDataFlag  <= clk_dataFlag_rxgb10G when dataRateUpLink = '1' else clk_dataFlag_rxgb5G;

    -- Uplink Datapath (from the FPGA Rx)
    dpUpLink : entity work.LpGBT_FPGA_Uplink_datapath
        generic map (
            DATARATE         => DYNAMIC,
            FEC              => DYNAMIC
        )
        port map (
            -- Clocks and Reset
            uplinkClk_i                 => clk320MHz, -- TODO clk40MHz divided from 320MHz
            uplinkClkInEn_i             => gbDataFlag,
            uplinkClkOutEn_o            => upLinkClkOutEn, -- TODO --! Clock enable shifted from N clock cycle (clock data out - used by the user's logic)
            uplinkRst_i                 => resetUpLink,   --! Uplink datapath's reset signal

            -- Input
            uplinkFrame_i               => upLinkFrame,    --! Input frame coming from the MGT -> Rx Gearbox.  --! as followind: uplinkFrame_i <= data_5g12 & data_5g12

            -- Data
            uplinkUserData_o            => userDataUpLink, --! User output (decoded data). The payload size varies depending on the
                                                                                     --! datarate/FEC configuration: 
                                                                                     --!     * *FEC5 / 5.12 Gbps*: 112bit
                                                                                     --!     * *FEC12 / 5.12 Gbps*: 98bit
                                                                                     --!     * *FEC5 / 10.24 Gbps*: 230bit
                                                                                     --!     * *FEC12 / 10.24 Gbps*: 202bit
            uplinkEcData_o              => ecDataUpLink,   --! EC field value received from the LpGBT
            uplinkIcData_o              => icDataUpLink,   --! IC field value received from the LpGBT

            -- Control
            uplinkSelectDataRate_i      => dataRateUpLink,          
            uplinkSelectFEC_i           => fecModeUpLink,  --! FEC selection (only in DYNAMIC mode) -> '0': FEC5 / '1': FEC12
            uplinkBypassInterleaver_i   => bypassIntlvUpLink, --! Bypass uplink interleaver (test purpose only)
            uplinkBypassFECEncoder_i    => bypassFecCdUpLink, --! Bypass uplink FEC (test purpose only)
            uplinkBypassScrambler_i     => bypassScramUpLink, --! Bypass uplink scrambler (test purpose only)
            
            -- Status
            uplinkReady_o               => readyUpLink        
        );

        -- The 40MHz clock generator
        clk40MHz_RX_o   <= '1' when stateClkGen = HIGH else '0';
        clk40MHz_RX <= clk40MHz_RX_buf;

        clk40MHZ_RX_bufg : BUFG 
            port map(
                I => clk40MHz_RX_o,
                O => clk40MHz_RX_buf
            );


        process(clk320MHz) begin
            if rising_edge(clk320MHz) then
                stateClkGen <= next_stateClkGen;
                counter <= nextcounter;
            end if;
        end process;

        process(stateClkGen, upLinkClkOutEn, counter) begin
            case (stateClkGen) is
                when IDLE =>
                    nextcounter <= B"000";
                    if (upLinkClkOutEn = '1') then
                        next_stateClkGen <= HIGH;
                    else
                        next_stateClkGen <= LOW; 
                    end if;
                when HIGH =>
                    if (counter = 3) then
                        nextcounter <= counter + 1;
                        next_stateClkGen <= LOW;
                    else
                        nextcounter <= counter + 1;
                        next_stateClkGen <= HIGH;
                    end if;
                when LOW =>
                    if (upLinkClkOutEn = '1') then
                        nextcounter <= B"000"; 
                        next_stateClkGen <= HIGH;
                    elsif (counter = 7) then
                        nextcounter <= counter + 1;
                        next_stateClkGen <= HIGH;
                    else
                        nextcounter <= counter + 1;
                        next_stateClkGen <= LOW;
                    end if;
            end case;
        end process;

end rtl;
