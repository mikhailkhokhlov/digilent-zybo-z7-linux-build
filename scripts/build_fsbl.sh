#!/bin/sh

function build_fsbl() {
  HW_SPEC=$1

  if [ -z ${HW_SPEC} ]; then
    echo "=== ERROR: Hardware specification <.hdf> must be specified"
    return 1
  fi

  #TODO: removing existent projects have to be moved to create_fsbl.tcl and removed
  #      using deleteprojects xsct command

  if  [ -d ${BUILD_ROOT}/${BOARD_NAME}_hw0 ]; then
    rm -rvf ${BUILD_ROOT}/${BOARD_NAME}_hw0
  fi

  if  [ -d ${BUILD_ROOT}/${BOARD_NAME}_fsbl_bsp ]; then
    rm -rvf ${BUILD_ROOT}/${BOARD_NAME}_fsbl_bsp
  fi

  if [ -d ${BUILD_ROOT}/${BOARD_NAME}_fsbl ]; then
    rm -rvf ${BUILD_ROOT}/${BOARD_NAME}_fsbl
  fi

  if [ -d ${BUILD_ROOT}/.metadata ]; then
    rm -rvf ${BUILD_ROOT}/.metadata
  fi

  echo "=== Create FSBL" 
  xsct ${BUILD_ROOT}/scripts/create_fsbl.tcl ${BUILD_ROOT} ${HW_SPEC} ${BOARD_NAME} || return 1

  echo "=== Install FSBL"
  cp -v ${BUILD_ROOT}/${BOARD_NAME}_fsbl/Debug/${BOARD_NAME}_fsbl.elf ${INSTALL_DIR}/${FSBL_BIN}

  echo "=== Install fpga.bit"
  fpga=$(ls ${BUILD_ROOT}/${BOARD_NAME}_hw0/*.bit)
  cp -v ${fpga} ${INSTALL_DIR}/${FPGA_BIN}
}
