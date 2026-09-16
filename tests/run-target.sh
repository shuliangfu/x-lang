#!/usr/bin/env bash
# -target triple accepted by driver; host-native triple builds + runs hello
#
# Honesty: soft default `./compiler/xlang` + soft auto-make (false authority)
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
# Unknown uname → skip= (platform N/A), not soft FAIL swallow.
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

PREFIX="${XLANG_TARGET_PREFIX:-xlang: [TARGET]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "target FAIL: $*" >&2
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

echo "=== target gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# PLATFORM: SHARED — host-native triple only; unknown OS → skip=.
case "$(uname -s)" in
  Darwin) triple="$(uname -m)-apple-darwin" ;;
  Linux) triple="$(uname -m)-linux-gnu" ;;
  *)
    SKIP=$((SKIP + 1))
    echo "target: unknown uname=$(uname -s) → skip= (platform N/A)"
    ok_report
    echo "target test OK (skip)"
    exit 0
    ;;
esac

exe="/tmp/xlang_target_hello_$$"
log="/tmp/xlang_target_hello_$$.log"
rm -f "$exe" "$log"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . -target "$triple" examples/hello.x -o "$exe" >"$log" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -eq 124 ]; then
  die "product -o -target $triple timeout"
elif [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  die "product -o -target $triple failed (ec=$o_ec); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
fi
set +e
out=$(gate_run_timeout "$XLANG_CASE_TIMEOUT" "$exe" 2>/dev/null)
r_ec=$?
set -e
rm -f "$exe" "$log"
if [ "$r_ec" -eq 124 ]; then
  die "run timeout"
elif [ "$r_ec" -ne 0 ]; then
  die "run exit $r_ec (want 0)"
fi
echo "$out" | grep -q "Hello World" || die "expected Hello World in stdout"
RUN_OK=$((RUN_OK + 1))
ok_report
echo "target test OK"
