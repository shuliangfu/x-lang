#!/usr/bin/env bash
# Ternary operator smoke — honesty soft→硬绿.
#
# Honesty: soft default `./compiler/xlang-c` + soft auto-make (prefer-c /
# false authority) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - hard: product -o main.x exit 10 + clamp.x exit 0
# Report: run=/obs=/skip=
# Usage: ./tests/run-ternary.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_TERNARY_PREFIX:-xlang: [XLANG_TERNARY]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-90}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "ternary FAIL: $*" >&2
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

# Product -o hard green. Return 0=ok, 1=hard fail.
# NOTE: keep errexit off across non-zero returns (bash 3.2 + set -e).
product_run_case() {
  local label="$1"
  local src="$2"
  local expect_ec="$3"
  local err="/tmp/xlang_ternary_${label}.log"
  local out="/tmp/xlang_ternary_${label}"
  local o_ec r_ec
  rm -f "$out"
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" "$src" -o "$out" >"$err" 2>&1
  o_ec=$?
  if [ "$o_ec" -eq 124 ]; then
    echo "ternary FAIL: $label -o timeout" >&2
    return 1
  fi
  if [ "$o_ec" -ne 0 ] || [ ! -x "$out" ]; then
    echo "ternary FAIL: $label -o ec=$o_ec; $(tail -3 "$err" 2>/dev/null | tr '\n' ' ')" >&2
    return 1
  fi
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$out" >/dev/null 2>&1
  r_ec=$?
  if [ "$r_ec" -eq 124 ]; then
    echo "ternary FAIL: $label run timeout" >&2
    return 1
  fi
  if [ "$r_ec" -ne "$expect_ec" ]; then
    echo "ternary FAIL: $label run exit=$r_ec expect=$expect_ec" >&2
    return 1
  fi
  echo "ternary OK: $label exit=$expect_ec"
  return 0
}

echo "=== ternary (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

for f in tests/ternary/main.x tests/ternary/clamp.x; do
  [ -f "$f" ] || die "missing $f"
done

set +e
product_run_case main tests/ternary/main.x 10
prc=$?
set -e
[ "$prc" -eq 0 ] || die "main"
RUN_OK=$((RUN_OK + 1))

set +e
product_run_case clamp tests/ternary/clamp.x 0
prc=$?
set -e
[ "$prc" -eq 0 ] || die "clamp"
RUN_OK=$((RUN_OK + 1))

echo "ternary test OK"
ok_report
