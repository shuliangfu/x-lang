#!/usr/bin/env bash
# P0-4 / MEM-CTFE: i64 large lit + INT64_MIN fold regression gate.
#
# Honesty: soft auto-make + soft bootstrap-link / min_link + soft xlang-c
# fallback (false authority) retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die (refuse soft
# SKIP→OK / soft auto-make / prefer-c / soft bootstrap-link).
# `xlang check` paused (2026-08-05) → former typeck-only arm = obs= (CHK002),
# not soft FAIL→OK. Product `-o` exit 42 is the hard gate.
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

PREFIX="${XLANG_I64_CTFE_PREFIX:-xlang: [I64-CTFE]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
DOC="analysis/安全与性能.md"
SRC="tests/typeck/ctfe/i64_min_not_zero.x"
BASELINE="tests/baseline/i64-ctfe.tsv"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "i64-ctfe FAIL: $*" >&2
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

echo "=== i64-ctfe gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# Manifest prerequisites (hard die; not soft SKIP→OK).
for f in "$DOC" "$SRC" "$BASELINE"; do
  [ -f "$f" ] || die "missing $f"
done
grep -qF "i64_min_not_zero.x" "$BASELINE" \
  || die "baseline missing i64_min_not_zero.x"
echo "i64-ctfe manifest OK"

# Check-paused typeck arm (CHK002): former `xlang check` authority.
# Do not soft-green by skipping silently — count obs= and keep fixture on disk.
echo "i64-ctfe OBS typeck_check (check paused CHK002; not soft FAIL→OK)" >&2
OBS=$((OBS + 1))

# Hard product -o: INT64_MIN fold must yield exit 42 (not silent 0).
exe="/tmp/xlang_i64_ctfe_$$"
log="/tmp/xlang_i64_ctfe_$$.log"
rm -f "$exe" "$log"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" build -L . "$SRC" -o "$exe" >"$log" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -eq 124 ]; then
  die "product -o timeout"
elif [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  die "product -o failed (ec=$o_ec); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
fi
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$exe" >/dev/null 2>&1
r_ec=$?
set -e
rm -f "$exe" "$log"
if [ "$r_ec" -eq 124 ]; then
  die "run timeout"
elif [ "$r_ec" -ne 42 ]; then
  die "expected exit 42 (INT64_MIN != 0), got $r_ec"
fi
RUN_OK=$((RUN_OK + 1))

ok_report
echo "i64-ctfe gate OK"
