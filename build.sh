#!/bin/bash

CDIR=$(pwd)
BUILD_THREADS=$(($(nproc)/2))

setup_flash_util() {
  local bolt_flash_util_dir="${CDIR}/bolt-flash-utility"

  [[ -f "${bolt_flash_util_dir}/Flash_tools/AFU/Linux/64/EtaAfuOemLnx64" ]] || {
    wget https://www.udoo.org/download/files/UDOO_BOLT/UEFI_update/UDOOBOLT_C40_UEFI_Update_rel108.zip \
         -O "${CDIR}/uefi-firmware-updateder.zip" || return 1

    mkdir -p "${bolt_flash_util_dir}"
    unzip "${CDIR}/uefi-firmware-updateder.zip" -d "${bolt_flash_util_dir}" || return 1
    rm "${CDIR}/uefi-firmware-updateder.zip"

    chmod +x "${bolt_flash_util_dir}/Flash_tools/AFU/Linux/64/bios_updater_x64.sh"
  }

  [[ -n "${1}" ]] && {
    ${bolt_flash_util_dir}/Flash_tools/AFU/Linux/64/bios_updater_x64.sh "${1}"
    cd "${CDIR}"
  }

  return 0
}


build_coreboot() {
  local coreboot_dir="${CDIR}/coreboot"

  [[ -d "${coreboot_dir}" ]] || {
    git clone https://review.coreboot.org/coreboot.git "${coreboot_dir}" || return 1
    git -C "${coreboot_dir}" checkout 4.19 || return 1
    git -C "${coreboot_dir}" submodule update --init --checkout || return 1
    make -C "${coreboot_dir}" crossgcc-i386 CPUS="${BUILD_THREADS}" || return 1
  }

  cat < "${CDIR}/amd-zen-coreboot.cfg" >> "${coreboot_dir}/.config"
  make -C "${coreboot_dir}" menuconfig || return 1
  make -C "${coreboot_dir}" -j"${BUILD_THREADS}" || return 1

  return 0
}

[[ "${1}" == "--flash-util" ]] && {
  setup_flash_util "${2}" || exit 1
} || {
  build_coreboot || exit 1
}

exit 0
