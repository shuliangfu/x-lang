#!/usr/bin/env bash
# ZC-3/P5：数组→slice 绑定 + 局部/形参 .data/.length 字段烟测（不依赖 core.option 链接）。
# 用法：./tests/run-slice-field.sh
set -e
cd "$(dirname "$0")/.."

if [ -n "$SHU" ]; then
  :
elif [ -x ./compiler/shu ]; then
  SHU=./compiler/shu
elif [ -x ./compiler/shu-c ]; then
  SHU=./compiler/shu-c
else
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c
  SHU=./compiler/shu-c
fi

# shu_asm 实验链 -o 链接 slice 字段 codegen 不完整；非 x86_64 须 shu-c 避免 asm x86_64 .o。
# shellcheck source=lib/bootstrap-link-shu.sh
. "$(dirname "$0")/lib/bootstrap-link-shu.sh"

make -C compiler -q ../std/process/process.o 2>/dev/null || make -C compiler ../std/process/process.o

$RUN_SHU tests/slice/data_field.su -o /tmp/shu_slice_data_field 2>&1
ec=0; /tmp/shu_slice_data_field >/dev/null 2>&1 || ec=$?
[ "$ec" -ne 0 ] && { echo "expected exit 0 (slice data_field), got $ec"; exit 1; }

$RUN_SHU tests/slice/main.su -o /tmp/shu_slice_main 2>&1
ec=0; /tmp/shu_slice_main >/dev/null 2>&1 || ec=$?
[ "$ec" -ne 20 ] && { echo "expected exit 20 (slice main s[1]), got $ec"; exit 1; }

echo "slice field OK"
