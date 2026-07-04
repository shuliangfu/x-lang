#!/usr/bin/env bash
# TOOL-005：-O 0 调试构建 symtab + not-stripped 烟测。
#
# 用法：./tests/run-debug-symbols.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/tool-debug-symbols.sh
. tests/lib/tool-debug-symbols.sh

SHUX="${SHUX:-./compiler/shux}"
SRC=tests/debug/symbols_marker.x
EXE="/tmp/shux_debug_symbols_$$"

make -C compiler -q 2>/dev/null || make -C compiler

if ! "$SHUX" -O 0 -L . "$SRC" -o "$EXE" 2>&1; then
  echo "run-debug-symbols FAIL: compile $SRC" >&2
  rm -f "$EXE"
  exit 1
fi

tool_dbg_exe_has_sym "$EXE" main
tool_dbg_exe_not_stripped "$EXE"

ec=0
"$EXE" >/dev/null 2>&1 || ec=$?
rm -f "$EXE"
if [ "$ec" -ne 42 ]; then
  echo "run-debug-symbols FAIL: expected exit 42, got $ec" >&2
  exit 1
fi

echo "tool-debug-symbols report sym=main stripped=no o0=OK capture=hook"
echo "debug-symbols OK"
