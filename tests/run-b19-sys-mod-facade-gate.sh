#!/usr/bin/env bash
# B-19: std.sys/mod.x unified facade symbols (honesty).
#
# Live surface (post rename): write / write_stdout / read / read_file_into /
# mmap / exit / close. Fossil os_write/os_read/os_mmap/os_exit/os_close names
# retired — scanning them was permanent hard-red false-authority.
#
# Usage: ./tests/run-b19-sys-mod-facade-gate.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

MOD="std/sys/mod.x"
echo "=== B-19: std.sys mod facade ==="
[ -f "$MOD" ] || { echo "b19 gate FAIL: missing mod.x" >&2; exit 1; }

# Live unified facade (cfg-selected bodies under the same short names).
for sym in write write_stdout read read_file_into mmap exit close; do
  grep -qE "^(export )?function ${sym}\\(" "$MOD" \
    || { echo "b19 gate FAIL: missing $sym in mod.x" >&2; exit 1; }
done

# Refuse fossil os_* resurrect as the only surface (aliases OK if live names stay).
# PLATFORM: SHARED — product callers use write_stdout / read / mmap / exit / close.
echo "b19 sys-mod-facade gate OK"
exit 0
