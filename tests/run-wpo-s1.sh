#!/usr/bin/env bash
# WPO-S1 烟测：call graph JSON 导出 + wpo_dce 死代码统计（NEXT §4.1 WPO-S1）
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
xlang_compiler_make -q 2>/dev/null || xlang_compiler_make

GRAPH="/tmp/xlang_wpo_dead_fn.json"
rm -f "$GRAPH"

XLANG_WPO_DUMP_CALLGRAPH="$GRAPH" ./compiler/xlang-c check tests/wpo/dead_fn.x >/dev/null
[ -s "$GRAPH" ] || { echo "WPO graph not written"; exit 1; }

perl compiler/scripts/wpo_dce.pl "$GRAPH" --expect-dead dead_helper | tee /tmp/wpo_dce.log
grep -q 'wpo_dce OK' /tmp/wpo_dce.log

echo "wpo-s1 smoke OK"
