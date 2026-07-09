#!/bin/sh
# g05_build_shux_asm.sh — G-05：build_tool → 日常 shux_asm 的唯一 shell 出口
#
# 目的：把「产物金标准 = make shux_asm / relink」收敛到本脚本，避免
# build_tool_libc_bridge.c 直接散落 `make …` 字符串。后续若把 relink 从
# Makefile 抽成纯 shell/cc，只改本文件即可，调用方（build_tool / c08 gate）不动。
#
# 用法（在 compiler/ 目录）：
#   sh scripts/g05_build_shux_asm.sh
#   SHUX_BUILD_TOOL_FULL=1 sh scripts/g05_build_shux_asm.sh
#
# 环境：
#   SHUX_BUILD_TOOL_FULL=1  → make bootstrap-driver-bstrict（全量 B-strict）
#   默认                    → make shux_asm（relink 金标准）
#
# 注意：当前实现仍委托 Makefile（冷启动/增量依赖图尚未迁出）。
# 这是刻意分层：用户入口已是 build.x/build_tool；Makefile 是实现层兜底。

set -e
cd "$(dirname "$0")/.."

if [ "${SHUX_BUILD_TOOL_FULL:-}" = "1" ]; then
  echo "g05_build_shux_asm: FULL=1 → make bootstrap-driver-bstrict"
  exec make bootstrap-driver-bstrict
fi

echo "g05_build_shux_asm: default → make shux_asm (relink gold)"
exec make shux_asm
