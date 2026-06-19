#!/usr/bin/env bash
# 验证多文件与跨模块调用：main.sx import foo，main 调用 bar() 解析为 foo.bar，退出码 42。
# seed asm：dep 前缀导出 + user_asm_seed_bridge 编入各 dep（L5）；仍可用 SHUX_LINK_SHUX 覆盖。
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi

"$RUN_SHUX" tests/multi-file/main.sx -o /tmp/shux_multi_file 2>&1
exitcode=0
/tmp/shux_multi_file >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 42 ]; then
    echo "expected exit code 42 (bar() from foo), got $exitcode"
    exit 1
fi
echo "multi-file test OK"
