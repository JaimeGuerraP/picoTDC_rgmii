#!/usr/bin/python

########################################################################################################################
#                                                                                                                      #
#                                                                                                                      #
#    A small template to show how can one control an IPBus slave through python                                        #
#    This script supposes that you set the PYTHONPATH appropriately and that the IPBus py modules are pointed by it    #
#                                                                                                                      #     
#                                                                                                                      #  
#    Jose Pedro Castro Fonseca, CERN, July 2018                                                                        # 
#                                                                                                                      # 
#                                                                                                                      #
########################################################################################################################

import os
import time
import sys


# We import the IPBus control library
import PyChipsUser as ipbus

# Reading the target IP address from a file and the address table
vc707AddrTable = ipbus.AddressTable('../ipbus_slave_reg_table.cfg')
fid_ipaddr = open('../target_ip_addr.cfg', 'r')
target_ipaddr = fid_ipaddr.readline()
fid_ipaddr.close()

# Creating the target object
vc707 = ipbus.ChipsBusUdp(vc707AddrTable, target_ipaddr, 50001);

#________________________ ePortRxDriver Registers description_____________________________________________________# 

# See ePortRxDriver_registermap.ods
#________________________________________________________________________________________________________________#

time.sleep(0.5)

vc707.write("CONFIGG0",   0x08418820)
vc707.write("PRBSSEEDG0", 0xA75C3595)



read_reg = vc707.read("PLLDLLSTATUS");
print "Read from PLLDLLSTATUS: ", ipbus.uInt32HexStr(read_reg);

