#!/bin/sh
# g05_ensure_relink_prereqs.sh — G-05 100%：依赖齐备（纯 shell，不调用 make）
#
# 职责：
#   1) 加载 g05_relink_env.sh 清单
#   2) 热路径 C 源用 cc 强制重编（对齐历史 ensure 的 -B runtime / glue）
#   3) 检查 G05_OBJS 全部存在；缺失则失败并提示冷启动（Makefile 仅冷启动）
#
# 用法（compiler/ 目录）：
#   sh scripts/g05_ensure_relink_prereqs.sh
#
# 环境：
#   G05_SKIP_HOT_REBUILD=1  跳过热路径 cc 重编（仅检查）
#   G05_CC                  覆盖编译器（默认 cc）

set -e
cd "$(dirname "$0")/.."

echo "g05_ensure_relink_prereqs: load env (shell, no make)"
# shellcheck disable=SC2046
eval "$(sh scripts/g05_relink_env.sh)"

CC="${G05_CC:-cc}"
BASE_CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc"
# 与 Makefile RUNTIME_DRIVER_NO_C_CFLAGS 一致（runtime.c → runtime_driver_no_c.o）
RUNTIME_DRIVER_NO_C_CFLAGS="-DSHUX_USE_X_DRIVER -DSHUX_USE_X_PIPELINE -DSHUX_USE_X_PREPROCESS -DSHUX_USE_X_TYPECK -DSHUX_USE_X_CODEGEN -DSHUX_NO_C_FRONTEND -DSHUX_ASM_USE_COMPILER_IMPL_C"

if [ ! -f "${G05_BOOTSTRAP:-bootstrap_shuxc}" ] && [ ! -f shux ] && [ ! -f shux-c ]; then
  echo "g05_ensure_relink_prereqs: missing bootstrap binary (bootstrap_shuxc/shux/shux-c)" >&2
  echo "  cold-start: make -C compiler bootstrap-driver-seed   # Makefile 冷启动实现层" >&2
  exit 1
fi

# --- 热路径：直接 cc -c（不经 make）---
g05_cc_c() {
  # $1 = .o  $2 = .c  [$3...] = extra cflags
  _o="$1"
  _c="$2"
  shift 2
  if [ ! -f "$_c" ]; then
    echo "g05_ensure_relink_prereqs: missing source $_c" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$_o")"
  echo "g05_ensure: cc -c $_c → $_o"
  # shellcheck disable=SC2086
  $CC $BASE_CFLAGS "$@" -c -o "$_o" "$_c"
}

if [ "${G05_SKIP_HOT_REBUILD:-}" != "1" ]; then
  echo "g05_ensure_relink_prereqs: hot rebuild (cc, no make)"
  g05_cc_c src/runtime_link_abi.o src/runtime_link_abi.c
  # 注意：.o 名是 runtime_driver_no_c.o，源文件是 runtime.c + NO_C flags
  g05_cc_c src/runtime_driver_no_c.o src/runtime.c $RUNTIME_DRIVER_NO_C_CFLAGS
  g05_cc_c build_asm/pipeline_glue_strict_minimal.o src/asm/pipeline_glue_strict_minimal.c
  # LANG-007：host-local typeck_gen.c 可能缺 S0 边界委托；补丁后若变更则重编 typeck_x.o
  if [ -f typeck_gen.c ] && [ -f scripts/patch_typeck_gen_lang007.py ]; then
    _tg_before=$(wc -c < typeck_gen.c | tr -d ' ')
    python3 scripts/patch_typeck_gen_lang007.py || true
    _tg_after=$(wc -c < typeck_gen.c | tr -d ' ')
    if [ "$_tg_before" != "$_tg_after" ] || [ ! -f typeck_x.o ] || [ typeck_gen.c -nt typeck_x.o ]; then
      echo "g05_ensure: cc -c typeck_gen.c → typeck_x.o (LANG-007 patch)"
      # shellcheck disable=SC2086
      $CC $BASE_CFLAGS $RUNTIME_DRIVER_NO_C_CFLAGS -c -o typeck_x.o typeck_gen.c
    fi
  fi
fi

# --- 齐备检查 ---
mkdir -p build_asm/seed_host
miss=0
# shellcheck disable=SC2086
for o in $G05_OBJS; do
  if [ ! -f "$o" ]; then
    echo "g05_ensure_relink_prereqs: MISSING $o" >&2
    miss=$((miss + 1))
  fi
done

if [ "$miss" -ne 0 ]; then
  echo "g05_ensure_relink_prereqs: $miss object(s) missing" >&2
  echo "  G-05 产品路径不调用 make 编 .o；请先冷启动补齐依赖图：" >&2
  echo "    make -C compiler bootstrap-driver-seed" >&2
  echo "    # 或已有完整 build_asm/ 时：" >&2
  echo "    make -C compiler build-seed-asm-host pipeline_x.o driver_x.o" >&2
  exit 1
fi

n=$(echo "$G05_OBJS" | wc -w | tr -d ' ')
echo "g05_ensure_relink_prereqs OK ($n objs present, host=${G05_UNAME_S:-?}/${G05_UNAME_M:-?})"
