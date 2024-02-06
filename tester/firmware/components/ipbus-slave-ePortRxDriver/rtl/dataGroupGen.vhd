--------------------------------------------------------------------------------------------------------------
--                                                                                                          --
--                                                                                                          --
--  Data Generator for each ePortRx group. probides Prbs, Constant Pattern and user-defined 32 byte cycles  --
--                                                                                                          --
--  Jose Pedro Castro Fonseca, CERN, EP-ESE-ME, August 2018                                                 --
--                                                                                                          --
--                                                                                                          --
--------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity dataGroupGen is
    generic (
        MAX_NUM_USER_PACKET : integer := 16
    );
    port (
        userData      : in  std_logic_vector (MAX_NUM_USER_PACKET*32-1 downto 0);
        dataRateMode  : in  std_logic_vector (2  downto 0); -- {5G_or_10G<0>, dataRate<1:0>}
        dataSource    : in  std_logic_vector (1  downto 0); -- from 0 to 3 {PRBS, RNG, CONST_PATT, USERDATA}
        prbsTypeMode  : in  std_logic_vector (1  downto 0);
        clk40MHz      : in  std_logic;
        sameSeed      : in  std_logic;
        prbsSeed      : in  std_logic_vector (31 downto 0);
        reset         : in  std_logic;
        dataOut       : out std_logic_vector (31 downto 0)
    );
end dataGroupGen;

architecture rtl of dataGroupGen is
    
    -- Signals parsed from registers
    type USER_ROM is array (0 to MAX_NUM_USER_PACKET) of std_logic_vector(31 downto 0);

    signal userDataBytes : USER_ROM;
    signal prbsData     : std_logic_vector (31 downto 0);
    signal cpData       : std_logic_vector (31 downto 0);
    signal udData       : std_logic_vector (31 downto 0);
    signal numUdBytes   : std_logic_vector (4  downto 0); -- TODO automatic with generic
    signal byteCount    : std_logic_vector (4  downto 0); -- TODO automatic with generic
    signal prbsSeedLast : std_logic_vector (31 downto 0);
    signal prbsSeedLoad : std_logic_vector (2  downto 0);
    signal prbsReset    : std_logic;

    begin

        ---------------------------- The data Generators ----------------------------

        -- PRBS Generator, for 7,15,23,31
        PRBSgen_inst: entity work.PRBSgen
            port map (
                dataRateMode => dataRateMode,
                prbsTypeMode => prbsTypeMode,
                clk40MHz     => clk40MHz,
                reset        => prbsReset,
                sameSeed     => sameSeed,
                seed         => prbsSeedLast,
                dataOut      => prbsData
            );

        -- The logic to generate the loading signal for the prbs new seed 
        process(clk40MHz)
        begin
            if rising_edge(clk40MHz) then
                prbsSeedLast <= prbsSeed;
            end if;
        end process;
        
        prbsSeedLoad(0) <= '1' when (prbsSeedLast /= prbsSeed) else '0';
        
        process(clk40MHz)
        begin
            if rising_edge(clk40MHz) then
                prbsSeedLoad(2 downto 1) <= prbsSeedLoad(1 downto 0);
            end if;
        end process;
       
       prbsReset <= prbsSeedLoad(2) or reset;
        
        -- Constant Pattern
        process(clk40MHz)
        begin
            if rising_edge(clk40MHz) then
                cpData <= userData(31 downto 0);
            end if;
        end process;

        -- User Data
        process(clk40MHz)
        begin
            if rising_edge(clk40MHz) then
                if (reset = '1') then
                    for I in 0 to MAX_NUM_USER_PACKET-1 loop
                        userDataBytes(I)(31 downto 0) <= userData((I+1)*32-1 downto I*32); -- Loading data from registers
                    end loop;

                    byteCount <= (others => '0');
                else
                    if(byteCount = (MAX_NUM_USER_PACKET-1)) then
                        byteCount <= (others => '0');
                    else
                        byteCount <= byteCount + '1';
                    end if;
                    userDataBytes <= userDataBytes;
                end if;
            end if;            
        end process;

        udData <= userDataBytes(to_integer(unsigned(byteCount)));
        
        -----------------------------------------------------------------------------
        
        with dataSource select
            dataOut <= prbsData when B"00",
                       cpData   when B"01",
                       udData   when B"10",
                       X"00000000" when others;
end rtl;
