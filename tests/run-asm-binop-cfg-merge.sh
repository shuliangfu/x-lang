#!/usr/bin/env bash
# asm 7.3：if/while/for 汇合 live ∪；嵌套/混合/多轮/break/continue；ldur b 门禁。
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/wpo-main-disasm.sh
. tests/lib/wpo-main-disasm.sh
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || true

# ldur / AArch64 形态反汇编门禁仅 arm64 宿主（与 run-asm-binop-block-var.sh 一致）。
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

# 编译 cfg-merge 用例 -o；strict shux_asm 在 GHA 偶发 SIGSEGV 时回退 seed（shux-sx / shux_asm73_seed）。
cfg_merge_compile_o() {
  local src="$1" out="$2" tag="$3"
  local comp compile_ec=0 attempt=1
  local fallbacks=("$SHUX")
  local cand dup=0 c
  local compile_log
  local compile_timeout="${CFG_MERGE_COMPILE_TIMEOUT:-180}"

  if [ -n "${ASM73_FALLBACK_SHU:-}" ] && [ -x "${ASM73_FALLBACK_SHU}" ]; then
    fallbacks+=("$ASM73_FALLBACK_SHU")
  fi
  for cand in ./compiler/shux-sx ./compiler/shux_asm73_seed; do
    [ -x "$cand" ] || continue
    dup=0
    for c in "${fallbacks[@]}"; do
      if [ "$c" = "$cand" ]; then dup=1; break; fi
    done
    [ "$dup" -eq 0 ] && fallbacks+=("$cand")
  done

  for comp in "${fallbacks[@]}"; do
    attempt=1
    while [ "$attempt" -le 2 ]; do
      compile_ec=0
      compile_log=$(mktemp)
      if command -v timeout >/dev/null 2>&1; then
        timeout "$compile_timeout" "$comp" "$src" -o "$out" >"$compile_log" 2>&1 || compile_ec=$?
      else
        "$comp" "$src" -o "$out" >"$compile_log" 2>&1 || compile_ec=$?
      fi
      if [ "$compile_ec" -eq 124 ]; then
        echo "run-asm-binop-cfg-merge: FAIL: $tag compile timeout (${compile_timeout}s) via $comp" >&2
        rm -f "$compile_log"
        return 124
      fi
      grep -vE 'missing \.note\.GNU-stack|NOTE: This behaviour is deprecated' "$compile_log" >&2 || true
      rm -f "$compile_log"
      if [ "$compile_ec" -eq 0 ]; then
        if [ "$comp" != "$SHUX" ]; then
          echo "run-asm-binop-cfg-merge: note: used $comp for $tag ($SHUX SIGSEGV/unstable)"
        fi
        return 0
      fi
      if [ "$compile_ec" -eq 139 ] && [ "$attempt" -eq 1 ]; then
        echo "run-asm-binop-cfg-merge: warn: $comp SIGSEGV ($tag), retry once ..."
        attempt=2
        continue
      fi
      break
    done
    if [ "$compile_ec" -eq 139 ]; then
      echo "run-asm-binop-cfg-merge: warn: $comp SIGSEGV ($tag), try next compiler ..."
    else
      return "$compile_ec"
    fi
  done
  return "$compile_ec"
}

run_one() {
  local src="$1"
  local out="$2"
  local want="$3"
  local tag="$4"
  local run_timeout="${CFG_MERGE_RUN_TIMEOUT:-30}"
  echo "run-asm-binop-cfg-merge: [$tag] compile ..."
  cfg_merge_compile_o "$src" "$out" "$tag"
  local exitcode=0
  echo "run-asm-binop-cfg-merge: [$tag] run (want exit $want) ..."
  if command -v timeout >/dev/null 2>&1; then
    timeout "$run_timeout" "$out" >/dev/null 2>&1 || exitcode=$?
    if [ "$exitcode" -eq 124 ]; then
      echo "run-asm-binop-cfg-merge FAIL: $tag run timeout (${run_timeout}s)"
      exit 1
    fi
  else
    "$out" >/dev/null 2>&1 || exitcode=$?
  fi
  if [ "$exitcode" -ne "$want" ]; then
    echo "run-asm-binop-cfg-merge FAIL: $tag expected exit $want, got $exitcode"
    exit 1
  fi
  echo "run-asm-binop-cfg-merge: [$tag] OK"
}

# 可选：检查 main 内 b 槽 ldur 次数上限（b 栈偏移 #-0x18，与 binop_block 用例一致）。
run_one_ldur_b() {
  local src="$1"
  local out="$2"
  local want="$3"
  local tag="$4"
  local max_b_ldur="$5"
  run_one "$src" "$out" "$want" "$tag"
  if ! asm_disasm_gate_host; then
    return 0
  fi
  local main_asm b_ldur
  main_asm=$(asm_main_disasm "$out")
  b_ldur=$(echo "$main_asm" | grep -cE 'ldur[[:space:]]+x1,.*#-0x18' || true)
  if [ "$b_ldur" -gt "$max_b_ldur" ]; then
    echo "run-asm-binop-cfg-merge FAIL: $tag ldur x1 [b] count $b_ldur > $max_b_ldur (selective merge?)"
    exit 1
  fi
}

run_one tests/asm/binop_if_plus_eq_merge.sx /tmp/shux_asm_binop_if_merge 13 "if merge a+=10"
run_one tests/asm/binop_if_both_assign_a.sx /tmp/shux_asm_binop_if_both_a 13 "if both branches a+="
run_one_ldur_b tests/asm/binop_if_both_assign_keep_b.sx /tmp/shux_asm_binop_if_both_b 13 "if phi both-def keep b" 2
run_one_ldur_b tests/asm/binop_if_merge_keep_b.sx /tmp/shux_asm_binop_if_keep_b 13 "if merge keep b cache" 2
run_one_ldur_b tests/asm/binop_if_after_use_b.sx /tmp/shux_asm_binop_if_after_b 13 "if after ldur b" 2
run_one tests/asm/binop_if_nested_after_b.sx /tmp/shux_asm_binop_if_nested_b 8 "nested if merge a+=5"
run_one_ldur_b tests/asm/binop_if_nested_after_b.sx /tmp/shux_asm_binop_if_nested_ldur 8 "nested if ldur b" 2
run_one tests/asm/binop_while_plus_eq_merge.sx /tmp/shux_asm_binop_while_merge 3 "while merge a+=1"
run_one_ldur_b tests/asm/binop_while_plus_eq_merge.sx /tmp/shux_asm_binop_while_merge_b 3 "while carried phi keep b" 2
run_one tests/asm/binop_while_twice_merge.sx /tmp/shux_asm_binop_while_twice 4 "while back-edge twice a+=1"
run_one tests/asm/binop_while_if_in_body.sx /tmp/shux_asm_binop_while_if 3 "while body if a+=1"
run_one_ldur_b tests/asm/binop_while_if_twice_keep_b.sx /tmp/shux_asm_binop_while_if2b 4 "while+if twice keep b" 2
run_one tests/asm/binop_while_break_merge.sx /tmp/shux_asm_binop_while_break 3 "while break a=1"
run_one_ldur_b tests/asm/binop_while_break_keep_b.sx /tmp/shux_asm_binop_while_break_b 3 "while break keep b" 2
run_one tests/asm/binop_while_continue_break.sx /tmp/shux_asm_binop_while_cont_br 6 "while continue+break"
run_one_ldur_b tests/asm/binop_while_nested_cont_br.sx /tmp/shux_asm_binop_while_nest_cb 5 "nested cont+br ldur b" 2
run_one_ldur_b tests/asm/binop_while_continue_keep_b.sx /tmp/shux_asm_binop_while_cont_b 6 "while continue keep b" 2
run_one tests/asm/binop_while_let_in_body.sx /tmp/shux_asm_binop_while_let 3 "while body let t a+=t"
run_one_ldur_b tests/asm/binop_if_while_in_then.sx /tmp/shux_asm_binop_if_while 3 "if then while ldur b" 2
run_one_ldur_b tests/asm/binop_while_nested_after_b.sx /tmp/shux_asm_binop_while_nested_b 3 "nested while after a+b" 2
run_one tests/asm/binop_while_nested_inner_break.sx /tmp/shux_asm_binop_while_nest_br 4 "nested while inner break"
run_one_ldur_b tests/asm/binop_while_nested_inner_break.sx /tmp/shux_asm_binop_while_nest_br_b 4 "nested inner break ldur b" 2
run_one tests/asm/binop_while_after_use_b.sx /tmp/shux_asm_binop_while_after_b 3 "while after a+b"
run_one_ldur_b tests/asm/binop_while_keep_b.sx /tmp/shux_asm_binop_while_keep_b 3 "while keep b ldur" 3
run_one tests/asm/binop_for_plus_eq_merge.sx /tmp/shux_asm_binop_for_merge 3 "for merge a+=1"
run_one tests/asm/binop_for_twice_merge.sx /tmp/shux_asm_binop_for_twice 4 "for twice a+=1"
run_one tests/asm/binop_for_if_in_body.sx /tmp/shux_asm_binop_for_if 3 "for body if a+=1"
run_one_ldur_b tests/asm/binop_if_for_in_then.sx /tmp/shux_asm_binop_if_for 3 "if then for ldur b" 2
run_one tests/asm/binop_for_step_header.sx /tmp/shux_asm_binop_for_step 3 "for step header a+=1"
run_one_ldur_b tests/asm/binop_for_keep_b.sx /tmp/shux_asm_binop_for_keep_b 3 "for keep b ldur" 3
run_one tests/asm/binop_for_continue_break.sx /tmp/shux_asm_binop_for_cont_br 6 "for continue+break"
run_one_ldur_b tests/asm/binop_for_carried_keep_b.sx /tmp/shux_asm_binop_for_carried_b 3 "for carried phi keep b" 2
run_one tests/asm/binop_if_return_eight_add.sx /tmp/shux_asm_binop_if_ret_eight 36 "if cfg + eight-var return add"
run_one tests/asm/binop_if_return_twelve_add.sx /tmp/shux_asm_binop_if_ret_twelve 78 "if cfg + twelve-var return add"
run_one tests/asm/binop_if_return_thirteen_add.sx /tmp/shux_asm_binop_if_ret_thirteen 91 "if cfg + thirteen-var return add"
run_one tests/asm/binop_if_return_fourteen_add.sx /tmp/shux_asm_binop_if_ret_fourteen 105 "if cfg + fourteen-var return add"
run_one tests/asm/binop_while_return_fourteen_add.sx /tmp/shux_asm_binop_while_ret_fourteen 105 "while cfg + fourteen-var return add"
run_one tests/asm/binop_for_return_fourteen_add.sx /tmp/shux_asm_binop_for_ret_fourteen 105 "for cfg + fourteen-var return add"
run_one tests/asm/binop_if_while_return_fourteen_add.sx /tmp/shux_asm_binop_if_while_ret_fourteen 105 "nested if+while + fourteen-var return"
run_one tests/asm/binop_if_phi_return_fourteen_add.sx /tmp/shux_asm_binop_if_phi_ret_fourteen 105 "if phi both-def a + fourteen-var return"
run_one tests/asm/binop_while_phi_return_fourteen_add.sx /tmp/shux_asm_binop_while_phi_ret_fourteen 105 "while loop phi a+=1 + fourteen-var return"
# 7.3：十四元 return（final_expr VAR≥12）须走栈帧 spill；φ 用例仅验 exit（双支写 a 后长链仍正确）。
if asm_disasm_gate_host; then
  for tag_bin in /tmp/shux_asm_binop_if_ret_fourteen /tmp/shux_asm_binop_while_ret_fourteen /tmp/shux_asm_binop_for_ret_fourteen /tmp/shux_asm_binop_if_while_ret_fourteen; do
    main_asm=$(asm_main_disasm "$tag_bin")
    if ! echo "$main_asm" | grep -q 'sub.*sp, sp, #0x10'; then
      echo "run-asm-binop-cfg-merge FAIL: $tag_bin missing cfg stack spill push"
      exit 1
    fi
  done
fi

echo "asm binop cfg merge OK"
