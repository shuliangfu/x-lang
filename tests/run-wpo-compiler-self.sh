#!/usr/bin/env bash
# WPO-S1 compiler self：从 main.su(entry) 导出全程序 call graph，验证 dead export ≥ min%（NEXT §4.1）
# 用法：./tests/run-wpo-compiler-self.sh
# 门禁：SHU_WPO_FAIL_ON_COMPILER_SELF=1 — dead% 须 ≥ baseline min_dead_pct
set -e
cd "$(dirname "$0")/.."
make -C compiler shu-c -q 2>/dev/null || make -C compiler shu-c

GRAPH="/tmp/shu_wpo_compiler_main.json"
LOG="/tmp/wpo_compiler_self.log"
BASELINE="${SHU_WPO_COMPILER_BASELINE:-tests/baseline/wpo-compiler-self.tsv}"
MIN_PCT=$(awk -F'\t' '$1=="min_dead_pct" && $1 !~ /^#/ { print $2; exit }' "$BASELINE")
MIN_PCT=${MIN_PCT:-5}

rm -f "$GRAPH"
SHU_WPO_DUMP_CALLGRAPH="$GRAPH" ./compiler/shu-c check compiler/src/main.su >/dev/null
[ -s "$GRAPH" ] || { echo "wpo compiler self: graph not written"; exit 1; }
grep -qE '"root": [0-9]+' "$GRAPH" || { echo "wpo compiler self: invalid root in graph"; exit 1; }

perl compiler/scripts/wpo_dce.pl "$GRAPH" --min-dead-pct "$MIN_PCT" | tee "$LOG"
grep -q 'wpo_dce OK' "$LOG"

echo "wpo compiler self OK (min_dead_pct=${MIN_PCT}%)"
