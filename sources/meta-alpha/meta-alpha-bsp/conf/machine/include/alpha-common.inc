# Common ALPHA machine settings live here.
# Individual board machine files should require this include and then require
# the relevant vendor machine to inherit the SoC BSP defaults.

MACHINEOVERRIDES =. "alpha:"
ALPHA_VENDOR ?= "generic"
ALPHA_PRODUCT_FAMILY ?= "generic"
