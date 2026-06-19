#!/usr/bin/env bash
# asm 7.3：块内连续 VAR binop 复用 rbx 右操作数槽；return 四～十四元链验 x10–x15 spill。
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-main-disasm.sh
. tests/lib/wpo-main-disasm.sh
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

# x10/x11 spill 与 ldur 门禁仅 arm64 宿主（otool/objdump 反汇编为 AArch64 指令形态）。
asm_disasm_gate_host() {
  case "$(uname -m 2>/dev/null)" in
    arm64|aarch64) return 0 ;;
    *) return 1 ;;
  esac
}

# 提取 _main 反汇编（macOS otool / Linux objdump）。
asm_main_disasm() {
  wpo_main_asm "$1" 2>/dev/null || true
}

run_one() {
  local src="$1"
  local out="$2"
  local want="$3"
  local tag="$4"
  local max_b_ldur="$5"
  local max_a_ldur="${6:-99}"
  $SHUX "$src" -o "$out" 2>&1
  local exitcode=0
  "$out" >/dev/null 2>&1 || exitcode=$?
  if [ "$exitcode" -ne "$want" ]; then
    echo "run-asm-binop-block-var FAIL: $tag expected exit $want, got $exitcode"
    exit 1
  fi
  if ! asm_disasm_gate_host; then
    return 0
  fi
  local main_asm b_ldur a_ldur
  main_asm=$(asm_main_disasm "$out")
  if echo "$main_asm" | grep -q 'sub.*sp, sp, #0x10'; then
    echo "run-asm-binop-block-var FAIL: $tag still uses stack push for binop"
    exit 1
  fi
  b_ldur=$(echo "$main_asm" | grep -cE 'ldur[[:space:]]+x1,.*#-0x18' || true)
  a_ldur=$(echo "$main_asm" | grep -cE 'ldur[[:space:]]+x0,.*#-0x10' || true)
  if [ "$b_ldur" -gt "$max_b_ldur" ]; then
    echo "run-asm-binop-block-var FAIL: $tag ldur x1 [b] count $b_ldur > $max_b_ldur"
    exit 1
  fi
  if [ "$a_ldur" -gt "$max_a_ldur" ]; then
    echo "run-asm-binop-block-var FAIL: $tag ldur x0 [a] count $a_ldur > $max_a_ldur"
    exit 1
  fi
}

# 7.3：_main 反汇编须含 x10 暂存或恢复到 rax/rbx。
check_x10_spill() {
  local out="$1"
  local tag="$2"
  local main_asm
  if ! asm_disasm_gate_host; then
    return 0
  fi
  main_asm=$(asm_main_disasm "$out")
  if ! echo "$main_asm" | grep -qE 'mov[[:space:]]+x10, x|mov[[:space:]]+x0, x10|mov[[:space:]]+x1, x10'; then
    echo "run-asm-binop-block-var FAIL: $tag missing x10 spill/reload in _main"
    exit 1
  fi
}

# 7.3：_main 内须含 x10 或 x11 spill（五 VAR 链可能用 x11）。
check_spill_x10_or_x11() {
  local out="$1"
  local tag="$2"
  local main_asm
  if ! asm_disasm_gate_host; then
    return 0
  fi
  main_asm=$(asm_main_disasm "$out")
  if ! echo "$main_asm" | grep -qE 'mov[[:space:]]+x1[01], x|mov[[:space:]]+x0, x1[01]|mov[[:space:]]+x1, x1[01]'; then
    echo "run-asm-binop-block-var FAIL: $tag missing x10/x11 spill/reload in _main"
    exit 1
  fi
}

# 7.3：六 VAR 链在 x10 已占用时应 spill 到 x11。
check_x11_spill() {
  local out="$1"
  local tag="$2"
  local main_asm
  if ! asm_disasm_gate_host; then
    return 0
  fi
  main_asm=$(asm_main_disasm "$out")
  if ! echo "$main_asm" | grep -qE 'mov[[:space:]]+x11, x|mov[[:space:]]+x0, x11|mov[[:space:]]+x1, x11'; then
    echo "run-asm-binop-block-var FAIL: $tag missing x11 spill/reload in _main"
    exit 1
  fi
}

# 7.3：_main 内不得出现 spill 槽与 x0/x1 连续往返 mov（应由 peephole_elf 消除）。
check_no_spill_roundtrip_mov() {
  local out="$1"
  local tag="$2"
  local main_asm
  if ! asm_disasm_gate_host; then
    return 0
  fi
  main_asm=$(asm_main_disasm "$out")
  if ! echo "$main_asm" | perl -0777 -ne 'exit 1 if /mov\s+x1[0-5],\s+x[01]\n\s*mov\s+x[01],\s+x1[0-5]/ || /mov\s+x[01],\s+x1[0-5]\n\s*mov\s+x1[0-5],\s+x[01]/'; then
    echo "run-asm-binop-block-var FAIL: $tag has redundant spill round-trip mov (peephole miss)"
    exit 1
  fi
}

# 7.3：十三 VAR 链在 x10–x14 已占用时应 spill 到 x15。
check_x15_spill() {
  local out="$1"
  local tag="$2"
  local main_asm
  if ! asm_disasm_gate_host; then
    return 0
  fi
  main_asm=$(asm_main_disasm "$out")
  if ! echo "$main_asm" | grep -qE 'mov[[:space:]]+x15, x|mov[[:space:]]+x0, x15|mov[[:space:]]+x1, x15'; then
    echo "run-asm-binop-block-var FAIL: $tag missing x15 spill/reload in _main"
    exit 1
  fi
}

# 7.3：九 VAR 链在 x10–x13 已占用时应 spill 到 x14。
check_x14_spill() {
  local out="$1"
  local tag="$2"
  local main_asm
  if ! asm_disasm_gate_host; then
    return 0
  fi
  main_asm=$(asm_main_disasm "$out")
  if ! echo "$main_asm" | grep -qE 'mov[[:space:]]+x14, x|mov[[:space:]]+x0, x14|mov[[:space:]]+x1, x14'; then
    echo "run-asm-binop-block-var FAIL: $tag missing x14 spill/reload in _main"
    exit 1
  fi
}

# 7.3：八 VAR 链在 x10/x11/x12 已占用时应 spill 到 x13。
check_x13_spill() {
  local out="$1"
  local tag="$2"
  local main_asm
  if ! asm_disasm_gate_host; then
    return 0
  fi
  main_asm=$(asm_main_disasm "$out")
  if ! echo "$main_asm" | grep -qE 'mov[[:space:]]+x13, x|mov[[:space:]]+x0, x13|mov[[:space:]]+x1, x13'; then
    echo "run-asm-binop-block-var FAIL: $tag missing x13 spill/reload in _main"
    exit 1
  fi
}

# 7.3：七 VAR 链在 x10/x11 已占用时应 spill 到 x12。
check_x12_spill() {
  local out="$1"
  local tag="$2"
  local main_asm
  if ! asm_disasm_gate_host; then
    return 0
  fi
  main_asm=$(asm_main_disasm "$out")
  if ! echo "$main_asm" | grep -qE 'mov[[:space:]]+x12, x|mov[[:space:]]+x0, x12|mov[[:space:]]+x1, x12'; then
    echo "run-asm-binop-block-var FAIL: $tag missing x12 spill/reload in _main"
    exit 1
  fi
}

run_one tests/asm/binop_block_repeat_add.sx /tmp/shux_asm_binop_block_repeat_add 60 "repeat add" 1 2
run_one tests/asm/binop_block_repeat_mul.sx /tmp/shux_asm_binop_block_repeat_mul 12 "repeat mul" 1 2
run_one tests/asm/binop_block_prune_dead_b.sx /tmp/shux_asm_binop_block_prune_b 10 "prune dead b" 1
run_one tests/asm/binop_block_shared_right.sx /tmp/shux_asm_binop_block_shared_right 90 "shared right var" 3 4
run_one tests/asm/binop_block_swap_add.sx /tmp/shux_asm_binop_block_swap_add 60 "swap add" 1 2
run_one tests/asm/binop_block_three_var.sx /tmp/shux_asm_binop_block_three 6 "three var linear chain" 99 99
run_one tests/asm/binop_block_four_var.sx /tmp/shux_asm_binop_block_four 10 "four var linear |live|>2" 99 99
run_one tests/asm/binop_block_five_var.sx /tmp/shux_asm_binop_block_five 231 "five var |live|>3 pressure" 99 99
run_one tests/asm/binop_block_six_var.sx /tmp/shux_asm_binop_block_six 21 "six var next-use eviction" 99 99
run_one tests/asm/binop_return_four_add.sx /tmp/shux_asm_binop_ret_four 10 "return four-var add chain" 99 99
check_x10_spill /tmp/shux_asm_binop_ret_four "return four add"
run_one tests/asm/binop_return_four_mul.sx /tmp/shux_asm_binop_ret_four_mul 24 "return four-var mul chain" 99 99
check_x10_spill /tmp/shux_asm_binop_ret_four_mul "return four mul"
run_one tests/asm/binop_return_four_and.sx /tmp/shux_asm_binop_ret_four_and 1 "return four-var and chain" 99 99
check_x10_spill /tmp/shux_asm_binop_ret_four_and "return four and"
run_one tests/asm/binop_return_four_or.sx /tmp/shux_asm_binop_ret_four_or 15 "return four-var or chain" 99 99
check_x10_spill /tmp/shux_asm_binop_ret_four_or "return four or"
run_one tests/asm/binop_return_four_xor.sx /tmp/shux_asm_binop_ret_four_xor 15 "return four-var xor chain" 99 99
check_x10_spill /tmp/shux_asm_binop_ret_four_xor "return four xor"
run_one tests/asm/binop_return_five_add.sx /tmp/shux_asm_binop_ret_five 15 "return five-var add chain" 99 99
check_spill_x10_or_x11 /tmp/shux_asm_binop_ret_five "return five add"
run_one tests/asm/binop_return_six_add.sx /tmp/shux_asm_binop_ret_six 21 "return six-var add chain" 99 99
check_x11_spill /tmp/shux_asm_binop_ret_six "return six add"
run_one tests/asm/binop_return_seven_add.sx /tmp/shux_asm_binop_ret_seven 28 "return seven-var add chain" 99 99
check_x12_spill /tmp/shux_asm_binop_ret_seven "return seven add"
run_one tests/asm/binop_return_eight_add.sx /tmp/shux_asm_binop_ret_eight 36 "return eight-var add chain" 99 99
check_x13_spill /tmp/shux_asm_binop_ret_eight "return eight add"
run_one tests/asm/binop_return_nine_add.sx /tmp/shux_asm_binop_ret_nine 45 "return nine-var add chain" 99 99
check_x14_spill /tmp/shux_asm_binop_ret_nine "return nine add"
check_no_spill_roundtrip_mov /tmp/shux_asm_binop_ret_nine "return nine add"
run_one tests/asm/binop_return_thirteen_add.sx /tmp/shux_asm_binop_ret_thirteen 91 "return thirteen-var add chain" 99 99
check_x15_spill /tmp/shux_asm_binop_ret_thirteen "return thirteen add"
check_no_spill_roundtrip_mov /tmp/shux_asm_binop_ret_thirteen "return thirteen add"
run_one tests/asm/binop_return_fourteen_add.sx /tmp/shux_asm_binop_ret_fourteen 105 "return fourteen-var add chain" 99 99
check_x15_spill /tmp/shux_asm_binop_ret_fourteen "return fourteen add"
run_one tests/asm/binop_block_two_phase_add.sx /tmp/shux_asm_binop_two_phase 36 "two-phase four-var chaitin share" 99 99

echo "asm binop block var OK"
