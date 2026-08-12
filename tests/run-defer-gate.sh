#!/usr/bin/env bash
# MEM-B0：defer 静态内联烟测（LIFO / 嵌套 / 多 return）。
# 用法：./tests/run-defer-gate.sh
# 产品路径：优先 pure-asm `$XLANG -o`（默认禁 host-cc）；
# optional host-cc only when XLANG_ALLOW_HOST_CC is set (matches void-main / struct gates).
# PLATFORM: SHARED — dual-end pure-asm product gate.
set -e
cd "$(dirname "$0")/.."

XLANG="${XLANG:-./compiler/xlang_asm}"
if [ ! -x "$XLANG" ]; then
  XLANG="./compiler/xlang"
fi
if [ ! -x "$XLANG" ]; then
  echo "defer-gate FAIL: no product XLANG (xlang_asm/xlang)" >&2
  exit 1
fi

run_case() {
  local src="$1"
  local expect="$2"
  local out="/tmp/xlang_defer_gate_$$"
  local log="/tmp/xlang_defer_gate_build.log"
  rm -f "$out"
  # Prefer pure-asm product -o (host-cc banned without XLANG_ALLOW_HOST_CC).
  if "$XLANG" build -L . "$src" -o "$out" 2>"$log"; then
    :
  elif [ -n "${XLANG_ALLOW_HOST_CC:-}" ] \
    && "$XLANG" build -backend c -L . "$src" -o "$out" 2>"$log"; then
    :
  else
    echo "defer-gate FAIL: compile $src" >&2
    tail -20 "$log" 2>/dev/null || true
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
