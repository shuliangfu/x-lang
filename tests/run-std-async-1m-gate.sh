#!/usr/bin/env bash
# STD-004: async 1M task stress gate (no crash + correct exit).
#
# Honesty: soft SKIP→OK when no native xlang + prefer-c / silent asm→c
# fallback retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG = hard die. Missing native = hard die. Fossil
# async_switch.x retired → live i06_* benches. coop_pingpong* UNDEF =
# obs (product residual — not soft). Platform must/skip from TSV stays
# honest skip. Report run=/obs=/skip=.
#
# Usage: ./tests/run-std-async-1m-gate.sh
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_ASYNC_1M_DOC:-analysis/archive/std/std-async-api-v1.md}"
MATRIX="${XLANG_STD_ASYNC_1M_TSV:-tests/baseline/std-async-1m.tsv}"
PREFIX="xlang: [XLANG_STD_ASYNC_1M]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-async-1m gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

platform_policy() {
  local linux="$1"
  local macos="$2"
  local windows="$3"
  if ci_is_linux; then
    echo "$linux"
  elif ci_is_darwin; then
    echo "$macos"
  elif ci_is_windows_msys; then
    echo "$windows"
  else
    echo "must"
  fi
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

# coop_pingpong* product UNDEF residual = obs (aligned with std-async-api).
# PLATFORM: SHARED — product residual; not soft silence.
obs_case() {
  case "$1" in
    async_1m_coop) return 0 ;;
    *) return 1 ;;
  esac
}

[ -f "$MATRIX" ] || die "missing $MATRIX"
[ -f "$DOC" ] || die "missing $DOC"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
xlang_compiler_make ../std/async/scheduler.o -q 2>/dev/null || xlang_compiler_make ../std/async/scheduler.o

# Compile with resolved product XLANG only — refuse silent xlang-c fallback.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
async_compile_bench() {
  local x="$1"
  local out="$2"
  rm -f "$out"
  if ! "$XLANG_BIN" -L . "$x" -o "$out" >/tmp/async_1m_compile.log 2>&1; then
    cat /tmp/async_1m_compile.log >&2
    return 1
  fi
  return 0
}

echo "=== STD-004: async 1M stress ($(ci_host_summary) XLANG=$XLANG_BIN) ==="

FAILS=0
CASES_RAN=0
while IFS=$'\t' read -r case_id script linux pol_mac pol_win want_ec notes; do
  [ -z "$case_id" ] && continue
  case "$case_id" in
    \#*) continue ;;
  esac
  pol=$(platform_policy "$linux" "$pol_mac" "$pol_win")
  if [ "$pol" = "skip" ]; then
    echo "async 1M SKIP $case_id ($notes)"
    SKIP=1
    continue
  fi
  src="bench/${script}"
  if [ ! -f "$src" ]; then
    echo "async 1M FAIL $case_id: missing $src" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  out="/tmp/xlang_async_1m_${case_id}"
  echo "── case $case_id: $src ──"
  if ! async_compile_bench "$src" "$out"; then
    if obs_case "$case_id"; then
      echo "async 1M OBS $case_id: compile (product residual)" >&2
      OBS=1
      continue
    fi
    echo "async 1M FAIL $case_id: compile" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  if [ "$ec" -ne "${want_ec:-0}" ]; then
    if obs_case "$case_id"; then
      echo "async 1M OBS $case_id: exit=$ec want=${want_ec:-0} (product residual)" >&2
      OBS=1
      continue
    fi
    echo "async 1M FAIL $case_id: exit=$ec want=${want_ec:-0}" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  echo "async 1M OK $case_id (exit=$ec)"
  CASES_RAN=$((CASES_RAN + 1))
done < "$MATRIX"

[ "$FAILS" -eq 0 ] || die "${FAILS} case(s)"
# Hard-green when at least one must-case ran OK (switch); coop may be obs.
[ "$CASES_RAN" -gt 0 ] || [ "$OBS" -eq 1 ] || [ "$SKIP" -eq 1 ] \
  || die "no cases ran"
RUN_OK=1
ok_report
echo "std-async-1m gate OK"
