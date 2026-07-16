#!/usr/bin/env bash
# MEM-B0：defer 静态内联烟测（LIFO / 嵌套 / 多 return）。
# 用法：./tests/run-defer-gate.sh
# 产品路径：必须 SHUX=shux_asm（或可 -o 的产品编译器）；失败硬退出（禁止假绿）。
set -e
cd "$(dirname "$0")/.."

SHUX="${SHUX:-./compiler/shux_asm}"
if [ ! -x "$SHUX" ]; then
  SHUX="./compiler/shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "defer-gate FAIL: no product SHUX (shux_asm/shux)" >&2
  exit 1
fi

run_case() {
  local src="$1"
  local expect="$2"
  local out="/tmp/shux_defer_gate_$$"
  if ! "$SHUX" -backend c "$src" -o "$out" 2>/tmp/shux_defer_gate_build.log; then
    echo "defer-gate FAIL: compile $src" >&2
    tail -20 /tmp/shux_defer_gate_build.log 2>/dev/null || true
    exit 1
  fi
  local got=0
  "$out" >/dev/null 2>&1 || got=$?
  rm -f "$out" 2>/dev/null || true
  if [ "$got" -ne "$expect" ]; then
    echo "defer-gate FAIL: $src expected exit=$expect got=$got" >&2
    exit 1
  fi
  echo "defer-gate OK $src exit=$expect"
}

run_case tests/defer/main.x 42
run_case tests/defer/order_lifo.x 21
run_case tests/defer/nested_if.x 111
run_case tests/defer/multi_return.x 30

echo "defer-gate OK (MEM-B0 defer smoke)"
