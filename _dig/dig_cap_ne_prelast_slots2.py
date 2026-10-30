#!/usr/bin/env python3
"""DIG SoftCap 10.60 follow-up: non-Capless pre_last callers @0f2108/@5a0dd2;
pre_last full arg prologue; Cap SoftCap lit path?
Deadline ≤85s. Ban mega/glue/LIVE/tip@121278.
"""
from pathlib import Path
import struct, hashlib, time, sys
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
from collections import defaultdict

T0 = time.time()
DEADLINE = T0 + 85
ISOL = Path("/tmp/p1060_dig/bins/xlang_isol1060_alt_frame2.exe")
buf = ISOL.read_bytes()
sha12 = hashlib.sha256(buf).hexdigest()[:12]
assert sha12 == "9378df517f96", sha12

def pe_secs(b):
    e = struct.unpack_from("<I", b, 0x3C)[0]
    nsec = struct.unpack_from("<H", b, e + 6)[0]
    opt = struct.unpack_from("<H", b, e + 20)[0]
    sec = e + 24 + opt
    out = {}
    for i in range(nsec):
        o = sec + i * 40
        n = bytes(b[o:o + 8]).split(b"\0")[0]
        vs, va, rs, ro = struct.unpack_from("<IIII", b, o + 8)
        out[n] = (va, vs, ro, rs)
    return out

def rva2off(secs, r):
    for n, (va, vs, ro, rs) in secs.items():
        if va <= r < va + max(vs, rs):
            return ro + (r - va)
    raise ValueError(hex(r))

secs = pe_secs(buf)
va, vs, ro, rs = secs[b".text"]
raw = buf[ro:ro + rs]
md = Cs(CS_ARCH_X86, CS_MODE_64)
md.detail = True

def disasm_range(rva, n=0x80):
    off = rva2off(secs, rva)
    return list(md.disasm(buf[off:off + n], rva))

def find_e8_callers_all(target):
    hits = []
    i = 0
    while i < len(raw) - 5:
        if raw[i] == 0xE8:
            rel = struct.unpack_from("<i", raw, i + 1)[0]
            abs_rva = (va + i + 5) + rel
            if abs_rva == target:
                hits.append(va + i)
            i += 5; continue
        i += 1
    return hits

def e8_dests_in(rva, n):
    off = rva2off(secs, rva)
    chunk = buf[off:off + n]
    out = []
    i = 0
    while i < len(chunk) - 5:
        if chunk[i] == 0xE8:
            rel = struct.unpack_from("<i", chunk, i + 1)[0]
            abs_rva = (rva + i + 5) + rel
            if va <= abs_rva < va + vs:
                out.append((rva + i, abs_rva))
            i += 5; continue
        i += 1
    return out

def find_fn_start(rva, back_max=0x400):
    """Walk back for push rbp; mov rbp,rsp prologue."""
    for back in range(0, back_max, 1):
        at = rva - back
        if at < va: break
        insns = disasm_range(at, 16)
        if not insns: continue
        if insns[0].mnemonic == "push" and "rbp" in insns[0].op_str:
            # confirm next is mov rbp, rsp
            if len(insns) > 1 and insns[1].mnemonic == "mov" and "rbp" in insns[1].op_str and "rsp" in insns[1].op_str:
                return at
    return None

LEN = 0x2a62c9
GETELEM = 0x2a5ca8
PUSH = 0x2a4f6a
UNWRAP = 0x2a5410
ALLOC_568 = 0x55d730
SOFTCAP_SITE = 0x2be519
PRE_LAST = 0x567a30
CAPLESS_LO, CAPLESS_HI = 0x576000, 0x578280
FILL_FAM = {0x1f9619, 0x1f9768, 0x1f99b2, 0x1fa9d9, 0x207462, 0x20760b, 0x207aef}

print(f"=== Isol sha12={sha12} DIG2 Cap≠Capless / hetero slots ===\n")

# ----- 1) Full pre_last prologue: ALL arg copies -----
print("=== 1) pre_last prologue full (first 0x80) ===")
for insn in disasm_range(PRE_LAST, 0x80):
    print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Map: which local gets which arg
print("\n=== 1b) arg→local map ===")
# From prior + disasm we expect:
# rcx→-0x10, rdx→-0x18, r8→-0x20, r9→-0x28, [rbp+0x30]→-0x30, [rbp+0x38]→-0x38, [rbp+0x40]→-0x40
# Only -0x30 feeds @2a62c9 SoftCap lit

# ----- 2) @0f2108 full context -----
print("\n=== 2) non-Capless pre_last caller @0f2108 ===")
c = 0xf2108
# raw bytes around call
off = rva2off(secs, c - 0x40)
print(f"  raw[{c-0x40:06x}..]: {buf[off:off+0x50].hex()}")
print("  disasm wide:")
for insn in disasm_range(c - 0x60, 0x80):
    mark = " <<<" if insn.address == c else ""
    print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}{mark}")
fn = find_fn_start(c)
print(f"  fn_start={hex(fn) if fn else None}")
if fn:
    e8s = e8_dests_in(fn, min(c - fn + 0x40, 0x800))
    dests = sorted({d for _, d in e8s})
    print(f"  fn E8 dests (to call): {[hex(d) for d in dests[:40]]}")
    hit = [d for d in dests if d in FILL_FAM or d in (PUSH, UNWRAP, LEN, GETELEM, ALLOC_568, SOFTCAP_SITE, 0x55d730)]
    print(f"  ∩ fill/push/len/alloc/site: {[hex(d) for d in hit]}")
# parents of this call site's function
if fn:
    parents = find_e8_callers_all(fn)
    print(f"  parents of fn: {[hex(p) for p in parents[:15]]} n={len(parents)}")

# ----- 3) @5a0dd2 full context — SoftCap lit? Cap? SoftMega? -----
print("\n=== 3) non-Capless pre_last caller @5a0dd2 ===")
c = 0x5a0dd2
fn = find_fn_start(c, 0x800)
print(f"  fn_start={hex(fn) if fn else None}")
# Who sets [rbp-0x50]?
print("  stores to [rbp-0x50] in fn (scan):")
if fn:
    for insn in disasm_range(fn, c - fn + 8):
        if insn.address > c: break
        if "rbp - 0x50" in insn.op_str or "rbp - 80" in insn.op_str:
            print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    e8s = e8_dests_in(fn, min(c - fn + 0x40, 0xa00))
    dests = sorted({d for _, d in e8s})
    print(f"  fn E8 count={len(e8s)} unique={len(dests)}")
    hit = [d for d in dests if d in FILL_FAM or d in (PUSH, UNWRAP, LEN, GETELEM, ALLOC_568, SOFTCAP_SITE)]
    print(f"  ∩ fill/push/len/alloc/site: {[hex(d) for d in hit]}")
    # SoftMega band? Capless?
    print(f"  fn in SoftMega(@59xxxx)? {0x590000 <= fn < 0x5b0000}")
    print(f"  fn in Capless? {CAPLESS_LO <= fn < CAPLESS_HI}")
    parents = find_e8_callers_all(fn)
    print(f"  parents: {[hex(p) for p in parents[:20]]} n={len(parents)}")
    # sample early body for 0x568 alloc / +0x478
    print("  early body (first 50 interesting / 0x568 / 478):")
    nshow = 0
    for insn in disasm_range(fn, 0x200):
        interesting = ("0x568" in insn.op_str or "0x478" in insn.op_str
                       or insn.mnemonic == "call"
                       or "push rbp" in f"{insn.mnemonic} {insn.op_str}")
        if interesting or nshow < 25:
            print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
            nshow += 1

# ----- 4) Is SoftCap lit ONLY via Capless→pre_last? -----
print("\n=== 4) SoftCap lit path exclusivity ===")
# SoftCap lit = Capless @57820f → pre_last with +0x478 empty
# Do @0f2108 / @5a0dd2 ever run for SoftCap lit CallExpr (p_ret_lit)?
# Heuristic: Capless is THE SoftCap lit CallExpr emitter (prior HIT traces).
# Check if @0f2108/@5a0dd2 are on SoftCap-site chain or CapFN.
print("  Capless→pre_last = SoftCap lit (prior HIT @57820f/+0x478)")
print("  Check whether @0f2108/@5a0dd2 reference SoftCap-site or Capless:")
for label, c in [("@0f2108", 0xf2108), ("@5a0dd2", 0x5a0dd2)]:
    fn = find_fn_start(c, 0x800)
    if not fn:
        print(f"  {label}: no fn"); continue
    e8s = e8_dests_in(fn, min(0x1000, max(c - fn + 0x100, 0x100)))
    dests = {d for _, d in e8s}
    print(f"  {label} fn@{fn:06x}: SoftCap-site?{SOFTCAP_SITE in dests} Capless-entry?{any(CAPLESS_LO<=d<CAPLESS_HI for d in dests)} PRE_LAST?{PRE_LAST in dests}")

# ----- 5) Other pre_last locals as @2a62c9 sources? -----
print("\n=== 5) Do OTHER pre_last locals (-0x10/-0x18/-0x20/-0x28/-0x38/-0x40) ever feed @2a62c9/@2a5ca8? ===")
# Scan pre_last band for loads of these before any call
PRE_LO, PRE_HI = 0x567a30, 0x569800
locals_of_interest = ["rbp - 0x10", "rbp - 0x18", "rbp - 0x20", "rbp - 0x28",
                      "rbp - 0x30", "rbp - 0x38", "rbp - 0x40"]
# For each E8 in band, check window for these locals as rcx source
all_e8 = e8_dests_in(PRE_LO, PRE_HI - PRE_LO)
for call_rva, dest in all_e8:
    if dest not in (LEN, GETELEM):
        continue
    win = disasm_range(call_rva - 0x30, 0x38)
    for insn in win:
        if insn.address >= call_rva: break
        for loc in locals_of_interest:
            if loc in insn.op_str and insn.mnemonic == "mov":
                print(f"  @{call_rva:06x}→{hex(dest)} via @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Also: any STORE to -0x30 OTHER than the prologue arg5 copy?
print("\n=== 5b) ALL stores to [rbp-0x30] in pre_last (besides prologue)? ===")
for insn in disasm_range(PRE_LO, PRE_HI - PRE_LO):
    if insn.mnemonic == "mov" and insn.op_str.startswith("qword ptr [rbp - 0x30],"):
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# ----- 6) Cap path CapFN: does any Cap (non-Capless) SoftCap CallExpr fill an arg vec? -----
print("\n=== 6) Cap SoftCap CallExpr — any path to pre_last with NON-empty-shell arg5? ===")
# SoftCap lit HIT path = Capless only (prior). Confirm @2be40f is dead (0 parents).
parents_2be40f = find_e8_callers_all(0x2be40f)
# Also check fallthrough: what is just before @2be40f?
print(f"  E8→@2be40f parents={[hex(p) for p in parents_2be40f]} n={len(parents_2be40f)}")
print("  bytes/insns immediately before @2be40f:")
for insn in disasm_range(0x2be3e0, 0x40):
    mark = " <<<" if insn.address == 0x2be40f else ""
    print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}{mark}")
# Is @2be40f inside SoftCap-site function itself (fallthrough after ret)?
# SoftCap-site starts @2be519 — so @2be40f is BEFORE site, separate.
# Check if @2be3xx is a different fn that falls into call site
fn40 = find_fn_start(0x2be40f, 0x200)
print(f"  fn containing @2be40f call = {hex(fn40) if fn40 else None}")
if fn40:
    parents = find_e8_callers_all(fn40)
    print(f"  that fn parents={[hex(p) for p in parents[:15]]} n={len(parents)}")

# ----- 7) @5a0dd2 arg5 source: is it 0x568 alloc empty or filled? -----
print("\n=== 7) @5a0dd2 [rbp-0x50] provenance (0x568? push? fill?) ===")
fn = find_fn_start(0x5a0dd2, 0x800)
if fn:
    # find all mov edx,0x568 / E8 alloc / push / unwrap in this fn
    for insn in disasm_range(fn, 0x5a0dd2 - fn + 8):
        if insn.address > 0x5a0dd2: break
        s = f"{insn.mnemonic} {insn.op_str}"
        if "0x568" in s or "0x478" in s:
            print(f"  @{insn.address:06x}: {s}")
    # E8 to alloc/push/fill
    for a, d in e8_dests_in(fn, 0x5a0dd2 - fn + 8):
        if d in (ALLOC_568, PUSH, UNWRAP, LEN, GETELEM) or d in FILL_FAM:
            print(f"  E8 @{a:06x} → {hex(d)}")
    # Who writes -0x50: show ±8 insns around each store
    for insn in disasm_range(fn, 0x5a0dd2 - fn + 8):
        if insn.address > 0x5a0dd2: break
        if insn.mnemonic == "mov" and insn.op_str.startswith("qword ptr [rbp - 0x50],"):
            print(f"  STORE -0x50 @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
            for x in disasm_range(insn.address - 0x20, 0x40):
                if abs(x.address - insn.address) <= 0x20:
                    print(f"    @{x.address:06x}: {x.mnemonic} {x.op_str}")

# ----- 8) VERDICT -----
print("\n=== 8) VERDICT probes ===")
print(f"  SoftCap-site reachable non-Capless (@2be40f) parents={len(parents_2be40f)} (0⇒dead for SoftCap lit)")
print(f"  SoftCap lit pre_last via Capless @57820f +0x478 empty only? (prior HIT)")
print(f"  pre_last @2a62c9 only @56888d on [rbp-0x30]=arg5")
print(f"  other locals feed len/get? see §5")
print(f"  non-Capless pre_last callers = Cap/SoftMega side paths — SoftCap lit? see §4")
print(f"  elapsed={time.time()-T0:.1f}s")
print("=== DONE ===")
