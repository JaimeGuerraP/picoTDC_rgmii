library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.clkmon_pkg.all;

entity delay_line_tb is
end delay_line_tb;

architecture sim of delay_line_tb is
	signal clk_fast	: std_logic := '1';
	signal clk_slow	: std_logic := '0';
	signal rst		: std_logic := '1';
	signal trigger	: std_logic := '0';
	signal d		: std_logic := '0';
	signal done		: std_logic;
	signal results	: delay_line_results;

begin
	-- instantiate DUT
	dut : entity work.delay_line
	port map(clk_fast, clk_slow, rst, trigger, d, done, results);
	
	-- generate clock inputs
	clk_fast <= not clk_fast after 1.5625 ns / 2.0;
	clk_slow <= not clk_slow after 25 ns / 2.0;
	
	gen_meas_clk : process
		variable T : time := 1.5625 ns * 2;
		variable jitter : time := 200 ps;
	begin
		-- create jittery clock
		wait for 25 ns - 1.5625 ns - jitter / 2.0;
		while true loop
			d <= '1';
			wait for T / 2.0;
			d <= '0';
			wait for T / 2.0 + jitter;
			d <= '1';
			wait for T / 2.0;
			d <= '0';
			wait for T / 2.0 - jitter;
		end loop;
	end process;

	-- stimulate measurements
	trigger_measurement : process
	begin
		wait for 100 ns;
		rst <= '0';
		wait for 100 ns;
		wait until rising_edge(clk_slow);
		while true loop
			trigger <= '1';
			wait until rising_edge(clk_slow);
			trigger <= '0';
			wait until rising_edge(clk_slow);
			while done = '0' loop
				wait until rising_edge(clk_slow);
			end loop;
			for i in 0 to 3 loop
				wait until rising_edge(clk_slow);
			end loop;
		end loop;
	end process;
end sim;
