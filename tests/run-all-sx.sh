#!/usr/bin/env bash
# 全量回归：仅用 .sx 流水线编译器（shux_sx）跑所有 run-*.sh，验证 .sx 前端/流水线行为。
# 在仓库根目录执行：./tests/run-all-sx.sh
# 依赖：make -C compiler shux-sx-pipeline 已产出 compiler/shux_sx；本脚本会先尝试构建再以 shux_sx 运行 run-all.sh。
# Makefile test_sx 在调用本脚本前已 bootstrap-driver-seed；默认 SHUX_SKIP_SUBSCRIPT_MAKE=1 避免重复链接 seed。

set -e
cd "$(dirname "$0")/.."
export SHUX_SKIP_SUBSCRIPT_MAKE="${SHUX_SKIP_SUBSCRIPT_MAKE:-1}"
# 先确保 shux、shux-c 及全部 std .o、runtime_panic.o 存在（make clean 后 run-all 里编译 -o 会链这些 .o）
make -C compiler -q all 2>/dev/null || make -C compiler all
# CI 全量：必须构建 shux_sx 并跑完整 run-all。
if [ -n "${SHUX_CI_NO_SKIP:-}" ] || [ -n "${CI:-}" ]; then
  make -C compiler bootstrap-pipeline
  make -C compiler shux-sx-pipeline
fi
if [ ! -x compiler/shux_sx ]; then
  make -C compiler bootstrap-pipeline 2>/dev/null || true
  make -C compiler shux-sx-pipeline 2>/dev/null || true
fi
# seed 由 Makefile test_sx / run-all.sh 负责；CI 内 skip 全量 bootstrap-driver（asm 编译 typeck.sx 极慢 → test_sx 25min 超时）
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler bootstrap-driver-seed 2>/dev/null || true
  if [ -z "${CI:-}" ]; then
    make -C compiler bootstrap-driver 2>/dev/null || true
  fi
fi
[ -x compiler/shux ] && cp compiler/shux compiler/shux_driver
if [ ! -x compiler/shux_sx ]; then
  if [ -n "${SHUX_CI_NO_SKIP:-}" ] || [ -n "${CI:-}" ]; then
    echo "run-all-sx FAIL: compiler/shux_sx not built (required in CI)" >&2
    exit 1
  fi
  echo "run-all-sx: skip (no shux_sx; local dev — run make -C compiler shux-sx-pipeline)"
  exit 0
fi
echo "run-all-sx: running full test suite with SHUX=compiler/shux_sx (.sx pipeline compiler)"
SHUX=compiler/shux_sx ./tests/run-all.sh
echo "run-all-sx: all tests OK (shux_sx)"
