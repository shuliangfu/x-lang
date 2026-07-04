#!/usr/bin/env bash
# asm 7.3：块内连续 INDEX assign（字面量/VAR/嵌套下标）+ return 求和，main 内无 mov x2。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

run_one() {
  local src="$1"
  local out="$2"
  local want="$3"
  local tag="$4"
  $SHUX "$src" -o "$out"
  local exitcode=0
  "$out" >/dev/null 2>&1 || exitcode=$?
  [ "$exitcode" -ne "$want" ] && { echo "run-asm-assign-index-block FAIL: $tag expected exit $want, got $exitcode"; exit 1; }
  if otool -tv "$out" 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p' | grep -q 'mov x2'; then
    echo "run-asm-assign-index-block FAIL: $tag still uses mov x2"
    exit 1
  fi
}

# Verify second store to the same INDEX skips redundant local reloads (addr cache hit).
run_one_reuse() {
  local src="$1"
  local out="$2"
  local want="$3"
  local tag="$4"
  local max_ldur="$5"
  $SHUX "$src" -o "$out"
  local exitcode=0
  "$out" >/dev/null 2>&1 || exitcode=$?
  [ "$exitcode" -ne "$want" ] && { echo "run-asm-assign-index-block FAIL: $tag expected exit $want, got $exitcode"; exit 1; }
  local main_asm
  main_asm=$(otool -tv "$out" 2>/dev/null | sed -n '/^_main:/,/^_[a-z]/p')
  if echo "$main_asm" | grep -q 'mov x2'; then
    echo "run-asm-assign-index-block FAIL: $tag still uses mov x2"
    exit 1
  fi
  local ldur_count
  ldur_count=$(echo "$main_asm" | grep -cE 'ldur[[:space:]]+w' || true)
  if [ "$ldur_count" -gt "$max_ldur" ]; then
    echo "run-asm-assign-index-block FAIL: $tag ldur w count $ldur_count > $max_ldur (addr cache miss?)"
    exit 1
  fi
}

run_one tests/asm/assign_index_block_sum.x /tmp/shux_asm_assign_index_block_sum 6 "lit index block"
run_one tests/asm/assign_index_block_var.x /tmp/shux_asm_assign_index_block_var 6 "var index block"
run_one tests/asm/assign_index_block_nested.x /tmp/shux_asm_assign_index_block_nested 62 "nested index block"
run_one tests/asm/assign_index_block_sub_mul.x /tmp/shux_asm_assign_index_block_sub_mul 33 "sub+mul index block"
run_one_reuse tests/asm/assign_index_block_sub_mul.x /tmp/shux_asm_assign_index_block_sub_mul_reuse 33 "sub+mul minus pair reuse" 6
run_one tests/asm/assign_index_block_seq.x /tmp/shux_asm_assign_index_block_seq 45 "index assign seq"
run_one_reuse tests/asm/assign_index_block_reuse_same_index.x /tmp/shux_asm_assign_index_block_reuse 22 "same index addr reuse" 8
run_one_reuse tests/asm/assign_index_block_subadd3_mul_lit.x /tmp/shux_asm_assign_index_block_subadd3_mul_lit 33 "subadd3 mul lit prefix reuse" 5
run_one_reuse tests/asm/assign_index_block_minus_mul_lit.x /tmp/shux_asm_assign_index_block_minus_mul_lit 33 "subadd3 then minus mul lit reuse" 6
run_one_reuse tests/asm/assign_index_block_minus_mul_lit_seq.x /tmp/shux_asm_assign_index_block_minus_mul_lit_seq 33 "minus mul lit seq reuse" 4
run_one tests/asm/assign_index_block_rhs_index.x /tmp/shux_asm_assign_index_block_rhs_index 20 "rhs index clears cache"
run_one_reuse tests/asm/assign_index_block_read_between.x /tmp/shux_asm_assign_index_block_read_between 33 "read between assigns" 10
run_one_reuse tests/asm/assign_index_block_let_read_addr_cache.x /tmp/shux_asm_assign_index_block_let_read_addr_cache 99 "let read assign addr cache" 3
run_one_reuse tests/asm/assign_index_block_read_subadd3.x /tmp/shux_asm_assign_index_block_read_subadd3 198 "read subadd3 after assign" 4
run_one_reuse tests/asm/assign_index_block_read_minus_mul.x /tmp/shux_asm_assign_index_block_read_minus_mul 22 "read minus mul after subadd3 assign" 5
run_one_reuse tests/asm/assign_index_block_read_minus_mul_seq.x /tmp/shux_asm_assign_index_block_read_minus_mul_seq 110 "read minus mul after assign" 3

echo "asm assign index block OK"
