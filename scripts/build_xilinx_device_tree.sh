#!/bin/sh

# https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/136904764/Creating+Devicetree+from+Devicetree+Generator+for+Zynq+Ultrascale+and+Zynq+7000
# https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18842279/Build+Device+Tree+Blob

XILINX_DEVICE_TREE_REPO=device-tree-xlnx
XILINX_DEVICE_TREE_TAG=xilinx-v2019.1

function get_xilinx_device_tree_generator() {
  if [ -d ${BUILD_ROOT}/${XILINX_DEVICE_TREE_REPO} ]; then
    echo "=== Derectory ${XILINX_DEVICE_TREE_REPO} already exists."
    echo ""
  else
    echo "=== Getting Xilinx Device Tree sources..."
    echo ""

    git clone ${XILINX_GIT_ROOT}/${XILINX_DEVICE_TREE_REPO}.git

    cd ${XILINX_DEVICE_TREE_REPO}
    git checkout -b ${XILINX_DEVICE_TREE_TAG}

    cd -
  fi
}

function create_dtb_from_dtg() {
  HW_SPEC=$1

  if [ -z ${HW_SPEC} ]; then
    echo "=== ERROR: Hardware spcification <.hdf> must be specified"
    return 1
  fi

  get_xilinx_device_tree_generator

  cd ${XILINX_DEVICE_TREE_REPO}

  xsct ${BUILD_ROOT}/scripts/create_dts_from_hw.tcl ${HW_SPEC} \
                                                    ${BUILD_ROOT} \
                                                    ${BUILD_ROOT}/${XILINX_DEVICE_TREE_REPO}

  echo "=== Patching Xilinx DTS"
  patch -p1 < ${BUILD_ROOT}/patches/dts-dtg.patch

  echo "=== Build Device Tree Blob"
  gcc -I . -E -nostdinc -undef -D__DTS__ -x assembler-with-cpp \
      -o ${DTS_DIR}/zynq-zybo-z7.dts system-top.dts

  dtc -I dts -O dtb -o ${DTS_DIR}/${DTB_BIN} ${DTS_DIR}/zynq-zybo-z7.dts || return 1

  echo "=== Install Device Tree Blob"
  cp -v ${DTS_DIR}/${DTB_BIN} ${INSTALL_DIR}

  cd -
}

function create_dtb_from_linux_sources() {
  #TODO:
  # For ARM platform it is possible to make DTB using following command
  # cd <linux src> && make ARCH=arm dtbs
  # see https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18842279/Build+Device+Tree+Blob#BuildDeviceTreeBlob-Alternative:ForARMonly
  
  XILINX_LINUX_REPO=$1

  if [ -z ${XILINX_LINUX_REPO} ]; then
    echo "=== ERROR: Linux sources path have to be specified"
    return 1
  fi


  cd ${XILINX_LINUX_REPO}

  echo "=== Build Device Tree Blob" 
  gcc -I ${XILINX_LINUX_REPO}/include -E -nostdinc -undef -D__DTS__ -x assembler-with-cpp \
      -o ${DTS_DIR}/zynq-zybo-z7.dts \
      ${XILINX_LINUX_REPO}/arch/arm/boot/dts/zynq-zybo-z7.dts

  dtc -I dts -O dtb -o ${DTS_DIR}/${DTB_BIN} ${DTS_DIR}/zynq-zybo-z7.dts || return 1

  echo "=== Install Device Tree Blob"
  cp -v ${DTS_DIR}/${DTB_BIN} ${INSTALL_DIR}

  cd -
}
