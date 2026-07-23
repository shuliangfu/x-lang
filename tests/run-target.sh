#!/usr/bin/env bash
# 阶段 6：-target 被 driver 接受并传给 cc；本机目标可正常编译运行

set -e
cd "$(dirname "$0")/.."
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler
fi
XLANG=${XLANG:-./compiler/xlang}
# 使用本机目标三元组（clang 接受 -target）
case "$(uname -s)" in
    Darwin)  triple="$(uname -m)-apple-darwin" ;;
    Linux)   triple="$(uname -m)-linux-gnu" ;;
    *)       triple="" ;;
esac
if [ -n "$triple" ]; then
    $XLANG build -target "$triple" examples/hello.x -o /tmp/xlang_target_hello 2>&1
    /tmp/xlang_target_hello | grep -q "Hello World" || { echo "expected Hello World"; exit 1; }
fi
echo "target test OK"
