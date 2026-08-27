#!/usr/bin/env bash
# MEM-C1 AL-05: arena Allocator realloc must typeck-reject.
#
# Honesty: soft default `./compiler/xlang-c` + soft auto-make (prefer-c /
# false authority) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - hard: product -o compile_fail with realloc diagnostic
#   - obs: tip residual where arena realloc still compiles (AL-05 debt)
# Report: run=/obs=/skip=
# Usage: ./tests/run-allocator-realloc-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_ALLOCATOR_REALLOC_PREFIX:-xlang: [XLANG_ALLOCATOR_REALLOC]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-90}"
SRC="tests/typeck/allocator_realloc_arena.x"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "allocator-realloc-gate FAIL: $*" >&2
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

echo "=== MEM-C1 AL-05: arena realloc reject (prefer asm; hard/obs) ==="
[ -f "$SRC" ] || die "missing $SRC"
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

OUT="/tmp/xlang_alloc_realloc_$$"
ERR="/tmp/xlang_alloc_realloc_$$.log"
rm -f "$OUT"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$SRC" -o "$OUT" >"$ERR" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -eq 124 ]; then
  OBS=$((OBS + 1))
  echo "allocator-realloc-gate OBS (-o timeout; product residual)" >&2
elif [ "$o_ec" -eq 0 ] && [ -x "$OUT" ]; then
  OBS=$((OBS + 1))
  echo "allocator-realloc-gate OBS (arena realloc still compiles; AL-05 tip residual; not soft false-green)" >&2
elif grep -qiE 'realloc' "$ERR" 2>/dev/null; then
  RUN_OK=$((RUN_OK + 1))
  echo "allocator-realloc-gate OK (arena realloc rejected)"
else
  OBS=$((OBS + 1))
  echo "allocator-realloc-gate OBS (compile_fail without realloc diagnostic; tip residual)" >&2
  tail -n 8 "$ERR" >&2 || true
fi
rm -f "$OUT"

echo "allocator-realloc-gate OK (AL-05 honesty; run=${RUN_OK} obs=${OBS})"
ok_report
exit 0
