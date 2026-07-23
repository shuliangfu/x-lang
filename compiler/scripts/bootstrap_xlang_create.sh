#!/bin/sh
# 创建 bootstrap_xlang：将当前 compiler 目录下的 xlang 复制为 bootstrap_xlang，供日后「无 make」构建使用。
#
# 用法：在 compiler 目录下执行 ./scripts/bootstrap_xlang_create.sh
# 前提：已有 xlang（例如刚执行过 make 或 ./build_tool ./xlang）。
# 之后：build.sh 在无 xlang 时会优先使用 bootstrap_xlang；实现「步骤 4」的种子编译器入库（本地等效）。
set -e
cd "$(dirname "$0")/.."
if [ ! -x "./xlang" ]; then
  echo "bootstrap_xlang_create: no ./xlang; run 'make' or './build_tool ./xlang' first."
  exit 1
fi
cp ./xlang ./bootstrap_xlang
chmod +x ./bootstrap_xlang
echo "bootstrap_xlang created (./bootstrap_xlang). Use: ./build.sh (from repo root) or make -C compiler; build_tool: make -C compiler build-tool."
