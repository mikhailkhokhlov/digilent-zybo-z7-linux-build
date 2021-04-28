#!/bin/sh

function create_boot_image() {
  SDCARD_MOUNT=$1

  if [ -z ${SDCARD_MOUNT} ]; then
    echo "=== ERROR: SD card mount point must be specified."
    return 1
  fi

  echo "=== Create boot image"

  cd ${INSTALL_DIR}

  # Needed binaries are:
  #
  # u-boot.elf
  # fsbl.elf
  # uImage
  # uramdisk.image.gz
  # zynq-zybo-z7.dtb
  # fpga.bit

  binaries=(${UBOOT_BIN} ${FSBL_BIN} ${KERNEL_BIN} ${RAMDISK_BIN} ${DTB_BIN} ${FPGA_BIN})

  for binary in ${binaries[@]}; do
    if [ ! -f ${binary} ]; then
      echo "=== ERROR: ${binary} needed for creating boot image."
      return 1
    fi
  done

  cat > boot.bif << EOF
image : {
      [bootloader]${FSBL_BIN}
      ${FPGA_BIN}
      ${UBOOT_BIN}
}
EOF

  bootgen -w -image boot.bif -o i boot.bin

  # TODO:
  # all load addresses have to be replaced to config variables

  cat > uEnv.txt << EOF
bootcmd=fatload mmc 0 0x3000000 uImage; fatload mmc 0 0x2000000 uramdisk.image.gz; fatload mmc 0 0x2A00000 devicetree.dtb; bootm 0x3000000 0x2000000 0x2A00000
uenvcmd=boot
EOF

  echo "=== Install binaries to SD card:"
  cp -v ${INSTALL_DIR}/boot.bin       ${SDCARD_MOUNT}
  cp -v ${INSTALL_DIR}/${DTB_BIN}     ${SDCARD_MOUNT}
  cp -v ${INSTALL_DIR}/${RAMDISK_BIN} ${SDCARD_MOUNT}
  cp -v ${INSTALL_DIR}/${KERNEL_BIN}  ${SDCARD_MOUNT}
  cp -v ${INSTALL_DIR}/uEnv.txt       ${SDCARD_MOUNT}


  cd -
}
