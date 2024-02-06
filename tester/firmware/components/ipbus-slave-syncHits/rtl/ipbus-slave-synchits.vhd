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

entity ipbus_sync_hits is
generic (
    constant NB_CHANNELS :integer := 64;
    addr_width: natural := 0
    );
port (
    clk:   in  std_logic;
    reset:      in  std_logic;
    ipbus_in:   in  ipb_wbus;
    ipbus_out:  out ipb_rbus;
    clkref40:   in std_logic;
    sync_reset: in std_logic;
    qhit:       out std_logic_vector(NB_CHANNELS-1 downto 0)
    );
end ipbus_sync_hits;

architecture rtl of ipbus_sync_hits is

type register_type is array(0 to NB_CHANNELS-1) of std_logic_vector(15 downto 0);

signal enable   : std_logic_vector(NB_CHANNELS-1 downto 0);
signal reset_hit_gen : std_logic;
signal polarity : std_logic;
signal single : std_logic;

signal pulse_period  : std_logic_vector(15 downto 0);
signal pulse_width  : std_logic_vector(15 downto 0);
signal pulse_count  : std_logic_vector(15 downto 0);

signal pulse_start   : register_type;
signal reg_v         : ipb_reg_v( 67 downto 0 );

begin 
-- control  
    data_reg: entity work.ipbus_reg_v
            generic map(
          N_REG => 68
        )
            port map(
                clk => clk,
                reset => reset,
                ipbus_in => ipbus_in,
                ipbus_out => ipbus_out,
                q => reg_v
            );
    
    reset_hit_gen <= sync_reset or reg_v(0)(0);
    polarity <= reg_v(0)(1);
    single <= reg_v(0)(2);
    
    pulse_period <= reg_v(1)(15 downto 0);
    pulse_width <=  reg_v(2)(15 downto 0);
    pulse_count <=  reg_v(3)(15 downto 0);
    
-- programmable pulse generator
    sync_pg_hitin : for i in 0 to NB_CHANNELS-1 generate
        sync_pg_inst : entity work.sync_pg 
        port map (
           enable => reg_v(i+4)(16), -- enable(i),
           reset  => reset_hit_gen,
           polarity => polarity,
           pulse_count => pulse_count,
           pulse_width => pulse_width, --(i),
           pulse_start => reg_v(i+4)(15 downto 0), -- pulse_start(i),
           pulse_period => pulse_period,
           clk => clkref40,
           output =>  qhit(i)
        );
     --   pulse_start(i) <= reg_v(i+4)(15 downto 0);
     --   enable(i) <= reg_v(i+4)(16);
    end generate;

-- hit parameters

    
    
--    hit_conf : for j in 0 to NB_CHANNELS-1 generate
--        pulse_start(j) <= reg_v(j+4)(15 downto 0);
--        enable(j) <= reg_v(j+4)(16);
--    end generate;    
end rtl;
