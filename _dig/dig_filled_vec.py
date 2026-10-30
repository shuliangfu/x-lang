#!/usr/bin/env python3
"""DIG SoftCap 10.60: Isol SoftCap lit — @2a62c9-compat FILLED vec / single E8 fill+push?
Deadline ≤85s. Isol alt_frame2 only. Ban tip@121278/join/epi/LIVE/mega/arg-loop.
"""
from pathlib import Path
import struct, hashlib, time, sys
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

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

def find_imm32_sites(imm, scan_lo=None, scan_hi=None):
    """Find mov edx/r8d/…, imm32 and similar C7 encodings with given imm."""
    lo = scan_lo if scan_lo is not None else va
    hi = scan_hi if scan_hi is not None else va + vs
    off0 = rva2off(secs, lo)
    chunk = buf[off0:off0 + (hi - lo)]
    pat = struct.pack("<I", imm)
    hits = []
    i = 0
    while True:
        j = chunk.find(pat, i)
        if j < 0:
            break
        # classify nearby opcode
        rva = lo + j
        # look back up to 3 bytes for opcode
        ctx = chunk[max(0, j - 3):j + 4]
        hits.append((rva, ctx.hex()))
        i = j + 1
        if len(hits) > 200:
            break
    return hits

def find_e8_callers_all(target):
    """Whole .text E8 → target."""
    hits = []
    i = 0
    while i < len(raw) - 5:
        if raw[i] == 0xE8:
            rel = struct.unpack_from("<i", raw, i + 1)[0]
            abs_rva = (va + i + 5) + rel
            if abs_rva == target:
                hits.append(va + i)
            i += 5
            continue
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
            i += 5
            continue
        i += 1
    return out

def window_before(call_rva, back=0x40):
    start = max(call_rva - back, va)
    insns = disasm_range(start, call_rva - start + 8)
    return [i for i in insns if i.address <= call_rva]

def time_ok():
    return time.time() < DEADLINE

print(f"=== Isol sha12={sha12} DIG filled_vec / e8_fillpush ===\n")

# Known APIs
ALLOC_568 = 0x55d730
PUSH = 0x2a4f6a          # grow/push inner
UNWRAP = 0x2a5410
LEN = 0x2a62c9
GETELEM = 0x2a5ca8
VEC_INIT_A = 0x2a4a37
VEC_INIT_B = 0x2a4b48
FILL_FAM = {0x1f9619, 0x1f9768, 0x1f99b2, 0x1fa9d9, 0x207462, 0x20760b, 0x207aef}
ENSURE = 0x1f70cf
PRE_LAST = 0x567a30
SOFTCAP_SITE = 0x2be519
CAPLESS_LO, CAPLESS_HI = 0x576000, 0x578280

# ========== A) All mov edx,0x568 / alloc(0x568) sites ==========
print("=== A) Isol-wide edx=0x568 / alloc 0x568 ===")
# BA 68 05 00 00 = mov edx, 0x568
pat_edx = b"\xBA\x68\x05\x00\x00"
sites_edx568 = []
i = 0
while True:
    j = raw.find(pat_edx, i)
    if j < 0:
        break
    sites_edx568.append(va + j)
    i = j + 1
print(f"  mov edx,0x568 sites={[hex(s) for s in sites_edx568]}")

# For each: nearby E8 to ALLOC_568?
for s in sites_edx568:
    e8s = e8_dests_in(s, 0x20)
    to_alloc = [(hex(a), hex(d)) for a, d in e8s if d == ALLOC_568]
    print(f"  @{s:06x}: next E8∩alloc={to_alloc}")
    for insn in disasm_range(s, 0x30)[:10]:
        print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Also find ALL E8→ALLOC_568
alloc_callers = find_e8_callers_all(ALLOC_568)
print(f"\n  ALL E8→@55d730 count={len(alloc_callers)}")
# classify by edx setup: look back for 0x568
alloc_568_true = []
alloc_other = []
for c in alloc_callers:
    if not time_ok():
        print("  TIME cutoff in alloc scan"); break
    win = window_before(c, 0x30)
    has568 = any("0x568" in insn.op_str for insn in win)
    # also check raw for BA68050000 in window
    off_c = rva2off(secs, c - 0x20)
    chunk_w = buf[off_c:off_c + 0x28]
    has568_raw = pat_edx in chunk_w
    if has568 or has568_raw:
        alloc_568_true.append(c)
    else:
        # sample edx
        edx_imm = None
        for insn in win:
            if insn.mnemonic == "mov" and insn.op_str.startswith("edx,"):
                edx_imm = insn.op_str
        alloc_other.append((c, edx_imm))

print(f"  alloc with edx=0x568: {[hex(s) for s in alloc_568_true]}")
print(f"  alloc other (first 15): {[(hex(c), e) for c,e in alloc_other[:15]]}")

# ========== B) All E8→@2a4f6a (push) — who / near 0x568? ==========
print("\n=== B) Isol-wide E8→@2a4f6a (push/grow) ===")
push_callers = find_e8_callers_all(PUSH)
print(f"  push callers count={len(push_callers)}")
# Classify: Capless? SoftCap? near 0x568? near fill?
push_in_capless = [c for c in push_callers if CAPLESS_LO <= c < CAPLESS_HI]
push_near_soft = [c for c in push_callers if 0x2be000 <= c < 0x2c0000]
push_near_prelast = [c for c in push_callers if 0x567000 <= c < 0x569000]
print(f"  in Capless={ [hex(c) for c in push_in_capless] }")
print(f"  near SoftCap-site(@2be*)={ [hex(c) for c in push_near_soft] }")
print(f"  near pre_last(@567*)={ [hex(c) for c in push_near_prelast] }")

# For each push caller: does window have 0x568 / unwrap / fill?
push_with_568 = []
push_with_unwrap = []
push_with_fill = []
for c in push_callers:
    if not time_ok():
        print("  TIME cutoff in push scan"); break
    # look at containing fn roughly: scan back to find prologue-ish, or ±0x200 E8s
    e8s_near = e8_dests_in(max(c - 0x200, va), 0x400)
    dests = {d for _, d in e8s_near}
    if ALLOC_568 in dests or any(
        "0x568" in insn.op_str for insn in disasm_range(max(c - 0x80, va), 0x100)
    ):
        push_with_568.append(c)
    if UNWRAP in dests:
        push_with_unwrap.append(c)
    if dests & FILL_FAM:
        push_with_fill.append(c)

print(f"  push±0x200 ∩alloc568/imm568: {[hex(c) for c in push_with_568]}")
print(f"  push±0x200 ∩unwrap@2a5410: {[hex(c) for c in push_with_unwrap]}")
print(f"  push±0x200 ∩fill-fam: {[hex(c) for c in push_with_fill]}")

# Sample first 12 push windows
print("\n  sample push windows (first 12):")
for c in push_callers[:12]:
    print(f"  --- @{c:06x} ---")
    for insn in window_before(c, 0x28):
        mark = " <<<" if insn.address == c else ""
        print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}{mark}")

# ========== C) Single fn that both fill AND push? ==========
print("\n=== C) Single E8 fill+push? (fn body calls fill-fam AND @2a4f6a) ===")
# For each fill caller, check if same ±0x400 window also calls push
fill_and_push = []
for fill_tgt in sorted(FILL_FAM):
    if not time_ok():
        break
    callers = find_e8_callers_all(fill_tgt)
    for c in callers:
        e8s = e8_dests_in(max(c - 0x100, va), 0x300)
        dests = {d for _, d in e8s}
        if PUSH in dests:
            fill_and_push.append((c, fill_tgt, "push_in_window"))
        # also check if the FUNCTION that contains fill also contains push —
        # approximate: scan forward from fill site for push within 0x800
        e8s_fwd = e8_dests_in(c, 0x800)
        if any(d == PUSH for _, d in e8s_fwd):
            fill_and_push.append((c, fill_tgt, "push_fwd_0x800"))

# unique
seen = set()
uniq = []
for item in fill_and_push:
    if item not in seen:
        seen.add(item)
        uniq.append(item)
print(f"  fill∩push co-window count={len(uniq)}")
for item in uniq[:20]:
    print(f"    fill_site=@{item[0]:06x} fill=@{item[1]:06x} kind={item[2]}")

# Also: any SINGLE E8 whose callee itself calls both fill and push?
print("\n  Callees that internally call fill-fam AND push:")
# Check push body for fill? and fill bodies for push?
push_body_e8 = e8_dests_in(PUSH, 0x200)
print(f"  @2a4f6a body E8={[hex(d) for _,d in push_body_e8[:15]]}")
print(f"  @2a4f6a∩fill={[hex(d) for _,d in push_body_e8 if d in FILL_FAM]}")
for ft in sorted(FILL_FAM):
    be = e8_dests_in(ft, 0x180)
    hit_push = [hex(d) for _, d in be if d == PUSH]
    if hit_push:
        print(f"  fill @{ft:06x} calls push: {hit_push}")

# ========== D) SoftCap lit path: Capless-only? other Caps? ==========
print("\n=== D) SoftCap lit path — Capless-only args container? ===")
# SoftCap-site @2be519 callers / what it does with +0x478 / args
print("  SoftCap-site @2be519 body (first 30 interesting):")
for insn in disasm_range(SOFTCAP_SITE, 0x120)[:30]:
    print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
e8s_site = e8_dests_in(SOFTCAP_SITE, 0x200)
print(f"  SoftCap-site E8={[hex(d) for _,d in e8s_site[:20]]}")

# Who calls SoftCap-site?
site_callers = find_e8_callers_all(SOFTCAP_SITE)
print(f"  SoftCap-site callers={[hex(c) for c in site_callers[:20]]} count={len(site_callers)}")

# Capless entry: who calls into Capless region?
# Find E8 from outside Capless into Capless
print("\n  External E8 → Capless region (entry points):")
entries = []
# scan .text for E8 landing in Capless
i = 0
while i < len(raw) - 5 and time_ok():
    if raw[i] == 0xE8:
        rel = struct.unpack_from("<i", raw, i + 1)[0]
        abs_rva = (va + i + 5) + rel
        src = va + i
        if CAPLESS_LO <= abs_rva < CAPLESS_HI and not (CAPLESS_LO <= src < CAPLESS_HI):
            entries.append((src, abs_rva))
        i += 5
        continue
    i += 1
print(f"  external→Capless entries count={len(entries)}")
for s, d in entries[:25]:
    print(f"    @{s:06x} → @{d:06x}")

# ========== E) +0x478 STOREs Isol-wide — any non-empty path? ==========
print("\n=== E) Isol-wide [rbp+0x478] STORE — filled? ===")
# Capstone scan for 0x478 in mov to memory
# This is expensive; scan known SoftCap-ish ranges + sample
ranges = [
    (0x576000, 0x579000, "Capless+"),
    (0x2be000, 0x2c2000, "SoftCap-site+"),
    (0x567000, 0x56a000, "pre_last+"),
    (0x58e000, 0x5a0000, "alt_frame@58e*"),
    (0x4d8000, 0x4d9000, "spill@4d8*"),
]
stores_478 = []
for lo, hi, label in ranges:
    if not time_ok():
        break
    off0 = rva2off(secs, lo)
    chunk = buf[off0:off0 + (hi - lo)]
    for insn in md.disasm(chunk, lo):
        if "0x478" in insn.op_str and insn.mnemonic == "mov" and insn.op_str.startswith("qword ptr"):
            stores_478.append((label, insn.address, f"{insn.mnemonic} {insn.op_str}"))
        elif "0x478" in insn.op_str and insn.mnemonic == "mov" and "[rbp" in insn.op_str and insn.op_str.index("[rbp") < insn.op_str.index(","):
            # mov [rbp+0x478], …
            stores_478.append((label, insn.address, f"{insn.mnemonic} {insn.op_str}"))

print(f"  [rbp+0x478] STORE-like hits:")
for label, a, s in stores_478:
    print(f"    [{label}] @{a:06x}: {s}")

# ========== F) @2a62c9 callers — any SoftCap lit with filled? ==========
print("\n=== F) @2a62c9 (len) callers — SoftCap lit context ===")
len_callers = find_e8_callers_all(LEN)
print(f"  @2a62c9 callers count={len(len_callers)}")
len_in_prelast = [c for c in len_callers if 0x567000 <= c < 0x569000]
len_in_capless = [c for c in len_callers if CAPLESS_LO <= c < CAPLESS_HI]
print(f"  in pre_last band={[hex(c) for c in len_in_prelast]}")
print(f"  in Capless={[hex(c) for c in len_in_capless]}")
# SoftCap lit path uses Capless empty → pre_last @56888d len=0 (prior DIG)
# Any OTHER len caller that could SoftCap lit use with filled vec?
print("\n  other @2a62c9 callers (first 20 windows):")
for c in len_callers[:20]:
    if c in len_in_prelast:
        continue
    print(f"  --- @{c:06x} ---")
    for insn in window_before(c, 0x20):
        mark = " <<<" if insn.address == c else ""
        print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}{mark}")

# ========== G) Is there ANY Isol SoftCap lit path that fills 0x568 then pushes? ==========
print("\n=== G) VERDICT probes ===")
# G1: Only 0x568 alloc in SoftCap lit = Capless empty shell
print(f"  G1 edx=0x568→alloc sites = {[hex(s) for s in alloc_568_true]}")
print(f"     Capless-only? {[hex(s) for s in alloc_568_true if CAPLESS_LO <= s < CAPLESS_HI]}")
print(f"     non-Capless 0x568 alloc = {[hex(s) for s in alloc_568_true if not (CAPLESS_LO <= s < CAPLESS_HI)]}")

# G2: Capless never push
print(f"  G2 Capless push count = {len(push_in_capless)}")

# G3: fill+push co-occurrence
print(f"  G3 fill∩push co-window = {len(uniq)} (0 ⇒ no single E8 fill+push glue)")

# G4: SoftCap lit args container source uniqueness
print(f"  G4 +0x478 STOREs in Capless+/SoftCap+/pre_last = see E")

elapsed = time.time() - T0
print(f"\n=== DONE elapsed={elapsed:.1f}s ===")
