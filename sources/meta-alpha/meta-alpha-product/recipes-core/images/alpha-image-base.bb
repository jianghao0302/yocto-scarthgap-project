SUMMARY = "ALPHA base image"
DESCRIPTION = "Minimal ALPHA-owned product image skeleton"
LICENSE = "MIT"

require recipes-core/images/core-image-base.bb

IMAGE_FEATURES += "ssh-server-dropbear"
