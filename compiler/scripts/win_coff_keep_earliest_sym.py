#!/usr/bin/env python3
"""
COFF: keep one EXTERNAL def of a symbol; demote other twins to STATIC.

Root (w1031): Windows tip egg runtime_pipeline_abi.o embeds two strong T for
pipeline_elf_ctx_append_reloc (leftover Cap cluster + historic tip elf_ctx
inject). Same-TU REL32 already calls the earliest body. PE first-wins +
win_patch earliest→later forced the tip twin. Demoting later EXTERNAL→STATIC
leaves a single exported T at the Cap leftover (matches Ubuntu W authority /
HARD BAN on whole-thin PREFER).

w1034–w1036: typed/absolute64/bake + Cap-band for fixed_array stubs.

w1037: --demote-all-dual scans the egg for every symbol with ≥2 EXTERNAL
defs and applies Cap-band keep (historic low-VA stub + tip inject ≥0xf0000
demoted). Replaces whack-a-mole symbol lists. PLATFORM: WINDOWS — no-op on
non-COFF.
"""
from __future__ import annotations

import struct
import sys
from collections import defaultdict
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


def _load_coff(path: Path) -> tuple[bytearray, int, int, int] | None:
    """Return (data, symptr, nsyms, strtab_off) or None if not AMD64 COFF."""
    data = bytearray(path.read_bytes())
    if len(data) < 20:
        return None
    machine, _nsect, _td, symptr, nsyms, _opthdr, _chars = struct.unpack_from(
        "<HHIIIHH", data, 0
    )
    if machine != 0x8664:
        print(
            f"win_coff_keep_earliest_sym: skip non-AMD64 COFF {path}",
            file=sys.stderr,
        )
        return None
    if symptr == 0 or nsyms == 0:
        return None
    return data, symptr, nsyms, symptr + nsyms * 18


def _collect_all_external_defs(
    data: bytearray, symptr: int, nsyms: int, strtab_off: int
) -> dict[str, list[tuple[int, int, int]]]:
    """Map sym_name → [(value, sym_index, file_off), ...] for EXTERNAL defs."""
    d: dict[str, list[tuple[int, int, int]]] = defaultdict(list)
    i = 0
    while i < nsyms:
        off = symptr + i * 18
        entry = bytes(data[off : off + 18])
        name = _sym_name(data, strtab_off, entry)
        value, _sect, _typ, storage, naux = struct.unpack_from("<IHHBB", entry, 8)
        if storage == _EXTERNAL and _sect != 0:
            d[name].append((value, i, off))
        i += 1 + naux
    return d


def _pick_keep(
    hits: list[tuple[int, int, int]], prefer_cap_band: bool
) -> tuple[int, int]:
    """Return (keep_val, keep_idx). Hits must be non-empty."""
    hits_sorted = sorted(hits, key=lambda t: t[0])
    if prefer_cap_band:
        band = [h for h in hits_sorted if _CAP_BAND_LO <= h[0] < _CAP_BAND_HI]
        if band:
            return band[0][0], band[0][1]
    return hits_sorted[0][0], hits_sorted[0][1]


def _apply_demotes(
    data: bytearray,
    hits: list[tuple[int, int, int]],
    keep_val: int,
    keep_idx: int,
    sym_name: str,
    verbose: bool,
) -> int:
    """Demote non-keep hits in-place; return count."""
    demoted = 0
    for value, idx, off in hits:
        if value == keep_val and idx == keep_idx:
            continue
        data[off + 16] = _STATIC
        demoted += 1
        if verbose:
            print(
                f"win_coff_keep_earliest_sym: {sym_name} demote "
                f"sym[{idx}]@{value:#x} EXTERNAL->STATIC "
                f"(keep @{keep_val:#x} sym[{keep_idx}])",
                file=sys.stderr,
            )
    return demoted


def keep_earliest_external(path: Path, sym_name: str) -> int:
    """Demote every EXTERNAL def except the lowest Value."""
    loaded = _load_coff(path)
    if loaded is None:
        return 0
    data, symptr, nsyms, strtab_off = loaded
    all_defs = _collect_all_external_defs(data, symptr, nsyms, strtab_off)
    hits = all_defs.get(sym_name, [])
    if len(hits) < 2:
        print(
            f"win_coff_keep_earliest_sym: {sym_name} defs={len(hits)} (noop)",
            file=sys.stderr,
        )
        return 0
    keep_val, keep_idx = _pick_keep(hits, prefer_cap_band=False)
    demoted = _apply_demotes(data, hits, keep_val, keep_idx, sym_name, True)
    path.write_bytes(data)
    return demoted


def keep_cap_band_external(path: Path, sym_name: str) -> int:
    """Prefer earliest EXTERNAL def in the Cap leftover band; else earliest."""
    loaded = _load_coff(path)
    if loaded is None:
        return 0
    data, symptr, nsyms, strtab_off = loaded
    all_defs = _collect_all_external_defs(data, symptr, nsyms, strtab_off)
    hits = all_defs.get(sym_name, [])
    if len(hits) < 2:
        print(
            f"win_coff_keep_earliest_sym: {sym_name} defs={len(hits)} (noop)",
            file=sys.stderr,
        )
        return 0
    keep_val, keep_idx = _pick_keep(hits, prefer_cap_band=True)
    print(
        f"win_coff_keep_earliest_sym: {sym_name} prefer-cap-band "
        f"keep @{keep_val:#x}",
        file=sys.stderr,
    )
    demoted = _apply_demotes(data, hits, keep_val, keep_idx, sym_name, True)
    path.write_bytes(data)
    return demoted


def demote_all_dual_external(path: Path) -> tuple[int, int]:
    """
    Cap-band demote every symbol with ≥2 EXTERNAL defs in one pass.

    Returns (symbols_touched, defs_demoted).
    """
    loaded = _load_coff(path)
    if loaded is None:
        return 0, 0
    data, symptr, nsyms, strtab_off = loaded
    all_defs = _collect_all_external_defs(data, symptr, nsyms, strtab_off)
    touched = 0
    demoted_total = 0
    for sym_name, hits in sorted(all_defs.items()):
        if len(hits) < 2:
            continue
        keep_val, keep_idx = _pick_keep(hits, prefer_cap_band=True)
        n = _apply_demotes(data, hits, keep_val, keep_idx, sym_name, False)
        if n:
            touched += 1
            demoted_total += n
    path.write_bytes(data)
    print(
        f"win_coff_keep_earliest_sym: demote-all-dual "
        f"symbols={touched} demoted={demoted_total}",
        file=sys.stderr,
    )
    return touched, demoted_total


def main() -> int:
    usage = (
        "usage: win_coff_keep_earliest_sym.py "
        "(--demote-all-dual <coff.o> | [--prefer-cap-band] <coff.o> <sym>...)"
    )
    if len(sys.argv) < 3:
        print(usage, file=sys.stderr)
        return 2
    args = sys.argv[1:]
    if args[0] == "--demote-all-dual":
        if len(args) != 2:
            print(usage, file=sys.stderr)
            return 2
        path = Path(args[1])
        if not path.is_file():
            print(f"win_coff_keep_earliest_sym: missing {path}", file=sys.stderr)
            return 1
        demote_all_dual_external(path)
        return 0

    prefer_cap = False
    if args[0] == "--prefer-cap-band":
        prefer_cap = True
        args = args[1:]
    if len(args) < 2:
        print(usage, file=sys.stderr)
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
