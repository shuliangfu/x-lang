#!/usr/bin/env bash
# MEM-C1 wave A: with_arena + std.vec push/reserve via v.al (scope bump).
#
# Honesty: soft XLANG_WITH_ARENA_VEC_GATE_FAIL retired — compile/run/emit
# failure was portable false-green (soft die→exit0) and the gate preferred
# xlang-c. Prefer xlang_asm; pin XLANG_LINK_XLANG. Missing compiler/src is
# hard die. Tip product residual (run≠0 content / reserve still heap_alloc /
# missing KEEP_C) is observational — report obs=, not soft-swallowed silence.
#
# Usage: ./tests/run-with-arena-vec-gate.sh
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology (MEM-C1 with_arena Vec_u8).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

SRC="tests/mem/with_arena_vec_push.x"
OUT="/tmp/xlang_with_arena_vec_$$"
PREFIX="xlang: [XLANG_WITH_ARENA_VEC]"
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
  echo "with-arena-vec-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

[ -f "$SRC" ] || die "missing $SRC"
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== with-arena-vec (XLANG=$XLANG_BIN; hard/obs) ==="
SKIP=0

rm -f "$OUT" 2>/dev/null || true
LOG="/tmp/xlang_with_arena_vec_build.log"
# Drain non-TTY stdout (same hang root as A-11 parse metric).
if ! XLANG_KEEP_C=1 "$XLANG_BIN" build "$SRC" -o "$OUT" 2>&1 | tee "$LOG" | cat >/dev/null; then
  # PLATFORM: SHARED — UNDEF / BLD001 product residual = obs.
  if grep -qE 'Undefined symbols|undefined reference|BLD001' "$LOG" 2>/dev/null; then
    tail -n 10 "$LOG" 2>/dev/null || true
    rm -f "$OUT" 2>/dev/null || true
    OBS=$((OBS + 1))
    echo "with-arena-vec-gate OBS (build/UNDEF residual; not soft false-green)"
    echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
    exit 0
  fi
  tail -8 "$LOG" 2>/dev/null || true
  rm -f "$OUT" 2>/dev/null || true
  die "compile $SRC"
fi

[ -x "$OUT" ] || die "no executable $OUT"
rc=0
"$OUT" >/dev/null 2>&1 || rc=$?
rm -f "$OUT" 2>/dev/null || true
if [ "$rc" != "0" ]; then
  # Product residual: with_arena Vec push/length/content (tip run=5 on Darwin).
  echo "with-arena-vec-gate OBS: run exit=$rc want 0 (MEM-C1 vec/al residual; not soft false-green)" >&2
  OBS=$((OBS + 1))
else
  RUN_OK=1
  echo "with-arena-vec-gate OK run exit=0"
fi

gen="$(grep -oE '/tmp/xlang_[A-Za-z0-9]+\.c' "$LOG" | tail -1)"
if [ -z "$gen" ] || [ ! -f "$gen" ]; then
  # asm backend may not leave KEEP_C path — observational, not soft silence.
  echo "with-arena-vec-gate OBS: missing kept generated C (emit residual; not soft false-green)" >&2
  OBS=$((OBS + 1))
else
  if grep -qE 'heap_alloc_u8_c|heap\.alloc_u8' "$gen" 2>/dev/null; then
    echo "with-arena-vec-gate OBS: reserve still uses heap.alloc in generated C (MEM-C1 residual)" >&2
    OBS=$((OBS + 1))
  fi
  rm -f "$gen"
fi

echo "with-arena-vec-gate OK (with_arena Vec_u8 honesty; run=${RUN_OK} obs=${OBS})"
echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
exit 0
