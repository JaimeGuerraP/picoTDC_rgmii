--------------------------------------------------------------------------------------------------------------
--                                                                                                          --
--                                                                                                          --
--  Random Number Generator for each ePortRx group. Provides a random number of 32 bits                     --
--                                                                                                          --
--  Jose Pedro Castro Fonseca, CERN, EP-ESE-ME, September 2018                                              --
--                                                                                                          --
--                                                                                                          --
--------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- For simulation of Xilinx model of OSERDESE2
library UNISIM;
use UNISIM.vcomponents.all;

entity RNGen is
    generic (
        MAX_NUM_USER_PACKET : integer := 16
    );
    port (
        clk40MHz      : in  std_logic;
        osc1          : in  std_logic;
        osc2          : in  std_logic;
        reset         : in  std_logic;
        randomNumber  : out std_logic_vector (31 downto 0)
    );
end RNGen;

architecture rtl of RNGen is
    
    signal caReg            : std_logic_vector (36 downto 0);
    signal lfsrReg          : std_logic_vector (42 downto 0);
    signal lfsr_feedback    : std_logic;
    signal caRegNext        : std_logic_vector(36 downto 0);
    signal caSelect         : std_logic_vector(31 downto 0);
    signal lfsrSelect       : std_logic_vector(31 downto 0);
    signal randomNumberComb : std_logic_vector(31 downto 0);
    signal osc1Taps         : std_logic_vector(2 downto 0);  -- 3 Taps
    signal osc2Taps         : std_logic_vector(4 downto 0);  -- 5 Taps

    begin

        --------------------------- The LFSR ---------------------------
        lfsr_feedback <= lfsrReg(0) xor lfsrReg(19) xor lfsrReg(40) xor lfsrReg(42);

        process(osc1)
        begin
            if rising_edge(osc1) then
                if reset = '1' then
                    lfsrReg <= B"1010100011000110111101110001001010011011010";
                else
                    lfsrReg <= lfsrReg(41 downto 0) & lfsr_feedback;
                end if;
            end if;
        end process;
        
        --------------------------- The Cellular Automata ---------------------------
        process(caReg)
        begin
            for I in 0 to 36 loop
                if I = 27 then
                    caRegNext(27) <= caReg(I-1) xor caReg(I) xor caReg(I+1);
                elsif I = 0 then
                    caRegNext(0)  <= caReg(1);
                elsif I = 36 then
                    caRegNext(36) <= caReg(35);
                else
                    caRegNext(I) <= caReg(I-1) xor caReg(I+1);
                end if;
            end loop;
        end process;
        
        process(osc2)
        begin
            if rising_edge(osc2) then
                if reset = '1' then
                    caReg <= B"1010001110010011100101001001101101011";
                else
                    caReg <= caRegNext;
                end if;
            end if;
        end process;

        --------------------------- Permutations on the register contetnts ---------------------------
        lfsrSelect <= (lfsrReg(11) & lfsrReg(32) & lfsrReg(24) & lfsrReg(19) & lfsrReg(16) & lfsrReg(23) & lfsrReg(27) & lfsrReg(33) & lfsrReg(13) & lfsrReg(12) &
                       lfsrReg(1)  & lfsrReg(40) & lfsrReg(18) & lfsrReg(38) & lfsrReg(20) & lfsrReg(10) & lfsrReg(6)  & lfsrReg(21) & lfsrReg(2)  & lfsrReg(39) &
                       lfsrReg(34) & lfsrReg(41) & lfsrReg(25) & lfsrReg(8)  & lfsrReg(17) & lfsrReg(5)  & lfsrReg(35) & lfsrReg(15) & lfsrReg(26) & lfsrReg(7)  &
                       lfsrReg(3)  & lfsrReg(30));

        caSelect   <= (caReg(5)  & caReg(18) & caReg(12) & caReg(1)  & caReg(32) & caReg(7)  & caReg(36) & caReg(13) & caReg(3)  & caReg(30) &
                       caReg(14) & caReg(33) & caReg(34) & caReg(24) & caReg(20) & caReg(26) & caReg(16) & caReg(22) & caReg(17) & caReg(0)  &
                       caReg(21) & caReg(9)  & caReg(19) & caReg(6)  & caReg(27) & caReg(23) & caReg(31) & caReg(2)  & caReg(8)  & caReg(28)  &
                       caReg(29) & caReg(15));

        --------- Sampling the output number from the XOR of the lfsr/ca selection and permitation
        process(clk40MHz)
        begin
            if rising_edge(clk40MHz) then
                randomNumberComb <= lfsrSelect xor caSelect;
            end if;
        end process;

        process(clk40MHz)
        begin
            if rising_edge(clk40MHz) then
                randomNumber <= randomNumberComb;
            end if;
        end process;


end rtl;
