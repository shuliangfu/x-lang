#!/usr/bin/env python3
"""
审计 k_asm_parser_thin_delegate 表：su/c 名长度、parser.su 是否存在对应 function。
用法：python3 compiler/scripts/audit_parser_thin_delegate.py
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
AST_POOL = ROOT / "compiler/ast_pool.c"
PARSER_SU = ROOT / "compiler/src/parser/parser.su"


def main() -> int:
    ast = AST_POOL.read_text()
    parser = PARSER_SU.read_text()
    start = ast.find("k_asm_parser_thin_delegate")
    if start < 0:
        print("k_asm_parser_thin_delegate not found", file=sys.stderr)
        return 1
    block = ast[start : start + 20000]
    entries = re.findall(r'\{"(\w+)", (\d+), "(\w+)", (\d+)\}', block)
    funcs = set(re.findall(r"(?m)^(?:extern\s+)?function\s+(\w+)\s*\(", parser))
    bad = 0
    for su, sl, cg, cl in entries:
        if int(sl) != len(su):
            print(f"BAD su_len: {su} table={sl} actual={len(su)}")
            bad += 1
        if int(cl) != len(cg):
            print(f"BAD c_len: {cg} table={cl} actual={len(cg)}")
            bad += 1
        if su not in funcs:
            print(f"MISSING func: {su}")
            bad += 1
    print(f"entries={len(entries)} bad={bad}")
    return 1 if bad else 0


if __name__ == "__main__":
    raise SystemExit(main())
