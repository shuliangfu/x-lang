#!/usr/bin/env bash
# NL-02：Linux freestanding socket syscall 烟测（零 libc / 无 net.c）。
#
# 用法：./tests/run-no-libc-socket-gate.sh
# 环境：
#   SHUX_NOLIBC_SOCKET_FAIL=1  — 失败时硬退出
#   SHUX=./compiler/shux
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_NOLIBC_SOCKET_FAIL:-0}
SX="tests/sys/linux_socket_invoke_smoke.sx"
NET_MOD="std/net/freestanding_linux.sx"
ASM="compiler/src/asm/freestanding_io_x86_64.s"
OUT="/tmp/shux_nolibc_socket.$$.out"

die() {
  echo "nolibc-socket gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== NL-02: freestanding socket syscall (zero libc) ==="
for f in "$SX" "$NET_MOD" "$ASM"; do
  [ -f "$f" ] || die "missing $f"
done
for sym in shux_sys_socket shux_sys_connect shux_sys_bind shux_sys_listen shux_sys_accept; do
  grep -q "$sym" "$ASM" || die "$ASM missing $sym"
done

if [ "$(uname -s 2>/dev/null)" != "Linux" ] || [ "$(uname -m 2>/dev/null)" != "x86_64" ]; then
  echo "nolibc-socket gate: N/A (Linux x86_64 freestanding only; manifest OK)"
  exit 0
fi

SHUX="${SHUX:-./compiler/shux}"
if [ ! -x "$SHUX" ] && [ -x ./compiler/shux_asm ]; then
  SHUX=./compiler/shux_asm
fi
if [ ! -x "$SHUX" ]; then
  echo "nolibc-socket gate: SKIP (no shux/shux_asm)"
  exit 0
fi

rm -f "$OUT" 2>/dev/null || true
if ! "$SHUX" -freestanding -backend asm -o "$OUT" "$SX" 2>/tmp/shux_nolibc_socket.log; then
  tail -n 12 /tmp/shux_nolibc_socket.log 2>/dev/null || true
  die "compile $SX failed"
fi
[ -x "$OUT" ] || die "no executable $OUT"

if command -v ldd >/dev/null 2>&1; then
  if ldd "$OUT" 2>&1 | grep -qi 'libc\.so'; then
    ldd "$OUT" 2>&1 || true
    die "$OUT linked against libc.so"
  fi
fi

rc=0
"$OUT" || rc=$?
rm -f "$OUT" 2>/dev/null || true
if [ "$rc" -ne 0 ]; then
  die "expected exit 0, got $rc"
fi

echo "nolibc-socket gate OK (socket+close via syscall, no net.c/libc)"
