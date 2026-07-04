#!/usr/bin/env bash
# ZC-3/P5：数组→slice 绑定 + 局部/形参 .data/.length 字段烟测（不依赖 core.option 链接）。
# 用法：./tests/run-slice-field.sh
set -e
cd "$(dirname "$0")/.."

if [ -n "$SHUX" ]; then
  :
elif [ -x ./compiler/shux ]; then
  SHUX=./compiler/shux
elif [ -x ./compiler/shux-c ]; then
  SHUX=./compiler/shux-c
else
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  SHUX=./compiler/shux-c
fi

# shux_asm 实验链 -o 链接 slice 字段 codegen 不完整；非 x86_64 须 shux-c 避免 asm x86_64 .o。
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"

# slice 烟测不 import std.process；勿强编 process.o（arm64 上 shux-c 无 -backend asm）。
$RUN_SHUX tests/slice/data_field.x -o /tmp/shux_slice_data_field 2>&1
ec=0; /tmp/shux_slice_data_field >/dev/null 2>&1 || ec=$?
[ "$ec" -ne 0 ] && { echo "expected exit 0 (slice data_field), got $ec"; exit 1; }

$RUN_SHUX tests/slice/main.x -o /tmp/shux_slice_main 2>&1
ec=0; /tmp/shux_slice_main >/dev/null 2>&1 || ec=$?
[ "$ec" -ne 20 ] && { echo "expected exit 20 (slice main s[1]), got $ec"; exit 1; }

echo "slice field OK"
