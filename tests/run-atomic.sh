#!/usr/bin/env bash
# Atomic leftover runner (bstrict catalog: run-atomic.sh): tests/atomic/main.x
# product -o exit 0.
#
# Honesty: leftover soft `ensure_std_c_o atomic.o` retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard
# die (refuse leftover SKIP→OK / leftover XLANG fallthrough / leftover
# auto-make / leftover ensure / prefer-c). Check path = obs= (check gate
# paused 2026-08-05). Product `-o` tests/atomic/main.x must exit 0.
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-atomic.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_ATOMIC_PREFIX:-xlang: [XLANG_ATOMIC]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
SMOKE="tests/atomic/main.x"
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

# G.7: complete the existing per-script resolve_shu family (dod_native_exe);
# do not fork a third resolver. Explicit XLANG that is missing/non-native
# returns 1 (caller hard-dies; refuse leftover XLANG fallthrough).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

[ -f "$SMOKE" ] || die "missing $SMOKE"
# Raise stack for atomic smoke (heritage; keep when host allows).
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

echo "=== atomic leftover (prefer asm; hard; refuse leftover ensure) ==="
if [ -n "${XLANG:-}" ]; then
  if ! XLANG_BIN="$(resolve_shu)"; then
    die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover ensure)"
  fi
elif ! XLANG_BIN="$(resolve_shu)"; then
  die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / leftover ensure)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_atomic_check.log 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "atomic test OBS check (paused / CHK residual ec=$chk_ec; refuse leftover ensure)" >&2
  OBS=$((OBS + 1))
fi

exe="/tmp/xlang_atomic_$$"
log="/tmp/xlang_atomic_$$.log"
rm -f "$exe" "$log"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$SMOKE" -o "$exe" >"$log" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -eq 124 ]; then
  die "main product -o timeout"
elif [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  die "main product -o failed (ec=$o_ec; refuse leftover ensure); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
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
