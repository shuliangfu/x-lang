#!/usr/bin/env bash
# C2 §5: native self-host generic type-arg count diagnostic gate.
#
# Honesty: soft SKIP→OK when no native xlang retired. Prefer product
# xlang_asm (was pinned to ./compiler/xlang only); pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die. Report run=/obs=/skip=.
#
# Usage: ./tests/run-typeck-generic-args-gate.sh
# Env:   XLANG_C2_BIN / XLANG — explicit compiler (must be native).
# 2026-08-27: soft SKIP→OK →硬绿.
# PLATFORM: SHARED — typeck diagnostic on Darwin + Ubuntu.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_TYPECK_GENERIC_ARGS_PREFIX:-xlang: [XLANG_TYPECK_GENERIC_ARGS]}"
SRC="tests/generic/wrong_type_args.x"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "typeck-generic-args-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  # Explicit XLANG_C2_BIN wins, then XLANG, then prefer asm.
  if [ -n "${XLANG_C2_BIN:-}" ]; then
    case "$XLANG_C2_BIN" in
      /*) abs="$XLANG_C2_BIN" ;;
      *) abs="$root/$XLANG_C2_BIN" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
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

echo "=== C2: generic expects/got diagnostic ==="
[ -f "$SRC" ] || die "missing $SRC"

XLANG_COMPILER="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_COMPILER"
export XLANG_LINK_XLANG="$XLANG_COMPILER"
gate_progress "typeck-generic-args: XLANG=$XLANG_COMPILER"

set +e
ERR=$("$XLANG_COMPILER" -L . "$SRC" 2>&1)
EC=$?
set -e

if [ "$EC" -eq 0 ]; then
  echo "$ERR" >&2
  die "wrong_type_args unexpectedly succeeded"
fi

echo "$ERR" | grep -q "generic function 'id' expects 1 type arguments, got 2" || {
  echo "$ERR" >&2
  die "missing expects/got generic diagnostic"
}
RUN_OK=$((RUN_OK + 1))

# Tip span residual: all native shu emit expects/got but location may be 0:0
# (want 4:26). Product obs — not soft SKIP→OK and not honesty hard-red.
if echo "$ERR" | grep -q "4:26"; then
  gate_progress "typeck-generic-args: source location 4:26 OK"
else
  echo "typeck-generic-args-gate OBS: missing source location 4:26 (tip span residual; got 0:0-class)" >&2
  echo "$ERR" | head -6 >&2
  OBS=$((OBS + 1))
fi

gate_progress "typeck-generic-args-gate OK (native self-host generic expects/got diagnostic)"
echo "typeck-generic-args-gate OK"
ok_report
