#!/usr/bin/env bash
# ZC-3/P5：数组→slice 绑定 + 局部/形参 .data/.length 字段烟测（不依赖 core.option 链接）。
# 用法：./tests/run-slice-field.sh
set -e
cd "$(dirname "$0")/.."

if [ -n "$XLANG" ]; then
  :
elif [ -x ./compiler/xlang ]; then
  XLANG=./compiler/xlang
elif [ -x ./compiler/xlang-c ]; then
  XLANG=./compiler/xlang-c
else
  make -C compiler -q xlang-c 2>/dev/null || make -C compiler xlang-c
  XLANG=./compiler/xlang-c
fi

# xlang_asm 实验链 -o 链接 slice 字段 codegen 不完整；非 x86_64 须 xlang-c 避免 asm x86_64 .o。
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

# slice 烟测不 import std.process；勿强编 process.o（arm64 上 xlang-c 无 -backend asm）。
$RUN_XLANG build tests/slice/data_field.x -o /tmp/xlang_slice_data_field 2>&1
ec=0; /tmp/xlang_slice_data_field >/dev/null 2>&1 || ec=$?
[ "$ec" -ne 0 ] && { echo "expected exit 0 (slice data_field), got $ec"; exit 1; }

$RUN_XLANG build tests/slice/main.x -o /tmp/xlang_slice_main 2>&1
ec=0; /tmp/xlang_slice_main >/dev/null 2>&1 || ec=$?
[ "$ec" -ne 20 ] && { echo "expected exit 20 (slice main s[1]), got $ec"; exit 1; }

echo "slice field OK"
