VENDOR_PROFILE_LIST="${VENDOR_PROFILE_LIST} nxp"

VENDOR_MACHINE_REGEX_nxp='^(alpha-)?imx|^(alpha-)?mx'

VENDOR_DEFAULT_DISTRO_nxp='fsl-imx-xwayland'

VENDOR_COMMON_FEATURE_LAYERS_nxp=" \
    meta-virtualization \
    meta-security \
    meta-qt6 \
"

VENDOR_BASE_LAYERS_nxp=" \
    nxp/meta-freescale \
    nxp/meta-freescale-3rdparty \
    nxp/meta-freescale-distro \
    nxp/meta-imx/meta-imx-bsp \
    nxp/meta-imx/meta-imx-sdk \
"

VENDOR_FEATURE_LAYERS_nxp=" \
    nxp/meta-nxp-connectivity/meta-nxp-connectivity-examples \
    nxp/meta-nxp-connectivity/meta-nxp-matter-advanced \
    nxp/meta-nxp-connectivity/meta-nxp-matter-baseline \
    nxp/meta-nxp-connectivity/meta-nxp-openthread \
    nxp/meta-nxp-connectivity/meta-nxp-otbr \
    nxp/meta-nxp-connectivity/meta-nxp-zigbee-rcp \
    nxp/meta-nxp-demo-experience \
    nxp/meta-imx/meta-imx-cockpit \
    nxp/meta-imx/meta-imx-ml \
    nxp/meta-imx/meta-imx-v2x \
"
