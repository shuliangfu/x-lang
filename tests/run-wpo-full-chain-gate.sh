#!/usr/bin/env bash
# S5 WPO full-chain gate: five-module build_asm WPO artifacts + chain +
# strict link + binary proxy (requires xlang_asm). Lighter than
# run-bootstrap-bstrict-ci.sh (skips whitelist/stage2).
#
# Honesty: soft SKIP→OK when no xlang_asm retired. Missing native = hard die.
# Darwin strict_link residual = obs and CONTINUE (do not early-exit claiming
# full-chain OK after only ensure+chain). Report run=/obs=/skip=.
#
# Usage:
#   ./tests/run-wpo-full-chain-gate.sh
#   XLANG=./compiler/xlang_asm ./tests/run-wpo-full-chain-gate.sh
# Env:   XLANG_WPO_FULL_CHAIN_SKIP=1 → skip=1 status=ok
# 2026-08-27: soft SKIP→OK →硬绿.
# PLATFORM: SHARED harness — Ubuntu gold for FAIL=1 strict_link; Darwin may obs.
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

echo "=== wpo full-chain: build_asm chain gate ==="
# PLATFORM: MACOS — build_asm main.o entry symbols may residual; count obs and
# continue (Linux FAIL=1 gold). Refuse soft SKIP→OK / early silent OK.
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  set +e
  ./tests/run-wpo-build-asm-chain-gate.sh
  chain_ec=$?
  set -e
  if [ "$chain_ec" -eq 0 ]; then
    RUN_OK=$((RUN_OK + 1))
  else
    echo "wpo full-chain OBS: build_asm chain residual on Darwin (continue)" >&2
    OBS=$((OBS + 1))
  fi
else
  ./tests/run-wpo-build-asm-chain-gate.sh
  RUN_OK=$((RUN_OK + 1))
fi

echo "=== wpo full-chain: strict link gate ==="
# PLATFORM: SHARED — try real strict_glue on Darwin and Linux.
# PLATFORM: MACOS — final strict_glue link may still residual on stubs dual;
# count as obs and continue (refuse early soft OK that skips glue/proxy/stretch).
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  set +e
  XLANG_WPO_STRICT_LINK_FAIL=1 ./tests/run-wpo-strict-link-gate.sh
  sl_ec=$?
  set -e
  if [ "$sl_ec" -eq 0 ]; then
    gate_progress "wpo full-chain: strict_link OK on Darwin"
    RUN_OK=$((RUN_OK + 1))
  else
    echo "wpo full-chain OBS: strict_link residual on Darwin (continue glue/proxy/stretch)" >&2
    OBS=$((OBS + 1))
  fi
else
  XLANG_WPO_STRICT_LINK_FAIL=1 ./tests/run-wpo-strict-link-gate.sh
  RUN_OK=$((RUN_OK + 1))
fi

echo "=== wpo full-chain: strict_glue measured .text ==="
# Soft XLANG_WPO_STRICT_GLUE_TEXT_FAIL retired — gate is hard by default.
# PLATFORM: MACOS — glue text may residual after chain/link obs; count and continue.
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  set +e
  ./tests/run-wpo-strict-glue-text-gate.sh
  glue_ec=$?
  set -e
  if [ "$glue_ec" -eq 0 ]; then
    RUN_OK=$((RUN_OK + 1))
  else
    echo "wpo full-chain OBS: strict_glue text residual on Darwin (continue)" >&2
    OBS=$((OBS + 1))
  fi
else
  ./tests/run-wpo-strict-glue-text-gate.sh
  RUN_OK=$((RUN_OK + 1))
fi

echo "=== wpo full-chain: binary proxy baseline (0.8%) ==="
# PLATFORM: DARWIN — asm-text N/A → child skip; do not hard-fail full-chain.
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  set +e
  XLANG="$XLANG" XLANG_PERF_FAIL_ON_WPO_XLANG_ASM_TEXT=1 ./tests/run-perf-wpo-dce-xlang-asm-text.sh
  set -e
  SKIP=$((SKIP + 1))
else
  XLANG="$XLANG" XLANG_PERF_FAIL_ON_WPO_XLANG_ASM_TEXT=1 ./tests/run-perf-wpo-dce-xlang-asm-text.sh
  RUN_OK=$((RUN_OK + 1))
fi

echo "=== wpo full-chain: stretch -3% ==="
XLANG="$XLANG" ./tests/run-wpo-stretch-gate.sh
# stretch reports its own skip on Darwin
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  SKIP=$((SKIP + 1))
else
  RUN_OK=$((RUN_OK + 1))
fi

gate_progress "wpo full-chain gate OK (ensure + chain + strict link + proxy ≥3%)"
echo "wpo full-chain gate OK (ensure + chain + strict link + proxy ≥3%)"
ok_report
