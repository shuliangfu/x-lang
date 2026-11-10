#!/usr/bin/env python3
"""PE-patch Win tip L011 false string-too-long (DIG 2026-11-10).

Two cooperating sites (tip-aside / live image):

1) parser_asm_primary_string_x_into_c adjacent-concat kind check @ 0x1404128f2:
   tip does `mov eax,0x82; cmp ebx,eax` but ebx is a stale pointer/temp — not the
   peeked kind stored at [rbp-0x40]. When ebx happens to equal 0x82 the loop
   keeps append-decoding further STRING tokens into the same head until L011.
   Even/odd extra function bodies change leftover ebx → intermittent M:N:N.
   Patch: `cmp dword [rbp-0x40], 0x82` + setne + nops (same 10-byte window).

2) parser_parse_body_lets_into STRING decode calls @ 0x140250f70 / 0x14025103d:
   retarget E8 from parser_string_lit_decode_span to
   parser_asm_string_lit_decode_span_x_into_c so lets-into also uses scanned
   nlen (Result+0x38 ident_len is often stale on Win tip for TOKEN_STRING).

Idempotent. Apply after lexnbi + escape on tip-aside install.
PLATFORM: WINDOWS|X86_64 tip PE only. Soft Cap / tiphead HOLD.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

# --- primary adjacent-concat kind compare ---
KIND_VA = 0x1404128F2
KIND_OLD = bytes.fromhex("b88200000039c30f95c0")  # mov eax,0x82; cmp ebx,eax; setne al
KIND_NEW = bytes.fromhex("837dc0820f95c0909090")  # cmp dword [rbp-0x40],0x82; setne al; nop*3

# --- lets-into decode retarget ---
SITE_A = 0x140250F70
SITE_B = 0x14025103D
DECODE = 0x140244DE8
X_INTO = 0x1404118E4


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


def call_rel(site: int, target: int) -> bytes:
    return b"\xe8" + struct.pack("<i", target - (site + 5))


def read_call_target(data: bytearray, ib: int, secs, site: int) -> int:
    fo = fo_for(ib, secs, site)
    if data[fo] != 0xE8:
        raise SystemExit(f"not E8 at 0x{site:x}")
    rel = struct.unpack_from("<i", data, fo + 1)[0]
    return site + 5 + rel


def patch(path: Path, dry_run: bool) -> int:
    data = bytearray(path.read_bytes())
    ib, secs = pe_meta(data)
    changed = 0

    # 1) kind compare
    fo_k = fo_for(ib, secs, KIND_VA)
    cur_k = bytes(data[fo_k : fo_k + 10])
    if cur_k == KIND_NEW:
        print(f"OK already primary kind-cmp @0x{KIND_VA:x}")
    elif cur_k != KIND_OLD:
        print(f"FAIL unexpected kind bytes @0x{fo_k:x}: {cur_k.hex()}", file=sys.stderr)
        return 2
    else:
        print(f"PATCH primary kind-cmp @0x{KIND_VA:x}: cmp ebx -> cmp [rbp-0x40]")
        if not dry_run:
            data[fo_k : fo_k + 10] = KIND_NEW
        changed += 1

    # 2) lets-into retarget
    for site in (SITE_A, SITE_B):
        cur = read_call_target(data, ib, secs, site)
        if cur == X_INTO:
            print(f"OK already x_into @0x{site:x}")
            continue
        if cur != DECODE:
            print(f"FAIL unexpected call dest @0x{site:x}: 0x{cur:x}", file=sys.stderr)
            return 3
        new = call_rel(site, X_INTO)
        fo = fo_for(ib, secs, site)
        print(f"PATCH call @0x{site:x}: decode_span -> x_into")
        if not dry_run:
            data[fo : fo + 5] = new
        changed += 1

    if dry_run:
        print(f"dry-run: would change {changed} sites")
        return 0
    if changed:
        path.write_bytes(data)
        print(f"wrote {path} ({changed} sites)")
    else:
        print("no changes")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--path",
        type=Path,
        default=Path("C:/xlang_tmp/tip_aside_hello_zero_t001/xlang.exe"),
    )
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    if not args.path.is_file():
        print(f"missing {args.path}", file=sys.stderr)
        return 1
    return patch(args.path, args.dry_run)


if __name__ == "__main__":
    raise SystemExit(main())
