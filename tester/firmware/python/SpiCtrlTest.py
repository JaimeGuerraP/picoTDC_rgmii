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

#________________________SPI IPBus Registers description_________________________________________________________# 


# Control register

# 13th bit = ASS, Automatic SS control.
# 12th bit = IE, Interrupt enabled after transfer.
# 11th bit = LSB, LSB to MSB data transfer when '1'.
# 10th bit = Tx_NEG, if '1', changes on the falling edge of Tx data.
# 9th bit = Rx_NEG, if '1', changes on the rising edge of Rx data.
# 8th bit = GO_BSY, starts the transfer when set.
# 7th bit = RESERVED
# [6:0] = CHAR_LEN, how many bits are transmitted in one transfer.


# Divider register

# [31:16] = RESERVED
# [15:0] = Div
# Fsclk = 32MHz/(Div+1)*2
# If Div = 0b111 then Fsclk = 1 MHz


# Slave Select register

# [31:16] = RESERVED
# [15:0] = SS

#________________________________________________________________________________________________________________#

ASS   = 0x0
IE    = 0x0
LSB   = 0x0
CPOL  = 0x2
GO    = 0x1
CHARL = 8

ctrl_spi_pl = ((ASS << 13) | (IE << 12) | (LSB << 11) | (CPOL << 9) | (GO<<8) | (CHARL & 0x7F))

ctrl_spi = vc707.read("ctrl_spi")
print "[spi info]: ctrl_spi ->", ipbus.uInt32HexStr(ctrl_spi)

vc707.write("ctrl_spi", 0x00002814)

ctrl_spi = vc707.read("ctrl_spi")
print "[spi info]: ctrl_spi ->", ipbus.uInt32HexStr(ctrl_spi)


divider = vc707.read("divider")
print "[spi info]: divider ->", ipbus.uInt32HexStr(divider)

vc707.write("divider", 0x000000FF)

divider = vc707.read("divider")
print "[spi info]: divider ->", ipbus.uInt32HexStr(divider)


ss = vc707.read("ss")
print "[spi info]: ss ->", ipbus.uInt32HexStr(ss)

vc707.write("ss", 0x00000010)

ss = vc707.read("ss")
print "[spi info]: ss ->", ipbus.uInt32HexStr(ss)

#Data to write
vc707.write("d0", 0x7A)
vc707.write("d1", 0x12390A6F)
vc707.write("d2", 0x83462192)
vc707.write("d3", 0x19346342)

#Go SPI
vc707.write("ctrl_spi", ((ASS << 13) | (IE << 12) | (LSB << 11) | (CPOL << 9) | (0<<8) | (CHARL & 0x7F)))
vc707.write("ctrl_spi", ((ASS << 13) | (IE << 12) | (LSB << 11) | (CPOL << 9) | (1<<8) | (CHARL & 0x7F)))

print "[spi info]: First 24 bits written"

time.sleep(2)




