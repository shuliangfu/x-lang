#!/usr/bin/env python3
"""PE-patch Win tip host for large-source -E SEGV (DIG 2026-11-10).

Two sites (tip-aside / live_shift image):
1) lexer_next_buf_into trampoline: replace r9>=0x10000 discriminant with
   rdx==r8 (Type A both &Lex). Large Type B len was misread as data ptr.
2) lexer_next_buf_into_tip: retarget call lexer_next_into → lexer_next_impl
   so by-value tip path skips the into dual-ABI cave (rdx>=0x10000 mis-fires
   once lex.pos >= 64KiB).

Idempotent. Does not touch product unless --path given.
PLATFORM: WINDOWS|X86_64 tip PE only.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

BUF_OLD = bytes.fromhex("4981f90000010072094d89ca4c635d30eb064d89c24d63d9")
BUF_NEW = bytes.fromhex("4c39c2750d909090904d89ca4c635d30eb064d89c24d63d9")
# tip call at preferred VA 0x14029f62d
TIP_CALL_VA = 0x14029F62D
TIP_CALL_OLD = bytes.fromhex("e8ae25d6ff")  # call lexer_next_into
TIP_CALL_NEW = bytes.fromhex("e8b2f8ffff")  # call lexer_next_impl
BUF_VA = 0x140001A18


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
    changes = 0
    fo = fo_for(data, BUF_VA)
    cur = bytes(data[fo : fo + 24])
    if cur == BUF_NEW:
        print(f"OK already buf_into discriminant @0x{fo:x}")
    elif cur == BUF_OLD:
        print(f"PATCH buf_into discriminant @0x{fo:x}")
        if not dry_run:
            data[fo : fo + 24] = BUF_NEW
        changes += 1
    else:
        print(f"FAIL unexpected buf_into bytes {cur.hex()}", file=sys.stderr)
        return 2

    fo2 = fo_for(data, TIP_CALL_VA)
    cur2 = bytes(data[fo2 : fo2 + 5])
    if cur2 == TIP_CALL_NEW:
        print(f"OK already tip→impl call @0x{fo2:x}")
    elif cur2 == TIP_CALL_OLD:
        print(f"PATCH tip→impl call @0x{fo2:x}")
        if not dry_run:
            data[fo2 : fo2 + 5] = TIP_CALL_NEW
        changes += 1
    else:
        # Maybe tip layout shifted — still report
        print(f"FAIL unexpected tip call bytes {cur2.hex()}", file=sys.stderr)
        return 2

    if changes and not dry_run:
        path.write_bytes(data)
        print(f"wrote {path} ({changes} sites)")
    elif dry_run:
        print(f"dry-run: would change {changes} sites")
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
