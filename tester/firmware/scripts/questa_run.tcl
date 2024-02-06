###########################################################################################
#     
#     This is a Questasim tcl script to compile files in a given project to check for errors
#     
#     Jose Pedro Castro Fonseca, EP-ESE-ME, CERN, 2018
#
###########################################################################################

puts "\nCommand-line args:"
for {set i 0} {$i < [llength $argv]} {incr i} {
    puts "$i: [lindex $argv $i]"
}


# Sets the appropriate path and variables
set origin_dir  "[file normalize "."]"
set top_module  "[lindex $argv 5]"
set run_mode    "[lindex $argv 7]"
set timing_mode "[lindex $argv 9]"
set netlist_file "[lindex $argv 11]"
set project_dir "[file normalize "$origin_dir/work/rtl-$top_module"]"
set design_lib ""
set verif_lib  ""

# Opens the Manifest file specific for this design unit, created by the python script invocation
set fid_m [open $project_dir/manifest r]
set manifest [read $fid_m]
set manifest [split $manifest ","]
set i 0

if {[lindex $manifest $i] eq "rtlfiles"} {
    
    
    # Add rtl files
    incr i
    while {[lindex $manifest $i] ne "vrffiles"} {
        lappend design_lib [lindex $manifest $i]
        incr i
    }

    # Add verification files
    incr i
    while {[lindex $manifest $i] ne "simlibs"} {
        lappend verif_lib [lindex $manifest $i]
        incr i
    }


} else {
    puts "Bad Manifest File: Missing rtlfiles tag"
}

# Map external libs
cd $project_dir
vlib work
vmap work $project_dir/work
incr i
while {[lindex $manifest $i] ne "end"} {
    set library [split [lindex $manifest $i] ":"]
    set lib_name [lindex $library 0]
    set lib_path [lindex $library 1]
    set cmd "vmap $lib_name $origin_dir/$lib_path"
    eval $cmd
    
    incr i 
}

# Compile files, if they are outdated
if {$run_mode eq "init"} {
    puts "First compilation!\n"
    set fid_c [open $project_dir/compiletime w]
    set last_compile_time 0
} elseif {$run_mode eq "recom"} {
    if {[catch {open $project_dir/compiletime r+}]} {
        puts "Last Compile Time file doesn't exist!\n"
        set fid_c [open $project_dir/compiletime w]
        set last_compile_time 0
    } else {
        puts "Last Compile Time file exists!\n"
        set fid_c [open $project_dir/compiletime r+]
        set last_compile_time [read $fid_c]
        close $fid_c
    }
}

if { ($run_mode eq "init") || ($run_mode eq "recom") } {
    
    foreach design_file $design_lib {
        set design_file [file normalize $origin_dir/$design_file]
        set curr [file mtime $design_file]
        puts "\nLast Compile: $last_compile_time\nCurr Compile: $curr" 

        # If the file has a modification date later than the last compilation date saved in the file, we recompile
        if {$last_compile_time < [file mtime $design_file]} {
            # Deciding between VHDL or Verilog files, and choosing the appropriate compiler
            # Since these files are meant for synthesis, we use the -check_synthesis flag to make sure they are synthesizable
            if [regexp {.vhd} $design_file] {
                vcom -check_synthesis $design_file 
            } elseif [regexp {.v} $design_file] {
                vlog -check_synthesis $design_file
            }
            set last_compile_time 0
        } else {
            puts "Skipping compilation: $design_file unchaged..."
        }
    }

    foreach verif_file $verif_lib {
        set verif_file [file normalize $origin_dir/$verif_file]
        set curr [file mtime $design_file]
        puts "\nLast Compile: $last_compile_time\nCurr Compile: $curr" 

        if {$last_compile_time < [file mtime $verif_file]} {
            if [regexp {.vhd} $verif_file] {
                vcom $verif_file
            } elseif [regexp {.v} $verif_file] {
                vlog +fcover -sv $verif_file
            }
            set last_compile_time 0
        } else {
            puts "Skipping compilation: $verif_file unchaged..."
        }
    }

    # If any of the files was recompiled, we save the new compilation time in the text file
    if {$last_compile_time eq 0} {
        set fid_c [open $project_dir/compiletime w]
        puts -nonewline $fid_c [clock seconds]
        close $fid_c
    }

    exit
}

proc getStdinLine {} {
    set ::userInput [gets stdin]
}


if {$run_mode eq "siminit"} {

	set top_module_tb "tb_$top_module"

    if {$timing_mode eq "USE_SDF"} {
        # TODO set  num_verf_lib [llength $verif_lib] 
        puts "SDF Backannotation Simulation!"
        set top_tb_file [lindex $verif_lib 0]
        set verif_file [file normalize $origin_dir/$top_tb_file]
        set cmd "vlog $verif_file +define+SDF"
        eval $cmd
        set netlist_file "$origin_dir/$netlist_file/netlist.v"
        set cmd "vlog $netlist_file +define+SDF"
        eval $cmd
        set cmd "vsim -t fs $top_module_tb glbl -L secureip -L simprims_ver +transport_int_delays"
        eval $cmd
    } else {
        set cmd "vsim -cvgperinstance -t fs $top_module_tb"
        eval $cmd
    }



} elseif {$run_mode eq "simgui"} {
    
    set  top_module_tb "tb_$top_module"
    set  cmd "vsim -t fs $top_module_tb -do \"wave.do\""
    eval $cmd
    run -all

    # Prompts user for action
    while 1 {

        puts "What do you want to do? re(c)ompile and restart, just (r)estart or (q)uit? "
 
        # Waits for user input
        fileevent stdin readable getStdinLine
        vwait ::userInput

        # Unregister the callback
        fileevent stdin readable {}

        if {$userInput eq "c"} {
            # TODO use a TCL procedure to avoid recompilation
            if {[catch {open $project_dir/compiletime r+}]} {
                puts "Last Compile Time file doesn't exist!\n"
                set fid_c [open $project_dir/compiletime w]
                set last_compile_time 0
            } else {
                puts "Last Compile Time file exists!\n"
                set fid_c [open $project_dir/compiletime r+]
                set last_compile_time [read $fid_c]
                close $fid_c
            }

            foreach design_file $design_lib {
                set design_file [file normalize $origin_dir/$design_file]
                set curr [file mtime $design_file]
                puts "\nLast Compile: $last_compile_time\nCurr Compile: $curr" 

                # If the file has a modification date later than the last compilation date saved in the file, we recompile
                if {$last_compile_time < [file mtime $design_file]} {
                    # Deciding between VHDL or Verilog files, and choosing the appropriate compiler
                    # Since these files are meant for synthesis, we use the -check_synthesis flag to make sure they are synthesizable
                    if [regexp {.vhd} $design_file] {
                        vcom -check_synthesis $design_file 
                    } elseif [regexp {.v} $design_file] {
                        vlog -check_synthesis $design_file
                    }
                    set last_compile_time 0
                } else {
                    puts "Skipping compilation: $design_file unchaged..."
                }
            }

            foreach verif_file $verif_lib {
                set verif_file [file normalize $origin_dir/$verif_file]
                set curr [file mtime $design_file]
                puts "\nLast Compile: $last_compile_time\nCurr Compile: $curr" 

                if {$last_compile_time < [file mtime $verif_file]} {
                    if [regexp {.vhd} $verif_file] {
                        vcom $verif_file
                    } elseif [regexp {.v} $verif_file] {
                        vlog $verif_file
                    }
                    set last_compile_time 0
                } else {
                    puts "Skipping compilation: $verif_file unchaged..."
                }
            }

            # If any of the files was recompiled, we save the new compilation time in the text file
            if {$last_compile_time eq 0} {
                set fid_c [open $project_dir/compiletime w]
                puts -nonewline $fid_c [clock seconds]
                close $fid_c
            }
            
            # Restarts time to 0 and runs the simulation
            restart -force
            run -all

        } elseif {$userInput eq "q"} {
            quit -force
        } elseif {$userInput eq "r"} {
            # Restarts time to 0 and runs the simulation
            restart -force
            run -all
        }
    }
} elseif {$run_mode eq "simcmd"} {
    
    set top_module_tb "tb_$top_module"
    set  cmd "vsim -t fs $top_module_tb -c"
    eval $cmd
    run -all
    exit
}
