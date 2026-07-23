#!/usr/bin/env bash
# MEM-A3：scope borrow — return/assign 地址逃逸 typeck 负例。
set -e
cd "$(dirname "$0")/.."
XLANG="${XLANG:-./compiler/xlang-c}"
if [ ! -x "$XLANG" ]; then
  make -C compiler -q xlang-c 2>/dev/null || make -C compiler xlang-c
  XLANG=./compiler/xlang-c
fi

check_neg() {
  local src="$1"
  local msg="$2"
  local out
  out="$("$XLANG" check "$src" 2>&1)" || true
  if ! echo "$out" | grep -qF "$msg"; then
    echo "scope-borrow-gate FAIL: $src expected '$msg'" >&2
    echo "$out" >&2
    exit 1
  fi
  echo "scope-borrow-gate OK $src -> $msg"
}

check_neg tests/typeck/borrow/return_addr_escape.x "scope borrow escape"
check_neg tests/typeck/borrow/assign_scope_escape.x "scope borrow escape"
echo "scope-borrow-gate OK (MEM-A3 scope borrow v1)"
