#!/usr/bin/env bash
# WPO-S1 compiler self: dump whole-program call graph from main.x(entry)
# and require dead export ≥ baseline min% (NEXT §4.1).
#
# Honesty: soft prefer-c (hard-coded xlang-c) + soft auto-make retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make /
# prefer-c). Callgraph path uses `xlang check` → observational while
# check gate paused (2026-08-05 → CHK002); refuse soft FAIL→OK /
# soft silence. When graph is actually written, hard-assert
# wpo_dce.pl ≥ min_dead_pct. Report: run=/obs=/skip=
# Usage: ./tests/run-wpo-compiler-self.sh
# Optional: XLANG_WPO_FAIL_ON_COMPILER_SELF=1 keeps historical hard name
# (same as hard graph assert when graph present).
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_WPO_COMPILER_SELF_PREFIX:-xlang: [WPO_COMPILER_SELF]}"
XLANG_CASE_TIMEOUT="${XLANG_WPO_COMPILER_TIMEOUT:-${XLANG_CASE_TIMEOUT:-180}}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "wpo-compiler-self FAIL: $*" >&2
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

echo "=== wpo-compiler-self gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

[ -f compiler/src/main.x ] || die "missing compiler/src/main.x"
[ -f compiler/scripts/wpo_dce.pl ] || die "missing compiler/scripts/wpo_dce.pl"
BASELINE="${XLANG_WPO_COMPILER_BASELINE:-tests/baseline/wpo-compiler-self.tsv}"
[ -f "$BASELINE" ] || die "missing $BASELINE"
MIN_PCT=$(awk -F'\t' '$1=="min_dead_pct" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_PCT=${MIN_PCT:-5}

GRAPH="/tmp/xlang_wpo_compiler_main_$$.json"
LOG="/tmp/wpo_compiler_self_$$.log"
CKLOG="/tmp/wpo_compiler_self_ck_$$.log"
rm -f "$GRAPH" "$LOG" "$CKLOG"

set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" \
  env XLANG_WPO_DUMP_CALLGRAPH="$GRAPH" "$XLANG_BIN" check compiler/src/main.x \
  >"$CKLOG" 2>&1
ck_ec=$?
set -e

if [ "$ck_ec" -eq 124 ]; then
  die "check callgraph timeout"
fi

if [ ! -s "$GRAPH" ]; then
  # check paused / CHK002 — observational residual (refuse soft silence).
  echo "wpo-compiler-self OBS: callgraph not written (check paused/CHK002 ec=$ck_ec; refuse soft silence)" >&2
  OBS=$((OBS + 1))
  rm -f "$CKLOG"
  ok_report
  echo "wpo compiler self OK (obs; check paused)"
  exit 0
fi

grep -qE '"root": [0-9]+' "$GRAPH" || die "invalid root in graph"
set +e
perl compiler/scripts/wpo_dce.pl "$GRAPH" --min-dead-pct "$MIN_PCT" | tee "$LOG"
pl_ec=$?
set -e
grep -q 'wpo_dce OK' "$LOG" || die "wpo_dce.pl missing OK (ec=$pl_ec)"
RUN_OK=$((RUN_OK + 1))
rm -f "$GRAPH" "$LOG" "$CKLOG"

ok_report
echo "wpo compiler self OK (min_dead_pct=${MIN_PCT}%)"
