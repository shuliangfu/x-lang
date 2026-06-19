#!/usr/bin/env bash
# WPO-S1 烟测：call graph JSON 导出 + wpo_dce 死代码统计（NEXT §4.1 WPO-S1）
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler

GRAPH="/tmp/shux_wpo_dead_fn.json"
rm -f "$GRAPH"

SHUX_WPO_DUMP_CALLGRAPH="$GRAPH" ./compiler/shux-c check tests/wpo/dead_fn.sx >/dev/null
[ -s "$GRAPH" ] || { echo "WPO graph not written"; exit 1; }

perl compiler/scripts/wpo_dce.pl "$GRAPH" --expect-dead dead_helper | tee /tmp/wpo_dce.log
grep -q 'wpo_dce OK' /tmp/wpo_dce.log

echo "wpo-s1 smoke OK"
