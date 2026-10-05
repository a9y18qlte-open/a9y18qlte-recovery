#
# Copyright (C) 2026 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#
# Copyright (C) 2026 The OrangeFox Recovery Project
# SPDX-License-Identifier: GPL-3.0-or-later
#

# Inherit from common AOSP config
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)

# Exclude Apex
TW_EXCLUDE_APEX := true

# API
PRODUCT_SHIPPING_API_LEVEL := 26

# qcom decryption
PRODUCT_PACKAGES += \
        qcom_decrypt \
        qcom_decrypt_fbe \
        android.hardware.keymaster@3.0-service \
        android.hardware.keymaster@3.0-impl \
        libkeymaster3device

# Crypto
TW_INCLUDE_CRYPTO := true
BOARD_USES_QCOM_FBE_DECRYPTION := true
PLATFORM_VERSION := 99.87.36
PLATFORM_SECURITY_PATCH := 2127-12-31
VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)
PLATFORM_VERSION_LAST_STABLE := $(PLATFORM_VERSION)

# Libraries
TARGET_RECOVERY_DEVICE_MODULES += \
	libion \
	vendor.display.config@1.0 \
	vendor.display.config@2.0 \
	libdisplayconfig.qti

RECOVERY_LIBRARY_SOURCE_FILES += \
    $(TARGET_OUT_SHARED_LIBRARIES)/libion.so \
    $(TARGET_OUT_SYSTEM_EXT_SHARED_LIBRARIES)/vendor.display.config@1.0.so \
    $(TARGET_OUT_SYSTEM_EXT_SHARED_LIBRARIES)/libdisplayconfig.qti.so

# kernel
  PRODUCT_PROPERTY_OVERRIDES += \
	ro.orangefox.kernel_ver=4.4

#
