#!/usr/bin/python3

import string
import sys
import os
import glob
import time
import openpyxl as xlspy
import shutil

def Execute(cmd):
    errCode=os.system(cmd)
    if errCode:
        print("Application returned non zero code (%d). Ending ..."%errCode)
        sys.exit(1)

# Syntax formatting for console output
class color:
   PURPLE = '\033[95m'
   CYAN = '\033[96m'
   DARKCYAN = '\033[36m'
   BLUE = '\033[94m'
   GREEN = '\033[92m'
   YELLOW = '\033[93m'
   RED = '\033[91m'
   BOLD = '\033[1m'
   UNDERLINE = '\033[4m'
   END = '\033[0m'

# Loading a workbook, and getting the active sheet
wb = xlspy.load_workbook("manifest.xlsx")
sheet = wb.active

# First, we get the target coordinates. We know that the header of the Targe Manifest is always in the second row
designs = []
for cell in list(sheet.rows)[1]:
    if(cell.value == None):
        continue
    if(cell.value.split(":")[0] == "Design"):
        designs.append([cell.value.split(":")[1], cell.row, cell.col_idx])

numDesigns = len(designs)

# If there are no targets, exit!
#if(numDesigns == 0):
#    exit(-1);

# And then we parse the relevant data
designPropr = {}

for d in range(numDesigns):
    # Creating a dictionary for this entry
    row = designs[d][1]
    col = designs[d][2]

    designPropr_i = {'DesignName' : designs[d][0], 
                     'SynthMode'  : str.lower(list(sheet.rows)[row][col].value),
                     'TargetCore' : list(sheet.rows)[row+1][col].value,
                     'TargetBoard': list(sheet.rows)[row+2][col].value,
                     'TargetLang' : str.lower(list(sheet.rows)[row+3][col].value),
                     'TargetSimul': str.lower(list(sheet.rows)[row+4][col].value),
                     'TargetSynth': str.lower(list(sheet.rows)[row+5][col].value),
                     'TopRTLFile' : '',
                     'RTLFiles'   : '',
                     'TopVRFFile'  : '',
                     'VRFFiles'   : '',
                     'IPFiles' : '',
                     'ConstrFiles'   : '',
                     'SimLibs'    : ''} 
    try:
        str.lower(list(sheet.rows)[row+6][col-1].value) == "rtl design files", "Bad Structure in File"
    except AssertionError:
        raise
    
    # Parse the Top Level RTL file
    designPropr_i['TopRTLFile'] = list(sheet.rows)[row+7][col].value

    # Parse the RTL Files
    i = row + 8
    while(list(sheet.rows)[i][col].value != None):
        designPropr_i['RTLFiles']+=list(sheet.rows)[i][col].value+","
        i += 1
    designPropr_i['RTLFiles'] = designPropr_i['RTLFiles'][:len(designPropr_i['RTLFiles'])-1]
    
    # Parse the VRF Top file
    while(list(sheet.rows)[i][col-1].value == None):
        i += 1
        if(i == 1000000):
            print("Bad Structure in File")

    try:
        str.lower(list(sheet.rows)[i][col-1].value) == "verification files", "Bad Structure in File"
    except AssertionError:
        raise
    i+=1

    designPropr_i['TopVRFFile'] = list(sheet.rows)[i][col].value

    # Parse the VRF Files
    i += 1
    while(list(sheet.rows)[i][col].value != None):
        designPropr_i['VRFFiles']+=list(sheet.rows)[i][col].value+","
        i += 1
    designPropr_i['VRFFiles'] = designPropr_i['VRFFiles'][:len(designPropr_i['VRFFiles'])-1]

    # Parse the Simulation Library Files
    while(list(sheet.rows)[i][col-1].value == None):
        i += 1
        if(i == 1000000):
            print("Bad Structure in File")

    try:
        str.lower(list(sheet.rows)[i][col-1].value) == "simulation library paths (for questa simulation)", "Bad Structure in File"
    except AssertionError:
        raise

    i += 1
    while(list(sheet.rows)[i][col].value != None):
        designPropr_i['SimLibs']+=list(sheet.rows)[i][col-1].value+":"+list(sheet.rows)[i][col].value+","
        i += 1
    designPropr_i['SimLibs'] = designPropr_i['SimLibs'][:len(designPropr_i['SimLibs'])-1]
    
    # Parse the Simulation Library Files
    while(list(sheet.rows)[i][col-1].value == None):
        i += 1
        if(i == 1000000):
            print("Bad Structure in File")

    try:
        str.lower(list(sheet.rows)[i][col-1].value) == "ip configuration files path (for vivado synthesis)", "Bad Structure in File"
    except AssertionError:
        raise

    i += 1
    while(list(sheet.rows)[i][col].value != None):
        designPropr_i['IPFiles']+=list(sheet.rows)[i][col].value+","
        i += 1
    designPropr_i['IPFiles'] = designPropr_i['IPFiles'][:len(designPropr_i['IPFiles'])-1]

    # Parse the Constraint Files
    while(list(sheet.rows)[i][col-1].value == None):
        i += 1
        if(i == 1000000):
            print("Bad Structure in File")

    try:
        str.lower(list(sheet.rows)[i][col-1].value) == "constraints files path (for vivado synthesis", "Bad Structure in File"
    except AssertionError:
        raise

    i += 1
    while(list(sheet.rows)[i][col].value != None):
        designPropr_i['ConstrFiles']+=list(sheet.rows)[i][col].value+","
        i += 1
    designPropr_i['ConstrFiles'] = designPropr_i['ConstrFiles'][:len(designPropr_i['ConstrFiles'])-1]

    designPropr[designPropr_i['DesignName']] = designPropr_i

# Prints Usage exmaple message
def printUsageExample():
    print("Usage of makeit: ./makeit.py <design>-<target>-<command>\n\n");
    print("Where \033[1m<target>\033[0m:")
    print("\n\t \033[36m rtl\033[0m  - simulates the \033[1m<design>\033[0m module in Questasim/iverilog/GHDL")
    print("\n\t \033[36m fpga\033[0m - synthesis actions using Vivado")
    print("\nand \033[1m<command>\033[0m can be: ")
    print("\n\t \033[36m init\033[0m          - initializes an FPGA project on Vivado given the Top level design specified on the manifest file")
    print("\n\t \033[36m compile\033[0m       - compiles the <design> to check for errors before synthesis")
    print("\n\t \033[36m implement\033[0m     - Runs a full implementation cycle, with synthesis, implementation and bitfile generation")
    print("\n\t \033[36m program\033[0m       - downloads the bit file to the FPGA");
    print("\n\t \033[36m clean\033[0m         - cleans the work directory for this design project");
    print("\nbut if \033[1m<target>\033[0m used is \033[36m rtl\033[0m, \033[1m<target>\033[0m can be: ")
    print("\n\t \033[36m compile\033[0m     - compiles the <design> to check for errors before synthesis")
    print("\n\t \033[36m siminit\033[0m     - opens vsim without any script, so that you can configure your environment and create wave.do files manually")
    print("\n\t \033[36m simgui\033[0m      - opens vsim in GUI mode and automatically sources the wave.do file in $project_dir/scripts/wave.do");
    print("\n\t \033[36m simcmd\033[0m      - opens vsim in command-line, compiles the code with full optimization. Appropriate for running self-checking testbenches in Batch mode");
    print("\n");

# Checks for syntax errors in the invocation command
if(len(sys.argv) == 1):
    printUsageExample()
    sys.exit(1)
else:
    cmd = sys.argv[1].split('-')
    if(cmd[1] != 'fpga' and cmd[1] != 'rtl' and cmd[1] != 'cleanall'):
        print("\033[91mSyntax Error\033[0m. Please select the compilation target, \033[1mrtl\033[0m or \033[1mfpga\033[0m appropriately.")
        printUsageExample();
        sys.exit(1)
    elif(cmd[1] != 'cleanall'):
        if(cmd[1] == "rtl"):
            if(cmd[2] != "siminit" and cmd[2] != "compile" and cmd[2] != "simgui" and cmd[2] != "simcmd" and cmd[1]):
                print("\033[91mSyntax Error\033[0m. Please select the command, \033[1minit\033[0m or \033[1mcompile\033[0m or \033[1mwritebitfile\033[0m or \033[1mprog\033[0m appropriately.")
                printUsageExample();
                sys.exit(1)
        else: 
            if(cmd[2] != "init" and cmd[2] != "compile" and cmd[2] != "implement" and cmd[2] != "program" and cmd[2] != "clean" and cmd[1]):
                print("\033[91mSyntax Error\033[0m. Please select the command, \033[1minit\033[0m or \033[1mcompile\033[0m or \033[1mwritebitfile\033[0m or \033[1mprog\033[0m appropriately.")
                printUsageExample();
                sys.exit(1)
    if(len(cmd) == 4):
        if( cmd[3] != "USE_SDF"):
            print("\033[91mSyntax Error\033[0m. Please select \033[1msdf\033[0m for timing backannotation or don't write anything for rtl simulation")
    else:
        cmd.append('NO_SDF')
                    

# Check if IPBus Python modules have been loaded or not
#if "PYTHONPATH" not in os.environ:
#os.putenv("PYTHONPATH", "/opt/IPBus")

# Sets the path strings
project_dir    = os.path.join("work",cmd[1]+"-"+cmd[0]) #JM: Modified to be compliant with Windows (Old: "work/"+cmd[1]+"-"+cmd[0]+"/")
latest_run_dir = "NONE"
top_module = cmd[0];
init = 1


# Cleans up the junk log files
#Execute("rm *.jou *.log")

if(cmd[1] == 'fpga'):
    if(cmd[2] == 'init'):
        # Checks if dir already exists
        if(len(glob.glob("work")) == 0):
            Execute("mkdir work");
        if(len(glob.glob(project_dir)) == 0):
            print("mkdir "+project_dir)
            Execute("mkdir "+project_dir)
        else:
            print("INIT3 !")
            print("\033[93mWarning:\033[0m Work directory exists! Create new project? (Y/n)");
            if(str.lower(sys.stdin.read(1)) != 'y'):
                sys.exit(0)
            else:                
                #JM: Replace the old delete command (linux only) by a python script
                #   Old: Execute("rm -rf "+os.path.join(project_dir, "*"))
                for the_file in os.listdir(project_dir):
                    file_path = os.path.join(project_dir, the_file)
                    try:
                        if os.path.isfile(file_path):
                            os.unlink(file_path)
                        elif os.path.isdir(file_path): shutil.rmtree(file_path)
                    except Exception as e:
                        print(e)
                        
        fid = open(os.path.join(project_dir, "manifest"), "w+");
        fid.write("rtlfiles,"+designPropr[cmd[0]]['RTLFiles']+","+designPropr[cmd[0]]['TopRTLFile']+",")
        fid.write("xdcfiles,"+designPropr[cmd[0]]['ConstrFiles']+",")
        fid.write("ipcfiles,"+designPropr[cmd[0]]['IPFiles']+",")
        fid.write("simlibs," +designPropr[cmd[0]]['SimLibs']+",end")
        fid.close()
        
        print("vivado -mode batch -source scripts/vivado_run.tcl -tclargs init "+cmd[0]+" "+designPropr[cmd[0]]['TargetCore']+" "+designPropr[cmd[0]]['TargetBoard']+" "+designPropr[cmd[0]]['TargetLang']+" "+designPropr[cmd[0]]['TopRTLFile']+" "+designPropr[cmd[0]]['SynthMode'])
        Execute("vivado -mode batch -source scripts/vivado_run.tcl -tclargs init "+cmd[0]+" "+designPropr[cmd[0]]['TargetCore']+" "+designPropr[cmd[0]]['TargetBoard']+" "+designPropr[cmd[0]]['TargetLang']+" "+designPropr[cmd[0]]['TopRTLFile']+" "+designPropr[cmd[0]]['SynthMode'])

    elif(cmd[2] == 'compile'):

        Execute("vivado -mode batch -source scripts/vivado_run.tcl -tclargs compile "+cmd[0]+" "+designPropr[cmd[0]]['TargetCore']+" "+designPropr[cmd[0]]['TargetBoard']+" "+designPropr[cmd[0]]['TargetLang']+" "+designPropr[cmd[0]]['TopRTLFile']+" "+designPropr[cmd[0]]['SynthMode'])
        latest_log_file = max(glob.glob(os.path.join(project_dir, "compile*.log")), key=os.path.getctime)
        Execute("more "+latest_log_file)

    elif(cmd[2] == 'implement'):

        if(len(glob.glob("bin/")) == 0):
            Execute("mkdir bin")
        Execute("vivado -nojournal -mode batch -source scripts/vivado_run.tcl -tclargs implement "+cmd[0]+" \
        "+designPropr[cmd[0]]['TargetCore']+" "+designPropr[cmd[0]]['TargetBoard']+" \
        "+designPropr[cmd[0]]['TargetLang']+" "+designPropr[cmd[0]]['TopRTLFile']+" "+designPropr[cmd[0]]['SynthMode'])
        
        # Getting the latest run directory to display the results..
        latest_run_dir = max(glob.glob(os.path.join(project_dir, "impl_run_*")), key=os.path.getctime)
        Execute("gvim -p "+latest_run_dir+"/*.rpt & ")

    elif(cmd[2] == 'program'):

        if(len(glob.glob("bin/*.bit")) == 0):
            print("\033[91mERROR: There are no bitfiles present to program the FPGA.\033[0m")
            sys.exit(1)
        else:
            latest_bit_file = max(glob.glob("bin/bitfile*.bit"), key=os.path.getctime)
            print("File to program: "+latest_bit_file)
            Execute("djtgcfg init --verbose -d JtagSmt1")
            Execute("djtgcfg prog --verbose -d JtagSmt1 -i 0 -f "+latest_bit_file)

            time.sleep(0.5)

            # When the FPGA is reprogrammed, we lose the connection to the board, so we setup the eth connection again
#            Execute("sudo ifconfig eno1 192.168.200.1 netmask 255.255.255.0")
            
    elif(cmd[2] == 'clean'):
        Execute("rm -rf "+project_dir)
elif(cmd[1] == 'cleanall'):
    Execute("rm -rf work")
elif(cmd[1] == 'rtl'):
    if(cmd[2] == 'compile'):
        if(len(glob.glob("work/")) == 0):
            Execute("mkdir work");
        if(len(glob.glob(project_dir)) == 0):
            Execute("mkdir "+project_dir)
            init = 1
        else:
            init = 0

        fid = open(os.path.join(project_dir, "manifest"), "w+");
        fid.write("rtlfiles,"+designPropr[cmd[0]]['RTLFiles']+","+designPropr[cmd[0]]['TopRTLFile']+",")
        fid.write("vrffiles,"+designPropr[cmd[0]]['VRFFiles']+","+designPropr[cmd[0]]['TopVRFFile']+",")
        fid.write("simlibs," +designPropr[cmd[0]]['SimLibs']+",end")
        fid.close()

        if(init):
            Execute('vsim -c -do scripts/questa_run.tcl -do '+top_module+' -do init');
        else:
            Execute('vsim -c -do scripts/questa_run.tcl -do '+top_module+' -do recom');
    elif(cmd[2] == 'siminit'):
        if(cmd[3] == "USE_SDF"):
            # Getting the latest run directory to display the results..
            project_dir    = os.path.join("work", "fpga-"+cmd[0])
            latest_run_dir = max(glob.glob(os.path.join(project_dir, "/impl_run_*")), key=os.path.getctime)
            Execute('vsim -i -do scripts/questa_run.tcl -do '+top_module+' -do siminit'+' -do '+cmd[3]+' -do '+latest_run_dir);
        else:
            Execute('vsim -i -do scripts/questa_run.tcl -do '+top_module+' -do siminit -do NO_SDF');
    elif(cmd[2] == 'simgui'):
        Execute('vsim -i -do scripts/questa_run.tcl -do '+top_module+' -do simgui')
    elif(cmd[2] == 'simcmd'):
        Execute('vsim -c -do scripts/questa_run.tcl -do '+top_module+' -do simcmd')