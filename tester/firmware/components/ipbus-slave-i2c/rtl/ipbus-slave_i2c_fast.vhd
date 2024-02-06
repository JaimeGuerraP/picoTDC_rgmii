library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.all;
use work.ipbus_reg_types.all;
use ieee.numeric_std.all;

entity ipbus_i2c_fast is
	generic(addr_width: natural := 0);
	port(
		clk: in std_logic;
		rst: in std_logic; 
        ipbus_in:   in  ipb_wbus;
        ipbus_out:  out ipb_rbus;
		scl: inout std_logic;
        sda: inout std_logic
	);
	
end ipbus_i2c_fast;

architecture rtl of ipbus_i2c_fast is


COMPONENT i2c_master
  GENERIC(
    input_clk : INTEGER := 50_000_000; --input clock speed from user logic in Hz
    bus_clk   : INTEGER := 400_000);   --speed the i2c bus (scl) will run at in Hz
  PORT(
    clk       : IN     STD_LOGIC;                    --system clock
    reset_n   : IN     STD_LOGIC;                    --active low reset
    ena       : IN     STD_LOGIC;                    --latch in command
    addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
    rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
    data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
    busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
    data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
    ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : INOUT  STD_LOGIC);                   --serial clock output of i2c bus
END COMPONENT;

	signal ack, ena, rw, busy, ack_error, new_data, last_busy : std_logic;
	signal data_wr, data_rd : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal data : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal rst_syn1, rst_syn2 : std_logic := '1';

    
          
    type t_state is (IDLE, B1, B2, B3, B4);
    signal state, state_next: t_state;   
 
    function invert (input : std_logic) return std_logic is
    begin
      return not input;
    end function;

begin

	
      
      
      master: i2c_master
        GENERIC MAP(
          input_clk => 31_250_000, --input clock speed from user logic in Hz
          bus_clk  => 100_000)   --speed the i2c bus (scl) will run at in Hz
        PORT MAP(
          clk       => clk,
          reset_n   => invert(rst),
          ena       => ena,
          addr      => "1100011",
          rw        => rw,
          data_wr   => data_wr,
          busy      => busy,
          data_rd   => data_rd,
          ack_error => ack_error,
          sda       => sda,
          scl       => scl);

      

    ipbus_out.ipb_ack <= ack;
	ipbus_out.ipb_err <= '0';
	rw <= '0';

	
	
	process(clk)
    begin
        if rising_edge(clk) then
            new_data <= '0';
            if ipbus_in.ipb_strobe='1' and ipbus_in.ipb_write='1' then
              case ipbus_in.ipb_addr(3 downto 0) is
                when x"0"   =>
                    new_data <= '1';
                    data <= ipbus_in.ipb_wdata;
--                when x"1"   => 
                when others => 
              end case;
            end if;
   			ack <= ipbus_in.ipb_strobe and not ack;	
        end if;
    end process;
	
      
	process(clk)
    begin
      if falling_edge(clk) then
          rst_syn1 <= rst;
          rst_syn2 <= rst_syn1;
      end if;
    end process;      

    
      FSM_update : process (clk, rst_syn2)
      begin 
          if rst_syn2 = '1' then 
              state <= IDLE;
          elsif rising_edge(clk) then 
              state <= state_next;
              last_busy <= busy;
          end if;
      end process;
      
      
      data_update: process(new_data, state)
      
      begin
        
        data_wr <= x"00";
        ena <= '0';
        state_next <= state;
        case state is 
            when IDLE => 
                if new_data = '1' then
                   state_next <= B1;
                end if;
            when B1 =>
                ena <= '1';
                data_wr <= data(7 downto 0);
                if (last_busy = '0') and (busy = '1') then
                    state_next <= B2;
--                elsif ack_error = '1' then
--                    state_next <= IDLE; 
                end if;
            when B2 =>
                ena <= '1';
                data_wr <= data(15 downto 8);
                if (last_busy = '0') and (busy = '1') then
                    state_next <= B3;
--                elsif ack_error = '1' then
--                    state_next <= IDLE; 
                end if;
            when B3 =>
                ena <= '1';
                data_wr <= data(23 downto 16);
                if (last_busy = '0') and (busy = '1') then
                    state_next <= B4;
--                elsif ack_error = '1' then
--                    state_next <= IDLE;
                end if;
            when B4 =>
                ena <= '1';
                data_wr <= data(31 downto 24);
                if (last_busy = '0') and (busy = '1') then
                    state_next <= IDLE;
                end if;
            when others =>
                state_next <= IDLE;
        end case;
      
      end process;
	

end rtl;
