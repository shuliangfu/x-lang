#!/bin/sh
# g05_build_shux_asm.sh — G-05：build_tool → 日常 shux_asm 的唯一 shell 出口
#
# G-05 100%：默认产品路径**零 make**：
#   g05_prepare_and_relink.sh
#     → g05_ensure_relink_prereqs.sh（shell 检查 + 热路径 cc）
#     → g05_relink_env.sh（obj 清单）
#     → g05_relink_shux.sh（最终链接）
# Makefile 仅：冷启动、单文件 .o 规则、FULL=1 bstrict、历史 CI 目标。
#
# 用法（在 compiler/ 目录）：
#   sh scripts/g05_build_shux_asm.sh
#   SHUX_BUILD_TOOL_FULL=1 sh scripts/g05_build_shux_asm.sh
#
# 环境：
#   SHUX_BUILD_TOOL_FULL=1  → make bootstrap-driver-bstrict（全量 B-strict，冷/重路径）

set -e
cd "$(dirname "$0")/.."

if [ "${SHUX_BUILD_TOOL_FULL:-}" = "1" ]; then
  echo "g05_build_shux_asm: FULL=1 → make bootstrap-driver-bstrict (non-daily)"
  exec make bootstrap-driver-bstrict
fi

echo "g05_build_shux_asm: default → g05_prepare_and_relink (G-05 100% product path, no make)"
G05_SYNC_ASM=1 sh scripts/g05_prepare_and_relink.sh
