
library ieee;
use ieee.std_logic_1164.all;

entity enable_detect_12 is
  port (async_sig_12 : in std_logic_vector (11 downto 0);
        clk_12       : in std_logic;
        rise_12      : out std_logic_vector (11 downto 0)
	);
end;

architecture RTL of enable_detect_12 is

component enable_detect is
  port (async_sig : in std_logic;
        clk       : in std_logic;
        rise      : out std_logic);
end component;

begin

    GEN_REG: 
    for I in 0 to 11 generate
       sync : enable_detect 
        port map (
            async_sig => async_sig_12(I), 
            clk => clk_12, 
            rise => rise_12(I)
        );
    end generate GEN_REG;

end architecture;
