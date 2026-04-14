# Copyright 2013-2016 Freescale Semiconductor
# Copyright 2017-2025 NXP
# Copyright 2018 O.S. Systems Software LTDA.
# Released under the MIT license (see COPYING.MIT for the terms)
#
# SPDX-License-Identifier: MIT
#

SUMMARY = "Linux Kernel provided and supported by NXP"
DESCRIPTION = "Linux Kernel provided and supported by NXP with focus on \
i.MX Family Reference Boards. It includes support for many IPs such as GPU, VPU and IPU."

require recipes-kernel/linux/linux-imx.inc

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

DEPENDS += "coreutils-native"

SRC_URI = "${LINUX_IMX_SRC}"
LINUX_IMX_SRC ?= "git://github.com/jianghao0302/linux-imx.git;protocol=https;branch=${SRCBRANCH}"
SRCBRANCH = "master"
KBRANCH = "${SRCBRANCH}"
LOCALVERSION = "-lts-next"
# SRCREV = "be78e49cb4339fd38c9a40019df49b72fbb8bcb7"
SRCREV = "${AUTOREV}"

# PV is defined in the base in linux-imx.inc file and uses the LINUX_VERSION definition
# required by kernel-yocto.bbclass.
#
# LINUX_VERSION define should match to the kernel version referenced by SRC_URI and
# should be updated once patchlevel is merged.
LINUX_VERSION = "6.12.34"
# FIXME: Drop this line once LINUX_VERSION is stable
KERNEL_VERSION_SANITY_SKIP = "1"

KERNEL_CONFIG_COMMAND = 'oe_runmake_call -C ${S} CC="${KERNEL_CC}" O=${B} olddefconfig'

DEFAULT_PREFERENCE = "1"

KBUILD_DEFCONFIG ?= ""

# Use a verbatim copy of the defconfig from the linux-imx repo.
# IMPORTANT: This task effectively disables kernel config fragments
# since the config fragments applied in do_kernel_configme are replaced.
addtask copy_defconfig after do_kernel_configme before do_kernel_localversion
do_copy_defconfig () {
    install -d ${B}
    mkdir -p ${B}
    cp ${S}/arch/arm/configs/${KBUILD_DEFCONFIG} ${B}/.config
}

DELTA_KERNEL_DEFCONFIG ?= ""
#DELTA_KERNEL_DEFCONFIG:mx8-nxp-bsp = "imx.config"

do_merge_delta_config[dirs] = "${B}"
do_merge_delta_config[depends] += " \
    flex-native:do_populate_sysroot \
    bison-native:do_populate_sysroot \
"
do_merge_delta_config() {
    for deltacfg in ${DELTA_KERNEL_DEFCONFIG}; do
        if [ -f ${S}/arch/${ARCH}/configs/${deltacfg} ]; then
            ${KERNEL_CONFIG_COMMAND}
            oe_runmake_call -C ${S} CC="${KERNEL_CC}" O=${B} ${deltacfg}
        elif [ -f "${UNPACKDIR}/${deltacfg}" ]; then
            ${S}/scripts/kconfig/merge_config.sh -m .config ${UNPACKDIR}/${deltacfg}
        elif [ -f "${deltacfg}" ]; then
            ${S}/scripts/kconfig/merge_config.sh -m .config ${deltacfg}
        fi
    done
    cp .config ${WORKDIR}/defconfig
}
addtask merge_delta_config before do_kernel_localversion after do_copy_defconfig

do_deploy:append() {
    if [ ${@bb.utils.filter('UBOOT_CONFIG', 'crrm', d)} ]; then
        baseName=${KERNEL_IMAGETYPE}-${KERNEL_IMAGE_NAME}
        gzip -c ${DEPLOYDIR}/$baseName${KERNEL_IMAGE_BIN_EXT} > \
            ${DEPLOYDIR}/$baseName${KERNEL_IMAGE_BIN_EXT}.gz
        ln -sf $baseName${KERNEL_IMAGE_BIN_EXT}.gz $deployDir/${KERNEL_IMAGETYPE}.gz
        # FIXME: For now, the CRRM kernel is just a copy of the regular kernel
        ln -sf $baseName${KERNEL_IMAGE_BIN_EXT}    $deployDir/${KERNEL_IMAGETYPE}_crrm
        ln -sf $baseName${KERNEL_IMAGE_BIN_EXT}.gz $deployDir/${KERNEL_IMAGETYPE}_crrm.gz
    fi
}

COMPATIBLE_MACHINE = "(imx6ull14x14alpha|mx6ull)"
