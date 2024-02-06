
-- THIS SCRIPT HAS BEEN GENERATED AUTOMATICLY BY gen_vesrsionregs.py SCRIPT
--                    (DO NOT EDIT IT MANUALY!)
--
--
-- Copyright (c) 2014 Szymon Kulis <szymon.kulis@cern.ch> CERN.
-- All rights reserved.
--
-- You may redistribute and modify this project under the terms of the
-- CERN OHL v.1.2. (http://ohwr.org/cernohl). This project is distributed
-- WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY,
-- SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE. 
-- Please see the CERN OHL v.1.2 for applicable conditions.
-- 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;

entity versionregs is
  port(
    clk: in std_logic;
    reset: in std_logic;
    ipbus_in: in ipb_wbus;
    ipbus_out: out ipb_rbus
  );
end versionregs;

architecture rtl of versionregs is
  signal ack: std_logic;
begin
  --#addr_width_max <= ctrl_addr_width when ctrl_addr_width > stat_addr_width else stat_addr_width;
  process(clk)
  begin
    if rising_edge(clk) then
      case ipbus_in.ipb_addr(3 downto 0) is
        -- fw : lpGBT
        when x"0"   => ipbus_out.ipb_rdata <= x"6C704742";
        when x"1"   => ipbus_out.ipb_rdata <= x"54000000";
        -- rev : 0.1.0
        when x"2"   => ipbus_out.ipb_rdata <= x"00000100";
        -- user : dporret
        when x"3"   => ipbus_out.ipb_rdata <= x"64706F72";
        when x"4"   => ipbus_out.ipb_rdata <= x"72657400";
        when x"5"   => ipbus_out.ipb_rdata <= x"00000000";
        -- host : pcepese17
        when x"6"   => ipbus_out.ipb_rdata <= x"70636570";
        when x"7"   => ipbus_out.ipb_rdata <= x"65736531";
        when x"8"   => ipbus_out.ipb_rdata <= x"37000000";
        -- date : 2021/11/29
        when x"9"   => ipbus_out.ipb_rdata <= x"07E50B1D";
        -- time : 10/1/11
        when x"A"   => ipbus_out.ipb_rdata <= x"000A010B";
        -- git : c8620664f08d9f4de7b8beac9fc9f6c59362b3dc
        when x"B"   => ipbus_out.ipb_rdata <= x"c8620664";
        when x"C"   => ipbus_out.ipb_rdata <= x"f08d9f4d";
        when x"D"   => ipbus_out.ipb_rdata <= x"e7b8beac";
        when x"E"   => ipbus_out.ipb_rdata <= x"9fc9f6c5";
        when x"F"   => ipbus_out.ipb_rdata <= x"9362b3dc";
        when others => ipbus_out.ipb_rdata <= x"00000000";
      end case;

      ack <= ipbus_in.ipb_strobe and not ack;
    end if;
  end process;

  ipbus_out.ipb_ack <= ack;
  ipbus_out.ipb_err <= '0';

end rtl;

