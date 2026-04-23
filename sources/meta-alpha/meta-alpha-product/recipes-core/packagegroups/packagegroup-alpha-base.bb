SUMMARY = "ALPHA base package group"
DESCRIPTION = "Common rootfs packages for ALPHA product images"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = " \
    bash \
    coreutils \
    findutils \
    iproute2 \
    iputils \
    net-tools \
    ethtool \
    i2c-tools \
    ca-certificates \
"
