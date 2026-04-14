# Yocto Meta Layer Inventory

Generated on 2026-03-18 from the current workspace.

## Summary

- Valid Yocto layers detected: 52
- Detection rule: directories containing `conf/layer.conf`
- Excluded from the count: `sources/poky/bitbake/lib/layerindexlib/tests/testdata/*`

## Notes

- `version` below is recorded as `branch @ short-commit` of the Git repository that contains the layer.
- `download URL` is the current `origin` URL of that repository.
- Some layers in this workspace are vendored directly into the main repository instead of being separate Git clones. For those layers, the recorded download URL is the current workspace repository URL.

## Change Record (2026-04-14)

### BSP setup and layer policy

- `bsp-setup.sh` is now the single entrypoint for environment bootstrap, invoked as:
	- `source bsp-setup.sh -m imx6ull14x14alpha`
- Default layer selection was reduced to a minimal development set to support iterative bring-up.
	- `poky` core layers are still initialized by `oe-init-build-env`.
	- Script-managed defaults now focus on `meta-openembedded` core layers and `meta-alpha` layers.
- Layer configuration in `bsp-setup.sh` was refactored into grouped variables for readability and future expansion:
	- `OE_LAYER_LIST`
	- `ALPHA_LAYER_LIST`
	- Optional placeholders: `ARM_LAYER_LIST`, `UI_LAYER_LIST`, `SECURITY_LAYER_LIST`
	- Final aggregation: `LAYER_LIST`
- NXP layer paths are explicitly excluded when appending extra layers via `-e`.

### Input validation hardening

- `bsp-setup.sh` now validates:
	- `-j` and `-t` must be positive integers.
	- `MACHINE` and `DISTRO` names must only include `[A-Za-z0-9._-]`.

### Verification status

- Sourcing script with `-m imx6ull14x14alpha` completes successfully and enters the build directory.
- Negative-path checks (invalid `-j/-t`, invalid machine token) return expected error codes and messages.

## Repository Inventory

| Repository Root | Version | Download URL | Layers |
| --- | --- | --- | --- |
| `sources/poky` and `sources/meta-openembedded` vendored in workspace root | `master @ 2da3f71a` | `https://github.com/jianghao0302/yocto-scarthgap-project.git` | 15 |
| `sources/meta-arm` | `scarthgap @ a81c1991` | `git://git.yoctoproject.org/meta-arm` | 4 |
| `sources/meta-browser` | `scarthgap @ 168d2842` | `https://github.com/OSSystems/meta-browser.git` | 2 |
| `sources/meta-clang` | `scarthgap @ 5bce7e2` | `https://github.com/kraj/meta-clang` | 1 |
| `sources/meta-qt6` | `lts-6.8.7 @ 1d6fc215` | `git://code.qt.io/yocto/meta-qt6.git` | 1 |
| `sources/meta-security` | `scarthgap @ 97e482b` | `git://git.yoctoproject.org/meta-security` | 5 |
| `sources/meta-timesys` | `scarthgap @ 13dc56b` | `https://github.com/TimesysGit/meta-timesys.git` | 1 |
| `sources/meta-virtualization` | `scarthgap @ 3dd635f6` | `git://git.yoctoproject.org/meta-virtualization` | 1 |
| `sources/nxp/meta-freescale` | `scarthgap @ 902dde8c` | `https://github.com/Freescale/meta-freescale.git` | 1 |
| `sources/nxp/meta-freescale-3rdparty` | `scarthgap @ 70c83e9` | `https://github.com/Freescale/meta-freescale-3rdparty.git` | 1 |
| `sources/nxp/meta-freescale-distro` | `scarthgap @ b9d6a5d` | `https://github.com/Freescale/meta-freescale-distro.git` | 1 |
| `sources/nxp/meta-nxp-connectivity` | `master @ 02367cc` | `https://github.com/nxp-imx/meta-nxp-connectivity.git` | 6 |
| `sources/nxp/meta-nxp-demo-experience` | `walnascar-6.12.49-2.2.0 @ 391062c` | `https://github.com/nxp-imx-support/meta-nxp-demo-experience.git` | 1 |
| `sources/nxp/meta-openembedded` | `scarthgap @ 4d3e2639de` | `git://git.openembedded.org/meta-openembedded` | 10 |
| `sources/nxp/meta-selinux` | `scarthgap @ 8024696` | `git://git.yoctoproject.org/meta-selinux` | 1 |
| `sources/nxp/meta-virtualization` | `scarthgap @ 3dd635f6` | `git://git.yoctoproject.org/meta-virtualization` | 1 |

## Layer Details

### Vendored in Workspace Root

Version: `master @ 2da3f71a`

Download URL: `https://github.com/jianghao0302/yocto-scarthgap-project.git`

- `sources/poky/meta`
- `sources/poky/meta-poky`
- `sources/poky/meta-selftest`
- `sources/poky/meta-skeleton`
- `sources/poky/meta-yocto-bsp`
- `sources/meta-openembedded/meta-filesystems`
- `sources/meta-openembedded/meta-gnome`
- `sources/meta-openembedded/meta-initramfs`
- `sources/meta-openembedded/meta-multimedia`
- `sources/meta-openembedded/meta-networking`
- `sources/meta-openembedded/meta-oe`
- `sources/meta-openembedded/meta-perl`
- `sources/meta-openembedded/meta-python`
- `sources/meta-openembedded/meta-webserver`
- `sources/meta-openembedded/meta-xfce`

### `sources/meta-arm`

Version: `scarthgap @ a81c1991`

Download URL: `git://git.yoctoproject.org/meta-arm`

- `sources/meta-arm/meta-arm`
- `sources/meta-arm/meta-arm-bsp`
- `sources/meta-arm/meta-arm-systemready`
- `sources/meta-arm/meta-arm-toolchain`

### `sources/meta-browser`

Version: `scarthgap @ 168d2842`

Download URL: `https://github.com/OSSystems/meta-browser.git`

- `sources/meta-browser/meta-chromium`
- `sources/meta-browser/meta-firefox`

### `sources/meta-clang`

Version: `scarthgap @ 5bce7e2`

Download URL: `https://github.com/kraj/meta-clang`

- `sources/meta-clang`

### `sources/meta-qt6`

Version: `lts-6.8.7 @ 1d6fc215`

Download URL: `git://code.qt.io/yocto/meta-qt6.git`

- `sources/meta-qt6`

### `sources/meta-security`

Version: `scarthgap @ 97e482b`

Download URL: `git://git.yoctoproject.org/meta-security`

- `sources/meta-security`
- `sources/meta-security/meta-hardening`
- `sources/meta-security/meta-integrity`
- `sources/meta-security/meta-parsec`
- `sources/meta-security/meta-tpm`

### `sources/meta-timesys`

Version: `scarthgap @ 13dc56b`

Download URL: `https://github.com/TimesysGit/meta-timesys.git`

- `sources/meta-timesys`

### `sources/meta-virtualization`

Version: `scarthgap @ 3dd635f6`

Download URL: `git://git.yoctoproject.org/meta-virtualization`

- `sources/meta-virtualization`

### `sources/nxp/meta-freescale`

Version: `scarthgap @ 902dde8c`

Download URL: `https://github.com/Freescale/meta-freescale.git`

- `sources/nxp/meta-freescale`

### `sources/nxp/meta-freescale-3rdparty`

Version: `scarthgap @ 70c83e9`

Download URL: `https://github.com/Freescale/meta-freescale-3rdparty.git`

- `sources/nxp/meta-freescale-3rdparty`

### `sources/nxp/meta-freescale-distro`

Version: `scarthgap @ b9d6a5d`

Download URL: `https://github.com/Freescale/meta-freescale-distro.git`

- `sources/nxp/meta-freescale-distro`

### `sources/nxp/meta-nxp-connectivity`

Version: `master @ 02367cc`

Download URL: `https://github.com/nxp-imx/meta-nxp-connectivity.git`

- `sources/nxp/meta-nxp-connectivity/meta-nxp-connectivity-examples`
- `sources/nxp/meta-nxp-connectivity/meta-nxp-matter-advanced`
- `sources/nxp/meta-nxp-connectivity/meta-nxp-matter-baseline`
- `sources/nxp/meta-nxp-connectivity/meta-nxp-openthread`
- `sources/nxp/meta-nxp-connectivity/meta-nxp-otbr`
- `sources/nxp/meta-nxp-connectivity/meta-nxp-zigbee-rcp`

### `sources/nxp/meta-nxp-demo-experience`

Version: `walnascar-6.12.49-2.2.0 @ 391062c`

Download URL: `https://github.com/nxp-imx-support/meta-nxp-demo-experience.git`

- `sources/nxp/meta-nxp-demo-experience`

### `sources/nxp/meta-openembedded`

Version: `scarthgap @ 4d3e2639de`

Download URL: `git://git.openembedded.org/meta-openembedded`

- `sources/nxp/meta-openembedded/meta-filesystems`
- `sources/nxp/meta-openembedded/meta-gnome`
- `sources/nxp/meta-openembedded/meta-initramfs`
- `sources/nxp/meta-openembedded/meta-multimedia`
- `sources/nxp/meta-openembedded/meta-networking`
- `sources/nxp/meta-openembedded/meta-oe`
- `sources/nxp/meta-openembedded/meta-perl`
- `sources/nxp/meta-openembedded/meta-python`
- `sources/nxp/meta-openembedded/meta-webserver`
- `sources/nxp/meta-openembedded/meta-xfce`

### `sources/meta-selinux`

Version: `scarthgap @ 8024696`

Download URL: `git://git.yoctoproject.org/meta-selinux`

### `sources/nxp/meta-imx`

Version: `scarthgap-6.6.52-2.2.2`

Download URL: `https://github.com/nxp-imx/meta-imx/tree/scarthgap-6.6.52-2.2.2`

- `sources/nxp/meta-imx`