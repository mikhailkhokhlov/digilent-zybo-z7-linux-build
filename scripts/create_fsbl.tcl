#!/bin/tclsh

# using: %xcst create_fsbl.tcl <workspace> <path-to-hdf> <board_name>

# https://www.xilinx.com/html_docs/xilinx2018_1/SDK_Doc/xsct/use_cases/xsct_create_app_project.html
# https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18842019/Zynq+UltraScale+FSBL

if { $argc != 3 } {
  puts "Usage create_fsbl.tcl <workspace> <path-to-hdf> <board_name>"
} else {
  set workspace [lindex $argv 0]
  set hdf [lindex $argv 1]
  set board_name [lindex $argv 2]

  set hw_project $board_name
  append hw_project "_hw0"

  set fsbl_project $board_name
  append fsbl_project "_fsbl"

  setws $workspace
  createhw -name $hw_project -hwspec $hdf
  createapp -name $fsbl_project -app {Zynq FSBL} -proc ps7_cortexa9_0 -hwproject $hw_project -os standalone
  projects -build
}
