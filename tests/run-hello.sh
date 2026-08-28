#!/usr/bin/env bash
# Stage-4 Hello World: compile examples/hello.x; require stdout "Hello World"
# and process exit 0 (void main contract).
#
# Honesty: soft default `./compiler/xlang` + soft prefer-c on non-x86_64 /
# stage1/2 + soft auto-make under RUN_ALL_USE_C (false authority) retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make /
# prefer-c). Host-cc `-backend c` only when XLANG_ALLOW_HOST_CC=1 or
# XLANG_FORCE_LINK_BACKEND=c (explicit opt-in, not silent). RUN_ALL_USE_C=1
# may bind xlang-c when present (C pipeline); missing xlang-c = hard die
# (no soft auto-make). PLATFORM: WINDOWS/MSYS may bind xlang-c when present
# (seed -o hang avoidance). Report: run=/obs=/skip=
# Usage: ./tests/run-hello.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_HELLO_PREFIX:-xlang: [HELLO]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "hello FAIL: $*" >&2
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

echo "=== hello gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

[ -f examples/hello.x ] || die "missing examples/hello.x"

HELLO_OUT="${TMPDIR:-/tmp}/xlang_hello_$$"
HELLO_BUILD_LOG="${TMPDIR:-/tmp}/xlang_hello_build_$$.log"
trap 'rm -f "$HELLO_OUT" "$HELLO_BUILD_LOG"' EXIT

HELLO_COMPILE_XLANG="$XLANG_BIN"
HELLO_BACKEND=""

# Explicit experimental host-cc only (refuse silent host-cc).
if [ -n "${XLANG_FORCE_LINK_BACKEND:-}" ]; then
  HELLO_BACKEND="-backend ${XLANG_FORCE_LINK_BACKEND}"
elif [ "${XLANG_ALLOW_HOST_CC:-}" = "1" ]; then
  HELLO_BACKEND="-backend c"
fi

# PLATFORM: WINDOWS — MSYS2 seed -o can hang; bind xlang-c when present.
if [ -n "${MSYSTEM:-}" ] || case "$(uname -s 2>/dev/null)" in MINGW*|MSYS*) true ;; *) false ;; esac; then
  if dod_native_exe ./compiler/xlang-c; then
    HELLO_COMPILE_XLANG="$(pwd)/compiler/xlang-c"
    HELLO_BACKEND=""
  fi
fi

# run-all C pipeline: bind xlang-c when present; refuse soft auto-make.
if [ -n "${RUN_ALL_USE_C:-}" ]; then
  if dod_native_exe ./compiler/xlang-c; then
    HELLO_COMPILE_XLANG="$(pwd)/compiler/xlang-c"
    HELLO_BACKEND=""
  else
    die "RUN_ALL_USE_C=1 but no native xlang-c (refuse soft auto-make)"
  fi
fi

rm -f "$HELLO_OUT" "$HELLO_BUILD_LOG"
set +e
# Drain non-TTY stdout (seed hang on some hosts); pipefail so compile fail is not swallowed.
set -o pipefail
gate_run_timeout "$XLANG_CASE_TIMEOUT" \
  $HELLO_COMPILE_XLANG $HELLO_BACKEND -L . examples/hello.x -o "$HELLO_OUT" \
  >"$HELLO_BUILD_LOG" 2>&1
o_ec=$?
set +o pipefail
set -e

if [ "$o_ec" -eq 124 ]; then
  die "product -o timeout"
elif [ "$o_ec" -ne 0 ] || [ ! -x "$HELLO_OUT" ]; then
  die "product -o failed (ec=$o_ec); $(tail -5 "$HELLO_BUILD_LOG" 2>/dev/null | tr '\n' ' ')"
fi

set +e
out=$(gate_run_timeout "$XLANG_CASE_TIMEOUT" "$HELLO_OUT" 2>/dev/null)
r_ec=$?
set -e
if [ "$r_ec" -eq 124 ]; then
  die "run timeout"
fi
echo "$out" | grep -q "Hello World" \
  || die "expected 'Hello World' in output, got: $out"
if [ "$r_ec" -ne 0 ]; then
  die "expected hello exit 0, got $r_ec"
fi
echo "hello OK: Hello World exit=0"
RUN_OK=$((RUN_OK + 1))

ok_report
echo "Hello World test OK"
