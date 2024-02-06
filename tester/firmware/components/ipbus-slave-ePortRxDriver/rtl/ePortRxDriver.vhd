--------------------------------------------------------------------------------------------------------------
--                                                                                                          --
--                                                                                                          --
--  Module that drives the ePortRx. Accepts clocks of 40, 160 and 640MHz, and outputs 28 streams up to 1G28 --
--                                                                                                          --
--  Jose Pedro Castro Fonseca, CERN, EP-ESE-ME, August 2018                                                 --
--                                                                                                          --
--                                                                                                          --
--------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- For simulation of Xilinx model of OSERDESE2
library UNISIM;
use UNISIM.vcomponents.all;

entity ePortRxDriver is
    generic (
        MAX_NUM_USER_PACKET : integer := 16
    );
    port (
        signal userData      : in  std_logic_vector (MAX_NUM_USER_PACKET*32*7-1 downto 0);
        signal dataRateMode  : in  std_logic_vector (20 downto 0);  -- {5G_or_10G<0>, dataRate<1:0>}, for each group (3bits X 7 groups = 21 bits)
        signal dataSource    : in  std_logic_vector (13 downto 0);  -- from 0 to 3 {PRBS, RNG, CONST_PATT, USERDATA} (2bits X 7 groups = 14 bits)
        signal prbsTypeMode  : in  std_logic_vector (13 downto 0);  -- from o to 3 {7,15,23,31} (2 X 7 groups = 14 bits}
        signal outputDelay   : in  std_logic_vector (139 downto 0); -- (28 channels * 5 bits = 140 bits)
        signal sameSeed      : in  std_logic_vector (6 downto 0);   -- Decide if channels of the same given group use the same initializaiton seed
        signal prbsSeed      : in  std_logic_vector (223 downto 0); -- 32bits * 7 groups.
        signal clk40MHzIn    : in  std_logic;
        --signal reset         : in  std_logic;
        signal pllLock       : out std_logic;
        signal dllLock       : out std_logic;
        signal channel       : out std_logic_vector (27 downto 0)  -- Serial outputs for each channel
    );
end ePortRxDriver;

architecture rtl of ePortRxDriver is

    -- Data group generator signals
    type GROUP_DATA_BUS is array (0 to 6) of std_logic_vector(31 downto 0);
    signal groupData : GROUP_DATA_BUS;
    
    -- Fanout signals
    type FANOUT_BUS is array (0 to 6, 0 to 3, 0 to 3) of std_logic_vector(7 downto 0);
    signal fanoutBus : FANOUT_BUS;

    --  Mux signals
    signal muxSel : std_logic_vector(1 downto 0);
    type CHANNEL_SER_BUS is array (0 to 6, 0 to 3) of std_logic_vector(7 downto 0);
    signal toChannelSerializer       : CHANNEL_SER_BUS; 
    signal toChannelSerializer_sync1 : CHANNEL_SER_BUS; 
    signal toChannelSerializer_sync2 : CHANNEL_SER_BUS; 

    -- Other internal signals
    signal clkSynthLock      : std_logic;
    signal delayLineLock     : std_logic;
    signal channel_noDelay   : std_logic_vector (27 downto 0); -- Serial outputs for each channel, without any delay
    signal delayLoad         : std_logic_vector (2 downto 0);
    signal outputDelayLast   : std_logic_vector (139 downto 0); -- (28 channels * 5 bits = 140 bits)
    signal reset             : std_logic;
    signal reset_serdes      : std_logic;
    signal state             : std_logic_vector (1 downto 0) := "00";
    signal state_next        : std_logic_vector (1 downto 0) := "00";
    signal counter           : std_logic_vector (3 downto 0) := "0000";
    signal counter_next      : std_logic_vector (3 downto 0) := "0000";

    -- Clock signals
    signal clk160MHz         : std_logic;
    signal clk160MHz_toBuf   : std_logic;
    signal clk40MHz          : std_logic;
    signal clk40MHz_toBuf    : std_logic;
    signal clk640MHz         : std_logic;
    signal clk640MHz_toBuf   : std_logic;
    signal clk40MHz_fromBuf  : std_logic;
    signal clk40MHz_toBufG   : std_logic;
    signal clkMMCMfb_toBuf   : std_logic;
    signal clkMMCMfb_fromBuf : std_logic;
    signal clk300MHz         : std_logic;
    signal clk300MHz_toBuf   : std_logic;

    begin

        pllLock <= clkSynthLock;
        dllLock <= delayLineLock;
        
        -- The mixed-mode clock synthezier tile, MMCM_BASE Xilinx primitive, with external feedback for increased performance
        MMCME2_BASE_i : MMCME2_BASE
            generic map (
                BANDWIDTH       => "OPTIMIZED",
                CLKFBOUT_MULT_F => 32.000,        -- The input clock is multiplied by this factor
                CLKFBOUT_PHASE  => 0.000,
                CLKIN1_PERIOD   => 25.0,        -- The input clock is 40MHz, hence has a period of 25ns

                CLKOUT0_DIVIDE_F => 4.25,        -- 300MHz output clock for ODELAYE2. (Actually 301.176 MHz)
                CLKOUT1_DIVIDE   => 2,           -- 640MHz output clock, 1.28G/2
                CLKOUT2_DIVIDE   => 8,           -- 60MHz output clock, 1.28G/8
                CLKOUT3_DIVIDE   => 32,          -- 40MHz output clock, 1.28G/32 
                CLKOUT4_DIVIDE   => 1,           -- NOT USED
                CLKOUT5_DIVIDE   => 1,           -- NOT USED
                CLKOUT6_DIVIDE   => 1,           -- NOT USED

                CLKOUT0_DUTY_CYCLE => 0.5,       -- All duty-cycles set to 50%
                CLKOUT1_DUTY_CYCLE => 0.5,        
                CLKOUT2_DUTY_CYCLE => 0.5,        
                CLKOUT3_DUTY_CYCLE => 0.5,        
                CLKOUT4_DUTY_CYCLE => 0.5,        
                CLKOUT5_DUTY_CYCLE => 0.5,        
                CLKOUT6_DUTY_CYCLE => 0.5,        

                CLKOUT0_PHASE => 0.0,        -- All duty-cycles set to 50%
                CLKOUT1_PHASE => 0.0,        
                CLKOUT2_PHASE => 0.0,        
                CLKOUT3_PHASE => 0.0,        
                CLKOUT4_PHASE => 0.0,        
                CLKOUT5_PHASE => 0.0,        
                CLKOUT6_PHASE => 0.0,        

                CLKOUT4_CASCADE => FALSE,
                DIVCLK_DIVIDE   => 1,
                REF_JITTER1     => 0.000,
                STARTUP_WAIT    => TRUE
            )
            port map (
                CLKIN1   => clk40MHz_fromBuf,
                PWRDWN   => '0',
                RST      => '0',
                CLKFBIN  => clkMMCMfb_fromBuf,

                CLKOUT0  => clk300MHz_toBuf,
                CLKOUT0B => open,
                CLKOUT1  => clk640MHz_toBuf,
                CLKOUT1B => open,
                CLKOUT2  => clk160MHz_toBuf,
                CLKOUT2B => open,
                CLKOUT3  => clk40MHz_toBuf,
                CLKOUT3B => open,
                CLKOUT4  => open,
                CLKOUT5  => open,
                CLKOUT6  => open,
                LOCKED   => clkSynthLock,
                CLKFBOUTB => open,
                CLKFBOUT  => clkMMCMfb_toBuf
            );

        -- The clocks buffers
        IBUFG_40MHz : IBUF
            generic map (
                IBUF_LOW_PWR => FALSE,
                IOSTANDARD   => "DEFAULT"
            )
            port map (
                I => clk40MHzIn,
                O => clk40MHz_toBufG
            );

        BUFG_40MHzIn : BUFG
            port map (
                I => clk40MHz_toBufG,
                O => clk40MHz_fromBuf
            );

        BUFG_640MHz : BUFG
            port map (
                I => clk640MHz_toBuf,
                O => clk640MHz
            );

        BUFG_300MHz : BUFG
            port map (
                I => clk300MHz_toBuf,
                O => clk300MHz
            );

        BUFG_160MHz : BUFG
            port map (
                I => clk160MHz_toBuf,
                O => clk160MHz
            );
        BUFG_40MHzO : BUFG
            port map (
                I => clk40MHz_toBuf,
                O => clk40MHz
            );
        BUFG_FB : BUFG
            port map (
                I => clkMMCMfb_toBuf,
                O => clkMMCMfb_fromBuf
            );

        -- The per-group data generators
        dataGroupGenerators : for I in 0 to 6 generate
            dataGroupGen_I : entity work.dataGroupGen(rtl) 
            generic map (
                MAX_NUM_USER_PACKET => 16
            )
            
            port map (
                userData     => userData((I+1)*512-1 downto I*512), 
                dataRateMode => dataRateMode((I+1)*3-1 downto I*3),
                dataSource   => dataSource((I+1)*2-1 downto I*2),
                prbsTypeMode => prbsTypeMode((I+1)*2-1 downto I*2),
                clk40MHz     => clk40MHz,
                sameSeed     => sameSeed(I),
                prbsSeed     => prbsSeed((I+1)*32-1 downto I*32),
                reset        => reset,
                dataOut      => groupData(I)
            );
        end generate dataGroupGenerators;

        -- Splitting group data into channels, and performing fanout to 8-bit parallel, suitable to the OSERDESE2
        fanoutGenerators: for I in 0 to 6 generate
            x8FanoutChanSplit_I : entity work.x8FanoutChanSplit(rtl) port map (
                dataGroup    => groupData(I),
                dataRateMode => dataRateMode((I+1)*3-1 downto I*3),
                chan0_part0  => fanoutBus(I,0,0)(7 downto 0),
                chan0_part1  => fanoutBus(I,0,1)(7 downto 0),
                chan0_part2  => fanoutBus(I,0,2)(7 downto 0),
                chan0_part3  => fanoutBus(I,0,3)(7 downto 0),
                chan1_part0  => fanoutBus(I,1,0)(7 downto 0),
                chan1_part1  => fanoutBus(I,1,1)(7 downto 0),
                chan1_part2  => fanoutBus(I,1,2)(7 downto 0),
                chan1_part3  => fanoutBus(I,1,3)(7 downto 0),
                chan2_part0  => fanoutBus(I,2,0)(7 downto 0),
                chan2_part1  => fanoutBus(I,2,1)(7 downto 0),
                chan2_part2  => fanoutBus(I,2,2)(7 downto 0),
                chan2_part3  => fanoutBus(I,2,3)(7 downto 0),
                chan3_part0  => fanoutBus(I,3,0)(7 downto 0),
                chan3_part1  => fanoutBus(I,3,1)(7 downto 0),
                chan3_part2  => fanoutBus(I,3,2)(7 downto 0),
                chan3_part3  => fanoutBus(I,3,3)(7 downto 0)
            );
        end generate fanoutGenerators;


        -- This mux, run by a 2-bit counter, time multiplexes @160MHz the incoming parallel data @40MHz
        -- TODO vectorize
        process(clk160MHz)
        begin
            if rising_edge(clk160MHz) then
                if(reset_serdes = '1') then
                    muxSel <= B"00"; -- To sync with 40m(others => '0');
                else
                    muxSel <= muxSel + '1';
                end if;
            end if; 
        end process;

        muxGen_G: for GR in 0 to 6 generate
            muxGen_C: for CH in 0 to 3 generate
            with muxSel select
                toChannelSerializer(GR,CH) <= fanoutBus(GR,CH,0)(7 downto 0) when B"11",
                                              fanoutBus(GR,CH,1)(7 downto 0) when B"10",
                                              fanoutBus(GR,CH,2)(7 downto 0) when B"01",
                                              fanoutBus(GR,CH,3)(7 downto 0) when B"00",
                                              X"00"                when others;
            end generate muxGen_C;
        end generate muxGen_G;

        -- Adds a half-clock cycle delay to the parallel data
        delay_G: for GR in 0 to 6 generate
            delay_C: for CH in 0 to 3 generate
            process(clk160MHz)
            begin
                if rising_edge(clk160MHz) then
                    toChannelSerializer_sync1(GR,CH) <= toChannelSerializer(GR,CH);
                end if;                        
            end process;
            end generate delay_C;
        end generate delay_G;

        -- Adds a half-clock cycle delay to the parallel data
        delay1_G: for GR in 0 to 6 generate
            delay1_C: for CH in 0 to 3 generate
            process(clk160MHz)
            begin
                if falling_edge(clk160MHz) then
                    toChannelSerializer_sync2(GR,CH) <= toChannelSerializer_sync1(GR,CH);
                end if;                        
            end process;
            end generate delay1_C;
        end generate delay1_G;

        -- Instantiating the Xilinx OSERDESE2 primitive, used to deserialize the data
        serGen_G : for GR in 0 to 6 generate
            serGen_C : for CH in 0 to 3 generate
                OSERDESE2_CH : OSERDESE2 
                    generic map (
                        DATA_RATE_OQ => "DDR",
                        DATA_RATE_TQ => "DDR",
                        DATA_WIDTH   => 8,
                        INIT_OQ      => '0',
                        INIT_TQ      => '0',
                        SERDES_MODE  => "MASTER",
                        SRVAL_OQ     => '0',
                        SRVAL_TQ     => '0',
                        TBYTE_CTL    => "FALSE",
                        TBYTE_SRC    => "FALSE",
                        TRISTATE_WIDTH => 1 
                    )
                    port map (
                        TQ  => open,
                        TFB => open,
                        TCE => '0',
                        TBYTEIN  => '0',
                        TBYTEOUT => open,
                        T1        => '0',  
                        T2        => '0',  
                        T3        => '0',  
                        T4        => '0',  
                        OFB => open,
                        SHIFTOUT1 => open,
                        SHIFTOUT2 => open,
                        SHIFTIN1  => '0',
                        SHIFTIN2  => '0',
                        OQ  => channel_noDelay(GR*4+CH),
                        CLK => clk640MHz,
                        CLKDIV => clk160MHz,
                        OCE => '1',
                        RST => reset_serdes,
                        D1 => toChannelSerializer_sync2(GR,CH)(7), 
                        D2 => toChannelSerializer_sync2(GR,CH)(6), 
                        D3 => toChannelSerializer_sync2(GR,CH)(5), 
                        D4 => toChannelSerializer_sync2(GR,CH)(4), 
                        D5 => toChannelSerializer_sync2(GR,CH)(3), 
                        D6 => toChannelSerializer_sync2(GR,CH)(2), 
                        D7 => toChannelSerializer_sync2(GR,CH)(1), 
                        D8 => toChannelSerializer_sync2(GR,CH)(0) 
                    );
            end generate serGen_C;
        end generate serGen_G;

        -- Logic for generating an asynchronous deassertion of the SERDES reset signal
        process(clk40MHz)
        begin
            if rising_edge(clk40MHz) then
                state   <= state_next;
                counter <= counter_next;
            end if;
        end process;

        process(state, counter, clkSynthLock)
        begin
            case state is
                when B"00" =>
                    reset <= '0';
                    if clkSynthLock = '1' then
                        state_next <= B"01";
                        counter_next <= counter + "1";
                    else
                        state_next <= B"00";
                        counter_next <= B"0000";
                    end if;
                when B"01" =>
                    reset <= '1';
                    if counter = B"11" then
                        state_next   <= B"10";
                        counter_next <= "0000";
                    else
                        state_next   <= B"01";
                        counter_next <= counter + "1";
                    end if;
                when B"10" =>
                    reset <= '0';
                    state_next <= B"10";
                    counter_next <= B"0000";
                when others =>
                    reset <= '0';
                    state_next <= B"00";
                    counter_next <= B"0000";
            end case;
        end process;

        process(clk160MHz)
        begin
            if falling_edge(clk160MHz) then
                reset_serdes <= reset;
            end if;
        end process;

        -- Instantiating the Xilinx ODELAYE2 primitive, used to add a programmable delay to the serial ouputs
        delayGen_C : for CH in 0 to 27 generate
            ODELAYE2_CH : ODELAYE2
                generic map (
                    ODELAY_TYPE  => "VAR_LOAD",
                    ODELAY_VALUE => 2,
                    HIGH_PERFORMANCE_MODE => "TRUE",
                    SIGNAL_PATTERN        => "DATA",
                    REFCLK_FREQUENCY      => 301.176,  -- 300MHz reference clock yields around 45ps of tap delay
                    CINVCTRL_SEL          => "FALSE",
                    PIPE_SEL              => "FALSE",
                    DELAY_SRC             => "ODATAIN"
                )
                port map (
                    C           => clk300MHz,
                    LD          => delayLoad(2),
                    ODATAIN     => channel_noDelay(CH),
                    REGRST      => '0',
                    CE          => '0',
                    INC         => '0',
                    CINVCTRL    => '0',
                    CLKIN       => '0',
                    LDPIPEEN    => '0',
                    DATAOUT     => channel(CH),
                    CNTVALUEIN  => outputDelayLast((CH+1)*5-1 downto CH*5),
                    CNTVALUEOUT => open
                );
        end generate delayGen_C;

        -- The logic to generate the loading signal for the delay tap values
        process(clk40MHz)
        begin
            if rising_edge(clk40MHz) then
                outputDelayLast <= outputDelay;
            end if;
        end process;
        
        delayLoad(0) <= '1' when (outputDelayLast /= outputDelay) else '0';
        
        process(clk40MHz)
        begin
            if rising_edge(clk40MHz) then
                delayLoad(2 downto 1) <= delayLoad(1 downto 0);
            end if;
        end process;


        -- IDELAYCTRL Xilinx primitive, to continuously calibrate the ODELAYE2 primitive
        IDELAYCTRL_INST : IDELAYCTRL
            port map (
                RST    => '0',
                REFCLK => clk300MHz,
                RDY    => delayLineLock
            );

end rtl;
