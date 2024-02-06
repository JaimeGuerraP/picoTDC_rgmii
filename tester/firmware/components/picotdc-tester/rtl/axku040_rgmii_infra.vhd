-- KC705_gmii_infra
--
-- All board-specific stuff goes here
--
-- Dave Newbold, June 2013

-------------------------------------------------------------------------------
-- --
-- CERN, EP-ESE-BE, eth_7s_sgmii --
-- --
-------------------------------------------------------------------------------
--
--  IPBus, SGMII + GMII on axku040. Ethernet generation for the IPBus.
--
--  Daniel Hernandez Montesinos / dahernan@cern.ch
--
--  30/01/2018
--
--  Reference: Dave Newbold, IPBus for KC705.
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Modified by Daniel Hernandez to adapt the GMII from KC705 to SGMII from axku040, January 2018.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.ipbus.all;

entity axku040_Ethernet is
	port(
		sysclk_p: in std_logic;       -- 200MHz board crystal clock
		sysclk_n: in std_logic;
		gtrefclk_p: in  std_logic;    -- 125 MHz from FPGA Oscillator for the Ethernet SGMII.                  
        gtrefclk_n: in  std_logic;
        phy_mdc: out std_logic;       -- Management interface pinout.
        phy_mdio: inout std_logic;  
		clk_ipb_o: out std_logic;     -- IPbus clock
		rst_ipb_o: out std_logic;
		rst_125_o: out std_logic;
		clk_125_o: out std_logic;
		clk_125_90_o: out std_logic;
		nuke: in std_logic;           -- The signal of doom
		soft_rst: in std_logic;                       -- The signal of lesser doom
		leds: out std_logic_vector(1 downto 0);       -- status LEDs
		mac_addr: in std_logic_vector(47 downto 0);   -- MAC address
		ip_addr: in std_logic_vector(31 downto 0);    -- IP address
		
		ipb_in: in ipb_rbus; -- IPBus
		ipb_out: out ipb_wbus;

		rgmii_txd: out std_logic_vector(3 downto 0);
		rgmii_tx_ctl: out std_logic;
		rgmii_txc: out std_logic;
		rgmii_rxd: in std_logic_vector(3 downto 0);
		rgmii_rx_ctl: in std_logic;
		rgmii_rxc: in std_logic;


        -- sgmii_txp, sgmii_txn: out std_logic; --#TODO
        -- sgmii_rxp, sgmii_rxn: in std_logic --#TODO
	);

end axku040_Ethernet;

architecture rtl of axku040_Ethernet is

	signal clk125, clk125_s, clk125_90_s, clk200, clk_ipb, clk_ipb_i, locked, rst125, rst_ipb, rst_ipb_ctrl, onehz, pkt: std_logic;
	signal mac_tx_data, mac_rx_data: std_logic_vector(7 downto 0);
	signal mac_tx_valid, mac_tx_last, mac_tx_error, mac_tx_ready, mac_rx_valid, mac_rx_last, mac_rx_error: std_logic;
	signal led_p: std_logic_vector(0 downto 0);
	
begin

	    
	IBUF_125_CLOCK: IBUFGDS port map (
		i   => gtrefclk_p,
		ib  => gtrefclk_n,
		o   => clk125
	);

	gthclk: entity work.clock_125MHz_shifter
		port map(
			master125clk => clk125,
			clk125 => clk125_s,
			clk125_90 => clk125_90

		);


	clocks: entity work.clocks_7s_extphy   --	Clock generation for the IPBus: 31.25 MHz.
		port map(
			sysclk_p => sysclk_p,
			sysclk_n => sysclk_n,
			clko_200 => clk200,
			clk125 => clk125_s,
			clko_ipb => clk_ipb_i, 
			locked => locked,
			nuke => nuke,
			soft_rst => soft_rst,
			rsto_125 => rst125,
			rsto_ipb => rst_ipb,
			rsto_ipb_ctrl => rst_ipb_ctrl,
			onehz => onehz
		);

	clk_ipb <= clk_ipb_i;  -- Best to align delta delays on all clocks for simulation
	clk_ipb_o <= clk_ipb_i;
	rst_ipb_o <= rst_ipb;
	rst_125_o <= rst125;
	clk_125_o <= clk125_s;
	clk_125_90_o <= clk125_90_s;
	
	stretch: entity work.led_stretcher -- Lit of led(0) at 1 Hz.
		generic map(
			WIDTH => 1
		)
		port map(
			clk => clk125_s,
			d(0) => pkt,
			q => led_p
		);

	leds <= (led_p(0), locked and onehz);
	
	
-- Ethernet MAC core and PHY interface
	eth:entity work.eth_7s_rgmii is
		port(
			clk125 => clk125_s,
			clk125_90 => clk125_90_s,
			clk200 => clk200,
			rst => rst125,
			rgmii_txd => rgmii_txd, --: out std_logic_vector(3 downto 0);
			rgmii_tx_ctl => rgmii_tx_ctl,  --: out std_logic;
			rgmii_txc => rgmii_txc, --: out std_logic;
			rgmii_rxd => rgmii_rxd, --: in std_logic_vector(3 downto 0);
			rgmii_rx_ctl => --: in std_logic;
			rgmii_rxc => rgmii_rxc --: in std_logic;
			tx_data => mac_tx_data,
			tx_valid => mac_tx_valid,
			tx_last => mac_tx_last,
			tx_error => mac_tx_error,
			tx_ready => mac_tx_ready,
			rx_data => mac_rx_data,
			rx_valid => mac_rx_valid,
			rx_last => mac_rx_last,
			rx_error => mac_rx_error,
			-- phy_mdc => phy_mdc,
			-- phy_mdio => phy_mdio,
			hostbus_in: in emac_hostbus_in := ('0', "00", "0000000000", X"00000000", '0', '0', '0');
			hostbus_out: out emac_hostbus_out;
			status: out std_logic_vector(3 downto 0)
		);



	-- eth: entity work.eth_7s_rgmii      -- FIFO + GMII + RGMII blocks for Ethernet + IPbus.
    --     port map(
	-- 		gtrefclk_p => gtrefclk_p,
    --         gtrefclk_n => gtrefclk_n,
    --         clk_200 => clk200,
    --         clk125 => clk125,
	-- 		clk125_90 => clk125_90,
    --         rst => rst125,
    --         locked => locked,
    --         phy_mdc => phy_mdc,
    --         phy_mdio => phy_mdio,          
    --         -- sgmii_txp => sgmii_txp,
    --         -- sgmii_txn => sgmii_txn,
    --         -- sgmii_rxp => sgmii_rxp,
    --         -- sgmii_rxn => sgmii_rxn,
    --         tx_data => mac_tx_data,
    --         tx_valid => mac_tx_valid,
    --         tx_last => mac_tx_last,
    --         tx_error => mac_tx_error,
    --         tx_ready => mac_tx_ready,
    --         rx_data => mac_rx_data,
    --         rx_valid => mac_rx_valid,
    --         rx_last => mac_rx_last,
    --         rx_error => mac_rx_error,
	-- 		rgmii_txd => rgmii_txd,
	-- 		rgmii_tx_ctl => rgmii_tx_ctl,
	-- 		rgmii_txc => rgmii_txc,
	-- 		rgmii_rxd => rgmii_rxd,
	-- 		rgmii_rx_ctl => rgmii_rx_ctl,
	-- 		rgmii_rxc => rgmii_rxc

    -- );
	
-- IPBus Control Logic

	ipbus: entity work.ipbus_ctrl      -- IPbus block using the AXI-4 ports generated by the GMII MAC.
		port map(
			mac_clk => clk125,
			rst_macclk => rst125,
			ipb_clk => clk_ipb,
			rst_ipb => rst_ipb_ctrl,
			mac_rx_data => mac_rx_data,
			mac_rx_valid => mac_rx_valid,
			mac_rx_last => mac_rx_last,
			mac_rx_error => mac_rx_error,
			mac_tx_data => mac_tx_data,
			mac_tx_valid => mac_tx_valid,
			mac_tx_last => mac_tx_last,
			mac_tx_error => mac_tx_error,
			mac_tx_ready => mac_tx_ready,
			ipb_out => ipb_out,
			ipb_in => ipb_in,
			mac_addr => mac_addr,
			ip_addr => ip_addr,
			pkt => pkt
		);

end rtl;