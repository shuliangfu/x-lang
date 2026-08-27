#!/usr/bin/env bash
# VEC-V1 / VEC-AUTO-001: loop autovec f32 dot honesty gate.
#
# Honesty: soft default `./compiler/xlang-c` + soft auto-make (prefer-c /
# false authority) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - hard: product -o + run exit 0 (scalar correctness still required)
#   - hard: -E emit non-empty C
#   - obs: missing xlang_autovec_dot_f32 / scalar loop still present
#     (autovec.c/h G-02a hard_retired; tip residual, not soft false-green)
# Report: run=/obs=/skip=
# Usage: ./tests/run-autovec-loop-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_AUTOVEC_LOOP_PREFIX:-xlang: [XLANG_AUTOVEC_LOOP]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
SRC="tests/vec/autovec_dot_loop.x"
HELPER='xlang_autovec_dot_f32'
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "autovec-loop-gate FAIL: $*" >&2
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

echo "=== VEC-V1: loop autovec f32 dot (prefer asm; hard/obs) ==="
[ -f "$SRC" ] || die "missing $SRC"
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

OUT="/tmp/xlang_autovec_dot_loop_$$"
C_OUT="/tmp/xlang_autovec_dot_loop_$$.c"
ERR="/tmp/xlang_autovec_dot_loop_$$.log"
rm -f "$OUT" "$C_OUT"

# Emit (-E): must produce non-empty C (hard); helper presence = tip residual.
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
echo "autovec-loop-gate OK emit (-E non-empty)"

if grep -q "$HELPER" "$C_OUT"; then
  if grep -qE 'for \(.*ap\)\[i\].*\*.*\(bp\)\[i\]' "$C_OUT"; then
    die "helper present but scalar dot loop still present"
  fi
  RUN_OK=$((RUN_OK + 1))
  echo "autovec-loop-gate OK emit helper ($HELPER)"
  # Optional: XLANG_NO_AUTovec=1 should preserve scalar when autovec is live.
  set +e
  XLANG_NO_AUTovec=1 gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -E "$SRC" >"${C_OUT}.scalar" 2>/dev/null
  s_ec=$?
  set -e
  if [ "$s_ec" -eq 0 ] && [ -s "${C_OUT}.scalar" ]; then
    if ! grep -qE 'for \(.*ap\)\[i\]|ap\)\[i\].*\*.*bp\)\[i\]' "${C_OUT}.scalar"; then
      OBS=$((OBS + 1))
      echo "autovec-loop-gate OBS (XLANG_NO_AUTovec=1 did not preserve scalar loop)" >&2
    else
      RUN_OK=$((RUN_OK + 1))
      echo "autovec-loop-gate OK NO_AUTovec scalar preserve"
    fi
  else
    OBS=$((OBS + 1))
    echo "autovec-loop-gate OBS (NO_AUTovec -E residual)" >&2
  fi
  rm -f "${C_OUT}.scalar"
else
  OBS=$((OBS + 1))
  echo "autovec-loop-gate OBS (missing $HELPER; autovec.c G-02a retired tip residual)" >&2
  if grep -qE 'for \(.*;.*;.*\)' "$C_OUT"; then
    OBS=$((OBS + 1))
    echo "autovec-loop-gate OBS (scalar for-loop still present; expected without helper)" >&2
  fi
fi

# Product -o + run exit 0 (hard semantic).
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
elif [ "$r_ec" -ne 0 ]; then
  die "run exit=$r_ec want 0"
fi
RUN_OK=$((RUN_OK + 1))
echo "autovec-loop-gate OK product -o (exit=0)"

echo "autovec-loop-gate OK (VEC-V1 honesty; run=${RUN_OK} obs=${OBS})"
ok_report
exit 0
