# Copyright (C) 2012, 2015 O.S. Systems Software LTDA.
# Released under the MIT license (see COPYING.MIT for the terms)

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

# Keep this include self-contained in meta-alpha and avoid dependencies on
# classes provided by sources/nxp layers.
inherit kernel-yocto kernel

# Put a local version until we have a true SRCREV to point to
LOCALVERSION ?= ""
SCMVERSION ?= "y"
SRCBRANCH ?= ""

# Allow use of kernel as linux-mfgtool provider.
PROVIDES += "linux-mfgtool"

# Set the PV to the correct kernel version to satisfy the kernel version sanity check
PV = "${LINUX_VERSION}+git${SRCPV}"

SRC_URI ?= "git://github.com/nxp-imx/linux-imx;protocol=https;branch=${SRCBRANCH}"

S = "${WORKDIR}/git"

# Tell kernel class we are expanding a normal defconfig baseline, not allnoconfig.
KCONFIG_MODE = "--alldefconfig"

# Pass load address for boards where this is required.
KERNEL_EXTRA_ARGS += "LOADADDR=${UBOOT_ENTRYPOINT}"

# A function to strip the new 32-bit dtb sub-folders in KERNEL_DEVICETREE
# for older kernel builds.
# Set KERNEL_DEVICETREE_32BIT_COMPATIBILITY_UPDATE = "1" to enable.
KERNEL_DEVICETREE_32BIT_COMPATIBILITY_UPDATE ?= "0"
python kernel_devicetree_32bit_compatibility_update() {
    import os.path
    import re
    if d.getVar('KERNEL_DEVICETREE_32BIT_COMPATIBILITY_UPDATE') != "1" or d.getVar('TUNE_ARCH') != "arm":
        return
    input = d.getVar('KERNEL_DEVICETREE').split()
    output = ""
    stripped = ""
    for original in input:
        if re.match("^.*/", original):
            stripped = os.path.basename(original)
            output += stripped + " "
            bb.debug(1, "Devicetrees are moved to sub-folder, stripping the sub-folder for older kernel: %s -> %s" % (original, stripped))
        else:
            output += original + " "
    if stripped:
        bb.warn("Updating KERNEL_DEVICETREE, removing sub-folders for older kernel. Use -D for more details. Set KERNEL_DEVICETREE_32BIT_COMPATIBILITY_UPDATE = \"0\" to disable.")
        d.setVar('KERNEL_DEVICETREE', output)
}
addhandler kernel_devicetree_32bit_compatibility_update
kernel_devicetree_32bit_compatibility_update[eventmask] = "bb.event.RecipeParsed"
