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


-- Modified by Daniel Hernandez, January 2018, dahernan@cern.ch.
-- 200 MHz reference clock in the eth 7s sgmii + 31.25 MHz clock for the IPBus + sync reset for the IPBus. 



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.VComponents.all;

entity clocks_7s_extphy is
	port(
		sysclk_p: in std_logic;
		sysclk_n: in std_logic;
		clk125: in std_logic;
		clko_200: out std_logic;
		clko_320: out std_logic;
		clko_ipb: out std_logic;
		locked: in std_logic;
		nuke: in std_logic;
		soft_rst: in std_logic;
		rsto_125: out std_logic;
		rsto_ipb: out std_logic;
		rsto_ipb_ctrl: out std_logic;
		onehz: out std_logic
	);

end clocks_7s_extphy;

architecture rtl of clocks_7s_extphy is
	
	signal dcm_locked, sysclk, clk_ipb_i, clkfb, clk_ipb_b, clk_125: std_logic;
	signal d17, d17_d: std_logic;
	signal nuke_i, nuke_d, nuke_d2: std_logic := '0';
	signal rst, srst, rst_ipb, rst_125, rst_ipb_ctrl: std_logic := '1';
	signal rctr: unsigned(3 downto 0) := "0000";
    signal clk320M : std_logic;
    
begin

	ibufgds0: IBUFGDS 
	   port map(
	      i => sysclk_p,
		  ib => sysclk_n,
		  o => sysclk         -- 200 MHz clock for the independent clock buffer of the SGMII block.
	);
	
	clko_200  <= sysclk;       -- io delay ref clock only, no bufg.
    clko_320 <= clk320M;

    bufg125: BUFG 
	   port map(
          i => clk125,
		  o => clk_125
	);
	
	bufgipb: BUFG 
	   port map(
	      i => clk_ipb_i,
		  o => clk_ipb_b
	);
	
	clko_ipb <= clk_ipb_b;
		
	mmcm: MMCME2_BASE
		generic map(
			clkfbout_mult_f  => 5.0,
			CLKOUT0_DIVIDE_F => 3.125,
			clkout1_divide   => 32,
			clkin1_period    => 5.0
		)
		port map(
			clkin1 => sysclk,        
			clkfbin => clkfb,
			clkfbout => clkfb,
			clkout0 => clk320M,
			clkout1 => clk_ipb_i,        -- (200*5)/(32)= 31.25 MHz
			locked => open,
			rst => '0',
			pwrdwn => '0'
		);
	
	clkdiv: entity work.ipbus_clock_div
		port map(
			clk => sysclk,
			d17 => d17,
			d28 => onehz
		);
	
	
	dcm_locked <= locked;
	
	process(sysclk)
	begin
		if rising_edge(sysclk) then
			d17_d <= d17;
			if d17='1' and d17_d='0' then
				rst <= nuke_d2 or not dcm_locked;
				nuke_d <= nuke_i; -- Time bomb (allows return packet to be sent)
				nuke_d2 <= nuke_d;
			end if;
		end if;
	end process;
		
	
	srst <= '1' when rctr /= "0000" else '0';
	
	process(clk_ipb_b)
	begin
		if rising_edge(clk_ipb_b) then
			rst_ipb <= rst or srst;
			nuke_i <= nuke;
			if srst = '1' or soft_rst = '1' then
				rctr <= rctr + 1;
			end if;
		end if;
	end process;
	
	rsto_ipb <= rst_ipb;
	
	process(clk_ipb_b)
	begin
		if rising_edge(clk_ipb_b) then
			rst_ipb_ctrl <= rst;
		end if;
	end process;
	
	rsto_ipb_ctrl <= rst_ipb_ctrl;
	
	process(clk_125)
	begin
		if rising_edge(clk_125) then
			rst_125 <= rst;
		end if;
	end process;
	
	rsto_125 <= rst_125;
			
end rtl;
