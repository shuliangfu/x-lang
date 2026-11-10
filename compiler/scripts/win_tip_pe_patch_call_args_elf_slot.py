#!/usr/bin/env python3
"""PE-patch Win tip for_call_args frame pad / elf slot (DIG 2026-11-10).

Root cause in pipeline_asm_emit_expr_elf_for_call_args (tip-aside PE,
0x1400413f0, 31KB, alloca 0xb318):

After saving arena/elf/expr/ctx/ta at [rbp-0x10]..[rbp-0x30], the tip
zeros 256 bytes from lea rax,[rbp-0x18] (source _frame_pad_y5 is 16384B;
tip only inits 256) and later zeros 512B from the same address. That
overlaps saved elf (-0x18), arena (-0x10), saved rbx/rbp, and the
return address at [rbp+8]. CAST/BINOP call args take this path and
SEGV (rec called with rcx=rdx=0). VAR / bare INT_LIT args do not
enter this function.

Body stores of kind/local immediates also reuse [rbp-0x18]. All 77
loads of [rbp-0x18] in the live range are elf uses (marshal to rcx/rdx
or null-check). [rbp-0x10] is never stored after the prologue, so
arena stays if the pad is skipped. [rbp-0x38] is unused in this
function (8-bit disp, same encoding length).

Patch:
  1) Right after the ta save, copy elf to [rbp-0x38] and jmp over the
     pad / colliding inits to the f32-xmm / widen_f64 init at
     0x140042028 (the first real logic).
  2) In the executed range [0x140042028, 0x140048dd0), retarget the
     69 `mov rax,[rbp-0x18]` and 8 `mov rbx,[rbp-0x18]` loads to
     [rbp-0x38]. Stores to [rbp-0x18] are left as local inits.

Idempotent. Apply after uasb_out_append_len_off on tip-aside install.
PLATFORM: WINDOWS|X86_64 tip PE only. Soft Cap / tiphead HOLD.
"""
from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

FUNC_LO = 0x1400413F0  # pipeline_asm_emit_expr_elf_for_call_args
FUNC_HI = 0x140048DD0  # next symbol sli_emit_if_arm_or_array_elf_c
STUB_VA = 0x14004143F  # immediately after mov [rbp-0x30], ta
APPLY_LO = 0x140042028  # pipeline_asm_abi_f32_xmm_enabled_c init
# 8 bytes before stub: mov rax,[rbp+0x30]; cdqe; mov [rbp-0x30],rax
CTX_BEFORE = bytes.fromhex("488b45304898488945d0")
# mov eax,0; mov [rbp-0x18],rax; mov eax,1  (last 4 of 5)
STUB_OLD = bytes.fromhex("b800000000488945e8b8010000")
# mov rax,[rbp-0x18]; mov [rbp-0x38],rax; jmp 0x140042028
STUB_NEW = bytes.fromhex("488b45e8488945c8e9dc0b0000")
LOAD_RAX_OLD = bytes.fromhex("488b45e8")  # mov rax,[rbp-0x18]
LOAD_RAX_NEW = bytes.fromhex("488b45c8")  # mov rax,[rbp-0x38]
LOAD_RBX_OLD = bytes.fromhex("488b5de8")  # mov rbx,[rbp-0x18]
LOAD_RBX_NEW = bytes.fromhex("488b5dc8")  # mov rbx,[rbp-0x38]
EXPECT_RAX = 69
EXPECT_RBX = 8


def pe_meta(data: bytearray):
    e = struct.unpack_from("<I", data, 0x3C)[0]
    ns = struct.unpack_from("<H", data, e + 6)[0]
    osize = struct.unpack_from("<H", data, e + 20)[0]
    ib = struct.unpack_from("<Q", data, e + 24 + 24)[0]
    so = e + 24 + osize
    secs = []
    for i in range(ns):
        o = so + i * 40
        vs, va, rs, rp = struct.unpack_from("<IIII", data, o + 8)
        secs.append({"va": va, "vsz": vs, "rsz": rs, "rp": rp})
    return ib, secs


def fo_for(ib: int, secs, va: int) -> int:
    rva = va - ib
    for s in secs:
        if s["va"] <= rva < s["va"] + max(s["vsz"], s["rsz"]):
            return s["rp"] + (rva - s["va"])
    raise SystemExit(f"VA 0x{va:x} not mapped")


def _count(buf: bytes, needle: bytes) -> int:
    return buf.count(needle)


def patch(path: Path, dry_run: bool) -> int:
    data = bytearray(path.read_bytes())
    ib, secs = pe_meta(data)
    stub_fo = fo_for(ib, secs, STUB_VA)
    apply_fo = fo_for(ib, secs, APPLY_LO)
    hi_fo = fo_for(ib, secs, FUNC_HI)

    before = data[stub_fo - len(CTX_BEFORE) : stub_fo]
    if before != CTX_BEFORE:
        print("FAIL stub CTX_BEFORE mismatch", file=sys.stderr)
        return 2
    head = bytes(data[stub_fo : stub_fo + len(STUB_OLD)])
    live = bytes(data[apply_fo:hi_fo])
    n_rax_old = _count(live, LOAD_RAX_OLD)
    n_rax_new = _count(live, LOAD_RAX_NEW)
    n_rbx_old = _count(live, LOAD_RBX_OLD)
    n_rbx_new = _count(live, LOAD_RBX_NEW)

    stub_old = head == STUB_OLD
    stub_new = head == STUB_NEW
    loads_old = n_rax_old == EXPECT_RAX and n_rbx_old == EXPECT_RBX and n_rax_new == 0 and n_rbx_new == 0
    loads_new = n_rax_new == EXPECT_RAX and n_rbx_new == EXPECT_RBX and n_rax_old == 0 and n_rbx_old == 0

    if stub_new and loads_new:
        print(f"OK already call-args-elf-slot (stub + {EXPECT_RAX}+{EXPECT_RBX} loads) in {path}")
        return 0
    if not (stub_old and loads_old):
        print(
            "FAIL mixed/unexpected state: "
            f"stub_old={stub_old} stub_new={stub_new} "
            f"rax old/new={n_rax_old}/{n_rax_new} "
            f"rbx old/new={n_rbx_old}/{n_rbx_new} "
            f"(want {EXPECT_RAX}+{EXPECT_RBX}); refuse partial patch",
            file=sys.stderr,
        )
        return 2
    if dry_run:
        print("DRY-RUN would patch pipeline_asm_emit_expr_elf_for_call_args:")
        print(f"  0x{STUB_VA:x}  copy elf [rbp-0x18] -> [rbp-0x38], jmp 0x{APPLY_LO:x}")
        print(f"  0x{APPLY_LO:x}..0x{FUNC_HI:x}  {EXPECT_RAX} mov rax,[rbp-0x18]->[rbp-0x38]")
        print(f"  0x{APPLY_LO:x}..0x{FUNC_HI:x}  {EXPECT_RBX} mov rbx,[rbp-0x18]->[rbp-0x38]")
        return 0

    data[stub_fo : stub_fo + len(STUB_NEW)] = STUB_NEW
    # replace loads back-to-front in the apply window
    window = bytearray(data[apply_fo:hi_fo])

    def replace_all(buf: bytearray, old: bytes, new: bytes, expect: int, label: str) -> None:
        n = 0
        i = 0
        while True:
            j = buf.find(old, i)
            if j < 0:
                break
            buf[j : j + len(old)] = new
            n += 1
            i = j + len(new)
        if n != expect:
            raise SystemExit(f"FAIL {label} replaced {n}, want {expect}")

    replace_all(window, LOAD_RAX_OLD, LOAD_RAX_NEW, EXPECT_RAX, "rax-load")
    replace_all(window, LOAD_RBX_OLD, LOAD_RBX_NEW, EXPECT_RBX, "rbx-load")
    data[apply_fo:hi_fo] = window
    path.write_bytes(data)
    print(
        f"PATCHED call-args elf slot: stub + {EXPECT_RAX}+{EXPECT_RBX} loads -> [rbp-0x38] in {path}"
    )
    return 0


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("exe", type=Path)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    if not args.exe.is_file():
        print(f"FAIL missing {args.exe}", file=sys.stderr)
        return 2
    return patch(args.exe, args.dry_run)


if __name__ == "__main__":
    sys.exit(main())
