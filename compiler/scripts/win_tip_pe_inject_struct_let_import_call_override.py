#!/usr/bin/env python3
"""PLATFORM: WINDOWS tip PE only — win_tip_l2_product_matrix_5_5 / import-call-to-let.

Inject host-gcc glue_emit_struct_type_let_init_elf_c override into .c76sli and
JMP tip stub @0x14011ab20 onto live.

Root: host leftover CALL/METHOD let-init returns -1 before emit
(CG002 code_len≈19 for `let x = import.fn()`). Soft Cap Prefer same red.
tip.x Mac greens via emit+store. Soft Cap body copy banned.

Pre: tip PE with store_retval slot_off patch (fe82d4a49235… / bak_pre_import_let).
Obj: seeds/win_tip_pe_overrides/struct_type_let_init_import_call_override.c
     gcc -c -O2 -o override.o that.c

Tip symbol VAs are fingerprint-mapped from Soft Cap Prefer nm (tip PE stripped).
"""
from __future__ import annotations

import argparse
import hashlib
import struct
import subprocess
import sys
from pathlib import Path

STUB = 0x14011AB20  # glue_emit_struct_type_let_init_elf_c host leftover
SEC_NAME = b".c76sli\x00"
SEC_CHARS = 0x60000020

# Fingerprint-mapped tip PE VAs (fe82 lineage; Soft Cap Prefer nm + body match).
TIP_SYMS = {
    "pipeline_expr_kind_ord_at": 0x140212958,
    "pipeline_asm_emit_expr_elf_c": 0x14027626A,
    "backend_enc_store_rax_to_rbp_arch": 0x14052967C,
    "pipeline_asm_emit_struct_let_init_elf_c": 0x1402C9EFF,
    "glue_emit_module_from_ctx": 0x140294753,
    "glue_store_retval_pair_to_rbp_elf_c": 0x14012AE98,
}


def pe_sections(data: bytes):
    e_lfanew = struct.unpack_from("<I", data, 0x3C)[0]
    num_sec = struct.unpack_from("<H", data, e_lfanew + 6)[0]
    opt_size = struct.unpack_from("<H", data, e_lfanew + 20)[0]
    img_base = struct.unpack_from("<Q", data, e_lfanew + 24 + 24)[0]
    sec_off = e_lfanew + 24 + opt_size
    secs = []
    for i in range(num_sec):
        o = sec_off + i * 40
        name = data[o : o + 8].split(b"\0")[0].decode(errors="replace")
        vsz, va, rsz, ro = struct.unpack_from("<IIII", data, o + 8)
        secs.append({"name": name, "va": va, "vsz": vsz, "ro": ro, "rsz": rsz})
    return e_lfanew, img_base, secs, sec_off, num_sec, opt_size


def va_to_off(img_base: int, secs, va: int) -> int:
    rva = va - img_base
    for s in secs:
        if s["va"] <= rva < s["va"] + max(s["vsz"], s["rsz"]):
            return s["ro"] + (rva - s["va"])
    raise ValueError(f"VA {va:#x} not in sections")


def align_up(v: int, a: int) -> int:
    return (v + a - 1) & ~(a - 1)


def load_obj_nm(obj: Path) -> dict[str, int]:
    out = subprocess.check_output(["nm", str(obj)], text=True, errors="replace")
    syms: dict[str, int] = {}
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[1] in ("T", "t") and all(
            c in "0123456789abcdefABCDEF" for c in parts[0]
        ):
            syms[parts[2]] = int(parts[0], 16)
    return syms


def read_obj_text_relocs(obj_path: Path):
    text = subprocess.check_output(
        ["objdump", "-s", "-j", ".text", str(obj_path)], text=True, errors="replace"
    )
    blob = bytearray()
    for line in text.splitlines():
        line = line.strip()
        if (
            not line
            or "Contents" in line
            or line.startswith(".text")
            or "file format" in line
            or line.endswith(".o:")
        ):
            continue
        parts = line.split()
        if not parts:
            continue
        try:
            off = int(parts[0], 16)
        except ValueError:
            continue
        hexbytes: list[int] = []
        for p in parts[1:]:
            if len(p) == 8 and all(c in "0123456789abcdefABCDEF" for c in p):
                for i in range(0, 8, 2):
                    hexbytes.append(int(p[i : i + 2], 16))
            else:
                break
        while len(blob) < off:
            blob.append(0)
        blob[off : off + len(hexbytes)] = bytes(hexbytes)
    rel_out = subprocess.check_output(
        ["objdump", "-r", "-j", ".text", str(obj_path)], text=True, errors="replace"
    )
    relocs: list[tuple[int, str]] = []
    for line in rel_out.splitlines():
        line = line.strip()
        if "IMAGE_REL_AMD64_REL32" not in line:
            continue
        parts = line.split()
        relocs.append((int(parts[0], 16), parts[2]))
    return bytes(blob), relocs


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("exe")
    ap.add_argument("obj")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    exe = Path(args.exe)
    obj = Path(args.obj)
    obj_syms = load_obj_nm(obj)
    live = obj_syms.get("glue_emit_struct_type_let_init_elf_c")
    if live is None:
        print("obj missing glue_emit_struct_type_let_init_elf_c", file=sys.stderr)
        return 2
    text, relocs = read_obj_text_relocs(obj)
    data = bytearray(exe.read_bytes())
    e_lfanew, img_base, secs, sec_off, num_sec, opt_size = pe_sections(data)
    sect_align = struct.unpack_from("<I", data, e_lfanew + 24 + 32)[0]
    file_align = struct.unpack_from("<I", data, e_lfanew + 24 + 36)[0]
    size_of_image_off = e_lfanew + 24 + 56
    size_of_image = struct.unpack_from("<I", data, size_of_image_off)[0]
    if any(s["name"].startswith(".c76sli") for s in secs):
        print("refuse: .c76sli already present", file=sys.stderr)
        return 2
    stub_off = va_to_off(img_base, secs, STUB)
    cur = bytes(data[stub_off : stub_off + 7])
    expect_pro = bytes.fromhex("554889e553b8a8")
    if not cur.startswith(expect_pro[:6]) and cur[0] != 0xE9:
        print(f"refuse: unexpected stub bytes {cur.hex()}", file=sys.stderr)
        return 2
    last = max(secs, key=lambda s: s["va"] + max(s["vsz"], s["rsz"]))
    new_va = align_up(last["va"] + max(last["vsz"], last["rsz"]), sect_align)
    raw_size = align_up(len(text), file_align)
    new_ro = align_up(len(data), file_align)
    place_va = img_base + new_va
    buf = bytearray(text)
    for off, sym in relocs:
        if sym not in TIP_SYMS:
            print(f"missing tip VA for {sym}", file=sys.stderr)
            return 2
        P = place_va + off + 4
        addend = struct.unpack_from("<i", buf, off)[0]
        struct.pack_into("<i", buf, off, TIP_SYMS[sym] + addend - P)
    if args.dry_run:
        print(f"dry-run ok place={place_va:#x} live+{live:#x} stub={STUB:#x}")
        return 0
    if len(data) < new_ro:
        data.extend(b"\x00" * (new_ro - len(data)))
    payload = bytes(buf) + b"\x00" * (raw_size - len(buf))
    data.extend(payload)
    hdr = sec_off + num_sec * 40
    if hdr + 40 > secs[0]["ro"]:
        print("no room for section header", file=sys.stderr)
        return 2
    data[hdr : hdr + 8] = SEC_NAME
    struct.pack_into("<IIII", data, hdr + 8, len(text), new_va, raw_size, new_ro)
    struct.pack_into("<II", data, hdr + 24, 0, 0)
    struct.pack_into("<HH", data, hdr + 32, 0, 0)
    struct.pack_into("<I", data, hdr + 36, SEC_CHARS)
    struct.pack_into("<H", data, e_lfanew + 6, num_sec + 1)
    new_soi = align_up(max(size_of_image, new_va + max(len(text), raw_size)), sect_align)
    struct.pack_into("<I", data, size_of_image_off, new_soi)
    e_lfanew, img_base, secs, _, _, _ = pe_sections(data)
    stub_off = va_to_off(img_base, secs, STUB)
    target = place_va + live
    data[stub_off] = 0xE9
    struct.pack_into("<i", data, stub_off + 1, target - (STUB + 5))
    data[stub_off + 5 : stub_off + 8] = b"\x90\x90\x90"
    exe.write_bytes(data)
    print(f"JMP {STUB:#x} -> {target:#x}")
    print("sha16", hashlib.sha256(data).hexdigest()[:16])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
