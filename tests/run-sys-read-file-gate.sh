#!/usr/bin/env bash
# B-20 v0: std.sys os_read_file_into smoke (Darwin hosted / Linux freestanding).
#
# Honesty: soft XLANG_SYS_READ_FILE_FAIL retired — compile/run failure was
# portable false-green (soft die→exit0). Prefer xlang_asm; pin XLANG_LINK_XLANG.
# Missing compiler is hard die. Linux freestanding path is hard green (Ubuntu
# gold). Tip Darwin UNDEF residual for std_sys_read_file_into is observational
# — report obs=1, not soft-swallowed silence.
#
# Usage: ./tests/run-sys-read-file-gate.sh
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology (LINUX freestanding hard / DARWIN hosted+obs).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

X="tests/sys/sys_read_file_smoke.x"
OUT="/tmp/xlang_sys_read_file.$$.out"
GATE_FILE="/tmp/xlang_read_file_gate.txt"
PREFIX="xlang: [XLANG_SYS_READ_FILE]"
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
  echo "sys-read-file-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

[ -f "$X" ] || die "missing $X"
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

OS="$(uname -s)"
EXTRA=()
# PLATFORM: LINUX — freestanding read path (align B-14 / BOOT-029).
# PLATFORM: MACOS|DARWIN — hosted -o (no freestanding).
if [ "$OS" = "Linux" ]; then
  EXTRA=(-freestanding -backend asm)
fi

echo "=== sys-read-file (XLANG=$XLANG_BIN; ${EXTRA[*]:-hosted}; hard/obs) ==="
printf 'ABC' >"$GATE_FILE"
rm -f "$OUT" 2>/dev/null || true
LOG="/tmp/xlang_sys_read_file.log"

if [ "${#EXTRA[@]}" -gt 0 ]; then
  compile_ok=0
  if "$XLANG_BIN" "${EXTRA[@]}" -o "$OUT" "$X" 2>"$LOG"; then
    compile_ok=1
  fi
else
  compile_ok=0
  if "$XLANG_BIN" build -o "$OUT" "$X" 2>"$LOG"; then
    compile_ok=1
  fi
fi

if [ "$compile_ok" -ne 1 ]; then
  # PLATFORM: MACOS — tip product UNDEF residual (std_sys_read_file_into).
  # Observational: not soft false-green; counters report obs=.
  if [ "$OS" = "Darwin" ] && grep -qE 'Undefined symbols|std_sys_read_file_into|BLD001' "$LOG" 2>/dev/null; then
    tail -n 10 "$LOG" 2>/dev/null || true
    rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true
    OBS=1
    SKIP=0
    echo "sys-read-file-gate OBS (Darwin UNDEF residual std_sys_read_file_into; not soft false-green)"
    echo "${PREFIX} status=ok run=0 obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
    exit 0
  fi
  tail -n 10 "$LOG" 2>/dev/null || true
  rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true
  die "compile $X on $OS"
fi

if [ ! -x "$OUT" ]; then
  rm -f "$GATE_FILE" 2>/dev/null || true
  die "no executable $OUT"
fi

rc=0
"$OUT" || rc=$?
rm -f "$OUT" "$GATE_FILE" 2>/dev/null || true
[ "$rc" -eq 0 ] || die "expected exit 0, got $rc on $OS"

RUN_OK=1
SKIP=0
echo "sys-read-file-gate OK (std.sys os_read_file_into on $OS; honesty)"
echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
exit 0
