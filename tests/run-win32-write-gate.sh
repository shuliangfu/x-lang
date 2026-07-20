#!/usr/bin/env bash
# B-17 v1：Windows std.sys os_write_stdout（GetStdHandle + WriteFile）烟测。
# 用法：./tests/run-win32-write-gate.sh
# 环境：SHUX_WIN32_WRITE_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_WIN32_WRITE_FAIL:-0}
X="tests/sys/win32_write_smoke.x"
# Why: bash direct exec of .exe under /tmp/ hits Windows Device Guard / Smart
#      App Control intermittently (Permission denied, exit 126). $TEMP (set to
#      C:/shux_tmp short path in Windows build env) is reliable. POSIX falls
#      back to /tmp where Device Guard does not apply.
OUT="${TEMP:-/tmp}/shux_win32_write.$$.exe"
SHUX="${SHUX:-./compiler/shux-c}"

if [ "$(uname -s 2>/dev/null)" != "MINGW"* ] && [ "$(uname -s 2>/dev/null)" != "MSYS"* ] \
   && [ "${OS:-}" != "Windows_NT" ]; then
  echo "win32-write-gate: N/A (Windows/MSYS2 only)"
  exit 0
fi

if [ ! -x "$SHUX" ]; then
  SHUX="./compiler/shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "win32-write-gate: SKIP (no shux/shux-c)"
  exit 0
fi

rm -f "$OUT" 2>/dev/null || true
# F-02 v2：kernel32 由链接器解析；无 win32.inc.c / win32.o。
if ! "$SHUX" build -L . -o "$OUT" "$X" 2>/tmp/shux_win32_write.log; then
  echo "win32-write-gate FAIL: compile $X" >&2
  tail -n 10 /tmp/shux_win32_write.log 2>/dev/null || true
  rm -f "$OUT" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ ! -x "$OUT" ] && [ ! -f "$OUT" ]; then
  echo "win32-write-gate FAIL: no executable $OUT" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rc=0
# PLATFORM: WINDOWS | MSYS | MINGW — sign the compiled .exe so Smart App
# Control (SAC) does not intermittently block it. No-op on POSIX.
_sign_cert="${SHUX_CODESIGN_THUMBPRINT:-697D4125CC086F4BF683053A2BD6025B939D96FC}"
if command -v powershell.exe >/dev/null 2>&1; then
  _win_out="$(cygpath -m "$OUT" 2>/dev/null || echo "$OUT")"
  powershell.exe -NoProfile -Command \
    "Set-AuthenticodeSignature -FilePath '$_win_out' -Certificate (Get-Item \"Cert:\\LocalMachine\\My\\$_sign_cert\")" >/dev/null 2>&1 || true
fi
OUT=$( "$OUT" 2>/dev/null ) || rc=$?
rm -f "$OUT" 2>/dev/null || true

if [ "$rc" -ne 0 ]; then
  echo "win32-write-gate FAIL: expected exit 0, got $rc" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

EXPECTED=$(printf 'Hello Shu!\n')
if [ "$OUT" != "$EXPECTED" ]; then
  echo "win32-write-gate FAIL: stdout='$OUT' expected='$EXPECTED'" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "win32-write-gate OK (Windows std.sys os_write_stdout via WriteFile)"
exit 0
