#!/usr/bin/env python3
"""
COFF: keep the earliest-VA EXTERNAL def of a symbol; demote later twins to STATIC.

Root (w1031): Windows tip egg runtime_pipeline_abi.o embeds two strong T for
pipeline_elf_ctx_append_reloc (leftover Cap cluster + historic tip elf_ctx
inject). Same-TU REL32 already calls the earliest body. PE first-wins +
win_patch earliest→later forced the tip twin. Demoting later EXTERNAL→STATIC
leaves a single exported T at the Cap leftover (matches Ubuntu W authority /
HARD BAN on whole-thin PREFER).

w1034: same egg dual/triple T for append_reloc_typed and
append_reloc_absolute64. typed Cap twin stays EXTERNAL then g05 weakens it
when the wave743 sidecar is present (sidecar first-wins PAGE21 owner bind).
absolute64 earliest is a historic EXTERNAL-reloc stub; Cap/tip twins become
STATIC (same-TU Cap callers unchanged). PLATFORM: WINDOWS — no-op on non-COFF.
"""
from __future__ import annotations

import struct
import sys
from pathlib import Path

# IMAGE_SYM_CLASS_EXTERNAL / STATIC
_EXTERNAL = 2
_STATIC = 3


def _sym_name(data: bytes, strtab_off: int, entry: bytes) -> str:
    name_bytes = entry[:8]
    if name_bytes[:4] == b"\x00\x00\x00\x00":
        off = struct.unpack_from("<I", name_bytes, 4)[0]
        end = data.index(b"\x00", strtab_off + off)
        return data[strtab_off + off : end].decode("ascii", errors="replace")
    return name_bytes.split(b"\x00", 1)[0].decode("ascii", errors="replace")


def keep_earliest_external(path: Path, sym_name: str) -> int:
    """
    Demote every EXTERNAL def of sym_name except the lowest Value to STATIC.
    Returns how many symbols were demoted.
    """
    data = bytearray(path.read_bytes())
    if len(data) < 20:
        return 0
    machine, _nsect, _td, symptr, nsyms, _opthdr, _chars = struct.unpack_from(
        "<HHIIIHH", data, 0
    )
    # IMAGE_FILE_MACHINE_AMD64
    if machine != 0x8664:
        print(
            f"win_coff_keep_earliest_sym: skip non-AMD64 COFF {path}",
            file=sys.stderr,
        )
        return 0
    if symptr == 0 or nsyms == 0:
        return 0
    strtab_off = symptr + nsyms * 18

    hits: list[tuple[int, int, int]] = []  # (value, sym_index, file_off)
    i = 0
    while i < nsyms:
        off = symptr + i * 18
        entry = bytes(data[off : off + 18])
        name = _sym_name(data, strtab_off, entry)
        value, _sect, _typ, storage, naux = struct.unpack_from("<IHHBB", entry, 8)
        if name == sym_name and storage == _EXTERNAL and _sect != 0:
            # Defined in a section (not UNDEF).
            hits.append((value, i, off))
        i += 1 + naux

    if len(hits) < 2:
        print(
            f"win_coff_keep_earliest_sym: {sym_name} defs={len(hits)} (noop)",
            file=sys.stderr,
        )
        return 0

    hits.sort(key=lambda t: t[0])
    keep_val, keep_idx, _keep_off = hits[0]
    demoted = 0
    for value, idx, off in hits[1:]:
        # Storage class is at offset 16 within the 18-byte symbol record.
        data[off + 16] = _STATIC
        demoted += 1
        print(
            f"win_coff_keep_earliest_sym: {sym_name} demote "
            f"sym[{idx}]@{value:#x} EXTERNAL->STATIC "
            f"(keep @{keep_val:#x} sym[{keep_idx}])",
            file=sys.stderr,
        )
    path.write_bytes(data)
    return demoted


def main() -> int:
    if len(sys.argv) < 3:
        print(
            "usage: win_coff_keep_earliest_sym.py <coff.o> <sym> [<sym>...]",
            file=sys.stderr,
        )
        return 2
    path = Path(sys.argv[1])
    if not path.is_file():
        print(f"win_coff_keep_earliest_sym: missing {path}", file=sys.stderr)
        return 1
    total = 0
    for sym in sys.argv[2:]:
        total += keep_earliest_external(path, sym)
    print(f"win_coff_keep_earliest_sym: demoted={total}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
