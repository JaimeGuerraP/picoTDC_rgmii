library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- IP Bus infrastruture
use work.ipbus.all;
use work.ipbus_reg_types.all;

entity ipbus_intf is
    generic (
        c_addrwidth   : integer
    );
    port (
        -- IP Bus connections
        ipbus_in      : in  ipb_wbus;
        ipbus_out     : out ipb_rbus;
        ipbus_clk     : in  std_logic;
        ipbus_rst     : in  std_logic;

        dest_clk      : in  std_logic;
        
        -- Other connections
        register_o    : out ipb_reg_v((2 ** c_addrwidth)-1 downto 0);
        wr_fifo_o     : out std_logic_vector((2 ** c_addrwidth)-1 downto 0); -- Only used when the register is connected to a FIFO

        register_i    : in  ipb_reg_v((2 ** c_addrwidth)-1 downto 0);
        rd_fifo_o     : out std_logic_vector((2 ** c_addrwidth)-1 downto 0)  -- Only used when the register is connected to a FIFO
    );
end ipbus_intf;

architecture rtl of ipbus_intf is

	signal sel                 : std_logic_vector ((c_addrwidth)-1 downto 0) := (others => '0');
	signal ack                 : std_logic;
	
	signal register_out_s      : ipb_reg_v((2 ** c_addrwidth)-1 downto 0);
begin

    sel <= ipbus_in.ipb_addr(c_addrwidth-1 downto 0);
    
    process(dest_clk)
    begin
        if rising_edge(dest_clk) then
            register_o <= register_out_s;
        end if;
    end process;
    
	process(ipbus_clk)
	begin

		if rising_edge(ipbus_clk) then

            rd_fifo_o <= (others => '0');
            wr_fifo_o <= (others => '0');

		    if ipbus_rst='1' then
                register_out_s         <= (others => x"00000000");
                ipbus_out.ipb_rdata  <= (others => '0');

			elsif ipbus_in.ipb_strobe='1' and ipbus_in.ipb_write='1' then
                register_out_s(to_integer(unsigned(sel))) <= ipbus_in.ipb_wdata;
                wr_fifo_o(to_integer(unsigned(sel)))  <= ack;
                
            elsif ipbus_in.ipb_strobe='1' then
                rd_fifo_o(to_integer(unsigned(sel))) <= not ack;
                
			end if;
			
            ipbus_out.ipb_rdata <= register_i(to_integer(unsigned(sel)));
            ack <= ipbus_in.ipb_strobe and not ack;
		end if;

	end process;

	ipbus_out.ipb_ack <= ack;
	ipbus_out.ipb_err <= '0';

end rtl;

