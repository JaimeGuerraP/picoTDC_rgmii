library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;

entity GPIO is
	generic(
        ADDR_WIDTH: positive
    );
    port(
        clk:        in  std_logic;
        reset:      in  std_logic;
        ipbus_in:   in  ipb_wbus;
        ipbus_out:  out ipb_rbus;
        gpio_in:    in  std_logic_vector (15 downto 0);
        gpio_out:   out std_logic_vector (15 downto 0);
        gpio_dir:   out std_logic_vector (15 downto 0)
    );
end GPIO;

--
--
-- The GPIO_IN is used to read from the input IO buffer (the external interface values)
-- The GPIO_OUT is a register that holds the values to be written to the output IO
-- The GPIO_DIR controls the direction of the IO. A logic 1 disables the GPIO_OUT buffer, and therefore configures the IO as input
--
--

architecture rtl of GPIO is

    subtype REG is std_logic_vector (15 downto 0);
    type REG_FILE is array (0 to 2) of REG;

	signal sel:           std_logic_vector (ADDR_WIDTH-1 downto 0) := (others => '0');
	signal gpio_reg_file: REG_FILE;
	signal ack:           std_logic;

begin

    sel <= ipbus_in.ipb_addr(ADDR_WIDTH-1 downto 0);

	process(clk)
	begin
		if rising_edge(clk) then
		    if reset='1' then
		        -- By default, pins configured as outputs with a value of 0
                --gpio_reg_file(1)(15 downto 0) <= X"0000";
                --gpio_reg_file(2)(15 downto 0) <= X"0000";
			elsif ipbus_in.ipb_strobe='1' and ipbus_in.ipb_write='1' then
			    if sel = "01" then
			        gpio_reg_file(1)(15 downto 0) <= ipbus_in.ipb_wdata(15 downto 0); -- Write to GPIO_OUT
			    elsif sel = "10" then
			        gpio_reg_file(2)(15 downto 0) <= ipbus_in.ipb_wdata(15 downto 0); -- Write to GPIO_DIR
			    else 
			        gpio_reg_file(1)(15 downto 0) <= gpio_reg_file(1)(15 downto 0);
			        gpio_reg_file(2)(15 downto 0) <= gpio_reg_file(2)(15 downto 0);
			    end if;
			end if;
			ipbus_out.ipb_rdata(15 downto 0) <= gpio_reg_file(to_integer(unsigned(sel)))(15 downto 0);
			ack <= ipbus_in.ipb_strobe and not ack;	
		end if;
	end process;
	
	ipbus_out.ipb_ack <= ack;
	ipbus_out.ipb_err <= '0';
	ipbus_out.ipb_rdata(31 downto 16) <= (others => '0');

    -- Assigns the outputs to the corresponding position of the register file. The assignement/read is clock synchronous
    gpio_reg_file(0)(15 downto 0) <= gpio_in;
    gpio_out <= gpio_reg_file(1)(15 downto 0);
    gpio_dir <= gpio_reg_file(2)(15 downto 0);

end rtl;
