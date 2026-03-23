SUMMARY = "ALPHA BSP metadata marker"
DESCRIPTION = "Empty recipe used to keep the ALPHA BSP layer visible to BitBake"
LICENSE = "CLOSED"

inherit allarch

ALLOW_EMPTY:${PN} = "1"
do_install[noexec] = "1"
