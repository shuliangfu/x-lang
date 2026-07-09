#!/bin/sh
# g05_relink_shux.sh — G-05：最终链接 shux 的唯一 shell 实现
#
# 由 Makefile `relink-shux` 在依赖齐备后调用（变量已展开）。
# 目的：把「最终 cc 链接 + 同步 shux-c/bootstrap_shuxc」从 Makefile recipe 迁出，
# 使产品链接步骤可在 shell 中审计/替换；依赖图仍由 Makefile 保证（G-05 ~98%）。
#
# 环境变量（Makefile 注入）：
#   G05_CC          编译器（默认 cc）
#   G05_CFLAGS      完整 cflags + link flags（含 -e _start 等）
#   G05_OUT         输出二进制名（默认 shux）
#   G05_OBJS        全部 .o 参数（空格分隔）
#   G05_SHUX_C      shux-c 同步名（默认 shux-c）
#   G05_BOOTSTRAP   bootstrap_shuxc 同步名（默认 bootstrap_shuxc）
#   G05_SYNC_ASM=1  同时 cp 到 shux_asm（可选；make shux_asm 亦可在外层做）
#
# 用法（compiler/ 目录）：
#   G05_CC=cc G05_CFLAGS='...' G05_OBJS='a.o b.o' sh scripts/g05_relink_shux.sh

set -e
cd "$(dirname "$0")/.."

CC="${G05_CC:-cc}"
CFLAGS="${G05_CFLAGS:-}"
OUT="${G05_OUT:-shux}"
OBJS="${G05_OBJS:-}"
SHUX_C="${G05_SHUX_C:-shux-c}"
BOOTSTRAP="${G05_BOOTSTRAP:-bootstrap_shuxc}"

if [ -z "$OBJS" ]; then
  echo "g05_relink_shux: G05_OBJS empty (call from make relink-shux)" >&2
  exit 1
fi

# shellcheck disable=SC2086
echo "g05_relink_shux: $CC ... -o $OUT  ($(echo $OBJS | wc -w | tr -d ' ') objs)"
# shellcheck disable=SC2086
$CC $CFLAGS -o "$OUT" $OBJS

cp -f "$OUT" "$SHUX_C"
cp -f "$OUT" "$BOOTSTRAP"
echo "g05_relink_shux OK ($OUT → $SHUX_C + $BOOTSTRAP)"

if [ "${G05_SYNC_ASM:-}" = "1" ]; then
  cp -f "$OUT" shux_asm
  echo "g05_relink_shux: synced shux_asm"
fi
