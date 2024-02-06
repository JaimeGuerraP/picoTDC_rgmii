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

#________________________GPIO IPBus Registers description_________________________________________________________# 


# GPIO_IN:  16bit register that maps what is seen at the output buffer (outside world -> FPGA fabric)
# GPIO_OUT: 16bit register that stores what is to be written to the output buffer (FPGA fabric -> outside world)
# GPIO_DIR: 16bit register that stores what is the direction of each pin (1 -> input, 0 -> output (FPGA to outside world))

#________________________________________________________________________________________________________________#

vc707.write("GPIO_DIR", 0x00000000)
prbs7 = "1000001100001010001111001000101100111010100111110100001110001001001101101011011110110001101001011101110011001010101111111000000"

i=0;

# This Generates a PRBS7 Sequence @100kHz on pin 0-3 (delayed) and and a 50kHz clock on pin 7, and a constant pattern
# 0x1010_1011 on pins 15:8.
while(i < 127):
    vc707.write("GPIO_OUT", 0x0000AB00 | (0x00000001 & int(prbs7[i%127])) | (0x00000001 & int(prbs7[(i+1) %127])) << 1 | (0x00000001 & int(prbs7[(i+2) %127])) << 2 | (0x00000001 & (i%2)) << 7);    
    time.sleep(0.00001);
    i += 1;

read_reg = vc707.read("GPIO_IN");
print "Read from GPIO_IN: ", ipbus.uInt32HexStr(read_reg);

read_reg = vc707.read("GPIO_OUT");
print "Read from GPIO_OUT: ", ipbus.uInt32HexStr(read_reg);

read_reg = vc707.read("GPIO_DIR");
print "Read from GPIO_DIR: ", ipbus.uInt32HexStr(read_reg);
