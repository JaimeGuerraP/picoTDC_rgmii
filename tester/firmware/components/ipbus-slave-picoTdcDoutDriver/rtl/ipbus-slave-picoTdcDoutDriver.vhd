library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.all;
use work.ipbus_reg_types.all;
use ieee.numeric_std.all;

entity ipbus_picoTdcDout is
	generic(addr_width: natural := 0);
	port(
		clk_ipbus: in std_logic;
		clk_sys: in std_logic; 
		rst: in std_logic;
        ipbus_in:   in  ipb_wbus;
        ipbus_out:  out ipb_rbus;
		data_in: in std_logic_vector(7 downto 0)
	);
	
end ipbus_picoTdcDout;

architecture rtl of ipbus_picoTdcDout is

COMPONENT fifo_generator_0
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    rd_data_count : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
    wr_rst_busy : OUT STD_LOGIC;
    rd_rst_busy : OUT STD_LOGIC
  );
END COMPONENT;

	signal stb, ack, wr_en, rd_en, full, empty, wr_rst_busy, rd_rst_busy, rst_from_ipbus,rst2 : std_logic; 
	signal rst_syn1, rst_syn2 : std_logic := '1';
	signal din, dout : std_logic_vector(31 downto 0);
	signal data_count : std_logic_vector(17 downto 0);
	signal data_in1, data_in2 : std_logic_vector(7 downto 0);
	signal data_in_temp : std_logic_vector(15 downto 0);
	signal data_in_full : std_logic_vector(31 downto 0);	

    constant IDLE : std_logic_vector(7 downto 0):= "11010000";
    
          
    type t_state is (A,B,C,D,E);
    signal state, state_next: t_state;   
	

begin

	
	fifo: fifo_generator_0 port map(
        rst => rst2,
        wr_clk => clk_sys,
        rd_clk => clk_ipbus,
        din => din,
        wr_en => wr_en,
        rd_en => rd_en, 
        dout => dout,
        full => full,
        empty => empty,
        rd_data_count => data_count,
        wr_rst_busy => wr_rst_busy,
        rd_rst_busy => rd_rst_busy 
      );
      

	stb <= ipbus_in.ipb_strobe and not ack;
    ipbus_out.ipb_ack <= ack;
	ipbus_out.ipb_err <= '0';
	din <= data_in_full;
	
	-- Combination of reset ipbus and reset hw
	rst2 <= rst or  rst_from_ipbus;
	
	-- FIFO output to picoTDC
	process(clk_ipbus)
    begin
      if rising_edge(clk_ipbus) then
        ipbus_out.ipb_rdata <= x"00000000";
        ack <= '0';
        rd_en <= '0';
        rst_from_ipbus <= '0';
        
        if ipbus_in.ipb_strobe='1' and ipbus_in.ipb_write='1' then 
            case ipbus_in.ipb_addr(3 downto 0) is
                  when x"2"   =>
                    rst_from_ipbus <= ipbus_in.ipb_wdata(0);
                  when others => 
             end case;
             ack <= ipbus_in.ipb_strobe and not ack;
        end if;
        
              
        case ipbus_in.ipb_addr(3 downto 0) is
          when x"1"   => 
              ipbus_out.ipb_rdata(17 downto 0) <= data_count;
              ipbus_out.ipb_rdata(30) <= empty;
              ipbus_out.ipb_rdata(31) <= rd_rst_busy;
              ack <= stb;
          when x"3"   => 
              ipbus_out.ipb_rdata <= dout;
              ack <= (not empty) and stb;
              rd_en <= (not empty) and stb;  
          when others => 
        end case;
      end if;
    end process;
      
      
    -- FIFO input from picoTDC
	process(clk_sys)
    begin
      if falling_edge(clk_sys) then
          rst_syn1 <= rst;
          rst_syn2 <= rst_syn1;
      end if;
    end process;      

	process(clk_sys, rst_syn2)
    begin
      if rst_syn2 = '1' then
          data_in1 <= IDLE;
          data_in_temp <= IDLE & IDLE;
          data_in_full <= IDLE & IDLE & IDLE & IDLE;
      elsif rising_edge(clk_sys) then
          data_in1 <= data_in;
          data_in_temp <= data_in1 & data_in2;
          data_in_full <= data_in_temp & data_in1 & data_in2;
      end if;
    end process;

	process(clk_sys, rst_syn2)
    begin
      if rst_syn2 = '1' then
          data_in2 <= IDLE;
      elsif falling_edge(clk_sys) then
          data_in2 <= data_in;
      end if;
    end process;
      
      
      FSM_update : process (clk_sys, rst_syn2)
      begin 
          if rst_syn2 = '1' then 
              state <= A;
          elsif rising_edge(clk_sys) then 
              state <= state_next;
          end if;
      end process;
      
      
      data_update: process(data_in_full, state)
      
      begin
      
        wr_en <= '0';
        case state is 
            when A => -- IDLE/0
                if data_in_full(31 downto 24) = IDLE then -- Got again IDLE value : no change
                   state_next <= A;
                   
                else --DATA/0 -- Got some data
                    state_next <= B;
                    wr_en <= '1';
                end if;
            when B => -- IDLE/1 
                state_next <= A;
            when others =>
                state_next <= A;
        end case;
      
      end process;
	

end rtl;
