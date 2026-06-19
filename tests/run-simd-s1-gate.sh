#!/usr/bin/env bash
# SIMD-S1 门禁：`-target-cpu` 解析 + 宿主机 feature 探测（--print-target-cpu）。
# 用法：
#   ./tests/run-simd-s1-gate.sh
#   SHUX=./compiler/shux ./tests/run-simd-s1-gate.sh
set -e
cd "$(dirname "$0")/.."

SHUX_BIN="${SHUX:-}"
case "$SHUX_BIN" in
  /*) SHUX_ABS="$SHUX_BIN" ;;
  "") SHUX_ABS="" ;;
  *) SHUX_ABS="$(pwd)/$SHUX_BIN" ;;
esac

# 优先选择与宿主机 ABI 匹配的可执行文件（避免 Linux shux-c 在 macOS 上误选）。
simd_s1_native_exe() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

if [ -z "$SHUX_ABS" ] || ! simd_s1_native_exe "$SHUX_ABS"; then
  SHUX_ABS=""
  for cand in ./compiler/shux_asm ./compiler/shux; do
    case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
    if simd_s1_native_exe "$abs"; then
      SHUX_ABS="$abs"
      break
    fi
  done
fi

echo "=== SIMD-S1: --print-target-cpu (host probe) ==="

if [ -z "$SHUX_ABS" ] || ! simd_s1_native_exe "$SHUX_ABS"; then
  echo "simd-s1 gate SKIP (no native shux/shux_asm)"
  exit 0
fi

OUT="$(mktemp)"
trap 'rm -f "$OUT"' EXIT

if ! "$SHUX_ABS" --print-target-cpu >"$OUT" 2>&1; then
  echo "simd-s1 FAIL: --print-target-cpu exit non-zero" >&2
  cat "$OUT" >&2
  exit 1
fi

if ! grep -q '^target_cpu_features=0x' "$OUT"; then
  echo "simd-s1 FAIL: missing target_cpu_features line" >&2
  cat "$OUT" >&2
  exit 1
fi

if ! grep -q '^target_cpu_host_features=0x' "$OUT"; then
  echo "simd-s1 FAIL: missing target_cpu_host_features line" >&2
  cat "$OUT" >&2
  exit 1
fi

ARCH="$(uname -m 2>/dev/null || echo unknown)"
FEAT_LINE="$(grep '^target_cpu_features=' "$OUT" | head -1)"
FEAT_HEX="${FEAT_LINE#target_cpu_features=0x}"
FEAT_VAL=$((16#$FEAT_HEX))

echo "simd-s1: host arch=$ARCH features=$FEAT_LINE"

case "$ARCH" in
  x86_64|amd64)
    if [ "$FEAT_VAL" -eq 0 ]; then
      echo "simd-s1 FAIL: x86_64 host features=0 (expect at least SSE2)" >&2
      exit 1
    fi
    ;;
  aarch64|arm64)
    NEON_MASK=256
    if [ $((FEAT_VAL & NEON_MASK)) -eq 0 ]; then
      echo "simd-s1 FAIL: arm64 host missing NEON bit" >&2
      exit 1
    fi
    ;;
esac

echo "=== SIMD-S1: -target-cpu generic (baseline subset) ==="
GEN_OUT="$(mktemp)"
trap 'rm -f "$OUT" "$GEN_OUT"' EXIT

if ! "$SHUX_ABS" --print-target-cpu -target-cpu generic >"$GEN_OUT" 2>&1; then
  echo "simd-s1 FAIL: --print-target-cpu -target-cpu generic" >&2
  cat "$GEN_OUT" >&2
  exit 1
fi

GEN_LINE="$(grep '^target_cpu_features=' "$GEN_OUT" | head -1)"
GEN_HEX="${GEN_LINE#target_cpu_features=0x}"
GEN_VAL=$((16#$GEN_HEX))

if [ "$GEN_VAL" -gt "$FEAT_VAL" ]; then
  echo "simd-s1 FAIL: generic ($GEN_LINE) > native ($FEAT_LINE)" >&2
  exit 1
fi

echo "simd-s1: generic baseline OK ($GEN_LINE <= $FEAT_LINE)"
echo "simd-s1 gate OK"
