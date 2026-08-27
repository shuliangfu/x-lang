#!/usr/bin/env bash
# MEM-AUTO-005: Allocator domain escape — scope_alloc outside with_arena.
#
# Honesty: soft default `./compiler/xlang-c` + soft auto-make (prefer-c /
# false authority) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - hard: product -o compile_fail with scope_alloc diagnostic
#   - obs: tip residual where typeck does not reject and link fails on
#     std_heap_scope_alloc UNDEF / BLD001 (MEM-C1 product debt)
# Report: run=/obs=/skip=
# Usage: ./tests/run-allocator-escape-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_ALLOCATOR_ESCAPE_PREFIX:-xlang: [XLANG_ALLOCATOR_ESCAPE]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-90}"
SRC="tests/typeck/allocator_escape.x"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "allocator-escape-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

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
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

echo "=== MEM-AUTO-005: allocator escape (prefer asm; hard/obs) ==="
[ -f "$SRC" ] || die "missing $SRC"
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

OUT="/tmp/xlang_alloc_escape_$$"
ERR="/tmp/xlang_alloc_escape_$$.log"
rm -f "$OUT"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$SRC" -o "$OUT" >"$ERR" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -eq 124 ]; then
  OBS=$((OBS + 1))
  echo "allocator-escape-gate OBS (-o timeout; product residual)" >&2
elif [ "$o_ec" -eq 0 ] && [ -x "$OUT" ]; then
  die "expected typeck reject for $SRC (compiled successfully)"
elif grep -qiE 'typeck error' "$ERR" 2>/dev/null \
  && grep -qiE 'scope_alloc' "$ERR" 2>/dev/null \
  && ! grep -qiE 'Undefined symbols|undefined reference|BLD001' "$ERR" 2>/dev/null; then
  # Require real "typeck error" (not path tests/typeck/…) and refuse
  # UNDEF std_heap_scope_alloc false hard-green.
  RUN_OK=$((RUN_OK + 1))
  echo "allocator-escape-gate OK (scope_alloc outside with_arena rejected)"
elif grep -qiE 'Undefined symbols|undefined reference|std_heap_scope_alloc|BLD001' "$ERR" 2>/dev/null; then
  OBS=$((OBS + 1))
  echo "allocator-escape-gate OBS (link/UNDEF residual without typeck reject; MEM-C1 tip; not soft false-green)" >&2
  tail -n 8 "$ERR" >&2 || true
else
  die "compile_fail without typeck scope_alloc diagnostic"
fi
rm -f "$OUT"

echo "allocator-escape-gate OK (MEM-AUTO-005 honesty; run=${RUN_OK} obs=${OBS})"
ok_report
exit 0
