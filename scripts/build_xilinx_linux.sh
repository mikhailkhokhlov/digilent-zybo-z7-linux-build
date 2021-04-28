#!/bin/sh

XILINX_LINUX_REPO=linux-xlnx
XILINX_LINUX_TAG=xlnx_rebase_v4.19_2019.1

get_xilinx_linux() {
  if [ -d ${BUILD_ROOT}/${XILINX_LINUX_REPO} ]; then
    echo "=== Xilinx Linux sources already exists ..."
    echo ""
  else
    echo "=== Getting Xilinx Linux sources..."
    echo ""

    git clone ${XILINX_GIT_ROOT}/${XILINX_LINUX_REPO}.git
    cd ${XILINX_LINUX_REPO}
    git checkout -b ${XILINX_LINUX_TAG}
    cd -
  fi
}

build_xilinx_linux() {
  get_xilinx_linux

  cd ${XILINX_LINUX_REPO}

  echo "=== Configure Linux kernel"
  make ARCH=arm xilinx_zynq_defconfig || return 1

  echo "=== Build kernel"
  make -j $(nproc --all) ARCH=arm UIMAGE_LOADADDR=0x8000 uImage || return 1

  echo "=== Install uImage to ${INSTALL_DIR}"
  cp -v arch/arm/boot/uImage ${INSTALL_DIR}/${KERNEL_BIN}

  cd -
}

