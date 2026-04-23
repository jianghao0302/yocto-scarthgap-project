require conf/distro/poky.conf

DISTRO = "alpha"
DISTRO_NAME = "Alpha Release Distro"
DISTRO_VERSION = "1.0"
DISTROOVERRIDES = "alpha"

MAINTAINER = "ALPHA <lauren.post@alpha.com>"

# Use systemd as default init manager
POKY_INIT_MANAGER = "systemd"0