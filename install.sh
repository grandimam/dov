#!/bin/sh
# Faz v0.1.0 installer. Downloaded payloads are pinned by SHA-256 below.
# No sudo, shell-profile edits, or security-setting changes.
set -eu
faz_version=v0.1.0
faz_prefix=${HOME:?HOME must be set}/.local
fail() { printf 'Faz install: %s\n' "$*" >&2; exit 1; }
while [ "$#" -gt 0 ]; do
    case "$1" in
        --prefix) [ "$#" -ge 2 ] || fail '--prefix needs a directory'; faz_prefix=$2; shift 2 ;;
        --help|-h) printf 'Usage: sh install.sh [--prefix DIRECTORY]\nDefault: $HOME/.local\n'; exit 0 ;;
        *) fail "unknown argument: $1" ;;
    esac
done
[ -n "$faz_prefix" ] || fail 'prefix must not be empty'
case "$(uname -s):$(uname -m)" in
    Darwin:arm64)
        faz_platform=darwin-arm64
        faz_os_version=$(/usr/bin/sw_vers -productVersion)
        [ "${faz_os_version%%.*}" -ge 26 ] || fail 'this macOS ARM64 package requires macOS 26 or newer'
        faz_expected=83df5b8935b638ee16db4f76e000124dc64131d441d9f0bd1eab71b15776f87a
        ;;
    Linux:x86_64)
        faz_platform=linux-x86_64
        faz_libc=$(getconf GNU_LIBC_VERSION 2>/dev/null) || fail 'Linux package requires glibc 2.39 or newer (musl is unsupported)'
        faz_libc=${faz_libc#glibc }
        faz_major=${faz_libc%%.*}; faz_minor=${faz_libc#*.}; faz_minor=${faz_minor%%.*}
        case "$faz_major:$faz_minor" in *[!0-9:]*|'') fail 'cannot determine glibc version' ;; esac
        [ "$faz_major" -gt 2 ] || { [ "$faz_major" -eq 2 ] && [ "$faz_minor" -ge 39 ]; } || fail 'Linux package requires glibc 2.39 or newer (Ubuntu 24.04+)'
        faz_expected=6950acce7ce503e746e855b2d5bdcd6c62d34279a9d7f54ab700dbe93d9b6643
        ;;
    *) fail 'supported packages: Linux x86-64 (glibc 2.39+) and macOS ARM64 (macOS 26+)' ;;
esac
[ "${#faz_expected}" -eq 64 ] || fail 'release checksums are not configured'
for faz_command in curl tar mktemp; do command -v "$faz_command" >/dev/null 2>&1 || fail "required system utility missing: $faz_command"; done
if command -v sha256sum >/dev/null 2>&1; then faz_sha=sha256sum
elif command -v shasum >/dev/null 2>&1; then faz_sha=shasum
else fail 'sha256sum or shasum is required'; fi
checksum() { if [ "$faz_sha" = shasum ]; then shasum -a 256 "$1"; else sha256sum "$1"; fi; }
verify_files() { (cd "$1"; if [ "$faz_sha" = shasum ]; then shasum -a 256 -c FILES.sha256; else sha256sum -c FILES.sha256; fi) >/dev/null; }
faz_temp= faz_stage= faz_lock= faz_link=
cleanup() {
    [ -z "$faz_link" ] || rm -f "$faz_link"
    [ -z "$faz_stage" ] || rm -rf "$faz_stage"
    [ -z "$faz_temp" ] || rm -rf "$faz_temp"
    [ -z "$faz_lock" ] || rmdir "$faz_lock"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
mkdir -p "$faz_prefix/bin" "$faz_prefix/lib/faz/versions"
faz_prefix=$(cd "$faz_prefix" && pwd -P)
faz_versions=$faz_prefix/lib/faz/versions
mkdir "$faz_versions/.install-lock" 2>/dev/null || fail "another installer is running, or a stale lock exists: $faz_versions/.install-lock"
faz_lock=$faz_versions/.install-lock
check_destination() {
    if [ -L "$faz_prefix/bin/faz" ]; then
        case "$(readlink "$faz_prefix/bin/faz")" in "$faz_versions/"*/bin/faz) ;; *) fail "preserving existing unmanaged symlink: $faz_prefix/bin/faz; choose another --prefix" ;; esac
    elif [ -e "$faz_prefix/bin/faz" ]; then
        fail "preserving existing file: $faz_prefix/bin/faz; choose another --prefix or move it yourself"
    fi
}
check_destination
faz_name=faz-$faz_version-$faz_platform
faz_destination=$faz_versions/$faz_name-$faz_expected
if [ -d "$faz_destination" ]; then
    [ -f "$faz_destination/.archive-sha256" ] && [ "$(cat "$faz_destination/.archive-sha256")" = "$faz_expected" ] || fail 'existing version directory has unexpected provenance; preserving it'
    verify_files "$faz_destination" || fail 'installed files were modified; preserving them (use another --prefix for a clean copy)'
else
    faz_temp=$(mktemp -d "${TMPDIR:-/tmp}/faz-download.XXXXXX")
    faz_archive=$faz_temp/$faz_name.tar.gz
    curl --fail --show-error --location --proto '=https' --tlsv1.2 "https://github.com/grandimam/faz/releases/download/$faz_version/$faz_name.tar.gz" --output "$faz_archive"
    faz_actual=$(checksum "$faz_archive"); faz_actual=${faz_actual%% *}
    [ "$faz_actual" = "$faz_expected" ] || fail 'archive checksum mismatch; existing installation was not changed'
    faz_stage=$(mktemp -d "$faz_versions/.staging.XXXXXX")
    tar -xzf "$faz_archive" -C "$faz_stage"
    faz_candidate=$faz_stage/$faz_name
    [ -x "$faz_candidate/bin/faz" ] || fail 'archive does not contain the expected compiler'
    verify_files "$faz_candidate" || fail 'archive file verification failed'
    printf 'fn main():\n    print("Faz is ready.")\n' > "$faz_temp/hello.fz"
    (
        unset FAZ_LLVM_LIBRARY FAZ_LLVM_HOME FAZ_LINKER FAZ_SDKROOT SDKROOT
        export FAZ_LLVM_BUNDLED_ONLY=1 FAZ_TOOLCHAIN_BUNDLED_ONLY=1
        "$faz_candidate/bin/faz" run "$faz_temp/hello.fz"
    ) || fail 'compiler smoke test failed; existing installation was not changed'
    printf '%s\n' "$faz_expected" > "$faz_candidate/.archive-sha256"
    mv "$faz_candidate" "$faz_destination"
fi
check_destination
faz_link=$faz_prefix/bin/.faz-link-$$
ln -s "$faz_destination/bin/faz" "$faz_link"
mv -f "$faz_link" "$faz_prefix/bin/faz"
faz_link=
printf '\nInstalled Faz %s: %s/bin/faz\n' "$faz_version" "$faz_prefix"
printf 'Add this directory to PATH for your current shell (your profile was not edited):\n  %s/bin\n' "$faz_prefix"
printf 'Then run: faz --version\nPrevious managed versions remain in %s\n' "$faz_versions"
