#!/usr/bin/env bash
# F-02 v2：std.sys win32 去 C 门禁（无 win32*.inc.c + B-17/B-18 委托 + F-01）。
#
# 用法：./tests/run-f02-std-sys-win32-gate.sh
# 环境：SHUX_F02_WIN32_FAIL=1 — 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_F02_WIN32_FAIL:-0}
DOC="analysis/phase-f-f02-v2.md"

die() {
  echo "f02-win32 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== F-02 v2: std.sys win32 remove win32*.inc.c ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-02 v2' "$DOC" || die "doc missing F-02 v2 marker"
[ ! -f std/sys/win32.inc.c ] || die "win32.inc.c should be deleted"
[ ! -f std/sys/win32_net.inc.c ] || die "win32_net.inc.c should be deleted"
grep -q 'GetStdHandle' std/sys/win32.sx || die "win32.sx missing GetStdHandle FFI"
grep -q 'WSAStartup' std/sys/win32_net.sx || die "win32_net.sx missing WSAStartup FFI"
if grep -q 'shux_win32_' std/sys/win32.sx 2>/dev/null; then
  die "win32.sx still references shux_win32_* C shim"
fi
if grep -q 'shux_win32_net_available_c' std/sys/win32_net.sx 2>/dev/null; then
  die "win32_net.sx still references shux_win32_net_available_c"
fi

for g in tests/run-b17-exit-process-gate.sh tests/run-b18-win32-net-gate.sh; do
  if [ -f "$g" ]; then
    echo "=== F-02 v2: delegate $(basename "$g") ==="
    chmod +x "$g"
    if ! "$g"; then
      die "$(basename "$g") sub-gate failed"
    fi
  fi
done

if [ -f tests/run-std-c-inventory-gate.sh ]; then
  echo "=== F-02 v2: delegate run-std-c-inventory-gate (F-01) ==="
  chmod +x tests/run-std-c-inventory-gate.sh
  if ! SHUX_STD_C_INVENTORY_FAIL="$FAIL" tests/run-std-c-inventory-gate.sh; then
    die "std-c-inventory sub-gate failed"
  fi
fi

echo "f02 std.sys win32 gate OK (F-02 v2; Windows smoke N/A on non-Windows hosts)"
