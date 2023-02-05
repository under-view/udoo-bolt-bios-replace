#!/bin/bash

CDIR=$(pwd)
BUILD_THREADS=$(($(nproc)/2))

build_coreboot() {
  local coreboot_dir="${CDIR}/coreboot"

  [[ -d "${coreboot_dir}" ]] || {
    git clone https://review.coreboot.org/coreboot.git "${coreboot_dir}" || return 1
    git -C "${coreboot_dir}" checkout 4.19 || return 1
    git -C "${coreboot_dir}" submodule update --init --checkout || return 1
    make -C "${coreboot_dir}" crossgcc-x64 CPUS="${BUILD_THREADS}" || return 1
  }
  
  cat < "${CDIR}/amd-zen-coreboot.cfg" >> "${coreboot_dir}/.config"
  make -C "${coreboot_dir}" menuconfig || return 1
  make -C "${coreboot_dir}" -j"${BUILD_THREADS}" || return 1

  return 0
}

build_coreboot || exit 1

exit 0
