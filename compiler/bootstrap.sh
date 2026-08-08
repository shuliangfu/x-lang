#!/bin/sh
# bootstrap.sh — Xlang 冷启动引导脚本（G-06：优先 bootstrap_xlangc，无 C 前端编译）
#
# 从零构建：若已有 bootstrap_xlangc / xlang_asm，直接复制为 xlang/xlang-c 并生成 build_tool。
# 否则回退最小 C 链（仅 runtime/main/async，无 lexer/parser/typeck C 前端）。
#
# 用法：cd compiler && sh bootstrap.sh

set -e

echo "=== Xlang Cold Bootstrap (G-06) ==="

if [ -x ./scripts/select_bootstrap_xlangc.sh ]; then
  chmod +x ./scripts/select_bootstrap_xlangc.sh 2>/dev/null || true
  ./scripts/select_bootstrap_xlangc.sh
  SEED=./bootstrap_xlangc
elif [ -x ./bootstrap_xlangc ]; then
  SEED=./bootstrap_xlangc
elif [ -x ./xlang_asm ]; then
  SEED=./xlang_asm
  ./scripts/bootstrap_xlangc_create.sh "$SEED" 2>/dev/null || cp -f "$SEED" ./bootstrap_xlangc
elif [ -x ./xlang ]; then
  SEED=./xlang
else
  SEED=
fi

if [ -n "$SEED" ]; then
  echo "[1/2] G-06: copy seed -> xlang / xlang-c"
  cp -f "$SEED" ./xlang
  cp -f "$SEED" ./xlang-c
else
  # wave321 7.1.1: monofile seeds/runtime.from_x.c retired. LEGACY host-cc of
  # monofile is gone; cold egg path must supply SEED (pin bootstrap_xlangc).
  # PLATFORM: SHARED — product cold start uses pin egg, not monofile compile.
  echo "bootstrap.sh: LEGACY monofile compile path retired (wave321 7.1.1)." >&2
  echo "  Provide a seed binary (seeds/bootstrap_xlangc.*) or pin egg; do not host-cc monofile." >&2
  exit 1
fi

echo "[build_tool] generating from build.x (build_runner + build_runtime_x)..."
./xlang-c -E -E-extern -L .. ../build.x > build_gen.c
./xlang-c -E -E-extern -L .. ../build_runner.x > build_runner_gen.c
./xlang-c -E -E-extern -L .. ../build_runtime_x.x > build_runtime_x_gen.c
cc -Wall -Wextra -I. -Iinclude -Isrc -c build_gen.c -o build_tool.o
cc -Wall -Wextra -I. -Iinclude -Isrc -c src/build_tool_libc_bridge.c -o build_tool_libc_bridge.o
cc -Wall -Wextra -I. -Iinclude -Isrc -c build_runner_gen.c -o build_runner.o
cc -Wall -Wextra -I. -Iinclude -Isrc -c build_runtime_x_gen.c -o build_runtime_x.o
cc -Wall -Wextra -I. -Iinclude -Isrc -c src/build_tool_main.c -o build_tool_main.o
cc -Wall -Wextra -o build_tool build_tool_main.o build_runner.o build_tool.o build_runtime_x.o build_tool_libc_bridge.o -lc

echo ""
echo "=== Bootstrap Complete ==="
echo "  compiler/bootstrap_xlangc — G-06 cold-start seed"
echo "  compiler/xlang / xlang-c   — copied from seed"
echo "  compiler/build_tool      — build.x driver"
echo ""
echo "Daily: ./xbuild full"
echo "      cd compiler && ./build_tool ./xlang"
