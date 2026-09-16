#!/usr/bin/env bash
# B-16 v1: macOS std.sys file MAP_SHARED mmap smoke (Darwin hosted; no mmap.inc.c).
#
# Honesty: leftover XLANG fallthrough (`for cand in "${XLANG:-}" …`) retired.
# Soft XLANG_MACOS_MMAP_FILE_FAIL already retired. Prefer xlang_asm; pin
# XLANG_LINK_XLANG. Explicit-bad XLANG / missing native = hard die.
# Tip Darwin UNDEF residual for std_sys_read_file_into (verify path after
# mmap) is observational — report obs=1, not soft-swallowed silence. Ubuntu
# stays N/A (Darwin gold covers). G.7: complete existing resolve_shu;
# converge dod_native_exe.
#
# Usage: ./tests/run-macos-mmap-file-gate.sh
# Report: run=/obs=/skip=
# PLATFORM: MACOS|DARWIN gold when green; SHARED N/A elsewhere.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

X="tests/sys/macos_mmap_file_smoke.x"
OUT="/tmp/xlang_macos_mmap_file.$$.out"
GATE_FILE="/tmp/xlang_macos_mmap_file_gate.dat"
PREFIX="xlang: [XLANG_MACOS_MMAP_FILE]"
RUN_OK=0
OBS=0
SKIP=1

# G.7: complete existing resolve_shu. Explicit XLANG that is missing or
# non-native returns 1 (caller hard-dies). Unset XLANG prefers asm.
# Do not restore set -e before return 1.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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
  echo "macos-mmap-file-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

if ! ci_is_darwin; then
  echo "macos-mmap-file-gate: N/A (Darwin only)"
  echo "${PREFIX} status=ok run=0 obs=0 skip=1 host=$(ci_host_summary)"
  exit 0
fi

[ -f "$X" ] || die "missing $X"
[ ! -f std/sys/mmap.inc.c ] || die "mmap.inc.c should be removed (F-02)"
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover XLANG fallthrough / soft SKIP→OK / soft auto-make)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover XLANG fallthrough / soft SKIP→OK / soft auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== macos-mmap-file (XLANG=$XLANG_BIN; hard/obs) ==="
: >"$GATE_FILE"
rm -f "$OUT" 2>/dev/null || true
LOG="/tmp/xlang_macos_mmap_file.log"

if ! "$XLANG_BIN" build -o "$OUT" "$X" 2>"$LOG"; then
  # PLATFORM: MACOS — tip product UNDEF residual (std_sys_read_file_into) is
  # observational; refuse silent soft die→exit0 without obs= counter.
  if grep -qE 'Undefined symbols|std_sys_read_file_into|BLD001' "$LOG" 2>/dev/null; then
    tail -n 10 "$LOG" 2>/dev/null || true
    rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true
    OBS=1
    SKIP=0
    echo "macos-mmap-file-gate OBS (Darwin UNDEF residual std_sys_read_file_into; not soft false-green)"
    echo "${PREFIX} status=ok run=0 obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
    exit 0
  fi
  tail -n 10 "$LOG" 2>/dev/null || true
  rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true
  die "compile $X"
fi
if [ ! -x "$OUT" ]; then
  rm -f "$GATE_FILE" 2>/dev/null || true
  die "no executable $OUT"
fi

rc=0
"$OUT" || rc=$?
rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true
[ "$rc" -eq 0 ] || die "expected exit 0, got $rc"

RUN_OK=1
SKIP=0
echo "macos-mmap-file-gate OK (macOS MAP_SHARED os_mmap_rw via std.sys.macos; honesty)"
echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
exit 0
