------------------------------------------------------------------------------
--                                                                          --
--                                                                          --
--  32-bit Parallel PRBS Generator and Checker, configurable for 7,15,23,31 --
--                                                                          --
--                              TESTBENCH                                   --
--                                                                          --
--          Jose Pedro Castro Fonseca, CERN, EP-ESE-ME, August 2018         --
--                                                                          --
--                                                                          --
------------------------------------------------------------------------------
library std;
use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;

entity tb_PRBSgen is
end tb_PRBSgen;

architecture tb of tb_PRBSgen is

    -- Signals and variables
    signal mode     : std_logic_vector(4 downto 0);
    signal clk40MHz : std_logic := '0';
    signal reset    : std_logic := '1';
    signal dataOut  : std_logic_vector(31 downto 0);

    -- Internal simulation signals
    signal sim_running: boolean := true;

    -- Simulation parameters
    constant SIM_TIME    : time := 5 us;
    constant CLK_40M_PER : time := 25 ns;

    constant PRBS7_MODE  : std_logic_vector(1 downto 0) := B"00";
    constant PRBS15_MODE : std_logic_vector(1 downto 0) := B"01";
    constant PRBS23_MODE : std_logic_vector(1 downto 0) := B"10";
    constant PRBS31_MODE : std_logic_vector(1 downto 0) := B"11";
    constant HSX32_MODE : std_logic_vector(2 downto 0) := B"111";
    constant HSX16_MODE : std_logic_vector(2 downto 0) := B"110";
    constant HSX8_MODE  : std_logic_vector(2 downto 0) := B"101";
    constant LSX16_MODE : std_logic_vector(2 downto 0) := B"011";
    constant LSX8_MODE  : std_logic_vector(2 downto 0) := B"010";
    constant LSX4_MODE  : std_logic_vector(2 downto 0) := B"001";

begin
    -- Module instantiation
    PRBSgen: entity work.PRBSgen(rtl)
        port map (
            clk40MHz     => clk40MHz,
            reset        => reset,
            prbsTypeMode => mode(1 downto 0),
            dataRateMode => mode(4 downto 2),
            dataOut  => dataOut);
   
    -- Generating a 40MHz clock
    clkGen : process begin
        if (sim_running) then
            clk40MHz <= not clk40MHz;
            wait for CLK_40M_PER / 2;
        else
            wait;
        end if;
    end process clkGen;

    simulationBody : process 

        -- Procedure to reconstruct the stream and check the values 
        procedure prbs_check(
            constant prbsOut    : in std_logic_vector(31 downto 0);
            constant prbsSpeed  : in std_logic_vector(2 downto 0);
            constant prbsMode   : in std_logic_vector(1 downto 0)
        ) is
            
            variable numBits        : integer;
            variable numSamples     : integer;
            variable stateLen       : integer;
            variable state          : std_logic_vector(30 downto 0);
            variable stream_c0      : std_logic_vector(64000 downto 0);
            variable stream_c1      : std_logic_vector(64000 downto 0);
            variable stream_c2      : std_logic_vector(64000 downto 0);
            variable stream_c3      : std_logic_vector(64000 downto 0);
            variable recovStream_c0 : std_logic_vector(64000 downto 0);
            variable recovStream_c1 : std_logic_vector(64000 downto 0);
            variable recovStream_c2 : std_logic_vector(64000 downto 0);
            variable recovStream_c3 : std_logic_vector(64000 downto 0);
            variable msg : line;

            begin
                if (prbsSpeed = HSX32_MODE) then
                    numBits := 32;
                elsif (prbsSpeed = HSX16_MODE or prbsSpeed = LSX16_MODE) then
                    numBits := 16;
                elsif (prbsSpeed = HSX8_MODE  or prbsSpeed = LSX8_MODE) then
                    numBits := 8;
                elsif (prbsSpeed = LSX4_MODE) then
                    numBits := 4;
                else
                    numBits := 0;
                end if;

                if(prbsMode = PRBS7_MODE) then
                    stateLen := 7;
                    report("PRBS7 Mode");
                elsif(prbsMode = PRBS15_MODE) then
                    stateLen := 15;
                    report("PRBS15 Mode");
                elsif(prbsMode = PRBS23_MODE) then
                    stateLen := 23;
                    report("PRBS23 Mode");
                elsif(prbsMode = PRBS31_MODE) then
                    stateLen := 31;
                    report("PRBS31 Mode");
                else
                    stateLen := 0;
                    report("Error Mode");
                end if;
                
                numSamples := 64000/numBits;

                -- Reconstruct the stream coming from module
                for N in (numSamples-1) downto 0 loop
                    wait until rising_edge(clk40MHz);
                    wait for 1 ns;
                    if (prbsSpeed = HSX32_MODE) then
                        stream_c0(((N+1)*numBits-1) downto (N*numBits)) := prbsOut((numBits-1) downto 0);
                    elsif (prbsSpeed = HSX16_MODE) then
                        stream_c0(((N+1)*numBits-1) downto (N*numBits)) := prbsOut((numBits-1) downto 0);
                        stream_c2(((N+1)*numBits-1) downto (N*numBits)) := prbsOut((2*numBits-1) downto numBits);
                    elsif (prbsSpeed = HSX8_MODE) then
                        stream_c0(((N+1)*numBits-1) downto (N*numBits)) := prbsOut((numBits-1)   downto 0);
                        stream_c1(((N+1)*numBits-1) downto (N*numBits)) := prbsOut((2*numBits-1) downto numBits);
                        stream_c2(((N+1)*numBits-1) downto (N*numBits)) := prbsOut((3*numBits-1) downto 2*numBits);
                        stream_c3(((N+1)*numBits-1) downto (N*numBits)) := prbsOut((4*numBits-1) downto 3*numBits);
                    elsif (prbsSpeed = LSX16_MODE) then
                        stream_c0(((N+1)*numBits-1) downto (N*numBits)) := prbsOut((numBits-1) downto 0);
                    elsif (prbsSpeed = LSX8_MODE) then
                        stream_c0(((N+1)*numBits-1) downto (N*numBits)) := prbsOut((numBits-1) downto 0);
                        stream_c2(((N+1)*numBits-1) downto (N*numBits)) := prbsOut((2*numBits-1) downto numBits);
                    elsif (prbsSpeed = LSX4_MODE) then
                        stream_c0(((N+1)*numBits-1) downto (N*numBits)) := prbsOut((numBits-1)   downto 0);
                        stream_c1(((N+1)*numBits-1) downto (N*numBits)) := prbsOut((2*numBits-1) downto numBits);
                        stream_c2(((N+1)*numBits-1) downto (N*numBits)) := prbsOut((3*numBits-1) downto 2*numBits);
                        stream_c3(((N+1)*numBits-1) downto (N*numBits)) := prbsOut((4*numBits-1) downto 3*numBits);
                    end if;
                end loop;

                -- Load the initial state of the LFSR for channel 0
                if (prbsSpeed = HSX32_MODE or prbsSpeed = LSX16_MODE) then
                    state((stateLen-1) downto 0) := stream_c0( (numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1));
                    recovStream_c0((numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1)) := stream_c0((numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1));

                    -- Construct stream based upon the first bits of the stream
                    for I in (numBits*numSamples-1-stateLen) downto 0 loop
                        if(prbsMode = PRBS7_MODE) then
                            state := state(29 downto 0) & (state(6) xor state(5));
                        elsif(prbsMode = PRBS15_MODE) then
                            state := state(29 downto 0) & (state(14) xor state(13));
                        elsif(prbsMode = PRBS23_MODE) then
                            state := state(29 downto 0) & (state(17) xor state(22));
                        elsif(prbsMode = PRBS31_MODE) then
                            state := state(29 downto 0) & (state(30) xor state(27));
                        else
                        end if;
                        recovStream_c0(I) := state(0);
                    end loop;

                    if(recovStream_c0 /= stream_c0) then
                        write(msg, string'("!!ERROR!! CHAN0: ") & LF);
                        hwrite(msg, recovStream_c0(500 downto 0));
                        write(msg, LF);
                        hwrite(msg, stream_c0(500 downto 0));
                        writeline(output, msg);
                    else 
                        write(msg, string'("Good CHAN0: ") & LF);
                        hwrite(msg, recovStream_c0(500 downto 0));
                        write(msg, LF);
                        hwrite(msg, stream_c0(500 downto 0));
                        writeline(output, msg);
                    end if;

                elsif (prbsSpeed = LSX8_MODE  or prbsSpeed = HSX16_MODE) then
                    state((stateLen-1) downto 0) := stream_c0( (numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1));
                    recovStream_c0((numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1)) := stream_c0((numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1));
                    
                    -- Construct stream based upon the first bits of the stream
                    for I in (numBits*numSamples-1-stateLen) downto 0 loop
                        if(prbsMode = PRBS7_MODE) then
                            state := state(29 downto 0) & (state(6) xor state(5));
                        elsif(prbsMode = PRBS15_MODE) then
                            state := state(29 downto 0) & (state(14) xor state(13));
                        elsif(prbsMode = PRBS23_MODE) then
                            state := state(29 downto 0) & (state(17) xor state(22));
                        elsif(prbsMode = PRBS31_MODE) then
                            state := state(29 downto 0) & (state(30) xor state(27));
                        else
                        end if;
                        recovStream_c0(I) := state(0);
                    end loop;

                    if(recovStream_c0 /= stream_c0) then
                        write(msg, string'("!!ERROR!! CHAN0: ") & LF);
                        hwrite(msg, recovStream_c0(500 downto 0));
                        write(msg, LF);
                        hwrite(msg, stream_c0(500 downto 0));
                        writeline(output, msg);
                    else 
                        write(msg, string'("Good CHAN0: ") & LF);
                        hwrite(msg, recovStream_c0(500 downto 0));
                        write(msg, LF);
                        hwrite(msg, stream_c0(500 downto 0));
                        writeline(output, msg);
                    end if;

                    state((stateLen-1) downto 0) := stream_c2( (numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1));
                    recovStream_c2((numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1)) := stream_c2((numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1));

                    -- Construct stream based upon the first bits of the stream
                    for I in (numBits*numSamples-1-stateLen) downto 0 loop
                        if(prbsMode = PRBS7_MODE) then
                            state := state(29 downto 0) & (state(6) xor state(5));
                        elsif(prbsMode = PRBS15_MODE) then
                            state := state(29 downto 0) & (state(14) xor state(13));
                        elsif(prbsMode = PRBS23_MODE) then
                            state := state(29 downto 0) & (state(17) xor state(22));
                        elsif(prbsMode = PRBS31_MODE) then
                            state := state(29 downto 0) & (state(30) xor state(27));
                        else
                        end if;
                        recovStream_c2(I) := state(0);
                    end loop;

                    if(recovStream_c2 /= stream_c2) then
                        write(msg, string'("!!ERROR!! CHAN2: ") & LF);
                        hwrite(msg, recovStream_c2(500 downto 0));
                        write(msg, LF);
                        hwrite(msg, stream_c2(500 downto 0));
                        writeline(output, msg);
                    else 
                        write(msg, string'("Good CHAN2: ") & LF);
                        hwrite(msg, recovStream_c2(500 downto 0));
                        write(msg, LF);
                        hwrite(msg, stream_c2(500 downto 0));
                        writeline(output, msg);
                    end if;
                elsif (prbsSpeed = LSX4_MODE or prbsSpeed = HSX8_MODE) then
                    state((stateLen-1) downto 0) := stream_c0( (numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1));
                    recovStream_c0((numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1)) := stream_c0((numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1));

                    -- Construct stream based upon the first bits of the stream
                    for I in (numBits*numSamples-1-stateLen) downto 0 loop
                        if(prbsMode = PRBS7_MODE) then
                            state := state(29 downto 0) & (state(6) xor state(5));
                        elsif(prbsMode = PRBS15_MODE) then
                            state := state(29 downto 0) & (state(14) xor state(13));
                        elsif(prbsMode = PRBS23_MODE) then
                            state := state(29 downto 0) & (state(17) xor state(22));
                        elsif(prbsMode = PRBS31_MODE) then
                            state := state(29 downto 0) & (state(30) xor state(27));
                        else
                        end if;
                        recovStream_c0(I) := state(0);
                    end loop;

                    if(recovStream_c0 /= stream_c0) then
                        write(msg, string'("!!ERROR!! CHAN0: ") & LF);
                        hwrite(msg, recovStream_c0(500 downto 0));
                        write(msg, LF);
                        hwrite(msg, stream_c0(500 downto 0));
                        writeline(output, msg);
                    else 
                        write(msg, string'("Good CHAN0: ") & LF);
                        hwrite(msg, recovStream_c0(500 downto 0));
                        write(msg, LF);
                        hwrite(msg, stream_c0(500 downto 0));
                        writeline(output, msg);
                    end if;

                    state((stateLen-1) downto 0) := stream_c1( (numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1));
                    recovStream_c1((numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1)) := stream_c1((numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1));
                    
                    -- Construct stream based upon the first bits of the stream
                    for I in (numBits*numSamples-1-stateLen) downto 0 loop
                        if(prbsMode = PRBS7_MODE) then
                            state := state(29 downto 0) & (state(6) xor state(5));
                        elsif(prbsMode = PRBS15_MODE) then
                            state := state(29 downto 0) & (state(14) xor state(13));
                        elsif(prbsMode = PRBS23_MODE) then
                            state := state(29 downto 0) & (state(17) xor state(22));
                        elsif(prbsMode = PRBS31_MODE) then
                            state := state(29 downto 0) & (state(30) xor state(27));
                        else
                        end if;
                        recovStream_c1(I) := state(0);
                    end loop;

                    if(recovStream_c1 /= stream_c1) then
                        write(msg, string'("!!ERROR!! CHAN1: ") & LF);
                        hwrite(msg, recovStream_c1(500 downto 0));
                        write(msg, LF);
                        hwrite(msg, stream_c1(500 downto 0));
                        writeline(output, msg);
                    else 
                        write(msg, string'("Good CHAN1: ") & LF);
                        hwrite(msg, recovStream_c1(500 downto 0));
                        write(msg, LF);
                        hwrite(msg, stream_c1(500 downto 0));
                        writeline(output, msg);
                    end if;

                    state((stateLen-1) downto 0) := stream_c2( (numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1));
                    recovStream_c2((numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1)) := stream_c2((numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1));
                    
                    -- Construct stream based upon the first bits of the stream
                    for I in (numBits*numSamples-1-stateLen) downto 0 loop
                        if(prbsMode = PRBS7_MODE) then
                            state := state(29 downto 0) & (state(6) xor state(5));
                        elsif(prbsMode = PRBS15_MODE) then
                            state := state(29 downto 0) & (state(14) xor state(13));
                        elsif(prbsMode = PRBS23_MODE) then
                            state := state(29 downto 0) & (state(17) xor state(22));
                        elsif(prbsMode = PRBS31_MODE) then
                            state := state(29 downto 0) & (state(30) xor state(27));
                        else
                        end if;
                        recovStream_c2(I) := state(0);
                    end loop;

                    if(recovStream_c2 /= stream_c2) then
                        write(msg, string'("!!ERROR!! CHAN2: ") & LF);
                        hwrite(msg, recovStream_c2(500 downto 0));
                        write(msg, LF);
                        hwrite(msg, stream_c2(500 downto 0));
                        writeline(output, msg);
                    else 
                        write(msg, string'("Good CHAN2: ") & LF);
                        hwrite(msg, recovStream_c2(500 downto 0));
                        write(msg, LF);
                        hwrite(msg, stream_c2(500 downto 0));
                        writeline(output, msg);
                    end if;

                    state((stateLen-1) downto 0) := stream_c3( (numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1));
                    recovStream_c3((numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1)) := stream_c3((numSamples*numBits-1) downto (numSamples*numBits-1-stateLen+1));

                    -- Construct stream based upon the first bits of the stream
                    for I in (numBits*numSamples-1-stateLen) downto 0 loop
                        if(prbsMode = PRBS7_MODE) then
                            state := state(29 downto 0) & (state(6) xor state(5));
                        elsif(prbsMode = PRBS15_MODE) then
                            state := state(29 downto 0) & (state(14) xor state(13));
                        elsif(prbsMode = PRBS23_MODE) then
                            state := state(29 downto 0) & (state(17) xor state(22));
                        elsif(prbsMode = PRBS31_MODE) then
                            state := state(29 downto 0) & (state(30) xor state(27));
                        else
                        end if;
                        recovStream_c3(I) := state(0);
                    end loop;

                    if(recovStream_c3 /= stream_c3) then
                        write(msg, string'("!!ERROR!! CHAN3: ") & LF);
                        hwrite(msg, recovStream_c3(500 downto 0));
                        write(msg, LF);
                        hwrite(msg, stream_c3(500 downto 0));
                        writeline(output, msg);
                    else 
                        write(msg, string'("Good CHAN3: ") & LF);
                        hwrite(msg, recovStream_c3(500 downto 0));
                        write(msg, LF);
                        hwrite(msg, stream_c3(500 downto 0));
                        writeline(output, msg);
                    end if;
                else
                    numBits := 0;
                end if;


        end procedure prbs_check; 

    begin

        wait for 10 ns;
        reset <= '1';
        wait for 75 ns;
        reset <= '0';

        mode <= LSX8_MODE & PRBS7_MODE;
        wait until rising_edge(clk40MHz);
        prbs_check(dataOut, mode(4 downto 2), mode(1 downto 0));
    
        mode <= LSX4_MODE & PRBS7_MODE;
        wait until rising_edge(clk40MHz);
        prbs_check(dataOut, mode(4 downto 2), mode(1 downto 0));

        mode <= LSX4_MODE & PRBS7_MODE;
        wait until rising_edge(clk40MHz);
        prbs_check(dataOut, mode(4 downto 2), mode(1 downto 0));

        mode <= HSX8_MODE & PRBS7_MODE;
        wait until rising_edge(clk40MHz);
        prbs_check(dataOut, mode(4 downto 2), mode(1 downto 0));

        mode <= LSX16_MODE & PRBS7_MODE;
        wait until rising_edge(clk40MHz);
        prbs_check(dataOut, mode(4 downto 2), mode(1 downto 0));

        mode <= HSX16_MODE & PRBS7_MODE;
        wait until rising_edge(clk40MHz);
        prbs_check(dataOut, mode(4 downto 2), mode(1 downto 0));


        -- Simulation finished
        sim_running <= false;

    end process;
        
end architecture tb;





