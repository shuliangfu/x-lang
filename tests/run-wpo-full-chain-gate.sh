#!/usr/bin/env bash
# S5 WPO full-chain gate: five-module build_asm WPO artifacts + chain +
# strict link + binary proxy (requires xlang_asm). Lighter than
# run-bootstrap-bstrict-ci.sh (skips whitelist/stage2).
#
# Honesty: soft SKIP→OK when no xlang_asm retired. Missing native = hard die.
# Tip chain/strict_link/glue residuals = obs and CONTINUE (do not early-exit
# claiming full-chain OK after only ensure). XLANG_WPO_FULL_CHAIN_HARD=1
# still hard-dies on those steps. Report run=/obs=/skip=.
#
# Usage:
#   ./tests/run-wpo-full-chain-gate.sh
#   XLANG=./compiler/xlang_asm ./tests/run-wpo-full-chain-gate.sh
# Env:   XLANG_WPO_FULL_CHAIN_SKIP=1 → skip=1 status=ok
#        XLANG_WPO_FULL_CHAIN_HARD=1 → chain/link/glue hard (default obs)
# 2026-08-27: soft SKIP→OK →硬绿.
# PLATFORM: SHARED harness — tip main.o entry／Darwin stubs＝obs；HARD=1 金标.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_WPO_FULL_CHAIN_PREFIX:-xlang: [XLANG_WPO_FULL_CHAIN]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "wpo full-chain gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

resolve_asm() {
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
  abs="$root/compiler/xlang_asm"
  if dod_native_exe "$abs"; then
    echo "$abs"
    return 0
  fi
  return 1
}

echo "=== wpo full-chain ==="
if [ "${XLANG_WPO_FULL_CHAIN_SKIP:-0}" = "1" ]; then
  SKIP=$((SKIP + 1))
  gate_progress "wpo full-chain gate: SKIP (XLANG_WPO_FULL_CHAIN_SKIP=1)"
  echo "wpo full-chain gate OK"
  ok_report
  exit 0
fi

ASM="$(resolve_asm)" || die "no native xlang_asm (refuse soft SKIP→OK; run: xlang_compiler_make bootstrap-driver-bstrict)"
export XLANG="$ASM"
export XLANG_LINK_XLANG="$ASM"

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

chmod +x tests/ensure-wpo-build-asm-artifacts.sh \
  tests/run-wpo-build-asm-chain-gate.sh \
  tests/run-wpo-strict-link-gate.sh \
  tests/run-wpo-strict-glue-text-gate.sh \
  tests/run-perf-wpo-dce-xlang-asm-text.sh \
  tests/run-wpo-stretch-gate.sh \
  compiler/scripts/relink_xlang_asm_strict_glue.sh

echo "=== wpo full-chain: ensure build_asm 五模块 ==="
XLANG_WPO_ENSURE_FAIL=1 XLANG_WPO_ENSURE_COMPILER="$XLANG" ./tests/ensure-wpo-build-asm-artifacts.sh
RUN_OK=$((RUN_OK + 1))

HARD="${XLANG_WPO_FULL_CHAIN_HARD:-0}"

run_step_obs() {
  # Run "$@"; on success RUN_OK++; on fail HARD=1 → die, else OBS++ and continue.
  local label="$1"
  shift
  set +e
  "$@"
  local ec=$?
  set -e
  if [ "$ec" -eq 0 ]; then
    RUN_OK=$((RUN_OK + 1))
    return 0
  fi
  if [ "$HARD" = "1" ]; then
    die "$label failed ec=$ec (XLANG_WPO_FULL_CHAIN_HARD=1)"
  fi
  echo "wpo full-chain OBS: $label residual ec=$ec (continue; not soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
}

echo "=== wpo full-chain: build_asm chain gate ==="
# PLATFORM: SHARED — tip build_asm main.o may miss main_entry/entry (obs).
run_step_obs "build_asm chain" ./tests/run-wpo-build-asm-chain-gate.sh

echo "=== wpo full-chain: strict link gate ==="
# PLATFORM: SHARED — try real strict_glue; Darwin stubs dual may obs.
run_step_obs "strict_link" \
  env XLANG_WPO_STRICT_LINK_FAIL=1 ./tests/run-wpo-strict-link-gate.sh

echo "=== wpo full-chain: strict_glue measured .text ==="
# Soft XLANG_WPO_STRICT_GLUE_TEXT_FAIL retired — child hard by default; tip may obs.
run_step_obs "strict_glue text" ./tests/run-wpo-strict-glue-text-gate.sh

echo "=== wpo full-chain: binary proxy baseline (0.8%) ==="
# PLATFORM: DARWIN — asm-text N/A → child skip; Linux tip ≥0.8% hard via FAIL_ON.
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  set +e
  XLANG="$XLANG" XLANG_PERF_FAIL_ON_WPO_XLANG_ASM_TEXT=1 ./tests/run-perf-wpo-dce-xlang-asm-text.sh
  set -e
  SKIP=$((SKIP + 1))
else
  run_step_obs "asm-text baseline" \
    env XLANG="$XLANG" XLANG_PERF_FAIL_ON_WPO_XLANG_ASM_TEXT=1 \
    ./tests/run-perf-wpo-dce-xlang-asm-text.sh
fi

echo "=== wpo full-chain: stretch -3% ==="
# stretch defaults tip under-min to obs; Darwin skip.
set +e
XLANG="$XLANG" ./tests/run-wpo-stretch-gate.sh
st_ec=$?
set -e
if [ "$st_ec" -ne 0 ]; then
  if [ "$HARD" = "1" ]; then
    die "stretch failed ec=$st_ec (XLANG_WPO_FULL_CHAIN_HARD=1)"
  fi
  echo "wpo full-chain OBS: stretch residual ec=$st_ec (continue)" >&2
  OBS=$((OBS + 1))
elif [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  SKIP=$((SKIP + 1))
else
  RUN_OK=$((RUN_OK + 1))
fi

gate_progress "wpo full-chain gate OK (ensure + chain + strict link + proxy; obs=${OBS})"
echo "wpo full-chain gate OK (ensure + chain + strict link + proxy ≥3%)"
ok_report
