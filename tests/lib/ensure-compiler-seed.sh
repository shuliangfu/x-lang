#!/usr/bin/env bash
# 门禁脚本共用：仅保证 seed shu 存在，勿 make -C compiler（all 为 C-only，会覆盖 shu_asm 门禁前提）。
# 用法：在仓库根目录 source tests/lib/ensure-compiler-seed.sh
if [ ! -x compiler/shu ]; then
  make -C compiler bootstrap-driver-seed
fi
