# Yocto Migration Notes

## Record Guidelines

- Add new entries in reverse chronological order (newest first).
- Use a date header in `YYYY-MM-DD` format.
- Keep each entry in this fixed structure:
  - `Background`
  - `Scope and objectives`
  - `Changes implemented`
  - `Verification`
  - `Risks and follow-ups`
  - `Rollback`
- In `Verification`, include at least one positive-path and one negative-path or edge-case result when applicable.
- In `Rollback`, explicitly list files or commits to revert.

## 2026-04-14

### Background

- Goal: migrate to a self-owned `meta-alpha` workflow and reduce coupling with vendor layers.

### Scope and objectives

- Use `bsp-setup.sh` as the single bootstrap entry.
- Keep default layer set minimal for incremental bring-up.
- Improve script readability by grouping layer lists.
- Improve script robustness with argument validation.

### Changes implemented

- Bootstrap entry:
  - Use `source bsp-setup.sh -m imx6ull14x14alpha`.
- Layer policy:
  - `poky` core remains initialized by `oe-init-build-env`.
  - Script-managed default focuses on `meta-openembedded` core layers and `meta-alpha` layers.
  - Extra layers under `sources/nxp` are explicitly skipped when passed via `-e`.
- Layer-list structure:
  - Introduced grouped variables: `OE_LAYER_LIST`, `ALPHA_LAYER_LIST`.
  - Reserved optional groups: `ARM_LAYER_LIST`, `UI_LAYER_LIST`, `SECURITY_LAYER_LIST`.
  - Aggregated through `LAYER_LIST`.
- Validation hardening:
  - `-j` and `-t` must be positive integers.
  - `MACHINE` and `DISTRO` tokens accept `[A-Za-z0-9._-]` only.

### Verification

- Positive path:
  - Sourcing with `-m imx6ull14x14alpha` succeeds and enters build directory.
- Negative path:
  - Invalid `-j/-t` values return expected error code and message.
  - Invalid machine token returns expected error code and message.

### Risks and follow-ups

- Existing old build directories may still contain previously added layers.
- If new feature requirements appear, optional groups can be enabled incrementally.

### Rollback

- Revert related commits that touched `bsp-setup.sh`, `doc/meta-layer-inventory.md`, and this file.