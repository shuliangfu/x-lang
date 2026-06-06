#!/usr/bin/env bash
# P3 asm：struct CALL 内联（try_inline_*）；exit 验语义 + 部分用例要求 _main 无 bl 外呼。
set -e
cd "$(dirname "$0")/.."
# shellcheck source=lib/ensure-compiler-seed.sh
source "$(dirname "$0")/lib/ensure-compiler-seed.sh"
SHU=${SHU:-./compiler/shu_asm}

run_one() {
  local src="$1"
  local out="$2"
  local want="$3"
  local tag="$4"
  $SHU "$src" -o "$out" 2>&1
  local exitcode=0
  "$out" >/dev/null 2>&1 || exitcode=$?
  if [ "$exitcode" -ne "$want" ]; then
    echo "run-asm-call-inline FAIL: $tag expected exit $want, got $exitcode"
    exit 1
  fi
}

# _main 反汇编不得含对用户函数的 bl（CALL 内联）；允许 bl _shulang_panic_（向量除法逐 lane 除零检查）。
check_no_bl_in_main() {
  local out="$1"
  local tag="$2"
  local main_asm
  local bad_bl
  main_asm=$(otool -tv "$out" 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p')
  bad_bl=$(echo "$main_asm" | grep -E '[[:space:]]bl[[:space:]]' | grep -v '_shulang_panic_' || true)
  if [ -n "$bad_bl" ]; then
    echo "run-asm-call-inline FAIL: $tag _main still has bl (expected full inline)"
    echo "$bad_bl"
    exit 1
  fi
}

run_one tests/boundary/struct_add_pair_inline.su /tmp/shu_asm_struct_add_pair 12 "add_pair loop"
check_no_bl_in_main /tmp/shu_asm_struct_add_pair "add_pair loop"
run_one tests/boundary/struct_get_field_inline.su /tmp/shu_asm_struct_get_field 10 "get_a loop"
check_no_bl_in_main /tmp/shu_asm_struct_get_field "get_a loop"
run_one tests/boundary/struct_mk_field_inline.su /tmp/shu_asm_struct_mk_field 10 "mk+get_a nested"
check_no_bl_in_main /tmp/shu_asm_struct_mk_field "mk+get_a nested"
run_one tests/boundary/struct_mk_pair_sum_inline.su /tmp/shu_asm_struct_mk_pair_sum 20 "mk+add_pair nested"
check_no_bl_in_main /tmp/shu_asm_struct_mk_pair_sum "mk+add_pair nested"
run_one tests/boundary/struct_mk_let_inline.su /tmp/shu_asm_struct_mk_let 10 "mk let slot"
check_no_bl_in_main /tmp/shu_asm_struct_mk_let "mk let slot"
run_one tests/boundary/struct_mk_while_let_inline.su /tmp/shu_asm_struct_mk_while_let 9 "mk while let"
check_no_bl_in_main /tmp/shu_asm_struct_mk_while_let "mk while let"
run_one tests/boundary/inc_while_inline.su /tmp/shu_asm_inc_while 15 "inc while outer i"
check_no_bl_in_main /tmp/shu_asm_inc_while "inc while outer i"
run_one tests/boundary/vec_add4_call_inline.su /tmp/shu_asm_vec_add4 0 "vec_add4 call inline"
check_no_bl_in_main /tmp/shu_asm_vec_add4 "vec_add4 call inline"
run_one tests/boundary/vec_sub4_call_inline.su /tmp/shu_asm_vec_sub4 0 "vec_sub4 call inline"
check_no_bl_in_main /tmp/shu_asm_vec_sub4 "vec_sub4 call inline"
run_one tests/boundary/vec_mul4_call_inline.su /tmp/shu_asm_vec_mul4 0 "vec_mul4 call inline"
check_no_bl_in_main /tmp/shu_asm_vec_mul4 "vec_mul4 call inline"
run_one tests/boundary/vec_div4_call_inline.su /tmp/shu_asm_vec_div4 0 "vec_div4 call inline"
check_no_bl_in_main /tmp/shu_asm_vec_div4 "vec_div4 call inline"

echo "asm call inline OK (11 cases: 6 struct + inc while + vec add/sub/mul/div)"
