#!/usr/bin/env bash
# 全量回归：仅用 C 版编译器（xlang-c）跑所有 run-*.sh，验证 C 构建的 xlang 行为。
# 在仓库根目录执行：./tests/run-all-c.sh
# 依赖：make -C compiler all 产出 xlang + xlang-c；勿触发 bootstrap-driver-seed（CI test_c 须在合理时间内完成）。

set -e
cd "$(dirname "$0")/.."
make -C compiler -q all 2>/dev/null || make -C compiler all
make -C compiler xlang-c 2>/dev/null || true
make -C compiler build-tool 2>/dev/null || true
if [ ! -x compiler/xlang-c ]; then
    echo "run-all-c: compiler/xlang-c not found (C-only xlang); run 'make -C compiler all'" >&2
    exit 1
fi
echo "run-all-c: running full test suite via run-all.sh (RUN_ALL_USE_C, xlang-c; no bootstrap-driver-seed)"
# 不设 SHU：run-all.sh 走 RUN_ALL_USE_C 路径（make all + xlang-c），不 bootstrap-driver-seed
./tests/run-all.sh
echo "run-all-c: all tests OK (C compiler)"
