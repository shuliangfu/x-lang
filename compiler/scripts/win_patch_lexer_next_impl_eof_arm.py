#!/usr/bin/env python3
"""Redirect typool lexer_next_impl pos>=len EOF arm to host-cc thin.

typool lexer_next_impl (first-wins and leftover faces) builds TOKEN_EOF at
local -0xe0 but then copies the wrong slot -0x70 into write_tok (s279 UNIQUE;
form typool typool-same as runtime_pipeline_abi_lexer_emit_eof_token_thin.c).
This patch does not replace lexer_next_impl. It overwrites only the pos>=len
arm start with: rcx=out (-0x10(%rbp)), call lexer_emit_eof_token, jmp epilogue.

The thin must already be linked (symbol lexer_emit_eof_token). Idempotent.
Refuses compiler/xlang_asm.exe. Soft Cap / tiphead HOLD. PLATFORM: WINDOWS.
"""
from __future__ import annotations

import argparse
import struct
import subprocess
import sys
from pathlib import Path

# lea -0xe0(%rbp),%rax; mov %rax,%rbx; push %rbx; mov $0,%eax
ARM_START = bytes.fromhex("488d8520ffffff4889c353b800000000")
LEA_70 = bytes.fromhex("488d4590")  # lea -0x70(%rbp),%rax  (wrong slot)
# typool huge-frame epilogue
EPILOGUE = bytes.fromhex("488d65f85b5dc3")  # lea -8(%rbp),%rsp; pop rbx; pop rbp; ret
# already-patched: mov -0x10(%rbp),%rcx; sub $0x20,%rsp; call rel32
PATCHED_PFX = bytes.fromhex("488b4df04883ec20e8")


def pe_va_to_off(data: bytes, va: int) -> tuple[int, int]:
    e_lfanew = struct.unpack_from("<I", data, 0x3C)[0]
    coff = e_lfanew + 4
    nsec = struct.unpack_from("<H", data, coff + 2)[0]
    optsz = struct.unpack_from("<H", data, coff + 16)[0]
    magic = struct.unpack_from("<H", data, coff + 20)[0]
    if magic == 0x20B:
        image_base = struct.unpack_from("<Q", data, coff + 20 + 24)[0]
    else:
        image_base = struct.unpack_from("<I", data, coff + 20 + 28)[0]
    sec_off = coff + 20 + optsz
    rva = va - image_base
    for i in range(nsec):
        o = sec_off + i * 40
        vsz, va_s, rawsz, rawptr = struct.unpack_from("<IIII", data, o + 8)
        if va_s <= rva < va_s + max(vsz, rawsz):
            return rawptr + (rva - va_s), image_base
    raise SystemExit(f"win_patch_lexer_next_impl_eof_arm: VA 0x{va:x} not mapped")


def is_asm_product(path: Path) -> bool:
    parts = [p.lower() for p in path.resolve().parts]
    return path.name.lower() == "xlang_asm.exe" and "compiler" in parts


def nm_text_addrs(exe: Path, name: str) -> list[int]:
    out = subprocess.check_output(["nm", str(exe)], text=True, errors="replace")
    addrs: list[int] = []
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 3 and parts[-1] == name and parts[1] in "TtWw":
            addrs.append(int(parts[0], 16))
    addrs.sort()
    return addrs


def preceded_by_test_je(body: bytes, i: int) -> bool:
    return (
        i >= 8
        and body[i - 8 : i - 6] == bytes.fromhex("85c0")
        and body[i - 6] == 0x0F
        and body[i - 5] == 0x84
    )


def build_stub(call_rel: int, jmp_rel: int) -> bytes:
    # mov -0x10(%rbp),%rcx; sub $0x20,%rsp; call rel32; add $0x20,%rsp; jmp rel32
    return (
        bytes.fromhex("488b4df04883ec20")
        + b"\xe8"
        + struct.pack("<i", call_rel)
        + bytes.fromhex("4883c420")
        + b"\xe9"
        + struct.pack("<i", jmp_rel)
    )


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("exe", nargs="?", default="xlang.exe")
    args = ap.parse_args()
    exe = Path(args.exe)
    if not exe.is_file():
        print(f"win_patch_lexer_next_impl_eof_arm: skip missing {exe}", file=sys.stderr)
        return 1
    if is_asm_product(exe):
        print("win_patch_lexer_next_impl_eof_arm: refuse compiler/xlang_asm.exe", file=sys.stderr)
        return 1

    thins = nm_text_addrs(exe, "lexer_emit_eof_token")
    if not thins:
        print(
            "win_patch_lexer_next_impl_eof_arm: missing lexer_emit_eof_token (thin not linked)",
            file=sys.stderr,
        )
        return 1
    thin_va = thins[0]
    impls = nm_text_addrs(exe, "lexer_next_impl")
    if not impls:
        print("win_patch_lexer_next_impl_eof_arm: missing lexer_next_impl", file=sys.stderr)
        return 1

    data = bytearray(exe.read_bytes())
    patched = 0
    skipped = 0
    found_unpatched = 0
    for impl_va in impls:
        try:
            impl_off, image_base = pe_va_to_off(bytes(data), impl_va)
        except SystemExit as e:
            print(e, file=sys.stderr)
            return 1
        # typool face is ~0x514 bytes; scan a modest window
        window = 0x800
        body = bytes(data[impl_off : impl_off + window])
        epi = body.find(EPILOGUE)
        if epi < 0:
            print(
                f"win_patch_lexer_next_impl_eof_arm: no epilogue in lexer_next_impl @{impl_va:#x}",
                file=sys.stderr,
            )
            return 1
        epi_va = impl_va + epi

        arm_off = -1
        pos = 0
        while True:
            i = body.find(ARM_START, pos)
            if i < 0 or i >= epi:
                break
            if preceded_by_test_je(body, i) and LEA_70 in body[i:epi]:
                arm_off = i
                break
            pos = i + 1

        if arm_off < 0:
            already = False
            pos = 0
            while True:
                j = body.find(PATCHED_PFX, pos)
                if j < 0 or j >= epi:
                    break
                if preceded_by_test_je(body, j):
                    already = True
                    break
                pos = j + 1
            if already:
                print(f"win_patch_lexer_next_impl_eof_arm: already patched @{impl_va:#x}")
                skipped += 1
                continue
            print(
                f"win_patch_lexer_next_impl_eof_arm: no pos>=len EOF arm in lexer_next_impl @{impl_va:#x}",
                file=sys.stderr,
            )
            return 1

        found_unpatched += 1
        file_off = impl_off + arm_off
        arm_va = impl_va + arm_off
        stub_len = 22
        call_va = arm_va + 8  # after mov rcx / sub rsp
        call_rel = thin_va - (call_va + 5)
        jmp_va = arm_va + 17  # after call + add rsp
        jmp_rel = epi_va - (jmp_va + 5)
        if not (-0x80000000 <= call_rel <= 0x7FFFFFFF):
            print(f"win_patch_lexer_next_impl_eof_arm: call rel32 overflow {call_rel}", file=sys.stderr)
            return 1
        if not (-0x80000000 <= jmp_rel <= 0x7FFFFFFF):
            print(f"win_patch_lexer_next_impl_eof_arm: jmp rel32 overflow {jmp_rel}", file=sys.stderr)
            return 1
        stub = build_stub(call_rel, jmp_rel)
        assert len(stub) == stub_len
        data[file_off : file_off + stub_len] = stub
        print(
            f"win_patch_lexer_next_impl_eof_arm: "
            f"impl@{impl_va:#x} arm@{arm_va:#x} -> thin@{thin_va:#x} jmp epi@{epi_va:#x}"
        )
        patched += 1

    if found_unpatched == 0 and skipped == 0:
        print("win_patch_lexer_next_impl_eof_arm: no typool pos>=len EOF arm found", file=sys.stderr)
        return 1
    exe.write_bytes(data)
    print(f"win_patch_lexer_next_impl_eof_arm: patched={patched} skipped={skipped}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
