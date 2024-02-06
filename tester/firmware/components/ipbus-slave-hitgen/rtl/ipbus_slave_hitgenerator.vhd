----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/14/2021 09:33:09 AM
-- Design Name: 
-- Module Name: ipbus-slave-hitgen - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;


entity ipbus_hitgenerator is
	generic(
        ADDR_WIDTH: positive
    );
    
    port(
            clk_ipbus: in std_logic;
            rst: in std_logic;
            ipbus_in: in ipb_wbus;
            ipbus_out: out ipb_rbus;
            hit_mask: out std_logic_vector(63 downto 0)
        );
end ipbus_hitgenerator;

architecture rtl of ipbus_hitgenerator is

	signal reg: std_logic_vector(((2**ADDR_WIDTH) - 1) downto 0); --   := 0;
	signal sel: integer range 0 to ((2**ADDR_WIDTH) - 1) := 0;
	signal ack: std_logic;

begin

    sel <= to_integer(unsigned(ipbus_in.ipb_addr(((2**ADDR_WIDTH) - 1) downto 0)));

	process(clk_ipbus)
	begin
		if rising_edge(clk_ipbus) then
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
	
	hit_mask(0) <= reg(0);         
    hit_mask(1) <= reg(1);
    hit_mask(2) <= reg(2);
    hit_mask(3) <= reg(3);
    hit_mask(4) <= reg(4);
    hit_mask(5) <= reg(5);
    hit_mask(6) <= reg(6);
    hit_mask(7) <= reg(7);
    

end rtl;
