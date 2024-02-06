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

-- For simulation of Xilinx models of GTXE2
library UNISIM;
use UNISIM.vcomponents.all;

entity datapath is
    port (
        signal sysclk_i         : in  std_logic;
        signal refClkGTX_320M_n : in  std_logic;
        signal refClkGTX_320M_p : in  std_logic;        
        signal clk40MHz         : out std_logic;
        signal clk80MHz         : out std_logic;
        signal clk320MHz        : out std_logic;
        signal hsUpLink_p_i     : in  std_logic;
        signal hsUpLink_n_i     : in  std_logic;
        signal hsDnLink_p_o     : out std_logic;     
        signal hsDnLink_n_o     : out std_logic;      
        signal data_to_fpga_tx  : in  std_logic_vector(63 downto 0);
        signal data_fr_fpga_rx  : out std_logic_vector(31 downto 0);
        signal statusBus        : out std_logic_vector(31 downto 0);
        signal controlBus       : in  std_logic_vector(31 downto 0)
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
            GT0_RX_MMCM_LOCK_OUT                    : out  std_logic;
         
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

    begin
        -- The serial links
        hsDnLink_p_o <= hsDnLink_p;
        hsDnLink_n_o <= hsDnLink_n;
        hsUpLink_p   <= hsUpLink_p_i;
        hsUpLink_n   <= hsUpLink_n_i;

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
        statusBus(0) <= tx_fsm_reset_done_out;
        statusBus(1) <= txresetdone;
        statusBus(2) <= mmcmLock(0);   -- Tx MMCM
        statusBus(3) <= rx_fsm_reset_done_out;
        statusBus(4) <= rxresetdone;
        statusBus(5) <= mmcmLock(1);   -- RX MMCM
        statusBus(6) <= qPLLstatus(0); -- QPLL Locked
        statusBus(7) <= qPLLstatus(1); -- QPLL Reference Clock Lost
        statusBus(31 downto 8) <= (others => '0');

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
                Q0_CLK1_GTREFCLK_PAD_N_IN => refClkGTX_320M_n,
                Q0_CLK1_GTREFCLK_PAD_P_IN => refClkGTX_320M_p,

                -- State-machine reset done signal
                GT0_TX_FSM_RESET_DONE_OUT => tx_fsm_reset_done_out,
                GT0_RX_FSM_RESET_DONE_OUT => rx_fsm_reset_done_out,

                -- Data valid signal
                GT0_DATA_VALID_IN => '1', --rx_data_valid,

                -- Lock signals from MMCM blocks
                GT0_TX_MMCM_LOCK_OUT => mmcmLock(0),
                GT0_RX_MMCM_LOCK_OUT => mmcmLock(1),

                -- 80MHz clock
                GT0_TXUSRCLK_OUT => clk80MHz,

                -- 40MHz clock
                GT0_TXUSRCLK2_OUT => clk40MHz,

                -- 320MHz clock
                GT0_RXUSRCLK_OUT => clk320MHz,

                -- Same as above...
                GT0_RXUSRCLK2_OUT => open,

                --_________________________________________________________________________
                --GT0  (X0Y0)
                --____________________________CHANNEL PORTS________________________________
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

                sysclk_in => sysclk_i

            );

end rtl;
