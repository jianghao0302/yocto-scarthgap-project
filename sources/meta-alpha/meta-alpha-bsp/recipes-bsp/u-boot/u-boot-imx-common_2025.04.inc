DESCRIPTION = "i.MX U-Boot suppporting i.MX reference boards."

LICENSE = "GPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

SRC_URI = "${UBOOT_SRC};branch=${SRCBRANCH}"

UBOOT_SRC ?= "git://github.com/jianghao0302/uboot-imx.git;protocol=https"
SRCBRANCH = "master"
LOCALVERSION ?= "-${SRCBRANCH}"
# SRCREV = "44898b9f3cfe5ff881c11ab1c44b714041f2b4ac"
SRCREV = "${AUTOREV}"

DEPENDS += " \
    bc-native \
    bison-native \
    dtc-native \
    flex-native \
    gnutls-native \
    python3-setuptools-native \
    xxd-native \
"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

BOOT_TOOLS = "imx-boot-tools"
