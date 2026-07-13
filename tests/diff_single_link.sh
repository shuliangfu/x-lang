#!/usr/bin/env bash
# diff_single_link.sh — 单链差分 harness（自举方法 Phase 0）
#
# 对每个 compiler/src/*.x 核心模块跑 shux -E，对比 seed _gen.c / seeds/*.from_x.c
# 输出：自举进度地图（已自举 / typeck 失败 / 差分非空）
#
# 用法：cd compiler && bash ../tests/diff_single_link.sh
#       或：SHUX=./compiler/shux bash tests/diff_single_link.sh

set -u
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT/compiler" || exit 1

# 解析 SHUX 为绝对路径（支持 SHUX=./compiler/shux 或 SHUX=./shux 两种写法）
# 根因：macOS arm64 ASM backend 链接失败（pre-existing），shux 二进制可能不存在；
# 此时 fallback 到 shux-c（C 前端构建，-E 功能等价用于差分验证）
SHUX_REL="${SHUX:-./shux}"
if [ ! -f "$SHUX_REL" ]; then
  SHUX_REL="$REPO_ROOT/compiler/shux"
fi
if [ ! -f "$SHUX_REL" ]; then
  # shux 不存在，fallback 到 shux-c
  SHUX_REL="$REPO_ROOT/compiler/shux-c"
  if [ ! -f "$SHUX_REL" ]; then
    echo "diff_single_link: neither shux nor shux-c found in compiler/" >&2
    exit 127
  fi
  echo "diff_single_link: WARN shux not found, fallback to shux-c" >&2
fi
SHUX_BIN="$(cd "$(dirname "$SHUX_REL")" && pwd)/$(basename "$SHUX_REL")"
COMPILER_DIR="."
TMP_DIR="${TMPDIR:-/tmp}/shux_diff_$$"
mkdir -p "$TMP_DIR"

# import 搜索路径：覆盖所有 compiler/src/ 子模块 + 上级 std/
# 根因：.x 文件用 import("ast") / import("std.heap") 等，需要 -L 指定搜索目录
SHUX_LIB_PATHS="-L .. -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/lsp -L src/driver -L src/preprocess"

# 核心前端模块（.x 源 → seed C）
# 格式：.x相对路径|seed相对路径
MODULES=(
  "src/runtime_driver_diagnostic.x|seeds/runtime_driver_diagnostic.from_x.c"
  "src/lexer/token.x|token_gen.c"
  "src/lexer/lexer.x|lexer_gen.c"
  "src/preprocess/preprocess.x|preprocess_gen.c"
  "src/ast/ast.x|ast_gen.c"
  "src/parser/parser.x|parser_gen.c"
  "src/typeck/typeck.x|typeck_gen.c"
  "src/codegen/codegen.x|codegen_gen.c"
  "src/lsp/lsp.x|lsp_gen.c"
  "src/lsp/lsp_diag.x|lsp_diag_gen.c"
  "src/lsp/lsp_io.x|lsp_io_gen.c"
  "src/driver/fmt.x|driver_fmt_gen.c"
  "src/driver/check.x|driver_check_gen.c"
  "src/driver/test.x|driver_test_gen.c"
  "src/driver/compile.x|driver_compile_gen.c"
  "src/driver/build.x|driver_build_gen.c"
  "src/driver/run.x|driver_run_gen.c"
  "src/driver/emit.x|driver_emit_gen.c"
)

# 统计
TOTAL=0
PASS_TYPECK=0      # typeck 通过（-E 成功）
PASS_DIFF=0        # typeck 通过 + diff 为空（可退役 seed）
FAIL_TYPECK=0      # typeck 失败
FAIL_DIFF=0        # typeck 通过但 diff 非空
FAIL_OTHER=0       # 其它失败

printf "%-45s | %-10s | %-8s | %s\n" "模块" "typeck" "diff" "备注"
printf "%-45s-+-%-10s-+-%-8s-+-%s\n" "$(printf '%0.s-' {1..45})" "$(printf '%0.s-' {1..10})" "$(printf '%0.s-' {1..8})" "$(printf '%0.s-' {1..30})"

for entry in "${MODULES[@]}"; do
  x_src="${entry%%|*}"
  seed="${entry##*|}"
  seed_path="$COMPILER_DIR/$seed"
  x_path="$COMPILER_DIR/$x_src"
  TOTAL=$((TOTAL + 1))

  if [ ! -f "$x_path" ]; then
    printf "%-45s | %-10s | %-8s | %s\n" "$x_src" "NOSRC" "-" "-"
    FAIL_OTHER=$((FAIL_OTHER + 1))
    continue
  fi

  if [ ! -f "$seed_path" ]; then
    printf "%-45s | %-10s | %-8s | %s\n" "$x_src" "NOSEED" "-" "seed=$seed"
    FAIL_OTHER=$((FAIL_OTHER + 1))
    continue
  fi

  # 跑 shux -E，捕获 stdout 到临时文件（超时 30 秒，防止大模块死循环）
  # 加 -L 搜索路径，让 import("ast") / import("std.heap") 等能正确解析
  out_file="$TMP_DIR/$(basename "$x_src" .x)_gen.c"
  err_file="$TMP_DIR/$(basename "$x_src" .x)_err.txt"
  perl -e 'alarm 30; exec @ARGV' "$SHUX_BIN" -E $SHUX_LIB_PATHS "$x_src" >"$out_file" 2>"$err_file"
  rc=$?

  if [ $rc -ne 0 ]; then
    # 失败：看是超时、typeck 还是其它
    if [ $rc -eq 14 ] || [ $rc -eq 142 ]; then
      printf "%-45s | %-10s | %-8s | %s\n" "$x_src" "TIMEOUT" "-" "30s 超时（死循环/性能）"
      FAIL_OTHER=$((FAIL_OTHER + 1))
      continue
    fi
    if grep -q "typeck error" "$err_file" 2>/dev/null || grep -q "typeck error" "$out_file" 2>/dev/null; then
      # 提取第一个 typeck 错误的行号
      first_err=$(grep -m1 "typeck error" "$err_file" "$out_file" 2>/dev/null | head -1 | tr -d '\n' | cut -c1-60)
      printf "%-45s | %-10s | %-8s | %s\n" "$x_src" "FAIL" "-" "$first_err"
      FAIL_TYPECK=$((FAIL_TYPECK + 1))
    else
      first_err=$(head -1 "$err_file" 2>/dev/null | tr -d '\n' | cut -c1-60)
      printf "%-45s | %-10s | %-8s | %s\n" "$x_src" "ERR" "-" "${first_err:-rc=$rc}"
      FAIL_OTHER=$((FAIL_OTHER + 1))
    fi
    continue
  fi

  PASS_TYPECK=$((PASS_TYPECK + 1))

  # typeck 通过，做 diff
  # 归一化：去掉首行的调试输出（如 DBG-CALL）和尾随空白
  norm_out="$TMP_DIR/$(basename "$x_src" .x)_norm.out"
  norm_seed="$TMP_DIR/$(basename "$x_src" .x)_norm.seed"
  grep -v '^DBG-' "$out_file" | sed 's/[[:space:]]*$//' >"$norm_out"
  sed 's/[[:space:]]*$//' "$seed_path" >"$norm_seed"

  diff_lines=$(diff "$norm_seed" "$norm_out" | wc -l | tr -d ' ')

  if [ "$diff_lines" -eq 0 ]; then
    printf "%-45s | %-10s | %-8s | %s\n" "$x_src" "OK" "EMPTY" "可退役 seed"
    PASS_DIFF=$((PASS_DIFF + 1))
  else
    printf "%-45s | %-10s | %-8s | %s\n" "$x_src" "OK" "${diff_lines}行" "diff 非空"
    FAIL_DIFF=$((FAIL_DIFF + 1))
  fi
done

echo ""
echo "=== 自举进度地图 ==="
echo "总计模块：$TOTAL"
echo "  typeck 通过：$PASS_TYPECK / $TOTAL"
echo "  diff 为空（可退役 seed）：$PASS_DIFF / $TOTAL"
echo "  typeck 失败：$FAIL_TYPECK"
echo "  diff 非空：$FAIL_DIFF"
echo "  其它失败：$FAIL_OTHER"
echo ""
echo "自举完成度：$PASS_DIFF / $TOTAL"

# 清理
rm -rf "$TMP_DIR"
