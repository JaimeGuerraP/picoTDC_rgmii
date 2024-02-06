#!/bin/bash


# pass on errors to the script above
set -e 

# Initializes submodules
git submodule init
git submodule update

# generate dynamic VHDL files
make dynamic_vhdl

# Source xilinx env
source /opt/Xilinx/Vivado/2018.2/settings64.sh

# Generate bitstream
./makeit.py lpgbt_fpga_tester-fpga-init
./makeit.py lpgbt_fpga_tester-fpga-compile
./makeit.py lpgbt_fpga_tester-fpga-implement


