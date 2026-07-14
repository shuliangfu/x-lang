#!/usr/bin/env bash
# prove_module_selfhost.sh — 单模块自举验证（.o 符号差分）
#
# 自举方法 P0 工具：验证某模块的 .x → .o 与 seed gen.c → .o 符号一致
# 这是比 C 源码 diff 更准确的差分验证（符号层面 = 功能层面等价）
#
# 用法：bash tests/prove_module_selfhost.sh [模块名...]
#   不传参数 = 验证所有已配置模块
#   传模块名 = 只验证指定模块（如：fmt check test build run diagnostic）
#
# 输出：每个模块的 shux-E / cc-c / nm-diff 状态
#
# 模式（第 5 字段，可选）：
#   （空）  IDENTICAL — 已定义符号完全一致 → 可退役 seed（计入 N）
#   core:a,b,c  CORE — x 定义符号 ⊆ seed，允许 x 独有辅助符号 a,b,c
#               （hybrid thin/C-tail seed 的中间门禁；不计 N 退役）

set -u
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT/compiler" || exit 1

# 模块配置（模块名|.x路径|seed路径|符号重命名|模式）
# 符号重命名映射格式：old1:new1,old2:new2,...
# 模式：空 | core:x_only_sym1,x_only_sym2
MODULES=(
  "fmt|src/driver/fmt.x|driver_fmt_gen.c|cmd_fmt:driver_cmd_fmt|"
  "check|src/driver/check.x|driver_check_gen.c|cmd_check:driver_cmd_check|"
  "test|src/driver/test.x|driver_test_gen.c|cmd_test:driver_cmd_test|"
  "build|src/driver/build.x|driver_build_gen.c|cmd_build:build_cmd_build|"
  "run|src/driver/run.x|driver_run_gen.c|cmd_run:driver_cmd_run,run_eq_word:driver_run_eq_word|"
  "compile|src/driver/compile.x|driver_compile_gen.c|compile_dispatch_asm_backend:driver_compile_dispatch_asm_backend,compile_dispatch_emit_c_path:driver_compile_dispatch_emit_c_path,eq_minus_o:driver_eq_minus_o,eq_minus_L:driver_eq_minus_L,eq_minus_backend:driver_eq_minus_backend,eq_minus_target:driver_eq_minus_target,eq_minus_target_cpu:driver_eq_minus_target_cpu,eq_print_target_cpu:driver_eq_print_target_cpu,eq_minus_O:driver_eq_minus_O,eq_flto:driver_eq_flto,eq_minus_freestanding:driver_eq_minus_freestanding,eq_legacy_f32_abi:driver_eq_legacy_f32_abi,eq_fsanitize_address:driver_eq_fsanitize_address,eq_asm_word:driver_eq_asm_word,eq_c_word:driver_eq_c_word,path_ends_x:driver_path_ends_x,target_has_arm:driver_target_has_arm,run_compiler_full_x_post_parse:driver_run_compiler_full_x_post_parse,run_compiler_full_x:driver_run_compiler_full_x|"
  "emit|src/driver/emit.x|driver_emit_gen.c|emit_copy_lib_roots_to_ctx:driver_emit_copy_lib_roots_to_ctx,run_x_emit_x:driver_run_x_emit_x,dispatch_x_emit_to_c:driver_dispatch_x_emit_to_c,emit_state_key:driver_emit_state_key,pipeline_dep_ctx_fill_for_emit:driver_pipeline_dep_ctx_fill_for_emit|"
  "lsp_io_std_heap|src/lsp/lsp_io_std_heap.x|lsp_io_std_heap_gen.c|std_heap_alloc:lsp_io_std_heap_std_heap_alloc,std_heap_alloc_zeroed:lsp_io_std_heap_std_heap_alloc_zeroed,std_heap_free:lsp_io_std_heap_std_heap_free|"
  # token：enum+Token+token_is_eof；产品链仍用 include/token.h（C 头），本条锁 nm 面 / 扩 N
  "token|src/lexer/token.x|token_gen.c||"
  # lsp_diag_pipeline_sizes：三枚 sizeof 门闩；产品 sizes_nostub PREFER_X_O；本条锁 nm / 扩 N
  "lsp_diag_pipeline_sizes|src/lsp/lsp_diag_pipeline_sizes.x|seeds/lsp_diag_pipeline_sizes.from_x.c||"
  # labi_path_pure：路径纯串 L0；产品 hybrid 入 runtime_link_abi；本条锁 nm / 扩 N
  "labi_path_pure|src/runtime/labi_path_pure.x|seeds/labi_path_pure.from_x.c||"
  # labi_gates：L9 thin null-check 转发；产品 PREFER_X_O；冷启动 seed；本条锁 nm / 扩 N
  "labi_gates|src/runtime/labi_gates.x|seeds/labi_gates.from_x.c||"
  # labi_invoke_cc_list：L5 短字面量表；依赖 W-string-nul；产品 PREFER_X_O；本条锁 nm / 扩 N
  "labi_invoke_cc_list|src/runtime/labi_invoke_cc_list.x|seeds/labi_invoke_cc_list.from_x.c||"
  # labi_invoke_ld_list：L6 brew/compress/tail 短字面量表；依赖 W-string-nul；产品 PREFER_X_O；本条锁 nm / 扩 N
  "labi_invoke_ld_list|src/runtime/labi_invoke_ld_list.x|seeds/labi_invoke_ld_list.from_x.c||"
  # labi_freestanding_list：L7 env/io_sym/ensure 短字面量表；依赖 W-string-nul；产品 PREFER_X_O；本条锁 nm / 扩 N
  "labi_freestanding_list|src/runtime/labi_freestanding_list.x|seeds/labi_freestanding_list.from_x.c||"
  # labi_std_list：L8 默认 std 链接计划表；plan_step_at 多 out（*i32/*usize）；产品 PREFER_X_O；本条锁 nm / 扩 N
  "labi_std_list|src/runtime/labi_std_list.x|seeds/labi_std_list.from_x.c||"
  # labi_ondemand_list：L8b on_demand 符号组/rel 纯表；依赖 W-string-nul；产品 PREFER_X_O；本条锁 nm / 扩 N
  "labi_ondemand_list|src/runtime/labi_ondemand_list.x|seeds/labi_ondemand_list.from_x.c||"
  # hybrid thin+C-tail：seed 多 _impl/scratch；x 多 append_*（.x 真迁拼装）。CORE 锁公共 API 面不丢。
  "diagnostic|src/runtime_driver_diagnostic.x|seeds/runtime_driver_diagnostic.from_x.c||core:driver_diag_append_cstr,driver_diag_append_i32,driver_diag_append_name"
)

# 找 shux 二进制（优先 shux，fallback shux-c）
SHUX_BIN=""
for bin in ./shux ./shux-c ./bootstrap_shuxc; do
  if [ -x "$bin" ]; then
    SHUX_BIN="$bin"
    break
  fi
done
if [ -z "$SHUX_BIN" ]; then
  echo "prove: no shux/shux-c/bootstrap_shuxc found in compiler/" >&2
  exit 127
fi

CC="${CC:-cc}"
BASE_CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc"
TMP_DIR="${TMPDIR:-/tmp}/shux_prove_$$"
mkdir -p "$TMP_DIR"

SHUX_LIB_PATHS="-L .. -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/lsp -L src/driver -L src/preprocess"

# 生成 .x 版 .o（模拟 g05_try_x_to_o 逻辑）
gen_x_o() {
  local xsrc="$1"
  local xout="$2"
  local sym_rename="$3"

  local tmp="$TMP_DIR/$(basename "$xsrc" .x)_x.c"

  # shux -E（超时 30s 防死循环）
  if ! perl -e 'alarm 30; exec @ARGV' "$SHUX_BIN" -E $SHUX_LIB_PATHS "$xsrc" >"$tmp" 2>/dev/null || [ ! -s "$tmp" ]; then
    return 1
  fi

  # 过滤 DBG- 调试行
  grep -v '^DBG-' "$tmp" >"${tmp}.clean" && mv "${tmp}.clean" "$tmp"

  # 符号重命名（与 g05 G05_X_O_SYM_RENAME 一致）
  if [ -n "$sym_rename" ]; then
    local old_ifs="$IFS"
    IFS=','
    for pair in $sym_rename; do
      old_name="${pair%%:*}"
      new_name="${pair#*:}"
      if [ -n "$old_name" ] && [ -n "$new_name" ] && [ "$old_name" != "$new_name" ]; then
        perl -i -pe "s/\\b${old_name}\\b/${new_name}/g" "$tmp" || true
      fi
    done
    IFS="$old_ifs"
  fi

  # POSIX prologue + 删 -E 自带 #include 和 libc extern（与 g05 一致）
  {
    echo '/* prove prologue (g05_try_x_to_o aligned) */'
    echo '#include <stddef.h>'
    echo '#include <stdint.h>'
    echo '#include <sys/types.h>'
    echo '#include <stdlib.h>'
    echo '#include <string.h>'
    echo '#include <stdio.h>'
    echo '#ifndef _WIN32'
    echo '#include <unistd.h>'
    echo '#include <fcntl.h>'
    echo '#include <errno.h>'
    echo '#endif'
    sed -e '/^#include /d' \
        -e '/^extern ssize_t read(/d' \
        -e '/^extern ssize_t write(/d' \
        -e '/^extern int32_t open(/d' \
        -e '/^extern int open(/d' \
        -e '/^extern int32_t close(/d' \
        -e '/^extern int close(/d' \
        -e '/^extern uint8_t \* calloc(/d' \
        -e '/^extern uint8_t \* malloc(/d' \
        -e '/^extern void free(/d' \
        -e '/^extern char \* getenv(/d' \
        -e '/^extern uint8_t \* getenv(/d' \
        -e '/^extern int32_t unlink(/d' \
        -e '/^extern int unlink(/d' \
        -e '/^extern size_t strlen(/d' \
        "$tmp"
  } >"${tmp}.full" && mv "${tmp}.full" "$tmp"

  # cc -c
  $CC $BASE_CFLAGS -x c -c -o "$xout" "$tmp" 2>"${TMP_DIR}/cc_err.txt"
}

# 生成 seed 版 .o
gen_seed_o() {
  local seed="$1"
  local out="$2"
  $CC $BASE_CFLAGS -I. -c -o "$out" "$seed" 2>"${TMP_DIR}/cc_err.txt"
}

# 已定义**全局**业务符号裸名（去 Mach-O 前导 _），一行一个
# 只取 nm 大写类型（T/D/B/R/S/C…）：忽略局部 t/d/s（字符串池 l_constinit / l_.str、
# static 表、ltmp）与 U（含 stack_chk 引用）。W-string-nul 后 .x 与 seed 字符串编码
# 不同属预期，IDENTICAL 比公共 API 面而非 rodata 形名。
defined_sym_names() {
  # LC_ALL=C：comm 要求字节序排序；locale sort 在 Ubuntu 会触发 “not in sorted order”
  nm "$1" 2>/dev/null | awk '
    $2 ~ /^[A-Z]$/ && $2 != "U" {
      s = $3
      if (s ~ /^_/) s = substr(s, 2)
      # 保险：仍丢编译器局部命名（极少数平台大写类型误标）
      if (s ~ /^l_/) next
      if (s ~ /^\./) next
      if (s ~ /^L\./) next
      if (s ~ /^ltmp/) next
      print s
    }' | LC_ALL=C sort -u
}

# nm 比较符号 — IDENTICAL 模式：全局业务符号集合相等（可退役 seed）
compare_symbols() {
  local o1="$1"
  local o2="$2"
  local sym1="$TMP_DIR/sym1.txt"
  local sym2="$TMP_DIR/sym2.txt"
  defined_sym_names "$o1" >"$sym1"
  defined_sym_names "$o2" >"$sym2"
  diff "$sym1" "$sym2"
}

# CORE 模式：x 定义符号（除 allowlist）必须 ⊆ seed；seed 可多 thin/impl/C-tail
# 输出：空=通过；否则列出缺失符号
compare_core_surface() {
  local x_o="$1"
  local seed_o="$2"
  local allow_csv="$3"
  local x_syms="$TMP_DIR/core_x.txt"
  local seed_syms="$TMP_DIR/core_seed.txt"
  local allow_file="$TMP_DIR/core_allow.txt"
  local missing="$TMP_DIR/core_missing.txt"

  defined_sym_names "$x_o" >"$x_syms"
  defined_sym_names "$seed_o" >"$seed_syms"
  : >"$allow_file"
  if [ -n "$allow_csv" ]; then
    local old_ifs="$IFS"
    IFS=','
    for a in $allow_csv; do
      a="${a#_}"
      [ -n "$a" ] && echo "$a" >>"$allow_file"
    done
    IFS="$old_ifs"
    LC_ALL=C sort -u "$allow_file" -o "$allow_file"
  fi

  # x \ seed \ allow
  comm -23 "$x_syms" "$seed_syms" >"${missing}.raw"
  if [ -s "$allow_file" ]; then
    comm -23 "${missing}.raw" "$allow_file" >"$missing"
  else
    mv "${missing}.raw" "$missing"
  fi

  if [ -s "$missing" ]; then
    echo "CORE missing from seed:"
    cat "$missing"
    return 1
  fi
  # 备注：seed 多 / x 仅 allowlist 不 fail
  local seed_only x_only
  seed_only=$(comm -13 "$x_syms" "$seed_syms" | wc -l | tr -d ' ')
  x_only=$(comm -23 "$x_syms" "$seed_syms" | wc -l | tr -d ' ')
  echo "seed+${seed_only} x_allow+${x_only}"
  return 0
}

# 主逻辑
printf "%-18s | %-8s | %-8s | %-10s | %s\n" "模块" "shux-E" "cc-c" "nm-diff" "备注"
printf "%-18s-+-%-8s-+-%-8s-+-%-10s-+-%s\n" "$(printf '%0.s-' {1..18})" "$(printf '%0.s-' {1..8})" "$(printf '%0.s-' {1..8})" "$(printf '%0.s-' {1..10})" "$(printf '%0.s-' {1..30})"

PASS=0
CORE_PASS=0
FAIL=0
SKIP=0

# 过滤模块（如果传了参数）
SELECTED="${*:-}"
for entry in "${MODULES[@]}"; do
  IFS='|' read -r name xsrc seed sym_rename mode <<< "$entry"

  # 如果传了参数，只验证指定的模块
  if [ -n "$SELECTED" ]; then
    found=0
    for sel in $SELECTED; do
      [ "$sel" = "$name" ] && found=1 && break
    done
    [ "$found" = "0" ] && continue
  fi

  # 检查 .x 和 seed 是否存在
  if [ ! -f "$xsrc" ]; then
    printf "%-18s | %-8s | %-8s | %-10s | %s\n" "$name" "NOSRC" "-" "-" ".x 不存在"
    SKIP=$((SKIP + 1))
    continue
  fi
  seed_path=""
  # Track L：工作区 *_gen.c 已非构建硬依赖；冷启动对照用 seeds/*_gen.linux.x86_64.c
  _seed_base="${seed%.c}"
  for s in "$seed" "seeds/$seed" "seeds/${_seed_base}.linux.x86_64.c" "seeds/${seed}"; do
    if [ -f "$s" ]; then
      seed_path="$s"
      break
    fi
  done
  if [ -z "$seed_path" ]; then
    printf "%-18s | %-8s | %-8s | %-10s | %s\n" "$name" "NOSEED" "-" "-" "seed=$seed 不存在"
    SKIP=$((SKIP + 1))
    continue
  fi

  x_o="$TMP_DIR/${name}_x.o"
  seed_o="$TMP_DIR/${name}_seed.o"

  # 生成 .x 版 .o
  if ! gen_x_o "$xsrc" "$x_o" "$sym_rename"; then
    printf "%-18s | %-8s | %-8s | %-10s | %s\n" "$name" "FAIL" "-" "-" "shux -E 或 cc -c 失败"
    FAIL=$((FAIL + 1))
    continue
  fi

  # 生成 seed 版 .o
  if ! gen_seed_o "$seed_path" "$seed_o"; then
    printf "%-18s | %-8s | %-8s | %-10s | %s\n" "$name" "OK" "FAIL" "-" "seed cc -c 失败"
    FAIL=$((FAIL + 1))
    continue
  fi

  # nm 比较
  if [[ "$mode" == core:* ]]; then
    allow_csv="${mode#core:}"
    core_out=$(compare_core_surface "$x_o" "$seed_o" "$allow_csv")
    core_rc=$?
    if [ "$core_rc" -eq 0 ]; then
      printf "%-18s | %-8s | %-8s | %-10s | %s\n" "$name" "OK" "OK" "CORE_OK" "$core_out; hybrid 非退役"
      CORE_PASS=$((CORE_PASS + 1))
    else
      printf "%-18s | %-8s | %-8s | %-10s | %s\n" "$name" "OK" "OK" "CORE_FAIL" "x 公共面缺失于 seed"
      echo "$core_out" | head -8 | sed 's/^/    /'
      FAIL=$((FAIL + 1))
    fi
  else
    diff_out=$(compare_symbols "$x_o" "$seed_o")
    if [ -z "$diff_out" ]; then
      printf "%-18s | %-8s | %-8s | %-10s | %s\n" "$name" "OK" "OK" "IDENTICAL" "可退役 seed"
      PASS=$((PASS + 1))
    else
      diff_lines=$(echo "$diff_out" | wc -l | tr -d ' ')
      printf "%-18s | %-8s | %-8s | %-10s | %s\n" "$name" "OK" "OK" "${diff_lines}行" "符号差异"
      # 显示前 5 行差异
      echo "$diff_out" | head -5 | sed 's/^/    /'
      FAIL=$((FAIL + 1))
    fi
  fi
done

echo ""
echo "=== 自举验证结果 ==="
echo "总计：$((PASS + CORE_PASS + FAIL + SKIP))"
echo "  符号一致（可退役 seed / KPI N）：$PASS"
echo "  核心面 OK（hybrid CORE，不计 N）：$CORE_PASS"
echo "  符号差异 / CORE 失败：$FAIL"
echo "  跳过：$SKIP"
echo ""
echo "IDENTICAL = .x→.o 与 seed→.o 已定义符号完全相同（可退役）"
echo "CORE_OK   = x 公共符号 ⊆ seed（允许 seed 多 thin/C-tail；x 独有列于 core: allowlist）"

# 清理
rm -rf "$TMP_DIR"

# 有 FAIL 则非零退出（CI / 门禁）
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
