#!/bin/sh
# bootstrap.sh — Shux 冷启动引导脚本（G-06：优先 bootstrap_shuxc，无 C 前端编译）
#
# 从零构建：若已有 bootstrap_shuxc / shux_asm，直接复制为 shux/shux-c 并生成 build_tool。
# 否则回退最小 C 链（仅 runtime/main/async，无 lexer/parser/typeck C 前端）。
#
# 用法：cd compiler && sh bootstrap.sh

set -e

echo "=== Shux Cold Bootstrap (G-06) ==="

if [ -x ./scripts/select_bootstrap_shuxc.sh ]; then
  chmod +x ./scripts/select_bootstrap_shuxc.sh 2>/dev/null || true
  ./scripts/select_bootstrap_shuxc.sh
  SEED=./bootstrap_shuxc
elif [ -x ./bootstrap_shuxc ]; then
  SEED=./bootstrap_shuxc
elif [ -x ./shux_asm ]; then
  SEED=./shux_asm
  ./scripts/bootstrap_shuxc_create.sh "$SEED" 2>/dev/null || cp -f "$SEED" ./bootstrap_shuxc
elif [ -x ./shux ]; then
  SEED=./shux
else
  SEED=
fi

if [ -n "$SEED" ]; then
  echo "[1/2] G-06: copy seed -> shux / shux-c"
  cp -f "$SEED" ./shux
  cp -f "$SEED" ./shux-c
else
  echo "[1/4] LEGACY: compiling minimal C runtime (no C frontend)..."
  SRCS="seeds/main.from_x.c seeds/runtime.from_x.c seeds/async_liveness.from_x.c seeds/async_cps_codegen.from_x.c"
  OBJS=""
  for src in $SRCS; do
    obj="${src%.c}.o"
    OBJS="$OBJS $obj"
    echo "  cc -c $src"
    cc -Wall -Wextra -I. -Iinclude -Isrc -c -o "$obj" "$src"
  done
  echo "[2/4] linking shux..."
  cc -Wall -Wextra -I. -Iinclude -Isrc -o shux $OBJS
  cp -f shux shux-c
  ./scripts/bootstrap_shuxc_create.sh ./shux 2>/dev/null || cp -f shux bootstrap_shuxc
fi

echo "[build_tool] generating from build.x (build_runner + build_runtime_x)..."
./shux-c -E -E-extern -L .. ../build.x > build_gen.c
./shux-c -E -E-extern -L .. ../build_runner.x > build_runner_gen.c
./shux-c -E -E-extern -L .. ../build_runtime_x.x > build_runtime_x_gen.c
cc -Wall -Wextra -I. -Iinclude -Isrc -c build_gen.c -o build_tool.o
cc -Wall -Wextra -I. -Iinclude -Isrc -c src/build_tool_libc_bridge.c -o build_tool_libc_bridge.o
cc -Wall -Wextra -I. -Iinclude -Isrc -c build_runner_gen.c -o build_runner.o
cc -Wall -Wextra -I. -Iinclude -Isrc -c build_runtime_x_gen.c -o build_runtime_x.o
cc -Wall -Wextra -I. -Iinclude -Isrc -c src/build_tool_main.c -o build_tool_main.o
cc -Wall -Wextra -o build_tool build_tool_main.o build_runner.o build_tool.o build_runtime_x.o build_tool_libc_bridge.o -lc

echo ""
echo "=== Bootstrap Complete ==="
echo "  compiler/bootstrap_shuxc — G-06 cold-start seed"
echo "  compiler/shux / shux-c   — copied from seed"
echo "  compiler/build_tool      — build.x driver"
echo ""
echo "Daily: make -C compiler bootstrap-driver-bstrict"
echo "      cd compiler && ./build_tool ./shux"
