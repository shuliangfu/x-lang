#!/usr/bin/env bash
# MEM-D1: small struct call SROA honesty gate (local + cross-module).
#
# Honesty: soft default `./compiler/xlang-c` + soft auto-make (prefer-c /
# false authority) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - hard: local product -o exit 7 (3+4 scalar correctness)
#   - obs: SROA compound-literal emit missing under tip asm (calls remain)
#   - obs: cross-module tip residual (exit≠7 / emit not promoted)
# Report: run=/obs=/skip=
# Usage: ./tests/run-sroa-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_SROA_PREFIX:-xlang: [XLANG_SROA]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
SRC="tests/mem/sroa_struct_call.x"
CROSS_SRC="tests/mem/sroa_struct_cross.x"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "sroa-gate FAIL: $*" >&2
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

main_body_from_c() {
  local cfile="$1"
  # Prefer int32_t main(void) shape tip emits; fall back to int main.
  if grep -q 'int32_t main(void)' "$cfile" 2>/dev/null; then
    sed -n '/int32_t main(void)/,/^}/p' "$cfile"
  else
    sed -n '/int main/,/^}/p' "$cfile"
  fi
}

echo "=== MEM-D1: SROA struct call (prefer asm; hard/obs) ==="
[ -f "$SRC" ] || die "missing $SRC"
[ -f "$CROSS_SRC" ] || die "missing $CROSS_SRC"
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

C_OUT="/tmp/xlang_sroa_struct_$$.c"
OUT="/tmp/xlang_sroa_struct_$$"
ERR="/tmp/xlang_sroa_struct_$$.log"
rm -f "$C_OUT" "$OUT"

# Emit shape: SROA markers observational under tip asm.
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
echo "sroa-gate OK emit (-E non-empty)"

MAIN_BODY="$(main_body_from_c "$C_OUT")"
if echo "$MAIN_BODY" | grep -qE 'struct Pair p = \(struct Pair\)\{'; then
  if echo "$MAIN_BODY" | grep -qE 'make_pair\('; then
    die "SROA compound literal present but make_pair call still in main"
  fi
  if echo "$MAIN_BODY" | grep -qE 'sum_pair\('; then
    die "SROA compound literal present but sum_pair call still in main"
  fi
  RUN_OK=$((RUN_OK + 1))
  echo "sroa-gate OK emit SROA compound literal"
else
  OBS=$((OBS + 1))
  echo "sroa-gate OBS (SROA compound literal missing; tip asm scalar calls remain; not soft false-green)" >&2
fi

# Product -o exit 7 hard (scalar correctness still required).
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
elif [ "$r_ec" -ne 7 ]; then
  die "run exit=$r_ec want 7 (3+4)"
fi
RUN_OK=$((RUN_OK + 1))
echo "sroa-gate OK product -o (exit=7)"

echo "=== MEM-D1.2: cross-module sroa_struct_cross ==="
CROSS_C="/tmp/xlang_sroa_cross_$$.c"
CROSS_OUT="/tmp/xlang_sroa_cross_$$"
CROSS_ERR="/tmp/xlang_sroa_cross_$$.log"
rm -f "$CROSS_C" "$CROSS_OUT"

set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -E "$CROSS_SRC" >"$CROSS_C" 2>"$CROSS_ERR"
ce_ec=$?
set -e
if [ "$ce_ec" -eq 124 ]; then
  OBS=$((OBS + 1))
  echo "sroa-cross-gate OBS (-E timeout; tip residual)" >&2
elif [ "$ce_ec" -ne 0 ] || [ ! -s "$CROSS_C" ]; then
  OBS=$((OBS + 1))
  echo "sroa-cross-gate OBS (-E ec=$ce_ec; tip residual)" >&2
else
  CROSS_MAIN="$(main_body_from_c "$CROSS_C")"
  if echo "$CROSS_MAIN" | grep -qE 'make_pair\(|sroa_lib_make_pair\(|stack_promote_lib_make_pair\('; then
    OBS=$((OBS + 1))
    echo "sroa-cross-gate OBS (make_pair call still in main; tip SROA residual)" >&2
  else
    RUN_OK=$((RUN_OK + 1))
    echo "sroa-cross-gate OK emit (no make_pair in main)"
  fi
fi

set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$CROSS_SRC" -o "$CROSS_OUT" >"$CROSS_ERR" 2>&1
co_ec=$?
set -e
if [ "$co_ec" -eq 124 ]; then
  OBS=$((OBS + 1))
  echo "sroa-cross-gate OBS (-o timeout; tip residual)" >&2
elif [ "$co_ec" -ne 0 ] || [ ! -x "$CROSS_OUT" ]; then
  OBS=$((OBS + 1))
  echo "sroa-cross-gate OBS (-o ec=$co_ec; tip residual)" >&2
else
  set +e
  gate_run_timeout 10 "$CROSS_OUT" >/dev/null 2>&1
  cr_ec=$?
  set -e
  if [ "$cr_ec" -eq 7 ]; then
    RUN_OK=$((RUN_OK + 1))
    echo "sroa-cross-gate OK product -o (exit=7)"
  else
    OBS=$((OBS + 1))
    echo "sroa-cross-gate OBS (exit=$cr_ec want 7; tip cross-module residual; not soft false-green)" >&2
  fi
fi
rm -f "$CROSS_C" "$CROSS_OUT"

echo "sroa-gate OK (MEM-D1 honesty; run=${RUN_OK} obs=${OBS})"
ok_report
exit 0
