#!/bin/bash
# Apply the device's patches to core repositories using relative paths:
# FBE decryption fixes (recovery, vold) and scripted ADB sideload fixes (recovery).
#
# Every run starts from a clean state: the files the patches touch (now, or on
# the last run) are restored to HEAD first, so a changed or removed patch never
# leaves a stale copy behind. What gets reverted is saved to
# <repo>/.git/a9y18qlte-before-reapply.diff in case a file held other edits.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
FAILED=0

# patch_files <patch>...: the paths the patches read or write, one per line
patch_files() {
    sed -n -e 's|^--- a/||p' -e 's|^+++ b/||p' "$@" | sort -u
}

# reapply <repo dir> <patch>...
reapply() {
    local repo="$1"; shift
    local git_dir record backup f name
    git_dir="$(git -C "${repo}" rev-parse --absolute-git-dir)" || { FAILED=1; return; }
    record="${git_dir}/a9y18qlte-patched-files"
    backup="${git_dir}/a9y18qlte-before-reapply.diff"

    local files
    mapfile -t files < <( { patch_files "$@"; [ -f "${record}" ] && cat "${record}"; } | sort -u)

    # Leave other local changes alone, but say so.
    local others
    others="$(git -C "${repo}" status --porcelain --untracked-files=no | cut -c4- | grep -vxF -f <(printf '%s\n' "${files[@]}"))"
    [ -n "${others}" ] && printf '[!] Not touching other local changes:\n%s\n' "${others}"

    # 1. Remove the old patches: restore their files to HEAD.
    git -C "${repo}" diff HEAD -- "${files[@]}" > "${backup}"
    for f in "${files[@]}"; do
        if git -C "${repo}" cat-file -e "HEAD:${f}" 2>/dev/null; then
            git -C "${repo}" checkout -q HEAD -- "${f}"
        else
            rm -f "${repo}/${f}"   # created by a patch
        fi
    done
    [ -s "${backup}" ] && echo "[*] Reverted the old patches (saved to ${backup})"

    # 2. Apply the current ones in order.
    for PATCH in "$@"; do
        name="$(basename "${PATCH}")"
        if git -C "${repo}" apply "${PATCH}"; then
            echo "[+] Applied ${name}"
        else
            echo "[-] FAILED to apply ${name}"
            FAILED=1
        fi
    done

    patch_files "$@" > "${record}"
}

echo "=== Applying patches for a9y18qlte ==="

# 1. bootable/recovery
RECOVERY_DIR="${ROOT_DIR}/bootable/recovery"
if [ -d "${RECOVERY_DIR}" ]; then
    echo "bootable/recovery:"
    reapply "${RECOVERY_DIR}" "${SCRIPT_DIR}"/patches/bootable_recovery*.patch
fi

# 2. system/vold
VOLD_DIR="${ROOT_DIR}/system/vold"
if [ -d "${VOLD_DIR}" ]; then
    echo "system/vold:"
    reapply "${VOLD_DIR}" "${SCRIPT_DIR}"/patches/system_vold*.patch
fi

if [ "${FAILED}" -ne 0 ]; then
    echo "=== Done, with FAILURES ==="
    exit 1
fi
echo "=== Done ==="
