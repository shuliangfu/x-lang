#!/usr/bin/env bash
# S5: strict-chain WPO link gate (pipeline_wpo helpers + C orch → xlang_asm.strict_glue).
#
# Honesty: soft SKIP→OK when no native xlang_asm/strict_glue retired.
# Missing native = hard die. Relink/UNDEF residual: FAIL=1 hard die; FAIL=0
# → obs + exit 0 (caller-requested soft residual, counted). Reach gates stay
# hard. Report run=/obs=/skip=.
#
# Usage:
#   ./tests/run-wpo-strict-link-gate.sh
#   XLANG_WPO_STRICT_LINK_FAIL=1 ./tests/run-wpo-strict-link-gate.sh
# Env:   XLANG_WPO_STRICT_LINK_SKIP=1 → skip=1 status=ok
# 2026-08-27: soft SKIP→OK →硬绿.
# PLATFORM: SHARED — try real strict_glue on Darwin and Linux (false Darwin
# N/A narrative retired). Ubuntu gold for FAIL=1.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/comp-riscv64.sh
. tests/lib/comp-riscv64.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_WPO_STRICT_LINK_PREFIX:-xlang: [XLANG_WPO_STRICT_LINK]}"
FAIL=${XLANG_WPO_STRICT_LINK_FAIL:-1}
COMPILER="${XLANG_WPO_STRICT_LINK_COMPILER:-compiler/xlang_asm.strict_glue}"
PIPE_WPO="${XLANG_WPO_PIPELINE_O:-compiler/build_asm/pipeline_wpo.o}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "run-wpo-strict-link-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

obs_residual() {
  echo "run-wpo-strict-link-gate OBS: $* (FAIL=0 soft residual; counted)" >&2
  OBS=$((OBS + 1))
}

echo "=== wpo strict link gate (pipeline_wpo reach + abi-covered strict_glue) ==="
if [ "${XLANG_WPO_STRICT_LINK_SKIP:-0}" = "1" ]; then
  SKIP=$((SKIP + 1))
  gate_progress "run-wpo-strict-link-gate: SKIP (XLANG_WPO_STRICT_LINK_SKIP=1)"
  echo "run-wpo-strict-link-gate OK"
  ok_report
  exit 0
fi

chmod +x compiler/scripts/relink_xlang_asm_strict_glue.sh \
  tests/run-wpo-pipeline-reach-gate.sh \
  tests/run-wpo-typeck-reach-gate.sh \
  tests/run-wpo-backend-reach-gate.sh 2>/dev/null || true

# Native product chain required — refuse soft SKIP→OK for seed/C-only.
if ! dod_native_exe compiler/xlang_asm && ! dod_native_exe "$COMPILER"; then
  die "no native xlang_asm/strict_glue (refuse soft SKIP→OK)"
fi
if [ -x compiler/xlang_asm ] && ! comp_riscv64_native_xlang compiler/xlang_asm \
  && [ ! -x "$COMPILER" ]; then
  die "xlang_asm present but not native for this host (refuse soft SKIP→OK)"
fi

# Soft XLANG_WPO_*_REACH_FAIL retired — reach gates hard-die on miss/U.
./tests/run-wpo-pipeline-reach-gate.sh "$PIPE_WPO" || die "pipeline_wpo reach failed"
if [ -f compiler/build_asm/typeck_wpo.o ]; then
  ./tests/run-wpo-typeck-reach-gate.sh compiler/build_asm/typeck_wpo.o || die "typeck_wpo reach failed"
fi
if [ -f compiler/build_asm/backend_wpo.o ]; then
  ./tests/run-wpo-backend-reach-gate.sh compiler/build_asm/backend_wpo.o || die "backend_wpo reach failed"
fi
RUN_OK=$((RUN_OK + 1))

# Capture relink rc: set -e must not abort before FAIL=0 obs residual path.
# PLATFORM: SHARED — Darwin stubs dual residual is honest obs when FAIL=0.
if ! (
  cd compiler
  export XLANG_ASM_STRICT_LINK_PIPELINE_WPO=1
  # FULL=0: abi already on LD argv; avoid dual-authority whole pipeline_wpo.
  export XLANG_ASM_STRICT_LINK_PIPELINE_WPO_FULL=0
  export STRICT_LINK_BUILD_ASM_PIPELINE=1
  export STRICT_LINK_BUILD_ASM_WPO=1
  export STRICT_LINK_BUILD_ASM_BACKEND_WPO=1
  ./scripts/relink_xlang_asm_strict_glue.sh
); then
  if [ "$FAIL" = "1" ]; then
    die "strict_glue relink failed (0-symbol/N/A lifted; final-link residual)"
  fi
  obs_residual "strict_glue relink failed"
  echo "run-wpo-strict-link-gate OK"
  ok_report
  exit 0
fi

if [ ! -x "$COMPILER" ]; then
  if [ "$FAIL" = "1" ]; then
    die "missing $COMPILER"
  fi
  obs_residual "missing $COMPILER"
  echo "run-wpo-strict-link-gate OK"
  ok_report
  exit 0
fi

# Linked binary must resolve orch symbols (not U). Mach-O nm uses leading _; ELF often bare.
MISSING=""
for sym in \
  run_x_pipeline_impl \
  typeck_x_ast \
  check_block \
  asm_codegen_ast \
  backend_asm_codegen_ast_seed_mega; do
  if nm "$COMPILER" 2>/dev/null | grep -qE " U (_)?${sym}$"; then
    MISSING="${MISSING} ${sym}"
  fi
done
if [ -n "$MISSING" ]; then
  if [ "$FAIL" = "1" ]; then
    die "$COMPILER undefined:${MISSING}"
  fi
  obs_residual "$COMPILER undefined:${MISSING}"
  echo "run-wpo-strict-link-gate OK"
  ok_report
  exit 0
fi
RUN_OK=$((RUN_OK + 1))

# Optional smoke compile (strict_glue full-path asm still unstable; default off).
if [ "${XLANG_WPO_STRICT_LINK_SMOKE_COMPILE:-0}" = "1" ]; then
  LIBROOT="-L compiler/asm_libroot -L compiler/src -L std -L core"
  TEST_X="tests/asm/binop_var_fast.x"
  TMP_O="/tmp/xlang_wpo_strict_link_smoke.$$.o"
  rm -f "$TMP_O" 2>/dev/null || true
  if ! "$COMPILER" -backend asm -o "$TMP_O" $LIBROOT "$TEST_X" 2>/dev/null; then
    if [ "$FAIL" = "1" ]; then
      die "$COMPILER cannot compile $TEST_X"
    fi
    obs_residual "smoke compile failed"
  elif [ ! -s "$TMP_O" ]; then
    if [ "$FAIL" = "1" ]; then
      die "empty output from $TEST_X"
    fi
    obs_residual "empty smoke .o"
  else
    rm -f "$TMP_O" 2>/dev/null || true
    gate_progress "run-wpo-strict-link-gate: smoke compile OK ($TEST_X)"
    RUN_OK=$((RUN_OK + 1))
  fi
fi

gate_progress "run-wpo-strict-link-gate OK ($COMPILER; reach+abi orch)"
echo "run-wpo-strict-link-gate OK ($COMPILER; reach+abi orch; helpers extract soft when dual)"
ok_report
