#!/usr/bin/env bash
# MEM-B0：defer 静态内联烟测（LIFO / 嵌套 / 多 return）。
# 用法：./tests/run-defer-gate.sh
# 环境：SHUX_DEFER_GATE_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
SHUX="${SHUX:-./compiler/shux-c}"
FAIL="${SHUX_DEFER_GATE_FAIL:-0}"

run_case() {
  local src="$1"
  local expect="$2"
  local out="/tmp/shux_defer_gate_$$"
  if ! "$SHUX" "$src" -o "$out" 2>/tmp/shux_defer_gate_build.log; then
    echo "defer-gate FAIL: compile $src" >&2
    tail -5 /tmp/shux_defer_gate_build.log 2>/dev/null || true
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
  local got=0
  "$out" >/dev/null 2>&1 || got=$?
  if [ "$got" -ne "$expect" ]; then
    echo "defer-gate FAIL: $src expected exit=$expect got=$got" >&2
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
  echo "defer-gate OK $src exit=$expect"
}

run_case tests/defer/main.x 42
run_case tests/defer/order_lifo.x 21
run_case tests/defer/nested_if.x 111
run_case tests/defer/multi_return.x 30

echo "defer-gate OK (MEM-B0 defer smoke)"
