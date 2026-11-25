#!/usr/bin/env python3
"""PE-patch Win tip lexer_next_buf_into_tip park-prefer (DIG 2026-11-10).

compile.x is -E green (67 funcs, typeck OK) but -backend asm -c fails
IMP001 with a smashed path `src/typeck/n/ .x`. The import *key* is the
3-byte slice `n. `. That is not a missing -L, and it is not the landed
fixed_array_let_init 7th-arg slot.

Trace (no product-source change):
  collect of compile.x records `const ast = import("ast")` correctly.
  Dep prerun then xlang_module_collect_imports_from_buf(ast.x, 39221).
  parser_asm_collect_imports_into_c sees a perfect CONST/IDENT/ASSIGN/
  IMPORT/LPAREN/STRING/RPAREN/SEMI stream whose token_start values are
  the compile.x offsets (IDENT 898, STRING 912), but
  parser_asm_lex_source_data_c returns the ast.x buffer. Copying 3
  bytes at 912 in ast.x yields `n. ` (the tail of `implementation. `).
  Resolve then writes `src/typeck/n/ .x` and IMP001s.

Cause: lexer_next_buf_into_tip (0x14029f420), called from the dual-ABI
thunk lexer_next_buf_into (0x140001a10), reads g_lex_src_data_fix /
g_lex_src_len_fix and, when the park is set, *overwrites* the caller's
data/len. The main compile.x parse parks that file. Dep collect of
ast.x still prefers the parked compile.x bytes. This is not the 7th-arg
SysV [rbp+0x10] template, and not the bake_array or fixed_array knives.

Patch: force the park-non-null flag to 0 so the overwrite is skipped
and the provided (data,len) are used.
  0x14029f4dc  0f95c0 -> 30c090    setne al  ->  xor al,al; nop

Idempotent. Refuse mixed.

PLATFORM: WINDOWS|X86_64 tip PE only. Soft Cap / tiphead HOLD.
L4 apply order: after fixed_array_let_init_stack_arg_off.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

FUNC_LO = 0x14029F420
# cmp park vs 0, then the setne we rewrite
CTX_BEFORE = bytes.fromhex("488b5da8b8000000004839c3")
SITE = 0x14029F4DC
OLD = bytes.fromhex("0f95c00fb6c085c00f8415000000")
NEW = bytes.fromhex("30c0900fb6c085c00f8415000000")


def pe_meta(data: bytearray):
    e = struct.unpack_from("<I", data, 0x3C)[0]
    ns = struct.unpack_from("<H", data, e + 6)[0]
    osize = struct.unpack_from("<H", data, e + 20)[0]
    ib = struct.unpack_from("<Q", data, e + 24 + 24)[0]
    so = e + 24 + osize
    secs = []
    for i in range(ns):
        o = so + i * 40
        vs, va, rs, rp = struct.unpack_from("<IIII", data, o + 8)
        secs.append({"va": va, "vsz": vs, "rsz": rs, "rp": rp})
    return ib, secs


def fo_for(ib: int, secs, va: int) -> int:
    rva = va - ib
    for s in secs:
        if s["va"] <= rva < s["va"] + max(s["vsz"], s["rsz"]):
            return s["rp"] + (rva - s["va"])
    raise SystemExit(f"VA 0x{va:x} not mapped")


def patch(path: Path, dry_run: bool) -> int:
    data = bytearray(path.read_bytes())
    ib, secs = pe_meta(data)
    site_fo = fo_for(ib, secs, SITE)
    before = bytes(data[site_fo - len(CTX_BEFORE) : site_fo])
    if before != CTX_BEFORE:
        print("FAIL CTX_BEFORE mismatch at lexer_buf_into park-prefer", file=sys.stderr)
        return 2
    cur = bytes(data[site_fo : site_fo + len(OLD)])
    if cur == NEW:
        print(f"OK already lexer_buf_into skip park-prefer in {path}")
        return 0
    if cur != OLD:
        print(f"FAIL mixed/unexpected at 0x{SITE:x}: {cur.hex()}", file=sys.stderr)
        return 2
    if dry_run:
        print(f"DRY-RUN would patch 0x{SITE:x} setne al -> xor al,al (skip park prefer)")
        return 0
    data[site_fo : site_fo + len(NEW)] = NEW
    path.write_bytes(data)
    print(f"PATCHED lexer_buf_into skip park-prefer in {path}")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("pe")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    return patch(Path(args.pe), args.dry_run)


if __name__ == "__main__":
    sys.exit(main())
