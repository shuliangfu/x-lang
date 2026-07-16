#!/usr/bin/env bash
# 验证跨模块调用：main 调用 import 的 foo.id_i32(42)，退出码 42。
# 产品路径：SHUX 默认 shux_asm（Darwin -backend c）；跨模块 id<T> 单态化未全闭合时用显式 id_i32。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
# shellcheck source=tests/lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"

$RUN_SHUX -L tests/multi-file-generic tests/multi-file-generic/main.x -o /tmp/shux_multi_file_gen 2>&1
exitcode=0
/tmp/shux_multi_file_gen >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 42 ]; then
    echo "expected exit code 42 (foo.id_i32(42)), got $exitcode"
    exit 1
fi
echo "multi-file generic test OK"
