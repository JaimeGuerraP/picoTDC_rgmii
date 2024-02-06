# Copied from https://gitlab.cern.ch/lpgbt/lpgbt_tester/-/blob/master/firmware/Makefile
# 2021.11.25 DPo
 
TESTER_RTL_DIR=components/picotdc-tester/rtl
help:
	@echo "Targets:"
	@echo "  dynamic_vhdl                                       - generates dynamic VHDL files"
	@echo "  init                                               - inits top FPGA project"
	@echo "  compile                                            - compiles top FPGA project"
	@echo "  implement                                          - implements top FPGA project"
	@echo "  program                                            - programs the FPGA"
	@echo "  flash                                              - programs the FPGA flash"


# due to limitation of  gen_ipbus_addr_decode script, we can not specify the output file name
# we generate the file in place and we move the file where we want it to be
${TESTER_RTL_DIR}/ipbus_decode_picotdc_tester.vhd: ../common/picotdc_tester.xml
	./scripts/gen_ipbus_addr_decode  \
	-t  scripts/ipbus_addr_decode.vhd.tmpl \
	../common/picotdc_tester.xml
	mv ipbus_decode_picotdc_tester.vhd $@

${TESTER_RTL_DIR}/versionregs.vhd:
	@scripts/gen_versionregs.py  $@

dynamic_vhdl: ${TESTER_RTL_DIR}/ipbus_decode_picotdc_tester.vhd ${TESTER_RTL_DIR}/versionregs.vhd

#work/fpga-picotdc_fpga_tester/picotdc_fpga_tester.xpr : dynamic_vhdl
#	rm -rf work
#	./makeit.py picotdc_fpga_tester-fpga-init

#init: work/fpga-picotdc_fpga_tester/picotdc_fpga_tester.xpr

init : dynamic_vhdl
	./makeit.py picotdc_fpga_tester-fpga-init

compile:
	./makeit.py picotdc_fpga_tester-fpga-compile

implement:
	./makeit.py picotdc_fpga_tester-fpga-implement

program:
	./makeit.py picotdc_fpga_tester-fpga-program

flash:
	./makeit.py lpgbt_fpga_tester-fpga-flash


clean:
	@rm -rf work
	@rm -rf .Xil/
	@rm -rf vivado*
	@rm -rf ${TESTER_RTL_DIR}/ipbus_decode_picotdc_tester.vhd
	@rm -rf ${TESTER_RTL_DIR}/versionregs.vhd

.PHONY: init compile implement program clean rtl/picotdc-tester/rtl/versionregs.vhd
