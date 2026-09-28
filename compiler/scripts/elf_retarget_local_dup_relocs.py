#!/usr/bin/env python3
"""Retarget relocations off localized duplicate function symbols.

Usage: elf_retarget_local_dup_relocs.py OBJ NAME [NAME ...]

Some Linux pipeline_abi objects were merged with a C rest whose weak
twins (for example pipeline_asm_modlet_prepare_and_emit_elf_c) became
LOCAL copies next to the GLOBAL .x definition of the same name. Calls
inside the rest still point at the local copy, so the rest writes one
modlet table while the global load/find read another. Module-let access
then fails with CG002 (code_len=12, 0 patches).

For each NAME that has exactly one GLOBAL defined FUNC symbol, every
relocation whose symbol is a LOCAL FUNC of the same NAME is rewritten to
use the GLOBAL symbol. Addends are unchanged. The file is edited in
place. Prints one line per NAME with the number of rewritten entries.
Exit status 0 when the file is valid ELF64 little-endian.

Windows pabi_weak.o has the same split (static C-rest copies next to the
external .x faces). x86-64 COFF, regular or bigobj, is handled the same
way: a relocation on an IMAGE_SYM_CLASS_STATIC function symbol of NAME is
moved to the single IMAGE_SYM_CLASS_EXTERNAL defined symbol of NAME.

PLATFORM: LINUX x86_64 (ELF64) · WINDOWS x86_64 (COFF). Darwin unused.
"""
import struct
import sys


def main(argv):
    if len(argv) < 3:
        sys.stderr.write("usage: elf_retarget_local_dup_relocs.py OBJ NAME...\n")
        return 2
    path = argv[1]
    names = set(argv[2:])
    with open(path, "rb") as f:
        data = bytearray(f.read())
    if data[:4] != b"\x7fELF":
        return coff_main(path, data, names)
    if data[4] != 2 or data[5] != 1:
        sys.stderr.write("not ELF64 LE: %s\n" % path)
        return 1
    e_shoff = struct.unpack_from("<Q", data, 0x28)[0]
    e_shentsize, e_shnum, e_shstrndx = struct.unpack_from("<HHH", data, 0x3A)
    secs = []
    for i in range(e_shnum):
        off = e_shoff + i * e_shentsize
        (sh_name, sh_type, sh_flags, sh_addr, sh_offset, sh_size,
         sh_link, sh_info, sh_addralign, sh_entsize) = struct.unpack_from(
            "<IIQQQQIIQQ", data, off)
        secs.append((sh_type, sh_offset, sh_size, sh_link, sh_entsize))
    symtab = [i for i, s in enumerate(secs) if s[0] == 2]
    if len(symtab) != 1:
        sys.stderr.write("need one SHT_SYMTAB\n")
        return 1
    st = symtab[0]
    _, st_off, st_size, st_link, st_ent = secs[st]
    str_off = secs[st_link][1]

    def cstr(o):
        e = data.index(b"\x00", o)
        return data[o:e].decode("latin-1")

    nsym = st_size // st_ent
    local_idx = {}
    global_idx = {}
    for i in range(nsym):
        o = st_off + i * st_ent
        st_name, st_info, st_other, st_shndx = struct.unpack_from("<IBBH", data, o)
        if st_shndx == 0:
            continue
        typ = st_info & 0xF
        bind = st_info >> 4
        if typ != 2:
            continue
        nm = cstr(str_off + st_name)
        if nm not in names:
            continue
        if bind == 0:
            local_idx.setdefault(nm, set()).add(i)
        elif bind in (1, 2):
            global_idx.setdefault(nm, []).append(i)
    remap = {}
    for nm in names:
        g = global_idx.get(nm, [])
        if len(g) != 1:
            continue
        for li in local_idx.get(nm, ()):
            remap[li] = g[0]
    counts = dict((nm, 0) for nm in names)
    idx_name = {}
    for nm in names:
        for li in local_idx.get(nm, ()):
            idx_name[li] = nm
    for sh_type, sh_offset, sh_size, sh_link, sh_entsize in secs:
        if sh_type not in (4, 9) or sh_link != st or sh_entsize == 0:
            continue
        for k in range(sh_size // sh_entsize):
            o = sh_offset + k * sh_entsize
            r_info = struct.unpack_from("<Q", data, o + 8)[0]
            sym = r_info >> 32
            if sym in remap:
                struct.pack_into("<Q", data, o + 8, (remap[sym] << 32) | (r_info & 0xFFFFFFFF))
                counts[idx_name[sym]] += 1
    with open(path, "wb") as f:
        f.write(data)
    for nm in sorted(names):
        print("retarget %s %d" % (nm, counts[nm]))
    return 0


def coff_main(path, data, names):
    big = struct.unpack_from("<HH", data, 0) == (0, 0xFFFF)
    if big:
        machine = struct.unpack_from("<H", data, 6)[0]
        nsec, sym_ptr, nsym = struct.unpack_from("<III", data, 44)
        sec_off = 56
        sym_sz = 20
    else:
        machine, nsec = struct.unpack_from("<HH", data, 0)
        sym_ptr, nsym = struct.unpack_from("<II", data, 8)
        opt = struct.unpack_from("<H", data, 16)[0]
        sec_off = 20 + opt
        sym_sz = 18
    if machine != 0x8664:
        sys.stderr.write("not ELF64 or x86-64 COFF: %s\n" % path)
        return 1
    str_base = sym_ptr + nsym * sym_sz

    def sym_name(o):
        if struct.unpack_from("<I", data, o)[0] == 0:
            so = str_base + struct.unpack_from("<I", data, o + 4)[0]
            e = data.index(b"\x00", so)
            return data[so:e].decode("latin-1")
        return bytes(data[o:o + 8]).rstrip(b"\x00").decode("latin-1")

    static_idx = {}
    extern_idx = {}
    i = 0
    while i < nsym:
        o = sym_ptr + i * sym_sz
        if big:
            secno, typ, cls, naux = struct.unpack_from("<iHBB", data, o + 12)
        else:
            secno, typ, cls, naux = struct.unpack_from("<hHBB", data, o + 12)
        if secno > 0 and (typ & 0x30) == 0x20:
            nm = sym_name(o)
            if nm in names:
                if cls == 3:
                    static_idx.setdefault(nm, set()).add(i)
                elif cls == 2:
                    extern_idx.setdefault(nm, []).append(i)
        i += 1 + naux
    remap = {}
    idx_name = {}
    for nm in names:
        g = extern_idx.get(nm, [])
        if len(g) != 1:
            continue
        for li in static_idx.get(nm, ()):
            remap[li] = g[0]
            idx_name[li] = nm
    counts = dict((nm, 0) for nm in names)
    for k in range(nsec):
        so = sec_off + k * 40
        rptr = struct.unpack_from("<I", data, so + 24)[0]
        nrel = struct.unpack_from("<H", data, so + 32)[0]
        chars = struct.unpack_from("<I", data, so + 36)[0]
        first = 0
        if (chars & 0x01000000) and nrel == 0xFFFF:
            nrel = struct.unpack_from("<I", data, rptr)[0]
            first = 1
        for r in range(first, nrel):
            ro = rptr + r * 10
            sym = struct.unpack_from("<I", data, ro + 4)[0]
            if sym in remap:
                struct.pack_into("<I", data, ro + 4, remap[sym])
                counts[idx_name[sym]] += 1
    with open(path, "wb") as f:
        f.write(data)
    for nm in sorted(names):
        print("retarget %s %d" % (nm, counts[nm]))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
