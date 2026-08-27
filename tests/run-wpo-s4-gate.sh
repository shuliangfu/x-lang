#!/usr/bin/env bash
# WPO-S4 PGO-Lite gate: S0 binary __text proxy no-regress; S1 XLANG_WPO_PGO_HOT=1
# → .text.hot + .text.unlikely; S2 call-depth emit order.
#
# Honesty: soft SKIP→OK when no xlang_asm retired. Missing native = hard die.
# Host asm/PGO N/A (Windows / Linux aarch64) = skip=1 (not silent OK without
# counter). Darwin S0 delegates to asm-text N/A (skip). Report run=/obs=/skip=.
#
# Usage:
#   ./tests/run-wpo-s4-gate.sh
#   XLANG=./compiler/xlang_asm XLANG_WPO_PGO_HOT=1 ./tests/run-wpo-s4-gate.sh
# Env:   XLANG_WPO_S4_SKIP=1 → skip=1 status=ok
# 2026-08-27: soft SKIP→OK →硬绿.
# PLATFORM: SHARED harness — Linux x86_64 gold for PGO sections; Darwin S0 skip.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-main-disasm.sh
. tests/lib/wpo-main-disasm.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_WPO_S4_PREFIX:-xlang: [XLANG_WPO_S4]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "wpo-s4 gate FAIL: $*" >&2
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

echo "=== WPO-S4: PGO-Lite ==="
if [ "${XLANG_WPO_S4_SKIP:-0}" = "1" ]; then
  SKIP=$((SKIP + 1))
  gate_progress "wpo-s4 gate: SKIP (XLANG_WPO_S4_SKIP=1)"
  echo "wpo-s4 gate OK"
  ok_report
  exit 0
fi

if wpo_host_asm_run_na; then
  SKIP=$((SKIP + 1))
  gate_progress "wpo-s4: asm/PGO N/A on $(uname -s)-$(uname -m) (skip=1; x86_64 covers)"
  echo "wpo-s4 gate OK"
  ok_report
  exit 0
fi

ASM="$(resolve_asm)" || die "no native xlang_asm (refuse soft SKIP→OK)"
export XLANG="$ASM"
export XLANG_LINK_XLANG="$ASM"

echo "=== WPO-S4-S0: xlang_asm binary .text proxy (PGO-Lite baseline) ==="
chmod +x tests/run-perf-wpo-dce-xlang-asm-text.sh tests/lib/wpo-ab-proxy.sh
# PLATFORM: DARWIN — asm-text N/A; count skip, do not claim S0 proxy green.
if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  SKIP=$((SKIP + 1))
  gate_progress "wpo-s4-S0: SKIP (Darwin asm-text N/A; Linux covers)"
else
  set +e
  XLANG="$ASM" ./tests/run-perf-wpo-dce-xlang-asm-text.sh
  ec=$?
  set -e
  if [ "$ec" -ne 0 ]; then
    die "S0 asm-text failed ec=$ec"
  fi
  RUN_OK=$((RUN_OK + 1))
fi

# S4-S1: compile user program and assert .text.hot (not xlang_asm itself)
if [ -n "${XLANG_WPO_PGO_HOT:-}" ]; then
  echo "=== WPO-S4-S1: user .o .text.hot + .text.unlikely (XLANG_WPO_PGO_HOT=1) ==="
  if ! command -v readelf >/dev/null 2>&1; then
    SKIP=$((SKIP + 1))
    gate_progress "wpo-s4: readelf missing; skip PGO section check"
  else
    PGO_O="/tmp/xlang_wpo_pgo_hot_smoke.$$.o"
    PGO_SRC="tests/wpo/pgo_hot_smoke.x"
    [ -f "$PGO_SRC" ] || die "missing $PGO_SRC"
    rm -f "$PGO_O"
    if ! XLANG_WPO_PGO_HOT=1 XLANG="$ASM" "$ASM" "$PGO_SRC" -o "$PGO_O"; then
      die "compile $PGO_SRC with XLANG_WPO_PGO_HOT=1"
    fi
    if ! readelf -S "$PGO_O" 2>/dev/null | grep -q '\.text\.hot'; then
      die "no .text.hot in $PGO_O (XLANG_WPO_PGO_HOT=1)"
    fi
    UNLIKELY_LINE="$(readelf -S "$PGO_O" 2>/dev/null | grep '\.text\.unlikely' || true)"
    if [ -z "$UNLIKELY_LINE" ]; then
      die "no .text.unlikely in $PGO_O"
    fi
    UNLIKELY_SIZE="$(echo "$UNLIKELY_LINE" | awk '{print $6}')"
    if [ -z "$UNLIKELY_SIZE" ] || [ "$UNLIKELY_SIZE" = "000000" ]; then
      die ".text.unlikely size is zero in $PGO_O"
    fi
    gate_progress "wpo-s4: .text.hot + .text.unlikely present ($PGO_O, unlikely=$UNLIKELY_SIZE)"
    echo "=== WPO-S4-S2: .text.hot emit call-depth order ==="
    MAIN_LINE="$(readelf -s "$PGO_O" 2>/dev/null | awk '$4=="FUNC" && $NF=="main" {print; exit}')"
    WM_LINE="$(readelf -s "$PGO_O" 2>/dev/null | awk '$4=="FUNC" && $NF=="warm_mid" {print; exit}')"
    HA_LINE="$(readelf -s "$PGO_O" 2>/dev/null | awk '$4=="FUNC" && $NF=="hot_add" {print; exit}')"
    if [ -z "$MAIN_LINE" ] || [ -z "$WM_LINE" ]; then
      die "missing main/warm_mid symbol in $PGO_O"
    fi
    MAIN_NDX="$(echo "$MAIN_LINE" | awk '{print $7}')"
    WM_NDX="$(echo "$WM_LINE" | awk '{print $7}')"
    MAIN_VAL="$(echo "$MAIN_LINE" | awk '{print $2}')"
    WM_VAL="$(echo "$WM_LINE" | awk '{print $2}')"
    if [ "$MAIN_NDX" != "2" ] || [ "$WM_NDX" != "2" ]; then
      die "main/warm_mid not in .text.hot (shndx 2): main=$MAIN_NDX warm_mid=$WM_NDX"
    fi
    if [ -z "$MAIN_VAL" ] || [ -z "$WM_VAL" ]; then
      die "cannot read main/warm_mid symbol offset"
    fi
    if [ $((16#${MAIN_VAL#0x})) -gt $((16#${WM_VAL#0x})) ]; then
      die "main offset ($MAIN_VAL) > warm_mid ($WM_VAL); expect call-depth emit order"
    fi
    if [ -n "$HA_LINE" ]; then
      HA_NDX="$(echo "$HA_LINE" | awk '{print $7}')"
      if [ "$HA_NDX" != "3" ]; then
        die "hot_add shndx=$HA_NDX (expect 3 .text.unlikely, depth>=2)"
      fi
    fi
    gate_progress "wpo-s4: .text.hot order OK (main=$MAIN_VAL <= warm_mid=$WM_VAL)"
    rm -f "$PGO_O"
    RUN_OK=$((RUN_OK + 1))
  fi
fi

gate_progress "wpo-s4 gate OK"
echo "wpo-s4 gate OK"
ok_report
