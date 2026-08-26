#!/usr/bin/env bash
# F-atomic v1: std.atomic de-C (atomic.x + seeds/runtime_atomic_glue.from_x.c).
#
# Usage: ./tests/run-f-atomic-v1-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-atomic-v1-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-046 atomic-ordering hard delegate. Soft XLANG_F_ATOMIC_V1_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD-046 already green).
# STD-146 atomic-widen product smoke observational (listed skip residual).
# Report static=/ensure=/glue=/ordering=/widen=/skip=.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-atomic-v1.md"
MANIFEST="tests/baseline/f-atomic-v1-closure.tsv"
PREFIX="xlang: [XLANG_F_ATOMIC_V1]"

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
  echo "f-atomic-v1 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} glue=${GLUE_OK:-0} ordering=${ORDERING_OK:-0} widen=${WIDEN_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
GLUE_OK=0
ORDERING_OK=0
WIDEN_OK=0
SKIP=1

echo "=== F-atomic v1: std.atomic atomic.c → atomic.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-atomic v1' "$DOC" || die "doc missing F-atomic v1 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/atomic/atomic.x ] || die "missing std/atomic/atomic.x"
[ -f compiler/seeds/runtime_atomic_glue.from_x.c ] || die "missing runtime_atomic_glue.from_x.c"
[ ! -f std/atomic/atomic_glue.c ] || die "atomic_glue.c should be deleted"
[ ! -f std/atomic/atomic.c ] || die "atomic.c should be deleted"

while IFS=$'\t' read -r item_id kind anchor _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile)
      [ -f "$anchor" ] || die "missing $anchor ($item_id)"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)"
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
STATIC_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

xlang_compiler_make -q runtime_atomic_glue.o 2>/dev/null \
  || xlang_compiler_make runtime_atomic_glue.o >/dev/null 2>&1 \
  || die "runtime_atomic_glue.o build failed"
GLUE_OK=1

xlang_compiler_make ../std/atomic/atomic.o >/dev/null 2>&1 \
  || die "ensure atomic.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

if [ -f tests/run-std-atomic-ordering-gate.sh ]; then
  echo "=== F-atomic v1: delegate run-std-atomic-ordering-gate ==="
  chmod +x tests/run-std-atomic-ordering-gate.sh
  if ! tests/run-std-atomic-ordering-gate.sh; then
    die "std-atomic-ordering sub-gate failed"
  fi
  ORDERING_OK=1
fi

# STD-146 widen product residual (listed skip) — observational only.
if [ -f tests/run-std-atomic-widen-gate.sh ]; then
  echo "=== F-atomic v1: std-atomic-widen (observational; product residual) ==="
  chmod +x tests/run-std-atomic-widen-gate.sh
  if tests/run-std-atomic-widen-gate.sh; then
    WIDEN_OK=1
  else
    echo "f-atomic-v1 WARN: std-atomic-widen failed (observational)" >&2
    WIDEN_OK=0
  fi
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} glue=${GLUE_OK} ordering=${ORDERING_OK} widen=${WIDEN_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-atomic-v1 std.atomic gate OK (F-atomic v1; honesty)"
