# Common ALPHA machine settings live here.
# Individual board machine files should require this include and then require
# the relevant vendor machine to inherit the SoC BSP defaults.

include conf/machine/include/arm/armv7a/tune-cortexa7.inc

MACHINEOVERRIDES =. "alpha:"
ALPHA_VENDOR ?= "generic"
ALPHA_PRODUCT_FAMILY ?= "generic"

PREFERRED_PROVIDER_u-boot = "u-boot-imx"
PREFERRED_PROVIDER_u-boot-mfgtool = "u-boot-imx"
PREFERRED_PROVIDER_virtual/bootloader = "u-boot-imx"
PREFERRED_VERSION_u-boot-imx = "2025.04%"

PREFERRED_PROVIDER_virtual/kernel = "linux-imx"
PREFERRED_VERSION_linux-imx = "6.12%"

SERIAL_CONSOLES = "115200;ttymxc0"

SOC_DEFAULT_WKS_FILE                 ?= "imx-uboot-bootpart.wks.in"