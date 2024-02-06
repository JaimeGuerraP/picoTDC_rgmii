------------------------------------------------------------------------------
--                                                                          --
--                                                                          --
--  32-bit Parallel PRBS Generator and Checker, configurable for 7,15,23,31 --
--                                                                          --
--  Jose Pedro Castro Fonseca, CERN, EP-ESE-ME, August 2018                 --
--                                                                          --
--                                                                          --
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity PRBSgen is
    port (
        dataRateMode : in  std_logic_vector(2  downto 0); -- {5G_or_10G<0>, dataRate<1:0>} 
        prbsTypeMode : in  std_logic_vector(1  downto 0);
        sameSeed     : in  std_logic;
        seed         : in  std_logic_vector(31 downto 0);
        clk40MHz     : in  std_logic;
        reset        : in  std_logic;
        dataOut      : out std_logic_vector(31 downto 0)
    );
end PRBSgen;

architecture rtl of PRBSgen is

    signal prbsReg_c0   : std_logic_vector(31 downto 0);
    signal prbsReg_c1   : std_logic_vector(31 downto 0);
    signal prbsReg_c2   : std_logic_vector(31 downto 0);
    signal prbsReg_c3   : std_logic_vector(31 downto 0);

    ----------- Function to generate 'numBits' bits of PRBS<mode[1:0]> -----------------------------
    function prbsAdvanceState (
        numBits   : in integer;
        mode      : in std_logic_vector(1 downto 0);
        initstate : in std_logic_vector(31 downto 0)) 

        return std_logic_vector is
        
        variable regstate: std_logic_vector(31 downto 0);
        
        begin


            for I in 0 to (numBits-1) loop
                if (I = 0) then
                    if (mode = B"00") then
                        if(initstate(6 downto 0) = B"0000000") then
                            regstate := initstate(30 downto 0) & '1';
                        else
                            regstate := initstate(30 downto 0) & ( initstate(6)  xor initstate(5)  );
                        end if;
                    elsif (mode = B"01") then
                        if(initstate(14 downto 0) = B"000000000000000") then
                            regstate := initstate(30 downto 0) & '1';
                        else
                            regstate := initstate(30 downto 0) & ( initstate(14) xor initstate(13) );
                        end if;
                    elsif (mode = B"10") then
                        if(initstate(22 downto 0) = B"00000000000000000000000") then
                            regstate := initstate(30 downto 0) & '1';
                        else
                            regstate := initstate(30 downto 0) & ( initstate(17) xor initstate(22) );
                        end if;
                    elsif (mode = B"11") then
                        if(initstate(30 downto 0) = B"0000000000000000000000000000000") then
                            regstate := initstate(30 downto 0) & '1';
                        else
                            regstate := initstate(30 downto 0) & ( initstate(30) xor initstate(27) );
                        end if;
                    else 
                        regstate := X"12831213";
                    end if;
                else
                    if (mode = B"00") then
                        regstate := regstate(30 downto 0) & ( regstate(6)  xor regstate(5)  );
                    elsif (mode = B"01") then
                        regstate := regstate(30 downto 0) & ( regstate(14) xor regstate(13) );
                    elsif (mode = B"10") then
                        regstate := regstate(30 downto 0) & ( regstate(17) xor regstate(22) );
                    elsif (mode = B"11") then
                        regstate := regstate(30 downto 0) & ( regstate(30) xor regstate(27) );
                    else
                        regstate := X"12831213";
                    end if;
                end if;
            end loop;
        
        return regstate;
        
    end prbsAdvanceState;
    ------------------------------------------------------------------------------------------------

begin

    -- Constructing the group register according to the dataRateMode for PRBS7
    with dataRateMode select
        dataOut <= 
            X"0000" & prbsReg_c3(3 downto 0) & prbsReg_c2(3 downto 0) & prbsReg_c1(3 downto 0) & prbsReg_c0(3 downto 0) when B"001",
            X"0000" & prbsReg_c2(7 downto 0)  & prbsReg_c0(7 downto 0)                                       when B"010",
            X"0000" & prbsReg_c0(15 downto 0)                                                              when B"011",
            prbsReg_c3(7  downto 0)  & prbsReg_c2(7  downto 0) & prbsReg_c1(7 downto 0) & prbsReg_c0(7 downto 0) when B"101",
            prbsReg_c2(15 downto 0)  & prbsReg_c0(15 downto 0)                                           when B"110",
            prbsReg_c0(31 downto 0)                                                                      when B"111",
            X"00000000"                                                                                  when others;

    -- Generating the PRBS7 sequence
    process(clk40MHz, reset)
    begin
        if (rising_edge(clk40MHz)) then
            if (reset = '1') then
                if (sameSeed = '1') then
                    prbsReg_c0  <= seed;
                    prbsReg_c1  <= seed;
                    prbsReg_c2  <= seed;
                    prbsReg_c3  <= seed;
                else
                    prbsReg_c0  <= seed(7 downto 0)   & seed(31 downto 24) & seed(15 downto 8)  & seed(23 downto 16);
                    prbsReg_c1  <= seed(15 downto 8)  & seed(15 downto 8)  & seed(23 downto 16) & seed(31 downto 24);
                    prbsReg_c2  <= seed(31 downto 24) & seed(7  downto 0)  & seed(23 downto 16) & seed(15 downto 8);
                    prbsReg_c3  <= seed(23 downto 16) & seed(15  downto 8) & seed(31 downto 24) & seed(7 downto 0);
                end if;
            -- This is only enabled if the data rate is not set to 'IDLE' and we select the appropriate PRBS mode
            elsif (dataRateMode(1 downto 0) /= B"00" and prbsTypeMode = B"00") then
                case dataRateMode is
                    when B"001"  => 
                        prbsReg_c0 <= prbsAdvanceState(4,  "00", prbsReg_c0); 
                        prbsReg_c1 <= prbsAdvanceState(4,  "00", prbsReg_c1); 
                        prbsReg_c2 <= prbsAdvanceState(4,  "00", prbsReg_c2); 
                        prbsReg_c3 <= prbsAdvanceState(4,  "00", prbsReg_c3); 
                    when B"010"  => 
                        prbsReg_c0 <= prbsAdvanceState(8,  "00", prbsReg_c0); 
                        prbsReg_c2 <= prbsAdvanceState(8,  "00", prbsReg_c2); 
                    when B"011"  => 
                        prbsReg_c0 <= prbsAdvanceState(16, "00", prbsReg_c0); 
                    when B"101"  => 
                        prbsReg_c0 <= prbsAdvanceState(8,  "00", prbsReg_c0); 
                        prbsReg_c1 <= prbsAdvanceState(8,  "00", prbsReg_c1); 
                        prbsReg_c2 <= prbsAdvanceState(8,  "00", prbsReg_c2); 
                        prbsReg_c3 <= prbsAdvanceState(8,  "00", prbsReg_c3); 
                    when B"110"  => 
                        prbsReg_c0 <= prbsAdvanceState(16, "00", prbsReg_c0); 
                        prbsReg_c2 <= prbsAdvanceState(16, "00", prbsReg_c2); 
                    when B"111"  => 
                        prbsReg_c0 <= prbsAdvanceState(32, "00", prbsReg_c0); 
                    when others  => 
                        prbsReg_c0 <= X"00000000";
                        prbsReg_c1 <= X"00000000";
                        prbsReg_c2 <= X"00000000";
                        prbsReg_c3 <= X"00000000";
                end case;
            elsif (dataRateMode(1 downto 0) /= B"00" and prbsTypeMode = B"01") then
                case dataRateMode is
                    when B"001"  => 
                        prbsReg_c0 <= prbsAdvanceState(4,  "01", prbsReg_c0); 
                        prbsReg_c1 <= prbsAdvanceState(4,  "01", prbsReg_c1); 
                        prbsReg_c2 <= prbsAdvanceState(4,  "01", prbsReg_c2); 
                        prbsReg_c3 <= prbsAdvanceState(4,  "01", prbsReg_c3); 
                    when B"010"  => 
                        prbsReg_c0 <= prbsAdvanceState(8,  "01", prbsReg_c0); 
                        prbsReg_c2 <= prbsAdvanceState(8,  "01", prbsReg_c2); 
                    when B"011"  => 
                        prbsReg_c0 <= prbsAdvanceState(16, "01", prbsReg_c0); 
                    when B"101"  => 
                        prbsReg_c0 <= prbsAdvanceState(8,  "01", prbsReg_c0); 
                        prbsReg_c1 <= prbsAdvanceState(8,  "01", prbsReg_c1); 
                        prbsReg_c2 <= prbsAdvanceState(8,  "01", prbsReg_c2); 
                        prbsReg_c3 <= prbsAdvanceState(8,  "01", prbsReg_c3); 
                    when B"110"  => 
                        prbsReg_c0 <= prbsAdvanceState(16, "01", prbsReg_c0); 
                        prbsReg_c2 <= prbsAdvanceState(16, "01", prbsReg_c2); 
                    when B"111"  => 
                        prbsReg_c0 <= prbsAdvanceState(32, "01", prbsReg_c0); 
                    when others  => 
                        prbsReg_c0 <= X"00000000";
                        prbsReg_c1 <= X"00000000";
                        prbsReg_c2 <= X"00000000";
                        prbsReg_c3 <= X"00000000";
                end case;
            elsif (dataRateMode(1 downto 0) /= B"00" and prbsTypeMode = B"10") then
                case dataRateMode is
                    when B"001"  => 
                        prbsReg_c0 <= prbsAdvanceState(4,  "10", prbsReg_c0); 
                        prbsReg_c1 <= prbsAdvanceState(4,  "10", prbsReg_c1); 
                        prbsReg_c2 <= prbsAdvanceState(4,  "10", prbsReg_c2); 
                        prbsReg_c3 <= prbsAdvanceState(4,  "10", prbsReg_c3); 
                    when B"010"  => 
                        prbsReg_c0 <= prbsAdvanceState(8,  "10", prbsReg_c0); 
                        prbsReg_c2 <= prbsAdvanceState(8,  "10", prbsReg_c2); 
                    when B"011"  => 
                        prbsReg_c0 <= prbsAdvanceState(16, "10", prbsReg_c0); 
                    when B"101"  => 
                        prbsReg_c0 <= prbsAdvanceState(8,  "10", prbsReg_c0); 
                        prbsReg_c1 <= prbsAdvanceState(8,  "10", prbsReg_c1); 
                        prbsReg_c2 <= prbsAdvanceState(8,  "10", prbsReg_c2); 
                        prbsReg_c3 <= prbsAdvanceState(8,  "10", prbsReg_c3); 
                    when B"110"  => 
                        prbsReg_c0 <= prbsAdvanceState(16, "10", prbsReg_c0); 
                        prbsReg_c2 <= prbsAdvanceState(16, "10", prbsReg_c2); 
                    when B"111"  => 
                        prbsReg_c0 <= prbsAdvanceState(32, "10", prbsReg_c0); 
                    when others  => 
                        prbsReg_c0 <= X"00000000";
                        prbsReg_c1 <= X"00000000";
                        prbsReg_c2 <= X"00000000";
                        prbsReg_c3 <= X"00000000";
                end case;
            elsif (dataRateMode(1 downto 0) /= B"00" and prbsTypeMode = B"11") then
                case dataRateMode is
                    when B"001"  => 
                        prbsReg_c0 <= prbsAdvanceState(4,  "11", prbsReg_c0); 
                        prbsReg_c1 <= prbsAdvanceState(4,  "11", prbsReg_c1); 
                        prbsReg_c2 <= prbsAdvanceState(4,  "11", prbsReg_c2); 
                        prbsReg_c3 <= prbsAdvanceState(4,  "11", prbsReg_c3); 
                    when B"010"  => 
                        prbsReg_c0 <= prbsAdvanceState(8,  "11", prbsReg_c0); 
                        prbsReg_c2 <= prbsAdvanceState(8,  "11", prbsReg_c2); 
                    when B"011"  => 
                        prbsReg_c0 <= prbsAdvanceState(16, "11", prbsReg_c0); 
                    when B"101"  => 
                        prbsReg_c0 <= prbsAdvanceState(8,  "11", prbsReg_c0); 
                        prbsReg_c1 <= prbsAdvanceState(8,  "11", prbsReg_c1); 
                        prbsReg_c2 <= prbsAdvanceState(8,  "11", prbsReg_c2); 
                        prbsReg_c3 <= prbsAdvanceState(8,  "11", prbsReg_c3); 
                    when B"110"  => 
                        prbsReg_c0 <= prbsAdvanceState(16, "11", prbsReg_c0); 
                        prbsReg_c2 <= prbsAdvanceState(16, "11", prbsReg_c2); 
                    when B"111"  => 
                        prbsReg_c0 <= prbsAdvanceState(32, "11", prbsReg_c0); 
                    when others  => 
                        prbsReg_c0 <= X"00000000";
                        prbsReg_c1 <= X"00000000";
                        prbsReg_c2 <= X"00000000";
                        prbsReg_c3 <= X"00000000";
                end case;
                
            end if;
        end if;
    end process;

end rtl;
        
