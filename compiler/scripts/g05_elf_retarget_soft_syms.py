#!/usr/bin/env python3
"""ELF64 MH_OBJECT retarget: demote defined megas, point call-site relocs at U soft names.
PLATFORM: LINUX tip soft (UFCS). Args: <in.o> <out.o> mega=orig [mega=orig ...]
After objcopy --redefine-sym orig=mega on in.o, this adds U orig symbols and retargets
relocs that still name mega so soft T orig wins at pure-ld; mega stays for soft fallback.
"""
from __future__ import annotations

import struct
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) < 4:
        print(
            "usage: g05_elf_retarget_soft_syms.py <in.o> <out.o> mega=orig [...]",
            file=sys.stderr,
        )
        return 2
    inp = Path(sys.argv[1])
    outp = Path(sys.argv[2])
    mega_to_orig: dict[bytes, bytes] = {}
    for pair in sys.argv[3:]:
        if "=" not in pair:
            print(f"bad pair {pair}", file=sys.stderr)
            return 2
        mega_s, orig_s = pair.split("=", 1)
        mega_to_orig[mega_s.encode()] = orig_s.encode()

    data = bytearray(inp.read_bytes())
    if data[:4] != b"\x7fELF" or data[4] != 2:
        print("not ELF64", file=sys.stderr)
        return 1

    e_shoff = struct.unpack_from("<Q", data, 40)[0]
    e_shentsize = struct.unpack_from("<H", data, 58)[0]
    e_shnum = struct.unpack_from("<H", data, 60)[0]

    def shdr(i: int) -> dict:
        off = e_shoff + i * e_shentsize
        return {
            "off": off,
            "type": struct.unpack_from("<I", data, off + 4)[0],
            "offset": struct.unpack_from("<Q", data, off + 24)[0],
            "size": struct.unpack_from("<Q", data, off + 32)[0],
            "link": struct.unpack_from("<I", data, off + 40)[0],
            "entsize": struct.unpack_from("<Q", data, off + 56)[0],
        }

    sections = [shdr(i) for i in range(e_shnum)]
    try:
        symtab_i = next(i for i, s in enumerate(sections) if s["type"] == 2)
    except StopIteration:
        print("no symtab", file=sys.stderr)
        return 1
    symtab = sections[symtab_i]
    strtab = sections[symtab["link"]]
    strdata = bytes(data[strtab["offset"] : strtab["offset"] + strtab["size"]])
    entsz = symtab["entsize"] or 24
    nsyms = symtab["size"] // entsz

    mega_def_idx: dict[bytes, int] = {}
    for i in range(nsyms):
        so = symtab["offset"] + i * entsz
        st_name, _st_info, _st_other, st_shndx, _st_value, _st_size = struct.unpack_from(
            "<IBBHQQ", data, so
        )
        nm = strdata[st_name : strdata.find(b"\0", st_name)]
        if nm in mega_to_orig and st_shndx != 0:
            mega_def_idx[nm] = i
    if len(mega_def_idx) != len(mega_to_orig):
        missing = set(mega_to_orig) - set(mega_def_idx)
        print(f"missing mega defs: {sorted(x.decode() for x in missing)}", file=sys.stderr)
        return 1

    strtab_bytes = bytearray(strdata)
    new_syms: list[bytes] = []
    orig_u_idx: dict[bytes, int] = {}
    for mega, orig in mega_to_orig.items():
        strx = len(strtab_bytes)
        strtab_bytes.extend(orig + b"\0")
        new_idx = nsyms + len(new_syms)
        # STB_GLOBAL | STT_NOTYPE
        new_syms.append(struct.pack("<IBBHQQ", strx, 0x10, 0, 0, 0, 0))
        orig_u_idx[mega] = new_idx

    rela_patches = 0
    for s in sections:
        if s["type"] != 4 or s["link"] != symtab_i:
            continue
        ents = s["entsize"] or 24
        for j in range(s["size"] // ents):
            ro = s["offset"] + j * ents
            r_info = struct.unpack_from("<Q", data, ro + 8)[0]
            r_sym = r_info >> 32
            r_type = r_info & 0xFFFFFFFF
            for mega, midx in mega_def_idx.items():
                if r_sym == midx:
                    struct.pack_into(
                        "<Q", data, ro + 8, (orig_u_idx[mega] << 32) | r_type
                    )
                    rela_patches += 1
                    break

    sym_blob = bytes(data[symtab["offset"] : symtab["offset"] + symtab["size"]])
    new_str_off = len(data)
    data.extend(strtab_bytes)
    new_sym_off = len(data)
    data.extend(sym_blob)
    for ns in new_syms:
        data.extend(ns)
    new_sym_size = len(sym_blob) + 24 * len(new_syms)
    struct.pack_into("<Q", data, strtab["off"] + 24, new_str_off)
    struct.pack_into("<Q", data, strtab["off"] + 32, len(strtab_bytes))
    struct.pack_into("<Q", data, symtab["off"] + 24, new_sym_off)
    struct.pack_into("<Q", data, symtab["off"] + 32, new_sym_size)
    outp.write_bytes(data)
    print(
        f"g05_elf_retarget_soft_syms: {outp.name} megas={len(mega_def_idx)} "
        f"rela={rela_patches}",
        file=sys.stderr,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
