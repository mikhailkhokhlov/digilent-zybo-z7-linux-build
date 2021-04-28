#!/usr/bin/tclsh

# using: %xcst create_dts_from_hw.tcl <path-to-hdf> <repo-path> <DTG-sorces>

# https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18842279/Build+Device+Tree+Blob
# https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/136904764/Creating+Devicetree+from+Devicetree+Generator+for+Zynq+Ultrascale+and+Zynq+7000
# https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18841693/HSI+debugging+and+optimization+techniques

if { $argc != 3 } {
  puts "Usage: create_dts_from_hw.tcl <path-to-hdf> <repo-path> <DTG-sorces>"
} else {
  set hdf [lindex $argv 0]
  set repo_path [lindex $argv 1]
  set dtg_src [lindex $argv 2]

  hsi::open_hw_design $hdf
  hsi::set_repo_path $repo_path
  hsi::create_sw_design device-tree -os device_tree -proc ps7_cortexa9_0
  hsi::generate_target -dir $dtg_src
  hsi::close_hw_design [hsi::current_hw_design]
}
