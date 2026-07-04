#!/usr/bin/env bash
# B-17 v3：win32 ExitProcess / std.sys os_exit 门面登记（F-02 v2 纯 .x）。
#
# 用法：./tests/run-b17-exit-process-gate.sh
set -e
cd "$(dirname "$0")/.."

echo "=== B-17 v3: ExitProcess facade ==="
grep -q 'ExitProcess' std/sys/win32.x || { echo "b17 gate FAIL: win32.x missing ExitProcess FFI" >&2; exit 1; }
grep -q 'win32_exit_process' std/sys/win32.x || { echo "b17 gate FAIL: win32.x" >&2; exit 1; }
[ ! -f std/sys/win32.inc.c ] || { echo "b17 gate FAIL: win32.inc.c should be removed (F-02 v2)" >&2; exit 1; }
grep -q 'function os_exit(' std/sys/mod.x || { echo "b17 gate FAIL: mod.x os_exit" >&2; exit 1; }
chmod +x tests/run-win32-write-gate.sh tests/run-win32-read-file-gate.sh 2>/dev/null || true
echo "b17 exit-process gate OK"
