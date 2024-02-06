LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.Numeric_Std.all;

use work.ipbus.all;
use work.ipbus_reg_types.all;

entity i2c_master_logic is
	generic(
	   mode_w: boolean  
	   );
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
end i2c_master_logic;

architecture arch of i2c_master_logic is

    type i2cMasterFSM_t is (s0_idle, s1_start, s2_writeByte, s3_getWrAck, s4_readByte, s5_setRdAck, s6_stop);
    signal i2cMaster_FSM   : i2cMasterFSM_t;

    type sclGenFSM_t is (s0_idle, s1_oneState, s2_zeroState);
    signal sclGen_FSM   : sclGenFSM_t;

    signal scl_s0                  : std_logic;
    signal scl_s                   : std_logic;
    signal sda_s                   : std_logic;
    signal sda_oe                  : std_logic;

    signal scl_generator_en_s      : std_logic;
    signal start_stop_s            : std_logic;
    signal scl_counter_s           : unsigned(15 downto 0);
    signal dat_update_s            : std_logic;
    signal dat_read_s              : std_logic;

    signal fifo_rst_s              : std_logic;
    signal rd_tx_fifo_s            : std_logic;
    signal wr_rx_fifo_s            : std_logic;
    signal tx_fifo_empty_s         : std_logic;
    signal tx_fifo_rdData_s        : std_logic_vector(7 downto 0);

    signal go_to_rd_s              : std_logic;
    signal rd_nwr_s                : std_logic;
    signal rd_ack_set_s            : std_logic;
    signal ack_error_s             : std_logic;
    signal wr_byte_s               : std_logic_vector(7 downto 0);
    signal rd_byte_s               : std_logic_vector(7 downto 0);
    signal bitpos                  : integer range 0 to 8;
    signal nb_byte_rd              : unsigned(8 downto 0);

    signal i2c_fault_s             : std_logic;

    component i2c_master_fifo
        generic (
            g_FIFO_DEPTH    : integer := 10;                                    --! Depth of the internal FIFO used to improve the timming performance
            g_WORD_SIZE     : integer := 8                                      --! Size of the words to be stored
        );
        port (
            clk_i           : in  std_logic;                                    --! Rx clock (Rx_frameclk_o from GBT-FPGA IP): must be a multiple of the LHC frequency
            reset_i         : in  std_logic;                                    --! Reset all of the RX processes

            -- Data
            data_i          : in  std_logic_vector((g_WORD_SIZE-1) downto 0);   --! Input data (from deserializer)
            write_i         : in  std_logic;                                    --! Write data
            data_o          : out std_logic_vector((g_WORD_SIZE-1) downto 0);   --! Data from the FIFO (read by the user)
            read_i          : in  std_logic;                                    --! Request a read (from user)

            --Status
            empty_o         : out std_logic
        );
    end component;

begin

    ack_error_o <= ack_error_s;
    i2c_fault_o <= i2c_fault_s;
    fifo_rst_s  <= reset;


    sda         <= sda_s when (drive_sda = '1' and sda_oe = '1') else 
                   '0' when sda_s = '0' else 'Z';

    scl         <= scl_s when drive_scl = '1' else 
                   '0' when scl_s = '0' else 'Z';

    txFifo_inst: i2c_master_fifo
        generic map(
            g_FIFO_DEPTH   => 512,
            g_WORD_SIZE    => 8
        )
        port map(
            clk_i          => clk,
            reset_i        => fifo_rst_s,

            data_i         => tx_data,
            write_i        => tx_wr,
            data_o         => tx_fifo_rdData_s,
            read_i         => rd_tx_fifo_s,

            empty_o        => tx_fifo_empty_s
        );

    rxFifo_inst: i2c_master_fifo
        generic map(
            g_FIFO_DEPTH   => 512,
            g_WORD_SIZE    => 8
        )
        port map(
            clk_i          => clk,
            reset_i        => fifo_rst_s,

            data_i         => rd_byte_s,
            write_i        => wr_rx_fifo_s,
            data_o         => rx_data,
            read_i         => rx_rd,

            empty_o        => rx_empty_o
        );

    i2cMasterFSM_proc: process(reset, clk)
    begin
        if reset = '1' then
            i2cMaster_FSM       <= s0_idle;
            scl_generator_en_s  <= '0';

        elsif rising_edge(clk) then

            scl_s0       <= scl_s;
            rd_tx_fifo_s <= '0';
            wr_rx_fifo_s <= '0';
            sda_oe       <= '1';

            case i2cMaster_FSM is

                when s0_idle => -- Idle state: wait for trigger in idle mode (SCL and SDA are pulled-up)
                                sda_s               <= '1';
                                bitpos              <= 0;
                                scl_generator_en_s  <= '0';
                                go_to_rd_s          <= '0';
                                busy_o              <= '0';

                                if trg_wr = '1' then
                                    busy_o        <= '1';
                                    rd_nwr_s      <= '0';
                                    ack_error_s   <= '0';
                                    i2c_fault_s   <= '0';

                                    if sda = '0' or scl = '0' then
                                        i2c_fault_s   <= '1';
                                    else
                                        i2cMaster_FSM <= s1_start;
                                    end if;

                                elsif trg_rd = '1' then
                                    busy_o        <= '1';
                                    ack_error_s   <= '0';
                                    i2c_fault_s   <= '0';

                                    if tx_fifo_empty_s = '1' then
                                        go_to_rd_s  <= '1';
                                    else
                                        if mode_w = false then 
                                            rd_nwr_s    <= '1';
                                        elsif mode_w = true then
                                            go_to_rd_s  <= '1'; -- modification for picoTDC BUG
                                        end if;
                                    end if;

                                    if sda = '0' or scl = '0' then
                                        i2c_fault_s   <= '1';
                                    else
                                        i2cMaster_FSM <= s1_start;
                                    end if;
                                end if;

                when s1_start =>
                                scl_generator_en_s  <= '0';

                                if go_to_rd_s = '1' then
                                    wr_byte_s <= device_addr & '1';
                                else
                                    wr_byte_s <= device_addr & '0';
                                end if;

                                if start_stop_s = '1' then
                                    sda_s               <= '0';
                                    scl_generator_en_s  <= '1';
                                    bitpos              <= 0;
                                    i2cMaster_FSM       <= s2_writeByte;
                                end if;


                when s2_writeByte =>
                                scl_generator_en_s  <= '1';

                                if dat_update_s = '1' then

                                    if bitpos = 8 then
                                        bitpos         <= 0;
                                        sda_s          <= '1';
                                        sda_oe         <= '0';
                                        i2cMaster_FSM  <= s3_getWrAck;

                                    else
                                        sda_s   <= wr_byte_s(7 - bitpos);
                                        bitpos  <= bitpos + 1;

                                    end if;
                                end if;

                when s3_getWrAck =>
                                scl_generator_en_s  <= '1';
                                sda_oe              <= '0';

                                if dat_read_s = '1' then
                                    if sda = '1' then
                                        ack_error_s   <= '1';
                                        sda_s         <= '0';
                                        i2cMaster_FSM <= s6_stop;

                                    else
                                        ack_error_s  <= '0';

                                        if tx_fifo_empty_s = '0' then
                                            rd_tx_fifo_s  <= '1';
                                            wr_byte_s     <= tx_fifo_rdData_s;
                                            i2cMaster_FSM <= s2_writeByte;
                                            bitpos        <= 0;

                                        elsif go_to_rd_s = '1' then
                                            i2cMaster_FSM       <= s4_readByte;
                                            nb_byte_rd          <= (others => '0');
                                            sda_s               <= '1';
                                            bitpos              <= 0;

                                        else
                                            sda_s               <= '0';
                                            i2cMaster_FSM       <= s6_stop;

                                        end if;
                                    end if;
                                end if;

                when s4_readByte =>
                                sda_oe <= '0';
                                scl_generator_en_s  <= '1';

                                if dat_read_s = '1' then
                                    rd_byte_s(7 - bitpos) <= sda;
                                    if bitpos = 7 then
                                        wr_rx_fifo_s   <= '1';
                                        bitpos         <= 0;
                                        rd_ack_set_s   <= '0';
                                        i2cMaster_FSM  <= s5_setRdAck;

                                    else
                                        bitpos  <= bitpos + 1;

                                    end if;
                                end if;

                when s5_setRdAck =>
                                scl_generator_en_s  <= '1';
                                sda_oe <= sda_oe;

                                if dat_update_s = '1' and rd_ack_set_s = '0' then
                                    sda_oe <= '1';

                                    if nb_byte_rd = unsigned(rd_len) then
                                        sda_s  <= '1';
                                    else
                                        sda_s  <= '0';
                                    end if;

                                    rd_ack_set_s   <= '1';

                                elsif dat_update_s = '1' and rd_ack_set_s = '1' then
                                    if nb_byte_rd = unsigned(rd_len) then
                                        sda_s           <= '0';
                                        i2cMaster_FSM  <= s6_stop;

                                    else
                                        sda_s          <= '1';
                                        sda_oe         <= '0';
                                        nb_byte_rd     <= nb_byte_rd + 1;
                                        bitpos         <= 0;
                                        i2cMaster_FSM  <= s4_readByte;

                                    end if;
                                end if;

                when s6_stop =>
                                scl_generator_en_s  <= '0';
                                sda_s               <= '0';

                                if start_stop_s = '1' then
                                    sda_s               <= '1';

                                    if rd_nwr_s = '1' then
                                        rd_nwr_s      <= '0';
                                        go_to_rd_s    <= '1';
                                        i2cMaster_FSM <= s1_start;

                                    else
                                        i2cMaster_FSM <= s0_idle;

                                    end if;
                                end if;
            end case;
        end if;
    end process;

    sclGen_proc: process(reset, clk)
    begin
        if reset = '1' then
            scl_s <= '1';

        elsif rising_edge(clk) then

            dat_update_s   <= '0';
            dat_read_s     <= '0';
            start_stop_s   <= '0';

            case sclGen_FSM is

                when s0_idle => scl_s <= '1';

                                if scl_counter_s = unsigned(scl_presc) then
                                    start_stop_s   <= '1';
                                    scl_counter_s  <= x"0000";
                                else
                                    scl_counter_s  <= scl_counter_s + 1;
                                end if;

                                if scl_generator_en_s = '1' then
                                    scl_counter_s  <= x"0000";
                                    sclGen_FSM     <= s1_oneState;
                                end if;

                when s1_oneState =>
                                if scl_counter_s = unsigned(scl_presc - 1) then
                                    dat_read_s   <= '1';
                                end if;

                                if scl_counter_s = unsigned(scl_presc) then
                                    scl_s          <= '0';
                                    scl_counter_s  <= x"0000";
                                    sclGen_FSM     <= s2_zeroState;
                                else
                                    scl_counter_s  <= scl_counter_s + 1;
                                end if;

                when s2_zeroState =>
                                if scl_counter_s = unsigned(dat_setup) then
                                    dat_update_s   <= '1';
                                end if;

                                if scl_counter_s = unsigned(scl_presc) then
                                    scl_s          <= '1';
                                    scl_counter_s  <= x"0000";
                                    sclGen_FSM     <= s0_idle;
                                else
                                    scl_counter_s  <= scl_counter_s + 1;
                                end if;
            end case;
        end if;
    end process;
end arch;
