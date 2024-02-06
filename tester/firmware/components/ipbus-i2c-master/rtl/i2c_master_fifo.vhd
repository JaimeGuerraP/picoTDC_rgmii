-------------------------------------------------------
--! @file
--! @author Julian Mendez <julian.mendez@cern.ch> (CERN - EP-ESE-BE)
--! @date April, 2017
--! @version 1.0
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_master_fifo is
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
end i2c_master_fifo;

architecture behavioral of i2c_master_fifo is

    -- Types
    subtype reg_t   is std_logic_vector((g_WORD_SIZE-1) downto 0);
    type ramreg_t   is array(integer range<>) of reg_t;

    -- Signals
    signal mem_arr              : ramreg_t(g_FIFO_DEPTH downto 0);

    signal wr_ptr               : integer range 0 to g_FIFO_DEPTH;
    signal word_in_mem_size     : integer range 0 to g_FIFO_DEPTH;
    signal rd_ptr               : integer range 0 to g_FIFO_DEPTH;

begin                 --========####   Architecture Body   ####========--

    ram_proc: process(reset_i, clk_i)

    begin

        if reset_i = '1' then
            wr_ptr              <= 0;
            rd_ptr              <= 0;
            word_in_mem_size    <= 0;
            empty_o             <= '1';

        elsif rising_edge(clk_i) then

            -- Read
            if read_i = '1' and rd_ptr < word_in_mem_size then
                rd_ptr          <= rd_ptr + 1;
            end if;

            if word_in_mem_size > rd_ptr then
                empty_o         <= '0';
            else
                empty_o         <= '1';
            end if;

            -- Write
            if write_i = '1' then
                mem_arr(wr_ptr) <= data_i;
                wr_ptr <= wr_ptr + 1;
                word_in_mem_size  <= word_in_mem_size + 1;
            end if;
            
            data_o          <= mem_arr(rd_ptr);
           
        end if;

    end process;

    

end behavioral;
--============================================================================--
--############################################################################--
--============================================================================--
