#!/usr/bin/env python3

# Copyright (c) 2014 Szymon Kulis <szymon.kulis@cern.ch> CERN.
# All rights reserved.
#
# You may redistribute and modify this project under the terms of the
# CERN OHL v.1.2. (http://ohwr.org/cernohl). This project is distributed
# WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY,
# SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE. 
# Please see the CERN OHL v.1.2 for applicable conditions.
#
# Version history:
#   19/10/2018 Szymon Kulis : Modified for lpGBTTester to get git hash (instead of SVN rev)
#   2021.11.19 DPo : changed to py3

import sys
from optparse import OptionParser
import time
import getpass
import socket
import subprocess

def get_time():
    return list(map(int,time.strftime("%H %M %S", time.localtime()).split()))

def get_date():
    return list(map(int,time.strftime("%Y %m %d", time.localtime()).split()))

def get_user_name():
    return getpass.getuser()

def get_host_name():
    return socket.gethostname()


def str2hex(s,lenght=4):
  o=""
  for i in range(lenght):
    char=0
    if i<len(s): 
      char=ord(s[i])
    o+='%02X'%(char)
  return o

def githash():
    p = subprocess.Popen("git rev-parse HEAD", shell=True, \
       stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = p.communicate()
    return stdout.rstrip().decode("ascii")

def svnversion():
    p = subprocess.Popen("svnversion", shell=True, \
       stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = p.communicate()
    return stdout.rstrip().decode("ascii")
  
verilog_template='''
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
        -- fw : {fw_str}
        when x"0"   => ipbus_out.ipb_rdata <= x"{fw0}";
        when x"1"   => ipbus_out.ipb_rdata <= x"{fw1}";
        -- rev : {rev_str}
        when x"2"   => ipbus_out.ipb_rdata <= x"{rev}";
        -- user : {user_str}
        when x"3"   => ipbus_out.ipb_rdata <= x"{user0}";
        when x"4"   => ipbus_out.ipb_rdata <= x"{user1}";
        when x"5"   => ipbus_out.ipb_rdata <= x"{user2}";
        -- host : {host_str}
        when x"6"   => ipbus_out.ipb_rdata <= x"{host0}";
        when x"7"   => ipbus_out.ipb_rdata <= x"{host1}";
        when x"8"   => ipbus_out.ipb_rdata <= x"{host2}";
        -- date : {date_str}
        when x"9"   => ipbus_out.ipb_rdata <= x"{date}";
        -- time : {time_str}
        when x"A"   => ipbus_out.ipb_rdata <= x"{time}";
        -- git : {git_str}
        when x"B"   => ipbus_out.ipb_rdata <= x"{git0}";
        when x"C"   => ipbus_out.ipb_rdata <= x"{git1}";
        when x"D"   => ipbus_out.ipb_rdata <= x"{git2}";
        when x"E"   => ipbus_out.ipb_rdata <= x"{git3}";
        when x"F"   => ipbus_out.ipb_rdata <= x"{git4}";
        when others => ipbus_out.ipb_rdata <= x"00000000";
      end case;

      ack <= ipbus_in.ipb_strobe and not ack;
    end if;
  end process;

  ipbus_out.ipb_ack <= ack;
  ipbus_out.ipb_err <= '0';

end rtl;

'''


def main():
    parser = OptionParser(usage="usage: %prog [options] output_file")
    parser.add_option("-v", "--verbose", action="store_true", dest="verbose", default=False, help="make lots of noise")
    (options, args) = parser.parse_args()
    if len(args)==0:
        print("You have to provide output file name!")
        return
    print("Generating versionregs")

    fw_str="lpGBT"
    rev=[0,1,0]
    time=get_time()
    date=get_date()
    user=get_user_name()
    host=get_host_name()
    git_hash=githash()
    print("  Firmware : %s"%(fw_str))
    rev_str="%d.%d.%d"%(rev[0],rev[1],rev[2])
    print("  Version  : %s"%rev_str)
    print("  Host     : %s"%(host))
    date_str="%d/%d/%d"%(date[0],date[1],date[2])
    print("  Date     : %s"%(date_str))
    time_str="%d/%d/%d"%(time[0],time[1],time[2])
    print("  Time     : %s"%(time_str))
    print("  GIT      : %s"%(git_hash))
    values = {'fw_str':fw_str,'fw0': str2hex(fw_str[:4]), 'fw1': str2hex(fw_str[4:8]),
              'rev_str':rev_str, 'rev':"00%02X%02X%02X"%(rev[0],rev[1],rev[2]),
              'user_str':user[0:12],'user0': str2hex(user[:4]), 'user1': str2hex(user[4:8]),'user2': str2hex(user[8:12]),
              'host_str':host[0:12],'host0': str2hex(host[:4]), 'host1': str2hex(host[4:8]),'host2': str2hex(host[8:12]),
              'date_str':date_str,'date':"%04X%02X%02X"%(date[0],date[1],date[2]),
              'time_str':time_str,'time':"00%02X%02X%02X"%(time[0],time[1],time[2]),
              'git_str':git_hash,'git0': git_hash[:8], 'git1': git_hash[8:16],'git2': git_hash[16:24],'git3': git_hash[24:32],'git4': git_hash[32:40],
             }

    fname=args[0]
    print("  Saving data to %s"%fname)
    f=open(fname,"w")
    f.write(verilog_template.format(**values))
    f.close()
    print("  Done.")

if __name__=="__main__":
    main()

