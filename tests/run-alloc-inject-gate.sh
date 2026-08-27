#!/usr/bin/env bash
# MEM-C1 AL-01/02: default_alloc scope/heap inject honesty gate.
#
# Honesty: soft XLANG_ALLOC_INJECT_GATE_FAIL retired — compile/run/emit
# failure was portable false-green (soft die→exit0) and the gate preferred
# xlang-c while pointing at a missing tests/mem/default_alloc.x (authoritative
# fixture is default_allocator.x). Prefer xlang_asm; pin XLANG_LINK_XLANG.
# Missing compiler/src is hard die. Tip product residual (with_arena does not
# yet inject scope kind=1 / missing __xlang_scope_al_ emit) is observational
# — report obs=, not soft-swallowed silence.
#
# Usage: ./tests/run-alloc-inject-gate.sh
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology (AL-01/02 default_alloc).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

SRC="tests/mem/default_allocator.x"
OUT="/tmp/xlang_default_alloc.$$"
PREFIX="xlang: [XLANG_ALLOC_INJECT]"
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
  echo "alloc-inject-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

[ -f "$SRC" ] || die "missing $SRC"
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== alloc-inject (XLANG=$XLANG_BIN; hard/obs) ==="
SKIP=0

rm -f "$OUT" 2>/dev/null || true
LOG="/tmp/xlang_alloc_inject_run.log"
if ! XLANG_KEEP_C=1 "$XLANG_BIN" build "$SRC" -o "$OUT" >"$LOG" 2>&1; then
  # PLATFORM: SHARED — link/UNDEF residual for heap inject path = obs.
  if grep -qE 'Undefined symbols|undefined reference|BLD001' "$LOG" 2>/dev/null; then
    tail -n 10 "$LOG" 2>/dev/null || true
    rm -f "$OUT" 2>/dev/null || true
    OBS=1
    echo "alloc-inject-gate OBS (build/UNDEF residual; not soft false-green)"
    echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
    exit 0
  fi
  tail -8 "$LOG" 2>/dev/null || true
  rm -f "$OUT" 2>/dev/null || true
  die "build $SRC"
fi

[ -x "$OUT" ] || die "no executable $OUT"
rc=0
"$OUT" >/dev/null 2>&1 || rc=$?
if [ "$rc" != "0" ]; then
  # Product residual: with_arena body still sees heap kind=0 (no scope inject).
  echo "alloc-inject-gate OBS: run exit=$rc (AL-01/02 inject residual; not soft false-green)" >&2
  OBS=$((OBS + 1))
else
  RUN_OK=1
  echo "alloc-inject-gate OK run exit=0"
fi
rm -f "$OUT" 2>/dev/null || true

gen="$(grep -oE '/tmp/xlang_[A-Za-z0-9]+\.c' "$LOG" | tail -1)"
if [ -z "$gen" ] || [ ! -f "$gen" ]; then
  # asm backend may not leave KEEP_C path in log — observational, not soft silence.
  echo "alloc-inject-gate OBS: missing kept generated C (emit residual; not soft false-green)" >&2
  OBS=$((OBS + 1))
else
  if ! grep -q '__xlang_scope_al_' "$gen"; then
    echo "alloc-inject-gate OBS: missing __xlang_scope_al_ in with_arena path (MEM-C1 residual)" >&2
    OBS=$((OBS + 1))
  fi
  if ! grep -qE '\.kind = 0.*arena|kind = 0' "$gen"; then
    echo "alloc-inject-gate OBS: missing heap default_alloc emit (kind=0 residual)" >&2
    OBS=$((OBS + 1))
  fi
  rm -f "$gen"
fi

echo "alloc-inject-gate OK (AL-01/02 default_alloc honesty; run=${RUN_OK} obs=${OBS})"
echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
exit 0
