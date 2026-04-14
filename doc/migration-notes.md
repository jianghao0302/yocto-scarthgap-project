# Yocto Migration Notes

## 2026-04-14

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