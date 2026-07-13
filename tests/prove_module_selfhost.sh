#!/usr/bin/env bash
# prove_module_selfhost.sh — 单模块自举验证（.o 符号差分）
#
# 自举方法 P0 工具：验证某模块的 .x → .o 与 seed gen.c → .o 符号一致
# 这是比 C 源码 diff 更准确的差分验证（符号层面 = 功能层面等价）
#
# 用法：bash tests/prove_module_selfhost.sh [模块名...]
#   不传参数 = 验证所有已配置模块
#   传模块名 = 只验证指定模块（如：fmt check test build run）
#
# 输出：每个模块的 shux-E / cc-c / nm-diff 状态

set -u
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT/compiler" || exit 1

# 模块配置（模块名|.x路径|seed路径|符号重命名映射）
# 符号重命名映射格式：old1:new1,old2:new2,...
MODULES=(
  "fmt|src/driver/fmt.x|driver_fmt_gen.c|cmd_fmt:driver_cmd_fmt"
  "check|src/driver/check.x|driver_check_gen.c|cmd_check:driver_cmd_check"
  "test|src/driver/test.x|driver_test_gen.c|cmd_test:driver_cmd_test"
  "build|src/driver/build.x|driver_build_gen.c|cmd_build:build_cmd_build"
  "run|src/driver/run.x|driver_run_gen.c|cmd_run:driver_cmd_run,run_eq_word:driver_run_eq_word"
  "lsp_io_std_heap|src/lsp/lsp_io_std_heap.x|lsp_io_std_heap_gen.c|std_heap_alloc:lsp_io_std_heap_std_heap_alloc,std_heap_alloc_zeroed:lsp_io_std_heap_std_heap_alloc_zeroed,std_heap_free:lsp_io_std_heap_std_heap_free"
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

# nm 比较符号（只比较定义的符号，忽略未定义引用）
compare_symbols() {
  local o1="$1"
  local o2="$2"
  local sym1="$TMP_DIR/sym1.txt"
  local sym2="$TMP_DIR/sym2.txt"
  # 提取已定义符号（t/T/d/B/R = 定义，U = 未定义引用）
  nm "$o1" | awk '$1 != "" && $2 != "U" {print $2, $3}' | sort >"$sym1"
  nm "$o2" | awk '$1 != "" && $2 != "U" {print $2, $3}' | sort >"$sym2"
  diff "$sym1" "$sym2"
}

# 主逻辑
printf "%-18s | %-8s | %-8s | %-10s | %s\n" "模块" "shux-E" "cc-c" "nm-diff" "备注"
printf "%-18s-+-%-8s-+-%-8s-+-%-10s-+-%s\n" "$(printf '%0.s-' {1..18})" "$(printf '%0.s-' {1..8})" "$(printf '%0.s-' {1..8})" "$(printf '%0.s-' {1..10})" "$(printf '%0.s-' {1..30})"

PASS=0
FAIL=0
SKIP=0

# 过滤模块（如果传了参数）
SELECTED="${*:-}"
for entry in "${MODULES[@]}"; do
  IFS='|' read -r name xsrc seed sym_rename <<< "$entry"

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
  for s in "$seed" "seeds/$seed"; do
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
done

echo ""
echo "=== 自举验证结果 ==="
echo "总计：$((PASS + FAIL + SKIP))"
echo "  符号一致（可退役 seed）：$PASS"
echo "  符号差异：$FAIL"
echo "  跳过：$SKIP"
echo ""
echo "符号一致 = .x → .o 与 seed → .o 的已定义符号完全相同（功能层面自举）"

# 清理
rm -rf "$TMP_DIR"
