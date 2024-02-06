library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package clkmon_pkg is
	constant counter_width 	: integer := 8;
	constant line_taps 		: integer := 16;
	type delay_line_results        is array(0 to line_taps-1) of std_logic_vector(counter_width-1 downto 0);
end package;
