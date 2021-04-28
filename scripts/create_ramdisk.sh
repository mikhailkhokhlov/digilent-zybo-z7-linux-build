#!/bin/sh

# See details in Xilinx wiki:
#
# https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18842473/Build+and+Modify+a+Rootfs

function create_ramdisk() {
  echo "=== Create RAM disk image"

  if [ ! -f arm_ramdisk.image.gz ]; then
    wget --no-check-certificate https://xilinx-wiki.atlassian.net/wiki/download/attachments/18842473/arm_ramdisk.image.gz
  fi

  gzip -d arm_ramdisk.image.gz

  chmod u+rwx arm_ramdisk.image

  if [ ! -d ${BUILD_ROOT}/mnt ]; then
    mkdir ${BUILD_ROOT}/mnt
  fi

  if [ "$(ls -A ${BUILD_ROOT}/mnt)" ]; then
     echo "=== RAM disk already mounted"
  else
    echo "=== Mount RAM disk"
    sudo mount -o loop ${BUILD_ROOT}/arm_ramdisk.image ${BUILD_ROOT}/mnt || return 1
    cd ${BUILD_ROOT}/mnt

#    echo "=== Apply fs patch"
#    sudo patch -p1 < ${BUILD_ROOT}/patches/ramdisk.patch || return 1
    cd -

    sudo umount ${BUILD_ROOT}/mnt
    gzip ${BUILD_ROOT}/arm_ramdisk.image

    echo "=== Make uramdisk.image.gz"
    mkimage -A arm -T ramdisk -C gzip -d arm_ramdisk.image.gz ${RAMDISK_BIN} || return 1
  fi

  echo "=== Install uramdisk.image.gz"
  cp -v ${BUILD_ROOT}/${RAMDISK_BIN} ${INSTALL_DIR}
}

