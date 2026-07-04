#!/usr/bin/env bash
# B-15：std.sys io_uring 门面 + std.io 探测一致。
#
# 用法：./tests/run-b15-io-uring-sys-gate.sh
set -e
cd "$(dirname "$0")/.."

echo "=== B-15: std.sys io_uring facade ==="
for f in std/sys/linux_io_uring.x std/io/mod.x std/io/core.x; do
  [ -f "$f" ] || { echo "b15 gate FAIL: missing $f" >&2; exit 1; }
done
grep -q 'shux_io_uring_is_available_c' std/sys/linux_io_uring.x || { echo "b15 gate FAIL: facade" >&2; exit 1; }
grep -q 'io_uring' std/io/mod.x || grep -q 'shux_io_uring' std/io/core.x || grep -q 'shux_io_uring' compiler/src/io/io.c || {
  echo "b15 gate FAIL: std.io io_uring impl ref" >&2
  exit 1
}
echo "b15 io-uring-sys gate OK"
