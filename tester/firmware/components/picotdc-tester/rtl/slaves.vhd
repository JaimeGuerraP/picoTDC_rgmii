---------------------------------------------------------------------------------
--
--   Copyright 2017 - Rutherford Appleton Laboratory and University of Bristol
--
--   Licensed under the Apache License, Version 2.0 (the "License");
--   you may not use this file except in compliance with the License.
--   You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--
--                                     - - -
--
--   Additional information about ipbus-firmare and the list of ipbus-firmware
--   contacts are available at
--
--       https://ipbus.web.cern.ch/ipbus
--
---------------------------------------------------------------------------------
-- ipbus_slaves
--
-- selection of different IPBus slaves without actual function,
-- just for performance evaluation of the IPbus/uhal system
--
-- Kristian Harder, March 2014
-- based on code by Dave Newbold, February 2011
-------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--   PicoTDC Demo board
--   CERN EP-ESE
---------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.ipbus_decode_picotdc_tester.all;
use work.ipbus_trans_decl.all;


entity Slaves is
	port(
		ipb_clk: in std_logic; -- IPBus ports
		ipb_rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		nuke: out std_logic;
		soft_rst: out std_logic;
	   
	    -- I2C VC707 ports	       
        sda_vc707_carrier: inout std_logic; 
        scl_vc707_carrier: inout std_logic;
		
        -- I2C picoTDC Control ports
        sda_picoTDC: inout std_logic; 
        scl_picoTDC: inout std_logic;          

        -- The GPIO Interface
        gpio_in:   in  std_logic_vector(15 downto 0);
        gpio_out:  out std_logic_vector(15 downto 0);
        gpio_dir:  out std_logic_vector(15 downto 0);
       
        -- Readout --
        readout              : in std_logic_vector(7 downto 0);
        readout2             : in std_logic_vector(7 downto 0);
        readout3             : in std_logic_vector(7 downto 0);
        readout4             : in std_logic_vector(7 downto 0);
        sync                 : in std_logic;
                       
        -- Led tester ports
		userleds: out std_logic_vector(5 downto 0)
	);

end Slaves;

architecture rtl of Slaves is

	signal ipbw: ipb_wbus_array(N_SLAVES - 1 downto 0);
	signal ipbr: ipb_rbus_array(N_SLAVES - 1 downto 0);
	signal ctrl, stat: ipb_reg_v(0 downto 0);
    
  --  signal hitregmask : ipb_reg_v(1 downto 0);   
    signal resets     : ipb_reg_v(0 downto 0);    
 
begin

-- IPbus address decode
		
	Fabric: entity work.ipbus_fabric_sel
    generic map(
    	NSLV => N_SLAVES,
    	SEL_WIDTH => IPBUS_SEL_WIDTH)
    port map(
      ipb_in => ipb_in,
      ipb_out => ipb_out,
      sel => ipbus_sel_picotdc_tester(ipb_in.ipb_addr),
      ipb_to_slaves => ipbw,
      ipb_from_slaves => ipbr
    );
		
-- Slave 0:  version registers
            
    Leds: entity work.LED_tester                 -- Led tester slave.
        generic map(ADDR_WIDTH => LEDs_ADDR_WIDTH)    	
        port map(
            clk => ipb_clk,
            reset => ipb_rst,
            ipbus_in => ipbw(N_SLV_LEDs),
            ipbus_out => ipbr(N_SLV_LEDs),
            userleds => userleds
        );

    I2C_Silicon: entity work.ipbus_master_i2c               -- I2C master slave picoTDC I2C Silicon.
        generic map(addr_width => I2C_SILICON_ADDR_WIDTH,
                    MODE => false)
        port map(
            ipbus_clk => ipb_clk,
            ipbus_rst => ipb_rst,
            ipbus_in => ipbw(N_SLV_I2C_SILICON),
            ipbus_out => ipbr(N_SLV_I2C_SILICON),
            scl => open,
            sda => open
        );
        
     I2C_picoTDC: entity work.ipbus_master_i2c                -- I2C master slave PicoTDC Control.
        generic map(addr_width => I2C_PICOTDC_ADDR_WIDTH,
                    MODE => false)
        port map(
            ipbus_clk => ipb_clk,
            ipbus_rst => ipb_rst,
            ipbus_in => ipbw(N_SLV_I2C_PICOTDC),
            ipbus_out => ipbr(N_SLV_I2C_PICOTDC),
            scl => scl_picoTDC,
            sda => sda_picoTDC
        );

    I2C_VC707: entity work.ipbus_master_i2c                 -- I2C master slave VC707 Multiplexer control.
        generic map(addr_width => I2C_VC707_ADDR_WIDTH,
                    MODE => false)
        port map(
            ipbus_clk => ipb_clk,
            ipbus_rst => ipb_rst,
            ipbus_in => ipbw(N_SLV_I2C_VC707),
            ipbus_out => ipbr(N_SLV_I2C_VC707),
            scl => scl_vc707_carrier,
            sda => sda_vc707_carrier
        );


    GPIOs: entity work.GPIO            -- GPIO slave.
         generic map(ADDR_WIDTH => GPIO_ADDR_WIDTH)
         port map(
            clk       => ipb_clk,
            reset     => ipb_rst,
            ipbus_in  => ipbw(N_SLV_GPIO),
            ipbus_out => ipbr(N_SLV_GPIO),
            gpio_in   => gpio_in,
            gpio_out  => gpio_out,
            gpio_dir  => gpio_dir
        );
        
    DOUT: entity work.ipbus_picoTdcDout           
             generic map(ADDR_WIDTH => PICOTDC_READOUT_ADDR_WIDTH)
             port map(
                clk_ipbus => ipb_clk,
                clk_sys   => sync,
                rst       => ipb_rst,
                ipbus_in  => ipbw(N_SLV_PICOTDC_READOUT),
                ipbus_out => ipbr(N_SLV_PICOTDC_READOUT),
                data_in   => readout
            );
            
    DOUT2: entity work.ipbus_picoTdcDout           
             generic map(ADDR_WIDTH => PICOTDC_READOUT_ADDR_WIDTH)
             port map(
                clk_ipbus => ipb_clk,
                clk_sys   => sync,
                rst       => ipb_rst,
                ipbus_in  => ipbw(N_SLV_PICOTDC_READOUT2),
                ipbus_out => ipbr(N_SLV_PICOTDC_READOUT2),
                data_in   => readout2
            );

    DOUT3: entity work.ipbus_picoTdcDout           
             generic map(ADDR_WIDTH => PICOTDC_READOUT_ADDR_WIDTH)
             port map(
                clk_ipbus => ipb_clk,
                clk_sys   => sync,
                rst       => ipb_rst,
                ipbus_in  => ipbw(N_SLV_PICOTDC_READOUT3),
                ipbus_out => ipbr(N_SLV_PICOTDC_READOUT3),
                data_in   => readout3
            );
            
    DOUT4: entity work.ipbus_picoTdcDout           
             generic map(ADDR_WIDTH => PICOTDC_READOUT_ADDR_WIDTH)
             port map(
                clk_ipbus => ipb_clk,
                clk_sys   => sync,
                rst       => ipb_rst,
                ipbus_in  => ipbw(N_SLV_PICOTDC_READOUT4),
                ipbus_out => ipbr(N_SLV_PICOTDC_READOUT4),
                data_in   => readout4
            );
                
end rtl;


            