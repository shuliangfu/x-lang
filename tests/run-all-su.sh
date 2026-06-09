#!/usr/bin/env bash
# 全量回归：仅用 .su 流水线编译器（shu_su）跑所有 run-*.sh，验证 .su 前端/流水线行为。
# 在仓库根目录执行：./tests/run-all-su.sh
# 依赖：make -C compiler shu-su-pipeline 已产出 compiler/shu_su；本脚本会先尝试构建再以 shu_su 运行 run-all.sh。
# Makefile test_su 在调用本脚本前已 bootstrap-driver-seed；默认 SHULANG_SKIP_SUBSCRIPT_MAKE=1 避免重复链接 seed。

set -e
cd "$(dirname "$0")/.."
export SHULANG_SKIP_SUBSCRIPT_MAKE="${SHULANG_SKIP_SUBSCRIPT_MAKE:-1}"
# 先确保 shu、shu-c 及全部 std .o、runtime_panic.o 存在（make clean 后 run-all 里编译 -o 会链这些 .o）
make -C compiler -q all 2>/dev/null || make -C compiler all
# CI 全量：必须构建 shu_su 并跑完整 run-all。
if [ -n "${SHU_CI_NO_SKIP:-}" ] || [ -n "${CI:-}" ]; then
  make -C compiler bootstrap-pipeline
  make -C compiler shu-su-pipeline
fi
if [ ! -x compiler/shu_su ]; then
  make -C compiler bootstrap-pipeline 2>/dev/null || true
  make -C compiler shu-su-pipeline 2>/dev/null || true
fi
# seed 由 Makefile test_su / run-all.sh 负责；CI 内 skip 全量 bootstrap-driver（asm 编译 typeck.su 极慢 → test_su 25min 超时）
if [ -z "${SHULANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler bootstrap-driver-seed 2>/dev/null || true
  if [ -z "${CI:-}" ]; then
    make -C compiler bootstrap-driver 2>/dev/null || true
  fi
fi
[ -x compiler/shu ] && cp compiler/shu compiler/shu_driver
if [ ! -x compiler/shu_su ]; then
  if [ -n "${SHU_CI_NO_SKIP:-}" ] || [ -n "${CI:-}" ]; then
    echo "run-all-su FAIL: compiler/shu_su not built (required in CI)" >&2
    exit 1
  fi
  echo "run-all-su: skip (no shu_su; local dev — run make -C compiler shu-su-pipeline)"
  exit 0
fi
echo "run-all-su: running full test suite with SHU=compiler/shu_su (.su pipeline compiler)"
SHU=compiler/shu_su ./tests/run-all.sh
echo "run-all-su: all tests OK (shu_su)"
