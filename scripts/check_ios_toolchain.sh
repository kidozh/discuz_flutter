#!/bin/sh
# Used by CocoaPods and the Runner target, including IDE-initiated builds.
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
set --
case "${REQUIRE_IPHONE_DUO:-1}" in
  0|false) ;;
  *) set -- --require-duo ;;
esac
# Xcode's actual build SDK takes precedence over the shell's xcrun selection.
if [ -n "${SDK_VERSION:-}" ]; then
  set -- "$@" --sdk-version "$SDK_VERSION"
fi
if ! python3 "$script_dir/check_iphone_duo.py" "$@"; then
  echo 'error: Select Xcode 27.1+ for this build (DEVELOPER_DIR in the terminal or Flutter run configuration). CocoaPods and Flutter must use the same Xcode.' >&2
  echo 'error: Set REQUIRE_IPHONE_DUO=0 only when intentionally building an older-SDK compatibility app.' >&2
  exit 1
fi
