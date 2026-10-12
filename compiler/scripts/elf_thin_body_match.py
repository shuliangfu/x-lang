#!/usr/bin/env python3
"""Return 0 when a relocatable thin is already the live text in an ELF base.

Usage: elf_thin_body_match.py BASE.o THIN.o

PIPELINE_ABI inject merges with the thin first. On Linux, ld -r keeps the
weakened base bytes, so a second merge of an identical pure-asm thin prepends
another copy and the linked image .text grows. This predicate is the skip
gate for that merge. It is true only when every global function or object in
the thin's executable PROGBITS is already present in the same-named section
of the base, with the same bytes and the same relocations (offset within the
symbol, type, addend, symbol name).

Extent is st_size when it is non-zero. Otherwise it is the distance to the
next global in the THIN section, or the section end. The base's next-symbol
gap is not used: that gap includes the unsymbolized leftover hole.

A missing symbol, a length mismatch, a non-ELF file, or a parse error exits
1 so the caller merges as before. Darwin Mach-O and Windows COFF take that
path. PLATFORM: LINUX ELF64 little-endian. Callers on other hosts are
unchanged.
"""
import struct
import sys


def cstr(data, off):
    end = data.index(b"\x00", off)
    return data[off:end].decode("latin-1")


def parse(path):
    with open(path, "rb") as fh:
        data = fh.read()
    if len(data) < 64 or data[:4] != b"\x7fELF" or data[4] != 2 or data[5] != 1:
        return None
    e_shoff = struct.unpack_from("<Q", data, 0x28)[0]
    e_shentsize, e_shnum, e_shstrndx = struct.unpack_from("<HHH", data, 0x3A)
    if e_shentsize < 64 or e_shnum == 0 or e_shstrndx >= e_shnum:
        return None
    secs = []
    for i in range(e_shnum):
        off = e_shoff + i * e_shentsize
        if off + 64 > len(data):
            return None
        (sh_name, sh_type, sh_flags, sh_addr, sh_offset, sh_size,
         sh_link, sh_info, sh_addralign, sh_entsize) = struct.unpack_from(
            "<IIQQQQIIQQ", data, off)
        secs.append({
            "name_off": sh_name,
            "type": sh_type,
            "flags": sh_flags,
            "off": sh_offset,
            "size": sh_size,
            "link": sh_link,
            "info": sh_info,
            "entsize": sh_entsize,
        })
    if secs[e_shstrndx]["off"] + secs[e_shstrndx]["size"] > len(data):
        return None
    shstr = secs[e_shstrndx]["off"]
    for sec in secs:
        sec["name"] = cstr(data, shstr + sec["name_off"])
    symtabs = [s for s in secs if s["type"] == 2]
    if len(symtabs) != 1:
        return None
    symtab = symtabs[0]
    if symtab["link"] >= len(secs):
        return None
    strtab = secs[symtab["link"]]
    ent = symtab["entsize"] or 24
    if ent < 24 or symtab["off"] + symtab["size"] > len(data):
        return None
    syms = []
    for i in range(symtab["size"] // ent):
        o = symtab["off"] + i * ent
        st_name, st_info, st_other, st_shndx, st_value, st_size = struct.unpack_from(
            "<IBBHQQ", data, o)
        syms.append({
            "name": cstr(data, strtab["off"] + st_name),
            "shndx": st_shndx,
            "value": st_value,
            "size": st_size,
            "bind": st_info >> 4,
            "typ": st_info & 0xF,
        })
    rels = []
    for sec in secs:
        if sec["type"] not in (4, 9) or sec["entsize"] == 0:
            continue
        es = sec["entsize"]
        if sec["off"] + sec["size"] > len(data):
            return None
        for k in range(sec["size"] // es):
            o = sec["off"] + k * es
            if es >= 24:
                r_off, r_info, r_add = struct.unpack_from("<QQq", data, o)
            else:
                r_off, r_info = struct.unpack_from("<QQ", data, o)
                r_add = 0
            rels.append({
                "target": sec["info"],
                "off": r_off,
                "sym": r_info >> 32,
                "typ": r_info & 0xFFFFFFFF,
                "add": r_add,
            })
    return data, secs, syms, rels


def is_exec_progbits(sec):
    if sec["type"] != 1:
        return False
    name = sec["name"]
    if name == ".text" or name.startswith(".text."):
        return True
    # SHF_ALLOC | SHF_EXECINSTR. A pure-asm .text with those flags and a
    # non-standard name still counts.
    return (sec["flags"] & 6) == 6


def globals_in(syms, shndx):
    out = []
    for sym in syms:
        if sym["shndx"] != shndx or not sym["name"]:
            continue
        if sym["bind"] not in (1, 2) or sym["typ"] not in (1, 2):
            continue
        out.append(sym)
    out.sort(key=lambda s: (s["value"], s["name"]))
    return out


def span_end(funcs, index, sec_size):
    sym = funcs[index]
    if sym["size"] > 0:
        return sym["value"] + sym["size"]
    if index + 1 < len(funcs):
        return funcs[index + 1]["value"]
    return sec_size


def reloc_keys(rels, syms, base, length):
    keys = []
    for rel in rels:
        if rel["off"] < base or rel["off"] >= base + length:
            continue
        if rel["sym"] >= len(syms):
            return None
        keys.append((
            rel["off"] - base,
            rel["typ"],
            rel["add"],
            syms[rel["sym"]]["name"],
        ))
    keys.sort()
    return keys


def bodies_match(base_path, thin_path):
    base = parse(base_path)
    thin = parse(thin_path)
    if base is None or thin is None:
        return False
    bdata, bsecs, bsyms, brels = base
    tdata, tsecs, tsyms, trels = thin
    by_name = {}
    for i, sec in enumerate(bsecs):
        if is_exec_progbits(sec) and sec["name"] not in by_name:
            by_name[sec["name"]] = i
    checked = 0
    for ti, tsec in enumerate(tsecs):
        if not is_exec_progbits(tsec):
            continue
        bi = by_name.get(tsec["name"])
        if bi is None:
            return False
        bsec = bsecs[bi]
        if tsec["off"] + tsec["size"] > len(tdata) or bsec["off"] + bsec["size"] > len(bdata):
            return False
        ttext = tdata[tsec["off"]:tsec["off"] + tsec["size"]]
        btext = bdata[bsec["off"]:bsec["off"] + bsec["size"]]
        tfuncs = globals_in(tsyms, ti)
        bfuncs = globals_in(bsyms, bi)
        seen = {}
        for sym in bfuncs:
            if sym["name"] not in seen:
                seen[sym["name"]] = sym
        names = {}
        for sym in tfuncs:
            if sym["name"] in names:
                return False
            names[sym["name"]] = True
        trel = [r for r in trels if r["target"] == ti]
        brel = [r for r in brels if r["target"] == bi]
        for i, sym in enumerate(tfuncs):
            end = span_end(tfuncs, i, tsec["size"])
            start = sym["value"]
            if end <= start or end > tsec["size"]:
                return False
            length = end - start
            live = seen.get(sym["name"])
            if live is None:
                return False
            if live["value"] + length > bsec["size"]:
                return False
            if ttext[start:end] != btext[live["value"]:live["value"] + length]:
                return False
            tk = reloc_keys(trel, tsyms, start, length)
            bk = reloc_keys(brel, bsyms, live["value"], length)
            if tk is None or bk is None or tk != bk:
                return False
            checked += 1
    return checked > 0


def main(argv):
    if len(argv) != 3:
        return 1
    try:
        ok = bodies_match(argv[1], argv[2])
    except (OSError, ValueError, IndexError, struct.error):
        return 1
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
