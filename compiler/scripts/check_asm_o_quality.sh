#!/bin/sh
# check_asm_o_quality.sh — 检查 asm_build_list 中各 -backend asm -o 产物的可执行代码段是否非空。
# 用法：在 compiler 目录执行 SHUX=./shux ./scripts/check_asm_o_quality.sh
# 依赖：build_asm/*.o 已由 build_shux_asm 或等价 asm 编译产生；需 objdump（LLVM/GNU）。
# Mach-O 段名为 __text；ELF（Linux GNU ld 产出）为 .text —— 二者皆检测，避免 Linux 上误判「全部 EMPTY」。
# 退出码：默认 0（仅报告）；SHUX_ASM_QUALITY_STRICT=1 时若有代码段为空或缺失 .o 则退出 1。
# 写入：build_asm/.asm_text_quality — 1 全部非空，0 否则（供 build_shux_asm 拓扑自动选择）。
#       build_asm/.asm_empty_text_list — 每项一行「MISSING x.o」「EMPTY x.o」，供对照修 emitter/typeck/import。

set -e
cd "$(dirname "$0")/.."
BUILD_LIST_SX="src/asm/asm_build_list.sx"
BUILD_DIR="build_asm"
STRICT="${SHUX_ASM_QUALITY_STRICT:-0}"
TAB=$(printf '\t')

# 从对象文件中取出代码段大小（字节）：优先 Mach-O __text，否则 ELF .text；无法解析时输出 0。
text_section_size() {
  o="$1"
  [ -f "$o" ] || {
    echo 0
    return
  }
  hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
  [ -z "$hex" ] && hex=$(objdump -h "$o" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
  [ -z "$hex" ] && {
    echo 0
    return
  }
  perl -e 'print hex(shift)' "$hex" 2>/dev/null || echo 0
}

mkdir -p "$BUILD_DIR"
echo "check_asm_o_quality: scanning $BUILD_DIR (STRICT=$STRICT)"

if [ ! -f "$BUILD_LIST_SX" ]; then
  echo "check_asm_o_quality: $BUILD_LIST_SX missing, skip"
  echo 0 >"$BUILD_DIR/.asm_text_quality"
  exit 0
fi

bad=0
tot=0
BAD_LIST="$BUILD_DIR/.asm_empty_text_list"
# 每条一行：EMPTY 或 MISSING 的 .o 基名（供 SELFHOST / emitter 逐项对照）
rm -f "$BAD_LIST"

while IFS= read -r line; do
  rest=$(echo "$line" | sed "s|^// BUILD:${TAB}||")
  out=$(echo "$rest" | cut -f1)
  [ -z "$out" ] && continue
  tot=$((tot + 1))
  path="$BUILD_DIR/$out"
  sz=$(text_section_size "$path")
  if [ ! -f "$path" ]; then
    echo "  MISSING $out"
    echo "MISSING $out" >>"$BAD_LIST"
    bad=$((bad + 1))
  elif [ "${sz:-0}" -eq 0 ] 2>/dev/null; then
    # token.sx 仅 enum+struct+单函数；若仍空则计 bad。允许显式跳过：SHUX_ASM_ALLOW_EMPTY_TEXT=token.o,...
    allow_empty=0
    case ",${SHUX_ASM_ALLOW_EMPTY_TEXT:-}," in
      *",$out,"*) allow_empty=1 ;;
    esac
    if [ "$allow_empty" = "1" ]; then
      echo "  OK code section $out size=0 (allowed empty)"
    else
      echo "  EMPTY code section $out"
      echo "EMPTY $out" >>"$BAD_LIST"
      bad=$((bad + 1))
    fi
  else
    echo "  OK code section $out size=$sz"
  fi
done <<EOF
$(grep '^// BUILD:' "$BUILD_LIST_SX")
EOF

echo "check_asm_o_quality: summary bad=$bad total=$tot"

if [ "$bad" -eq 0 ] && [ "$tot" -gt 0 ]; then
  echo 1 >"$BUILD_DIR/.asm_text_quality"
  echo "check_asm_o_quality: all objects have non-empty code section (.text/__text)"
  : >"$BAD_LIST"
  exit 0
fi

echo 0 >"$BUILD_DIR/.asm_text_quality"
echo "check_asm_o_quality: empty/missing list -> $BAD_LIST (see compiler/docs/SELFHOST.md §4)"
echo "check_asm_o_quality: see compiler/docs/SELFHOST.md (topology / Target B)"
if [ "$STRICT" = "1" ]; then
  exit 1
fi
exit 0
