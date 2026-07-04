#!/usr/bin/env bash
# 文件职责：验证顶层 let（与 import/const 同级）；main 前初始化，main 中可引用。
# 依赖：compiler/shux，tests/toplevel_let/main.x

set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi

# 单顶层 let（C 与 .x 流水线均支持；run-all 始终跑本脚本）
$RUN_SHUX tests/toplevel_let/main.x -o /tmp/shux_toplevel_let 2>&1
exitcode=0; /tmp/shux_toplevel_let >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 42 ] && { echo "expected exit 42 (main.x global_x), got $exitcode"; exit 1; }

# 两顶层 let，后者依赖前者
$RUN_SHUX tests/toplevel_let/two_lets.x -o /tmp/shux_toplevel_two 2>&1
exitcode=0; /tmp/shux_toplevel_two >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 12 ] && { echo "expected exit 12 (two_lets.x b=12), got $exitcode"; exit 1; }

echo "toplevel let test OK"
