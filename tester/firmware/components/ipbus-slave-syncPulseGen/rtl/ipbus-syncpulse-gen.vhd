----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/25/2022 11:39:01 PM
-- Design Name: 
-- Module Name: ipbus-pgm-slave - rtl
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ipbus_sync_pulse_gen is
generic (
    addr_width: natural := 0
    );
port (
    clk:   in  std_logic;
    reset:      in  std_logic;
    ipbus_in:   in  ipb_wbus;
    ipbus_out:  out ipb_rbus;
    clkref40:   in std_logic;
    sync_reset: in std_logic;
    q:          out std_logic
    );
end ipbus_sync_pulse_gen;

architecture rtl of ipbus_sync_pulse_gen is


signal enable   : std_logic;
signal reset_pg : std_logic;
signal polarity : std_logic;

signal pulse_period  : std_logic_vector(15 downto 0);
signal pulse_width  : std_logic_vector(15 downto 0);
signal pulse_delay  : std_logic_vector(15 downto 0);
signal pulse_count  : std_logic_vector(15 downto 0);

signal reg_v         : ipb_reg_v( 4 downto 0 );

begin 
-- control  
    data_reg: entity work.ipbus_reg_v
            generic map(
          N_REG => 5
            )
            port map(
                clk => clk,
                reset => reset,
                ipbus_in => ipbus_in,
                ipbus_out => ipbus_out,
                q => reg_v
            );
    
    reset_pg <= sync_reset or reg_v(0)(0);
    polarity <= reg_v(0)(1);
    enable <= reg_v(0)(2);
    
    pulse_period <= reg_v(1)(15 downto 0);
    pulse_width <=  reg_v(2)(15 downto 0);
    pulse_delay <=  reg_v(3)(15 downto 0);
    pulse_count <=  reg_v(4)(15 downto 0);
    
-- programmable pulse generator
        inst_sync_pg : entity work.sync_pg 
        port map (
           enable => enable,
           reset  => reset_pg,
           polarity => polarity,
           pulse_count => pulse_count,
           pulse_width => pulse_width, 
           pulse_start => pulse_delay,
           pulse_period => pulse_period,
           clk => clkref40,
           output =>  q
        );

end rtl;

