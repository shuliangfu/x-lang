#!/usr/bin/env bash
# TOOL-006：项目模板编译运行烟测（期望 exit 42）。
#
# 用法：./tests/run-tool-scaffold.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/tool-scaffold.sh
. tests/lib/tool-scaffold.sh

SHUX="${SHUX:-./compiler/shux}"
EXPECT_EXIT="${SHUX_SCAFFOLD_EXPECT_EXIT:-42}"
WORKDIR="/tmp/shux_scaffold_test_$$"
EXE="$WORKDIR/app"

cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

make -C compiler -q 2>/dev/null || make -C compiler

tool_scaffold_copy_to "$WORKDIR"

if ! "$SHUX" -L . "$WORKDIR/main.x" -o "$EXE" 2>&1; then
  echo "run-tool-scaffold FAIL: compile template main.x" >&2
  exit 1
fi

ec=0
"$EXE" >/dev/null 2>&1 || ec=$?
if [ "$ec" -ne "$EXPECT_EXIT" ]; then
  echo "run-tool-scaffold FAIL: expected exit $EXPECT_EXIT, got $ec" >&2
  exit 1
fi

echo "tool-scaffold report template=project-hello exit=${ec} runnable=OK"
echo "scaffold test OK"
