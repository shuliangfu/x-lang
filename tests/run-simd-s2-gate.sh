#!/usr/bin/env bash
# SIMD-S2 门禁：std.simd Vec4f/Vec8i 编译 + 可选运行 smoke。
# 用法：
#   ./tests/run-simd-s2-gate.sh
#   SHUX=./compiler/shux_asm ./tests/run-simd-s2-gate.sh
set -e
cd "$(dirname "$0")/.."

SHUX_BIN="${SHUX:-}"
case "$SHUX_BIN" in
  /*) SHUX_ABS="$SHUX_BIN" ;;
  "") SHUX_ABS="" ;;
  *) SHUX_ABS="$(pwd)/$SHUX_BIN" ;;
esac

simd_s2_native_exe() {
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

if [ -z "$SHUX_ABS" ] || ! simd_s2_native_exe "$SHUX_ABS"; then
  SHUX_ABS=""
  for cand in ./compiler/shux_asm ./compiler/shux; do
    case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
    if simd_s2_native_exe "$abs"; then
      SHUX_ABS="$abs"
      break
    fi
  done
fi

echo "=== SIMD-S2: Vec4f / Vec8i compile smoke ==="

if [ -z "$SHUX_ABS" ] || ! simd_s2_native_exe "$SHUX_ABS"; then
  echo "simd-s2 gate SKIP (no native shux/shux_asm)"
  exit 0
fi

SMOKE_SRC="tests/simd/vec4f_vec8i_smoke.x"
SMOKE_O="/tmp/shux_simd_s2_smoke.o"
rm -f "$SMOKE_O"

if ! SHUX="$SHUX_ABS" "$SHUX_ABS" "$SMOKE_SRC" -o "$SMOKE_O"; then
  echo "simd-s2 FAIL: compile $SMOKE_SRC" >&2
  exit 1
fi

if [ ! -f "$SMOKE_O" ]; then
  echo "simd-s2 FAIL: missing $SMOKE_O" >&2
  exit 1
fi

if command -v readelf >/dev/null 2>&1; then
  # readelf -S 双行格式：`.text` 在第 1 行，Size 在下一行第 1 列（勿用 $2==".text"）。
  if ! readelf -S "$SMOKE_O" 2>/dev/null | grep -qE '[[:space:]]\.text[[:space:]]'; then
    echo "simd-s2 FAIL: no .text in $SMOKE_O" >&2
    exit 1
  fi
  TEXT_SIZE="$(readelf -S "$SMOKE_O" 2>/dev/null | awk '
    /[[:space:]]\.text[[:space:]]/ { getline; print $1; exit }
  ')"
  if [ -z "$TEXT_SIZE" ] || [ "$TEXT_SIZE" = "000000" ]; then
    echo "simd-s2 FAIL: .text size zero in $SMOKE_O" >&2
    exit 1
  fi
  echo "simd-s2: .text present (size=$TEXT_SIZE)"
fi

echo "simd-s2 gate OK"
