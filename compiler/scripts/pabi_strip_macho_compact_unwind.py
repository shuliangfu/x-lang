#!/usr/bin/env python3
"""Class BB／BD／BQ／BS／BT／BU: strip __LD,__compact_unwind (+ its relocs) from Darwin
Mach-O relocatable .o without FORCE-rebuild.

Class BS: remap nlist n_sect after section removal.
Class BT／BU: tip-link batch expands to all G05 objs with CU (ban thin_glue).
Safe batch: scripts/bq_strip_compact_unwind_safe.sh
PLATFORM: Darwin only. Idempotent if section already absent.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("obj", type=Path)
    ap.add_argument("-o", "--output", type=Path, default=None)
    args = ap.parse_args()
    src = args.obj
    dst = args.output or src
    data = bytearray(src.read_bytes())

    def u32(buf: bytearray | bytes, o: int) -> int:
        return struct.unpack_from("<I", buf, o)[0]

    def u64(buf: bytearray | bytes, o: int) -> int:
        return struct.unpack_from("<Q", buf, o)[0]

    magic = u32(data, 0)
    if magic != 0xFEEDFACF:
        print(f"skip: not MH_MAGIC_64 ({magic:#x})", file=sys.stderr)
        return 0

    ncmds = u32(data, 16)
    sizeofcmds = u32(data, 20)
    off = 32
    seg_off = None
    sects: list[dict] = []
    for _ in range(ncmds):
        cmd = u32(data, off)
        cmdsize = u32(data, off + 4)
        if cmd == 0x19:  # LC_SEGMENT_64
            seg_off = off
            nsects = u32(data, off + 64)
            so = off + 72
            for s in range(nsects):
                name = bytes(data[so : so + 16]).split(b"\0")[0]
                sects.append(
                    {
                        "hdr": so,
                        "name": name,
                        "size": u64(data, so + 40),
                        "fileoff": u32(data, so + 48),
                        "reloff": u32(data, so + 56),
                        "nreloc": u32(data, so + 60),
                    }
                )
                so += 80
        off += cmdsize

    if seg_off is None:
        print("skip: no LC_SEGMENT_64", file=sys.stderr)
        return 0

    cu_list = [s for s in sects if s["name"] == b"__compact_unwind"]
    if not cu_list:
        print("skip: no __compact_unwind", file=sys.stderr)
        if dst != src:
            dst.write_bytes(data)
        return 0
    cu = cu_list[0]

    deletes: list[tuple[int, int, str]] = []
    if cu["fileoff"] and cu["size"]:
        deletes.append((cu["fileoff"], cu["fileoff"] + cu["size"], "cu_data"))
    if cu["reloff"] and cu["nreloc"]:
        deletes.append((cu["reloff"], cu["reloff"] + cu["nreloc"] * 8, "cu_reloc"))
    deletes.sort()
    for i in range(len(deletes) - 1):
        if deletes[i][1] > deletes[i + 1][0]:
            raise SystemExit(f"overlapping deletes: {deletes}")

    def map_off(old: int) -> int | None:
        if old == 0:
            return 0
        delta = 0
        for a, b, _ in deletes:
            if old >= b:
                delta += b - a
            elif old >= a:
                return None
        return old - delta

    old_cmdsize = u32(data, seg_off + 4)
    nsects_old = u32(data, seg_off + 64)
    filesize = u64(data, seg_off + 48)

    hdr = bytearray(data[: 32 + sizeofcmds])

    def hp32(o: int, v: int) -> None:
        struct.pack_into("<I", hdr, o, v)

    def hp64(o: int, v: int) -> None:
        struct.pack_into("<Q", hdr, o, v)

    hp64(seg_off + 48, filesize - cu["size"])
    hp32(seg_off + 64, nsects_old - 1)
    hp32(seg_off + 4, old_cmdsize - 80)
    hp32(20, sizeofcmds - 80)

    new_sect_hdrs = bytearray()
    for s in sects:
        if s["name"] == b"__compact_unwind":
            continue
        raw = bytearray(data[s["hdr"] : s["hdr"] + 80])
        fo = s["fileoff"]
        if fo:
            nfo = map_off(fo)
            if nfo is None:
                raise SystemExit(f"fileoff inside delete: {s['name']}")
            struct.pack_into("<I", raw, 48, nfo)
        ro = s["reloff"]
        if ro:
            nro = map_off(ro)
            if nro is None:
                raise SystemExit(f"reloff inside delete: {s['name']}")
            struct.pack_into("<I", raw, 56, nro)
        new_sect_hdrs.extend(raw)

    other_cmds = bytearray(data[seg_off + old_cmdsize : 32 + sizeofcmds])
    pos = 0
    while pos < len(other_cmds):
        c = struct.unpack_from("<I", other_cmds, pos)[0]
        cs = struct.unpack_from("<I", other_cmds, pos + 4)[0]
        if c == 0x2:  # LC_SYMTAB
            symoff, _nsyms, stroff, _strsize = struct.unpack_from("<IIII", other_cmds, pos + 8)
            struct.pack_into("<I", other_cmds, pos + 8, map_off(symoff) or 0)
            struct.pack_into("<I", other_cmds, pos + 16, map_off(stroff) or 0)
        pos += cs

    new_seg = bytearray()
    new_seg.extend(hdr[seg_off : seg_off + 72])
    new_seg.extend(new_sect_hdrs)
    if len(new_seg) != old_cmdsize - 80:
        raise SystemExit("segment cmd size mismatch")

    new_cmds = bytearray()
    new_cmds.extend(hdr[32:seg_off])
    new_cmds.extend(new_seg)
    new_cmds.extend(other_cmds)
    if len(new_cmds) != sizeofcmds - 80:
        raise SystemExit("sizeofcmds mismatch")

    new_hdr = bytearray(hdr[:32])
    struct.pack_into("<I", new_hdr, 20, sizeofcmds - 80)

    content_start = 32 + sizeofcmds
    pad = content_start - (32 + len(new_cmds))
    if pad < 0:
        raise SystemExit("header grew unexpectedly")

    parts: list[bytes] = []
    cursor = content_start
    for a, b, _ in deletes:
        parts.append(bytes(data[cursor:a]))
        cursor = b
    parts.append(bytes(data[cursor:]))
    body = b"".join(parts)

    out = bytearray(bytes(new_hdr) + bytes(new_cmds) + (b"\0" * pad) + body)

    # Class BS: remap nlist n_sect after removing __compact_unwind.
    cu_idx = next(i + 1 for i, s in enumerate(sects) if s["name"] == b"__compact_unwind")
    pos = 0
    while pos < len(new_cmds):
        c = struct.unpack_from("<I", new_cmds, pos)[0]
        cs = struct.unpack_from("<I", new_cmds, pos + 4)[0]
        if c == 0x2:  # LC_SYMTAB
            symoff_n, nsyms_n, _, _ = struct.unpack_from("<IIII", new_cmds, pos + 8)
            for i in range(nsyms_n):
                o = symoff_n + i * 16
                strx, typ, sect, desc, val = struct.unpack_from("<IBBHQ", out, o)
                if sect == cu_idx:
                    # Local labels that lived in compact_unwind → absolute/empty.
                    typ = (typ & ~0x0E) | 0x02  # N_ABS
                    sect = 0
                elif sect > cu_idx:
                    sect -= 1
                struct.pack_into("<IBBHQ", out, o, strx, typ, sect, desc, val)
            break
        pos += cs

    dst.write_bytes(out)
    print(f"OK {src} {len(data)} -> {len(out)} (-{len(data) - len(out)}) -> {dst}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
