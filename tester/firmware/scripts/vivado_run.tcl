###########################################################################################
#     
#     This is a Xilinx tcl script to compile files in a given project to check for errors
#     
#     Jose Pedro Castro Fonseca, EP-ESE-ME, CERN, 2018
#
###########################################################################################

# Tcl procedure to get a timestamp

puts "Command-line args: [lindex $argv 0] [lindex $argv 1]"

# Sets the appropriate path and variables

# Sets the appropriate path and variables
set origin_dir  "[file normalize "."]"
set run_mode        "[lindex $argv 0]"
set top_module      "[lindex $argv 1]"
set target_core     "[lindex $argv 2]" 
set target_board    "[lindex $argv 3]"
set target_language "[lindex $argv 4]"
set sim_language    "Mixed"
set project_name    $top_module
set top_file_name   "[lindex $argv 5]"
if {[lindex $argv 6] eq "out-of-context"} {
    set synth_mode "out_of_context"
} else {
    set synth_mode "default"
}
set project_dir "[file normalize "$origin_dir/work/fpga-$project_name"]"


if {$run_mode eq "init"} {
    
    # Reference dir for the source files, and creates a work directory
    set top_file_path "[file normalize "$origin_dir/$top_file_name"]"

    # Creating a Vivado project, should we ever need to open the GUI
    create_project $project_name $project_dir

    # Opens the Manifest file specific for this design unit, created by the python script invocation
    set fid_m [open $project_dir/manifest r]
    set manifest [read $fid_m]
    set manifest [split $manifest ","]
    set i 0

    if {[lindex $manifest $i] eq "rtlfiles"} {
         
        # Add rtl files
        incr i
        while {[lindex $manifest $i] ne "xdcfiles"} {
            lappend design_lib [lindex $manifest $i]
            incr i
        }

    } else {
        puts "Bad Manifest File: Missing rtlfiles tag"
    }


    set project [get_projects $project_name]
    set_property "default_lib"      "xil_default_lib" $project
    set_property "source_mgmt_mode" "DisplayOnly"     $project
    set_property "target_language"  $target_language  $project
    set_property "part"             $target_core      $project
    set_property "board_part"       $target_board     $project

    #### --------------- Adding the RTL files --------------- ####

    # Create the sources fileset, but first checking if it doesn't already exist
    if {[string equal [get_filesets -quiet sources_1] ""]} {
        create_fileset -srcset sources_1
    }

    # Add the source RTL files
    set sources_obj [get_filesets sources_1]
    add_files -norecurse -fileset $sources_obj $top_file_path
    foreach design_file $design_lib {
        set design_file [file normalize $origin_dir/$design_file]
        puts "Adding Design File: $design_file"
        add_files            -fileset $sources_obj $design_file
    }

    # Setting the top level file. TODO this assumes that the top-most module inside $top_file_name has the name "top"
    set_property top $top_module $sources_obj


    # Add the include files

    #############################################################



    #### ----------- Adding the constraint files ----------- ####

    # Create the constrs fileset, but first checking if it doesn't already exist
    if {[string equal [get_filesets -quiet constrs_1] ""]} {
        create_fileset -constrset constrs_1
    }

    # Add the constraint files. 
    set constrs_obj [get_filesets constrs_1]
    incr i
    while {[lindex $manifest $i] ne "ipcfiles"} {
        set constr_file [file normalize "$origin_dir/[lindex $manifest $i]"]
        puts "Read Constraint File: $constr_file"
        add_files -norecurse -fileset $constrs_obj $constr_file 
        incr i
    }

    #############################################################

    # Add the IP configuration files
    incr i
    if {[lindex $manifest $i] ne "NONE"} {
        while {[lindex $manifest $i] ne "simlibs"} {
            set ipcfg_file [file normalize "$origin_dir/[lindex $manifest $i]"]
            puts "Read IP File: $ipcfg_file"
            read_ip $ipcfg_file
            incr i
        }
    }

} elseif {$run_mode eq "compile"} {

    # Opens the previously created project
    open_project $project_dir/$project_name.xpr

    # Updates the compilation order for the current fileset
    update_compile_order -fileset [get_filesets sources_1]

    # Launches the compiler to check for errors, but only elaborates design to save time
    set timestamp [clock format [clock seconds] -format "%b%d_%H%M%S"]
    set fid [open $project_dir/compile-$timestamp.log w]
    set output_str [check_syntax -fileset [get_filesets sources_1] -return_string]
    puts $fid $output_str
    close $fid

    # Exits vivado
    exit

} elseif {$run_mode eq "implement"} {

    # Opens the previously created project
    open_project $project_dir/$project_name.xpr

    # Updates the compilation order for the current fileset
    update_compile_order -fileset [get_filesets sources_1]

    # Creates a folder for the present run
    set  timestamp [clock format [clock seconds] -format "%b%d_%H%M%S"]
    set  run_dir $project_dir/impl_run_$timestamp/
    file mkdir   $run_dir

    # Synthesis STEP (HELLO USER, THIS IS FOR YOU!! :) Add your synthesis custom options here)
    puts "\n\033\[95mRUNINFO\033\[0m: Running Synthesis Step...\n"
    synth_design -mode $synth_mode -fsm_extraction auto -flatten_hierarchy none

    # Pre-optimization STEP (mainly to write Reports)
    report_utilization -file $run_dir/post_synth_util.rpt
    set post_synth_util [report_utilization -return_string]
    report_timing_summary -warn_on_violation -file $run_dir/post_synth_timing_summary.rpt

    # Optimization STEP
    puts "\n\033\[95mRUNINFO\033\[0m: Running Post-Synthesis Optimization Step...\n"
    opt_design     

    # Placement STEP
    puts "\n\033\[95mRUNINFO\033\[0m: Running Placement Step...\n"
    place_design -directive Explore

    # Post-placement STEP
    report_clock_utilization -file $run_dir/clk_util.rpt

    # Physical Optimization STEP
    puts "\n\033\[95mRUNINFO\033\[0m: Running Physical Optimization Step...\n"
    phys_opt_design -placement_opt

    # Post-PhysicalOpt STEP
    report_timing_summary -warn_on_violation -file $run_dir/post_phys_opt_timing_summary.rpt

    # Routing STEP
    puts "\n\033\[95mRUNINFO\033\[0m: Running Routing Step...\n"
    route_design -directive Explore

    # Post Routing STEP
    report_timing_summary -file $run_dir/post_route_timing_summary.rpt
    report_drc            -file $run_dir/post_route_drc.rpt
    report_power          -file $run_dir/post_route_power.rpt
    report_route_status   -file $run_dir/post_route_status.rpt

    # If we are not in OOC mode, writes the bitstream
    if {$synth_mode eq "default"} {
        puts "\n\033\[95mRUNINFO\033\[0m: Writing bitstream...\n"
        write_bitstream "$origin_dir/bin/bitfile-$timestamp.bit"
    }

    # Writes the backannotated netlist
    puts "\n\033\[95mRUNINFO\033\[0m: Writing the backannotated netlist...\n"
    write_sdf     -rename_top "NETLIST_$top_module" -process_corner fast "$run_dir/timing.sdf"
    write_verilog -rename_top "NETLIST_$top_module"  -mode timesim -sdf_anno true -sdf_file $run_dir/timing.sdf -force "$run_dir/netlist.v"

}
