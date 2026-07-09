#!/bin/sh
# g05_prepare_and_relink.sh — G-05 100%：产品路径编排（依赖准备 + 最终链接）
#
# 产品日常 shux/shux_asm 的**编排图**全部在 shell：
#   g05_ensure_relink_prereqs.sh → g05_relink_env.sh → g05_relink_shux.sh
# Makefile **不**参与产品路径（仅冷启动 / 单文件 .o 规则兜底）。
#
# 用法（compiler/ 目录）：
#   sh scripts/g05_prepare_and_relink.sh
#   G05_SYNC_ASM=1 sh scripts/g05_prepare_and_relink.sh   # 默认 1

set -e
cd "$(dirname "$0")/.."

SYNC_ASM="${G05_SYNC_ASM:-1}"

echo "g05_prepare_and_relink: ensure prereqs (shell, no make)"
sh scripts/g05_ensure_relink_prereqs.sh

echo "g05_prepare_and_relink: export link env (shell) + final link"
# shellcheck disable=SC2046
eval "$(sh scripts/g05_relink_env.sh)"
export G05_CC G05_CFLAGS G05_OUT G05_SHUX_C G05_BOOTSTRAP G05_OBJS
export G05_SYNC_ASM=0
sh scripts/g05_relink_shux.sh

if [ "$SYNC_ASM" = "1" ]; then
  cp -f "${G05_OUT:-shux}" shux_asm
  echo "g05_prepare_and_relink: shux_asm OK (synced from ${G05_OUT:-shux})"
fi

echo "g05_prepare_and_relink OK"
