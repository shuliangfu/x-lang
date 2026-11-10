#!/usr/bin/env python3
"""PE-patch Win tip host for L010 false reject of product escapes (DIG 2026-11-10).

Root cause in lexer_next_body_into (tip-aside PE): after reading the byte
following `\\`, tip stores it to [rbp-0xb68] but the wave281 escape checks
compare [rbp-0x158]. The stale slot never matches n/t/r/0/\\/" / x → sticky
L010 on every product-valid escape. Mac tip is fine; Win tip PE only.

Patch: retarget the single store mov [rbp-0xb68],rax → mov [rbp-0x158],rax
at preferred VA 0x14029264c (inside lexer_next_body_into).

Idempotent. Pair with win_tip_pe_patch_lexnbi_large_src.py after L4 tip-aside
install. PLATFORM: WINDOWS|X86_64 tip PE only.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

# mov QWORD PTR [rbp-0xb68], rax
STORE_OLD = bytes.fromhex("48898598f4ffff")
# mov QWORD PTR [rbp-0x158], rax
STORE_NEW = bytes.fromhex("488985a8feffff")
STORE_VA = 0x14029264C


def fo_for(data: bytearray, va: int) -> int:
    e_lfanew = struct.unpack_from("<I", data, 0x3C)[0]
    num_sections = struct.unpack_from("<H", data, e_lfanew + 6)[0]
    opt_size = struct.unpack_from("<H", data, e_lfanew + 20)[0]
    opt_off = e_lfanew + 24
    image_base = struct.unpack_from("<Q", data, opt_off + 24)[0]
    sec_off = opt_off + opt_size
    rva = va - image_base
    for i in range(num_sections):
        off = sec_off + i * 40
        vsize, vaddr, rawsize, rawptr = struct.unpack_from("<IIII", data, off + 8)
        if vaddr <= rva < vaddr + max(vsize, rawsize):
            return rawptr + (rva - vaddr)
    raise SystemExit(f"VA 0x{va:x} not in any section")


def patch(path: Path, dry_run: bool) -> int:
    data = bytearray(path.read_bytes())
    fo = fo_for(data, STORE_VA)
    cur = bytes(data[fo : fo + 7])
    if cur == STORE_NEW:
        print(f"OK already escape-store slot @0x{fo:x}")
        return 0
    if cur != STORE_OLD:
        print(f"FAIL unexpected bytes at 0x{fo:x}: {cur.hex()}", file=sys.stderr)
        # fallback: search unique OLD pattern once in .text
        idx = data.find(STORE_OLD)
        if idx < 0 or data.find(STORE_OLD, idx + 1) >= 0:
            return 2
        print(f"FALLBACK unique OLD at file 0x{idx:x}")
        fo = idx
        cur = STORE_OLD
    print(f"PATCH escape-store [rbp-0xb68]→[rbp-0x158] @0x{fo:x} ({cur.hex()} → {STORE_NEW.hex()})")
    if not dry_run:
        data[fo : fo + 7] = STORE_NEW
        path.write_bytes(data)
        print(f"wrote {path}")
    else:
        print("dry-run: no write")
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
