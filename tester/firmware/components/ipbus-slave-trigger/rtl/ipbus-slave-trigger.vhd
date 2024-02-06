library IEEE;
Library UNISIM;

use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.all;
use work.ipbus_reg_types.all;
use ieee.numeric_std.all;

use UNISIM.vcomponents.all;


entity ipbus_triggering  is
	generic(addr_width: natural := 0);
	port(
	    clk_ipbus: in std_logic;
		clk_sys: in std_logic; 
		rst: in std_logic;
        ipbus_in:   in  ipb_wbus;
        ipbus_out:  out ipb_rbus;
        reset:      buffer std_logic;
        hit_trigger:  out std_logic;
        trigger:      out std_logic

	);
	
end ipbus_triggering ;

architecture rtl of ipbus_triggering  is
    
component edge_detect is
  port (async_sig : in std_logic;
        clk       : in std_logic;
        rise      : out std_logic;
        fall      : out std_logic);
end component;

component enable_detect is
  port (async_sig : in std_logic;
        clk       : in std_logic;
        rise      : out std_logic);
end component;

component enable_detect_12 is
  port (async_sig_12 : in std_logic_vector (11 downto 0);
        clk_12       : in std_logic;
        rise_12      : out std_logic_vector (11 downto 0)
	);
end component;

component counter is 
  port(C, CLR, EN, START, CIRC, EXTERNAL  : in  std_logic;  
       TRIGGER,HIT        : out  std_logic;
       RESET                          : buffer std_logic;
       TRIGGER_IN,HIT_IN,CNT_IN : in std_logic_vector(11 downto 0)
    );  
end component; 

signal clock_out        : std_logic; 
signal enable           : std_logic; 
signal fall_start       : std_logic; 
signal rise_start       : std_logic;
signal fall_clear       : std_logic; 
signal rise_clear       : std_logic;
signal ip_clear         : std_logic; 
signal ip_enable        : std_logic; 
signal ip_start         : std_logic; 
signal ip_circular      : std_logic; 
signal fall_circular    : std_logic; 
signal rise_circular    : std_logic; 
signal ack              : std_logic;
signal ip_hits          : std_logic_vector (11 downto 0);
signal rise_hits        : std_logic_vector (11 downto 0);
signal ip_trigger       : std_logic_vector (11 downto 0);
signal rise_trigger     : std_logic_vector (11 downto 0);
signal ip_cnt           : std_logic_vector (11 downto 0);
signal rise_cnt         : std_logic_vector (11 downto 0);
signal rise_external    : std_logic;
signal ip_external      : std_logic; 

signal hit_trigger_tmp  : std_logic; 
signal stb : std_logic;
signal sel: integer range 0 to ((2**ADDR_WIDTH) - 1) := 0;
signal CE   : std_logic := '1';
 
 
signal CNTVALUEOUT      : std_logic_vector (4 downto 0);
signal CEN              : std_logic := '0';
signal CINVCTRL         : std_logic := '0';
signal CNTVALUEIN       : std_logic_vector (4 downto 0);
signal INC              : std_logic := '0';
signal LD               : std_logic := '0';
signal LDPIPEEN         : std_logic := '0';
signal REGRST           : std_logic := '0';

attribute IODELAY_GROUP : STRING;
--attribute IODELAY_GROUP of <label_name>: label is "<iodelay_group_name>";
    
begin 

BUFR_inst : BUFR
   generic map (
      BUFR_DIVIDE => "1",   -- Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8" 
      SIM_DEVICE => "7SERIES"  -- Must be set to "7SERIES" 
   )
   port map (
      O => clock_out,     -- 1-bit output: Clock output port
      CE => CE,   -- 1-bit input: Active high, clock enable (Divided modes only)
      CLR => rst, -- 1-bit input: Active high, asynchronous clear (Divided modes only)
      I => clk_sys      -- 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
   );			
				
				
syncronizer_enable: enable_detect
    port map (
        async_sig => ip_enable,
        clk => clock_out,
        rise => enable
        );

syncronizer_start: edge_detect
    port map (
        async_sig => ip_start,
        clk => clock_out,
        rise => rise_start,
        fall => fall_start        
        );

syncronizer_circular: enable_detect
    port map (
        async_sig => ip_circular,
        clk => clock_out,
        rise => rise_circular     
        );
        
syncronizer_external: enable_detect
            port map (
                async_sig => ip_external,
                clk => clock_out,
                rise => rise_external  
                );        
	
syncronizer_hit: enable_detect_12
    port map(
        async_sig_12 => ip_hits,
        clk_12 => clock_out,
        rise_12 => rise_hits 
    );
  
  
syncronizer_trigger: enable_detect_12
        port map(
            async_sig_12 => ip_trigger,
            clk_12 => clock_out,
            rise_12 => rise_trigger 
        );
        
syncronizer_cnt: enable_detect_12
                port map(
                    async_sig_12 => ip_cnt,
                    clk_12 => clock_out,
                    rise_12 => rise_cnt
                );
                        
syncronizer_clear: edge_detect
            port map (
                async_sig => ip_clear,
                clk => clock_out,
                rise => rise_clear,
                fall => fall_clear        
                );
                
counter_trigger : counter
        port map(
           C => clock_out,
           CLR => rise_clear,
           EN => enable,
           START => rise_start,
           CIRC => rise_circular,
           TRIGGER => trigger,
           HIT => hit_trigger_tmp,
           TRIGGER_IN => rise_trigger,
           HIT_IN => rise_hits,
           CNT_IN => rise_cnt,
           RESET => reset, 
           EXTERNAL => rise_external
        );
    
    process(clk_ipbus)
        begin
            if rising_edge(clk_ipbus) then
                if ipbus_in.ipb_strobe='1' and ipbus_in.ipb_write='1' then
                    case ipbus_in.ipb_addr(3 downto 0) is
                        when x"0"   => 
                        ip_enable <= ipbus_in.ipb_wdata(0);
                        when x"1"   =>
                        ip_clear <= ipbus_in.ipb_wdata(0);
                        when x"2"   =>
                        ip_start <= ipbus_in.ipb_wdata(0);
                        when x"3"   =>
                        ip_circular <= ipbus_in.ipb_wdata(0);
                        when x"4"   =>
                        ip_hits <= ipbus_in.ipb_wdata(11 downto 0);
                        when x"5"   =>
                        ip_trigger <= ipbus_in.ipb_wdata(11 downto 0);
                        when x"6"   =>
                        ip_cnt <= ipbus_in.ipb_wdata(11 downto 0);
                        when x"7"   =>
                        ip_external <= ipbus_in.ipb_wdata(0);
                        
                        when others => 
                    end case;
                end if;
                ack <= ipbus_in.ipb_strobe and not ack;    
            end if;
        end process;
        
    ipbus_out.ipb_ack <= ack;
    ipbus_out.ipb_err <= '0';    
    
    

       
       ODELAYE2_inst : ODELAYE2
       generic map (
          CINVCTRL_SEL => "FALSE",          -- Enable dynamic clock inversion (FALSE, TRUE)
          DELAY_SRC => "ODATAIN",           -- Delay input (ODATAIN, CLKIN)
          HIGH_PERFORMANCE_MODE => "TRUE",  -- Reduced jitter ("TRUE"), Reduced power ("FALSE")
          ODELAY_TYPE => "FIXED",           -- FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
          ODELAY_VALUE => 0,                -- Output delay tap setting (0-31)
          PIPE_SEL => "FALSE",              -- Select pipelined mode, FALSE, TRUE
          REFCLK_FREQUENCY => 200.0,        -- IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
          SIGNAL_PATTERN => "DATA"          -- DATA, CLOCK input signal
       )
       port map (
          CNTVALUEOUT => CNTVALUEOUT, -- 5-bit output: Counter value output
          DATAOUT => hit_trigger,         -- 1-bit output: Delayed data/clock output
          C => clk_ipbus,                     -- 1-bit input: Clock input
          CE => CEN,                   -- 1-bit input: Active high enable increment/decrement input
          CINVCTRL => CINVCTRL,       -- 1-bit input: Dynamic clock inversion input
          CLKIN => clk_sys,             -- 1-bit input: Clock delay input
          CNTVALUEIN => CNTVALUEIN,   -- 5-bit input: Counter value input
          INC => INC,                 -- 1-bit input: Increment / Decrement tap delay input
          LD => LD,                   -- 1-bit input: Loads ODELAY_VALUE tap delay in VARIABLE mode, in VAR_LOAD or
                                      -- VAR_LOAD_PIPE mode, loads the value of CNTVALUEIN
    
          LDPIPEEN => LDPIPEEN,       -- 1-bit input: Enables the pipeline register to load data
          ODATAIN => hit_trigger_tmp,         -- 1-bit input: Output delay data input
          REGRST => REGRST            -- 1-bit input: Active-high reset tap-delay input
       );
    
    
end rtl;

 
