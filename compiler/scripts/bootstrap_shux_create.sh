#!/bin/sh
# 创建 bootstrap_shux：将当前 compiler 目录下的 shux 复制为 bootstrap_shux，供日后「无 make」构建使用。
#
# 用法：在 compiler 目录下执行 ./scripts/bootstrap_shux_create.sh
# 前提：已有 shux（例如刚执行过 make 或 ./build_tool ./shux）。
# 之后：build.sh 在无 shux 时会优先使用 bootstrap_shux；实现「步骤 4」的种子编译器入库（本地等效）。
set -e
cd "$(dirname "$0")/.."
if [ ! -x "./shux" ]; then
  echo "bootstrap_shux_create: no ./shux; run 'make' or './build_tool ./shux' first."
  exit 1
fi
cp ./shux ./bootstrap_shux
chmod +x ./bootstrap_shux
echo "bootstrap_shux created (./bootstrap_shux). Use: ./build.sh (from repo root) or make -C compiler; build_tool: make -C compiler build-tool."
