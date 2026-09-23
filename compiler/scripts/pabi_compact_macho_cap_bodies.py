#!/usr/bin/env python3
"""Class BC: compact Cap/debug function bodies in Darwin leftover
runtime_pipeline_abi.o (no FORCE rebuild).

Replaces wpo_dump_* / pipeline_debug_* / asm_diag_trace_* /
pipeline_typeck_wpo_dump_callgraph bodies with an 8-byte
`mov w0,#0; ret` stub and drops the remainder of each body
(+ mid-body text relocs). Typical save ~20–35KB on tip leftover (BC dump/trace + BD w502_wpo).
PLATFORM: Darwin MH_MAGIC_64 only. Idempotent if targets already 8B.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

STUB = struct.pack("<II", 0x52800000, 0xd65f03c0)  # mov w0,#0; ret


def u32(b: bytes | bytearray, o: int) -> int:
    return struct.unpack_from("<I", b, o)[0]


def u64(b: bytes | bytearray, o: int) -> int:
    return struct.unpack_from("<Q", b, o)[0]


def want_compact(name: str) -> bool:
    if name.startswith("_wpo_dump"):
        return True
    if name.startswith("_pipeline_debug_"):
        return True
    if name.startswith("_asm_diag_trace_"):
        return True
    if name == "_pipeline_typeck_wpo_dump_callgraph":
        return True
    # Class BD: WPO dump helpers (only called from dump Cap path)
    if name.startswith("_w502_wpo_"):
        return True
    # Class BH: PGO-Lite / WPO_MONO Cap (env-gated; product L2 unset)
    if name in (
        "_pipeline_elf_write_o_pgo_to_buf",
        "_pipe_elf_pgo_emit_rela_for_sh",
        "_pipe_elf_init_shstr_pgo",
        "_pipeline_asm_emit_wpo_mono_thunks_elf_c",
        "_glue_wpo_mono_register_thunk_n",
        "_glue_wpo_mono_has_sym",
        "_glue_wpo_mono_register_thunk",
        "_glue_wpo_mono_reset_pending",
        "_platform_elf_pipeline_elf_write_o_pgo_to_buf",
    ):
        return True
    if name.startswith("_asm_wpo_mark_pgo"):
        return True
    return False


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("obj", type=Path)
    ap.add_argument("-o", "--output", type=Path, default=None)
    args = ap.parse_args()
    src = args.obj
    dst = args.output or src
    data0 = src.read_bytes()
    data = bytearray(data0)

    if u32(data, 0) != 0xFEEDFACF:
        print(f"skip: not MH_MAGIC_64", file=sys.stderr)
        return 0

    ncmds = u32(data, 16)
    sizeofcmds = u32(data, 20)
    off = 32
    sects: list[dict] = []
    seg_off = None
    symtab = None
    for _ in range(ncmds):
        cmd = u32(data, off)
        cs = u32(data, off + 4)
        if cmd == 0x19:
            seg_off = off
            nsects = u32(data, off + 64)
            so = off + 72
            for _s in range(nsects):
                name = bytes(data[so : so + 16]).split(b"\0")[0]
                sects.append(
                    dict(
                        hdr=so,
                        name=name,
                        addr=u64(data, so + 32),
                        size=u64(data, so + 40),
                        fileoff=u32(data, so + 48),
                        reloff=u32(data, so + 56),
                        nreloc=u32(data, so + 60),
                    )
                )
                so += 80
        elif cmd == 0x2:
            symoff, nsyms, stroff, strsize = struct.unpack_from("<IIII", data, off + 8)
            symtab = dict(off=off, symoff=symoff, nsyms=nsyms, stroff=stroff, strsize=strsize)
        off += cs

    if seg_off is None or symtab is None:
        print("skip: missing segment/symtab", file=sys.stderr)
        return 0

    text = next(s for s in sects if s["name"] == b"__text")
    text_sect_idx = [i + 1 for i, s in enumerate(sects) if s["name"] == b"__text"][0]
    base = text["addr"]

    blob = data[symtab["stroff"] : symtab["stroff"] + symtab["strsize"]]

    def symname(strx: int) -> str:
        end = blob.find(b"\0", strx)
        return blob[strx:end].decode("latin1")

    nlist = []
    for i in range(symtab["nsyms"]):
        o = symtab["symoff"] + i * 16
        strx, typ, sect, desc, val = struct.unpack_from("<IBBHQ", data, o)
        nlist.append(
            dict(i=i, o=o, strx=strx, typ=typ, sect=sect, desc=desc, val=val, name=symname(strx))
        )

    def is_text_def(s: dict) -> bool:
        return (s["typ"] & 0x0E) == 0x0E and s["sect"] == text_sect_idx

    text_syms = sorted([s for s in nlist if is_text_def(s)], key=lambda s: s["val"])
    ranges: list[tuple[int, int, str]] = []
    for i, s in enumerate(text_syms):
        if not want_compact(s["name"]):
            continue
        start = s["val"]
        end = text_syms[i + 1]["val"] if i + 1 < len(text_syms) else base + text["size"]
        if end - start <= len(STUB):
            continue  # already stub-sized
        ranges.append((start, end, s["name"]))
    ranges.sort()
    if not ranges:
        print("skip: no Cap bodies to compact", file=sys.stderr)
        if dst != src:
            dst.write_bytes(data0)
        return 0

    old_text = data[text["fileoff"] : text["fileoff"] + text["size"]]
    new_text = bytearray()
    old_to_new: dict[int, int] = {}
    cursor_vm = base
    end_vm = base + text["size"]
    ri = 0

    def emit_range(vm0: int, vm1: int) -> None:
        if vm1 <= vm0:
            return
        for v in range(vm0, vm1):
            old_to_new[v] = base + len(new_text) + (v - vm0)
        new_text.extend(old_text[vm0 - base : vm1 - base])

    while cursor_vm < end_vm:
        if ri < len(ranges) and cursor_vm == ranges[ri][0]:
            s, e, _n = ranges[ri]
            new_start = base + len(new_text)
            for v in range(s, e):
                old_to_new[v] = new_start
            new_text.extend(STUB)
            cursor_vm = e
            ri += 1
        else:
            nxt = ranges[ri][0] if ri < len(ranges) else end_vm
            emit_range(cursor_vm, nxt)
            cursor_vm = nxt

    saved = len(old_text) - len(new_text)
    after_text_start = text["fileoff"] + text["size"]

    # text relocs
    reloc_off = text["reloff"]
    nreloc = text["nreloc"]
    reloc_bytes = data[reloc_off : reloc_off + nreloc * 8]
    new_relocs = bytearray()
    dropped = 0
    for i in range(nreloc):
        o = i * 8
        r_addr = struct.unpack_from("<i", reloc_bytes, o)[0]
        rest = reloc_bytes[o + 4 : o + 8]
        old_vm = base + r_addr
        skip = False
        for s, e, _ in ranges:
            # Class BH: inclusive start — reloc at function entry must drop too
            if s <= old_vm < e:
                skip = True
                break
        if skip:
            dropped += 1
            continue
        nvm = old_to_new.get(old_vm)
        if nvm is None:
            dropped += 1
            continue
        new_relocs.extend(struct.pack("<i", nvm - base))
        new_relocs.extend(rest)
    reloc_shrink = nreloc * 8 - len(new_relocs)

    hdr = bytearray(data[: 32 + sizeofcmds])
    filesize = u64(hdr, seg_off + 48)
    vmsize = u64(hdr, seg_off + 32)
    struct.pack_into("<Q", hdr, text["hdr"] + 40, len(new_text))
    struct.pack_into("<Q", hdr, seg_off + 48, filesize - saved)
    struct.pack_into("<Q", hdr, seg_off + 32, vmsize - saved)

    old_reloc_end = reloc_off + nreloc * 8
    text_vm_end = text["addr"] + text["size"]
    for s in sects:
        if s["name"] == b"__text":
            continue
        fo, ro = s["fileoff"], s["reloff"]
        if fo >= old_reloc_end:
            struct.pack_into("<I", hdr, s["hdr"] + 48, fo - saved - reloc_shrink)
        elif fo >= after_text_start:
            struct.pack_into("<I", hdr, s["hdr"] + 48, fo - saved)
        if ro >= old_reloc_end:
            struct.pack_into("<I", hdr, s["hdr"] + 56, ro - saved - reloc_shrink)
        elif ro >= after_text_start:
            struct.pack_into("<I", hdr, s["hdr"] + 56, ro - saved)
        # Class BH: slide VM addr for sections after __text (single-segment .o
        # keeps __DATA/__bss after text; shrinking text without sliding addr
        # leaves __bss past segment vmsize → ld fail).
        if s["addr"] >= text_vm_end:
            struct.pack_into("<Q", hdr, s["hdr"] + 32, s["addr"] - saved)

    struct.pack_into("<I", hdr, text["hdr"] + 56, reloc_off - saved)
    struct.pack_into("<I", hdr, text["hdr"] + 60, len(new_relocs) // 8)
    struct.pack_into("<I", hdr, symtab["off"] + 8, symtab["symoff"] - saved - reloc_shrink)
    struct.pack_into("<I", hdr, symtab["off"] + 16, symtab["stroff"] - saved - reloc_shrink)

    sym_bytes = bytearray(data[symtab["symoff"] : symtab["symoff"] + symtab["nsyms"] * 16])
    for s in nlist:
        if is_text_def(s):
            nvm = old_to_new.get(s["val"])
            if nvm is None:
                raise SystemExit("unmapped sym " + s["name"])
            struct.pack_into("<Q", sym_bytes, s["i"] * 16 + 8, nvm)
        elif s["val"] >= text_vm_end and s["val"] != 0:
            # Class BH: data/bss/abs-ish addrs after shrunk text
            struct.pack_into("<Q", sym_bytes, s["i"] * 16 + 8, s["val"] - saved)

    content_start = text["fileoff"]
    pad = content_start - (32 + sizeofcmds)
    out = bytearray()
    out.extend(hdr[:32])
    out.extend(hdr[32 : 32 + sizeofcmds])
    out.extend(b"\0" * pad)
    out.extend(new_text)
    out.extend(data[after_text_start:reloc_off])
    out.extend(new_relocs)
    out.extend(data[old_reloc_end:])

    new_symoff = symtab["symoff"] - saved - reloc_shrink
    out[new_symoff : new_symoff + len(sym_bytes)] = sym_bytes

    dst.write_bytes(out)
    print(
        f"OK {src} {len(data0)} -> {len(out)} (-{len(data0) - len(out)}; "
        f"text -{saved}, reloc -{reloc_shrink}, funcs {len(ranges)}, relocs dropped {dropped}) -> {dst}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
