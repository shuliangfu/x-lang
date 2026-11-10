#!/usr/bin/env python3
"""PE-patch Win tip if-stmt else-if recurse 7th Win64 arg (DIG 2026-11-10).

Root cause in parser_asm_parse_if_stmt_x_into_c: the self-recursive call
that parses `else if (...)` passes 7 arguments (arena, lex, source,
type_ref, &ncond, &nthen, &nelse) but the tip emit only wrote the 5th
and 6th Win64 stack slots. &nelse was pushed into the 32-byte shadow
space (and a dummy 0 was pushed first) instead of [rsp+0x30]. The
inner call still parsed a following `else` / `else if` and advanced
the cursor, but wrote out_else through a stale 7th slot, so
pipeline_block_append_if received nelse=0. The AST kept only `if` plus
the first `else if`; later arms were dropped. Compile still succeeded
because the leftover source had already been consumed.

That is why tip 7a87 compiled product lexer.x skip_whitespace_and_comments
as a short 0x5b0 body (whitespace + `//` only). Official
win_tip_p001_face_pe_patch then refused lexer_skip_whitespace_and_comments
+0x727 — those bytes sit in skip_ws_buf (`push rax; mov rax,[rbp-0x10];
mov rax,[rax]; ...`), not a blkdepth store. The script was right to
refuse; the missing P001 nest was this parser 7th-slot bug, not a new
tip-shape store to poke.

Patch (1 site @ parser_asm_parse_if_stmt_x_into_c+0x74e):
  mov eax,0; push rax; lea rax,[rbp-0xa8]; push rax
    -> lea rax,[rbp-0xa8]; push rax; push rax; mov [rsp+0x30], rax
Keeps the same 16-byte stack adjust used by the later [rsp+0x20]/
[rsp+0x28] stores, and writes &nelse into the 7th Win64 slot.

Unique 14-byte window plus the preceding `mov [rbp-0xa8], rax` (zero
nelse) and the following `mov rax, [rbp-0x10]` (arena). Idempotent.
Proven on a copy of tip 7a87 (live image not written by the dig):
  if / else, if / else-if unchanged; if / else-if / else and a 4-arm
  chain emit every return; lexer.x skip_ws grows 0x5b0 -> 0x146c and
  stores/loads [rbp-0x40] with `/*` / `#` immediates.

L4 apply order: after append_struct_lit_field_rebase.
PLATFORM: WINDOWS|X86_64 tip PE only. Soft Cap / tiphead HOLD.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

FUNC = 0x140425C94  # parser_asm_parse_if_stmt_x_into_c
SITE = 0x1404263E2  # +0x74E
FUNC_HI = 0x140426824
# mov eax,0; push rax; lea rax,[rbp-0xa8]; push rax
OLD = bytes.fromhex("b80000000050488d8558ffffff50")
# lea rax,[rbp-0xa8]; push rax; push rax; mov [rsp+0x30], rax
NEW = bytes.fromhex("488d8558ffffff50504889442430")
# preceding: mov QWORD PTR [rbp-0xa8], rax  (zero nelse)
CTX_BEFORE = bytes.fromhex("48898558ffffff")
# following: mov rax, QWORD PTR [rbp-0x10]  (arena)
CTX_AFTER = bytes.fromhex("488b45f0")


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
    fo = fo_for(ib, secs, SITE)
    lo = fo_for(ib, secs, FUNC)
    hi = fo_for(ib, secs, FUNC_HI)
    if not (lo <= fo < hi):
        print(f"FAIL site 0x{SITE:x} outside function window", file=sys.stderr)
        return 2
    n = len(OLD)
    got = bytes(data[fo : fo + n])
    ctx = bytes(data[fo - len(CTX_BEFORE) : fo + n + len(CTX_AFTER)])
    if got == NEW:
        want_ctx = CTX_BEFORE + NEW + CTX_AFTER
        if ctx != want_ctx:
            print("FAIL site already NEW but unique context mismatch", file=sys.stderr)
            return 2
        print("OK already if-stmt-elseif-7th-slot @ 0x1404263e2")
        return 0
    if got != OLD:
        print(
            f"FAIL unexpected bytes at 0x{SITE:x}: {got.hex()} "
            f"(want OLD {OLD.hex()} or NEW {NEW.hex()})",
            file=sys.stderr,
        )
        return 2
    want_ctx = CTX_BEFORE + OLD + CTX_AFTER
    if ctx != want_ctx:
        print("FAIL unique context mismatch around 0x1404263e2", file=sys.stderr)
        return 2
    if dry_run:
        print("DRY-RUN would patch 1 if-stmt-elseif-7th-slot site:")
        print(
            "  0x1404263e2  push 0 / push &nelse  ->  "
            "lea &nelse; push; push; mov [rsp+0x30], rax"
        )
        return 0
    data[fo : fo + n] = NEW
    path.write_bytes(data)
    print(f"PATCHED 1 if-stmt-elseif-7th-slot site @ 0x1404263e2 in {path}")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("exe", type=Path)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    if not args.exe.is_file():
        print(f"FAIL missing {args.exe}", file=sys.stderr)
        return 2
    return patch(args.exe, args.dry_run)


if __name__ == "__main__":
    sys.exit(main())
