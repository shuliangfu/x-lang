#!/usr/bin/env bash
# label 与 goto：解析与 codegen，跳转后 return
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
XLANG=${XLANG:-./compiler/xlang}

$XLANG build tests/goto/main.x -o /tmp/xlang_goto 2>&1
exitcode=0; /tmp/xlang_goto >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 42 ] && { echo "expected 42 (goto main), got $exitcode"; exit 1; }

echo "goto test OK"
