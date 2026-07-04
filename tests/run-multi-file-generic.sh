#!/usr/bin/env bash
# 验证跨模块泛型调用：main 调用 import 的 id<i32>(42)，退出码 42。
# 使用 shux-c（C 流水线）因 seed shux 的 .x pipeline 暂不支持泛型+import 单态化。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler

./compiler/shux-c tests/multi-file-generic/main.x -o /tmp/shux_multi_file_gen 2>&1
exitcode=0
/tmp/shux_multi_file_gen >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 42 ]; then
    echo "expected exit code 42 (id<i32>(42) from foo), got $exitcode"
    exit 1
fi
echo "multi-file generic test OK"
