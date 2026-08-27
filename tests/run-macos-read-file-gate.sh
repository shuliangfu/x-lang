#!/usr/bin/env bash
# B-16 v2: macOS open/read file smoke (delegates run-sys-read-file-gate; Darwin only).
#
# Honesty: soft XLANG_MACOS_READ_FILE_FAIL retired with sys-read soft FAIL.
# Hard-delegate sys-read (prefer asm / obs Darwin UNDEF / hard Linux).
# Missing macos.x facade marker is hard die.
#
# Usage: ./tests/run-macos-read-file-gate.sh
# Report: delegated run=/obs=/skip= from sys-read-file-gate
# PLATFORM: MACOS|DARWIN only.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

PREFIX="xlang: [XLANG_MACOS_READ_FILE]"

if ! ci_is_darwin; then
  echo "macos-read-file-gate: N/A (Darwin only)"
  echo "${PREFIX} status=ok run=0 obs=0 skip=1 host=$(ci_host_summary)"
  exit 0
fi

grep -q 'macos_read_file_into' std/sys/macos.x || {
  echo "macos-read-file-gate FAIL: macos.x missing macos_read_file_into" >&2
  echo "${PREFIX} status=fail run=0 obs=0 skip=0 host=$(ci_host_summary)"
  exit 1
}
chmod +x tests/run-sys-read-file-gate.sh
# soft XLANG_MACOS_READ_FILE_FAIL / XLANG_SYS_READ_FILE_FAIL retired (honesty).
./tests/run-sys-read-file-gate.sh
echo "macos-read-file-gate OK (delegated sys-read-file honesty)"
echo "${PREFIX} status=ok host=$(ci_host_summary)"
exit 0
