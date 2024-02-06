--------------------------------------------------------------------------------------------------------------
--                                                                                                          --
--  Frequency counter                                                                                       --
--                                                                                                          --
--  Szymon Kulis, CERN, EP-ESE-ME, April 2019                                                               --
--                                                                                                          --
--------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- IP Bus infrastruture
use work.ipbus.all;
use work.ipbus_reg_types.all;
-- use work.clkmon_pkg.all;

entity ipbus_freqCounter is
    generic(
        ADDR_WIDTH: positive
    );
    port (
        -- IP Bus connections
        ipbus_in:   in  ipb_wbus;
        ipbus_out:  out ipb_rbus;

        -- Other connections
        clk320MHzIn   : in  std_logic;
        clkIPBus      : in  std_logic;
        reset         : in  std_logic;
        clkMon        : in  std_logic  -- clock to monitor
    );

end ipbus_freqCounter;

architecture rtl of ipbus_freqCounter is

    subtype REG_t is std_logic_vector (31 downto 0);
    type REG_FILE_t is array (0 to 1) of REG_t;

    signal reg_file  : REG_FILE_t;
    signal sel       : std_logic_vector (ADDR_WIDTH-1    downto 0) := (others => '0');
    signal ack       : std_logic;

    constant idle    : std_logic_vector(1 downto 0) := b"00";
    constant couting : std_logic_vector(1 downto 0) := b"01";
    constant done    : std_logic_vector(1 downto 0) := b"10";
    constant fault   : std_logic_vector(1 downto 0) := b"11";

   
    signal state                  : std_logic_vector(1 downto 0) := idle;
    signal state_next             : std_logic_vector(1 downto 0) := idle;
    signal state_ipbclk           : std_logic_vector(1 downto 0) := idle;
    
    signal meas_start             : std_logic := '0';
    signal meas_startF            : std_logic := '0';
    signal meas_startFF           : std_logic := '0';

    signal ctrl_reg_ipbclk        : std_logic_vector(31 downto 0);
    signal ctrl_reg_320mhz        : std_logic_vector(31 downto 0);
    signal ctrl_reg_320mhz_d      : std_logic_vector(31 downto 0);

    signal freq_counter           : unsigned(23 downto 0);
    signal freq_counter_next      : unsigned(23 downto 0);
    signal time_counter           : unsigned(23 downto 0);
    signal time_counter_next      : unsigned(23 downto 0);

    constant ctrl_meas_start_idx  : integer := 0;
    constant state_idx            : integer := 30;
    constant counter_idx          : integer := 0;
    
    signal clkMonF    : std_logic := '0';
    signal clkMonFF   : std_logic := '0';
    signal clkMonFFF  : std_logic := '0';

    signal resetF     : std_logic := '1';
    signal resetFF    : std_logic := '1';
begin

    -- Selects the address on where to write
    sel <= ipbus_in.ipb_addr(ADDR_WIDTH-1 downto 0);

    -- Reads/Writes to/from the IPBus bus to the registers
    process(clkIPBus)
    begin
        if rising_edge(clkIPBus) then
            -- control register writing
            ctrl_reg_ipbclk(ctrl_meas_start_idx) <= '0';  -- reset 'start measurement' flag
            if ipbus_in.ipb_strobe = '1' and ipbus_in.ipb_write='1' then
                meas_start <= ipbus_in.ipb_wdata(0); -- Write to control register regardless of address
            end if;

            -- bus reads
            ipbus_out.ipb_rdata <= reg_file(to_integer(unsigned(sel)));
            ack <= ipbus_in.ipb_strobe and not ack;    
        end if;
    end process;

    -- control register clock domain crossing
    meas_startF   <= meas_start when rising_edge(clk320MHzIn);
    meas_startFF  <= meas_startF when rising_edge(clk320MHzIn);

    meas_start <= ctrl_reg_320mhz_d(ctrl_meas_start_idx);

    ipbus_out.ipb_ack <= ack;
    ipbus_out.ipb_err <= '0';

    state_ipbclk <= state when rising_edge(clkIPBus);
    reg_file(1)(state_idx + 1 downto state_idx) <= state_ipbclk;
    reg_file(1)(23 downto 0) <= std_logic_vector(freq_counter);


   state_register: process
   begin
        wait until rising_edge(clk320MHzIn);
        state        <= state_next;
        clkMonF      <= clkMon;
        clkMonFF     <= clkMonF;
        clkMonFFF    <= clkMonFF; 
        time_counter <= time_counter_next;
        freq_counter <= freq_counter_next;
        resetF       <= reset;
        resetFF      <= resetF;
   end process;
   
   next_state_logic: process (meas_start, clkMonFF, clkMonFFF, state, time_counter, freq_counter, resetFF)
   begin
       state_next <= state; --default is to stay in current state
       time_counter_next <= time_counter;
       freq_counter_next <= freq_counter;
       case (state) is
           when idle =>
               time_counter_next <= to_unsigned(0, time_counter'length);
               freq_counter_next <= to_unsigned(0, freq_counter'length);
               if meas_startFF = '1' then
                   state_next <= couting;  
               end if;
           when couting =>
               time_counter_next <= time_counter + to_unsigned(1, time_counter'length);
               if clkMonFFF = '0' and clkMonFF = '1' then
                   freq_counter_next <= freq_counter + to_unsigned(1, freq_counter'length);
               end if;
               -- 320_000 clocks at 320 MHz is 1ms
               if time_counter = to_unsigned(320_000, time_counter'length) then
                   state_next <= done;
               end if;
           when done =>
               if meas_startFF = '0' then
                   state_next <= idle;  
               end if;
           when fault =>
               state_next <= idle;  
       end case;
       if resetFF = '1' then
           state_next <= idle;
           time_counter_next <= to_unsigned(0, time_counter'length);
           freq_counter_next <= to_unsigned(0, freq_counter'length);
       end if;
   end process;


end rtl;
