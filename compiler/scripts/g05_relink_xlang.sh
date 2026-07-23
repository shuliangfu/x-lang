#!/bin/sh
# g05_relink_xlang.sh — G-05：最终链接 xlang 的唯一 shell 实现
#
# 由 g05_prepare_and_relink.sh 在依赖齐备后调用（G05_* 来自 g05_relink_env.sh）。
# 目的：最终 cc 链接 + 同步 xlang-c/bootstrap_xlangc 仅在本脚本（G-05 100% 产品路径）。
#
# 环境变量（g05_relink_env.sh 注入）：
#   G05_CC          编译器（默认 cc）
#   G05_CFLAGS      完整 cflags + link flags（含 -e _start 等）
#   G05_OUT         输出二进制名（默认 xlang）
#   G05_OBJS        全部 .o 参数（空格分隔）
#   G05_XLANG_C      xlang-c 同步名（默认 xlang-c）
#   G05_BOOTSTRAP   bootstrap_xlangc 同步名（默认 bootstrap_xlangc）
#   G05_SYNC_ASM=1  同时 cp 到 xlang_asm（可选；prepare 亦可在外层做）
#
# 用法（compiler/ 目录）：
#   eval "$(sh scripts/g05_relink_env.sh)" && sh scripts/g05_relink_xlang.sh

set -e
cd "$(dirname "$0")/.."

CC="${G05_CC:-cc}"
CFLAGS="${G05_CFLAGS:-}"
OUT="${G05_OUT:-xlang}"
OBJS="${G05_OBJS:-}"
XLANG_C="${G05_XLANG_C:-xlang-c}"
BOOTSTRAP="${G05_BOOTSTRAP:-bootstrap_xlangc}"

if [ -z "$OBJS" ]; then
  echo "g05_relink_xlang: G05_OBJS empty (eval g05_relink_env.sh first)" >&2
  exit 1
fi

# shellcheck disable=SC2086
echo "g05_relink_xlang: $CC ... -o $OUT  ($(echo $OBJS | wc -w | tr -d ' ') objs)"
# shellcheck disable=SC2086
$CC $CFLAGS -o "$OUT" $OBJS

cp -f "$OUT" "$XLANG_C"
cp -f "$OUT" "$BOOTSTRAP"
echo "g05_relink_xlang OK ($OUT → $XLANG_C + $BOOTSTRAP)"

if [ "${G05_SYNC_ASM:-}" = "1" ]; then
  cp -f "$OUT" xlang_asm
  echo "g05_relink_xlang: synced xlang_asm"
fi
