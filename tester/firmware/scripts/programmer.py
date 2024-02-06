#!/usr/bin/env python3
###############################################################################
#                                                                             #
#        _        _____ ____ _______     _            _                       #
#       | |      / ____|  _ \__   __|   | |          | |                      #
#       | |_ __ | |  __| |_) | | |______| |_ ___  ___| |_ ___ _ __            #
#       | | '_ \| | |_ |  _ <  | |______| __/ _ \/ __| __/ _ \ '__|           #
#       | | |_) | |__| | |_) | | |      | ||  __/\__ \ ||  __/ |              #
#       |_| .__/ \_____|____/  |_|       \__\___||___/\__\___|_|              #
#         | |                                                                 #
#         |_|                                                                 #
#                                                                             #
#  Copyright (C) 2018 lpGBT Team, CERN                                        #
#                                                                             #
#  This IP block is free for HEP experiments and other scientific research    #
#  purposes. Commercial exploitation of a chip containing the IP is not       #
#  permitted.  You can not redistribute the IP without written permission     #
#  from the authors. Any modifications of the IP have to be communicated back #
#  to the authors. The use of the IP should be acknowledged in publications,  #
#  public presentations, user manual, and other documents.                    #
#                                                                             #
#  This IP is distributed in the hope that it will be useful, but WITHOUT ANY #
#  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  #
#  FOR A PARTICULAR PURPOSE.                                                  #
#                                                                             #
###############################################################################
#
# Requirements:
#  1) Access gitlab repository
#     - Gitlab package for python3
#     - You need to generate private token:
#       *  Log in to your GitLab account
#       *  Go to your Profile settings
#       *  Go to Access tokens
#       *  Choose a name and optionally an expiry date for the token
#       *  Choose the **api** in the scopes sectio
#       *  Click on Create personal access token.
#       *  Save the personal access token somewhere safe. Once you leave or
#          refresh the page, you won't be able to access it again.
#     - Export your token as an enviromental variable:
#       $ export CI_PRIVATE_TOKEN=YOUR_TOKEN_HERE
#       Or better put it in your `.bashrc`.
#
#  2) Download to FPGA SRAM
#     Digilent Adept 2 Runtime and Utilities
#     https://store.digilentinc.com/digilent-adept-2-download-only/
#
#  3) Download to BPI Flash
#     Vivado from https://www.xilinx.com/products/design-tools/vivado.html
#


# 2021.11.25 DPo Change path

"""Simple script to program FPGA"""

import optparse
import logging
import os
import tempfile
import sys
import shutil
import zipfile
import traceback
import gitlab

BIT_DIR = os.path.join("/tmp", "picotdc_tester_programmer")
PROJECT_ID = 37640

def run_command(cmd):
    """ Execute command. Returns output code"""
    if cmd == "":
        return
    logging.info("Executing '%s'", cmd)
    exitcode = os.system(cmd)
    exitcode >>= 8
    logging.debug("Exit code %d", exitcode)
    if exitcode:
        logging.error("Dir        : %s", os.getcwd())
        logging.error("Application: %s", cmd)
        logging.error("Exit code  : %s", exitcode)
        sys.exit(exitcode)


def bit_to_mcs(bit, mcs):
    """Convert BIT file to MCS"""

    flash_script = 'write_cfgmem -format mcs -interface bpix16 -size 128 \
                    -loadbit "up 0x0 {bit}" -file {mcs}\n'.format(bit=bit, mcs=mcs)
    file_ = tempfile.NamedTemporaryFile(mode='w', delete=False)
    file_.write(flash_script)
    file_.close()
    run_command("vivado -mode batch -source {}".format(file_.name))


def program_mcs(mcs_file_name):
    """ Program FPGA BPI flash with MCS file"""

    logging.info("Program BPI flash with '%s'", mcs_file_name)
    flash_script = """
open_hw
connect_hw_server
open_hw_target
create_hw_cfgmem -hw_device [lindex [get_hw_devices xc7vx485t_0] 0] [lindex [get_cfgmem_parts {{mt28gu01gaax1e-bpi-x16}}] 0]

set_property PROGRAM.ADDRESS_RANGE  {{use_file}} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7vx485t_0] 0]]
set_property PROGRAM.FILES [list "{mcs}" ] [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7vx485t_0] 0]]
set_property PROGRAM.PRM_FILE {{}} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7vx485t_0] 0]]
set_property PROGRAM.BPI_RS_PINS {{none}} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7vx485t_0] 0]]
set_property PROGRAM.UNUSED_PIN_TERMINATION {{pull-none}} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7vx485t_0] 0]]
set_property PROGRAM.BLANK_CHECK  0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7vx485t_0] 0]]
set_property PROGRAM.ERASE  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7vx485t_0] 0]]
set_property PROGRAM.CFG_PROGRAM  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7vx485t_0] 0]]
set_property PROGRAM.VERIFY  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7vx485t_0] 0]]
set_property PROGRAM.CHECKSUM  0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7vx485t_0] 0]]

if {{![string equal [get_property PROGRAM.HW_CFGMEM_TYPE  [lindex [get_hw_devices xc7vx485t_0] 0]] [get_property MEM_TYPE [get_property CFGMEM_PART [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7vx485t_0] 0]]]]] }}  {{ create_hw_bitstream -hw_device [lindex [get_hw_devices xc7vx485t_0] 0] [get_property PROGRAM.HW_CFGMEM_BITFILE [ lindex [get_hw_devices xc7vx485t_0] 0]]; program_hw_devices [lindex [get_hw_devices xc7vx485t_0] 0]; }}; 

program_hw_cfgmem -hw_cfgmem [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7vx485t_0] 0]]
""".format(mcs=mcs_file_name)
    file_ = tempfile.NamedTemporaryFile(mode='w', delete=False)
    file_.write(flash_script)
    file_.close()
    run_command("vivado -mode batch -source {}".format(file_.name))


def program_bit(bit_file_name):
    """ Download bit file (bit_file_name) to FPGA"""

    logging.info("Program via JTAG with '%s'", bit_file_name)
    program_script = """
open_hw
connect_hw_server
open_hw_target

set_property PROBES.FILE {{}} [get_hw_devices xc7vx485t_0]
set_property FULL_PROBES.FILE {{}} [get_hw_devices xc7vx485t_0]
set_property PROGRAM.FILE {bit} [get_hw_devices xc7vx485t_0]
program_hw_devices [get_hw_devices xc7vx485t_0]
""".format(bit=bit_file_name)
    file_ = tempfile.NamedTemporaryFile(mode='w', delete=False)
    file_.write(program_script)
    file_.close()
    run_command("vivado -mode batch -source {}".format(file_.name))


def download_bit(sha, bit_file_name, mezz_version):
    """Download the bit file (corresponding to the latest job for SHA commit) from
       the repository. Rename output file to bit_file_name.
    """
    def find_last_job(pipelines, stage):
        """Find latest job executed from stage in the pipelines list"""
        for pipeline in pipelines:
            jobs = pipeline.jobs.list()
            for job in jobs:
                if job.stage == stage and job.status == 'success':
                    return job
        return None

    if 'CI_PRIVATE_TOKEN' not in os.environ:
        logging.error("CI_PRIVATE_TOKEN env variable not set!")
        return -1

    glab = gitlab.Gitlab('http://gitlab.cern.ch/', private_token=os.environ['CI_PRIVATE_TOKEN'])
    project = glab.projects.get(PROJECT_ID)
    pipelines = project.pipelines.list(sha=sha)
    if len(pipelines) < 1:
        logging.error("No corresponding pipelines found!")
        return -1
    fw_compile_stage = 'fwTimingCheck'
    last_fw_compilation_job = find_last_job(pipelines, fw_compile_stage)

    # Have we already compiled the firmware?
    if  last_fw_compilation_job is None:
        logging.error("No Fw compilation found")
        return -1

    # Did the previous job succeeded?
    if last_fw_compilation_job.status != 'success':
        logging.error("Last Fw compilation failed but no Fw files were modified!")
        return -2

    logging.info("Last compilation date: %s", last_fw_compilation_job.created_at)
    logging.info("Last compilation Commit: %s", last_fw_compilation_job.commit['id'])

    # Get artifact
    with open('artifacts.zip', "wb") as file_:
        project.jobs.get(last_fw_compilation_job.id, lazy=True).artifacts(streamed=True,
                                                                          action=file_.write)

    bit_file_path = None
    bit_file_paths = []
    with zipfile.ZipFile('artifacts.zip', 'r') as zipfile_:
        names = zipfile_.namelist()
        for name in names:
            if '.bit' in name:
                bit_file_paths.append(name)

        if len(bit_file_paths) == 1:
            if mezz_version != "":
                logging.error("Only one bitfile found, mezzanine version can not be selected.")
                return -1
            logging.warning("Legacy use of lpgbt_tester_programmer detected.")
            logging.warning("Please double-check mezannine version matches SHA, press RETURN to continue, CTRL-C to cancel.")
            input()
            bit_file_path = bit_file_paths[0]  # use the only bitfile available
        elif len(bit_file_paths) == 2 :
            if mezz_version == "":
                logging.error("Mezzanine version not specified, will not program FPGA.")
                return -1
            # select the bitfile corresponding to the selected mezzanine version
            try:
                bit_file_path = [path for path in bit_file_paths if mezz_version in path][0]
            except IndexError:
                bit_file_path = None

        if bit_file_path is None:
            logging.error('Bitfile not found in artifacts.zip')
            return -1

        logging.info("BitFile: %s", bit_file_path)
        logging.info("Storing bit file in : %s", bit_file_name)

        if not os.path.exists(BIT_DIR):
            os.makedirs(BIT_DIR)

        with zipfile_.open(bit_file_path) as zipedfile_, open(bit_file_name, 'wb') as file_:
            shutil.copyfileobj(zipedfile_, file_)
        return 0

def main():
    """ Main function. We parse arguments, download file in necessary and program FPGA"""
    parser = optparse.OptionParser(
        version="lpgbt_tester_programmer", usage="%prog SHA1 || %prog filename")

    parser.add_option("-q", "--quite", dest="quite", action="store_true", default=False,
                      help="Quite output (show only warnings and errors)")
    parser.add_option("-v", "--verbose", dest="verbose", action="count", default=0,
                      help="More verbose output (use: -v, -vv, -vvv..)")
    parser.add_option("-f", "--flash", dest="flash", action="store_true", default=False,
                      help="Flash")
    parser.add_option("-m", "--mezzanine", dest="mezz", type="choice", choices=["", "v12", "prod"], default="",
                      help="Mezzanine version ('v12' or 'prod')")
    try:
        (options, args) = parser.parse_args()

        log_formatter = logging.Formatter('[%(levelname)-7s] %(message)s')
        root_logger = logging.getLogger()
        root_logger.setLevel(logging.DEBUG)
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(log_formatter)
        root_logger.addHandler(console_handler)

        if options.quite:
            console_handler.setLevel(logging.WARNING)
        elif options.verbose == 0:
            console_handler.setLevel(logging.INFO)
        elif options.verbose == 1:
            console_handler.setLevel(logging.DEBUG)

        if len(args) != 1:
            logging.error("Invalid number of arguments.")
            sys.exit(1)

        arg_is_sha = len(args[0]) == 40 and args[0].isalnum()

        if arg_is_sha:
            logging.info("SHA-1 provided for programming.")
            sha = args[0]
            bit_file_name = os.path.join(BIT_DIR, "firmware_%s.bit" % args[0])
            mcs_file_name = os.path.join(BIT_DIR, "firmware_%s.mcs" % args[0])
        else:
            logging.info("Filename provided for programming.")
            bit_file_name = args[0]
            mcs_file_name = os.path.join(BIT_DIR, "%s.mcs" % os.path.basename(args[0]).split('.')[0])

        if options.mezz == "":
            logging.warning("No mezzanine revision specified. This is only supported for legacy bitstream downloads.")

        if os.path.exists(bit_file_name):
            logging.info("Found '%s'", bit_file_name)
        else:
            if arg_is_sha:
                error = download_bit(sha, bit_file_name, options.mezz)
                if error:
                    sys.exit(-1)
            else:
                logging.error("File '%s' not found." % bit_file_name)
                sys.exit(-1)

        if options.flash:
            if os.path.exists(mcs_file_name):
                logging.info("Found '%s'", mcs_file_name)
            else:
                bit_to_mcs(bit_file_name, mcs_file_name)
            program_mcs(mcs_file_name)
        else:
            program_bit(bit_file_name)

    except optparse.OptionError as error:
        logging.error(str(error))
        exc_traceback = sys.exc_info()[2]
        logging.debug("The exception was raised from:")
        for line in traceback.format_tb(exc_traceback):
            for split_line in line.split("\n"):
                logging.debug(split_line)
        logging.debug("")
        sys.exit(1)


if __name__ == "__main__":
    main()

