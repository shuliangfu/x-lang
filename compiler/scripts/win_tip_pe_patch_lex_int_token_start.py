#!/usr/bin/env python3
"""PE-patch Win tip first-let lit-left binop P001 (DIG 2026-11-10).

Root cause in lexer_next_body_into (tip-aside PE): the is_digit block
saves `start = l.pos` at [rbp-0xda8] (0x140293909), but every
lexer_park_token_start(out, start) in that block loads the never-written
hoisted slot [rbp-0x2e0]. token_start therefore stays stack garbage (first
INT in a frame) or 0 (later). parse_body_lets_into then rebuilds the
let-init cursor from token_start to reparse `0 - 1` / `12 + i * N`; a
non-zero garbage cursor makes parse_expr_into fail and drops the function
(P001 no functions). A prior bare `let z = 0;` can leave token_start=0 so
the `next_lex.pos-1` fallback accidentally greens one-digit inits — not a
real fix (`12 + i` would rewind one byte too few).

`(0 - 1)` and `return 0 - 1` already worked: they do not use INT
token_start as the parse_expr cursor. Anonymous struct lit / ident-left
binops are unrelated.

Patch: retarget the 23 in-function `mov rax, [rbp-0x2e0]` loads to
`mov rax, [rbp-0xda8]` (same 7-byte window). Scope is lexer_next_body_into
only — the same OLD encoding appears elsewhere in the image.

Idempotent. Apply after lexnbi + escape + string_lit_l011 on tip-aside
install. PLATFORM: WINDOWS|X86_64 tip PE only. Soft Cap / tiphead HOLD.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

FUNC_LO = 0x140291CC8  # lexer_next_body_into
FUNC_HI = 0x14029ED04
# mov rax, qword ptr [rbp-0x2e0]
OLD = bytes.fromhex("488b8520fdffff")
# mov rax, qword ptr [rbp-0xda8]  (disp32 0xfffff258)
NEW = bytes.fromhex("488b8558f2ffff")
# expected unique in-function count
N_SITES = 23
# representative sites (first / hex park / decimal park) for diagnostics
SITE_FIRST = 0x140294117
SITE_HEX_PARK = 0x140294751
SITE_DEC_PARK = 0x140298C91


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


def va_of(ib: int, secs, fo: int):
    for s in secs:
        if s["rp"] <= fo < s["rp"] + s["rsz"]:
            return ib + s["va"] + (fo - s["rp"])
    return None


def iter_pattern(data: bytearray, pat: bytes, fo_lo: int, fo_hi: int):
    i = fo_lo
    while True:
        j = data.find(pat, i, fo_hi)
        if j < 0:
            return
        yield j
        i = j + 1


def patch(path: Path, dry_run: bool) -> int:
    data = bytearray(path.read_bytes())
    ib, secs = pe_meta(data)
    fo_lo = fo_for(ib, secs, FUNC_LO)
    fo_hi = fo_for(ib, secs, FUNC_HI)

    old_sites = list(iter_pattern(data, OLD, fo_lo, fo_hi))
    # The NEW encoding already occurs in later lexer_next_body_into blocks
    # (dot-float start slot). Do not require a global NEW count.

    def site_bytes(va: int) -> bytes:
        fo = fo_for(ib, secs, va)
        return bytes(data[fo : fo + 7])

    if not old_sites:
        bad = [va for va in (SITE_FIRST, SITE_HEX_PARK, SITE_DEC_PARK) if site_bytes(va) != NEW]
        if bad:
            print(
                "FAIL no OLD sites and expected VAs not already NEW: "
                + ", ".join(f"0x{va:x}" for va in bad),
                file=sys.stderr,
            )
            return 2
        print(f"OK already int-token-start {N_SITES} sites in lexer_next_body_into")
        return 0
    if len(old_sites) != N_SITES:
        print(
            f"FAIL unexpected OLD count {len(old_sites)} (want {N_SITES}) in lexer_next_body_into",
            file=sys.stderr,
        )
        return 2

    # sanity: known VAs are among the hits
    vas = [va_of(ib, secs, fo) for fo in old_sites]
    for want in (SITE_FIRST, SITE_HEX_PARK, SITE_DEC_PARK):
        if want not in vas:
            print(f"FAIL missing expected site 0x{want:x}", file=sys.stderr)
            return 2

    if dry_run:
        print(f"DRY-RUN would patch {len(old_sites)} int-token-start loads:")
        for va in vas:
            print(f"  0x{va:x}")
        return 0

    for fo in old_sites:
        data[fo : fo + 7] = NEW
    path.write_bytes(data)
    print(f"PATCHED {len(old_sites)} int-token-start loads in {path}")
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
