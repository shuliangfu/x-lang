#!/usr/bin/env bash
# Debug modules gate (bstrict catalog: run-debug.sh).
# Merged: core.debug + core.assert + std.debug.
#
# Honesty: soft default `./compiler/xlang-c` + soft auto-make (prefer-c /
# false authority) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - hard: product -o tests/{debug,core-assert,std-debug}/main.x + run exit 0
#   - hard: std-debug stderr contains "debug line"
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

PREFIX="${XLANG_DEBUG_PREFIX:-xlang: [XLANG_DEBUG]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "debug test FAIL: $*" >&2
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
    # Explicit XLANG that is not native = hard die (refuse soft fallthrough).
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

# Compile SRC to OUT and require run exit 0. Optional: require stderr needle.
# PLATFORM: SHARED — product -o path; Ubuntu gold still required.
run_product_case() {
  local label="$1"
  local src="$2"
  local out="$3"
  local err_log="$4"
  local stderr_needle="${5:-}"
  local o_ec r_ec run_out run_err

  [ -f "$src" ] || die "missing $src"
  rm -f "$out" "$err_log"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$src" -o "$out" >"$err_log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    die "$label product -o timeout"
  elif [ "$o_ec" -ne 0 ] || [ ! -x "$out" ]; then
    die "$label product -o failed (ec=$o_ec); $(tail -5 "$err_log" 2>/dev/null | tr '\n' ' ')"
  fi

  run_out="${out}.stdout"
  run_err="${out}.stderr"
  rm -f "$run_out" "$run_err"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$out" >"$run_out" 2>"$run_err"
  r_ec=$?
  set -e
  if [ "$r_ec" -eq 124 ]; then
    die "$label run timeout"
  elif [ "$r_ec" -ne 0 ]; then
    die "$label run exit=$r_ec (expect 0)"
  fi
  if [ -n "$stderr_needle" ]; then
    grep -q "$stderr_needle" "$run_err" || die "$label missing stderr '$stderr_needle'"
  fi
  RUN_OK=$((RUN_OK + 1))
  echo "debug OK: $label exit=0"
  rm -f "$out" "$run_out" "$run_err"
}

echo "=== debug gate: core.debug + core.assert + std.debug (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

run_product_case "core.debug" \
  "tests/debug/main.x" \
  "/tmp/xlang_debug_$$" \
  "/tmp/xlang_debug_$$.log"

run_product_case "core.assert" \
  "tests/core-assert/main.x" \
  "/tmp/xlang_core_assert_$$" \
  "/tmp/xlang_core_assert_$$.log"

run_product_case "std.debug" \
  "tests/std-debug/main.x" \
  "/tmp/xlang_std_debug_$$" \
  "/tmp/xlang_std_debug_$$.log" \
  "debug line"

echo "debug test OK"
ok_report
