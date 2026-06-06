#!/usr/bin/env bash
# WPO-S4 PGO-Lite 门禁：S0 binary __text 代理不回归；S1 SHU_WPO_PGO_HOT=1 时 .text.hot + .text.unlikely；S2 call-depth emit 序。
# 用法：
#   ./tests/run-wpo-s4-gate.sh
#   SHU=./compiler/shu_asm SHU_WPO_PGO_HOT=1 ./tests/run-wpo-s4-gate.sh
set -e
cd "$(dirname "$0")/.."

SHU_ASM="${SHU:-./compiler/shu_asm}"
case "$SHU_ASM" in
  /*) SHU_ASM_ABS="$SHU_ASM" ;;
  *) SHU_ASM_ABS="$(pwd)/$SHU_ASM" ;;
esac

echo "=== WPO-S4-S0: shu_asm binary .text proxy (PGO-Lite baseline) ==="

if [ ! -x "$SHU_ASM_ABS" ]; then
  echo "wpo-s4 gate SKIP (no shu_asm: $SHU_ASM_ABS)"
  exit 0
fi

chmod +x tests/run-perf-wpo-dce-shu-asm-text.sh tests/lib/wpo-ab-proxy.sh
SHU="$SHU_ASM" ./tests/run-perf-wpo-dce-shu-asm-text.sh

# S4-S1：编译用户程序并断言 .text.hot 段（非 shu_asm 自身）
if [ -n "${SHU_WPO_PGO_HOT:-}" ]; then
  echo "=== WPO-S4-S1: user .o .text.hot + .text.unlikely (SHU_WPO_PGO_HOT=1) ==="
  if ! command -v readelf >/dev/null 2>&1; then
    echo "wpo-s4: readelf missing; skip PGO section check"
  else
    PGO_O="/tmp/shu_wpo_pgo_hot_smoke.o"
    PGO_SRC="tests/wpo/pgo_hot_smoke.su"
    rm -f "$PGO_O"
    if ! SHU_WPO_PGO_HOT=1 SHU="$SHU_ASM" "$SHU_ASM_ABS" "$PGO_SRC" -o "$PGO_O"; then
      echo "wpo-s4 FAIL: compile $PGO_SRC with SHU_WPO_PGO_HOT=1" >&2
      exit 1
    fi
    if ! readelf -S "$PGO_O" 2>/dev/null | grep -q '\.text\.hot'; then
      echo "wpo-s4 FAIL: no .text.hot in $PGO_O (SHU_WPO_PGO_HOT=1)" >&2
      exit 1
    fi
    UNLIKELY_LINE="$(readelf -S "$PGO_O" 2>/dev/null | grep '\.text\.unlikely' || true)"
    if [ -z "$UNLIKELY_LINE" ]; then
      echo "wpo-s4 FAIL: no .text.unlikely in $PGO_O (SHU_WPO_PGO_HOT=1)" >&2
      exit 1
    fi
    UNLIKELY_SIZE="$(echo "$UNLIKELY_LINE" | awk '{print $6}')"
    if [ -z "$UNLIKELY_SIZE" ] || [ "$UNLIKELY_SIZE" = "000000" ]; then
      echo "wpo-s4 FAIL: .text.unlikely size is zero in $PGO_O" >&2
      exit 1
    fi
    echo "wpo-s4: .text.hot + .text.unlikely present in user .o ($PGO_O, unlikely size=$UNLIKELY_SIZE)"
    echo "=== WPO-S4-S2: .text.hot emit call-depth order ==="
    MAIN_LINE="$(readelf -s "$PGO_O" 2>/dev/null | awk '$4=="FUNC" && $NF=="main" {print; exit}')"
    WM_LINE="$(readelf -s "$PGO_O" 2>/dev/null | awk '$4=="FUNC" && $NF=="warm_mid" {print; exit}')"
    HA_LINE="$(readelf -s "$PGO_O" 2>/dev/null | awk '$4=="FUNC" && $NF=="hot_add" {print; exit}')"
    if [ -z "$MAIN_LINE" ] || [ -z "$WM_LINE" ]; then
      echo "wpo-s4 FAIL: missing main/warm_mid symbol in $PGO_O" >&2
      exit 1
    fi
    MAIN_NDX="$(echo "$MAIN_LINE" | awk '{print $7}')"
    WM_NDX="$(echo "$WM_LINE" | awk '{print $7}')"
    MAIN_VAL="$(echo "$MAIN_LINE" | awk '{print $2}')"
    WM_VAL="$(echo "$WM_LINE" | awk '{print $2}')"
    if [ "$MAIN_NDX" != "2" ] || [ "$WM_NDX" != "2" ]; then
      echo "wpo-s4 FAIL: main/warm_mid not in .text.hot (shndx 2): main=$MAIN_NDX warm_mid=$WM_NDX" >&2
      exit 1
    fi
    if [ -z "$MAIN_VAL" ] || [ -z "$WM_VAL" ]; then
      echo "wpo-s4 FAIL: cannot read main/warm_mid symbol offset" >&2
      exit 1
    fi
    if [ $((16#${MAIN_VAL#0x})) -gt $((16#${WM_VAL#0x})) ]; then
      echo "wpo-s4 FAIL: main offset ($MAIN_VAL) > warm_mid ($WM_VAL); expect call-depth emit order" >&2
      exit 1
    fi
    if [ -n "$HA_LINE" ]; then
      HA_NDX="$(echo "$HA_LINE" | awk '{print $7}')"
      if [ "$HA_NDX" != "3" ]; then
        echo "wpo-s4 FAIL: hot_add shndx=$HA_NDX (expect 3 .text.unlikely, depth>=2)" >&2
        exit 1
      fi
    fi
    echo "wpo-s4: .text.hot order OK (main=$MAIN_VAL <= warm_mid=$WM_VAL)"
    rm -f "$PGO_O"
  fi
fi

echo "wpo-s4 gate OK"
