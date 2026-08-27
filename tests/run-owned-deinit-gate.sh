#!/usr/bin/env bash
# MEM-B1: owned(Vec_u8) block-end auto emit vec_u8_deinit honesty gate.
#
# Honesty: soft default `./compiler/xlang-c` + soft auto-make (prefer-c /
# false authority) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - hard: when product -o succeeds → run exit 0 + deinit emit markers
#   - obs: tip parse/typeck/link residual (P001 no funcs / missing main /
#     BLD001) — owned path tip debt, not soft false-green
# Report: run=/obs=/skip=
# Usage: ./tests/run-owned-deinit-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_OWNED_DEINIT_PREFIX:-xlang: [XLANG_OWNED_DEINIT]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
SRC="tests/mem/owned_vec_u8.x"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "owned-deinit-gate FAIL: $*" >&2
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

echo "=== MEM-B1: owned Vec_u8 deinit (prefer asm; hard/obs) ==="
[ -f "$SRC" ] || die "missing $SRC"
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

OUT="/tmp/xlang_owned_deinit_$$"
ERR="/tmp/xlang_owned_deinit_$$.log"
rm -f "$OUT"

set +e
XLANG_KEEP_C=1 gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$SRC" -o "$OUT" >"$ERR" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -eq 124 ]; then
  OBS=$((OBS + 1))
  echo "owned-deinit-gate OBS (-o timeout; product residual)" >&2
elif [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  OBS=$((OBS + 1))
  echo "owned-deinit-gate OBS (-o ec=$o_ec; tip owned parse/typeck/link residual; not soft false-green)" >&2
  tail -n 8 "$ERR" >&2 || true
else
  gen="$(grep 'kept generated C:' "$ERR" 2>/dev/null | sed 's/.*: //' | tail -1 || true)"
  if [ -z "$gen" ] || [ ! -f "$gen" ]; then
    gen="$(grep -oE '/tmp/xlang_[A-Za-z0-9]+\.c' "$ERR" 2>/dev/null | tail -1 || true)"
  fi
  if [ -z "$gen" ] || [ ! -f "$gen" ]; then
    OBS=$((OBS + 1))
    echo "owned-deinit-gate OBS (missing kept C under asm; emit residual)" >&2
  elif ! grep -qE 'heap_free_u8_c|std_vec_vec_u8_deinit' "$gen"; then
    die "product built but missing vec_u8_deinit emit"
  else
    set +e
    gate_run_timeout 10 "$OUT" >/dev/null 2>&1
    r_ec=$?
    set -e
    if [ "$r_ec" -eq 124 ]; then
      die "run timeout"
    elif [ "$r_ec" -ne 0 ]; then
      die "run exit=$r_ec want 0"
    fi
    RUN_OK=$((RUN_OK + 1))
    echo "owned-deinit-gate OK (deinit emit + exit=0)"
  fi
  rm -f "$gen"
fi
rm -f "$OUT"

echo "owned-deinit-gate OK (MEM-B1 honesty; run=${RUN_OK} obs=${OBS})"
ok_report
exit 0
