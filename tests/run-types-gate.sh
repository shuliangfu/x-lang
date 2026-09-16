#!/usr/bin/env bash
# Types gate: overload smoke — honesty soft→硬绿.
#
# Honesty: soft default `./compiler/xlang-c` + soft auto-make + hard-bound
# `xlang check` (prefer-c / false authority; check gate paused pre-selfhost)
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
#   - hard: product -o tests/types/overload.x + run exit 0
#   - obs:  check (paused / CHK002 path hygiene)
# Report: run=/obs=/skip=
# Usage: ./tests/run-types-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_TYPES_PREFIX:-xlang: [XLANG_TYPES]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
SRC="tests/types/overload.x"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "types-gate FAIL: $*" >&2
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

echo "=== types gate: overload (prefer asm; hard/obs) ==="
[ -f "$SRC" ] || die "missing $SRC"
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# check = observational (gate paused 2026-08-05; CHK002 / path hygiene).
# PLATFORM: SHARED — product check ignores paths under /tests/; stage outside.
_types_chk_tmp="${TMPDIR:-/tmp}/xlang_types_check_$$"
mkdir -p "$_types_chk_tmp"
_base=$(basename "$SRC")
cp "$SRC" "$_types_chk_tmp/$_base"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" check -L . "$_types_chk_tmp/$_base" \
  >/tmp/xlang_types_check.log 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "types-gate OBS check (paused / CHK residual ec=$chk_ec; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
else
  _chk_out=$(cat /tmp/xlang_types_check.log 2>/dev/null || true)
  if [ -n "$_chk_out" ]; then
    echo "types-gate OBS check not silent (CHK residual; refuse soft SKIP→OK)" >&2
    OBS=$((OBS + 1))
  fi
fi
rm -rf "$_types_chk_tmp"

OUT="/tmp/xlang_types_overload_$$"
ERR="/tmp/xlang_types_overload_$$.log"
rm -f "$OUT"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$SRC" -o "$OUT" >"$ERR" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -eq 124 ]; then
  die "product -o timeout"
elif [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  die "product -o failed (ec=$o_ec); $(tail -5 "$ERR" 2>/dev/null | tr '\n' ' ')"
fi
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$OUT" >/dev/null 2>&1
r_ec=$?
set -e
if [ "$r_ec" -eq 124 ]; then
  die "run timeout"
elif [ "$r_ec" -ne 0 ]; then
  die "run exit=$r_ec (expect 0)"
fi
RUN_OK=$((RUN_OK + 1))
echo "types-gate OK: run $SRC exit=0"
rm -f "$OUT"

echo "types gate OK"
ok_report
