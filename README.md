Bildscript for creating Xilinx Linux SD boot image for Digilent Zybo-Z7-10 board

Following sources will be cloned from public repositories:

Linux kernel:
https://github.com/Xilinx/linux-xlnx

U-Boot:
https://github.com/Xilinx/u-boot-xlnx

Device Tree Compiler:
https://git.kernel.org/pub/scm/utils/dtc/dtc.git

Root FS is a pre-built image that will be downloaded from Xilinx web site.

Required environment (specified in build_zybo_z7_linux.sh)
	Vivado and Xilinx SDK:
		version and path to vivado

	ARM toolchain: 
		sudo apt-get install gcc-arm-linux-gnueabihf

How to use buildscript:

./build_zybo_z7_linux.sh --help

./build_zybo_z7_linux.sh --hdf=<path to hardware specification .hdf> --build=<module> --sdcard=/media/sdcard

source ./build_zybo_z7_linux.sh
