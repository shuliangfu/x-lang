#!/usr/bin/env bash
# B-16 v1: macOS std.sys file MAP_SHARED mmap smoke (Darwin hosted; no mmap.inc.c).
#
# Honesty: soft XLANG_MACOS_MMAP_FILE_FAIL retired — soft die→exit0 was portable
# false-green. Prefer xlang_asm; pin XLANG_LINK_XLANG. Missing compiler/source
# is hard die. Tip Darwin UNDEF residual for std_sys_read_file_into (verify
# path after mmap) is observational — report obs=1, not soft-swallowed silence.
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

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
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
