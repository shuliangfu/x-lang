#!/usr/bin/env bash
# B-17 v2：Windows std.sys os_read_file_into（CreateFileA + ReadFile）烟测。
# 用法：./tests/run-win32-read-file-gate.sh
# 环境：SHUX_WIN32_READ_FILE_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_WIN32_READ_FILE_FAIL:-0}
X="tests/sys/win32_read_file_smoke.x"
# Why: Win32 CreateFileA does not recognize MSYS2 /tmp/ mapping; the smoke
#      binary uses a relative path, so the gate file must live in CWD.
GATE_FILE="shux_win32_read_gate.txt"
# Why: bash direct exec of .exe under /tmp/ hits Windows Device Guard / Smart
#      App Control intermittently (Permission denied, exit 126). $TEMP (set to
#      C:/shux_tmp short path in Windows build env) is reliable. POSIX falls
#      back to /tmp where Device Guard does not apply.
OUT="${TEMP:-/tmp}/shux_win32_read_file.$$.exe"
SHUX="${SHUX:-./compiler/shux-c}"

if [ "$(uname -s 2>/dev/null)" != "MINGW"* ] && [ "$(uname -s 2>/dev/null)" != "MSYS"* ] \
   && [ "${OS:-}" != "Windows_NT" ]; then
  echo "win32-read-file-gate: N/A (Windows/MSYS2 only)"
  exit 0
fi

if [ ! -x "$SHUX" ]; then
  SHUX="./compiler/shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "win32-read-file-gate: SKIP (no shux/shux-c)"
  exit 0
fi

printf 'WIN' >"$GATE_FILE"
rm -f "$OUT" 2>/dev/null || true
# F-02 v2：kernel32 由链接器解析；无 win32.inc.c / win32.o。
if ! "$SHUX" build -L . -o "$OUT" "$X" 2>/tmp/shux_win32_read_file.log; then
  echo "win32-read-file-gate FAIL: compile $X" >&2
  tail -n 10 /tmp/shux_win32_read_file.log 2>/dev/null || true
  rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ ! -x "$OUT" ] && [ ! -f "$OUT" ]; then
  echo "win32-read-file-gate FAIL: no executable $OUT" >&2
  rm -f "$GATE_FILE" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

# PLATFORM: WINDOWS | MSYS | MINGW — sign the compiled .exe so Smart App
# Control (SAC) does not intermittently block it (Permission denied, exit 126).
# No-op on POSIX. Matches bootstrap_driver_seed_smoke.sh maybe_codesign.
_sign_cert="${SHUX_CODESIGN_THUMBPRINT:-697D4125CC086F4BF683053A2BD6025B939D96FC}"
if command -v powershell.exe >/dev/null 2>&1; then
  _win_out="$(cygpath -m "$OUT" 2>/dev/null || echo "$OUT")"
  powershell.exe -NoProfile -Command \
    "Set-AuthenticodeSignature -FilePath '$_win_out' -Certificate (Get-Item \"Cert:\\LocalMachine\\My\\$_sign_cert\")" >/dev/null 2>&1 || true
fi
rc=0
"$OUT" || rc=$?
rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true

if [ "$rc" -ne 0 ]; then
  echo "win32-read-file-gate FAIL: expected exit 0, got $rc" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "win32-read-file-gate OK (Windows std.sys os_read_file_into via ReadFile)"
exit 0
