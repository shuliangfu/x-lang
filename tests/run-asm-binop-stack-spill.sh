#!/usr/bin/env bash
# asm 7.3：十～十二 VAR return 链；允许实栈 push spill（sub sp,#16），与 block-var 无 push 门禁分离。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

run_one() {
  local src="$1"
  local out="$2"
  local want="$3"
  local tag="$4"
  $SHUX "$src" -o "$out" 2>&1
  local exitcode=0
  "$out" >/dev/null 2>&1 || exitcode=$?
  if [ "$exitcode" -ne "$want" ]; then
    echo "run-asm-binop-stack-spill FAIL: $tag expected exit $want, got $exitcode"
    exit 1
  fi
}

# 7.3：长 return 链以 exit 为准；|live|max≥15 才走栈帧 spill（十～十四元以 x10–x15 驱逐为主，与 block-var 无 push 门禁分离）。

run_one tests/asm/binop_return_ten_add.sx /tmp/shux_asm_binop_ret_ten 55 "return ten-var add"
run_one tests/asm/binop_return_eleven_add.sx /tmp/shux_asm_binop_ret_eleven 66 "return eleven-var add"
run_one tests/asm/binop_return_twelve_add.sx /tmp/shux_asm_binop_ret_twelve 78 "return twelve-var add"
run_one tests/asm/binop_return_thirteen_add.sx /tmp/shux_asm_binop_ret_thirteen 91 "return thirteen-var add"
run_one tests/asm/binop_return_fourteen_add.sx /tmp/shux_asm_binop_ret_fourteen 105 "return fourteen-var add"

echo "asm binop stack spill OK"
