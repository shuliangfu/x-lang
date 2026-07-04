#!/usr/bin/env bash
# B-19：std.sys 统一 os_write 烟测（Darwin 常规链接 / Linux freestanding 可选）。
# 用法：./tests/run-sys-platform-write-gate.sh
# 环境：SHUX_SYS_PLATFORM_WRITE_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_SYS_PLATFORM_WRITE_FAIL:-0}
X="tests/sys/sys_platform_write_unified.x"
OUT="/tmp/shux_sys_platform_write.$$.out"
SHUX="${SHUX:-./compiler/shux-c}"

if [ ! -x "$SHUX" ]; then
  SHUX="./compiler/shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "sys-platform-write-gate: SKIP (no shux/shux-c)"
  exit 0
fi

OS="$(uname -s)"
EXTRA=()
if [ "$OS" = "Linux" ]; then
  # Linux 走 freestanding_io 桩（与 sys_write_freestanding 一致）
  EXTRA=(-freestanding -backend asm)
fi

rm -f "$OUT" 2>/dev/null || true

if ! "$SHUX" "${EXTRA[@]}" -o "$OUT" "$X" 2>/tmp/shux_sys_platform_write.log; then
  echo "sys-platform-write-gate FAIL: compile $X on $OS" >&2
  tail -n 10 /tmp/shux_sys_platform_write.log 2>/dev/null || true
  rm -f "$OUT" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ ! -x "$OUT" ]; then
  echo "sys-platform-write-gate FAIL: no executable $OUT" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rc=0
"$OUT" || rc=$?
rm -f "$OUT" 2>/dev/null || true

if [ "$rc" -ne 0 ]; then
  echo "sys-platform-write-gate FAIL: expected exit 0, got $rc on $OS" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "sys-platform-write-gate OK (std.sys os_write_stdout unified on $OS)"
exit 0
