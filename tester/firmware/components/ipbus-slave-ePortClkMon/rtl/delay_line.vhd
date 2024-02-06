-- delay_line
--
-- Implements a delay line for clock equivalent time scanning purposes. A synchronous
-- input clock is 'sampled' by a flip flop chain clocked at high clock frequency.
-- PLL based phase shifting can be used to further oversample this waveform
--
-- Stefan Biereigel, CERN, EP-ESE-ME, October 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.clkmon_pkg.all;

entity delay_line is
	port (
		clk_fast	: in std_logic;
		clk_slow	: in std_logic;
        sample_en   : in std_logic;
		rst			: in std_logic;		-- slow clock domain reset
		trigger		: in std_logic;		-- measurement start
		d			: in std_logic;		-- measurement signal input
		done		: out std_logic;
		results		: out delay_line_results
	);
end delay_line;

architecture rtl of delay_line is
	signal tap_outputs : std_logic_vector(0 to line_taps-1);
begin
	-- instantiate first delay line tap
	tap : entity work.tap_counter
	generic map (counter_width => counter_width)
	port map(
		clk_fast => clk_fast,
		clk_slow => clk_slow,
        sample_en => sample_en,
		rst => rst,
		trigger => trigger,
		d => d,
		q => tap_outputs(0),
		done => done,
		std_logic_vector(count) => results(0)
	);

	-- build rest of delay line
	gen_taps : for i in 1 to line_taps-1 generate
		tap : entity work.tap_counter
		generic map (counter_width => counter_width)
		port map(
			clk_fast => clk_fast,
			clk_slow => clk_slow,
            sample_en => sample_en,
			rst => rst,
			trigger => trigger,
			d => tap_outputs(i-1),
			q => tap_outputs(i),
			done => open,
			std_logic_vector(count) => results(i)
		);
	end generate;
end rtl;


