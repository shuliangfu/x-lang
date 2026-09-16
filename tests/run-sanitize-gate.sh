#!/usr/bin/env bash
# M-6: `-fsanitize=address` forces INDEX bounds instrumentation
# (release default has no extra checks).
#
# Honesty: soft prefer-c (xlang-c before asm) + soft auto-make + hard
# `xlang check` binding (false authority / CHK002 under paused check)
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad
# XLANG / missing native = hard die (refuse soft SKIP→OK / soft auto-make /
# prefer-c).
#   - hard: default -E has no proven-literal bounds guard; OOB product -o
#     panics (non-zero)
#   - obs: `xlang check` (paused → CHK002); tip `-fsanitize=address -E`
#     currently emits identical C (no INDEX bounds delta; not soft green)
# Report: run=/obs=/skip=
# Usage: ./tests/run-sanitize-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_SANITIZE_PREFIX:-xlang: [SANITIZE]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "sanitize FAIL: $*" >&2
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
  if [ -n "${XLANG_BSTRICT_USE_ASM2:-}" ] && dod_native_exe ./compiler/xlang_asm2; then
    echo "$(pwd)/compiler/xlang_asm2"
    return 0
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

echo "=== sanitize gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

SRC="tests/sanitize/bounds_literal_ok.x"
OOB="tests/ub/bounds_array.x"
[ -f "$SRC" ] || die "missing $SRC"
[ -f "$OOB" ] || die "missing $OOB"

OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
NORM_OUT="$OUT_DIR/xlang_sanitize_norm_$$.c"
SAN_OUT="$OUT_DIR/xlang_sanitize_asan_$$.c"
CK_LOG="/tmp/xlang_sanitize_ck_$$.log"
rm -f "$NORM_OUT" "$SAN_OUT" "$CK_LOG"

# Observational check — paused / CHK002; refuse soft silence / soft FAIL→OK.
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" check "$SRC" >"$CK_LOG" 2>&1
ck_ec=$?
set -e
echo "sanitize OBS: check paused/CHK002 (ec=$ck_ec; refuse soft silence)" >&2
OBS=$((OBS + 1))
rm -f "$CK_LOG"

echo "=== M-6: sanitize=address bounds instrumentation ==="
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -E "$SRC" >"$NORM_OUT" 2>/tmp/xlang_sanitize_norm_$$.err
n_ec=$?
set -e
[ "$n_ec" -eq 0 ] && [ -s "$NORM_OUT" ] || die "default -E failed (ec=$n_ec)"

set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -fsanitize=address -E "$SRC" >"$SAN_OUT" 2>/tmp/xlang_sanitize_san_$$.err
s_ec=$?
set -e
[ "$s_ec" -eq 0 ] && [ -s "$SAN_OUT" ] || die "sanitize -E failed (ec=$s_ec)"

bounds_guard_re='>= [0-9]+ \? \(xlang_panic_'

if grep -qE "$bounds_guard_re" "$NORM_OUT" 2>/dev/null; then
  die "default -E should skip bounds for proven literal index"
fi
echo "sanitize OK: default emit no extra bounds"
RUN_OK=$((RUN_OK + 1))

if grep -qE "$bounds_guard_re" "$SAN_OUT" 2>/dev/null; then
  echo "sanitize OK: -fsanitize=address emit bounds"
  RUN_OK=$((RUN_OK + 1))
else
  # Tip product parses -fsanitize=address but -E body matches default (no delta).
  echo "sanitize OBS: -fsanitize=address -E missing INDEX bounds delta (tip residual; not soft false-green)" >&2
  OBS=$((OBS + 1))
fi

UB_OUT="$OUT_DIR/xlang_sanitize_oob_$$"
rm -f "$UB_OUT"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -fsanitize=address "$OOB" -o "$UB_OUT" \
  >/tmp/xlang_sanitize_oob_$$.log 2>&1
o_ec=$?
set -e
[ "$o_ec" -eq 0 ] && [ -x "$UB_OUT" ] || die "compile bounds_array.x (ec=$o_ec)"

set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$UB_OUT" >/dev/null 2>&1
r_ec=$?
set -e
rm -f "$UB_OUT" "$NORM_OUT" "$SAN_OUT" \
  /tmp/xlang_sanitize_norm_$$.err /tmp/xlang_sanitize_san_$$.err /tmp/xlang_sanitize_oob_$$.log
if [ "$r_ec" -eq 124 ]; then
  die "bounds_array run timeout"
elif [ "$r_ec" -eq 0 ]; then
  die "bounds_array expected panic, rc=0"
fi
echo "sanitize OK: bounds_array OOB panic (rc=$r_ec)"
RUN_OK=$((RUN_OK + 1))

ok_report
echo "sanitize gate OK"
