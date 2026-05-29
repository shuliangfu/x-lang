#!/usr/bin/env bash
# 文件职责：验证顶层 let（与 import/const 同级）；main 前初始化，main 中可引用。
# 依赖：compiler/shu，tests/toplevel_let/main.su

set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/bootstrap-link-shu.sh
. "$(dirname "$0")/lib/bootstrap-link-shu.sh"
if [ -z "${SHULANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi

# 单顶层 let（C 与 .su 流水线均支持；run-all 始终跑本脚本）
$RUN_SHU tests/toplevel_let/main.su -o /tmp/shu_toplevel_let 2>&1
exitcode=0; /tmp/shu_toplevel_let >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 42 ] && { echo "expected exit 42 (main.su global_x), got $exitcode"; exit 1; }

# 两顶层 let，后者依赖前者
$RUN_SHU tests/toplevel_let/two_lets.su -o /tmp/shu_toplevel_two 2>&1
exitcode=0; /tmp/shu_toplevel_two >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 12 ] && { echo "expected exit 12 (two_lets.su b=12), got $exitcode"; exit 1; }

echo "toplevel let test OK"
