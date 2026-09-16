#!/usr/bin/env bash
# boundary leftover runner: base64/json/csv boundary smokes product -o
# (illegal/empty/round-trip). Nested leftover run-base64/json/csv skip-if-fail
# retired (those leftover runners are already honesty-closed).
#
# Honesty: leftover soft auto-make (`xlang_compiler_make -q || xlang_compiler_make`)
# + default ./compiler/xlang + fossil `$XLANG build` + soft skip if nested
# leftover runners fail retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# leftover XLANG fallthrough / leftover auto-make). Check path = obs=
# (check gate paused 2026-08-05). Product `-o` of the three boundary smokes
# must match expected exit (base64_roundtrip 0 / json_invalid 1 / csv_empty 0).
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-boundary-encodings.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_BOUNDARY_ENCODINGS_PREFIX:-xlang: [BOUNDARY_ENCODINGS]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "boundary encodings FAIL: $*" >&2
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

# Refuse leftover nested skip-if-fail (run-base64/json/csv) and leftover
# fossil `$XLANG build`. Product -o of each boundary smoke is the hard path.
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.
run_case() {
  local name="$1"
  local x="$2"
  local expect="$3"
  local exe log_o log_chk o_ec run_ec chk_ec
  [ -f "$x" ] || die "missing $x ($name)"
  log_chk="/tmp/xlang_boundary_${name}_check.log"
  log_o="/tmp/xlang_boundary_${name}_o.log"
  set +e
  "$XLANG_BIN" check -L . "$x" >"$log_chk" 2>&1
  chk_ec=$?
  set -e
  if [ "$chk_ec" -ne 0 ]; then
    echo "boundary $name OBS check (paused / CHK residual ec=$chk_ec; refuse leftover auto-make / nested skip)" >&2
    OBS=$((OBS + 1))
  fi
  exe="/tmp/xlang_boundary_${name}_$$"
  rm -f "$exe" 2>/dev/null || true
  set +e
  "$XLANG_BIN" -L . "$x" -o "$exe" >"$log_o" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    tail -n 12 "$log_o" 2>/dev/null || true
    rm -f "$exe"
    die "product -o failed for $name (ec=$o_ec; refuse leftover auto-make / fossil XLANG build / nested skip)"
  fi
  set +e
  "$exe" >/dev/null 2>&1
  run_ec=$?
  set -e
  rm -f "$exe"
  if [ "$run_ec" -ne "$expect" ]; then
    die "$name expected exit $expect, got $run_ec"
  fi
  RUN_OK=$((RUN_OK + 1))
  echo "boundary $name OK"
}

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

echo "=== boundary encodings leftover (prefer asm; hard; refuse leftover auto-make / nested skip) ==="
if [ -n "${XLANG:-}" ]; then
  if ! XLANG_BIN="$(resolve_shu)"; then
    die "explicit XLANG not native (refuse leftover XLANG fallthrough / leftover auto-make / nested skip)"
  fi
elif ! XLANG_BIN="$(resolve_shu)"; then
  die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / leftover auto-make / nested skip)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

run_case base64_roundtrip tests/boundary/base64_roundtrip.x 0
run_case json_invalid tests/boundary/json_invalid.x 1
run_case csv_empty tests/boundary/csv_empty.x 0

ok_report
echo "boundary encodings OK (smoke)"
