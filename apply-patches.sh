#!/bin/bash
# Apply FBE decryption patches to core repositories using relative paths

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

echo "=== Applying FBE patches for a9y18qlte ==="

# 1. bootable/recovery
RECOVERY_DIR="${ROOT_DIR}/bootable/recovery"
if [ -d "${RECOVERY_DIR}" ]; then
    echo "Checking bootable/recovery..."
    if git -C "${RECOVERY_DIR}" apply --check "${SCRIPT_DIR}/patches/bootable_recovery.patch" 2>/dev/null; then
        git -C "${RECOVERY_DIR}" apply "${SCRIPT_DIR}/patches/bootable_recovery.patch"
        echo "[+] Applied bootable/recovery patch successfully."
    else
        echo "[-] bootable/recovery patch already applied or cannot be applied cleanly."
    fi
fi

# 2. system/vold
VOLD_DIR="${ROOT_DIR}/system/vold"
if [ -d "${VOLD_DIR}" ]; then
    echo "Checking system/vold..."
    if git -C "${VOLD_DIR}" apply --check "${SCRIPT_DIR}/patches/system_vold.patch" 2>/dev/null; then
        git -C "${VOLD_DIR}" apply "${SCRIPT_DIR}/patches/system_vold.patch"
        echo "[+] Applied system/vold patch successfully."
    else
        echo "[-] system/vold patch already applied or cannot be applied cleanly."
    fi
fi

echo "=== Done ==="
