-------------------------------------------------------------------------------

-- CERN, EP - ESE - BE, eth_7s_sgmii --
 
-------------------------------------------------------------------------------

--  IPBus, SGMII + GMII on VC707. Ethernet generation for the IPBus.
--  Daniel Hernandez Montesinos / dahernan@cern.ch
--  30/01/2018

--  Reference: Dave Newbold, IPBus for KC705.

-----------------------------------------------------------------------------
-- Daniel Hernandez, VC707 SGMII for the IPBus, January 2018
-- dahernan@cern.ch


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library unisim;
use unisim.VComponents.all;

use work.emac_hostbus_decl.all;


entity eth_7s_sgmii is
    port(
        sgmii_txp, sgmii_txn: out std_logic;
        sgmii_rxp, sgmii_rxn: in std_logic;
        gtrefclk_p : in std_logic;
        gtrefclk_n : in std_logic;
        phy_mdc: out std_logic;
        phy_mdio: inout std_logic;
        rst: in std_logic;
		clk125: out std_logic;
		clk_200: in std_logic;
		locked: out std_logic;
        tx_data: in std_logic_vector(7 downto 0);
        tx_valid: in std_logic;
        tx_last: in std_logic;
        tx_error: in std_logic;
        tx_ready: out std_logic;
        rx_data: out std_logic_vector(7 downto 0);
        rx_valid: out std_logic;
        rx_last: out std_logic;
        rx_error: out std_logic;
        hostbus_in: in emac_hostbus_in := ('0', "00", "0000000000", X"00000000", '0', '0', '0'); -- From the package emac_hostbus_decl
        hostbus_out: out emac_hostbus_out
    );

end eth_7s_sgmii;

architecture rtl of eth_7s_sgmii is

    COMPONENT sgmii_eth_v7
	   PORT (
         txp                  : out std_logic;                      -- Differential +ve of serial transmission from PMA to PMD.
         txn                  : out std_logic;                      -- Differential -ve of serial transmission from PMA to PMD.
         rxp                  : in std_logic;                       -- Differential +ve for serial reception from PMD to PMA.
         rxn                  : in std_logic;                       -- Differential -ve for serial reception from PMD to PMA.        
         
         userclk2_out         : out std_logic;                      -- 125 MHz generated clock from the SGMII IP.
         userclk_out          : out std_logic;                      -- 62.5 MHz generated clock from the SGMII IP.
         
         rxuserclk_out        : out std_logic;                      
         rxuserclk2_out       : out std_logic;   
         
         gtrefclk_p           : in std_logic;                       -- Main 125 MHz SGMII input clock from ports (xosc).
         gtrefclk_n           : in std_logic;
         
         independent_clock_bufg  : in std_logic;                    -- 200 MHz input clock for the IdelayCtrl (from sysclk)
        
         sgmii_clk_r          : out std_logic;                      -- Clock for client MAC (125Mhz, 12.5MHz or 1.25MHz).
         sgmii_clk_en         : out std_logic;   
                  
         speed_is_10_100      : in std_logic;                       -- Core should operate at either 10Mbps or 100Mbps speeds
         speed_is_100         : in std_logic;                       -- Core should operate at 100Mbps speed

         gmii_txd             : in std_logic_vector(7 downto 0);    -- Transmit data from client MAC.
         gmii_tx_en           : in std_logic;                       -- Transmit control signal from client MAC.
         gmii_tx_er           : in std_logic;                       -- Transmit control signal from client MAC.
         gmii_rxd             : out std_logic_vector(7 downto 0);   -- Received Data to client MAC.
         gmii_rx_dv           : out std_logic;                      -- Received control signal to client MAC.
         gmii_rx_er           : out std_logic;                      -- Received control signal to client MAC.
         gmii_isolate         : out std_logic;                      -- Tristate control to electrically isolate GMII. 
         
         gt0_qplloutclk_out   : out std_logic;
         gt0_qplloutrefclk_out : out std_logic;
         
         gtrefclk_out         : out std_logic;                        
         gtrefclk_bufg_out    : out std_logic;
         
         resetdone            : out std_logic;
         sgmii_clk_f            : out std_logic;
         an_interrupt         : out std_logic;    
         
         pma_reset_out        : out std_logic;                      -- transceiver PMA reset signal
         mmcm_locked_out      : out std_logic;                      -- MMCM Locked  
         
         reset                : in std_logic;                       -- SGMII input reset synchronous to the the other blocks reset.
         
         an_adv_config_vector : in std_logic_vector(15 downto 0);   -- Alternate interface to program REG4 (AN ADV)
         an_restart_config    : in std_logic;
         signal_detect        : in std_logic;
         configuration_vector : in std_logic_vector(4 downto 0);    -- Alternative to MDIO interface.
         
         status_vector        : out std_logic_vector(15 downto 0)   -- Core status.
	   );   
	END COMPONENT;
    
    
	COMPONENT tri_eth_gmii_v7
	   PORT (
         gtx_clk                    : in  std_logic;                        -- Main 125 MHz TEMAC input clock. Same clock domain.
         s_axi_aclk                 : in  std_logic;                        -- Main 125 MHz AXI input clock. Same clock domain.
         
         s_axi_resetn               : in  std_logic;
         
         glbl_rstn                  : in  std_logic;                        -- TEMAC input reset synchronous to the the other blocks reset.
         rx_axi_rstn                : in  std_logic;
         tx_axi_rstn                : in  std_logic;
   
         rx_statistics_vector       : out std_logic_vector(27 downto 0);
         rx_statistics_valid        : out std_logic;
   
         rx_mac_aclk                : out std_logic;                        -- Main MAC ports generated from the TEMAC to be used by the IPBus.
         rx_reset                   : out std_logic;
         rx_axis_mac_tdata          : out std_logic_vector(7 downto 0);
         rx_axis_mac_tvalid         : out std_logic;
         rx_axis_mac_tlast          : out std_logic;
         rx_axis_mac_tuser          : out std_logic;

         tx_ifg_delay               : in  std_logic_vector(7 downto 0);
         tx_statistics_vector       : out std_logic_vector(31 downto 0);
         tx_statistics_valid        : out std_logic;
   
         tx_mac_aclk                : out std_logic;                        -- Main MAC ports generated from the TEMAC to be used by the IPBus.
         tx_reset                   : out std_logic;
         tx_axis_mac_tdata          : in  std_logic_vector(7 downto 0);
         tx_axis_mac_tvalid         : in  std_logic;
         tx_axis_mac_tlast          : in  std_logic;
         tx_axis_mac_tuser          : in  std_logic;
         tx_axis_mac_tready         : out std_logic;
         
         mdio                       : inout std_logic;                      -- External MDIO interface to manage the Ethernet Marvell's PHY.
         mdc                        : out std_logic;
         
         clk_enable                 : in  std_logic;                        -- Main TEMAC clock enable interconnected to the SGMII clock enable.

         pause_req                  : in  std_logic;
         pause_val                  : in  std_logic_vector(15 downto 0);
   
         speedis100                 : out std_logic;                        -- TEMAC trispeed ports interconnected with the SGMII ports. (1 Gbs = "00").
         speedis10100               : out std_logic;
               
         s_axi_awaddr               : in  std_logic_vector(11 downto 0);
         s_axi_awvalid              : in  std_logic;
         s_axi_awready              : out std_logic;
   
         s_axi_wdata                : in  std_logic_vector(31 downto 0);
         s_axi_wvalid               : in  std_logic;
         s_axi_wready               : out std_logic;
   
         s_axi_bresp                : out std_logic_vector(1 downto 0);
         s_axi_bvalid               : out std_logic;
         s_axi_bready               : in  std_logic;
   
         s_axi_araddr               : in  std_logic_vector(11 downto 0);
         s_axi_arvalid              : in  std_logic;
         s_axi_arready              : out std_logic;
   
         s_axi_rdata                : out std_logic_vector(31 downto 0);
         s_axi_rresp                : out std_logic_vector(1 downto 0);
         s_axi_rvalid               : out std_logic;
         s_axi_rready               : in  std_logic;
         
         mac_irq                    : out std_logic;

         gmii_txd                   : out std_logic_vector(7 downto 0);     -- GMII ports generated by the TEMAC to be linked with the SGMII ones.
         gmii_tx_en                 : out std_logic;
         gmii_tx_er                 : out std_logic;
         gmii_rxd                   : in  std_logic_vector(7 downto 0);
         gmii_rx_dv                 : in  std_logic;
         gmii_rx_er                 : in  std_logic
            
	   );  
	END COMPONENT;
	
	COMPONENT fifo_axi4_mac  -- The remote TX Ethernet clock is faster than the local clock => Need FIFO.
      PORT (
         m_aclk : IN STD_LOGIC;                             -- Main 125 MHz FIFO clock, needs to be in the same clock domain.
         s_aclk : IN STD_LOGIC;                             -- To be interconnect with the TEMAC RX AXI clock.
         s_aresetn : IN STD_LOGIC;                          -- Main FIFO's reset.
         s_axis_tvalid : IN STD_LOGIC;                      -- FIFO Axis signals, only using FIFO for the RX Ethernet.
         s_axis_tready : OUT STD_LOGIC;
         s_axis_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
         s_axis_tlast : IN STD_LOGIC;
         s_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
         m_axis_tvalid : OUT STD_LOGIC;
         m_axis_tready : IN STD_LOGIC;
         m_axis_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
         m_axis_tlast : OUT STD_LOGIC;
         m_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
      );
    END COMPONENT;
	

    signal rstn, clk_enable: std_logic;                                 -- Signals instantiations.
    signal gmii_txd, gmii_rxd: std_logic_vector(7 downto 0);
    signal gmii_tx_en, gmii_tx_er, gmii_rx_dv, gmii_rx_er: std_logic;
    signal speedis10100, speedis100: std_logic;

    signal an_restart_config, signal_detect: std_logic;
    signal an_adv_config_vect: std_logic_vector (15 downto 0);
    signal config_vector: std_logic_vector (4 downto 0);
    signal rx_data_e: std_logic_vector(7 downto 0);
    signal rx_clk_e, rx_valid_e, rx_last_e, rx_user_e, rx_rst_e, rx_rst_en: std_logic;
    signal rx_user_f, rx_user_ef: std_logic_vector(0 downto 0);
    signal userclk2_o, userclk_o: std_logic;
    
    signal s_axi_awaddr: std_logic_vector(11 downto 0) := (others => '0');         
    signal s_axi_wdata: std_logic_vector(31 downto 0):= (others => '0');
    signal s_axi_awvalid, s_axi_wvalid, s_axi_bready, s_axi_arvalid, s_axi_rready: std_logic := '0';
    signal s_axi_araddr: std_logic_vector(11 downto 0):= (others => '0');
       
   
begin
             
	idelayctrl0: idelayctrl 
	   port map(
           refclk => clk_200,
           rst => rst
       );       
    
    rstn <= not rst;         
     
    config_vector <= "10000";  --[4]AN enable, [3]Isolate disabled, [2]Powerdowndisabled, [1]loopback disabled, [0] Unidirectional disabled
    signal_detect <= '1';
    an_adv_config_vect <= "0000000000100001";
    an_restart_config <= '1';
    
    rx_user_ef(0) <= rx_user_e;  -- Signals for FIFO/TEMAC RX interconnection. 
    rx_error <= rx_user_f(0);
    rx_rst_en <= not rx_rst_e;
    
    clk125 <= userclk2_o;     -- To synchronize the IPBus clock domain with the Ethernet MAC clock domain.
     
    sgmii: sgmii_eth_v7         -- SGMII instantiation    
       port map(
           txp => sgmii_txp,                           -- SGMII data ports connected to the Marvell's PHY data ports. 
           txn => sgmii_txn,
           rxp => sgmii_rxp,
           rxn => sgmii_rxn, 
           
           userclk2_out => userclk2_o,                 -- Main 125 MHz clock generated by the SGMII (from the GTRefclk)
           userclk_out => userclk_o,                   -- Main 62.5 MHz clock generated by the SGMII.
           
           gtrefclk_p => gtrefclk_p,                   -- Main 125 MHz clock used by the SGMII from the x25MHzOscillator and Clock generator.
           gtrefclk_n => gtrefclk_n,  
           
           independent_clock_bufg => clk_200,          -- 200 MHz clock input for the SGMII IdelayCtrl.  
      
           speed_is_10_100 => speedis10100 ,           -- Core should operate at either 10Mbps or 100Mbps speeds
           speed_is_100 => speedis100,                 -- Core should operate at 100Mbps speed    
           
           gmii_txd => gmii_txd,                       -- Transmit data from client MAC.
           gmii_tx_en => gmii_tx_en,                   -- Transmit control signal from client MAC.
           gmii_tx_er => gmii_tx_er,                   -- Transmit control signal from client MAC.
           gmii_rxd => gmii_rxd,                       -- Received Data to client MAC.
           gmii_rx_dv => gmii_rx_dv,                   -- Received control signal to client MAC.
           gmii_rx_er => gmii_rx_er,                   -- Received control signal to client MAC.
           sgmii_clk_en => clk_enable,                 -- Clock enable for client MAC interconnect to the TEMAC.
           sgmii_clk_r => open,        
             
           configuration_vector => config_vector,      -- Configuration for the SGMII.
           an_adv_config_vector => an_adv_config_vect,
           an_restart_config => an_restart_config,
           signal_detect => signal_detect,
           
           gt0_qplloutclk_out => open,
           gt0_qplloutrefclk_out => open,
           
           gtrefclk_out => open,
           gtrefclk_bufg_out => open,
           resetdone => open,
           sgmii_clk_f => open,
           an_interrupt => open,
           
           rxuserclk_out => open,
           rxuserclk2_out => open,
           
           pma_reset_out => open,
           mmcm_locked_out => locked,
           
           reset => rst,                               -- Main reset.
           status_vector => open
        );
               
    gmii: tri_eth_gmii_v7                             -- TEMAC Instantiation 
        port map(
            gtx_clk => userclk2_o,                    -- 125 MHz clock input.
            s_axi_aclk => userclk_o,                  -- 62.5 MHz clock input.
            glbl_rstn => rstn,                        -- Main reset.
            s_axi_resetn => rstn,
                        
            rx_axi_rstn => '1',                       -- No AXI reset.             
            tx_axi_rstn => '1',
            rx_statistics_vector => open,
            rx_statistics_valid => open,
            rx_mac_aclk => rx_clk_e,                  -- FIFO's connections.
            rx_reset => rx_rst_e,
            
            rx_axis_mac_tdata => rx_data_e,           -- FIFO's connections.
            rx_axis_mac_tvalid => rx_valid_e,
            rx_axis_mac_tlast => rx_last_e,
            rx_axis_mac_tuser => rx_user_e,
            
            tx_ifg_delay => X"00",
            tx_statistics_vector => open,
            tx_statistics_valid => open,
            tx_mac_aclk => open,
            tx_reset => open,
            
            tx_axis_mac_tdata => tx_data,             -- MAC signals to be used by the IPBus.
            tx_axis_mac_tvalid => tx_valid,
            tx_axis_mac_tlast => tx_last,
            tx_axis_mac_tuser => tx_error,
            tx_axis_mac_tready => tx_ready,             
            
            mdio => phy_mdio,                         -- External MDIO connection (TEMAC<-> Marvell's PHY)
            mdc => phy_mdc,               
            
            clk_enable => clk_enable,                 -- Clock enable.
            
            pause_req => '0',
            pause_val => X"0000",
            
            speedis10100 => speedis10100,             -- 1 Gbs config from the SGMII ports.
            speedis100 => speedis100,
            
            gmii_txd => gmii_txd,                     -- GMII ports.
            gmii_tx_en => gmii_tx_en,
            gmii_tx_er => gmii_tx_er,
            gmii_rxd => gmii_rxd,
            gmii_rx_dv => gmii_rx_dv,
            gmii_rx_er => gmii_rx_er,
           
            s_axi_awaddr => s_axi_awaddr,             -- AXI signals comming from the FIFO.
            s_axi_awvalid => s_axi_awvalid,
            s_axi_awready => open,      
            s_axi_wdata => s_axi_wdata,
            s_axi_wvalid => s_axi_wvalid,
            s_axi_wready => open,         
            s_axi_bresp => open,
            s_axi_bvalid => open,
            s_axi_bready => s_axi_bready,         
            s_axi_araddr => s_axi_araddr,
            s_axi_arvalid => s_axi_arvalid,
            s_axi_arready => open,       
            s_axi_rdata => open,
            s_axi_rresp => open,
            s_axi_rvalid => open,
            s_axi_rready => s_axi_rready,         
            mac_irq => open 
        );
       
--    RX FIFO to handle buffering the incoming octets because
--    the remote TX Ethernet clock is faster than the local clock.
       
    fifo: fifo_axi4_mac                             -- FIFO instantiation. -- Clock domain crossing FIFO.
        port map(
            m_aclk => userclk2_o,                   -- 125 MHz clock.
            s_aclk => rx_clk_e,                     -- 62.5 MHz clock.
            s_aresetn => rx_rst_en,
            s_axis_tvalid => rx_valid_e,            -- FIFO's RX <-> TEMAC.
            s_axis_tready => open,
            s_axis_tdata => rx_data_e,
            s_axis_tlast => rx_last_e,
            s_axis_tuser => rx_user_ef,
            m_axis_tvalid => rx_valid,
            m_axis_tready => '1',
            m_axis_tdata => rx_data,
            m_axis_tlast => rx_last,
            m_axis_tuser => rx_user_f
    ); 
   
	hostbus_out.hostrddata <= (others => '0');
    hostbus_out.hostmiimrdy <= '0';
                 	
end rtl;
