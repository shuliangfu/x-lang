#!/usr/bin/env bash
# Stage-8 size baseline: compile fixed fixtures and print executable sizes.
#
# Honesty: soft default `./compiler/xlang` + soft auto-make (false
# authority) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c). Hard: product -o hello + option emit
# executables (sizes printed). Report: run=/obs=/skip=
# Usage: ./tests/run-size-baseline.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_SIZE_BASELINE_PREFIX:-xlang: [SIZE_BASELINE]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "size-baseline FAIL: $*" >&2
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

compile_size() {
  local tag="$1" src="$2" out="$3"
  shift 3
  local log="/tmp/xlang_size_${tag}_$$.log"
  local o_ec
  rm -f "$out" "$log"
  [ -f "$src" ] || die "missing $src ($tag)"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" "$@" "$src" -o "$out" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    die "$tag product -o timeout"
  elif [ "$o_ec" -ne 0 ] || [ ! -f "$out" ]; then
    die "$tag product -o failed (ec=$o_ec); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
  fi
  ls -l "$out" | awk -v t="$tag" '{print t " -> " $5 " bytes"}'
  rm -f "$log"
  RUN_OK=$((RUN_OK + 1))
}

echo "=== size-baseline gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

echo "=== size baseline (default / -O2 strip host-dependent) ==="
compile_size hello examples/hello.x /tmp/xlang_baseline_hello_$$
compile_size option tests/option/main.x /tmp/xlang_baseline_option_$$ build -L .

echo "=== -O 0 / -O 2 / -O s compare (hello.x) ==="
compile_size hello_o0 examples/hello.x /tmp/xlang_baseline_hello_o0_$$ -O 0
compile_size hello_o2 examples/hello.x /tmp/xlang_baseline_hello_o2_$$ -O 2
compile_size hello_os examples/hello.x /tmp/xlang_baseline_hello_os_$$ -O s

rm -f /tmp/xlang_baseline_hello_$$ /tmp/xlang_baseline_option_$$ \
  /tmp/xlang_baseline_hello_o0_$$ /tmp/xlang_baseline_hello_o2_$$ \
  /tmp/xlang_baseline_hello_os_$$

ok_report
echo "=== size baseline OK ==="
