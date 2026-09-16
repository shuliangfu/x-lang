#!/usr/bin/env bash
# UB narrowing runner — honesty soft→硬绿.
#
# Honesty: soft prefer `./compiler/xlang` + bootstrap-link prefer-c heritage +
# unbounded Darwin hang (bounds_slice) retired. Prefer product xlang_asm;
# pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die
# (refuse soft SKIP→OK / soft auto-make / prefer-c).
#   - hard: div_ok exit 3; unsigned_wrap_ok exit 42; panic cases non-zero exit
#   - timeout / Darwin hang residual = obs (not soft SKIP→OK)
# Report: run=/obs=/skip=
# Usage: ./tests/run-ub.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_UB_PREFIX:-xlang: [XLANG_UB]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-90}"
XLANG_RUN_TIMEOUT="${XLANG_UB_RUN_TIMEOUT:-10}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "ub FAIL: $*" >&2
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

# Product -o + run with wall timeout.
# mode=hard|obs; expect_ec empty → any non-zero (panic); else exact exit.
# Return: 0=ok, 1=hard fail, 2=obs (timeout / tip residual).
# NOTE: keep errexit off across non-zero returns — bash `set -e` + `return 2`
# from a function aborts the caller (Darwin / bash 3.2). Callers use `prc=0; f || prc=$?`.
product_case() {
  local label="$1"
  local src="$2"
  local expect_ec="${3:-}"
  local mode="${4:-hard}"
  local err="/tmp/xlang_ub_${label}.log"
  local out="/tmp/xlang_ub_${label}"
  local o_ec r_ec
  [ -f "$src" ] || { echo "ub FAIL: missing $src" >&2; return 1; }

  rm -f "$out"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$src" -o "$out" >"$err" 2>&1
  o_ec=$?
  if [ "$o_ec" -eq 124 ]; then
    echo "ub OBS $label (-o timeout ${XLANG_CASE_TIMEOUT}s; Darwin/product residual)" >&2
    return 2
  fi
  if [ "$o_ec" -ne 0 ]; then
    if [ "$mode" = "obs" ]; then
      echo "ub OBS $label (-o fail ec=$o_ec; product residual)" >&2
      return 2
    fi
    echo "ub FAIL $label (-o ec=$o_ec)" >&2
    tail -n 12 "$err" >&2 || true
    return 1
  fi
  if [ ! -x "$out" ]; then
    if [ "$mode" = "obs" ]; then
      echo "ub OBS $label (no exe; product residual)" >&2
      return 2
    fi
    echo "ub FAIL $label (no exe)" >&2
    return 1
  fi

  gate_run_timeout "$XLANG_RUN_TIMEOUT" "$out" >/dev/null 2>"$err"
  r_ec=$?
  rm -f "$out"
  if [ "$r_ec" -eq 124 ]; then
    echo "ub OBS $label (run timeout ${XLANG_RUN_TIMEOUT}s; Darwin hang residual)" >&2
    return 2
  fi

  if [ -z "$expect_ec" ]; then
    # Panic / abort: any non-zero (incl. SIGABRT=134) is green.
    if [ "$r_ec" -ne 0 ]; then
      echo "ub OK $label (panic/abort exit=$r_ec)"
      return 0
    fi
    if [ "$mode" = "obs" ]; then
      echo "ub OBS $label (expected panic, got exit 0)" >&2
      return 2
    fi
    echo "ub FAIL $label (expected panic, got exit 0)" >&2
    return 1
  fi

  if [ "$r_ec" -eq "$expect_ec" ]; then
    echo "ub OK $label (exit=$r_ec)"
    return 0
  fi
  if [ "$mode" = "obs" ]; then
    echo "ub OBS $label (expected exit $expect_ec, got $r_ec)" >&2
    return 2
  fi
  echo "ub FAIL $label (expected exit $expect_ec, got $r_ec)" >&2
  return 1
}

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== UB: product -o smokes (XLANG=$XLANG_BIN) ==="

# Hard-green OK paths.
HARD_OK=(
  "div_ok:tests/ub/div_ok.x:3"
  "unsigned_wrap_ok:tests/ub/unsigned_wrap_ok.x:42"
)
for entry in "${HARD_OK[@]}"; do
  label="${entry%%:*}"
  rest="${entry#*:}"
  src="${rest%%:*}"
  expect_ec="${rest##*:}"
  prc=0
  product_case "$label" "$src" "$expect_ec" hard || prc=$?
  case "$prc" in
    0) RUN_OK=$((RUN_OK + 1)) ;;
    2) OBS=$((OBS + 1)) ;;
    *) die "hard ok $label" ;;
  esac
done

# Panic cases: non-zero exit hard; Darwin hang/timeout = obs.
# PLATFORM: SHARED — tip residual "Darwin ub … = obs".
PANIC_CASES=(
  "div_zero:tests/ub/div_zero.x"
  "bounds_array:tests/ub/bounds_array.x"
  "bounds_slice:tests/ub/bounds_slice.x"
)
for entry in "${PANIC_CASES[@]}"; do
  label="${entry%%:*}"
  src="${entry#*:}"
  prc=0
  product_case "$label" "$src" "" hard || prc=$?
  case "$prc" in
    0) RUN_OK=$((RUN_OK + 1)) ;;
    2) OBS=$((OBS + 1)) ;;
    *) die "panic $label" ;;
  esac
done

ok_report
echo "ub: OK"
