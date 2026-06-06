#!/usr/bin/env bash
# asm 7.3：嵌套 VAR 返回链免 x2 暂存（活跃性原型：VAR→rbx 不 clobber rax）。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHU=${SHU:-./compiler/shu}

run_case() {
  local src="$1"
  local out="$2"
  local want="$3"
  local max_ldur="$4"
  $SHU "$src" -o "$out" 2>&1
  local exitcode=0
  "$out" >/dev/null 2>&1 || exitcode=$?
  [ "$exitcode" -ne "$want" ] && {
    echo "run-asm-binop-nested-var FAIL: $src expected exit $want, got $exitcode"
    exit 1
  }
  if otool -tv "$out" 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
    echo "run-asm-binop-nested-var FAIL: $src main still uses x2 scratch"
    exit 1
  fi
  local main_ldur
  main_ldur=$(otool -tv "$out" 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -c 'ldur' || true)
  if [ "${main_ldur:-0}" -gt "$max_ldur" ]; then
    echo "run-asm-binop-nested-var FAIL: $src main ldur count $main_ldur > $max_ldur"
    exit 1
  fi
}

run_case tests/asm/binop_nested_var_return.su /tmp/shu_asm_binop_nested_var 20 8
run_case tests/asm/binop_nested_mul_return.su /tmp/shu_asm_binop_nested_mul 120 8

echo "asm binop nested var OK"
