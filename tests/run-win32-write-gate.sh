#!/usr/bin/env bash
# B-17 v1: Windows std.sys os_write_stdout (GetStdHandle + WriteFile) smoke.
#
# Honesty: soft XLANG_WIN32_WRITE_FAIL retired — compile/run failure was
# portable false-green (soft die→exit0). Prefer xlang_asm; pin XLANG_LINK_XLANG.
# Missing compiler on Windows is hard die (refuse soft SKIP→OK). Non-Windows
# hosts exit 0 N/A with report counters.
#
# Usage: ./tests/run-win32-write-gate.sh
# Report: run=/skip=
# PLATFORM: WINDOWS gold for run; SHARED N/A elsewhere.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

X="tests/sys/win32_write_smoke.x"
# Why: bash direct exec of .exe under /tmp/ hits Windows Device Guard / Smart
#      App Control intermittently (Permission denied, exit 126). $TEMP (set to
#      C:/xlang_tmp short path in Windows build env) is reliable. POSIX falls
#      back to /tmp where Device Guard does not apply.
OUT="${TEMP:-/tmp}/xlang_win32_write.$$.exe"
PREFIX="xlang: [XLANG_WIN32_WRITE]"
RUN_OK=0
SKIP=1

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Windows probe still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$(pwd)/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

die() {
  echo "win32-write-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

if ! ci_is_windows_msys && [ "${OS:-}" != "Windows_NT" ]; then
  echo "win32-write-gate: N/A (Windows/MSYS2 only)"
  echo "${PREFIX} status=ok run=0 skip=1 host=$(ci_host_summary)"
  exit 0
fi

[ -f "$X" ] || die "missing $X"
[ ! -f std/sys/win32.inc.c ] || die "win32.inc.c should be removed (F-02 v2)"
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== win32-write (XLANG=$XLANG_BIN; hard) ==="
rm -f "$OUT" 2>/dev/null || true
# F-02 v2: kernel32 resolved by linker; no win32.inc.c / win32.o.
if ! "$XLANG_BIN" build -L . -o "$OUT" "$X" 2>/tmp/xlang_win32_write.log; then
  tail -n 10 /tmp/xlang_win32_write.log 2>/dev/null || true
  rm -f "$OUT" 2>/dev/null || true
  die "compile $X"
fi
if [ ! -x "$OUT" ] && [ ! -f "$OUT" ]; then
  die "no executable $OUT"
fi

rc=0
# PLATFORM: WINDOWS | MSYS | MINGW — sign the compiled .exe so Smart App
# Control (SAC) does not intermittently block it. No-op on POSIX.
_sign_cert="${XLANG_CODESIGN_THUMBPRINT:-697D4125CC086F4BF683053A2BD6025B939D96FC}"
if command -v powershell.exe >/dev/null 2>&1; then
  _win_out="$(cygpath -m "$OUT" 2>/dev/null || echo "$OUT")"
  powershell.exe -NoProfile -Command \
    "Set-AuthenticodeSignature -FilePath '$_win_out' -Certificate (Get-Item \"Cert:\\LocalMachine\\My\\$_sign_cert\")" >/dev/null 2>&1 || true
fi
STDOUT_CAPTURE=$("$OUT" 2>/dev/null) || rc=$?
rm -f "$OUT" 2>/dev/null || true

[ "$rc" -eq 0 ] || die "expected exit 0, got $rc"
EXPECTED=$(printf 'Hello Xlang!\n')
[ "$STDOUT_CAPTURE" = "$EXPECTED" ] || die "stdout='$STDOUT_CAPTURE' expected='$EXPECTED'"

RUN_OK=1
SKIP=0
echo "win32-write-gate OK (Windows std.sys os_write_stdout via WriteFile; honesty)"
echo "${PREFIX} status=ok run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
exit 0
