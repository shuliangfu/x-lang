#!/usr/bin/env bash
# 烟测 core.assert（core.debug 兼容 alias 仍可用）
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler shux-c
SHUX=${SHUX:-./compiler/shux-c}
$SHUX -L . tests/core-assert/main.sx -o /tmp/shux_core_assert 2>&1
ec=0
/tmp/shux_core_assert >/dev/null 2>&1 || ec=$?
[ "$ec" -ne 0 ] && { echo "core-assert: expected exit 0, got $ec"; exit 1; }
$SHUX -L . tests/debug/main.sx -o /tmp/shux_core_debug_alias 2>&1
ec=0
/tmp/shux_core_debug_alias >/dev/null 2>&1 || ec=$?
[ "$ec" -ne 0 ] && { echo "core.debug alias: expected exit 0, got $ec"; exit 1; }
echo "core-assert test OK"
