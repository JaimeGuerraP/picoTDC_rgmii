library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;

entity ipbus_master_i2c is
	generic(
	   ADDR_WIDTH: positive;
	   MODE: boolean  
	   );
	port(
        -- IPBus connections
        ipbus_in      : in  ipb_wbus;
        ipbus_out     : out ipb_rbus;
        ipbus_clk     : in  std_logic;
        ipbus_rst     : in  std_logic;

		scl           : inout std_logic;
		sda           : inout std_logic
	);

end ipbus_master_i2c;

architecture rtl of ipbus_master_i2c is


    -- IPbus interface
    component ipbus_intf
        generic (
            c_addrwidth   : integer);
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
    end component;

    -- I2c interface
    component i2c_master_logic
        generic(
            mode_w    : boolean);
        port(
            clk         : in std_logic;
            reset       : in std_logic;

            sda         : inout std_logic;
            scl         : inout std_logic;

            scl_presc   : in  std_logic_vector(15 downto 0);
            dat_setup   : in  std_logic_vector(15 downto 0);

            drive_sda   : in std_logic;
            drive_scl   : in std_logic;

            device_addr : in  std_logic_vector(6 downto 0);
            rd_len      : in  std_logic_vector(8 downto 0);

            -- Triggers
            trg_wr      : in std_logic;
            trg_rd      : in std_logic;

            -- control interface
            tx_data     : in std_logic_vector(7 downto 0);
            tx_wr       : in std_logic;

            rx_data     : out std_logic_vector(7 downto 0);
            rx_rd       : in  std_logic;
            rx_empty_o  : out std_logic;

            -- Status
            ack_error_o : out std_logic;
            i2c_fault_o : out std_logic;
            busy_o      : out std_logic
        );
    end component;

    signal register_o_s  : ipb_reg_v((2 ** ADDR_WIDTH)-1 downto 0);
    signal register_i_s  : ipb_reg_v((2 ** ADDR_WIDTH)-1 downto 0);
    signal ipb_wrfifo_s  : std_logic_vector((2 ** ADDR_WIDTH)-1 downto 0);
    signal ipb_rdfifo_s  : std_logic_vector((2 ** ADDR_WIDTH)-1 downto 0);

    signal i2c_rst_s     : std_logic;

begin

    -- IPBUS registers
    ipbus_intf_inst: ipbus_intf
        generic map(
            c_addrwidth   => ADDR_WIDTH)
        port map(
            -- IPBus connections
            ipbus_in      => ipbus_in,
            ipbus_out     => ipbus_out,
            ipbus_clk     => ipbus_clk,
            ipbus_rst     => ipbus_rst,

            dest_clk      => ipbus_clk,

            -- Other connections
            register_o    => register_o_s,
            register_i    => register_i_s,

            wr_fifo_o     => ipb_wrfifo_s,
            rd_fifo_o     => ipb_rdfifo_s
        );


    i2c_rst_s  <= ipbus_rst or ipb_wrfifo_s(1);

    i2c_master_logic_inst: i2c_master_logic
        generic map(
            mode_w   => MODE)
        port map(
            clk          => ipbus_clk,
            reset        => i2c_rst_s,

            sda          => sda,
            scl          => scl,

            scl_presc    => register_o_s(0)(15 downto 0),
            dat_setup    => register_o_s(0)(31 downto 16),

            device_addr  => register_o_s(1)(6 downto 0),
            drive_sda    => register_o_s(1)(31),
            drive_scl    => register_o_s(1)(30),
            rd_len       => register_o_s(2)(8 downto 0),

            -- Triggers
            trg_wr       => ipb_wrfifo_s(3),
            trg_rd       => ipb_wrfifo_s(2),

            -- control interface
            tx_data      => register_o_s(4)(7 downto 0),
            tx_wr        => ipb_wrfifo_s(4),

            rx_data      => register_i_s(5)(7 downto 0),
            rx_rd        => ipb_rdfifo_s(5),
            rx_empty_o   => register_i_s(6)(2),

            -- Status
            ack_error_o  => register_i_s(6)(0),
            i2c_fault_o  => register_i_s(6)(3),
            busy_o       => register_i_s(6)(1)
        );

end rtl;




