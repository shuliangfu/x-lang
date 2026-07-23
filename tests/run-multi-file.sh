#!/usr/bin/env bash
# 验证多文件与跨模块调用：main.x import foo，main 调用 bar() 解析为 foo.bar，退出码 42。
# seed asm：dep 前缀导出 + user_asm_seed_bridge 编入各 dep（L5）；仍可用 XLANG_LINK_XLANG 覆盖。
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi

# seed/xlang_asm：非 TTY stdout 会挂起；须 tee|cat Drain（nohup >>log / W3 bstrict 同根因）。
if ! "$RUN_XLANG" build tests/multi-file/main.x -o /tmp/xlang_multi_file 2>&1 | tee /tmp/xlang_multi_file_build.log | cat >/dev/null; then
  echo "multi-file: compile failed (see /tmp/xlang_multi_file_build.log)" >&2
  exit 1
fi
exitcode=0
/tmp/xlang_multi_file >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 42 ]; then
    echo "expected exit code 42 (bar() from foo), got $exitcode"
    exit 1
fi
echo "multi-file test OK"
