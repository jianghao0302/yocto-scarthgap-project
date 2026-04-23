# image_types_alpha.bbclass
#
# Create a friendly SD card image alias name without "rootfs" in filename.
# Example:
#   alpha-image-base-imx6ull14x14alpha.sdcard -> alpha-image-base-imx6ull14x14alpha.rootfs.wic

do_alpha_create_sdcard_alias() {
    if ! ${@bb.utils.contains('IMAGE_FSTYPES', 'wic', 'true', 'false', d)}; then
        exit 0
    fi

    src="${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.wic"
    dst="${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}.sdcard"

    if [ -e "$src" ]; then
        ln -sf "$(basename "$src")" "$dst"
        bbnote "Created SD alias: $(basename "$dst") -> $(basename "$src")"
    else
        bbwarn "Skip SD alias, source wic not found: $src"
    fi
}

addtask alpha_create_sdcard_alias after do_image_complete before do_build
