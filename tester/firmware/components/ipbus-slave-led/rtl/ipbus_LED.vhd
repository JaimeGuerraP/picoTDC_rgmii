----------------------------------------------------------------------------------
-- Company: CERN, EP-ESE-BE.
-- Engineer: Daniel Hernandez, dahernan@cern.ch
-- 
-- Create Date: 15.01.2018 17:04:51
-- Design Name: Led
-- Module Name: ipbus_LED/Led_tester- rtl
-- Project Name: IPBus
-- Target Devices: VC707
-- Description: Led lit via ethernet.
-- 
-- Revision 1.3 - File Created
-- Additional Comments: None.
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;

entity LED_tester is
	generic(
        ADDR_WIDTH: positive
    );
    port(
        clk: in std_logic;
        reset: in std_logic;
        ipbus_in: in ipb_wbus;
        ipbus_out: out ipb_rbus;
        userleds: out std_logic_vector(5 downto 0)
    );
end LED_tester;

architecture rtl of LED_tester is

	signal reg: std_logic_vector(((2**ADDR_WIDTH) - 1) downto 0)  := "00111000";
	signal sel: integer range 0 to ((2**ADDR_WIDTH) - 1) := 0;
	signal ack: std_logic;

begin

    sel <= to_integer(unsigned(ipbus_in.ipb_addr(((2**ADDR_WIDTH) - 1) downto 0)));

	process(clk)
	begin
		if rising_edge(clk) then
			if ipbus_in.ipb_strobe='1' and ipbus_in.ipb_write='1' then
				reg(sel) <= ipbus_in.ipb_wdata(0);
			end if;
			ipbus_out.ipb_rdata(0) <= reg(sel);
			ack <= ipbus_in.ipb_strobe and not ack;	
		end if;
	end process;
	
	ipbus_out.ipb_ack <= ack;
	ipbus_out.ipb_err <= '0';
	ipbus_out.ipb_rdata(31 downto 1) <= (others => '0');
	
	userleds(0) <= reg(0);         
    userleds(1) <= reg(1);
    userleds(2) <= reg(2);
    userleds(3) <= reg(3);
    userleds(4) <= reg(4);
    userleds(5) <= reg(5);
    

end rtl;

