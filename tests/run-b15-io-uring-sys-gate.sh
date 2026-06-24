#!/usr/bin/env bash
# B-15：std.sys io_uring 门面 + std.io 探测一致。
#
# 用法：./tests/run-b15-io-uring-sys-gate.sh
set -e
cd "$(dirname "$0")/.."

echo "=== B-15: std.sys io_uring facade ==="
for f in std/sys/linux_io_uring.sx std/io/mod.sx std/io/core.sx; do
  [ -f "$f" ] || { echo "b15 gate FAIL: missing $f" >&2; exit 1; }
done
grep -q 'shux_io_uring_is_available_c' std/sys/linux_io_uring.sx || { echo "b15 gate FAIL: facade" >&2; exit 1; }
grep -q 'io_uring' std/io/mod.sx || grep -q 'shux_io_uring' std/io/core.sx || grep -q 'shux_io_uring' compiler/src/io/io.c || {
  echo "b15 gate FAIL: std.io io_uring impl ref" >&2
  exit 1
}
echo "b15 io-uring-sys gate OK"
