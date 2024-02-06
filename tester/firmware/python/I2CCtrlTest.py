#!/usr/bin/python

########################################################################################################################
#                                                                                                                      #
#                                                                                                                      #
#    A small template to show how can one control an IPBus slave through python                                        #
#    This script supposes that you set the PYTHONPATH appropriately and that the IPBus py modules are pointed by it    #
#                                                                                                                      #     
#                                                                                                                      #  
#    Jose Pedro Castro Fonseca, CERN, July 2018                                                                        # 
#    Daniel Hernandez, CERN, February 2018                                                                             #
#                                                                                                                      # 
#                                                                                                                      #
########################################################################################################################

import os
import time
import sys


# We import the IPBus control library
import PyChipsUser as ipbus

# Reading the target IP address from a file and the address table
vc707AddrTable = ipbus.AddressTable('../ipbus_slave_addr_table.cfg')
fid_ipaddr = open('../target_ip_addr.cfg', 'r')
target_ipaddr = fid_ipaddr.readline()
fid_ipaddr.close()

# Creating the target object
vc707 = ipbus.ChipsBusUdp(vc707AddrTable, target_ipaddr, 50001);


#________________________I2C IPBus Registers description_________________________________________________________# 

# I2C Data input register.
# Only readable register.
# [7:0] Last byte received via I2C.

#********************************************************************
#data_i = vc707.read("data_i")
#print "[info]: Data input ->", uInt32HexStr(data_i)
#********************************************************************


# Status register.
# Only readable register.
# 7th bit = ACK Flag, '0' ACK received, '1' No ACK received.
# 6th bit = I2C busy, '1' Busy, '0' Not busy.
# 5th bit = Arbitration lost, '1' lost, '0' not lost.
# [4:2] = RESERVED.
# 1st bit = Transfer in Progress, '1' transfering data, '0' transfer complete.
# 0th bit = Interrupt Flag, '1' IF, '0' no IF.

#********************************************************************
#status = vc707.read("status")
#print "[info]: Status ->", uInt32HexStr(status)
#********************************************************************


# Transmit register.
# Writable register only.
# [7:1] Next byte to transmit via I2C.
# [0] = '0' Writing to slave, '1' Reading from slave.

#********************************************************************
#vc707.write("data_o", 0x000000A0)
#data_o = vc707.read("data_o")
#print "[info]: Data output ->", uInt32HexStr(data_o)
#********************************************************************


# Command register.
# Writable register only.
# 7th bit = STA, Start condition.
# 6th bit = STO, Stop condition.
# 5th bit = RD, Read from Slave.
# 4th bit = WR, Write to slave
# 3th bit = ACK, when '0', ack = sent, when '1', not ack.
# [2:1] = RESERVED
# 0th bit = IACK, Interrupt acknowledge. '1' clears a pending interrupt.

# # Control register.
# # 7th bit = '1' I2C Core enabled, '0' I2C core disabled.
# # 6th bit = '1' I2C interrup enabled, '0' I2C interrup disabled.
# # ctrl = 0x80 => I2C core enabled, I2C interrupt disabled.

# Prescale register => ps, Put a SCL frequency.
#ps = [(32 MHz / (5 * freq_scl)) - 1], if freq_scl = 100 kHz, ps = 3F.
#________________________________________________________________________________________________________________#

print "******Enabling I2C & Clock frequency of 100 kHz******"

ctrl_i2c = vc707.read("ctrl_i2c_LPGBT")
print "[i2c info]: ctrl_i2c_LPGBT ->", ipbus.uInt32HexStr(ctrl_i2c)

vc707.write("ctrl_i2c_LPGBT", 0x80)

ctrl_i2c = vc707.read("ctrl_i2c_LPGBT")
print "\n\n[i2c info]: ctrl_i2c_LPGBT ->", ipbus.uInt32HexStr(ctrl_i2c)
#********************************************************************


# Prescale register => ps, Put a SCL frequency.
#ps = [(32 MHz / (5 * freq_scl)) - 1], if freq_scl = 100 kHz, ps = 3F.

#********************************************************************
ps_lo = vc707.read("ps_lo_LPGBT")
print "[i2c info]: ps_lo_LPGBT ->", ipbus.uInt32HexStr(ps_lo)

vc707.write("ps_lo_LPGBT", 0x3F)

ps_lo = vc707.read("ps_lo_LPGBT")
print "[i2c info]: ps_lo_LPGBT ->", ipbus.uInt32HexStr(ps_lo)


ps_hi = vc707.read("ps_hi_LPGBT")
print "[i2c info]: ps_hi_LPGBT ->", ipbus.uInt32HexStr(ps_hi)

vc707.write("ps_hi_LPGBT", 0x0)

ps_hi = vc707.read("ps_hi_LPGBT")
print "[i2c info]: ps_hi_LPGBT ->", ipbus.uInt32HexStr(ps_hi), "\n"

time.sleep (0.1)

# Transmit register (Address + W = '0')
vc707.write("data_LPGBT", 0xC9)

# Command register (STA & WR = '1')
vc707.write("cmd_LPGBT", 0x90)
vc707.write("cmd_LPGBT", 0x90)

# Status register (ACK = '0'?)
cmd = vc707.read("cmd_LPGBT")

if(cmd & 0x80):
	print "[Error]: Communication error: ", ipbus.uInt32HexStr(cmd)
else:
    print "CMD Reply: ", ipbus.uInt32HexStr(cmd)

