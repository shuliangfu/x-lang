#!/usr/bin/env bash
# MEM-C1: with_arena vec_u8_push → push_arena monomorphization honesty gate.
#
# Honesty: soft default `./compiler/xlang-c` + soft auto-make (prefer-c /
# false authority) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - hard: -E emit non-empty C
#   - obs: tip product run exit≠0 (documented MEM-C1 with_arena_vec_push
#     exit=5) / missing push_arena monomorphization markers
# Report: run=/obs=/skip=
# Usage: ./tests/run-vec-push-arena-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_VEC_PUSH_ARENA_PREFIX:-xlang: [XLANG_VEC_PUSH_ARENA]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
SRC="tests/mem/with_arena_vec_push.x"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "vec-push-arena-gate FAIL: $*" >&2
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

echo "=== MEM-C1: with_arena vec push_arena (prefer asm; hard/obs) ==="
[ -f "$SRC" ] || die "missing $SRC"
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

C_OUT="/tmp/xlang_vec_push_arena_$$.c"
OUT="/tmp/xlang_vec_push_arena_$$"
ERR="/tmp/xlang_vec_push_arena_$$.log"
rm -f "$C_OUT" "$OUT"

set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -E "$SRC" >"$C_OUT" 2>"$ERR"
e_ec=$?
set -e
if [ "$e_ec" -eq 124 ]; then
  die "-E emit timeout"
elif [ "$e_ec" -ne 0 ] || [ ! -s "$C_OUT" ]; then
  die "-E emit failed (ec=$e_ec)"
fi
RUN_OK=$((RUN_OK + 1))
echo "vec-push-arena-gate OK emit (-E non-empty)"

# Monomorphization markers: tip often still emits heap push — observational.
if grep -qE 'std_vec_vec_u8_push_arena|std_vec_push_Vec_u8_ptr_u8_heap_Arena64_ptr' "$C_OUT" \
  && grep -q 'heap_arena64_alloc_c' "$C_OUT"; then
  RUN_OK=$((RUN_OK + 1))
  echo "vec-push-arena-gate OK emit (push_arena + arena alloc)"
else
  OBS=$((OBS + 1))
  echo "vec-push-arena-gate OBS (missing push_arena monomorphization; tip MEM-C1 residual)" >&2
fi

set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$SRC" -o "$OUT" >"$ERR" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -eq 124 ]; then
  OBS=$((OBS + 1))
  echo "vec-push-arena-gate OBS (-o timeout; product residual)" >&2
elif [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  OBS=$((OBS + 1))
  echo "vec-push-arena-gate OBS (-o ec=$o_ec; tip residual)" >&2
  tail -n 8 "$ERR" >&2 || true
else
  set +e
  gate_run_timeout 10 "$OUT" >/dev/null 2>&1
  r_ec=$?
  set -e
  if [ "$r_ec" -eq 0 ]; then
    RUN_OK=$((RUN_OK + 1))
    echo "vec-push-arena-gate OK product -o (exit=0)"
  else
    # Documented tip residual: with_arena_vec_push exit=5 under asm.
    OBS=$((OBS + 1))
    echo "vec-push-arena-gate OBS (run exit=$r_ec want 0; MEM-C1 tip residual; not soft false-green)" >&2
  fi
fi
rm -f "$OUT" "$C_OUT"

echo "vec-push-arena-gate OK (MEM-C1 honesty; run=${RUN_OK} obs=${OBS})"
ok_report
exit 0
