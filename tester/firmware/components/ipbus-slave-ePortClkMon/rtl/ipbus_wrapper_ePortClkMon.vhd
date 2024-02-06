--------------------------------------------------------------------------------------------------------------
--                                                                                                          --
--  ePort Clock Frequency, Duty Cycle, Jitter and Glitch monitoring.                                        --
--                                                                                                          --
--  Stefan Biereigel, CERN, EP-ESE-ME, August 2018                                                          --
--                                                                                                          --
--------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- IP Bus infrastruture
use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.clkmon_pkg.all;

entity ipbus_wrapper_ePortClkMon is
	generic(
        ADDR_WIDTH: positive;
        CLK_CHANNELS: positive
    );
    port (
        -- IP Bus connections
        ipbus_in:   in  ipb_wbus;
        ipbus_out:  out ipb_rbus;

        -- Other connections
        clk40MHzIn    : in  std_logic;
        clkIPBus      : in  std_logic;
        reset         : in  std_logic;
        clkMon        : in std_logic_vector (CLK_CHANNELS-1 downto 0)  -- clocks to monitor
    );

    -- OPTION 1: the entity is never dissolved 
    attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of ipbus_wrapper_ePortClkMon: entity is "YES";

end ipbus_wrapper_ePortClkMon;

architecture rtl of ipbus_wrapper_ePortClkMon is

    -- The register file signals
    -- 1 control register
    -- result registers (N clocks * 16 taps * 8 bit per result / 32 bit per register)
    subtype REG is std_logic_vector (31 downto 0);
    type REG_FILE is array (0 to CLK_CHANNELS * 16 * 8 / 32) of REG;

	signal sel              : std_logic_vector (ADDR_WIDTH-1    downto 0) := (others => '0');
	signal epclkmon_reg_file : REG_FILE;
	signal ack              : std_logic;

    -- Internal connection signals
    signal phase                : std_logic_vector(5 downto 0);
    signal phase_set            : std_logic;
    signal phase_ready          : std_logic;
    signal phase_ready_ipbclk   : std_logic;    -- phase_ready in IPbus clock domain
    signal meas_start           : std_logic;
    signal meas_done            : std_logic;
    signal meas_done_ipbclk     : std_logic;    -- meas_done flag in IPbus clock domain
    signal meas_results         : std_logic_vector(CLK_CHANNELS * line_taps * counter_width - 1 downto 0);
    signal clkMon_reversed      : std_logic_vector(0 to CLK_CHANNELS-1);

    type meas_results_type is array(0 to CLK_CHANNELS-1) of delay_line_results;
    signal meas_results_array : meas_results_type;

    signal ctrl_reg_ipbclk  : std_logic_vector(31 downto 0);
    signal ctrl_reg_40mhz   : std_logic_vector(31 downto 0);
    signal ctrl_reg_40mhz_d : std_logic_vector(31 downto 0);

    constant ctrl_meas_start_idx    : integer := 0;
    constant ctrl_phase_set_idx     : integer := 1;
    constant ctrl_phase_idx         : integer := 8;
    constant ctrl_meas_done_idx     : integer := 16;
    constant ctrl_phase_ready_idx   : integer := 17;

begin

    -- Selects the address on where to write
    sel       <= ipbus_in.ipb_addr(ADDR_WIDTH-1 downto 0);

    -- Reads/Writes to/from the IPBus bus to the registers
	process(clkIPBus)
	begin
		if rising_edge(clkIPBus) then
            -- control register writing
            ctrl_reg_ipbclk(ctrl_meas_start_idx) <= '0';  -- reset 'start measurement' flag
            ctrl_reg_ipbclk(ctrl_phase_set_idx) <= '0';  -- reset 'set phase' flag
		    if ipbus_in.ipb_strobe = '1' and ipbus_in.ipb_write='1' then
			    ctrl_reg_ipbclk <= ipbus_in.ipb_wdata; -- Write to control register regardless of address
			end if;

            -- bus reads
	        ipbus_out.ipb_rdata <= epclkmon_reg_file(to_integer(unsigned(sel)));
			ack <= ipbus_in.ipb_strobe and not ack;	
		end if;
	end process;

    -- control register clock domain crossing
    ctrl_reg_40mhz <= ctrl_reg_ipbclk when rising_edge(clk40MHzIn);
    ctrl_reg_40mhz_d <= ctrl_reg_40mhz when rising_edge(clk40MHzIn);

    meas_start <= ctrl_reg_40mhz_d(ctrl_meas_start_idx);
    phase_set <= ctrl_reg_40mhz_d(ctrl_phase_set_idx);
    phase <= ctrl_reg_40mhz_d(ctrl_phase_idx + 5 downto ctrl_phase_idx);

	ipbus_out.ipb_ack <= ack;
	ipbus_out.ipb_err <= '0';

    meas_done_ipbclk <= meas_done when rising_edge(clkIPBus);
    epclkmon_reg_file(0)(ctrl_meas_done_idx) <= meas_done_ipbclk when rising_edge(clkIPBus);
    
    phase_ready_ipbclk <= phase_ready when rising_edge(clkIPBus);
    epclkmon_reg_file(0)(ctrl_phase_ready_idx) <= phase_ready_ipbclk when rising_edge(clkIPBus);

    -- register map assignment
    assert counter_width = 8 report "Only 8 bit accumulators supported for automatic register mapping" severity error;
    assert line_taps mod 4 = 0 report "Only multiples of 4 delay line taps supported for automatic register mapping" severity error;
    assign_regs_outer : for i in 0 to CLK_CHANNELS - 1 generate
        assign_regs_inner : for j in 0 to (line_taps / 4) - 1  generate
            epclkmon_reg_file(i*line_taps/4 + j + 1) <= 
                meas_results_array(i)(4*j) & 
                meas_results_array(i)(4*j+1) & 
                meas_results_array(i)(4*j+2) & 
                meas_results_array(i)(4*j+3);
        end generate;
    end generate;
    
    -- Xilinx does not support having arrays on VHDL/SV boundaries
    -- for that reason, re-map here to some sane array type
    -- that later goes into the register map for clarity.
    assign_results_outer : for i in 0 to CLK_CHANNELS-1 generate
        assign_results_inner : for j in 0 to line_taps-1 generate
            meas_results_array(i)(j) <= meas_results(
                i*line_taps*counter_width + (j+1)*counter_width - 1 
                downto 
                i*line_taps*counter_width + j*counter_width
            );
        end generate;
    end generate;

    -- Accounting for a change of convention on the IPbus wrapper boundary,
    -- channel numberings are being reversed here, such that bit 0 of the
    -- input vector correctly maps to channel 0 of the result array.
    reverse_clk_channels : for i in 0 to CLK_CHANNELS-1 generate
        clkMon_reversed(i) <= clkMon(i);
    end generate;

    ePortClkMon_inst : entity work.ePortClkMon
        generic map (
            clock_channels => CLK_CHANNELS
        )
        port map (
            clk => clk40MHzIn,
            rst => reset,
            clk_mon => clkMon_reversed,
            phase => phase,
            phase_set => phase_set,
            phase_ready => phase_ready,
            meas_start => meas_start,
            meas_done => meas_done,
            meas_results => meas_results
        );
end rtl;
