
library ieee;
use ieee.std_logic_1164.all;

entity enable_detect is
  port (async_sig : in std_logic;
        clk       : in std_logic;
        rise      : out std_logic);
end;

architecture RTL of enable_detect is
begin
  sync1 : process(clk)
    variable resync : std_logic_vector(1 to 3);
  begin
    if rising_edge(clk) then
      -- detect rising and falling edges.
      rise <= resync(2);
      -- update history shifter.
      resync := async_sig & resync(1 to 2);
    end if;
  end process;

end architecture;
