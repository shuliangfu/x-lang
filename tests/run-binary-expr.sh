#!/usr/bin/env bash
# Binary / unary / bitwise / compare / logical expr gate
# (bstrict catalog: run-binary-expr.sh).
#
# Honesty: soft default `./compiler/xlang` + soft auto-make + bootstrap-link
# heritage (false authority) retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die
# (refuse soft SKIP→OK / soft auto-make / prefer-c).
#   - hard: each fixture product -o run with expected exit code
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_BINEXPR_PREFIX:-xlang: [XLANG_BINEXPR]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "binary-expr test FAIL: $*" >&2
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

run_expect() {
  local label="$1" src="$2" expect="$3"
  local out="/tmp/xlang_binexpr_${label}_$$" log="/tmp/xlang_binexpr_${label}_$$.log" o_ec r_ec
  [ -f "$src" ] || die "missing $src"
  rm -f "$out" "$log"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$src" -o "$out" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    die "$label product -o timeout"
  elif [ "$o_ec" -ne 0 ] || [ ! -x "$out" ]; then
    die "$label product -o failed (ec=$o_ec); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
  fi
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$out" >/dev/null 2>&1
  r_ec=$?
  set -e
  rm -f "$out"
  if [ "$r_ec" -eq 124 ]; then
    die "$label run timeout"
  elif [ "$r_ec" -ne "$expect" ]; then
    die "$label expected exit $expect, got $r_ec"
  fi
  RUN_OK=$((RUN_OK + 1))
  echo "binary-expr OK: $label exit=$expect"
}

echo "=== binary-expr gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

run_expect "add" "tests/binary-expr/main.x" 3
run_expect "sub" "tests/binary-expr/sub.x" 32
run_expect "mul" "tests/binary-expr/mul.x" 42
run_expect "div" "tests/binary-expr/div.x" 5
run_expect "precedence" "tests/binary-expr/precedence.x" 7
run_expect "paren" "tests/binary-expr/paren.x" 9
run_expect "unary_neg" "tests/binary-expr/unary_neg.x" 6
run_expect "mod" "tests/binary-expr/mod.x" 1
run_expect "shift" "tests/binary-expr/shift.x" 16
run_expect "bitwise" "tests/binary-expr/bitwise.x" 6
run_expect "compare" "tests/binary-expr/compare.x" 3
run_expect "logical" "tests/binary-expr/logical.x" 2
run_expect "lognot" "tests/binary-expr/lognot.x" 1

echo "binary expr test OK"
ok_report
