meta-alpha layout
=================

This directory contains ALPHA-owned Yocto layers separated by responsibility:

- meta-alpha-bsp: board-level BSP delta such as machines, kernel/u-boot appends, DT and board patches
- meta-alpha-product: product images, packagegroups and company-level defaults

The intent is to keep vendor BSP layers as the source of SoC truth while storing
ALPHA-specific board and product customization in separate integration layers.
