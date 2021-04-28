#!/bin/sh

sourced=0
hdf=""
build="all"
dts="xilinx-linux"
sdcard=""

#############################
#
# Binaries for Linux:
#

UBOOT_BIN=u-boot.elf
FSBL_BIN=fsbl.elf
KERNEL_BIN=uImage
RAMDISK_BIN=uramdisk.image.gz
DTB_BIN=zynq-zybo-z7.dtb
FPGA_BIN=fpga.bit

#############################

BOARD_NAME=zybo_z7_10
BOARD_BOOT_DIR=${BOARD_NAME}_linux_boot

BUILD_ROOT=${PWD}
SCRIPTS=${BUILD_ROOT}/scripts

INSTALL_DIR=${BUILD_ROOT}/${BOARD_BOOT_DIR}
LOCAL_BINARY=${BUILD_ROOT}/local/bin
DTS_DIR=${BUILD_ROOT}/dts

VIVADO_ROOT=/tools/Xilinx/Vivado
VIVADO_VERSION=2019.1

XILINX_GIT_ROOT=https://github.com/Xilinx

source ${VIVADO_ROOT}/${VIVADO_VERSION}/settings64.sh

source ${SCRIPTS}/build_u_boot.sh
source ${SCRIPTS}/build_xilinx_linux.sh
source ${SCRIPTS}/build_dtc.sh
source ${SCRIPTS}/build_xilinx_device_tree.sh
source ${SCRIPTS}/build_fsbl.sh
source ${SCRIPTS}/create_ramdisk.sh
source ${SCRIPTS}/create_boot_image.sh

export CROSS_COMPILE=arm-linux-gnueabihf-
export ARCH=arm
export KBUILD_DIR=${BUILD_ROOT}/${XILINX_LINUX_REPO}
export PATH=${PATH}:${LOCAL_BINARY}

function usage() {
  echo ""
  echo "Usage: ./build_zybo_z7_linux.sh [OPTION]"
  echo ""
  echo -e "\t--hdf=<XSDK_HDF_FILE>"
  echo -e "\t--build=<BOOT_MODULE>"
  echo -e "\t\tall (default)"
  echo -e "\t\tu-boot"
  echo -e "\t\tkernel"
  echo -e "\t\tdtb"
  echo -e "\t\tfsbl"
  echo -e "\t\tramdisk"
  echo -e "\t\tbootimage"
  echo -e "\t--dts=DTS_SRC"
  echo -e "\t\txilinx-linux (default)"
  echo -e "\t\tdtg"
  echo -e "\t--sdcard=<DIR>"
  echo ""
  echo "or"
  echo ""
  echo "source ./build_zybo_z7_linux.sh"
  echo ""
}

function create_directories() {
  dirs=(${INSTALL_DIR} ${LOCAL_BINARY} ${DTS_DIR})

  for d in ${dirs[@]}; do
    if [ -d ${d} ]; then
      echo "=== Directory ${d} already exists." 
    else
      echo "=== Create ${d}"
      mkdir -p ${d}
    fi
  done
}

if [[ "$0" != "$BASH_SOURCE" ]]; then
  sourced=1
  echo "=== ${BASH_SOURCE[0]} sourced!"
  echo ""
  echo "Avalibale commands:"
  echo ""
  echo -e "\tbuild_u_boot"
  echo -e "\tbuild_xilinx_linux"
  echo -e "\tbuild_dtc"
  echo -e "\tbuild_fsbl"
  echo -e "\tcreate_dtb_from_dtg"
  echo -e "\tcreate_dtb_from_linux_sources"
  echo -e "\tcreate_ramdisk"
  echo -e "\tcreate_boot_image"
  echo ""
else
  while [ "$1" != "" ]; do
    param=`echo $1 | awk -F= '{print $1}'`
    value=`echo $1 | awk -F= '{print $2}'`
    case ${param} in
      -h | --help)
        usage
        exit
        ;;
      --hdf)
        hdf=${value}
        ;;
      --build)
        build=${value}
        ;;
      --dts)
        dts=${value}
        if [[ ${dts} != "xilinx-linux" && ${dts} != "dtg" ]]; then
          echo "=== Unknown DTS"
          exit 1
        fi
        ;;
      --sdcard)
        sdcard=${value}
        ;;
      *)
        echo "=== ERROR: unknown parameter \"${param}\""
        usage
        exit 1
        ;;
    esac
    shift
  done
fi

if [ ${sourced} -ne 1 ]; then
  if [ ${build} == "all" ]; then
    if [ -z ${hdf} ]; then
      echo "=== ERROR: Xilinx SDK .hdf not specified"
      usage
      exit 1
    fi

    if [ -z ${sdcard} ]; then
      echo "=== ERROR: SD card mount point must be specified"
      usage
      exit 1
    fi

    create_directories

    echo "=== Build all"
    build_u_boot || exit 1
    build_dtc
    build_xilinx_linux || exit 1

    if [ ${dts} == "dtg" ]; then
      create_dtb_from_dtg ${hdf} || exit 1
    else
      create_dtb_from_linux_sources ${BUILD_ROOT}/${XILINX_LINUX_REPO} || exit 1
    fi

    build_fsbl ${hdf} || exit 1
    create_ramdisk || exit 1
    create_boot_image ${sdcard}
  else
    case ${build} in
      u-boot)
        build_u_boot
        ;;
      kernel)
        build_xilinx_linux
        ;;
      dtb)
        build_dtc
        if [ ${dts} == "DTG" ]; then
          create_dtb_from_dtg ${hdf}
        else
          create_dtb_from_linux_sources ${BUILD_ROOT}/${XILINX_LINUX_REPO}
        fi
        ;;
      fsbl)
        build_fsbl ${hdf}
        ;;
      ramdisk)
        create_ramdisk
        ;;
      bootimage)
        create_boot_image ${sdcard}
        ;;
      *)
        echo "=== ERROR: Unknown module \"${build}\""
        usage
        exit 1
        ;;
    esac
  fi
fi

