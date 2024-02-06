library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity edge_tb is end;

architecture test of edge_tb is
  signal clk, async, rise, fall : std_logic := '0';
begin

  UUT : entity work.edge_detect
       port map (async_sig => async,
                 clk => clk,
                 rise => rise,
                 fall => fall);

clk_gen : process begin
  while now < 1000 ns loop
    clk <= not clk;
    wait for 12.5 ns;
  end loop;
  wait;
end process;

-- Produce a randomly-changing async signal.
stim : process
  variable seed1, seed2 : POSITIVE;
  variable Rand : REAL;
  variable IRand : INTEGER;
begin
  while now < 1000 ns loop
    wait until FALLING_EDGE(Clk);
    -- make a random real between 0 and 1
    uniform(seed1, seed2, rand);
    -- turn it into a random integer between 50 and 150
    irand := integer((rand * 100.0  - 0.5) + 50.0 );
    -- wait for that many ns
    wait for irand * 1 ns;
    async <= not async;
  end loop;
  wait;
end process;

end architecture;

