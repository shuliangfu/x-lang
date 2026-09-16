#!/usr/bin/env bash
# WPO-S2 smoke: call graph v2 const-arg call sites + asm const fold / mono.
#
# Honesty: leftover auto-make ALWAYS (`xlang_compiler_make -q` even when
# XLANG is set / xlang-c already present) retired — that path kicked g05
# and raced L2. leftover ignore of explicit-bad (XLANG=/nonexistent
# silently auto-made then died on leftover nested xlang-c check HARD)
# retired. leftover unused compiler-make.sh sourced unused after leftover
# auto-make retired. Explicit-bad XLANG / missing native = hard die FIRST
# (before leftover nested check-bound graph obs). leftover nested
# check-bound graph dump (`xlang-c check`; selfhost pause → obs, continue
# asm fold) stay. leftover nested asm fold / Darwin exe N/A / host-arch
# N/A stay. G.7: complete existing resolve_shu; converge dod_native_exe.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Report run=/obs=/skip=.
#
# Usage: ./tests/run-wpo-s2.sh
# PLATFORM: SHARED archaeology (Ubuntu gold).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-main-disasm.sh
. tests/lib/wpo-main-disasm.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || true

PREFIX="xlang: [XLANG_WPO_S2]"
RUN_OK=0
OBS=0
SKIP=1

die() {
  echo "wpo-s2 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK:-0} obs=${OBS:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

# G.7: complete existing resolve_shu. Explicit XLANG that is missing or
# non-native returns 1 (caller hard-dies). Unset XLANG prefers asm.
# leftover auto-make xlang-c ALWAYS retired — converge dod_native_exe.
# Do not restore set -e before return 1.
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

# Explicit XLANG that is missing/non-native hard-dies BEFORE leftover
# nested check-bound graph obs (refuse leftover ignore of explicit-bad /
# leftover auto-make). leftover nested product path stays when XLANG is
# unset. leftover nested check-bound (`./compiler/xlang-c check`) stay.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  XLANG_BIN="$(resolve_shu)" || die "explicit XLANG not native (refuse leftover ignore of explicit-bad / leftover auto-make)"
else
  XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse leftover auto-make)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
SKIP=0
XLANG_C="./compiler/xlang-c"

echo "=== WPO-S2: const-spec / asm fold (honesty) ==="

# leftover nested check-bound graph dump stay (`xlang-c check`; selfhost
# pause → obs, continue asm fold). leftover auto-make xlang-c ALWAYS
# retired — missing xlang-c is obs, not a silent g05 relink.
# PLATFORM: SHARED — graph dump rides `xlang-c check`; selfhost check gate
# is paused, so CHK002 / parse failure is obs (continue asm), not a hard
# archaeology die.
GRAPH="/tmp/xlang_wpo_const_spec.json"
rm -f "$GRAPH"
GRAPH_OK=0
if [ -x "$XLANG_C" ] \
  && XLANG_WPO_DUMP_CALLGRAPH="$GRAPH" "$XLANG_C" check tests/wpo/const_spec.x >/dev/null 2>/tmp/wpo_s2_check.err \
  && [ -s "$GRAPH" ]; then
  if grep -q '"version": 2' "$GRAPH" \
    && grep -q '"call_sites"' "$GRAPH" \
    && perl compiler/scripts/wpo_const_spec.pl "$GRAPH" --expect-site 0 1 1024 64 \
      | tee /tmp/wpo_const_spec.log \
      | grep -q 'wpo_const_spec OK'; then
    GRAPH_OK=1
    echo "wpo-s2 graph: const_spec v2 OK"
  else
    echo "WPO-S2 OBS: wpo_const_spec.pl graph gate failed (check-bound residual)" >&2
    OBS=$((OBS + 1))
  fi
else
  echo "WPO-S2 OBS: xlang-c check/callgraph unavailable (check-bound residual; selfhost check gate paused)" >&2
  OBS=$((OBS + 1))
fi

DEAD_GRAPH="/tmp/xlang_wpo_dead_fn_v2.json"
rm -f "$DEAD_GRAPH"
if [ -x "$XLANG_C" ] \
  && XLANG_WPO_DUMP_CALLGRAPH="$DEAD_GRAPH" "$XLANG_C" check tests/wpo/dead_fn.x >/dev/null 2>/tmp/wpo_s2_dead_check.err \
  && [ -s "$DEAD_GRAPH" ] \
  && perl compiler/scripts/wpo_dce.pl "$DEAD_GRAPH" --expect-dead dead_helper \
    | tee /tmp/wpo_dce_s2.log \
    | grep -q 'wpo_dce OK'; then
  echo "wpo-s2 graph: dead_fn v2 OK"
else
  echo "WPO-S2 OBS: dead_fn v2 graph dump unavailable (check-bound residual; selfhost check gate paused)" >&2
  OBS=$((OBS + 1))
fi

# leftover nested asm fold stay HARD. leftover nested Darwin exe run N/A
# and leftover nested host-arch N/A stay (report skip, not leftover
# SKIP→OK without a counter). Prefer resolved XLANG when it is xlang_asm;
# otherwise native ./compiler/xlang_asm.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
ASM_BIN=""
if dod_native_exe "$XLANG_BIN" && echo "$XLANG_BIN" | grep -q 'xlang_asm'; then
  ASM_BIN="$XLANG_BIN"
elif dod_native_exe ./compiler/xlang_asm; then
  ASM_BIN=./compiler/xlang_asm
fi

if [ -n "$ASM_BIN" ] && ! wpo_host_asm_run_na; then
  if wpo_s2_darwin_skip_exe_run; then
    echo "wpo-s2: Darwin asm uses -o .o disasm (user exe ld __TEXT N/A)"
  fi

  OUT=$(wpo_s2_asm_out_path /tmp/xlang_wpo_const_spec_fold)
  if ! "$ASM_BIN" tests/wpo/const_spec_fold.x -o "$OUT" 2>/tmp/wpo_s2_fold_build.log; then
    echo "wpo-s2 asm FAIL: const_spec_fold compile failed" >&2
    tail -8 /tmp/wpo_s2_fold_build.log 2>/dev/null || true
    die "const_spec_fold compile failed"
  fi
  if ! wpo_s2_darwin_skip_exe_run; then
    EX=0
    "$OUT" >/dev/null 2>&1 || EX=$?
    if [ "$EX" -ne 0 ]; then
      die "const_spec_fold expected exit 0, got $EX"
    fi
  fi
  MAIN_ASM=$(wpo_main_asm "$OUT" || true)
  if [ -z "$MAIN_ASM" ]; then
    die "cannot disassemble _main ($OUT); need otool or objdump"
  fi
  if wpo_main_calls_pat "$OUT" '_scale([^_a-zA-Z0-9]|$)|[[:space:]]_scale([^_a-zA-Z0-9]|$)'; then
    echo "$MAIN_ASM" | grep -E 'scale|bl|call' || true
    die "_main still calls _scale (expected WPO const fold inline)"
  fi
  echo "wpo-s2 asm fold OK (_main no bl _scale, exit 0)"
  RUN_OK=$((RUN_OK + 1))

  OUT_MONO=$(wpo_s2_asm_out_path /tmp/xlang_wpo_const_spec_mono)
  if ! XLANG_WPO_MONO=1 "$ASM_BIN" tests/wpo/const_spec_fold.x -o "$OUT_MONO" 2>/tmp/wpo_s2_mono_build.log; then
    echo "wpo-s2 asm FAIL: const_spec_fold mono compile failed" >&2
    tail -8 /tmp/wpo_s2_mono_build.log 2>/dev/null || true
    die "const_spec_fold mono compile failed"
  fi
  if ! wpo_s2_darwin_skip_exe_run; then
    EXM=0
    "$OUT_MONO" >/dev/null 2>&1 || EXM=$?
    if [ "$EXM" -ne 0 ]; then
      die "const_spec_fold mono expected exit 0, got $EXM"
    fi
  fi
  if ! nm "$OUT_MONO" 2>/dev/null | grep -q 'scale__wpo_1024_64'; then
    nm "$OUT_MONO" 2>/dev/null | grep wpo || true
    die "missing mono symbol scale__wpo_1024_64"
  fi
  MAIN_MONO=$(wpo_main_asm "$OUT_MONO" || true)
  if [ -z "$MAIN_MONO" ]; then
    die "cannot disassemble _main ($OUT_MONO)"
  fi
  if ! wpo_main_calls_pat "$OUT_MONO" 'scale__wpo_1024_64'; then
    if wpo_s2_darwin_skip_exe_run && nm "$OUT_MONO" 2>/dev/null | grep -q 'scale__wpo_1024_64'; then
      echo "wpo-s2 asm mono OK (Darwin .o: nm scale__wpo_1024_64; bl sym N/A in disasm)"
    else
      echo "$MAIN_MONO" | grep -E 'bl|call|scale' || true
      die "_main expected bl scale__wpo_1024_64"
    fi
  else
    if wpo_main_calls_pat "$OUT_MONO" '_scale([^_a-zA-Z0-9]|$)|[[:space:]]_scale([^_a-zA-Z0-9]|$)'; then
      die "_main should not bl generic _scale in mono mode"
    fi
    echo "wpo-s2 asm mono OK (scale__wpo_1024_64 thunk + _main bl mono sym)"
  fi
  RUN_OK=$((RUN_OK + 1))

  OUT_VEC=$(wpo_s2_asm_out_path /tmp/xlang_wpo_vec_const_spec_fold)
  if ! "$ASM_BIN" tests/wpo/vec_const_spec_fold.x -o "$OUT_VEC" 2>/tmp/wpo_s2_vec_build.log; then
    echo "wpo-s2 asm FAIL: vec_const_spec_fold compile failed" >&2
    tail -8 /tmp/wpo_s2_vec_build.log 2>/dev/null || true
    die "vec_const_spec_fold compile failed"
  fi
  if ! wpo_s2_darwin_skip_exe_run; then
    EXV=0
    "$OUT_VEC" >/dev/null 2>&1 || EXV=$?
    if [ "$EXV" -ne 0 ]; then
      die "vec_const_spec_fold expected exit 0, got $EXV"
    fi
  fi
  MAIN_VEC=$(wpo_main_asm "$OUT_VEC" || true)
  if [ -z "$MAIN_VEC" ]; then
    die "cannot disassemble _main ($OUT_VEC)"
  fi
  if wpo_main_calls_pat "$OUT_VEC" 'vec_add4|lane0'; then
    echo "$MAIN_VEC" | grep -E 'bl|call|vec_add4|lane0' || true
    die "_main still bl vec_add4/lane0 (expected WPO vec const fold)"
  fi
  echo "wpo-s2 asm vec fold OK (_main no bl vec_add4/lane0, exit 0)"
  RUN_OK=$((RUN_OK + 1))

  OUT_VEC_MONO=$(wpo_s2_asm_out_path /tmp/xlang_wpo_vec_const_spec_mono)
  if ! XLANG_WPO_MONO=1 "$ASM_BIN" tests/wpo/vec_const_spec_mono.x -o "$OUT_VEC_MONO" 2>/tmp/wpo_s2_vec_mono_build.log; then
    echo "wpo-s2 asm FAIL: vec_const_spec_mono compile failed" >&2
    tail -8 /tmp/wpo_s2_vec_mono_build.log 2>/dev/null || true
    die "vec_const_spec_mono compile failed"
  fi
  if ! wpo_s2_darwin_skip_exe_run; then
    EXVM=0
    "$OUT_VEC_MONO" >/dev/null 2>&1 || EXVM=$?
    if [ "$EXVM" -ne 0 ]; then
      die "vec_const_spec_mono expected exit 0, got $EXVM"
    fi
  fi
  if ! nm "$OUT_VEC_MONO" 2>/dev/null | grep -q 'lane0__wpo_1_2_3_4_10_20_30_40'; then
    nm "$OUT_VEC_MONO" 2>/dev/null | grep wpo || true
    die "missing vec mono symbol lane0__wpo_1_2_3_4_10_20_30_40"
  fi
  MAIN_VEC_MONO=$(wpo_main_asm "$OUT_VEC_MONO" || true)
  if [ -z "$MAIN_VEC_MONO" ]; then
    die "cannot disassemble _main ($OUT_VEC_MONO)"
  fi
  if ! wpo_main_calls_pat "$OUT_VEC_MONO" 'lane0__wpo_1_2_3_4_10_20_30_40'; then
    if wpo_s2_darwin_skip_exe_run && nm "$OUT_VEC_MONO" 2>/dev/null | grep -q 'lane0__wpo_1_2_3_4_10_20_30_40'; then
      echo "wpo-s2 asm vec mono OK (Darwin .o: nm lane0__wpo_*; bl sym N/A in disasm)"
    else
      echo "$MAIN_VEC_MONO" | grep -E 'bl|call|lane0' || true
      die "_main expected bl lane0__wpo_1_2_3_4_10_20_30_40"
    fi
  elif wpo_main_calls_pat "$OUT_VEC_MONO" 'lane0([^_a-zA-Z0-9]|$)|vec_add4'; then
    die "_main should not bl generic lane0/vec_add4 in vec mono mode"
  else
    echo "wpo-s2 asm vec mono OK (lane0__wpo_* thunk + _main bl mono sym)"
  fi
  RUN_OK=$((RUN_OK + 1))
elif wpo_host_asm_run_na; then
  SKIP=1
  echo "wpo-s2: asm fold/mono N/A on $(uname -s)-$(uname -m) (refresh xlang_asm asm stub; x86_64 covers)"
else
  die "no native xlang_asm for leftover nested asm fold (refuse leftover auto-make)"
fi

echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} graph=${GRAPH_OK} host=$(ci_host_summary)"
echo "wpo-s2 smoke OK"
