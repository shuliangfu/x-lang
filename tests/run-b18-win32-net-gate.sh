#!/usr/bin/env bash
# B-18：std.sys win32 网络门面（WSA 探测）。
#
# 用法：./tests/run-b18-win32-net-gate.sh
set -e
cd "$(dirname "$0")/.."

echo "=== B-18: std.sys win32 net facade (F-02 v2) ==="
[ -f std/sys/win32_net.x ] || { echo "b18 gate FAIL: missing win32_net.x" >&2; exit 1; }
[ ! -f std/sys/win32_net.inc.c ] || { echo "b18 gate FAIL: win32_net.inc.c should be removed" >&2; exit 1; }
grep -q 'WSAStartup' std/sys/win32_net.x || { echo "b18 gate FAIL: missing WSAStartup FFI" >&2; exit 1; }
grep -q 'win32_net_available' std/sys/win32_net.x || { echo "b18 gate FAIL: facade fn" >&2; exit 1; }
echo "b18 win32-net gate OK"
