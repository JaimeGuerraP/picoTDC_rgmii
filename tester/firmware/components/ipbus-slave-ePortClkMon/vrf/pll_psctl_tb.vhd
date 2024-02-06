library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pll_psctl_tb is
end pll_psctl_tb;

architecture behavior of pll_psctl_tb is

	-- Component Declaration for the Unit Under Test (UUT)
	component pll_psctl is
	port (
		clk				: in	std_logic;
		rst				: in	std_logic;
		set_phase		: in	std_logic;
		phase			: in	unsigned(5 downto 0);
		ready			: out	std_logic;
		pll_psclk		: out	std_logic;
		pll_psincdec	: out	std_logic;
		pll_psen		: out	std_logic;
		pll_psdone		: in	std_logic
	);
	end component;

	-- Inputs
	signal	clk				: std_logic:='0';
	signal	rst				: std_logic:='1';
	signal	set_phase		: std_logic:='0';
	signal	phase			: unsigned(5 downto 0) := (others => '0');
	signal	pll_psdone		: std_logic:='0';

	-- Outputs
	signal	ready			: std_logic;
	signal	pll_psclk		: std_logic;
	signal	pll_psincdec	: std_logic;
	signal	pll_psen		: std_logic;

	-- Clock period definitions
	constant clk_period : time := 25 ns;
	
	-- PLL behavior state	
	type pll_state_t is (waiting, do_step);
	signal pll_state : pll_state_t := waiting;
	signal pll_cycle_counter : integer := 0;
begin

	pll_psctl_inst : pll_psctl
	port map(
		clk				=>	clk,
		rst				=>	rst,
		set_phase		=>	set_phase,
		phase			=>	phase,
		ready			=>	ready,
		pll_psclk		=>	pll_psclk,
		pll_psincdec	=>	pll_psincdec,
		pll_psen		=>	pll_psen,
		pll_psdone		=>	pll_psdone
	);

	-- Clock process definitions
	process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	-- Stimulus process
	stimulus : process
	begin
		-- hold reset state for 100 ns
		wait for 100 ns;
		rst <= '0';

		for i in 0 to 10 loop
			wait until rising_edge(clk);
		end loop;
		phase <= to_unsigned(32, phase'length);
		set_phase <= '1';
		wait until rising_edge(clk);
		set_phase <= '0';

		wait until rising_edge(ready);
		for i in 0 to 10 loop
			wait until rising_edge(clk);
		end loop;
		phase <= to_unsigned(31, phase'length);
		set_phase <= '1';
		wait until rising_edge(clk);
		set_phase <= '0';
		
		wait until rising_edge(ready);
		for i in 0 to 10 loop
			wait until rising_edge(clk);
		end loop;
		phase <= to_unsigned(63, phase'length);
		set_phase <= '1';
		wait until rising_edge(clk);
		set_phase <= '0';
		
		wait until rising_edge(ready);
		for i in 0 to 10 loop
			wait until rising_edge(clk);
		end loop;
		phase <= to_unsigned(63, phase'length);
		set_phase <= '1';
		wait until rising_edge(clk);
		set_phase <= '0';


		wait;
	end process;

	-- PLL behavioral model
	pll_behav : process
	begin
		wait until rising_edge(clk);
		case pll_state is
			when waiting =>
				pll_psdone <= '0';
				if pll_psen = '1' then
					pll_cycle_counter <= 0;
					pll_state <= do_step;
				end if;
			when do_step =>
				pll_cycle_counter <= pll_cycle_counter + 1;
				if pll_cycle_counter = 11 then
					pll_state <= waiting;
					pll_psdone <= '1';
				end if;
		end case;
	end process;

end behavior;

