#!/usr/bin/env bash
# 烟测 std.debug：stderr print + assert 重导出
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler shux-c
SHUX=${SHUX:-./compiler/shux-c}
$SHUX -L . tests/std-debug/main.sx -o /tmp/shux_std_debug 2>&1
ec=0
/tmp/shux_std_debug >/dev/null 2>/tmp/shux_std_debug_err.log || ec=$?
[ "$ec" -ne 0 ] && { echo "std-debug: run failed ec=$ec"; exit 1; }
grep -q 'debug line' /tmp/shux_std_debug_err.log || { echo "std-debug: missing stderr output"; exit 1; }
echo "std-debug test OK"
