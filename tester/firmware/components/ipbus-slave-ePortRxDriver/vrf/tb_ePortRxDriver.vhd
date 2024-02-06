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
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

entity tb_ePortRxDriver is
end tb_ePortRxDriver;

architecture tb of tb_ePortRxDriver is

    -- Signals and variables
    signal mode      : std_logic_vector(4 downto 0);
    signal clk40MHz  : std_logic := '0';
    signal clk160MHz : std_logic;
    signal reset     : std_logic := '1';
    signal dataRateMode_sel : std_logic_vector(20 downto 0);
    signal prbsTypeMode_sel : std_logic_vector(13 downto 0);
    signal dataSource_sel   : std_logic_vector(13 downto 0);
    signal serialOut        : std_logic_vector(27 downto 0);
    signal clkDivCnt        : unsigned(5 downto 0) := B"000000";
    signal userDataPatt     : std_logic_vector(16*32-1 downto 0);
    signal clkSynthLock     : std_logic;
    -- Internal simulation signals
    signal sim_running: boolean := true;

    -- Simulation parameters
    constant SIM_TIME     : time := 1 us;
    constant CLK_40M_PER : time  := 25 ns;

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
    ePortRxDriver: entity work.ePortRxDriver(rtl)
        generic map (
            MAX_NUM_USER_PACKET => 16
        )
        port map (
            userData     => userDataPatt, 
            constPattern => X"ABCD000F",
            dataRateMode => dataRateMode_sel, -- {5G_or_10G<0>, dataRate<1:0>}, for each group (3bits X 7 groups = 21 bits)
            dataSource   => dataSource_sel, -- from 0 to 3 {PRBS, RNG, CONST_PATT, USERDATA} (2bits X 7 groups = 14 bits)
            prbsTypeMode => prbsTypeMode_sel, -- from o to 3 {7,15,23,31} (2 X 7 groups = 14 bits}
            clk40MHz     => clk40MHz,
            clk160MHzout => clk160MHz,
            clkSynthLock => clkSynthLock,
            reset        => reset,
            channel      => serialOut -- Serial outputs for each channel
        ); 

    -- Generating a 40MHz clock
    clkGen40MHz : process begin
        if (sim_running) then
            clk40MHz <= not clk40MHz;
            wait for CLK_40M_PER / 2;
        else
            wait;
        end if;
    end process clkGen40MHz;

    userDataPatt(511 downto 384) <= X"11111111" & X"22222222" & X"33333333" & X"77777777" ;
    userDataPatt(383 downto 0)   <= (others => '0');

    simulationBody : process 

        procedure prbs_check(
            signal stream     : in std_logic;
            numBits    : in integer;
            prbsSpeed  : in std_logic_vector(2 downto 0);
            prbsMode   : in std_logic_vector(1 downto 0)
        ) is
            
            variable bitTime   : time;
            variable stateLen  : integer;
            variable state     : std_logic_vector(30 downto 0);
            variable msg       : line;

            begin
                if (prbsSpeed = HSX32_MODE) then
                    bitTime := 781.25 ps;
                    report("1G28 Mode");
                elsif (prbsSpeed = HSX16_MODE or prbsSpeed = LSX16_MODE) then
                    bitTime := 1.5625 ns;
                    report("640M Mode");
                elsif (prbsSpeed = HSX8_MODE  or prbsSpeed = LSX8_MODE) then
                    bitTime := 3.125 ns;
                    report("320M Mode");
                elsif (prbsSpeed = LSX4_MODE) then
                    bitTime := 6.25 ns;
                    report("160M Mode");
                else
                    bitTime := 0 ns;
                    report("ERROR Idle Mode");
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

                -- Sync with the stream
                wait until rising_edge(stream);
                wait for 10 ps;

                for I in stateLen-1 downto 0 loop
                    state(I):= stream;
                    wait for bitTime;
                end loop;

                -- Fetch samples
                for N in 0 to (numBits-1) loop
                    if(prbsMode = PRBS7_MODE) then
                        state := state(29 downto 0) & (state(6) xor state(5));
                    elsif(prbsMode = PRBS15_MODE) then
                        state := state(29 downto 0) & (state(14) xor state(13));
                    elsif(prbsMode = PRBS23_MODE) then
                        state := state(29 downto 0) & (state(17) xor state(22));
                    elsif(prbsMode = PRBS31_MODE) then
                        state := state(29 downto 0) & (state(30) xor state(27));
                    end if;
                    
                    if( state(0) /= stream) then
                        assert false report "Error!" severity error;
                        write(msg, state(0));
                        write(msg, string'(" "));
                        write(msg, stream);
                        writeline(output, msg);
                    --else 
                    --    write(msg, string'("Good: "));
                    --   write(msg, state(0));
                    --    write(msg, string'(" "));
                    --    write(msg, stream);
                    --    writeline(output, msg);
                    end if;

                    wait for bitTime; 
                end loop;
            end procedure prbs_check;

        begin

        -- Waits until the MMCM internal PLL is locked
        wait until rising_edge(clkSynthLock);

        wait for 10 ns;
        reset <= '1';
        wait for 60 ns;
        wait until falling_edge(clk160MHz);
        reset <= '0';

        --dataRateMode_sel <= HSX32_MODE & HSX32_MODE & HSX32_MODE & HSX32_MODE & HSX32_MODE & HSX32_MODE & HSX32_MODE; 
        --dataSource_sel   <= B"11" & B"11" & B"11" & B"11" & B"11" & B"11" & B"11";
        --wait for 1 us;

        --dataSource_sel   <= B"10" & B"10" & B"10" & B"10" & B"10" & B"10" & B"10";
        --wait for 1 us;
        -------------------------------------------------------------------------------------------------------------

        dataRateMode_sel <= HSX32_MODE & HSX32_MODE & HSX32_MODE & HSX32_MODE & HSX32_MODE & HSX32_MODE & HSX32_MODE; 
        dataSource_sel   <= B"00" & B"00" & B"00" & B"00" & B"00" & B"00" & B"00";
        prbsTypeMode_sel <= PRBS7_MODE & PRBS7_MODE & PRBS7_MODE & PRBS7_MODE & PRBS7_MODE & PRBS7_MODE & PRBS7_MODE;

        wait for 250 ns;
        prbs_check(serialOut(0),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  

        -------------------------------------------------------------------------------------------------------------

        dataRateMode_sel <= HSX32_MODE & HSX32_MODE & HSX32_MODE & HSX32_MODE & HSX32_MODE & HSX32_MODE & HSX32_MODE; 
        dataSource_sel   <= B"00" & B"00" & B"00" & B"00" & B"00" & B"00" & B"00";
        prbsTypeMode_sel <= PRBS15_MODE & PRBS15_MODE & PRBS15_MODE & PRBS15_MODE & PRBS15_MODE & PRBS15_MODE & PRBS15_MODE;

        wait for 250 ns;
        prbs_check(serialOut(4), 500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        
        -------------------------------------------------------------------------------------------------------------

        dataRateMode_sel <= HSX32_MODE & HSX32_MODE & HSX32_MODE & HSX32_MODE & HSX32_MODE & HSX32_MODE & HSX32_MODE; 
        dataSource_sel   <= B"00" & B"00" & B"00" & B"00" & B"00" & B"00" & B"00";
        prbsTypeMode_sel <= PRBS23_MODE & PRBS23_MODE & PRBS23_MODE & PRBS23_MODE & PRBS23_MODE & PRBS23_MODE & PRBS23_MODE;

        wait for 250 ns;
        prbs_check(serialOut(24), 500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  

        -------------------------------------------------------------------------------------------------------------

        dataRateMode_sel <= HSX32_MODE & HSX32_MODE & HSX32_MODE & HSX32_MODE & HSX32_MODE & HSX32_MODE & HSX32_MODE; 
        dataSource_sel   <= B"00" & B"00" & B"00" & B"00" & B"00" & B"00" & B"00";
        prbsTypeMode_sel <= PRBS31_MODE & PRBS31_MODE & PRBS31_MODE & PRBS31_MODE & PRBS31_MODE & PRBS31_MODE & PRBS31_MODE;

        wait for 250 ns;
        prbs_check(serialOut(8), 500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  

        -------------------------------------------------------------------------------------------------------------

        dataRateMode_sel <= LSX16_MODE & LSX16_MODE & LSX16_MODE & LSX16_MODE & LSX16_MODE & LSX16_MODE & LSX16_MODE; 
        dataSource_sel   <= B"00" & B"00" & B"00" & B"00" & B"00" & B"00" & B"00";
        prbsTypeMode_sel <= PRBS31_MODE & PRBS31_MODE & PRBS31_MODE & PRBS31_MODE & PRBS31_MODE & PRBS31_MODE & PRBS31_MODE;

        wait for 250 ns;
        prbs_check(serialOut(4),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  

        -----------------------------------------------------------------------------------------------------------

        dataRateMode_sel <= HSX16_MODE & HSX16_MODE & HSX16_MODE & HSX16_MODE & HSX16_MODE & HSX16_MODE & HSX16_MODE; 
        dataSource_sel   <= B"00" & B"00" & B"00" & B"00" & B"00" & B"00" & B"00";
        prbsTypeMode_sel <= PRBS31_MODE & PRBS31_MODE & PRBS31_MODE & PRBS31_MODE & PRBS31_MODE & PRBS31_MODE & PRBS31_MODE;

        wait for 250 ns;
        prbs_check(serialOut(0),   500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(2),   500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(4),   500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(6),   500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(8),   500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(10),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(12),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(14),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(16),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(18),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(20),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(22),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(24),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(26),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  

        -------------------------------------------------------------------------------------------------------------

        dataRateMode_sel <= HSX8_MODE & HSX8_MODE & HSX8_MODE & HSX8_MODE & HSX8_MODE & HSX8_MODE & HSX8_MODE; 
        dataSource_sel   <= B"00" & B"00" & B"00" & B"00" & B"00" & B"00" & B"00";
        prbsTypeMode_sel <= PRBS31_MODE & PRBS31_MODE & PRBS31_MODE & PRBS31_MODE & PRBS31_MODE & PRBS31_MODE & PRBS31_MODE;

        wait for 250 ns;
        prbs_check(serialOut(0),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(1),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(2),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(3),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(4),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(5),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(6),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(7),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(8),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(9),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(10),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(11),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(12),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(13),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(14),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(15),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(16),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(17),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(18),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(19),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(20),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(21),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(22),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(23),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(24),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(25),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(26),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  
        prbs_check(serialOut(27),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  

        -----------------------------------------------------------------------------------------------------------

        dataRateMode_sel <= LSX4_MODE & LSX4_MODE & LSX4_MODE & LSX4_MODE & LSX4_MODE & LSX4_MODE & LSX4_MODE; 
        dataSource_sel   <= B"00" & B"00" & B"00" & B"00" & B"00" & B"00" & B"00";
        prbsTypeMode_sel <= PRBS7_MODE & PRBS7_MODE & PRBS7_MODE & PRBS7_MODE & PRBS7_MODE & PRBS7_MODE & PRBS7_MODE;

        wait for 250 ns;
        prbs_check(serialOut(7),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  

        -----------------------------------------------------------------------------------------------------------

        dataRateMode_sel <= LSX8_MODE & LSX8_MODE & LSX8_MODE & LSX8_MODE & LSX8_MODE & LSX8_MODE & LSX8_MODE; 
        dataSource_sel   <= B"00" & B"00" & B"00" & B"00" & B"00" & B"00" & B"00";
        prbsTypeMode_sel <= PRBS31_MODE & PRBS31_MODE & PRBS31_MODE & PRBS31_MODE & PRBS31_MODE & PRBS31_MODE & PRBS31_MODE;

        wait for 250 ns;
        prbs_check(serialOut(14),  500, dataRateMode_sel(2 downto 0), prbsTypeMode_sel(1 downto 0));  

        -- Simulation finished
        sim_running <= false;

    end process;
        
end architecture tb;




