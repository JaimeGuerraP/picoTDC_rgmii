-- clock tap counter
--
-- Implements a single delay line tap for synchronous clock measurements. After trigger 
-- assertion, the tap output state is accumulated, giving the number of times the tap 
-- output was high during the measurement period.
--
-- Stefan Biereigel, CERN, EP-ESE-ME, October 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tap_counter is
	generic (
		counter_width : integer			-- accumulator width in bits
	);
	port (
		clk_fast	: in std_logic;
		clk_slow	: in std_logic;
        sample_en   : in std_logic;     -- fast clock domain sample clock enable
		rst			: in std_logic;		-- slow clock domain reset
		trigger		: in std_logic;		-- counter start, slow clock synchronous
		d			: in std_logic;		-- tap input, synchronous to fast clock
		q			: out std_logic;	-- tap output, synchronous to fast clock
		done		: out std_logic;
		count		: out unsigned(counter_width-1 downto 0)
	);
    attribute direct_enable : string;
    attribute direct_enable of sample_en: signal is "yes";
end tap_counter;

architecture rtl of tap_counter is
	type counter_state_t is (idle, counting);
	signal counter_state : counter_state_t := idle;
	signal tap_fast 	: std_logic := '0';
	signal tap_slow		: std_logic := '0';
    attribute extract_enable : string;
    attribute extract_enable of tap_slow: signal is "yes";
	signal counter 		: unsigned(counter_width-1 downto 0);	-- measurement cycle counter
	signal accumulator	: unsigned(counter_width-1 downto 0);	-- measurement accumulator
	signal tap_slow_dv	: std_logic_vector(0 downto 0);
begin
	-- delay input clock by one fast clock cycle
	tap_fast 	<= d when rising_edge(clk_fast);
	q 			<= tap_fast;

	-- move tap output into slow clock domain
    sample_tap : process
    begin
        wait until rising_edge(clk_fast);
        if sample_en = '1' then
            tap_slow <= tap_fast;
        end if;
    end process;
	tap_slow_dv(0)  <= tap_slow; 	-- for unsigned arithmetic

	-- sample output of tap at every slow clock cycle
	sample_clock : process
	begin
		wait until rising_edge(clk_slow);
		case counter_state is
			when idle =>
				done <= '1';
				if trigger = '1' then
					counter_state <= counting;
					done <= '0';
					counter <= (others => '1');
					accumulator <= (others => '0');
				end if;
			when counting =>
				counter <= counter - to_unsigned(1, counter'length);
				accumulator <= accumulator + unsigned(tap_slow_dv);
				if counter = to_unsigned(1, counter'length) then
					counter_state <= idle;
					done <= '1';
				end if;
		end case;

		if rst = '1' then
			counter_state <= idle;
		end if;
	end process;
	
	count <= accumulator;

end rtl;


