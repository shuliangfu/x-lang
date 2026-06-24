#!/usr/bin/env bash
# shux_asm2 跨平台烟测：native shux_asm2 编译 return 42 并验 exit=42。
#
# 用法：./tests/run-shux-asm2-cross-smoke.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/boot-027-shux-asm2-cross.sh
. tests/lib/boot-027-shux-asm2-cross.sh

ASM2=""
for c in compiler/shux_asm2 compiler/shux_asm2_refreshed; do
  if [ -x "$c" ] && boot027_native_binary "$c"; then
    ASM2="$c"
    break
  fi
done

if [ -z "$ASM2" ]; then
  echo "shux-asm2-cross-smoke SKIP (no native shux_asm2)"
  exit 0
fi

RV_SX="/tmp/shux_asm2_cross_rv_$$.sx"
OUT="/tmp/shux_asm2_cross_out_$$"
printf 'function main(): i32 { return 42; }\n' > "$RV_SX"

if ! "$ASM2" "$RV_SX" -o "$OUT" >/dev/null 2>&1; then
  echo "shux-asm2-cross-smoke FAIL: compile with $ASM2" >&2
  rm -f "$RV_SX" "$OUT"
  exit 1
fi
chmod +x "$OUT" 2>/dev/null || true

set +e
"$OUT" >/dev/null 2>&1
ec=$?
set -e
rm -f "$RV_SX" "$OUT"

if [ "$ec" -ne 42 ]; then
  echo "shux-asm2-cross-smoke FAIL: exit=$ec want 42 ($ASM2)" >&2
  exit 1
fi

echo "shux-asm2-cross-smoke OK ($ASM2 rv=42)"
