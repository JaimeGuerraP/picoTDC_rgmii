library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.VComponents.all;

entity 125_clock_shifter is 
    port (
        -- Add all your required ports here
        -- I highly recommend grouping them in types and subtypes if need be

        -- INPUTS
        master125clk: in std_logic; 
        
        -- OUTPUTS
        clk125: out std_logic;
        clk125_90: out std_logic;
    );

end 125_clock_shifter;
    
architecture rtl of 125_clock_shifter is
    signal clk_125, clk_125_90, clk125_o, clk125_90_o, clkfb: std_logic;

begin
    bufg125clk: BUFG 
        port map(
        i => master125clk,
        o => clk_125
    );
    mmcm125: MMCME2_BASE
        generic map(
            clkfbout_mult_f  => 8.0,
            clkout0_divide_f => 8.0,
            clkout1_divide_f   => 8.0,
            clkout1_phase => 90
            -- clkin1_period    => 5.0
        )
        port map(
            clkin1 => clk_125,        
            clkfbin => clkfb,
            clkfbout => clkfb,
            clkout0 => clk125_o,
            clkout1 => clk125_90_o,        -- (125*8)/(8)= 125 MHz
            locked => open,
            rst => '0',
            pwrdwn => '0'
        );
    
        clk125 <= clk125_o;
        clk125_90 <= clk125_90_o;
        
    end rtl;