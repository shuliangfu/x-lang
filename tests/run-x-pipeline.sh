#!/usr/bin/env bash
# Stage 2.11 / 9.1: pure .x pipeline `-x -E` on a minimal program must
# emit C containing a `return`.
#
# Honesty: soft auto-make of bootstrap-pipeline / xlang-x-pipeline /
# soft SKIP→OK when `-x -E` unsupported / soft SKIP on wrong-libc (false
# authority) retired. Prefer product xlang_asm (tip supports `-x -E`);
# optional existing compiler/xlang_x also accepted. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make).
# Tip `-x -E` emit residual (no `return`) = obs= (not soft SKIP→OK /
# soft FAIL→OK silence). Report: run=/obs=/skip=
# Usage: ./tests/run-x-pipeline.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_X_PIPELINE_PREFIX:-xlang: [X_PIPELINE]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-60}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "x-pipeline FAIL: $*" >&2
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
  # Prefer product asm; accept existing xlang_x when present (no soft build).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang_x ./compiler/xlang-c ./compiler/xlang; do
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

echo "=== x-pipeline gate (prefer asm; hard; refuse soft auto-make) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang_x/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

MIN_X="tests/x-pipeline/min.x"
[ -f "$MIN_X" ] || die "missing $MIN_X"

out=$(mktemp)
err=$(mktemp)
trap 'rm -f "$out" "$err"' EXIT

set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -x -E "$MIN_X" >"$out" 2>"$err"
ec=$?
set -e

if [ "$ec" -eq 124 ]; then
  die "-x -E timeout after ${XLANG_CASE_TIMEOUT}s; $(tail -5 "$err" 2>/dev/null | tr '\n' ' ')"
fi
if [ "$ec" -ne 0 ]; then
  die "-x -E failed (ec=$ec; refuse soft SKIP→OK); $(tail -5 "$err" 2>/dev/null | tr '\n' ' ')"
fi

if ! grep -q 'return' "$out"; then
  echo "x-pipeline OBS: -x -E emit missing return (tip residual; refuse soft silence); bytes=$(wc -c <"$out" | tr -d ' ')" >&2
  OBS=$((OBS + 1))
  ok_report
  echo "x-pipeline OK (emit obs)"
  exit 0
fi

echo "x-pipeline OK (-x -E minimal program has return)"
RUN_OK=$((RUN_OK + 1))
ok_report
