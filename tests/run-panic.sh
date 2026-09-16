#!/usr/bin/env bash
# panic() / panic(expr) smoke: product -o links; run aborts non-zero + stderr msg
#
# Honesty: soft default `./compiler/xlang` + soft auto-make (false authority)
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c /
# soft bootstrap-link / leftover xlang_asm2 unless XLANG_BSTRICT_USE_ASM2=1).
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

PREFIX="${XLANG_PANIC_PREFIX:-xlang: [PANIC]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "panic FAIL: $*" >&2
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
  # Opt-in leftover Stage2 only (July-14 wrong-binary ban otherwise).
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

build_case() {
  local tag="$1" src="$2" exe_var="$3"
  local exe="/tmp/xlang_panic_${tag}_$$"
  local log="/tmp/xlang_panic_${tag}_$$.log"
  local o_ec
  [ -f "$src" ] || die "missing $src ($tag)"
  rm -f "$exe" "$log"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$src" -o "$exe" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    die "$tag product -o timeout"
  elif [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    die "$tag product -o failed (ec=$o_ec); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
  fi
  rm -f "$log"
  eval "$exe_var=\"$exe\""
}

echo "=== panic gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

EXE_MAIN="" EXE_MSG="" EXE_STR=""
build_case main tests/panic/main.x EXE_MAIN
build_case with_msg tests/panic/with_msg.x EXE_MSG
build_case with_str tests/panic/with_str.x EXE_STR

# Run expects abort (non-zero). Suppress shell "Abort trap" noise.
run_abort() {
  local tag="$1" exe="$2"
  local r_ec=0
  set +e
  { ( gate_run_timeout "$XLANG_CASE_TIMEOUT" "$exe" 2>/dev/null ) 2>/dev/null || r_ec=$?; } 2>/dev/null
  set -e
  if [ "$r_ec" -eq 124 ]; then
    die "$tag run timeout"
  elif [ "$r_ec" -eq 0 ]; then
    die "$tag expected non-zero exit (panic abort), got 0"
  fi
  RUN_OK=$((RUN_OK + 1))
}

run_abort main "$EXE_MAIN"
run_abort with_msg "$EXE_MSG"
run_abort with_str "$EXE_STR"

# wave386: cstr message must appear on stderr.
str_err=$("$EXE_STR" 2>&1 >/dev/null || true)
case "$str_err" in
  *boom*) RUN_OK=$((RUN_OK + 1)) ;;
  *) die "expected panic cstr 'boom' on stderr, got: [$str_err]" ;;
esac

# wave389: integer panic(42) → contains 42 on stderr.
msg_err=$("$EXE_MSG" 2>&1 >/dev/null || true)
case "$msg_err" in
  *42*) RUN_OK=$((RUN_OK + 1)) ;;
  *) die "expected panic int '42' on stderr, got: [$msg_err]" ;;
esac

rm -f "$EXE_MAIN" "$EXE_MSG" "$EXE_STR"
ok_report
echo "panic test OK"
