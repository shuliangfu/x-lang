#!/usr/bin/env bash
# P1-3：Lexer 有界输入门禁 — 超长标识符/数字须 bounded scan，不栈溢出。
#
# 约定：标识符/数字扫描以源码 end 为界（不拷贝 ident）；TOKEN_STRING 解码缓冲 512 字节（lexer.c str_buf）。
# 用法：./tests/run-lexer-bounds-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/安全与性能.md"
MANIFEST="tests/baseline/lexer-bounds.tsv"
LONG_IDENT="/tmp/shux_lexer_long_ident_$$.x"
LONG_NUM="/tmp/shux_lexer_long_num_$$.x"

echo "=== P1-3: lexer bounds manifest ==="
for f in "$DOC" "$MANIFEST" compiler/src/lexer/lexer.c; do
  if [ ! -f "$f" ]; then
    echo "lexer-bounds gate FAIL: missing $f" >&2
    exit 1
  fi
done
if ! grep -qF 'str_buf[512]' compiler/src/lexer/lexer.c 2>/dev/null; then
  echo "lexer-bounds gate FAIL: lexer.c missing str_buf[512] bound" >&2
  exit 1
fi
echo "lexer-bounds manifest OK"

# shellcheck source=tests/lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
SHUX_BIN="${SHUX:-${RUN_SHUX:-./compiler/shux-c}}"
if [ ! -x "$SHUX_BIN" ]; then
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  SHUX_BIN=./compiler/shux-c
fi

# 2048 字节标识符（函数体内 local let）：须 bounded lex + typeck 通过（>4KiB 当前 parser 受限）
python3 - <<'PY' > "$LONG_IDENT"
ident = "x" * 2048
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
  if ! "$SHUX_BIN" check -L . "$src" >/dev/null 2>&1; then
    echo "lexer-bounds gate FAIL: typeck $src (long token)" >&2
    rm -f "$LONG_IDENT" "$LONG_NUM"
    exit 1
  fi
  echo "lexer-bounds OK $(basename "$src")"
done

rm -f "$LONG_IDENT" "$LONG_NUM"
echo "lexer-bounds gate OK"
