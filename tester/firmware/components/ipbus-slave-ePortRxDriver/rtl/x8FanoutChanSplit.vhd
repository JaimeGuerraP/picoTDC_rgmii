------------------------------------------------------------------------------
--                                                                          --
--                                                                          --
--  Splits the Group data into Channels and fans-out bits to 8 for Serializer --
--                                                                          --
--  Jose Pedro Castro Fonseca, CERN, EP-ESE-ME, August 2018                 --
--                                                                          --
--                                                                          --
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity x8FanoutChanSplit is
    port (
        dataGroup    : in  std_logic_vector(31 downto 0); 
        dataRateMode : in  std_logic_vector(2  downto 0); -- {5G_or_10G<0>, dataRate<1:0>}
        chan0_part3  : out std_logic_vector(7 downto 0);
        chan0_part2  : out std_logic_vector(7 downto 0);
        chan0_part1  : out std_logic_vector(7 downto 0);
        chan0_part0  : out std_logic_vector(7 downto 0);
        chan1_part3  : out std_logic_vector(7 downto 0);
        chan1_part2  : out std_logic_vector(7 downto 0);
        chan1_part1  : out std_logic_vector(7 downto 0);
        chan1_part0  : out std_logic_vector(7 downto 0);
        chan2_part3  : out std_logic_vector(7 downto 0);
        chan2_part2  : out std_logic_vector(7 downto 0);
        chan2_part1  : out std_logic_vector(7 downto 0);
        chan2_part0  : out std_logic_vector(7 downto 0);
        chan3_part3  : out std_logic_vector(7 downto 0);
        chan3_part2  : out std_logic_vector(7 downto 0);
        chan3_part1  : out std_logic_vector(7 downto 0);
        chan3_part0  : out std_logic_vector(7 downto 0)
    );
end x8FanoutChanSplit;

architecture rtl of x8FanoutChanSplit is


    begin

    -- Splitting the nibbles of Channel 0, and performing fanout
    with dataRateMode select
        chan0_part0 <= dataGroup(7 downto 0)                                                                                                             when B"111",
                       (7 downto 6 => dataGroup(3)) & (5 downto 4 => dataGroup(2)) & (3 downto 2 => dataGroup(1)) & (1 downto 0 => dataGroup(0)) when B"110",
                       (7 downto 4 => dataGroup(1)) & (3 downto 0 => dataGroup(0))                                                                   when B"101",
                       (7 downto 6 => dataGroup(3)) & (5 downto 4 => dataGroup(2)) & (3 downto 2 => dataGroup(1)) & (1 downto 0 => dataGroup(0)) when B"011",
                       (7 downto 4 => dataGroup(1)) & (3 downto 0 => dataGroup(0))                                                                   when B"010",
                       (7 downto 0 => dataGroup(0))                                                                                                    when B"001",
                       X"00"                                                                                                                             when others;

    with dataRateMode select
        chan0_part1 <= dataGroup(15 downto 8)                                                                                                            when B"111",
                       (7 downto 6 => dataGroup(7)) & (5 downto 4 => dataGroup(6)) & (3 downto 2 => dataGroup(5)) & (1 downto 0 => dataGroup(4)) when B"110",
                       (7 downto 4 => dataGroup(3)) & (3 downto 0 => dataGroup(2))                                                              when B"101",
                       (7 downto 6 => dataGroup(7)) & (5 downto 4 => dataGroup(6)) & (3 downto 2 => dataGroup(5)) & (1 downto 0 => dataGroup(4)) when B"011",
                       (7 downto 4 => dataGroup(3)) & (3 downto 0 => dataGroup(2))                                                                  when B"010",
                       (7 downto 0 => dataGroup(1))                                                                                                    when B"001",
                       X"00"                                                                                                                             when others;

    with dataRateMode select
        chan0_part2 <= dataGroup(23 downto 16)                                                                                                             when B"111",
                       (7 downto 6 => dataGroup(11)) & (5 downto 4 => dataGroup(10)) & (3 downto 2 => dataGroup(9)) & (1 downto 0 => dataGroup(8)) when B"110",
                       (7 downto 4 => dataGroup(5))  & (3 downto 0 => dataGroup(4))                                                                    when B"101",
                       (7 downto 6 => dataGroup(11)) & (5 downto 4 => dataGroup(10)) & (3 downto 2 => dataGroup(9)) & (1 downto 0 => dataGroup(8)) when B"011",
                       (7 downto 4 => dataGroup(5))  & (3 downto 0 => dataGroup(4))                                                                    when B"010",
                       (7 downto 0 => dataGroup(2))                                                                                                      when B"001",
                       X"00"                                                                                                                               when others;

    with dataRateMode select
        chan0_part3 <= dataGroup(31 downto 24)                                                                                                               when B"111",
                       (7 downto 6 => dataGroup(15)) & (5 downto 4 => dataGroup(14)) & (3 downto 2 => dataGroup(13)) & (1 downto 0 => dataGroup(12)) when B"110",
                       (7 downto 4 => dataGroup(7))  & (3 downto 0 => dataGroup(6))                                                                      when B"101",
                       (7 downto 6 => dataGroup(15)) & (5 downto 4 => dataGroup(14)) & (3 downto 2 => dataGroup(13)) & (1 downto 0 => dataGroup(12)) when B"011",
                       (7 downto 4 => dataGroup(7))  & (3 downto 0 => dataGroup(6))                                                                       when B"010",
                       (7 downto 0 => dataGroup(3))                                                                                                        when B"001",
                       X"00"                                                                                                                                 when others;

    -- Splitting the nibbles of Channel 1, and performing fanout
    with dataRateMode select
        chan1_part0 <= (7 downto 0 => dataGroup(4))                                     when B"001",
                       (7 downto 4 => dataGroup(9)) & (3 downto 0 => dataGroup(8))      when B"101",
                       X"00"                                                            when others;

    with dataRateMode select
        chan1_part1 <= (7 downto 0 => dataGroup(5))                                     when B"001",
                       (7 downto 4 => dataGroup(11)) & (3 downto 0 => dataGroup(10))    when B"101",
                       X"00"                                                            when others;

    with dataRateMode select
        chan1_part2 <= (7 downto 0 => dataGroup(6))                                     when B"001",
                       (7 downto 4 => dataGroup(13)) & (3 downto 0 => dataGroup(12))    when B"101",
                       X"00"                                                            when others;

    with dataRateMode select
        chan1_part3 <= (7 downto 0 => dataGroup(7))                                     when B"001",
                       (7 downto 4 => dataGroup(15)) & (3 downto 0 => dataGroup(14))    when B"101",
                       X"00"                                                            when others;

    -- Splitting the nibbles of Channel 2, and performing fanout
    with dataRateMode select
        chan2_part0 <= (7 downto 0 => dataGroup(8))                                                                                                        when B"001",
                       (7 downto 4 => dataGroup(9))  & (3 downto 0 => dataGroup(8))                                                                       when B"010",
                       (7 downto 4 => dataGroup(17)) & (3 downto 0 => dataGroup(16))                                                                     when B"101",
                       (7 downto 6 => dataGroup(19)) & (5 downto 4 => dataGroup(18)) & (3 downto 2 => dataGroup(17)) & (1 downto 0 => dataGroup(16)) when B"110",
                       X"00"                                                                                                                                 when others;

    with dataRateMode select
        chan2_part1 <= (7 downto 0 => dataGroup(9))                                                                                                        when B"001",
                       (7 downto 4 => dataGroup(11)) & (3 downto 0 => dataGroup(10))                                                                     when B"010",
                       (7 downto 4 => dataGroup(19)) & (3 downto 0 => dataGroup(18))                                                                     when B"101",
                       (7 downto 6 => dataGroup(23)) & (5 downto 4 => dataGroup(22)) & (3 downto 2 => dataGroup(21)) & (1 downto 0 => dataGroup(20)) when B"110",
                       X"00"                                                                                                                                 when others;

    with dataRateMode select
        chan2_part2 <= (7 downto 0 => dataGroup(10))                                                                                                       when B"001",
                       (7 downto 4 => dataGroup(13)) & (3 downto 0 => dataGroup(12))                                                                     when B"010",
                       (7 downto 4 => dataGroup(21)) & (3 downto 0 => dataGroup(20))                                                                     when B"101",
                       (7 downto 6 => dataGroup(27)) & (5 downto 4 => dataGroup(26)) & (3 downto 2 => dataGroup(25)) & (1 downto 0 => dataGroup(24)) when B"110",
                       X"00"                                                                                                                                when others;

    with dataRateMode select
        chan2_part3 <= (7 downto 0 => dataGroup(11))                                                                                                       when B"001",
                       (7 downto 4 => dataGroup(15)) & (3 downto 0 => dataGroup(14))                                                                      when B"010",
                       (7 downto 4 => dataGroup(23)) & (3 downto 0 => dataGroup(22))                                                                     when B"101",
                       (7 downto 6 => dataGroup(31)) & (5 downto 4 => dataGroup(30)) & (3 downto 2 => dataGroup(29)) & (1 downto 0 => dataGroup(28)) when B"110",
                       X"00"                                                                                                                                 when others;

    -- Splitting the nibbles of Channel 1, and performing fanout
    with dataRateMode select
        chan3_part0 <= (7 downto 0 => dataGroup(12))                                      when B"001",
                       (7 downto 4 => dataGroup(25)) & (3 downto 0 => dataGroup(24))    when B"101",
                       X"00"                                                                when others;

    with dataRateMode select
        chan3_part1 <= (7 downto 0 => dataGroup(13))                                      when B"001",
                       (7 downto 4 => dataGroup(27)) & (3 downto 0 => dataGroup(26))    when B"101",
                       X"00"                                                               when others;

    with dataRateMode select
        chan3_part2 <= (7 downto 0 => dataGroup(14))                                      when B"001",
                       (7 downto 4 => dataGroup(29)) & (3 downto 0 => dataGroup(28))    when B"101",
                       X"00"                                                               when others;

    with dataRateMode select
        chan3_part3 <= (7 downto 0 => dataGroup(15))                                      when B"001",
                       (7 downto 4 => dataGroup(31)) & (3 downto 0 => dataGroup(30))    when B"101",
                       X"00"                                                                when others;

end rtl;

