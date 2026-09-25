#!/usr/bin/env python3
"""
COFF: keep one EXTERNAL def of a symbol; demote other twins to STATIC.

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
STATIC (same-TU Cap callers unchanged).

w1035: pipe_modlet_bake_string_lit_elem_to_data and
pipe_modlet_bake_ptr_addr_elem_to_data (Cap earliest VA, tip inject later).

w1036: --prefer-cap-band keeps earliest VA in [0x40000, 0xf0000) so historic
low-VA stubs lose to Cap leftover (glue_type_is_fixed_array,
glue_struct_lit_store_fixed_array_field_elf_c). Tip inject (>=0xf0000) still
demoted. PLATFORM: WINDOWS — no-op on non-COFF.
"""
from __future__ import annotations

import struct
import sys
from pathlib import Path

# IMAGE_SYM_CLASS_EXTERNAL / STATIC
_EXTERNAL = 2
_STATIC = 3

# Cap leftover cluster in the tip egg (below tip elf_ctx inject ~0xf0000).
_CAP_BAND_LO = 0x40000
_CAP_BAND_HI = 0xF0000


def _sym_name(data: bytes, strtab_off: int, entry: bytes) -> str:
    name_bytes = entry[:8]
    if name_bytes[:4] == b"\x00\x00\x00\x00":
        off = struct.unpack_from("<I", name_bytes, 4)[0]
        end = data.index(b"\x00", strtab_off + off)
        return data[strtab_off + off : end].decode("ascii", errors="replace")
    return name_bytes.split(b"\x00", 1)[0].decode("ascii", errors="replace")


def _collect_external_defs(
    data: bytearray, symptr: int, nsyms: int, strtab_off: int, sym_name: str
) -> list[tuple[int, int, int]]:
    """Return (value, sym_index, file_off) for EXTERNAL defined hits."""
    hits: list[tuple[int, int, int]] = []
    i = 0
    while i < nsyms:
        off = symptr + i * 18
        entry = bytes(data[off : off + 18])
        name = _sym_name(data, strtab_off, entry)
        value, _sect, _typ, storage, naux = struct.unpack_from("<IHHBB", entry, 8)
        if name == sym_name and storage == _EXTERNAL and _sect != 0:
            hits.append((value, i, off))
        i += 1 + naux
    return hits


def _demote_except_keep(
    data: bytearray,
    path: Path,
    sym_name: str,
    hits: list[tuple[int, int, int]],
    keep_val: int,
    keep_idx: int,
) -> int:
    """Demote every hit except keep; write path; return demote count."""
    demoted = 0
    for value, idx, off in hits:
        if value == keep_val and idx == keep_idx:
            continue
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
    hits = _collect_external_defs(data, symptr, nsyms, strtab_off, sym_name)

    if len(hits) < 2:
        print(
            f"win_coff_keep_earliest_sym: {sym_name} defs={len(hits)} (noop)",
            file=sys.stderr,
        )
        return 0

    hits.sort(key=lambda t: t[0])
    keep_val, keep_idx, _keep_off = hits[0]
    return _demote_except_keep(data, path, sym_name, hits, keep_val, keep_idx)


def keep_cap_band_external(path: Path, sym_name: str) -> int:
    """
    Prefer earliest EXTERNAL def in the Cap leftover band; else plain earliest.

    Historic low-VA stubs and tip inject (>=0xf0000) are demoted when a Cap
    band twin exists. PLATFORM: WINDOWS.
    """
    data = bytearray(path.read_bytes())
    if len(data) < 20:
        return 0
    machine, _nsect, _td, symptr, nsyms, _opthdr, _chars = struct.unpack_from(
        "<HHIIIHH", data, 0
    )
    if machine != 0x8664:
        print(
            f"win_coff_keep_earliest_sym: skip non-AMD64 COFF {path}",
            file=sys.stderr,
        )
        return 0
    if symptr == 0 or nsyms == 0:
        return 0
    strtab_off = symptr + nsyms * 18
    hits = _collect_external_defs(data, symptr, nsyms, strtab_off, sym_name)

    if len(hits) < 2:
        print(
            f"win_coff_keep_earliest_sym: {sym_name} defs={len(hits)} (noop)",
            file=sys.stderr,
        )
        return 0

    hits.sort(key=lambda t: t[0])
    band = [h for h in hits if _CAP_BAND_LO <= h[0] < _CAP_BAND_HI]
    if band:
        keep_val, keep_idx, _keep_off = band[0]
        print(
            f"win_coff_keep_earliest_sym: {sym_name} prefer-cap-band "
            f"keep @{keep_val:#x} (band {len(band)}/{len(hits)})",
            file=sys.stderr,
        )
    else:
        keep_val, keep_idx, _keep_off = hits[0]
        print(
            f"win_coff_keep_earliest_sym: {sym_name} prefer-cap-band "
            f"fallback earliest @{keep_val:#x}",
            file=sys.stderr,
        )
    return _demote_except_keep(data, path, sym_name, hits, keep_val, keep_idx)


def main() -> int:
    if len(sys.argv) < 3:
        print(
            "usage: win_coff_keep_earliest_sym.py [--prefer-cap-band] "
            "<coff.o> <sym> [<sym>...]",
            file=sys.stderr,
        )
        return 2
    args = sys.argv[1:]
    prefer_cap = False
    if args and args[0] == "--prefer-cap-band":
        prefer_cap = True
        args = args[1:]
    if len(args) < 2:
        print(
            "usage: win_coff_keep_earliest_sym.py [--prefer-cap-band] "
            "<coff.o> <sym> [<sym>...]",
            file=sys.stderr,
        )
        return 2
    path = Path(args[0])
    if not path.is_file():
        print(f"win_coff_keep_earliest_sym: missing {path}", file=sys.stderr)
        return 1
    total = 0
    keep_fn = keep_cap_band_external if prefer_cap else keep_earliest_external
    for sym in args[1:]:
        total += keep_fn(path, sym)
    print(f"win_coff_keep_earliest_sym: demoted={total}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
