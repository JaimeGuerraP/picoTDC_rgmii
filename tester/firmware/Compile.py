#!/usr/bin/env python3

import string
import sys
import os
import glob
import time
import shutil

def Execute(cmd):
    errCode=os.system(cmd)
    if errCode:
        print("Application returned non zero code (%d). Ending ..."%errCode)
        return False
    return True

def prepareCompile():
    from manifest import designs

    for design in designs:
        designs[design]['RTLFiles'] = ",".join(designs[design]['RTLFiles'].split())
        designs[design]['IPFiles'] = ",".join(designs[design]['IPFiles'].split())
        designs[design]['ConstrFiles'] = ",".join(designs[design]['ConstrFiles'].split())

    return designs

def initFPGA(designPropr, top_module, project_dir):
    # Checks if dir already exists
    if(len(glob.glob("work/")) == 0):
        if Execute("mkdir work") == False:
            exit(1)
    if(len(glob.glob(project_dir)) == 0):
        print("mkdir "+project_dir)
        if Execute("mkdir "+project_dir) == False:
            exit(1)
    else:
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
    fid.write("rtlfiles,"+designPropr[top_module]['RTLFiles']+","+designPropr[top_module]['TopRTLFile']+",")
    fid.write("xdcfiles,"+designPropr[top_module]['ConstrFiles']+",")
    fid.write("ipcfiles,"+designPropr[top_module]['IPFiles']+",")
    fid.write("simlibs," +designPropr[top_module]['SimLibs']+",end")
    fid.close()

    print("vivado -mode batch -source scripts/vivado_run.tcl -tclargs init "+top_module+" "+designPropr[top_module]['TargetCore']+" "+designPropr[top_module]['TargetBoard']+" "+designPropr[top_module]['TargetLang']+" "+designPropr[top_module]['TopRTLFile']+" "+designPropr[top_module]['SynthMode'])
    if Execute("vivado -mode batch -source scripts/vivado_run.tcl -tclargs init "+top_module+" "+designPropr[top_module]['TargetCore']+" "+designPropr[top_module]['TargetBoard']+" "+designPropr[top_module]['TargetLang']+" "+designPropr[top_module]['TopRTLFile']+" "+designPropr[top_module]['SynthMode']) == False:
        #Print all of the log files
        for the_file in os.listdir('.'):
            if ".log" in the_file:
                print("Log file ({}): ".format(the_file))
                print("=======================================")
                #Execute('cat '+the_file)
                with open(the_file, 'r') as fin:
                    print('{}'.format(fin.read()))
        exit(1)

def compileFPGA(designPropr, top_module, project_dir):
    if Execute("vivado -mode batch -source scripts/vivado_run.tcl -tclargs compile "+top_module+" "+designPropr[top_module]['TargetCore']+" "+designPropr[top_module]['TargetBoard']+" "+designPropr[top_module]['TargetLang']+" "+designPropr[top_module]['TopRTLFile']+" "+designPropr[top_module]['SynthMode']) == False:
        #Print all of the log files
        for the_file in os.listdir('.'):
            if ".log" in the_file:
                print("Log file ({}): ".format(the_file))
                print("=======================================")
                with open(the_file, 'r') as fin:
                    print('{}'.format(fin.read()))
        exit(1)
    latest_log_file = max(glob.glob(os.path.join(project_dir, "compile*.log")), key=os.path.getctime)
    Execute("gvim -p "+latest_log_file+" & ")

def implementFPGA(designPropr, top_module, project_dir):
    if(len(glob.glob("bin/")) == 0):
        Execute("mkdir bin")

    if Execute("vivado -nojournal -mode batch -source scripts/vivado_run.tcl -tclargs implement "+top_module+" \
    "+designPropr[top_module]['TargetCore']+" "+designPropr[top_module]['TargetBoard']+" \
    "+designPropr[top_module]['TargetLang']+" "+designPropr[top_module]['TopRTLFile']+" "+designPropr[top_module]['SynthMode']) == False:
        #Print all of the log files
        for the_file in os.listdir('.'):
            if ".log" in the_file:
                print("Log file ({}): ".format(the_file))
                print("=======================================")
                #Execute('cat '+the_file)
                with open(the_file, 'r') as fin:
                    print('{}'.format(fin.read()))
        exit(1)

def timingCheck(designPropr, top_module, project_dir):
    # Getting the latest run directory to display the results..# Getting the latest run directory to display the results..
    latest_run_dir = max(glob.glob(os.path.join(project_dir, "impl_run_*")), key=os.path.getctime)
    timing_report = os.path.join(latest_run_dir, 'post_route_timing_summary.rpt')

    violations = False
    with open(timing_report) as file: # Use file to refer to the file object
        for lno,line in enumerate(file.readlines()):
            if line.find("VIO")>=0:
                print("#%d : %s"%(lno,line))
                violations = True
    if violations:
        print("Timing violations present in the design!")
        exit(1)

def programFPGA(designPropr, top_module, project_dir):
    if(len(glob.glob("bin/%s_*.bit" % top_module)) == 0):
        print("\033[91mERROR: There are no bitfiles present to program the FPGA.\033[0m")
        sys.exit(1)
    else:
        latest_bit_file = max(glob.glob("bin/%s_*.bit" % top_module), key=os.path.getctime)
        print("File to program: "+latest_bit_file)
        if Execute("scripts/lpgbt_tester_programmer.py "+latest_bit_file) == False:
            exit(1)

def flashFPGA(designPropr, top_module, project_dir):
    if(len(glob.glob("bin/%s_*.bit" % top_module)) == 0):
        print("\033[91mERROR: There are no bitfiles present to program the FPGA flash.\033[0m")
        sys.exit(1)
    else:
        latest_bit_file = max(glob.glob("bin/%s_bitfile*.bit" % top_module), key=os.path.getctime)
        print("File to program: "+latest_bit_file)
        if Execute("scripts/lpgbt_tester_programmer.py --flash "+latest_bit_file) == False:
            exit(1)

def rtlCompile(designPropr, top_module, project_dir):
    if(len(glob.glob("work/")) == 0):
        Execute("mkdir work");
    if(len(glob.glob(project_dir)) == 0):
        Execute("mkdir "+project_dir)
        init = 1
    else:
        init = 0

    fid = open(os.path.join(project_dir, "manifest"), "w+");
    fid.write("rtlfiles,"+designPropr[top_module]['RTLFiles']+","+designPropr[top_module]['TopRTLFile']+",")
    fid.write("vrffiles,"+designPropr[top_module]['VRFFiles']+","+designPropr[top_module]['TopVRFFile']+",")
    fid.write("simlibs," +designPropr[top_module]['SimLibs']+",end")
    fid.close()

    if(init):
        Execute('vsim -c -do scripts/questa_run.tcl -do '+top_module+' -do init');
    else:
        Execute('vsim -c -do scripts/questa_run.tcl -do '+top_module+' -do recom');

def rtlSimInit(useSDF, top_module, project_dir):
    if(useSDF == "USE_SDF"):
        # Getting the latest run directory to display the results..
        project_dir    = os.path.join("work", "fpga-"+top_module)
        latest_run_dir = max(glob.glob(os.path.join(project_dir, "impl_run_*")), key=os.path.getctime)
        Execute('vsim -i -do scripts/questa_run.tcl -do '+top_module+' -do siminit'+' -do USE_SDF -do '+latest_run_dir);
    else:
        Execute('vsim -i -do scripts/questa_run.tcl -do '+top_module+' -do siminit -do NO_SDF');
