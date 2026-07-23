#!/usr/bin/env bash
# 门禁脚本共用：仅保证 seed xlang 存在，勿 make -C compiler（all 为 C-only，会覆盖 xlang_asm 门禁前提）。
# 用法：在仓库根目录 source tests/lib/ensure-compiler-seed.sh
if [ ! -x compiler/xlang ]; then
  make -C compiler bootstrap-driver-seed
fi
