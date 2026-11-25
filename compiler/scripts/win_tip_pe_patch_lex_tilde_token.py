#!/usr/bin/env python3
"""PE-patch Win tip unary `~` silently dropping the current function and
all later ones (DIG 2026-11-10, pabi #405).

Root cause in the live lexer_next_punct_into path (tip-aside PE):
lexer_next_body_into calls 0x140001b00, which is `jmp 0x14047e440` into a
compact punct cave. That cave consumes one byte and dispatches
`(){};[],.=` plus a second-level `*+-/%<>` island at 0x1400dac06, then a
third-level `&|^!` island at 0x1400dc000. `^` stores TOKEN_CARET (0x67)
and `!` / `&` / `|` have compound handlers, but there is no `c==0x7e`
arm. `~` falls through the default `jmp 0x14047e54f` at 0x1400dc036 with
r9d still 0, so the token kind is 0 (the byte is already consumed).
Parse of the enclosing function aborts and every later function is
never registered — module.num_funcs stops at the last function before
the `~` (pabi: glue_arm64_stack_arg_align_pos, 1291). typeck of a later
callee then fails as silent XT001. A full punct copy at 0x140299b9c
already has `c==0x7e -> tok_with_kind(0x74)` but is not the trampoline
target.

Min repro `keep1 / let x: i32 = ~7 / keep2` exits 0 but emits only
keep1; `-7` / `nbytes & 7` still emit every function.

Patch (2 sites):
  - 0x1400dc036: retarget the unique default `jmp 0x14047e54f` to a
    19-byte stub in the 24-byte alignment-zero cave at 0x1400dbfe8
    (after the preceding string's NUL at 0x1400dbfe7; no existing
    rel32/jcc into the cave).
  - stub: `cmp al, 0x7e; jne store; mov r9d, 0x74; jmp store`
    (TOKEN_TILDE=116), matching the dead full-punct tilde arm and the
    live caret arm's store convention. Unknown punct still stores
    kind=0 as before.

Idempotent. Apply after star_type_stale_ebx on tip-aside install.
PLATFORM: WINDOWS|X86_64 tip PE only. Soft Cap / tiphead HOLD.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

# Third-level punct island (& | ^ ! / default store)
SITE = 0x1400DC036
STORE = 0x14047E54F
CAVE = 0x1400DBFE8
# jmp 0x14047e54f
OLD = bytes.fromhex("e914253a00")
# jmp 0x1400dbfe8
NEW = bytes.fromhex("e9adffffff")
# unique context: `cmp al,0x21; jne +5; jmp bang_handler` + site + `ff ff ff; jmp +0x2d8`
CTX_BEFORE = bytes.fromhex("3c217505e94d000000")
CTX_AFTER = bytes.fromhex("ffffffe9d8020000")
# alignment zeros after string NUL @ 0x1400dbfe7 (24 bytes of slack)
CAVE_LEN = 19
CAVE_OLD = b"\x00" * CAVE_LEN
# cmp al,0x7e; jne STORE; mov r9d,0x74; jmp STORE
CAVE_NEW = (
    bytes.fromhex("3c7e")
    + b"\x0f\x85"
    + struct.pack("<i", STORE - (CAVE + 2 + 6))
    + bytes.fromhex("41b974000000")
    + b"\xe9"
    + struct.pack("<i", STORE - (CAVE + 2 + 6 + 6 + 5))
)


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
    fo_cave = fo_for(ib, secs, CAVE)
    got = bytes(data[fo : fo + 5])
    cave_got = bytes(data[fo_cave : fo_cave + CAVE_LEN])
    ctx = bytes(data[fo - len(CTX_BEFORE) : fo + 5 + len(CTX_AFTER)])
    already = got == NEW and cave_got == CAVE_NEW
    if already:
        want_ctx = CTX_BEFORE + NEW + CTX_AFTER
        if ctx != want_ctx:
            print("FAIL site already NEW but unique context mismatch", file=sys.stderr)
            return 2
        print("OK already lex-tilde-token @ 0x1400dc036 + cave 0x1400dbfe8")
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
        print("FAIL unique context mismatch around 0x1400dc036", file=sys.stderr)
        return 2
    if cave_got != CAVE_OLD:
        print(
            f"FAIL unexpected cave bytes at 0x{CAVE:x}: {cave_got.hex()} "
            f"(want zeros or stub {CAVE_NEW.hex()})",
            file=sys.stderr,
        )
        return 2
    if dry_run:
        print("DRY-RUN would patch 1 lex-tilde-token default-jmp + 19-byte cave stub:")
        print("  0x1400dc036  jmp 0x14047e54f  ->  jmp 0x1400dbfe8")
        print("  0x1400dbfe8  cmp al,0x7e; jne store; mov r9d,0x74; jmp store")
        return 0
    data[fo : fo + 5] = NEW
    data[fo_cave : fo_cave + CAVE_LEN] = CAVE_NEW
    path.write_bytes(data)
    print(f"PATCHED 1 lex-tilde-token site + cave stub @ 0x1400dc036 / 0x1400dbfe8 in {path}")
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
