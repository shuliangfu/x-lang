#!/usr/bin/env python3
"""ELF64 executable: retarget callq in call_args that hit one_call_arg _prev → soft T.
10.22 Linux: objcopy --redefine-sym on backend_call_dispatch.o patches in-object
call sites to _prev, so soft glue_emit_one_call_arg_elf_c never runs. After
pure-ld, rewrite those PC-relative calls to the soft symbol. PLATFORM: LINUX.
Usage: g05_elf_retarget_call_arg_prev_product.py <xlang-product>
"""
from __future__ import annotations

import struct
import subprocess
import sys
from pathlib import Path


def nm_addrs(path: Path) -> dict[str, int]:
    out = subprocess.check_output(["nm", str(path)], text=True, stderr=subprocess.DEVNULL)
    addrs: dict[str, int] = {}
    for line in out.splitlines():
        parts = line.split()
        if len(parts) < 3:
            continue
        try:
            addr = int(parts[0], 16)
        except ValueError:
            continue
        addrs[parts[2]] = addr
    return addrs


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: g05_elf_retarget_call_arg_prev_product.py <product>", file=sys.stderr)
        return 2
    path = Path(sys.argv[1])
    data = bytearray(path.read_bytes())
    if data[:4] != b"\x7fELF" or data[4] != 2:
        print("not ELF64", file=sys.stderr)
        return 1
    addrs = nm_addrs(path)
    soft = addrs.get("glue_emit_one_call_arg_elf_c")
    prev = addrs.get("glue_emit_one_call_arg_elf_c_prev")
    call_args = addrs.get("glue_emit_call_args_elf_sysv_f32_xmm_c")
    if soft is None or prev is None or call_args is None:
        print(
            "g05_elf_retarget_call_arg_prev_product: skip (need soft+_prev+call_args)",
            file=sys.stderr,
        )
        return 0
    # Approximate call_args span: until _prev (usually next) or +0x3000
    end = prev if prev > call_args else call_args + 0x3000
    e_phoff = struct.unpack_from("<Q", data, 32)[0]
    e_phentsize = struct.unpack_from("<H", data, 54)[0]
    e_phnum = struct.unpack_from("<H", data, 56)[0]
    loads: list[tuple[int, int, int]] = []
    for i in range(e_phnum):
        off = e_phoff + i * e_phentsize
        p_type, _f, p_offset, p_vaddr, _p, p_filesz, _m, _a = struct.unpack_from(
            "<IIQQQQQQ", data, off
        )
        if p_type == 1:
            loads.append((p_vaddr, p_offset, p_filesz))

    def vma_to_off(vma: int) -> int | None:
        for v, o, sz in loads:
            if v <= vma < v + sz:
                return o + (vma - v)
        return None

    patched = 0
    vma = call_args
    while vma < end - 5:
        foff = vma_to_off(vma)
        if foff is None:
            break
        if data[foff] == 0xE8:
            rel = int.from_bytes(data[foff + 1 : foff + 5], "little", signed=True)
            tgt = vma + 5 + rel
            if tgt == prev:
                new_rel = soft - (vma + 5)
                data[foff + 1 : foff + 5] = (new_rel & 0xFFFFFFFF).to_bytes(4, "little")
                patched += 1
                vma += 5
                continue
        vma += 1
    if patched:
        path.write_bytes(data)
    print(
        f"g05_elf_retarget_call_arg_prev_product: {path.name} "
        f"soft={soft:#x} prev={prev:#x} patched={patched}",
        file=sys.stderr,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
