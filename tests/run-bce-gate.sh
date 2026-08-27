#!/usr/bin/env bash
# MEM-A2 BCE v1: proven-in-bounds arr[i] omits xlang_panic_ index guard.
#
# Honesty: soft default `./compiler/xlang-c` + soft auto-make (prefer-c /
# false authority) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - hard: -E emit non-empty C with no index-bounds xlang_panic_ guard
#   - hard: product -o + run exit 36 (sum 1..8)
# Report: run=/obs=/skip=
# Usage: ./tests/run-bce-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_BCE_PREFIX:-xlang: [XLANG_BCE]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
SRC="tests/mem/bce_array.x"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "bce-gate FAIL: $*" >&2
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

echo "=== MEM-A2: BCE array bounds (prefer asm; hard/obs) ==="
[ -f "$SRC" ] || die "missing $SRC"
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

C_OUT="/tmp/xlang_bce_array_$$.c"
OUT="/tmp/xlang_bce_array_$$"
ERR="/tmp/xlang_bce_array_$$.log"
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
if grep -qE '\) >= [0-9]+ \? \(xlang_panic_|length \? \(xlang_panic_' "$C_OUT"; then
  die "generated C still contains index bounds xlang_panic_ guard"
fi
RUN_OK=$((RUN_OK + 1))
echo "bce-gate OK emit (no bounds panic)"

set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$SRC" -o "$OUT" >"$ERR" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -eq 124 ]; then
  die "product -o timeout"
elif [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  die "product -o failed (ec=$o_ec)"
fi
set +e
gate_run_timeout 10 "$OUT" >/dev/null 2>&1
r_ec=$?
set -e
rm -f "$OUT" "$C_OUT"
if [ "$r_ec" -eq 124 ]; then
  die "run timeout"
elif [ "$r_ec" -ne 36 ]; then
  die "run exit=$r_ec want 36 (sum 1..8)"
fi
RUN_OK=$((RUN_OK + 1))
echo "bce-gate OK product -o (exit=36)"

echo "bce-gate OK (MEM-A2 BCE honesty; run=${RUN_OK} obs=${OBS})"
ok_report
exit 0
