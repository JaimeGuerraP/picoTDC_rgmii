----------------------------------------------------------------------------------
-- Company: CERN
-- Engineer: DPo
-- 
-- Create Date: 01/25/2022 07:00:35 PM
-- Design Name: Synchronous Pulse Generator
-- Module Name: sync_pg 
-- Project Name: PicoTDC production tester
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
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.VComponents.all;


entity sync_pg is
    Port ( enable : in STD_LOGIC;
           reset  : in STD_LOGIC;
           polarity : in STD_LOGIC;
           -- single : in STD_LOGIC;
           pulse_count : in std_logic_vector(16 - 1 downto 0);
           pulse_width : in std_logic_vector(16 - 1 downto 0);
           pulse_start : in std_logic_vector(16 - 1 downto 0);
           pulse_period : in std_logic_vector(16 - 1 downto 0);
           clk : in STD_LOGIC;
           output : out STD_LOGIC);
end sync_pg;

architecture rtl of sync_pg is

    signal count_start, count_width, pulses_counter: std_logic_vector (16-1 downto 0) := (others => '0');
    signal cnt_done : std_logic :='0';
    signal done : std_logic :='0';
    
    constant all_zeros : std_logic_vector(15 downto 0) := (others => '0');
	
begin

    process (clk)
    variable cmp_out: std_logic := '0' ; -- output before polarity
    begin
        -- resets
        if (enable = '0') then
            cmp_out := '0';
        end if;
        -- sync counting
        if rising_edge(clk) and (enable = '1') then
        -- synchronous reset
            if (reset = '1') then
                count_start <= x"0000";
                count_width <= x"0000";
                pulses_counter <= x"0000";
                done <= '0';
         -- reached specified number of pulses
            elsif (count_start = pulse_period) then
                cmp_out := '0';
                count_start <= x"0000";
                count_width <= x"0000";
            -- count endlessy or until reached number of pulses
            elsif (pulse_count = all_zeros)  or (pulses_counter /= pulse_count) then
                count_start <= count_start + 1; -- count up
                -- Comparator out put
                if (count_start = pulse_start) then
                    cmp_out := '1';  -- out on
                    count_width <= x"0000";                         
                end if;
                if (cmp_out = '1') then
                    count_width <= count_width +1;
                    if (count_width = pulse_width) then
                        cmp_out := '0'; -- out off
                        if (pulse_count /= all_zeros ) then -- if we want a defined numbe of pulses
                            pulses_counter <= pulses_counter +1; 
                        end if;
                    end if;
                end if;
            end if;
        end if;
        output <= cmp_out xor polarity;
    end process;
end rtl;
-- si period = 40-1 (39) et delay 38 alors count est ignoree ???
-- aussi le nombre de count est faux - il y a toujours un de plus produit