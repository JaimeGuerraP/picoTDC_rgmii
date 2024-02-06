-----------------------------------------------------------------------------------------------------------------
--                                                                                                             --
--                                                                                                             --
--  Module that implements the complimentary Datapath and Gigabit interfaces for multigigabit comm. with lpgbt --
--                                                                                                             --
--  Jose Pedro Castro Fonseca, CERN, EP-ESE-ME, October 2018                                                    --
--                                                                                                             --
--                                                                                                             --
-----------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- IP Bus infrastruture
use work.ipbus.all;
use work.ipbus_reg_types.all;

-- For simulation of Xilinx model of OSERDESE2
library UNISIM;
use UNISIM.vcomponents.all;

entity ipbus_wrapper_datapath is
	generic(
        ADDR_WIDTH: positive
    );
    port (
        -- IP Bus connections
        ipbus_in:     : in  ipb_wbus; 
        ipbus_out     : out ipb_rbus; 
        clkIPBus      : in  std_logic;

        -- Other connections
        refClkGTX_320M_n : in std_logic;
        refClkGTX_320M_p : in std_logic;        
        clk40MHz_TX      : out std_logic;
        clk40MHz_RX      : out std_logic;

        hsUpLink_p_i     : in std_logic;
        hsUpLink_n_i     : in std_logic;
        hsDnLink_p_o     : in std_logic;     
        hsDnLink_n_o     : in std_logic;
        
        userDataDnLink_i : in std_logic_vector(31 downto 0);
        icDataDnLink_i   : in std_logic_vector(1 downto 0);
        ecDataDnLink_i   : in std_logic_vector(1 downto 0);

        userDataUpLink_o : out std_logic_vector(223 downto 0);
        icDataUpLink_o   : out std_logic_vector(1 downto 0);
        ecDataUpLink_o   : out std_logic_vector(1 downto 0)
    );

end ipbus_wrapper_datapath;

architecture rtl of ipbus_wrapper_datapath is

    -- The register file signals
    subtype REG is std_logic_vector (31 downto 0);
    type REG_FILE is array (0 to 3) of REG;

	signal sel               : std_logic_vector (ADDR_WIDTH-1 downto 0) := (others => '0');
	signal datapath_reg_file : REG_FILE;
	signal ack               : std_logic;

    -- Internal connection signals
    signal statusBus        : std_logic_vector(31 downto 0);
    signal controlBus       : std_logic_vector(31 downto 0);
    signal controlBusDnLink : std_logic_vector(31 downto 0);
    signal controlBusUpLink : std_logic_vector(31 downto 0);

begin

    -- Selects the address on where to write
    sel       <= ipbus_in.ipb_addr(ADDR_WIDTH-1 downto 0);

    -- Reads/Writes to/from the IPBus bus to the registers
	process(clkIPBus)
	begin
		if rising_edge(clkIPBus) then
		    if ipbus_in.ipb_strobe='1' and ipbus_in.ipb_write='1' then
		        if sel /= B"00111" then
			        datapath_reg_file(to_integer(unsigned(sel)))(31 downto 0) <= ipbus_in.ipb_wdata(31 downto 0); -- Write to GPIO_OUT
			    end if;
            else
                datapath_reg_file(3)(31 downto 0) <= statusBus;
                datapath_reg_file(2)(31 downto 0) <= controlBusUpLink;
                datapath_reg_file(1)(31 downto 0) <= controlBusDnLink;
                datapath_reg_file(0)(31 downto 0) <= controlBus;
			end if;
	        ipbus_out.ipb_rdata(31 downto 0) <= datapath_reg_file(to_integer(unsigned(sel)))(31 downto 0);
			ack <= ipbus_in.ipb_strobe and not ack;	
		end if;
	end process;
	
	ipbus_out.ipb_ack <= ack;
	ipbus_out.ipb_err <= '0';

    -- TODO: Assigns the outputs to the corresponding position of the register file. The assignement/read is clock synchronous
    --eprxdrv_reg_file(7)(31 downto 0) <= (29 downto 0 => '0') & dllLock & pllLock;
   
    datapath_inst : entity work.datapath(rtl)
        port map (
            refClkGTX_320M_n => refClkGTX_320M_n,
            refClkGTX_320M_p => refClkGTX_320M_p,        
            clk40MHz_TX => clk40MHz_TX,
            clk40MHz_RX => clk40MHz_RX,

            hsUpLink_p_i => hsUpLink_p_i,
            hsUpLink_n_i => hsUpLink_n_i,
            hsDnLink_p_o => hsDownLink_p_o,     
            hsDnLink_n_o => hsDownLink_n_o,     
            
            userDataDnLink => userDataDnLink_i,
            icDataDnLink   => icDataDnLink_i,
            ecDataDnLink   => ecDataDnLink_i,

            userDataUpLink => userDataUpLink_o,
            icDataUpLink   => icDataUpLink_o,
            ecDataUpLink   => ecDataUpLink_o,
            
            statusBus          => statusBus       ,
            controlBus         => controlBus      ,
            controlBusDnLink   => controlBusDnLink,
            controlBusUpLink   => controlBusUpLink

        );

end rtl;
