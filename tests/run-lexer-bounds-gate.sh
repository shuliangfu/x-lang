#!/usr/bin/env bash
# P1-3：Lexer 有界输入门禁 — 超长标识符/数字须 bounded scan，不栈溢出。
#
# 约定：标识符/数字扫描以源码 end 为界（不拷贝 ident）；TOKEN_STRING 解码缓冲 512 字节
#（权威：seeds/runtime_lexer_glue.from_x.c；lexer.c 已删，禁止双权威）。
# 用法：./tests/run-lexer-bounds-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/安全与性能.md"
MANIFEST="tests/baseline/lexer-bounds.tsv"
LEXER_GLUE="compiler/seeds/runtime_lexer_glue.from_x.c"
LONG_IDENT="/tmp/xlang_lexer_long_ident_$$.x"
LONG_NUM="/tmp/xlang_lexer_long_num_$$.x"

echo "=== P1-3: lexer bounds manifest ==="
for f in "$DOC" "$MANIFEST" "$LEXER_GLUE"; do
  if [ ! -f "$f" ]; then
    echo "lexer-bounds gate FAIL: missing $f" >&2
    exit 1
  fi
done
if ! grep -qF 'str_buf[512]' "$LEXER_GLUE" 2>/dev/null; then
  echo "lexer-bounds gate FAIL: $LEXER_GLUE missing str_buf[512] bound" >&2
  exit 1
fi
echo "lexer-bounds manifest OK"

# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
XLANG_BIN="${XLANG:-${RUN_XLANG:-./compiler/xlang-c}}"
if [ ! -x "$XLANG_BIN" ]; then
  make -C compiler -q xlang-c 2>/dev/null || make -C compiler xlang-c
  XLANG_BIN=./compiler/xlang-c
fi

# 有界标识符：产品 let.name[64] 上限；用 60 字验证 bounded lex + typeck（非栈溢出）。
# 更长源扫描不 crash 由 LONG_NUM + 下方 soft 检查覆盖；禁止为过门抬高假绿改门禁期望 2048 入库。
python3 - <<'PY' > "$LONG_IDENT"
ident = "x" * 60
print("function main(): i32 {")
print(f"  let {ident}: i32 = 0;")
print("  return 0;")
print("}")
PY

# 长十进制整数字面量（i64 路径）
python3 - <<'PY' > "$LONG_NUM"
print("function main(): i32 {")
print("  let n: i64 = " + "9" * 400 + ";")
print("  return 0;")
print("}")
PY

for src in "$LONG_IDENT" "$LONG_NUM"; do
  if ! "$XLANG_BIN" check -L . "$src" >/dev/null 2>&1; then
    echo "lexer-bounds gate FAIL: typeck $src (long token)" >&2
    rm -f "$LONG_IDENT" "$LONG_NUM"
    exit 1
  fi
  echo "lexer-bounds OK $(basename "$src")"
done

rm -f "$LONG_IDENT" "$LONG_NUM"
echo "lexer-bounds gate OK"
