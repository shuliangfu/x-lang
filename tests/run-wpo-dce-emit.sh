#!/usr/bin/env bash
# WPO v0 烟测：codegen DCE 剔除 dead export（单文件 + 跨 import 库）
set -e
cd "$(dirname "$0")/.."
make -C compiler shux-c -q 2>/dev/null || make -C compiler shux-c

# 单文件 intra-module
out=$(./compiler/shux-c -E tests/wpo/dead_fn.x 2>/dev/null)
echo "$out" | grep -q used_helper || { echo "missing used_helper"; exit 1; }
if echo "$out" | grep -q 'dead_helper()'; then
  echo "WPO DCE FAIL: dead_helper still emitted"
  exit 1
fi

# 跨 import 库 dead export
out2=$(./compiler/shux-c -E tests/wpo/dead_user.x 2>/dev/null)
echo "$out2" | grep -q live_export || { echo "missing live_export"; exit 1; }
if echo "$out2" | grep -q 'dead_export()'; then
  echo "WPO DCE FAIL: dead_export still emitted in import lib"
  exit 1
fi

# -o 链路
./compiler/shux-c -o /tmp/shux_wpo_dead_user tests/wpo/dead_user.x >/dev/null
rc=$(/tmp/shux_wpo_dead_user; echo $?)
[ "$rc" = "7" ] || { echo "dead_user exit=$rc want 7"; exit 1; }

# if 分支 AST_EXPR_BLOCK 内 call 须计入 WPO 可达性（否则 core.option some/none 被 DCE 误删）
GRAPH="/tmp/shux_wpo_if_block_reach.json"
rm -f "$GRAPH"
SHUX_WPO_DUMP_CALLGRAPH="$GRAPH" ./compiler/shux-c check -L . tests/wpo/if_block_reach.x >/dev/null
[ -s "$GRAPH" ] || { echo "WPO if-block reach FAIL: graph not written"; exit 1; }
grep -qE '"name": "some_i32"[^}]*"reachable": true' "$GRAPH" || {
  echo "WPO if-block reach FAIL: some_i32 not reachable in call graph" >&2
  exit 1
}
grep -qE '"name": "none_i32"[^}]*"reachable": true' "$GRAPH" || {
  echo "WPO if-block reach FAIL: none_i32 not reachable in call graph" >&2
  exit 1
}
grep -qE '"name": "get_i32"[^}]*"reachable": true' "$GRAPH" || {
  echo "WPO if-block reach FAIL: get_i32 not reachable in call graph" >&2
  exit 1
}
out3=$(./compiler/shux-c -L . tests/wpo/if_block_reach.x -E 2>/dev/null)
echo "$out3" | grep -q 'core_option_some_i32(int32_t x) {' || {
  echo "WPO if-block reach FAIL: core_option_some_i32 body not emitted (DCE regression)" >&2
  exit 1
}
make -C compiler -q ../std/process/process.o 2>/dev/null || make -C compiler ../std/process/process.o
./compiler/shux-c -L . tests/wpo/if_block_reach.x -o /tmp/shux_wpo_if_block_reach >/dev/null
rc=0; /tmp/shux_wpo_if_block_reach >/dev/null 2>&1 || rc=$?
[ "$rc" = "0" ] || { echo "WPO if-block reach FAIL: run exit=$rc want 0"; exit 1; }

echo "wpo dce emit OK"
