#!/usr/bin/env bash
# B-17 v2: Windows std.sys os_read_file_into (CreateFileA + ReadFile) smoke.
#
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`)
# retired. Soft XLANG_WIN32_READ_FILE_FAIL already retired. Prefer
# xlang_asm; pin XLANG_LINK_XLANG. Explicit-bad XLANG / missing native =
# hard die FIRST (before Windows N/A skip; refuse leftover ignore of
# explicit-bad as Darwin/Ubuntu N/A). Compile/run failure stays hard on
# Windows. Darwin/Ubuntu stay N/A (Windows gold covers). leftover nested
# product path (codesign / ReadFile smoke) stay. G.7: complete existing
# resolve_shu; converge dod_native_exe.
#
# Usage: ./tests/run-win32-read-file-gate.sh
# Report: run=/skip=
# PLATFORM: WINDOWS gold for run; SHARED N/A elsewhere.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

X="tests/sys/win32_read_file_smoke.x"
# Why: Win32 CreateFileA does not recognize MSYS2 /tmp/ mapping; the smoke
#      binary uses a relative path, so the gate file must live in CWD.
GATE_FILE="xlang_win32_read_gate.txt"
# Why: bash direct exec of .exe under /tmp/ hits Windows Device Guard / Smart
#      App Control intermittently (Permission denied, exit 126). $TEMP (set to
#      C:/xlang_tmp short path in Windows build env) is reliable. POSIX falls
#      back to /tmp where Device Guard does not apply.
OUT="${TEMP:-/tmp}/xlang_win32_read_file.$$.exe"
PREFIX="xlang: [XLANG_WIN32_READ_FILE]"
RUN_OK=0
SKIP=1

# G.7: complete existing resolve_shu. Explicit XLANG that is missing or
# non-native returns 1 (caller hard-dies). Unset XLANG prefers asm.
# Do not restore set -e before return 1.
# PLATFORM: SHARED — product path honesty; Windows gold still required.
resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

die() {
  echo "win32-read-file-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

# Explicit XLANG that is missing/non-native hard-dies BEFORE Windows N/A
# skip (refuse leftover SKIP→OK / leftover ignore of explicit-bad /
# leftover XLANG fallthrough as Darwin/Ubuntu N/A). leftover nested
# Windows product path stays when XLANG is unset (do not rewrite leftover
# ReadFile smoke).
# PLATFORM: SHARED — product path honesty; Windows gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
fi

if ! ci_is_windows_msys && [ "${OS:-}" != "Windows_NT" ]; then
  echo "win32-read-file-gate: N/A (Windows/MSYS2 only)"
  echo "${PREFIX} status=ok run=0 skip=1 host=$(ci_host_summary)"
  exit 0
fi

[ -f "$X" ] || die "missing $X"
[ ! -f std/sys/win32.inc.c ] || die "win32.inc.c should be removed (F-02 v2)"
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ignore of explicit-bad / leftover SKIP→OK)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / leftover SKIP→OK / leftover auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== win32-read-file (XLANG=$XLANG_BIN; hard) ==="
printf 'WIN' >"$GATE_FILE"
rm -f "$OUT" 2>/dev/null || true
# F-02 v2: kernel32 resolved by linker; no win32.inc.c / win32.o.
if ! "$XLANG_BIN" build -L . -o "$OUT" "$X" 2>/tmp/xlang_win32_read_file.log; then
  tail -n 10 /tmp/xlang_win32_read_file.log 2>/dev/null || true
  rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true
  die "compile $X"
fi
if [ ! -x "$OUT" ] && [ ! -f "$OUT" ]; then
  rm -f "$GATE_FILE" 2>/dev/null || true
  die "no executable $OUT"
fi

# PLATFORM: WINDOWS | MSYS | MINGW — sign the compiled .exe so Smart App
# Control (SAC) does not intermittently block it (Permission denied, exit 126).
# No-op on POSIX. Matches bootstrap_driver_seed_smoke.sh maybe_codesign.
_sign_cert="${XLANG_CODESIGN_THUMBPRINT:-697D4125CC086F4BF683053A2BD6025B939D96FC}"
if command -v powershell.exe >/dev/null 2>&1; then
  _win_out="$(cygpath -m "$OUT" 2>/dev/null || echo "$OUT")"
  powershell.exe -NoProfile -Command \
    "Set-AuthenticodeSignature -FilePath '$_win_out' -Certificate (Get-Item \"Cert:\\LocalMachine\\My\\$_sign_cert\")" >/dev/null 2>&1 || true
fi
rc=0
"$OUT" || rc=$?
rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true
[ "$rc" -eq 0 ] || die "expected exit 0, got $rc"

RUN_OK=1
SKIP=0
echo "win32-read-file-gate OK (Windows std.sys os_read_file_into via ReadFile; honesty)"
echo "${PREFIX} status=ok run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
exit 0
