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


# We import the IPBus control library
import PyChipsUser as ipbus

# Reading the target IP address from a file and the address table
vc707AddrTable = ipbus.AddressTable('../ipbus_slave_reg_table.cfg')
fid_ipaddr = open('../target_ip_addr.cfg', 'r')
target_ipaddr = fid_ipaddr.readline()
fid_ipaddr.close()

# Creating the target object
vc707 = ipbus.ChipsBusUdp(vc707AddrTable, target_ipaddr, 50001);

# Writing some initial values to the leds
vc707.write("led2", 0x0)
vc707.write("led3", 0x0)
vc707.write("led4", 0x1)
vc707.write("led5", 0x0)
vc707.write("led6", 0x0)
vc707.write("led7", 0x1)





