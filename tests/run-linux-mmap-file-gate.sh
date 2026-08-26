#!/usr/bin/env bash
# F-02 v1: Linux std.sys file MAP_SHARED mmap smoke (hosted -o exe; no mmap.inc.c).
#
# Usage: ./tests/run-linux-mmap-file-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-linux-mmap-file-gate.sh
# 2026-08-26: Honesty — prefer asm; pin XLANG_LINK_XLANG; hard-fail on Linux
# (no soft die→exit0; no soft SKIP→OK when no native). Soft
# XLANG_LINUX_MMAP_FILE_FAIL retired. Non-Linux hosts exit 0 N/A (platform
# boundary, not soft false-green). Report run=/skip=.
# PLATFORM: LINUX|UBUNTU gold for run; SHARED N/A elsewhere.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

X="tests/sys/linux_mmap_file_smoke.x"
OUT="/tmp/xlang_linux_mmap_file.$$.out"
GATE_FILE="/tmp/xlang_linux_mmap_file_gate.dat"
PREFIX="xlang: [XLANG_LINUX_MMAP_FILE]"

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
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
  echo "linux-mmap-file-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

RUN_OK=0
SKIP=1

if ! ci_is_linux; then
  echo "linux-mmap-file-gate: N/A (Linux only)"
  echo "${PREFIX} status=ok run=0 skip=1 host=$(ci_host_summary)"
  exit 0
fi

[ -f "$X" ] || die "missing $X"
[ ! -f std/sys/mmap.inc.c ] || die "mmap.inc.c should be removed (F-02 v1)"

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi

echo "=== linux-mmap-file (XLANG=$XLANG_BIN; hard) ==="
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1

: >"$GATE_FILE"
rm -f "$OUT" 2>/dev/null || true

if ! "$XLANG_BIN" build -o "$OUT" "$X" 2>/tmp/xlang_linux_mmap_file.log; then
  echo "linux-mmap-file-gate FAIL: compile $X" >&2
  tail -n 10 /tmp/xlang_linux_mmap_file.log 2>/dev/null || true
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

if [ "$rc" -ne 0 ]; then
  die "expected exit 0, got $rc"
fi

RUN_OK=1
SKIP=0
echo "${PREFIX} status=ok run=${RUN_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "linux-mmap-file-gate OK (Linux MAP_SHARED os_mmap_rw via std.sys.linux; F-02 v1; honesty)"
exit 0
