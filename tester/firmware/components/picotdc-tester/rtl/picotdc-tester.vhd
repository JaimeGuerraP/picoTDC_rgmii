---------------------------------------------------------------------------------
--   PicoTDC Demo board
--   CERN EP-ESE
---------------------------------------------------------------------------------

--! Last changes:

-- 09\05\2022: Creation.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

use work.ipbus.ALL;


entity picotdc_fpga_tester is port (
    -- 200 MHz system clock
    sysclk_p                    : in std_logic;
    sysclk_n                    : in std_logic;

    -- Reference clock of 125 MHz to use the SGMII Ethernet block.
    gtrefclk_p                  : in std_logic;
    gtrefclk_n                  : in std_logic;

    -- Management interface signals connecting the Marvel's PHY and the GMII Ethernet block.
    phy_mdc                     : out std_logic;
    phy_mdio                    : inout std_logic;
    phy_rst                     : out std_logic;

    -- Switches to change the Ethernet IP value.
    dip_sw                      : in std_logic_vector(3 downto 0);

    -- SGMII ports connected to the Marvel's PHY.
    -- sgmii_txp                   : out std_logic;
    -- sgmii_txn                   : out std_logic;
    -- sgmii_rxp                   : in std_logic;
    -- sgmii_rxn                   : in std_logic;

    -- RGMII ports connected to the Marvel's PHY.
    rgmii_txd                   : out std_logic_vector(3 downto 0);
    rgmii_tx_ctl                : out std_logic;
    rgmii_txc                   : out std_logic;
    rgmii_rxd                   : in std_logic_vector(3 downto 0);
    rgmii_rx_ctl                : in std_logic;
    rgmii_rxc                   : in std_logic;


    -- I2C pins for the FPGA board control - used as I2C Master
    SDA_VC707_CARRIER           : inout std_logic;
    SCL_VC707_CARRIER           : inout std_logic;

    -- debug LEDs
    leds                        : out std_logic_vector(7 downto 0);
 
    -- picoTDC I2C slave
    SDA_PICOTDC                   : inout std_logic;
    SCL_PICOTDC                   : inout std_logic;   
   
    READOUT_P                  : in std_logic_vector (7 downto 0);
    READOUT_N                  : in std_logic_vector (7 downto 0);
    
    READOUT2_P                  : in std_logic_vector (7 downto 0);
    READOUT2_N                  : in std_logic_vector (7 downto 0);
    
    READOUT3_P                  : in std_logic_vector (7 downto 0);
    READOUT3_N                  : in std_logic_vector (7 downto 0);
    
    READOUT4_P                  : in std_logic_vector (7 downto 0);
    READOUT4_N                  : in std_logic_vector (7 downto 0);
    
    SYNC_P                     : in std_logic;
    SYNC_N                     : in std_logic;

    RESET_P                    : out std_logic;
    RESET_N                    : out std_logic;

    EID_RESET_P                : out std_logic;
    EID_RESET_N                : out std_logic;
    
    BX_RESET_P                 : out std_logic;
    BX_RESET_N                 : out std_logic;
        
    TRIGGER_P                 : out std_logic;
    TRIGGER_N                 : out std_logic;
    
    --Hit input from SMA and FMC driver
    USER_SMA_CLOCK_P            : in std_logic;
    USER_SMA_CLOCK_N            : in std_logic;
       
    -- CLock input trigger
    USER_SMA_GPIO_N             : in std_logic;
    USER_SMA_GPIO_P             : in std_logic;
    
    -- TEST1 SMA connectors
    TEST1_P : inout std_logic;
    TEST1_N : inout std_logic;
    
    -- TEST2 SMA connectors
    TEST2_P  : inout std_logic;
    TEST2_N  : inout std_logic;
    
    -- Pulse Output
    PULSEOUT_P : in std_logic;
    PULSEOUT_N : in std_logic
    
   
);

end picotdc_fpga_tester;


architecture vc707_picoTDC of picotdc_fpga_tester is

    component clk_factory
    port
     (-- Clock in ports
      -- Clock out ports
      clk40out          : out    std_logic;
      clk320out          : out    std_logic;
      clk80out          : out    std_logic;
      -- Status and control signals
      reset             : in     std_logic;
      input_clk_stopped : out    std_logic;
      locked            : out    std_logic;
      clk_in1_p         : in     std_logic;
      clk_in1_n         : in     std_logic
     );
    end component;

    -- IPbus signals
    signal clk_ipb              : std_logic;
    signal rst_ipb              : std_logic;
    signal nuke                 : std_logic;
    signal soft_rst             : std_logic;
    signal phy_rst_e            : std_logic;
    signal userleds             : std_logic_vector(5 downto 0);
    signal mac_addr             : std_logic_vector(47 downto 0);
    signal ip_addr              : std_logic_vector(31 downto 0);
    signal ipb_out              : ipb_wbus;
    signal ipb_in               : ipb_rbus;


    signal GPIO_IN              : std_logic_vector (15 downto 0);
    signal GPIO_OUT             : std_logic_vector (15 downto 0);
    signal GPIO_DIR             : std_logic_vector (15 downto 0);

    signal sysclk               : std_logic;
    signal clkMMCMfbBase        : std_logic;
    signal clk40MHzBase_toBuf   : std_logic;
    signal clk40MHzBase         : std_logic;
    signal clk125MHz            : std_logic;
    signal clk_ipb_buf1         : std_logic;
    signal clk_ipb_buf2         : std_logic;
    signal clk_ipb_buf3         : std_logic;
    signal extref               : std_logic;   
    -- Readout
    signal readout_pre          : std_logic_vector(7 downto 0);
    signal readout              : std_logic_vector(7 downto 0);

    signal readout2_pre          : std_logic_vector(7 downto 0);
    signal readout2              : std_logic_vector(7 downto 0);
    
    signal readout3_pre          : std_logic_vector(7 downto 0);
    signal readout3              : std_logic_vector(7 downto 0);
    
    signal readout4_pre          : std_logic_vector(7 downto 0);
    signal readout4              : std_logic_vector(7 downto 0);
                
    signal sync                 : std_logic;
    -- Trigger
    signal trigger              : std_logic;
    
    -- Resets
    signal reset_logic          : std_logic;
    signal reset_eid            : std_logic;
    signal reset_bx             : std_logic;
        
    function invert (input : std_logic) return std_logic is
    begin
      return not input;
    end function;  


begin


 ibufds_gen_DATA_IN: for I in 0 to 7 generate
        IBUF: IBUFDS port map (
            i   => READOUT_P(I),
            ib  => READOUT_N(I),
            o   => readout_pre(I)
        );
    end generate ibufds_gen_DATA_IN;
    
 --   readout <= readout_pre xor "00000000";
    readout <= readout_pre xor "11000000"; --invert swapped pairs
 
 ibufds2_gen_DATA_IN: for I in 0 to 7 generate
        IBUF: IBUFDS port map (
            i   => READOUT2_P(I),
            ib  => READOUT2_N(I),
            o   => readout2_pre(I)
        );
    end generate ibufds2_gen_DATA_IN;
    
  --  readout2 <= readout2_pre xor "00000000"; --invert swapped pairs
  readout2 <= readout2_pre xor "10000000"; --invert swapped pairs
    
  ibufds3_gen_DATA_IN: for I in 0 to 7 generate
        IBUF: IBUFDS port map (
            i   => READOUT3_P(I),
            ib  => READOUT3_N(I),
            o   => readout3_pre(I)
        );
    end generate ibufds3_gen_DATA_IN;
    
 --   readout3 <= readout3_pre xor "00000000"; --invert swapped pairs
    readout3 <= readout3_pre xor "10000000"; --invert swapped pairs
    
 ibufds4_gen_DATA_IN: for I in 0 to 7 generate
        IBUF: IBUFDS port map (
            i   => READOUT4_P(I),
            ib  => READOUT4_N(I),
            o   => readout4_pre(I)
        );
    end generate ibufds4_gen_DATA_IN;
    
  --  readout4 <= readout4_pre xor "00000000"; --invert swapped pairs
      readout4 <= readout4_pre xor "10100100"; --invert swapped pairs  
    
  IBUF_SYNC: IBUFGDS port map (
            i   => SYNC_P,
            ib  => SYNC_N,
            o   => sync
        );
    
--    OBUF_RESET: OBUFDS port map (
--            o   => RESET_P,
--            ob  => RESET_N,
--            i   => (reset_logic)
--            --i   => invert(GPIO_OUT(0))
--        );

 OBUF_RESET: OBUFDS port map (
            o   => RESET_P,
            ob  => RESET_N,
            i   => reset_logic
            --i   => invert(GPIO_OUT(0))
        );



    OBUF_RESET_EID: OBUFDS port map (
            o   => EID_RESET_P,
            ob  => EID_RESET_N,
            i   => (reset_eid)
            --i   => invert(GPIO_OUT(0))
        );
    
    OBUF_RESET_BX: OBUFDS port map (
        o   => BX_RESET_P,
        ob  => BX_RESET_N,
        i   => (reset_bx)
        --i   => invert(GPIO_OUT(0))
    );
    
    OBUF_TRIGGER: OBUFDS port map (
        o   => TRIGGER_P,
        ob  => TRIGGER_N,
        i   => (trigger)
        --i   => invert(GPIO_OUT(0))
    );
                  
    
  IBUF_PAR_HIT: IBUFGDS port map (
            i   => USER_SMA_CLOCK_P,
            ib  => USER_SMA_CLOCK_N,
            o   => open
        );
        
  IBUF_TRIGG: IBUFGDS
        port map (
           O => open, 
           i => USER_SMA_GPIO_P,  
           ib => USER_SMA_GPIO_N 
        );
                         

ODDR_inst1 : ODDR
generic map(
   DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE" 
   INIT => '0',   -- Initial value for Q port ('1' or '0')
   SRTYPE => "SYNC") -- Reset Type ("ASYNC" or "SYNC")
port map (
   Q => clk_ipb_buf1,   -- 1-bit DDR output
   C => clk40MHzBase,    -- 1-bit clock input
   CE => '1',  -- 1-bit clock enable input
   D1 => '0',  -- 1-bit data input (positive edge)
   D2 => '1',  -- 1-bit data input (negative edge)
   R => '0',    -- 1-bit reset input
   S => '0'     -- 1-bit set input
);
    

ODDR_inst2 : ODDR
    generic map(
       DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE" 
       INIT => '0',   -- Initial value for Q port ('1' or '0')
       SRTYPE => "SYNC") -- Reset Type ("ASYNC" or "SYNC")
    port map (
       Q => clk_ipb_buf2,   -- 1-bit DDR output
       C => clk40MHzBase,    -- 1-bit clock input
       CE => '1',  -- 1-bit clock enable input
       D1 => '0',  -- 1-bit data input (positive edge)
       D2 => '1',  -- 1-bit data input (negative edge)
       R => '0',    -- 1-bit reset input
       S => '0'     -- 1-bit set input
    );

    
ODDR_inst3 : ODDR
    generic map(
       DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE" 
       INIT => '0',   -- Initial value for Q port ('1' or '0')
       SRTYPE => "SYNC") -- Reset Type ("ASYNC" or "SYNC")
    port map (
       Q => clk_ipb_buf3,   -- 1-bit DDR output
       C => clk40MHzBase,    -- 1-bit clock input
       CE => '1',  -- 1-bit clock enable input
       D1 => '0',  -- 1-bit data input (positive edge)
       D2 => '1',  -- 1-bit data input (negative edge)
       R => '0',    -- 1-bit reset input
       S => '0'     -- 1-bit set input
    );

   

    Infra: entity work.vc707_Ethernet port map(
        sysclk_p    => sysclk_p,
        sysclk_n    => sysclk_n,
        gtrefclk_p  => gtrefclk_p,
        gtrefclk_n  => gtrefclk_n,
        clk_ipb_o   => clk_ipb,
        clk_125_o   => clk125MHz,
        rst_ipb_o   => rst_ipb,
        rst_125_o   => phy_rst_e,
        phy_mdc     => phy_mdc,
        phy_mdio    => phy_mdio,
        nuke        => nuke,
        soft_rst    => soft_rst,
        leds        => leds(1 downto 0),
        mac_addr    => mac_addr,
        ip_addr     => ip_addr,
        ipb_in      => ipb_in,
        ipb_out     => ipb_out,
        sgmii_txp   => sgmii_txp,
        sgmii_txn   => sgmii_txn,
        sgmii_rxp   => sgmii_rxp,
        sgmii_rxn   => sgmii_rxn
    );

    leds(7 downto 2) <= userleds;
    phy_rst <= not phy_rst_e;

    -- mac_addr <= X"020ddba1151" & dip_sw;
    -- ip_addr <= X"c0a8c81" & dip_sw;        -- 192.168.200.16+(DIP switch)

    mac_addr <= X"020ddba11511"; --#TODO Due to there is no dip_sw ¿which MAC address should be noted?
    ip_addr <= X"c0a8c8EF";        -- 192.168.200.16+(DIP switch) -- #TODO which IP address?

    MMCME2_BASE_i : MMCME2_BASE
        generic map (
            BANDWIDTH           => "OPTIMIZED",
            CLKFBOUT_MULT_F     => 8.000,       -- input clock is multiplied by this factor
            CLKFBOUT_PHASE      => 0.000,
            CLKIN1_PERIOD       => 8.0,         -- input clock is 125MHz

            CLKOUT0_DIVIDE_F    => 25.0,        -- 40MHz output clock
            CLKOUT0_DUTY_CYCLE  => 0.5,
            CLKOUT0_PHASE       => 0.0,

            CLKOUT4_CASCADE     => FALSE,
            DIVCLK_DIVIDE       => 1,
            REF_JITTER1         => 0.000,
            STARTUP_WAIT        => TRUE
        ) port map (
            CLKIN1              => clk125MHz,
            PWRDWN              => '0',
            RST                 => '0',
            CLKOUT0             => clk40MHzBase_toBuf,
            CLKFBOUT            => clkMMCMfbBase,
            CLKFBIN             => clkMMCMfbBase
        );

    BUFG_40MHzIn : BUFG port map (
        I   => clk40MHzBase_toBuf,
        O   => clk40MHzBase
    );
    
     
    IPbus_slaves: entity work.Slaves port map(
        -- Ipbus signals going inout the slaves.
        ipb_clk             => clk_ipb,
        ipb_rst             => rst_ipb,
        ipb_in              => ipb_out,
        ipb_out             => ipb_in,
        nuke                => nuke,
        soft_rst            => soft_rst,
        
        -- Userleds Slave ports.
        userleds            => userleds,
        -- SPI Slave ports.

        -- picoTDC control I2C master IPbus slave ports
        sda_picoTDC => SDA_PICOTDC,
        scl_picoTDC => SCL_PICOTDC,
        
        -- VC707 control I2C master IPbus slave ports
        sda_vc707_carrier   => SDA_VC707_CARRIER,
        scl_vc707_carrier   => SCL_VC707_CARRIER,
             
        -- GPIO slave output
        gpio_in             => GPIO_IN,
        gpio_out            => GPIO_OUT,
        gpio_dir            => GPIO_DIR,
        
        -- Readout --
        readout             => readout,
        readout2            => readout2,
        readout3            => readout3,
        readout4            => readout4,
        sync                => sync
         
    );


end vc707_picoTDC;
