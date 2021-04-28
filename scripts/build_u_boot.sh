#!/bin/sh

XILINX_UBOOT_REPO=u-boot-xlnx
XILINX_UBOOT_BRANCH=xilinx/versal

XILINX_U_BOOT_SRS=${BUILD_ROOT}/$XILINX_UBOOT_REPO

get_u_boot_sources() {
  echo "=== Getting U-Boot sources..."
  echo ""

  if [ -d ${XILINX_U_BOOT_SRS} ]; then
     echo "=== Directory ${XILINX_U_BOOT_SRS} exists." 
  else
    git clone ${XILINX_GIT_ROOT}/${XILINX_UBOOT_REPO}.git

    cd ${XILINX_UBOOT_REPO}
    git checkout ${XILINX_UBOOT_BRANCH}
    patch -p1 < ../patches/u-boot-xlnx.patch

    cd -
  fi
}

build_u_boot() {
  get_u_boot_sources

  cd ${XILINX_UBOOT_REPO}

  echo "=== Build U-Boot..."
  echo ""

  make zynq_zybo_z7_defconfig
  make -j $(nproc --all) || return 1

  echo "=== Install u-boot to ${INSTALL_DIR}"
  cp -v u-boot ${INSTALL_DIR}/${UBOOT_BIN}
  echo "=== Install mkimage to ${LOCAL_BINARY}"
  cp -v tools/mkimage ${LOCAL_BINARY}

  cd -
}

