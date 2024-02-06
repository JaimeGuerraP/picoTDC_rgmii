--------------------------------------------------------------------------------------------------------------
--                                                                                                          --
--                                                                                                          --
--  Module that drives the ePortRx. Accepts clocks of 40, 160 and 640MHz, and outputs 28 streams up to 1G28 --
--                                                                                                          --
--  Jose Pedro Castro Fonseca, CERN, EP-ESE-ME, August 2018                                                 --
--                                                                                                          --
--                                                                                                          --
--------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- IP Bus infrastruture
use work.ipbus.all;
use work.ipbus_reg_types.all;

-- For simulation of Xilinx model of OSERDESE2
library UNISIM;
use UNISIM.vcomponents.all;

entity ipbus_wrapper_ePortRxDriver is
	generic(
        ADDR_WIDTH: positive
    );
    port (
        -- IP Bus connections
        ipbus_in:   in  ipb_wbus;
        ipbus_out:  out ipb_rbus;

        -- Other connections
        clk40MHzIn    : in  std_logic;
        clkIPBus      : in  std_logic;
        reset         : in  std_logic;
        channel       : out std_logic_vector (27 downto 0) -- Serial outputs for each channel
    );

    -- OPTION 1: the entity is never dissolved 
    attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of ipbus_wrapper_ePortRxDriver: entity is "YES";

end ipbus_wrapper_ePortRxDriver;

architecture rtl of ipbus_wrapper_ePortRxDriver is

    -- The register file signals
    subtype REG is std_logic_vector (31 downto 0);
    type REG_FILE is array (0 to 126) of REG;

	signal sel              : std_logic_vector (ADDR_WIDTH-1    downto 0) := (others => '0');
	signal eprxdrv_reg_file : REG_FILE;
	signal ack              : std_logic;

    -- Internal connection signals
    signal pllLock      : std_logic;
    signal dllLock      : std_logic;
    signal userData     : std_logic_vector(16*32*7-1 downto 0);
    signal dataRateMode : std_logic_vector(20 downto 0);
    signal outputDelay  : std_logic_vector (139 downto 0); -- (28 channels * 5 bits = 140 bits)
    signal prbsSeed     : std_logic_vector (223 downto 0); -- 32bits * 7 groups.
    signal dataSource   : std_logic_vector (13 downto 0);  -- from 0 to 3 {PRBS, RNG, CONST_PATT, USERDATA} (2bits X 7 groups = 14 bits)
    signal prbsTypeMode : std_logic_vector (13 downto 0);  -- from o to 3 {7,15,23,31} (2 X 7 groups = 14 bits}
    signal sameSeed     : std_logic_vector (6 downto 0);   -- Decide if channels of the same given group use the same initializaiton seed
begin

    -- Selects the address on where to write
    sel       <= ipbus_in.ipb_addr(ADDR_WIDTH-1 downto 0);

    -- Reads/Writes to/from the IPBus bus to the registers
	process(clkIPBus)
	begin
		if rising_edge(clkIPBus) then
		    if ipbus_in.ipb_strobe='1' and ipbus_in.ipb_write='1' then
		        if sel /= B"00111" then
			        eprxdrv_reg_file(to_integer(unsigned(sel)))(31 downto 0) <= ipbus_in.ipb_wdata(31 downto 0); -- Write to GPIO_OUT
			    end if;
            else
                eprxdrv_reg_file(7)(31 downto 0) <= (29 downto 0 => '0') & dllLock & pllLock;
			end if;
	        ipbus_out.ipb_rdata(31 downto 0) <= eprxdrv_reg_file(to_integer(unsigned(sel)))(31 downto 0);
			ack <= ipbus_in.ipb_strobe and not ack;	
		end if;
	end process;
	
	ipbus_out.ipb_ack <= ack;
	ipbus_out.ipb_err <= '0';

    -- TODO: Assigns the outputs to the corresponding position of the register file. The assignement/read is clock synchronous
    --eprxdrv_reg_file(7)(31 downto 0) <= (29 downto 0 => '0') & dllLock & pllLock;
   
    -- G0
    userData(511 downto 0) <= eprxdrv_reg_file(15)(31 downto 0) & eprxdrv_reg_file(16)(31 downto 0) & eprxdrv_reg_file(17)(31 downto 0) & eprxdrv_reg_file(18)(31 downto 0) &
                              eprxdrv_reg_file(19)(31 downto 0) & eprxdrv_reg_file(20)(31 downto 0) & eprxdrv_reg_file(21)(31 downto 0) & eprxdrv_reg_file(22)(31 downto 0) &
                              eprxdrv_reg_file(23)(31 downto 0) & eprxdrv_reg_file(24)(31 downto 0) & eprxdrv_reg_file(25)(31 downto 0) & eprxdrv_reg_file(26)(31 downto 0) &
                              eprxdrv_reg_file(27)(31 downto 0) & eprxdrv_reg_file(28)(31 downto 0) & eprxdrv_reg_file(29)(31 downto 0) & eprxdrv_reg_file(30)(31 downto 0);
    -- G1
    userData(1023 downto 512) <= eprxdrv_reg_file(31)(31 downto 0) & eprxdrv_reg_file(32)(31 downto 0) & eprxdrv_reg_file(33)(31 downto 0) & eprxdrv_reg_file(34)(31 downto 0) &
                                eprxdrv_reg_file(35)(31 downto 0) & eprxdrv_reg_file(36)(31 downto 0) & eprxdrv_reg_file(37)(31 downto 0) & eprxdrv_reg_file(38)(31 downto 0) &
                                eprxdrv_reg_file(39)(31 downto 0) & eprxdrv_reg_file(40)(31 downto 0) & eprxdrv_reg_file(41)(31 downto 0) & eprxdrv_reg_file(42)(31 downto 0) &
                                eprxdrv_reg_file(43)(31 downto 0) & eprxdrv_reg_file(44)(31 downto 0) & eprxdrv_reg_file(45)(31 downto 0) & eprxdrv_reg_file(46)(31 downto 0);
    -- G2
    userData(1535 downto 1024) <= eprxdrv_reg_file(47)(31 downto 0) & eprxdrv_reg_file(48)(31 downto 0) & eprxdrv_reg_file(49)(31 downto 0) & eprxdrv_reg_file(50)(31 downto 0) &
                                eprxdrv_reg_file(51)(31 downto 0) & eprxdrv_reg_file(52)(31 downto 0) & eprxdrv_reg_file(53)(31 downto 0) & eprxdrv_reg_file(54)(31 downto 0) &
                                eprxdrv_reg_file(55)(31 downto 0) & eprxdrv_reg_file(56)(31 downto 0) & eprxdrv_reg_file(57)(31 downto 0) & eprxdrv_reg_file(58)(31 downto 0) &
                                eprxdrv_reg_file(59)(31 downto 0) & eprxdrv_reg_file(60)(31 downto 0) & eprxdrv_reg_file(61)(31 downto 0) & eprxdrv_reg_file(62)(31 downto 0);
    -- G3
    userData(2047 downto 1536) <= eprxdrv_reg_file(63)(31 downto 0) & eprxdrv_reg_file(64)(31 downto 0) & eprxdrv_reg_file(65)(31 downto 0) & eprxdrv_reg_file(66)(31 downto 0) &
                                eprxdrv_reg_file(67)(31 downto 0) & eprxdrv_reg_file(68)(31 downto 0) & eprxdrv_reg_file(69)(31 downto 0) & eprxdrv_reg_file(70)(31 downto 0) &
                                eprxdrv_reg_file(71)(31 downto 0) & eprxdrv_reg_file(72)(31 downto 0) & eprxdrv_reg_file(73)(31 downto 0) & eprxdrv_reg_file(74)(31 downto 0) &
                                eprxdrv_reg_file(75)(31 downto 0) & eprxdrv_reg_file(76)(31 downto 0) & eprxdrv_reg_file(77)(31 downto 0) & eprxdrv_reg_file(78)(31 downto 0);
    -- G4
    userData(2559 downto 2048) <= eprxdrv_reg_file(79)(31 downto 0) & eprxdrv_reg_file(80)(31 downto 0) & eprxdrv_reg_file(81)(31 downto 0) & eprxdrv_reg_file(82)(31 downto 0) &
                                 eprxdrv_reg_file(83)(31 downto 0) & eprxdrv_reg_file(84)(31 downto 0) & eprxdrv_reg_file(85)(31 downto 0) & eprxdrv_reg_file(86)(31 downto 0) &
                                 eprxdrv_reg_file(87)(31 downto 0) & eprxdrv_reg_file(88)(31 downto 0) & eprxdrv_reg_file(89)(31 downto 0) & eprxdrv_reg_file(90)(31 downto 0) &
                                 eprxdrv_reg_file(91)(31 downto 0) & eprxdrv_reg_file(92)(31 downto 0) & eprxdrv_reg_file(93)(31 downto 0) & eprxdrv_reg_file(94)(31 downto 0);
    -- G5
    userData(3071 downto 2560) <= eprxdrv_reg_file(95)(31 downto 0)  & eprxdrv_reg_file(96)(31 downto 0)  & eprxdrv_reg_file(97)(31 downto 0)  & eprxdrv_reg_file(98)(31 downto 0) &
                                  eprxdrv_reg_file(99)(31 downto 0)  & eprxdrv_reg_file(100)(31 downto 0) & eprxdrv_reg_file(101)(31 downto 0) & eprxdrv_reg_file(102)(31 downto 0) &
                                  eprxdrv_reg_file(103)(31 downto 0) & eprxdrv_reg_file(104)(31 downto 0) & eprxdrv_reg_file(105)(31 downto 0) & eprxdrv_reg_file(106)(31 downto 0) &
                                  eprxdrv_reg_file(107)(31 downto 0) & eprxdrv_reg_file(108)(31 downto 0) & eprxdrv_reg_file(109)(31 downto 0) & eprxdrv_reg_file(110)(31 downto 0);
    -- G6
    userData(3583 downto 3072) <= eprxdrv_reg_file(111)(31 downto 0) & eprxdrv_reg_file(112)(31 downto 0) & eprxdrv_reg_file(113)(31 downto 0) & eprxdrv_reg_file(114)(31 downto 0) &
                                  eprxdrv_reg_file(115)(31 downto 0) & eprxdrv_reg_file(116)(31 downto 0) & eprxdrv_reg_file(117)(31 downto 0) & eprxdrv_reg_file(118)(31 downto 0) &
                                  eprxdrv_reg_file(119)(31 downto 0) & eprxdrv_reg_file(120)(31 downto 0) & eprxdrv_reg_file(121)(31 downto 0) & eprxdrv_reg_file(122)(31 downto 0) &
                                  eprxdrv_reg_file(123)(31 downto 0) & eprxdrv_reg_file(124)(31 downto 0) & eprxdrv_reg_file(125)(31 downto 0) & eprxdrv_reg_file(126)(31 downto 0);

    dataRateMode <= eprxdrv_reg_file(6)(2 downto 0) & eprxdrv_reg_file(5)(2 downto 0) & eprxdrv_reg_file(4)(2 downto 0) 
                  & eprxdrv_reg_file(3)(2 downto 0) & eprxdrv_reg_file(2)(2 downto 0) & eprxdrv_reg_file(1)(2 downto 0) & eprxdrv_reg_file(0)(2 downto 0); 

    prbsTypeMode <= eprxdrv_reg_file(6)(26 downto 25) & eprxdrv_reg_file(5)(26 downto 25) & eprxdrv_reg_file(4)(26 downto 25) 
                  & eprxdrv_reg_file(3)(26 downto 25) & eprxdrv_reg_file(2)(26 downto 25) & eprxdrv_reg_file(1)(26 downto 25) & eprxdrv_reg_file(0)(26 downto 25); 

    dataSource   <= eprxdrv_reg_file(6)(4 downto 3) & eprxdrv_reg_file(5)(4 downto 3) & eprxdrv_reg_file(4)(4 downto 3) 
                  & eprxdrv_reg_file(3)(4 downto 3) & eprxdrv_reg_file(2)(4 downto 3) & eprxdrv_reg_file(1)(4 downto 3) & eprxdrv_reg_file(0)(4 downto 3); 

    sameSeed     <= eprxdrv_reg_file(6)(27) & eprxdrv_reg_file(5)(27) & eprxdrv_reg_file(4)(27) & eprxdrv_reg_file(3)(27) & eprxdrv_reg_file(2)(27) & eprxdrv_reg_file(1)(27) & eprxdrv_reg_file(0)(27);

    outputDelay  <= eprxdrv_reg_file(6)(24 downto 20) & eprxdrv_reg_file(6)(19 downto 15) & eprxdrv_reg_file(6)(14 downto 10) & eprxdrv_reg_file(6)(9 downto 5) &
                    eprxdrv_reg_file(5)(24 downto 20) & eprxdrv_reg_file(5)(19 downto 15) & eprxdrv_reg_file(5)(14 downto 10) & eprxdrv_reg_file(5)(9 downto 5) &
                    eprxdrv_reg_file(4)(24 downto 20) & eprxdrv_reg_file(4)(19 downto 15) & eprxdrv_reg_file(4)(14 downto 10) & eprxdrv_reg_file(4)(9 downto 5) &
                    eprxdrv_reg_file(3)(24 downto 20) & eprxdrv_reg_file(3)(19 downto 15) & eprxdrv_reg_file(3)(14 downto 10) & eprxdrv_reg_file(3)(9 downto 5) &
                    eprxdrv_reg_file(2)(24 downto 20) & eprxdrv_reg_file(2)(19 downto 15) & eprxdrv_reg_file(2)(14 downto 10) & eprxdrv_reg_file(2)(9 downto 5) &
                    eprxdrv_reg_file(1)(24 downto 20) & eprxdrv_reg_file(1)(19 downto 15) & eprxdrv_reg_file(1)(14 downto 10) & eprxdrv_reg_file(1)(9 downto 5) &
                    eprxdrv_reg_file(0)(24 downto 20) & eprxdrv_reg_file(0)(19 downto 15) & eprxdrv_reg_file(0)(14 downto 10) & eprxdrv_reg_file(0)(9 downto 5);

    prbsSeed <= eprxdrv_reg_file(6)(31 downto 0) & eprxdrv_reg_file(5)(31 downto 0) & eprxdrv_reg_file(4)(31 downto 0) & eprxdrv_reg_file(3)(31 downto 0) & 
                eprxdrv_reg_file(2)(31 downto 0) & eprxdrv_reg_file(1)(31 downto 0) & eprxdrv_reg_file(0)(31 downto 0);

    ePortRxDriver_inst : entity work.ePortRxDriver(rtl)
        port map (
            userData     => userData,
            dataRateMode => dataRateMode,
            dataSource   => dataSource,
            prbsTypeMode => prbsTypeMode,
            outputDelay  => outputDelay,
            sameSeed     => sameSeed,
            prbsSeed     => prbsSeed,
            clk40MHzIn   => clk40MHzIn,
            pllLock      => pllLock,
            dllLock      => dllLock,
            channel      => channel
        );

end rtl;
