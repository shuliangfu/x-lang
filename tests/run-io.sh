#!/usr/bin/env bash
# std.io gate: print_i32/u32/i64, write_stdout, write_with_timeout, print_str,
# read_stdin_ptr / read_ptr_slice (+param) — honesty soft auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … xlang-c … || true` + soft
# process.o make) + soft default `./compiler/xlang` + soft prefer-c via
# RUN_ALL_USE_C / non-asm first (false authority) retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die (refuse soft SKIP→OK / soft auto-make / prefer-c). RUN_ALL_USE_C=1
# may bind native xlang-c when present; missing = hard die (no soft make).
# Product -o cases = hard run. Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-io.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_IO_PREFIX:-xlang: [XLANG_IO]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "io test FAIL: $*" >&2
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
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in compiler/xlang_asm compiler/xlang-c compiler/xlang; do
    abs="$root/$cand"
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

# Product -o then run; require stdout contains needle and exit 0 (unless
# expect_exit set). Args: label src needle [expect_exit=0] [stdin_bytes]
run_stdout() {
  local label="$1" src="$2" needle="$3"
  local expect_exit="${4:-0}"
  local stdin_bytes="${5:-}"
  local out="/tmp/xlang_io_${label}_$$" log="/tmp/xlang_io_${label}_$$.log" o_ec r_ec got
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
  if [ -n "$stdin_bytes" ]; then
    got=$(printf '%s' "$stdin_bytes" | gate_run_timeout "$XLANG_CASE_TIMEOUT" "$out" 2>/dev/null)
    r_ec=$?
  else
    got=$(gate_run_timeout "$XLANG_CASE_TIMEOUT" "$out" 2>/dev/null)
    r_ec=$?
  fi
  set -e
  rm -f "$out"
  if [ "$r_ec" -eq 124 ]; then
    die "$label run timeout"
  fi
  if [ -n "$needle" ]; then
    echo "$got" | grep -q "$needle" \
      || die "$label expected stdout to contain '$needle', got: $got"
  fi
  if [ "$r_ec" -ne "$expect_exit" ]; then
    die "$label expected exit $expect_exit, got $r_ec"
  fi
  RUN_OK=$((RUN_OK + 1))
  echo "io OK: $label exit=$expect_exit"
}

echo "=== io gate (prefer asm; hard; refuse soft auto-make / soft SKIP→OK) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"

# run-all C pipeline: bind xlang-c when present; refuse soft auto-make.
if [ -n "${RUN_ALL_USE_C:-}" ]; then
  if dod_native_exe ./compiler/xlang-c; then
    XLANG_BIN="$(pwd)/compiler/xlang-c"
  else
    die "RUN_ALL_USE_C=1 but no native xlang-c (refuse soft auto-make)"
  fi
fi

export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# F-03 v3: io is pure .x — no soft make of io.o / process.o / xlang-c.
run_stdout "print_i32" "tests/io/main.x" "42"
run_stdout "print_u32" "tests/io/print_u32.x" "100"
run_stdout "print_i64" "tests/io/print_i64.x" "123"
run_stdout "write_stdout" "tests/io/write_stdout.x" "Hi"
run_stdout "write_with_timeout" "tests/io/write_with_timeout.x" "Hi"
run_stdout "print_str" "tests/io/print_str.x" "ok"
run_stdout "read_stdin_ptr" "tests/io/read_ptr.x" "" 0 "AB"
run_stdout "read_ptr_slice" "tests/io/read_ptr_slice.x" "" 0 "AB"
run_stdout "read_ptr_slice_param" "tests/io/read_ptr_slice_param.x" "" 0 "AB"

echo "io test OK"
ok_report
