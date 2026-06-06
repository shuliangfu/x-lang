#!/usr/bin/env bash
# SIMD-S2 门禁：std.simd Vec4f/Vec8i 编译 + 可选运行 smoke。
# 用法：
#   ./tests/run-simd-s2-gate.sh
#   SHU=./compiler/shu_asm ./tests/run-simd-s2-gate.sh
set -e
cd "$(dirname "$0")/.."

SHU_BIN="${SHU:-}"
case "$SHU_BIN" in
  /*) SHU_ABS="$SHU_BIN" ;;
  "") SHU_ABS="" ;;
  *) SHU_ABS="$(pwd)/$SHU_BIN" ;;
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

if [ -z "$SHU_ABS" ] || ! simd_s2_native_exe "$SHU_ABS"; then
  SHU_ABS=""
  for cand in ./compiler/shu_asm ./compiler/shu; do
    case "$cand" in /*) abs="$cand" ;; *) abs="$(pwd)/$cand" ;; esac
    if simd_s2_native_exe "$abs"; then
      SHU_ABS="$abs"
      break
    fi
  done
fi

echo "=== SIMD-S2: Vec4f / Vec8i compile smoke ==="

if [ -z "$SHU_ABS" ] || ! simd_s2_native_exe "$SHU_ABS"; then
  echo "simd-s2 gate SKIP (no native shu/shu_asm)"
  exit 0
fi

SMOKE_SRC="tests/simd/vec4f_vec8i_smoke.su"
SMOKE_O="/tmp/shu_simd_s2_smoke.o"
rm -f "$SMOKE_O"

if ! SHU="$SHU_ABS" "$SHU_ABS" "$SMOKE_SRC" -o "$SMOKE_O"; then
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
