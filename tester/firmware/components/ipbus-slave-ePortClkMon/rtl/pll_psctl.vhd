-- PLL phase shift controller
--
-- Implements an adapter for the fine phase shifting functionality of the Virtex 7
-- MMCMs. The phase can be shifted to one of 56 phase steps (0 .. 55).
--
-- Stefan Biereigel, CERN, EP-ESE-ME, October 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pll_psctl is
	port (
		clk				: in std_logic;
		rst				: in std_logic;
		set_phase		: in std_logic;
		phase			: in unsigned(5 downto 0);
		ready			: out std_logic;
		pll_psclk		: out std_logic;
		pll_psincdec	: out std_logic;
		pll_psen		: out std_logic;
		pll_psdone		: in std_logic
	);
end pll_psctl;

architecture rtl of pll_psctl is
	constant phase_steps	: integer := 56;

	type state_t is (idle, change, wait_step);
	signal state 			: state_t := idle;
	signal target_phase		: unsigned(5 downto 0);	-- cleaned up target phase value
	signal current_phase	: unsigned(5 downto 0); -- phase currently set
begin
	phase_fsm : process
	begin
		wait until rising_edge(clk);
		case state is
			when idle =>
				-- sanitize phase value
				if phase < to_unsigned(phase_steps, phase'length) then
					target_phase <= phase;
				else
					target_phase <= to_unsigned(phase_steps - 1, target_phase'length);
				end if;

				-- initiate phase change
				if set_phase = '1' then
					state <= change;
					ready <= '0';
				else
					ready <= '1';
				end if;
			when change =>
				-- initiate phase steps if not arrived at target phase yet
				if current_phase = target_phase then
					state <= idle;
					ready <= '1';
				else
					--if current_phase = to_unsigned(phase_steps - 1, current_phase'length) then
					--	current_phase <= to_unsigned(0, current_phase'length);
					--else
					--	current_phase <= current_phase + to_unsigned(1, current_phase'length);
					--end if;
                    if target_phase > current_phase then
                        pll_psincdec <= '1';
						current_phase <= current_phase + to_unsigned(1, current_phase'length);
                    else
                        pll_psincdec <= '0';
						current_phase <= current_phase - to_unsigned(1, current_phase'length);
                    end if;
					pll_psen <= '1';
					state <= wait_step;
				end if;
			when wait_step =>
				-- wait until PSDONE is asserted by PLL, signaling the phase step finish
				pll_psen <= '0';
				if pll_psdone = '1' then
					state <= change;
				end if;
		end case;

		if rst = '1' then
			state <= idle;
			target_phase <= to_unsigned(0, target_phase'length);
			current_phase <= to_unsigned(0, current_phase'length);
			pll_psen <= '0';
		end if;
	end process;

	pll_psclk <= clk;

end rtl;


