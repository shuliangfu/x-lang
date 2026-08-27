#!/usr/bin/env bash
# Atomic primitives gate (bstrict catalog: run-atomic.sh).
#
# Honesty: soft default `./compiler/xlang` + soft auto-make of the compiler
# (false authority) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c). Still ensures std/atomic.o via F-07 path
# (object ensure ≠ soft auto-make of the compiler).
#   - hard: tests/atomic/main.x product -o run exit 0
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
# shellcheck source=tests/lib/build-std-c-o.sh
. tests/lib/build-std-c-o.sh

PREFIX="${XLANG_ATOMIC_PREFIX:-xlang: [XLANG_ATOMIC]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "atomic test FAIL: $*" >&2
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

echo "=== atomic gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

ensure_std_c_o ../std/atomic/atomic.o || die "ensure atomic.o failed"

SRC="tests/atomic/main.x"
[ -f "$SRC" ] || die "missing $SRC"
exe="/tmp/xlang_atomic_$$"
log="/tmp/xlang_atomic_$$.log"
rm -f "$exe" "$log"
# Raise stack for atomic smoke (heritage; keep when host allows).
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$SRC" -o "$exe" >"$log" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -eq 124 ]; then
  die "main product -o timeout"
elif [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  die "main product -o failed (ec=$o_ec); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
fi

set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$exe" >/dev/null 2>&1
r_ec=$?
set -e
rm -f "$exe"
if [ "$r_ec" -eq 124 ]; then
  die "main run timeout"
elif [ "$r_ec" -ne 0 ]; then
  die "main expected exit 0, got $r_ec"
fi
RUN_OK=$((RUN_OK + 1))
echo "atomic OK: main exit=0"

echo "atomic test OK"
ok_report
