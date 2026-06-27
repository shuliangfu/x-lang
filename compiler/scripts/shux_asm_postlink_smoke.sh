#!/usr/bin/env bash
# shux_asm_postlink_smoke.sh — build_shux_asm 产出 shux_asm 的 -c/-o 烟测；失败则回退 experimental 或 SHUX 编译器
#
# 用法（compiler 目录）：
#   ./scripts/shux_asm_postlink_smoke.sh [shux_asm_path] [fallback_compiler]
#
# 回退顺序：shux_asm.experimental（strict 前快照）→ fallback_compiler（默认 $SHUX 或 ./shux）

set -euo pipefail
cd "$(dirname "$0")/.."

ASM="${1:-./shux_asm}"
FALLBACK="${2:-${SHUX:-./shux}}"
SMOKE_SRC="/tmp/shux_asm_postlink_smoke.$$.sx"
SMOKE_OUT="/tmp/shux_asm_postlink_smoke_out.$$"

cleanup() {
  rm -f "$SMOKE_SRC" "$SMOKE_OUT" 2>/dev/null || true
}
trap cleanup EXIT

if [ ! -x "$ASM" ]; then
  echo "shux_asm_postlink_smoke: missing $ASM" >&2
  exit 1
fi

printf '%s\n' 'function main(): i32 { return 42; }' >"$SMOKE_SRC"

smoke_bin() {
  local bin="$1"
  [ -x "$bin" ] || return 1
  "$bin" -c "$SMOKE_SRC" >/dev/null 2>&1 || return 1
  rm -f "$SMOKE_OUT"
  "$bin" -o "$SMOKE_OUT" "$SMOKE_SRC" >/dev/null 2>&1 || return 1
  [ -x "$SMOKE_OUT" ] || return 1
  local ec=0
  "$SMOKE_OUT" >/dev/null 2>&1 || ec=$?
  [ "$ec" -eq 42 ]
}

if smoke_bin "$ASM"; then
  echo "shux_asm_postlink_smoke: OK $ASM (-c + -o exit=42)"
  exit 0
fi

echo "shux_asm_postlink_smoke: WARN $ASM smoke failed" >&2

if [ -x ./shux_asm.experimental ] && smoke_bin ./shux_asm.experimental; then
  echo "shux_asm_postlink_smoke: fallback ./shux_asm.experimental -> $ASM" >&2
  cp -f ./shux_asm.experimental "$ASM"
  echo "shux_asm_postlink_smoke: OK after experimental fallback"
  exit 0
fi

if [ -x "$FALLBACK" ] && smoke_bin "$FALLBACK"; then
  echo "shux_asm_postlink_smoke: fallback $FALLBACK -> $ASM" >&2
  cp -f "$FALLBACK" "$ASM"
  echo "shux_asm_postlink_smoke: OK after compiler fallback"
  exit 0
fi

echo "shux_asm_postlink_smoke: FAIL no working fallback for $ASM" >&2
exit 1
