#!/bin/sh
# g05_build_xlang_asm.sh — G-05：build_tool → 日常 xlang_asm 的唯一 shell 出口
#
# G-05 100%：默认产品路径**零 make**：
#   g05_prepare_and_relink.sh
#     → g05_ensure_relink_prereqs.sh（shell 检查 + 热路径 cc）
#     → g05_relink_env.sh（obj 清单）
#     → g05_relink_xlang.sh（最终链接）
# Makefile 已物理删除（wave941+）。FULL=1 走 shell bootstrap_driver_bstrict.sh。
#
# 用法（在 compiler/ 目录）：
#   sh scripts/g05_build_xlang_asm.sh
#   XLANG_BUILD_TOOL_FULL=1 sh scripts/g05_build_xlang_asm.sh
#
# 环境：
#   XLANG_BUILD_TOOL_FULL=1 → bash scripts/bootstrap_driver_bstrict.sh（全量 B-strict）
#   XLANG_G05_FULL_VIA_MAKE=1 + Makefile → historic `make bootstrap-driver-bstrict`

set -e
cd "$(dirname "$0")/.."

if [ "${XLANG_BUILD_TOOL_FULL:-}" = "1" ]; then
  # PLATFORM: SHARED — post-Makefile phys-del: FULL path = shell bstrict body (G.7).
  if [ "${XLANG_G05_FULL_VIA_MAKE:-0}" = "1" ] && [ -f Makefile ]; then
    echo "g05_build_xlang_asm: FULL=1 VIA_MAKE → make bootstrap-driver-bstrict (non-daily)"
    exec make bootstrap-driver-bstrict
  fi
  echo "g05_build_xlang_asm: FULL=1 → bootstrap_driver_bstrict.sh (non-daily; 0-make)"
  exec bash scripts/bootstrap_driver_bstrict.sh
fi

echo "g05_build_xlang_asm: default → g05_prepare_and_relink (G-05 100% product path, no make)"
G05_SYNC_ASM=1 sh scripts/g05_prepare_and_relink.sh
