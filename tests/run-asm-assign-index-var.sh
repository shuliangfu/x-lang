#!/usr/bin/env bash
# asm 7.3：INDEX 变量下标 assign 直 scratch 缩放寻址，main 内无 mov x2。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

run_one() {
  local src="$1"
  local out="$2"
  local want="$3"
  $SHUX "$src" -o "$out" 2>&1
  local exitcode=0
  "$out" >/dev/null 2>&1 || exitcode=$?
  [ "$exitcode" -ne "$want" ] && {
    echo "run-asm-assign-index-var FAIL: $src expected exit $want, got $exitcode"
    exit 1
  }
  if otool -tv "$out" 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
    echo "run-asm-assign-index-var FAIL: $src main still uses mov x2"
    exit 1
  fi
}

run_one tests/asm/assign_index_var_to_var.sx /tmp/shux_asm_assign_index_var_to_var 15
run_one tests/asm/assign_index_lit_to_var.sx /tmp/shux_asm_assign_index_lit_to_var 15

echo "asm assign index var OK"
