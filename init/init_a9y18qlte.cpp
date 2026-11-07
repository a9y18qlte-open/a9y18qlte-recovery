/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include <string>

#include <android-base/properties.h>
#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>

#include "vendor_init.h"

using android::base::GetProperty;

static void property_override(const std::string& name, const std::string& value) {
    auto* pi = const_cast<prop_info*>(__system_property_find(name.c_str()));
    if (pi != nullptr) {
        __system_property_update(pi, value.c_str(), value.size());
    } else {
        __system_property_add(name.c_str(), name.size(), value.c_str(), value.size());
    }
}

void vendor_load_properties() {
    const std::string bootloader = GetProperty("ro.boot.bootloader", "");
    const bool is_a9200 = bootloader.rfind("A9200", 0) == 0;
    const bool is_a920n = bootloader.rfind("A920N", 0) == 0;

    if (!is_a9200 && !is_a920n) {
        return;
    }

    const char* model;
    const char* name;
    const char* fingerprint;
    const char* description;
    if (is_a9200) {
        model = "SM-A9200";
        name = "a9y18qltezh";
        fingerprint =
                "samsung/a9y18qltezh/a9y18qltechn:10/QP1A.190711.020/A9200ZHU5CZB1:user/"
                "release-keys";
        description = "a9y18qltezh-user 10 QP1A.190711.020 A9200ZHU5CZB1 release-keys";
    } else {
        model = "SM-A920N";
        name = "a9y18qltekx";
        fingerprint =
                "samsung/a9y18qltekx/a9y18qltekx:10/QP1A.190711.020/A920NKSU5CVG1:user/"
                "release-keys";
        description = "a9y18qltekx-user 10 QP1A.190711.020 A920NKSU5CVG1 release-keys";
    }

    for (const auto* partition : {"", "odm.", "product.", "system.", "system_ext.", "vendor."}) {
        property_override(std::string("ro.product.") + partition + "model", model);
        property_override(std::string("ro.product.") + partition + "name", name);
        property_override(std::string("ro.") + partition + "build.fingerprint", fingerprint);
    }
    property_override("ro.build.description", description);
}
