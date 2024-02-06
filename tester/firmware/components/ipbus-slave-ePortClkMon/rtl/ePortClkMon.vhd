library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.clkmon_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity ePortClkMon is
    generic (
        clock_channels  : positive
    );
    port (
        clk             : in std_logic;
        rst             : in std_logic;
        clk_mon         : in std_logic_vector(0 to clock_channels-1);
        phase           : in std_logic_vector(5 downto 0);
        phase_set       : in std_logic;
        phase_ready     : out std_logic;
        meas_start      : in std_logic;
        meas_done       : out std_logic;    -- synchronous to internal, phase shifted 40 MHz
        meas_results    : out std_logic_vector(clock_channels*line_taps*counter_width-1 downto 0) -- synchronous to internal, phase shifted 40 MHz
    );
end ePortClkMon;

architecture rtl of ePortClkMon is
    -- PLL outputs
    signal pll_clk640       : std_logic;
    signal pll_clk640buf    : std_logic;
    signal pll_clk40        : std_logic;
    signal pll_clk40buf     : std_logic;
    signal pll_clkfb        : std_logic;
    signal pll_clkfbbuf     : std_logic;
    signal pll_locked       : std_logic;

    -- delay line sampling clock enable
    signal dlyline_sample_en    : std_logic;
    signal edgedet_40m_tap1     : std_logic;
    signal edgedet_40m_tap2     : std_logic;

    -- phase shift controller internal interface
    signal pll_psclk        : std_logic;
    signal pll_psincdec     : std_logic;
    signal pll_psen         : std_logic;
    signal pll_psdone       : std_logic;
    
    -- phase shift controller ready feedback
    signal psctl_ready      : std_logic;
    signal meas_done_int    : std_logic_vector(0 to clock_channels-1);
	
	-- clock monitor input DDRs
	signal clk_mon_ddrq		: std_logic_vector(0 to clock_channels-1);

    -- clock domain crossing synchronizers
    signal meas_start_pll40     : std_logic;
    signal meas_start_pll40_d   : std_logic;
    
    type meas_results_type is array(0 to clock_channels-1) of delay_line_results;
    signal meas_results_array : meas_results_type;
    
begin
    -- PLL
    MMCME2_ADV_inst : MMCME2_ADV
    generic map (
        BANDWIDTH => "OPTIMIZED",      -- Jitter programming (OPTIMIZED, HIGH, LOW)
        CLKFBOUT_MULT_F => 16.0,        -- Multiply value for all CLKOUT (2.000-64.000).
        CLKFBOUT_PHASE => 0.0,         -- Phase offset in degrees of CLKFB (-360.000-360.000).
        -- CLKIN_PERIOD: Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
        CLKIN1_PERIOD => 25.0,
        CLKIN2_PERIOD => 0.0,
        -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for CLKOUT (1-128)
        CLKOUT0_DIVIDE_F => 1.0,       -- Divide amount for CLKOUT0 (1.000-128.000).
        CLKOUT1_DIVIDE => 16,
        -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.01-0.99).
        CLKOUT0_DUTY_CYCLE => 0.5,
        CLKOUT1_DUTY_CYCLE => 0.5,
        -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
        CLKOUT0_PHASE => 0.0,
        CLKOUT1_PHASE => 11.25,        -- ~10 degree phase shift to satisfy hold timing of edge detection
        COMPENSATION => "BUF_IN",      -- ZHOLD, BUF_IN, EXTERNAL, INTERNAL
        DIVCLK_DIVIDE => 1,            -- Master division value (1-106)
        -- REF_JITTER: Reference input jitter in UI (0.000-0.999).
        REF_JITTER1 => 0.0,
        REF_JITTER2 => 0.0,
        STARTUP_WAIT => FALSE,         -- Delays DONE until MMCM is locked (FALSE, TRUE)
        -- Spread Spectrum: Spread Spectrum Attributes
        SS_EN => "FALSE",              -- Enables spread spectrum (FALSE, TRUE)
        SS_MODE => "CENTER_HIGH",      -- CENTER_HIGH, CENTER_LOW, DOWN_HIGH, DOWN_LOW
        SS_MOD_PERIOD => 10000,        -- Spread spectrum modulation period (ns) (VALUES)
        -- USE_FINE_PS: Fine phase shift enable (TRUE/FALSE)
        CLKOUT0_USE_FINE_PS => FALSE,
        CLKOUT1_USE_FINE_PS => FALSE,
        CLKFBOUT_USE_FINE_PS => TRUE
    )
    port map (
        -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
        CLKOUT0 => pll_clk640,
        CLKOUT1 => pll_clk40,
        -- Dynamic Phase Shift Ports: 1-bit (each) output: Ports used for dynamic phase shifting of the outputs
        PSDONE => pll_psdone,
        -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
        CLKFBOUT => pll_clkfb,
        LOCKED => pll_locked,
        -- Clock Inputs: 1-bit (each) input: Clock inputs
        CLKIN1 => clk,
        CLKIN2 => '0',
        -- Control Ports: 1-bit (each) input: MMCM control ports
        CLKINSEL => '1',
        PWRDWN => '0',
        RST => rst,
        -- DRP Ports: 7-bit (each) input: Dynamic reconfiguration ports
        DADDR => (others => '0'),
        DCLK => '0',
        DEN => '0',
        DI => (others => '0'),
        DWE => '0',
        -- Dynamic Phase Shift Ports: 1-bit (each) input: Ports used for dynamic phase shifting of the outputs
        PSCLK => pll_psclk,
        PSEN => pll_psen,
        PSINCDEC => pll_psincdec,
        CLKFBIN => pll_clkfbbuf
    );
    
    buf640m : BUFG
    port map (
        I => pll_clk640,
        O => pll_clk640buf
    );
    
    buf40m : BUFG
    port map (
        I => pll_clk40,
        O => pll_clk40buf
    );
    
    fbbuf40m : BUFG
    port map (
        I => pll_clkfb,
        O => pll_clkfbbuf
    );

    -- PLL phase shift controller
    pll_ctl : entity work.pll_psctl
    port map (
        clk => clk,
        rst => rst,
        set_phase => phase_set,
        phase => unsigned(phase),
        ready => psctl_ready,
        
        pll_psclk => pll_psclk,
        pll_psincdec => pll_psincdec,
        pll_psen => pll_psen,
        pll_psdone => pll_psdone
    );

	-- IDDRs are only used on the external input clocks, not on the 40 MHz lines and the test channel
    gen_iddr : for i in 0 to clock_channels-4 generate
		IDDR_inst : IDDR generic map (
			DDR_CLK_EDGE => "SAME_EDGE",
			INIT_Q1 => '0',
			INIT_Q2 => '0',
			SRTYPE => "SYNC"
		)
		port map (
			Q1 => clk_mon_ddrq(i),
			Q2 => open,
			C => pll_clk640buf,
			CE => '1',
			D => clk_mon(i),
			R => '0',
			S => '0'
		);
	end generate;

    generate_non_iddr : for i in clock_channels-3 to clock_channels-1 generate
        clk_mon_ddrq(i) <= clk_mon(i);
    end generate;

    -- synchronize measurement start signal
    meas_start_pll40 <= meas_start when rising_edge(pll_clk40buf);
    meas_start_pll40_d <= meas_start_pll40 when rising_edge(pll_clk40buf);

    -- generate a sample clock enable signal on the falling edge of the 40 MHz clock
    edgedet_40m_tap1 <= pll_clk40buf when rising_edge(pll_clk640buf);
    edgedet_40m_tap2 <= edgedet_40m_tap1 when rising_edge(pll_clk640buf);
    dlyline_sample_en <= (not edgedet_40m_tap1 and edgedet_40m_tap2) when rising_edge(pll_clk640buf);
    
    gen_delaylines : for i in 0 to clock_channels-1 generate
        line : entity work.delay_line
        port map (
            clk_fast => pll_clk640buf,
            clk_slow => pll_clk40buf,
            sample_en => dlyline_sample_en,
            rst => rst,
            trigger => meas_start_pll40_d,
            d => clk_mon_ddrq(i),
            done => meas_done_int(i),
            results => meas_results_array(i)
        );
    end generate;
    
    -- Xilinx does not support having arrays on VHDL/SV boundaries, so here goes...
    assign_results_outer : for i in 0 to clock_channels-1 generate
        assign_results_inner : for j in 0 to line_taps-1 generate
            meas_results(
                i*line_taps*counter_width + (j+1)*counter_width - 1 
                    downto 
                i*line_taps*counter_width + j*counter_width
                ) <= meas_results_array(i)(j);
        end generate;
    end generate;
    
    meas_done <= meas_done_int(0);
    phase_ready <= psctl_ready and pll_locked;

end rtl;
