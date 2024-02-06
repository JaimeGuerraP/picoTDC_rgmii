library ieee;
Library UNISIM;

use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use UNISIM.vcomponents.all;
entity counter_tb is end;

use work.ipbus.all;
use work.ipbus_reg_types.all;

architecture test of counter_tb is
  signal C, CLR, EN, START, TRIGGER, HIT	: std_logic := '0';
  signal TRIGGER_IN  : std_logic_vector(11 downto 0) := "000000001000";
  signal HIT_IN  : std_logic_vector(11 downto 0) := "000000000010";
  signal CNT_IN  : std_logic_vector(11 downto 0) := "000000010000";
  signal CIRC : std_logic := '1';
  signal EXTERNAL : std_logic := '0';
  
  signal CNTVALUEOUT        : std_logic_vector (4 downto 0);
  signal CEN                : std_logic := '0';
  signal CINVCTRL           : std_logic := '0';
  signal CNTVALUEIN         : std_logic_vector (4 downto 0);
  signal INC                : std_logic := '0';
  signal LD                 : std_logic := '0';
  signal LDPIPEEN           : std_logic := '0';
  signal REGRST             : std_logic := '0';
  signal HIT_FINAL          : std_logic := '0';
  signal clk_ipbus          : std_logic := '0';
begin

  UUT : entity work.counter
       port map (C => C,
                 CLR => CLR,
                 EN => EN,
                 CIRC => CIRC,
                 TRIGGER => TRIGGER,
                 HIT => HIT,
                 TRIGGER_IN => TRIGGER_IN,
                 HIT_IN => HIT_IN,
                 START => START,
                 CNT_IN => CNT_IN,
                 EXTERNAL => EXTERNAL);


   UUT2 :  ODELAYE2
       generic map (
          CINVCTRL_SEL => "FALSE",          -- Enable dynamic clock inversion (FALSE, TRUE)
          DELAY_SRC => "ODATAIN",           -- Delay input (ODATAIN, CLKIN)
          HIGH_PERFORMANCE_MODE => "TRUE",  -- Reduced jitter ("TRUE"), Reduced power ("FALSE")
          ODELAY_TYPE => "FIXED",           -- FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
          ODELAY_VALUE => 16,                -- Output delay tap setting (0-31)
          PIPE_SEL => "FALSE",              -- Select pipelined mode, FALSE, TRUE
          REFCLK_FREQUENCY => 200.0,        -- IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
          SIGNAL_PATTERN => "DATA"          -- DATA, CLOCK input signal
       )
       port map (
          CNTVALUEOUT => CNTVALUEOUT, -- 5-bit output: Counter value output
          DATAOUT => HIT_FINAL,         -- 1-bit output: Delayed data/clock output
          C => clk_ipbus,                     -- 1-bit input: Clock input
          CE => CEN,                   -- 1-bit input: Active high enable increment/decrement input
          CINVCTRL => CINVCTRL,       -- 1-bit input: Dynamic clock inversion input
          CLKIN => C,             -- 1-bit input: Clock delay input
          CNTVALUEIN => CNTVALUEIN,   -- 5-bit input: Counter value input
          INC => INC,                 -- 1-bit input: Increment / Decrement tap delay input
          LD => LD,                   -- 1-bit input: Loads ODELAY_VALUE tap delay in VARIABLE mode, in VAR_LOAD or
                                      -- VAR_LOAD_PIPE mode, loads the value of CNTVALUEIN
    
          LDPIPEEN => LDPIPEEN,       -- 1-bit input: Enables the pipeline register to load data
          ODATAIN => TRIGGER,         -- 1-bit input: Output delay data input
          REGRST => REGRST            -- 1-bit input: Active-high reset tap-delay input
       );
       
 
 
clk_gen_ipbus : process begin
         while now < 25 ms loop
           clk_ipbus <= not clk_ipbus;
           wait for 6 ns;
         end loop;
         wait;
       end process;
             
       
clk_gen : process begin
  while now < 25 ms loop
    C <= not C;
    wait for 12.5 ns;
  end loop;
  wait;
end process;

reset : process begin
  wait for 20 ns;
  CLR <= '1';
  wait for 50 ns;
  CLR <= '0';
--  wait for 900 ns;
--  CLR <= '1';
--  wait for 50 ns;
--  CLR <= '0';
  wait;
end process;


enable : process begin
  wait for 60 ns;
  EN <= '1';
--  wait for 4900 ns;
--  EN <= '0';
  wait;
end process;

starting : process begin
  wait for 80 ns;
  START <= '1';
  wait for 120 ns;
  START <= '0';
  wait for 1000 ns;
  START <= '1';
  wait for 120 ns;
  START <= '0';
  wait;
end process;

external_trigger : process begin
  wait for 5 us;
  EXTERNAL <= '0';
  wait;
end process;


-- Produce a randomly-changing async signal.
--stim : process
--  variable seed1, seed2 : POSITIVE;
--  variable Rand : REAL;
--  variable IRand : INTEGER;
--begin
--  while now < 1000 ns loop
--    wait until FALLING_EDGE(Clk);
--    -- make a random real between 0 and 1
--    uniform(seed1, seed2, rand);
--    -- turn it into a random integer between 50 and 150
--    irand := integer((rand * 100.0  - 0.5) + 50.0 );
--    -- wait for that many ns
--    wait for irand * 1 ns;
--    async <= not async;
--  end loop;
--  wait;
--end process;

end architecture;

