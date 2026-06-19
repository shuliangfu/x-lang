#!/usr/bin/env bash
# run-portable-c.sh — Tier P：全平台可移植 C 编译器回归（shux-c，无 asm/自举）。
#
# 在 ARM64/Windows 等 lite CI 上替代「仅 bootstrap-shux-gate 烟测」，覆盖 std/语言/IO 等
# 与 Linux x86_64 相同的可移植 run-*.sh 子集（不含 x86 asm 专测）。
#
# 用法：./tests/run-portable-c.sh
set -e
cd "$(dirname "$0")/.."

make -C compiler -q all 2>/dev/null || make -C compiler all
if [ ! -x ./compiler/shux-c ]; then
  echo "run-portable-c FAIL: compiler/shux-c missing" >&2
  exit 1
fi

export RUN_ALL_PORTABLE=1
export RUN_ALL_USE_C=1
export SHUX=./compiler/shux-c
./tests/run-all.sh
echo "run-portable-c OK"
