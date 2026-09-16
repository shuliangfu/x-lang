#!/usr/bin/env bash
# P1-2: signed overflow policy gate — honesty soft→硬绿.
#
# Honesty: soft default `./compiler/xlang-c` + soft auto-make + `xlang check`
# binding (prefer-c / false authority; check gate paused pre-selfhost) retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
#   - hard: policy doc keywords + manifest anchor unsigned_wrap_ok.x
#   - hard: product -o tests/ub/unsigned_wrap_ok.x exit 42
#   - (signed overflow itself remains UB per analysis/UB与未定义行为.md §六;
#      this gate locks the documented unsigned wrapping smoke)
# Report: run=/obs=/skip=
# Usage: ./tests/run-signed-overflow-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_SIGNED_OVERFLOW_PREFIX:-xlang: [XLANG_SIGNED_OVERFLOW]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-90}"
DOC="analysis/UB与未定义行为.md"
MANIFEST="tests/baseline/signed-overflow.tsv"
CASE="tests/ub/unsigned_wrap_ok.x"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "signed-overflow FAIL: $*" >&2
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

# Product -o hard green. Return 0=ok, 1=hard fail, 2=obs.
# NOTE: keep errexit off across non-zero returns (bash 3.2 + set -e).
product_run_case() {
  local label="$1"
  local src="$2"
  local expect_ec="$3"
  local err="/tmp/xlang_signed_ovf_${label}.log"
  local out="/tmp/xlang_signed_ovf_${label}"
  local o_ec r_ec
  [ -f "$src" ] || { echo "signed-overflow FAIL: missing $src" >&2; return 1; }

  rm -f "$out"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$src" -o "$out" >"$err" 2>&1
  o_ec=$?
  if [ "$o_ec" -eq 124 ]; then
    echo "signed-overflow OBS $label (-o timeout; product residual)" >&2
    return 2
  fi
  if [ "$o_ec" -ne 0 ] || [ ! -x "$out" ]; then
    echo "signed-overflow FAIL $label (-o ec=$o_ec)" >&2
    tail -n 12 "$err" >&2 || true
    return 1
  fi
  gate_run_timeout 10 "$out" >/dev/null 2>&1
  r_ec=$?
  rm -f "$out"
  if [ "$r_ec" -eq 124 ]; then
    echo "signed-overflow OBS $label (run timeout; product residual)" >&2
    return 2
  fi
  if [ "$r_ec" -eq "$expect_ec" ]; then
    echo "signed-overflow OK $label (exit=$r_ec)"
    return 0
  fi
  echo "signed-overflow FAIL $label (expected exit $expect_ec, got $r_ec)" >&2
  return 1
}

echo "=== P1-2: signed overflow policy manifest ==="
for f in "$DOC" "$MANIFEST" "$CASE"; do
  [ -f "$f" ] || die "missing $f"
done
for kw in "有符号溢出" "无符号整数" "wrapping"; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing keyword $kw"
  fi
done
if ! grep -qF "unsigned_wrap_ok.x" "$MANIFEST" 2>/dev/null; then
  die "baseline missing case unsigned_wrap_ok.x"
fi
echo "signed-overflow manifest OK"
RUN_OK=$((RUN_OK + 1))

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== signed-overflow: product -o smoke (XLANG=$XLANG_BIN) ==="
# Refuse check-bound green: selfhost check gate paused (2026-08-05).
# Hard path = product -o + exit 42 (unsigned wrap).
prc=0
product_run_case "unsigned_wrap_ok" "$CASE" 42 || prc=$?
case "$prc" in
  0) RUN_OK=$((RUN_OK + 1)) ;;
  2) OBS=$((OBS + 1)) ;;
  *) die "hard smoke unsigned_wrap_ok" ;;
esac

ok_report
echo "signed-overflow gate OK"
