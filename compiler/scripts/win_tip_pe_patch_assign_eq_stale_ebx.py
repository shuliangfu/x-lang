#!/usr/bin/env python3
"""PE-patch Win tip `=` assignments emitted as C `>>=` (DIG 2026-11-10).

Root cause in parser_asm_parse_assign_x_into_c (tip-aside PE):
after the lvalue check, the body does
  mov rbx, lv; cmp ebx, 0
which clobbers the peeked token kind previously held in ebx.
The later `if (kind != TOKEN_ASSIGN)` at 0x14041f42d then does
  mov eax, 0x75; cmp ebx, eax
so it compares the lvalue flag (1 on this path) to TOKEN_ASSIGN (117).
The branch is always taken, and compound_assign_token_to_expr_kind_from_glue
is called with the correctly saved token in [rbp-0x40]. TOKEN_EQ `=` is
not in that table; the default returns EXPR_SHR_ASSIGN=38. The AST kind
is therefore already 38 at parser_asm_assign_wrap_into_c / set_kind, and
codegen emits `>>=`. Integer `b = a` still host-cc's (false-green:
`b >>= a` yields 0). Pointer `p = &a` is `invalid operands to binary >>`.
Float `x = 0.0` drops the operator (`expected ')' before numeric constant`).

The first TOKEN_ASSIGN check (@ 0x14041f349) correctly reloads ebx from
[rbp-0x40]. Only the assign_kind select omits that reload. Glue itself
is not the bug: compound `>>=` still maps via the saved kind.

Patch (1 site @ 0x14041f42d): replace
  mov eax, 0x75; cmp ebx, eax
with
  mov rbx, [rbp-0x40]; cmp ebx, 0x75
so the select uses the peeked token, not the leftover lvalue. Unique
7-byte window is preceded by `mov eax, 0x1c; mov [rbp-0x58], rax`
(assign_kind = EXPR_ASSIGN).

Idempotent. Apply after lex_tilde_token on tip-aside install.
PLATFORM: WINDOWS|X86_64 tip PE only. Soft Cap / tiphead HOLD.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

FUNC_LO = 0x14041F0B0  # parser_asm_parse_assign_x_into_c
FUNC_HI = 0x14041F6EF
SITE = 0x14041F42D
# mov eax, 0x75; cmp ebx, eax
OLD = bytes.fromhex("b87500000039c3")
# mov rbx, [rbp-0x40]; cmp ebx, 0x75
NEW = bytes.fromhex("488b5dc083fb75")
# unique context: `mov eax,0x1c; mov [rbp-0x58], rax` + site + setne/movzx/test/je +0x27
CTX_BEFORE = bytes.fromhex("b81c000000488945a8")
CTX_AFTER = bytes.fromhex("0f95c00fb6c085c00f8427000000")


def pe_meta(data: bytearray):
    import struct

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
    lo = fo_for(ib, secs, FUNC_LO)
    hi = fo_for(ib, secs, FUNC_HI)
    if not (lo <= fo < hi):
        print(f"FAIL site 0x{SITE:x} outside function window", file=sys.stderr)
        return 2
    got = bytes(data[fo : fo + 7])
    ctx = bytes(data[fo - len(CTX_BEFORE) : fo + 7 + len(CTX_AFTER)])
    if got == NEW:
        want_ctx = CTX_BEFORE + NEW + CTX_AFTER
        if ctx != want_ctx:
            print("FAIL site already NEW but unique context mismatch", file=sys.stderr)
            return 2
        print("OK already assign-eq-stale-ebx @ 0x14041f42d")
        return 0
    if got != OLD:
        print(
            f"FAIL unexpected bytes at 0x{SITE:x}: {got.hex()} (want OLD {OLD.hex()} or NEW {NEW.hex()})",
            file=sys.stderr,
        )
        return 2
    want_ctx = CTX_BEFORE + OLD + CTX_AFTER
    if ctx != want_ctx:
        print("FAIL unique context mismatch around 0x14041f42d", file=sys.stderr)
        return 2
    if dry_run:
        print("DRY-RUN would patch 1 assign-eq-stale-ebx site:")
        print("  0x14041f42d  mov eax,0x75; cmp ebx,eax  ->  mov rbx,[rbp-0x40]; cmp ebx,0x75")
        return 0
    data[fo : fo + 7] = NEW
    path.write_bytes(data)
    print(f"PATCHED 1 assign-eq-stale-ebx site @ 0x14041f42d in {path}")
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
