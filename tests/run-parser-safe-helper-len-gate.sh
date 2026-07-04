#!/usr/bin/env bash
# 校验 ast_pool.c 中 parser EMIT_HEAVY safe_helper / thin_delegate 的 x_len 与符号名长度一致。
# x_len 偏差会导致 PARSER_SAFE_EQ 永不命中，slice *_buf 包装无法真 emit、combined 指标虚低。
# 用法：./tests/run-parser-safe-helper-len-gate.sh
set -e
cd "$(dirname "$0")/.."
AST_POOL="compiler/ast_pool.c"
if [ ! -f "$AST_POOL" ]; then
  echo "parser-safe-helper-len-gate: SKIP (no $AST_POOL)"
  exit 0
fi
python3 - "$AST_POOL" <<'PY'
import re, sys
path = sys.argv[1]
text = open(path, encoding="utf-8").read()
fail = 0

def check_block(label, blob, pattern):
    global fail
    for m in re.finditer(pattern, blob):
        name, ln = m.group(1), int(m.group(2))
        if len(name) != ln:
            print(f"parser-safe-helper-len-gate FAIL: {label} {name!r} x_len={ln} expected={len(name)}")
            fail += 1

safe = text.split("static int32_t asm_parser_emit_heavy_safe_helper", 1)
if len(safe) > 1:
    block = safe[1].split("#undef PARSER_SAFE_EQ", 1)[0]
    check_block("PARSER_SAFE_EQ", block, r'PARSER_SAFE_EQ\("([^"]+)",\s*(\d+)\)')

td = text.split("k_asm_parser_thin_delegate[]", 1)
if len(td) > 1:
    block = td[1].split("};", 1)[0]
    check_block("thin_delegate", block, r'\{"([^"]+)",\s*(\d+),')

if fail:
    sys.exit(1)
print("parser-safe-helper-len-gate OK")
PY
