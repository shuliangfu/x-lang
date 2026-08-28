#!/usr/bin/env bash
# WPO v0 emit smoke: codegen DCE + if-block reachability.
#
# Honesty: soft prefer-c (hard-coded ./compiler/xlang-c) + soft auto-make
# xlang-c / process.o + soft false-green needles `dead_helper()` /
# `dead_export()` (never match tip C emit `dead_helper(void)`) retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make /
# prefer-c).
#   - hard: used/live symbols present on -E; product -o dead_user exit 7;
#     if_block_reach keeps core_option_some_i32 body; product -o exit 0
#   - obs: tip still emits dead_helper / dead_lib_dead_export bodies on
#     -E (DCE residual; honest needle); check callgraph dump (check gate
#     paused 2026-08-05 → CHK002)
# Report: run=/obs=/skip=
# Usage: ./tests/run-wpo-dce-emit.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_WPO_DCE_PREFIX:-xlang: [WPO_DCE_EMIT]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "wpo-dce-emit FAIL: $*" >&2
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

# Emit C via product -E. Extra args (e.g. -L .) go before -E.
emit_e() {
  local tag="$1"
  shift
  local out="$1"
  shift
  local log="/tmp/xlang_wpo_e_${tag}_$$.log"
  local ec
  rm -f "$out" "$log"
  set +e
  # -E must precede the .x path; trailing -E is treated as compile+run (exit 127).
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -E "$@" >"$out" 2>"$log"
  ec=$?
  set -e
  if [ "$ec" -eq 124 ]; then
    die "$tag -E timeout"
  elif [ "$ec" -ne 0 ] || [ ! -s "$out" ]; then
    die "$tag -E failed (ec=$ec); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
  fi
  rm -f "$log"
}

run_o() {
  local tag="$1" src="$2" want="$3"
  local exe="/tmp/xlang_wpo_o_${tag}_$$"
  local log="/tmp/xlang_wpo_o_${tag}_$$.log"
  local o_ec r_ec
  rm -f "$exe" "$log"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$src" -o "$exe" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    die "$tag product -o timeout"
  elif [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    die "$tag product -o failed (ec=$o_ec); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
  fi
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$exe" >/dev/null 2>&1
  r_ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$r_ec" -eq 124 ]; then
    die "$tag run timeout"
  elif [ "$r_ec" -ne "$want" ]; then
    die "$tag expected exit $want, got $r_ec"
  fi
  echo "wpo-dce-emit OK: $tag exit=$want"
  RUN_OK=$((RUN_OK + 1))
}

echo "=== wpo-dce-emit gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

for f in tests/wpo/dead_fn.x tests/wpo/dead_user.x tests/wpo/if_block_reach.x; do
  [ -f "$f" ] || die "missing $f"
done

# --- intra-module DCE emit ---
DF="/tmp/xlang_wpo_dead_fn_$$.c"
emit_e dead_fn "$DF" tests/wpo/dead_fn.x
grep -q 'used_helper' "$DF" || die "dead_fn missing used_helper"
# Honest body needle (old soft needle dead_helper() never matched tip emit).
if grep -q 'int32_t dead_helper(void) {' "$DF"; then
  echo "wpo-dce-emit OBS: dead_fn still emits dead_helper body on -E (DCE residual; not soft false-green)" >&2
  OBS=$((OBS + 1))
else
  echo "wpo-dce-emit OK: dead_fn DCE dropped dead_helper body"
  RUN_OK=$((RUN_OK + 1))
fi
echo "wpo-dce-emit OK: dead_fn used_helper present"
RUN_OK=$((RUN_OK + 1))
rm -f "$DF"

# --- cross-import DCE emit ---
DU="/tmp/xlang_wpo_dead_user_$$.c"
emit_e dead_user_e "$DU" tests/wpo/dead_user.x
grep -qE 'live_export|dead_lib_live_export' "$DU" || die "dead_user missing live_export"
if grep -q 'int32_t dead_lib_dead_export(void) {' "$DU"; then
  echo "wpo-dce-emit OBS: dead_user still emits dead_lib_dead_export body on -E (DCE residual; not soft false-green)" >&2
  OBS=$((OBS + 1))
else
  echo "wpo-dce-emit OK: dead_user DCE dropped dead_lib_dead_export body"
  RUN_OK=$((RUN_OK + 1))
fi
echo "wpo-dce-emit OK: dead_user live_export present"
RUN_OK=$((RUN_OK + 1))
rm -f "$DU"

# Product -o still must run (DCE residual must not break live path).
run_o dead_user_o tests/wpo/dead_user.x 7

# --- if-block reachability (must NOT DCE live option helpers) ---
GRAPH="/tmp/xlang_wpo_if_block_reach_$$.json"
rm -f "$GRAPH"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" \
  env XLANG_WPO_DUMP_CALLGRAPH="$GRAPH" "$XLANG_BIN" check -L . tests/wpo/if_block_reach.x \
  >/tmp/xlang_wpo_ck_$$.log 2>&1
ck_ec=$?
set -e
# check paused → observational only (refuse soft FAIL→OK / soft silence).
echo "wpo-dce-emit OBS: if_block callgraph check paused/CHK002 (ec=$ck_ec; refuse soft silence)" >&2
OBS=$((OBS + 1))
rm -f "$GRAPH" /tmp/xlang_wpo_ck_$$.log

IBR="/tmp/xlang_wpo_ibr_$$.c"
emit_e if_block_e "$IBR" -L . tests/wpo/if_block_reach.x
grep -q 'core_option_some_i32(int32_t x) {' "$IBR" \
  || die "if_block_reach missing core_option_some_i32 body (DCE over-delete)"
echo "wpo-dce-emit OK: if_block_reach keeps core_option_some_i32 body"
RUN_OK=$((RUN_OK + 1))
rm -f "$IBR"

# Refuse soft auto-make of process.o; product -o must succeed with tree as-is
# (existing std/process/process.o on SHARED hosts). Missing .o → hard link fail.
run_o if_block_o tests/wpo/if_block_reach.x 0

ok_report
echo "wpo dce emit OK"
