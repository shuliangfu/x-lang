#!/usr/bin/env python3
"""PE-patch Win tip: fill missing struct-lit field-vector rebase.

Not a 1-insn typo. tip pipeline_expr_append_struct_lit_field T
@ 0x140119604 only stores FIELD_BASE=gv_len when idx==0
(0x14011966f short jne 0x1401196ab -> field_at create=1). Current
source (runtime_pipeline_abi_expr_sidecar_thin.x ~1159-1180) also
does else if (glen != base+idx): copy this lit's fields to the vector
tail and retarget FIELD_BASE. Without that path, appending an outer
nested field after a sibling (and after the inner lit already pushed
its slots) overwrites the inner's first field; emit then hits the
init_ref==parent cycle guard (site 12) and CG002s.

This patch jmps the idx!=0 edge (and resumes idx==0 in-place) to a
mapped-NOP cave that implements the missing rebase using existing
tip helpers (w327_sc, w529_gv_at, gv grow, memcpy). No product-source
change. Not a unique 1-insn rewrite; it is a VA-unique, idempotent,
refuse-mixed, replayable fill of the missing path.

Hook (unique by VA + 0x4a0 NUM_FIELDS load; do not confuse with the
same short-jne template in append_match_arm @ 0x1401191df, which
loads 0x148):
  0x14011966f  75 3a 48 8b 45  ->  E9 rel32  (trailing 10 of
  mov rax,[rbp+0x10] left in place; cave resumes idx==0 at 0x140119675)

Caves: already-mapped between-fn / after-jmp NOP islands, plus mid64
with EB 3E jmp-over. Do not use .text raw slack at 0x14047e440.

PLATFORM: WINDOWS|X86_64 tip PE only. Soft Cap / tiphead HOLD.
L4 apply order: after lexer_buf_into_skip_park_prefer.
"""
from __future__ import annotations

import argparse
import hashlib
import shutil
import struct
import sys
from pathlib import Path

from keystone import KS_ARCH_X86, KS_MODE_64, Ks
from capstone import CS_ARCH_X86, CS_MODE_64, Cs

IB = 0x140000000
FUNC_T = 0x140119604
HOOK = 0x14011966F
JOIN = 0x1401196AB          # field_at(..., create=1) setup
IDX0 = 0x140119675          # after reconstructed mov rax,[rbp+0x10]
FAIL = 0x14011975D          # mov eax,-1 already done; add rsp,0x40; pop rbp; ret
# Unique context: NUM_FIELDS load at +0x4a0, not match_arm's +0x148
CTX_BEFORE = bytes.fromhex("488b45f88b80a004000085c0")  # at 0x140119663
HOOK_OLD = bytes.fromhex("753a488b45")  # jne +0x3A; start of mov rax,[rbp+0x10]
HOOK_TRAIL = bytes.fromhex("10")        # last byte of mov rax,[rbp+0x10]
# after trail: ba 01 00 00 00  = mov edx,1
CTX_AFTER = bytes.fromhex("10ba01000000")  # at 0x140119674

W327_SC = 0x1401101DF
GV_AT = 0x14010F307
GV_GROW = 0x14010F35C
MEMCPY = 0x140477F50
SLF_SZ = 264

# Already-mapped islands (caps are pure NOP counts we may use)
A1 = 0x140477BA2   # 30, between fn
A2 = 0x140477122   # 30, between fn
MID64 = 0x140435095
RB = 0x140435097   # 62 after EB 3E
LP0 = 0x140255BE0  # 20, after jmp
LP1 = 0x140255717  # 20, after jmp
LS = 0x140001BE5   # 27, between fn
MID24 = 0x140063349
S24 = 0x14006334B  # 22 after EB 16
MID18 = 0x1404064D8
S18 = 0x1404064DA  # 16 after EB 10

# Extra between-fn NOP padding (after ret, before next prologue).
E15 = 0x140001481   # 15
E15B = 0x140002DF1  # 15
E15C = 0x140128C91  # 15
E14  = 0x140012052  # 14 after ret
E15D = 0x14046BEA1  # 15 after ret
E15E = 0x140476E61  # 15 after uncond jmp
E14B = 0x14046AB72  # 14 after ret
E14C = 0x140359E62  # 14 after ret

ISLANDS = [
    (A1, 30),
    (A2, 30),
    (RB, 62),
    (LP0, 20),
    (LP1, 20),
    (LS, 27),
    (S24, 22),
    (S18, 16),
    (E15, 15),
    (E15B, 15),
    (E15C, 15),
    (E14, 14),
    (E15D, 15),
    (E15E, 15),
    (E14B, 14),
    (E14C, 14),
]


def rel32(target: int, va: int, ilen: int) -> bytes:
    return struct.pack("<i", target - (va + ilen))


def asm(src: str, addr: int) -> bytes:
    enc, _ = Ks(KS_ARCH_X86, KS_MODE_64).asm(src, addr)
    if enc is None:
        raise SystemExit("asm fail:\n" + src)
    return bytes(enc)


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
        name = data[o:o + 8].split(b"\x00", 1)[0]
        secs.append({"name": name, "va": va, "vsz": vs, "rsz": rs, "rp": rp, "hdr": o})
    return ib, secs


def fo_for(ib: int, secs, va: int) -> int:
    rva = va - ib
    for s in secs:
        if s["va"] <= rva < s["va"] + max(s["vsz"], s["rsz"]):
            return s["rp"] + (rva - s["va"])
    raise SystemExit("VA 0x%x not mapped" % va)


class Stream:
    def __init__(self, islands: list[tuple[int, int]]):
        self.islands = islands
        self.idx = 0
        self.va = islands[0][0]
        self.limit = islands[0][0] + islands[0][1]
        self.chunks: list[tuple[int, bytes]] = []
        self.labels: dict[str, int] = {}
        self.fixups: list[tuple[int, str, str, bytes]] = []

    def usable(self) -> int:
        if self.idx + 1 < len(self.islands):
            return self.limit - 5
        return self.limit

    def switch(self, need: int) -> None:
        if self.va + need <= self.usable():
            return
        if self.idx + 1 >= len(self.islands):
            raise SystemExit("cave overflow at 0x%x need %d" % (self.va, need))
        if self.limit - self.va < 5:
            raise SystemExit("no jmp room at 0x%x" % self.va)
        nxt = self.islands[self.idx + 1][0]
        self.chunks.append((self.va, b"\xE9" + rel32(nxt, self.va, 5)))
        self.idx += 1
        self.va = self.islands[self.idx][0]
        self.limit = self.islands[self.idx][0] + self.islands[self.idx][1]
        if self.va + need > self.limit:
            raise SystemExit("island overflow at 0x%x need %d" % (self.va, need))

    def emit(self, b: bytes) -> int:
        self.switch(len(b))
        va = self.va
        self.chunks.append((va, b))
        self.va += len(b)
        return va

    def emit_asm(self, src: str) -> int:
        # pre-size at current va, switch, re-encode at final va
        n = len(asm(src, self.va))
        self.switch(n)
        b = asm(src, self.va)
        if len(b) != n:
            self.switch(len(b))
            b = asm(src, self.va)
        return self.emit(b)

    def label(self, name: str) -> int:
        self.labels[name] = self.va
        return self.va

    def jmp(self, lab: str) -> int:
        self.switch(5)
        va = self.va
        self.chunks.append((va, b"\xE9\x00\x00\x00\x00"))
        self.fixups.append((va, "jmp", lab, b"\xE9"))
        self.va += 5
        return va

    def jcc(self, cc: str, lab: str) -> int:
        # 0F 8x rel32
        m = {
            "jz": 0x84, "je": 0x84, "jnz": 0x85, "jne": 0x85,
            "js": 0x88, "jns": 0x89, "jl": 0x8C, "jge": 0x8D,
            "jle": 0x8E, "jg": 0x8F,
        }[cc]
        self.switch(6)
        va = self.va
        prefix = bytes([0x0F, m])
        self.chunks.append((va, prefix + b"\x00\x00\x00\x00"))
        self.fixups.append((va, "jcc", lab, prefix))
        self.va += 6
        return va

    def resolve(self) -> None:
        by_va = {va: i for i, (va, _) in enumerate(self.chunks)}
        for va, kind, lab, prefix in self.fixups:
            if lab not in self.labels:
                raise SystemExit("unresolved %s" % lab)
            tgt = self.labels[lab]
            ilen = 5 if kind == "jmp" else 6
            i = by_va[va]
            self.chunks[i] = (va, prefix + rel32(tgt, va, ilen))


def build_cave() -> tuple[int, list[tuple[int, bytes]], dict[str, int]]:
    st = Stream(ISLANDS)
    entry = st.label("entry")
    st.emit_asm("test eax, eax")
    st.jcc("jz", "idx0")
    st.emit_asm("push rbx")
    st.emit_asm("push rsi")
    st.emit_asm("push rdi")
    st.emit_asm("push r12")
    st.emit_asm("push r13")
    st.emit_asm("push r14")
    st.emit_asm("push r15")
    st.emit_asm("sub rsp, 0x28")
    st.emit_asm("mov r13d, eax")
    st.emit_asm("mov r12, qword ptr [rbp - 8]")
    st.emit_asm("mov esi, dword ptr [r12 + 0x49c]")
    st.emit_asm("mov rcx, qword ptr [rbp + 0x10]")
    st.emit_asm("mov edx, 1")
    st.emit_asm("call 0x%x" % W327_SC)
    st.emit_asm("test rax, rax")
    st.jcc("jz", "fail")
    st.emit_asm("lea r15, [rax + 0x2d0]")
    st.emit_asm("mov edi, dword ptr [r15 + 0xc]")
    st.emit_asm("mov ecx, esi")
    st.emit_asm("add ecx, r13d")
    st.emit_asm("cmp edi, ecx")
    st.jcc("je", "done")
    st.label("ensure")
    st.emit_asm("lea eax, [rdi + r13]")  # new_base+idx; rdi is 32-bit new_base in edi
    st.emit_asm("cmp dword ptr [r15 + 0xc], eax")
    st.jcc("jge", "copies")
    st.emit_asm("mov rcx, r15")
    st.emit_asm("call 0x%x" % GV_GROW)
    st.emit_asm("test eax, eax")
    st.jcc("js", "fail")
    st.jmp("ensure")
    st.label("copies")
    st.emit_asm("xor ebx, ebx")
    st.label("copy_loop")
    st.emit_asm("cmp ebx, r13d")
    st.jcc("jge", "stored")
    st.emit_asm("mov rcx, r15")
    st.emit_asm("lea edx, [rsi + rbx]")
    st.emit_asm("call 0x%x" % GV_AT)
    st.emit_asm("mov r14, rax")
    st.emit_asm("mov rcx, r15")
    st.emit_asm("lea edx, [rdi + rbx]")
    st.emit_asm("call 0x%x" % GV_AT)
    st.emit_asm("mov rcx, rax")
    st.emit_asm("mov rdx, r14")
    st.emit_asm("mov r8d, %d" % SLF_SZ)
    st.emit_asm("call 0x%x" % MEMCPY)
    st.emit_asm("inc ebx")
    st.jmp("copy_loop")
    st.label("stored")
    st.emit_asm("mov dword ptr [r12 + 0x49c], edi")
    st.label("done")
    st.emit_asm("add rsp, 0x28")
    st.emit_asm("pop r15")
    st.emit_asm("pop r14")
    st.emit_asm("pop r13")
    st.emit_asm("pop r12")
    st.emit_asm("pop rdi")
    st.emit_asm("pop rsi")
    st.emit_asm("pop rbx")
    st.jmp("join_abs")
    st.label("fail")
    st.emit_asm("add rsp, 0x28")
    st.emit_asm("pop r15")
    st.emit_asm("pop r14")
    st.emit_asm("pop r13")
    st.emit_asm("pop r12")
    st.emit_asm("pop rdi")
    st.emit_asm("pop rsi")
    st.emit_asm("pop rbx")
    st.emit_asm("or eax, -1")
    st.jmp("fail_abs")
    st.label("idx0")
    st.emit_asm("mov rax, qword ptr [rbp + 0x10]")
    st.jmp("idx0_abs")
    # absolute targets as labels we poke in
    st.labels["join_abs"] = JOIN
    st.labels["fail_abs"] = FAIL
    st.labels["idx0_abs"] = IDX0
    st.resolve()
    return entry, st.chunks, st.labels


def install_jmp_overs(data: bytearray, fo, used_bases: set[int]) -> None:
    if RB in used_bases or any(RB <= va < RB + 62 for va in used_bases):
        if data[fo(MID64):fo(MID64) + 64] != b"\x90" * 64:
            raise SystemExit("mid64 nop changed")
        data[fo(MID64):fo(MID64) + 2] = b"\xEB\x3E"
    if S24 in used_bases:
        if data[fo(MID24):fo(MID24) + 24] != b"\x90" * 24:
            raise SystemExit("mid24 nop changed")
        data[fo(MID24):fo(MID24) + 2] = b"\xEB\x16"
    if S18 in used_bases:
        if data[fo(MID18):fo(MID18) + 18] != b"\x90" * 18:
            raise SystemExit("mid18 nop changed")
        data[fo(MID18):fo(MID18) + 2] = b"\xEB\x10"


def hook_bytes(entry: int) -> bytes:
    return b"\xE9" + rel32(entry, HOOK, 5)


def already_patched(data: bytearray, fo, entry: int) -> bool:
    return bytes(data[fo(HOOK):fo(HOOK) + 5]) == hook_bytes(entry) and data[fo(HOOK) + 5] == 0x10


def place_chunks(data: bytearray, fo, chunks: list[tuple[int, bytes]]) -> None:
    # gather per-island and require nops (or already our code on idempotent re-run)
    for va, b in chunks:
        off = fo(va)
        cur = bytes(data[off:off + len(b)])
        if cur != b"\x90" * len(b) and cur != bytes(b):
            raise SystemExit("island not nops at 0x%x: %s" % (va, cur.hex()))
        data[off:off + len(b)] = b


def patch(path: Path, dry_run: bool) -> int:
    raw = path.read_bytes()
    data = bytearray(raw)
    ib, secs = pe_meta(data)
    if ib != IB:
        print("FAIL ImageBase 0x%x != 0x%x" % (ib, IB), file=sys.stderr)
        return 2

    def fo(va: int) -> int:
        return fo_for(ib, secs, va)

    before = bytes(data[fo(HOOK) - len(CTX_BEFORE):fo(HOOK)])
    if before != CTX_BEFORE:
        print("FAIL CTX_BEFORE mismatch at append_struct_lit_field rebase (VA 0x%x)" % HOOK, file=sys.stderr)
        return 2
    after = bytes(data[fo(HOOK) + 4:fo(HOOK) + 4 + len(CTX_AFTER)])
    # CTX_AFTER starts at 0x140119674 = HOOK+5, but we compare trail+mov edx
    after = bytes(data[fo(0x140119674):fo(0x140119674) + len(CTX_AFTER)])
    # When patched, first byte is still 0x10 and mov edx,1 is intact
    if after != CTX_AFTER:
        print("FAIL CTX_AFTER mismatch at append_struct_lit_field rebase", file=sys.stderr)
        return 2

    # uniqueness: 0x4a0 context must be unique
    pat = CTX_BEFORE + HOOK_OLD + HOOK_TRAIL
    hits = raw.count(pat)
    # on a patched image, pat won't match; check old or new
    entry, chunks, labels = build_cave()
    if dry_run:
        print("cave entry 0x%x labels %s" % (entry, {k: hex(v) for k,v in labels.items() if not k.endswith("_abs")}))
    new5 = hook_bytes(entry)
    pat_new = CTX_BEFORE + new5 + HOOK_TRAIL
    if hits == 0:
        if raw.count(pat_new) != 1 and not already_patched(data, fo, entry):
            # maybe already patched; verify hook
            cur5 = bytes(data[fo(HOOK):fo(HOOK) + 5])
            if cur5[0] == 0xE9:
                # idempotent if jump lands at our entry and islands already hold the cave
                print("already patched (hook E9); verifying cave")
            else:
                print("FAIL unique pattern missing and hook is not E9", file=sys.stderr)
                return 2
    elif hits != 1:
        print("FAIL mixed/ambiguous pattern hits=%d (must be unique 0x4a0 site)" % hits, file=sys.stderr)
        return 2

    cur5 = bytes(data[fo(HOOK):fo(HOOK) + 5])
    if cur5 == new5 and data[fo(HOOK) + 5] == 0x10:
        # verify islands already match (idempotent)
        try:
            place_chunks(data, fo, chunks)
        except SystemExit as e:
            print("FAIL already-hooked but cave mismatch: %s" % e, file=sys.stderr)
            return 2
        print("OK already applied append_struct_lit_field rebase -> 0x%x" % entry)
        return 0
    if cur5 != HOOK_OLD:
        print("FAIL mixed hook bytes at 0x%x: %s" % (HOOK, cur5.hex()), file=sys.stderr)
        return 2

    if dry_run:
        print("DRY hook 0x%x %s -> %s (entry 0x%x)" % (HOOK, HOOK_OLD.hex(), new5.hex(), entry))
        for va, b in chunks:
            print("  cave 0x%x len %d" % (va, len(b)))
        return 0

    used_bases = {va for va, _ in chunks}
    install_jmp_overs(data, fo, used_bases)
    place_chunks(data, fo, chunks)
    data[fo(HOOK):fo(HOOK) + 5] = new5
    # trail 0x10 must remain
    if data[fo(HOOK) + 5] != 0x10:
        raise SystemExit("trail clobber")
    path.write_bytes(data)
    print("OK patched append_struct_lit_field rebase")
    print("  hook 0x%x %s -> E9 0x%x" % (HOOK, HOOK_OLD.hex(), entry))
    print("  md5 %s" % hashlib.md5(data).hexdigest())
    # disasm summary
    cs = Cs(CS_ARCH_X86, CS_MODE_64)
    print("  hook site:")
    for insn in cs.disasm(bytes(data[fo(HOOK - 8):fo(HOOK) + 16]), HOOK - 8):
        print("    %016x: %-6s %s" % (insn.address, insn.mnemonic, insn.op_str))
    # print islands with content
    used = {}
    for va, b in chunks:
        for base, cap in ISLANDS:
            if base <= va < base + cap:
                used.setdefault(base, bytearray(b"\x90" * cap))
                used[base][va - base:va - base + len(b)] = b
                break
    for base, cap in ISLANDS:
        if base not in used:
            continue
        print("======= cave %x =======" % base)
        for insn in cs.disasm(bytes(used[base]), base):
            print("    %016x: %-6s %s" % (insn.address, insn.mnemonic, insn.op_str))
    return 0


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("pe", type=Path)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args(argv)
    if not args.pe.is_file():
        print("FAIL missing", args.pe, file=sys.stderr)
        return 2
    return patch(args.pe, args.dry_run)


if __name__ == "__main__":
    raise SystemExit(main())
