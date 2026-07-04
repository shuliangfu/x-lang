#!/usr/bin/env bash
# B-19：std.sys/mod.x 统一门面 os_write/read/mmap/exit/close。
#
# 用法：./tests/run-b19-sys-mod-facade-gate.sh
set -e
cd "$(dirname "$0")/.."

MOD="std/sys/mod.x"
echo "=== B-19: std.sys mod facade ==="
[ -f "$MOD" ] || { echo "b19 gate FAIL: missing mod.x" >&2; exit 1; }
for sym in os_write os_read os_mmap os_exit os_close; do
  grep -q "function ${sym}(" "$MOD" || { echo "b19 gate FAIL: missing $sym in mod.x" >&2; exit 1; }
done
echo "b19 sys-mod-facade gate OK"
