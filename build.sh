#!/bin/sh
# build.sh — 以 build.su 为策略入口，用 build_tool 完成一次编译器构建（与 compiler/Makefile 中 build-tool + ./build_tool 一致）。
#
# 用法：在仓库根目录执行 ./build.sh
# 流程：进入 compiler；若无 build_tool，则用 shu-c（若已存在）或 shu/bootstrap_shu 对 ../build.su 做 -E 得到 build_gen.c，再用宿主 cc 与 build_runtime.c 链出 build_tool；最后执行 ./build_tool <shu>。
# 注意：不可用「shu ../build.su -o build_tool」直接链出可执行文件（生成 C 无用户 main，链接会失败）；必须与 Makefile 相同走 -E + cc。
# 前提：compiler 下已有可执行 shu 或 bootstrap_shu（首次：make -C compiler、或 cd compiler && sh bootstrap.sh）。
#
# 完全无 C/无 Makefile 自举见：analysis/完全自举-无C无Makefile.md；
# asm 后端编 shu（M7 默认 B-strict）：make -C compiler bootstrap-driver 或 ./build_tool ./shu asm。

set -e
cd "$(dirname "$0")/compiler"

# 传给 build_tool 的编译器路径（须能驱动完整构建；冷启动时 shu 与 shu-c 同源 C 对象，行为一致）
LINK_SHU="./shu"
if [ -f "./bootstrap_shu" ] && [ ! -x "./shu" ]; then
  LINK_SHU="./bootstrap_shu"
fi
if [ ! -x "$LINK_SHU" ]; then
  echo "build.sh: no compiler/shu or bootstrap_shu; run 'make -C compiler' or 'cd compiler && sh bootstrap.sh'."
  exit 1
fi

# 生成 build_gen.c 时优先 shu-c（与 Makefile build-tool / lsp_*_gen 一致：仅 C 前端 -E，避免依赖已链 driver 的 shu）
GEN_SHU="./shu-c"
if [ ! -x "$GEN_SHU" ]; then
  GEN_SHU="$LINK_SHU"
fi

CFLAGS_BT="-Wall -Wextra -I. -Iinclude -Isrc"

if [ ! -x "./build_tool" ]; then
  echo "build.sh: building build_tool from ../build.su ($GEN_SHU -E → build_gen.c + src/build_runtime.c) ..."
  "$GEN_SHU" ../build.su -E > build_gen.c
  cc $CFLAGS_BT -c build_gen.c -o build_tool.o
  cc $CFLAGS_BT -c src/build_runtime.c -o build_runtime.o
  cc $CFLAGS_BT -o build_tool build_tool.o build_runtime.o
fi

echo "build.sh: running ./build_tool $LINK_SHU ..."
./build_tool "$LINK_SHU"
