#
# Copyright (C) 2025 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/lenovo/malbec

# Inherit from device.mk configuration
$(call inherit-product, $(DEVICE_PATH)/device.mk)

## Device identifier
# Board/product name as reported by the bootloader (fastboot getvar product); model TB390FU.
PRODUCT_DEVICE  := malbec
PRODUCT_NAME    := twrp_malbec
PRODUCT_BRAND   := lenovo
PRODUCT_MODEL   := TB390FU

# Theme
TW_STATUS_ICONS_ALIGN   := center
