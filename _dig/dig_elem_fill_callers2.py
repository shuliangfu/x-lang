#!/usr/bin/env python3
"""DIG SoftCap 10.60 beat2: real fill-wrapper entries, @5d276c subsystem, parent elem factory, SoftCap reachability."""
from pathlib import Path
import struct, hashlib, sys, time
from collections import Counter, defaultdict
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

T0 = time.time()
DEADLINE = T0 + 85

ISOL = Path("/tmp/p1060_dig/bins/xlang_isol1060_alt_frame2.exe")
buf = ISOL.read_bytes()
sha = hashlib.sha256(buf).hexdigest()
print(f"Isol sha12={sha[:12]} left={int(DEADLINE-time.time())}s")
assert sha[:12] == "9378df517f96"

def pe_secs(b):
    e = struct.unpack_from("<I", b, 0x3C)[0]
    nsec = struct.unpack_from("<H", b, e + 6)[0]
    opt = struct.unpack_from("<H", b, e + 20)[0]
    sec = e + 24 + opt
    out = {}
    for i in range(nsec):
        o = sec + i * 40
        n = bytes(b[o:o+8]).split(b"\0")[0]
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
raw = buf[ro:ro+rs]
md = Cs(CS_ARCH_X86, CS_MODE_64)

def find_e8_callers(target):
    out = []
    i = 0
    while i < len(raw) - 5:
        if raw[i] == 0xE8:
            rel = struct.unpack_from("<i", raw, i+1)[0]
            abs_rva = (va + i + 5) + rel
            if abs_rva == target:
                out.append(va + i)
            i += 5; continue
        i += 1
    return out

def fn_approx(rva, lookback=0x400):
    try:
        off = rva2off(secs, rva)
    except ValueError:
        return None
    start = max(ro, off - lookback)
    chunk = buf[start:off+1]
    base = rva - (off - start)
    last = None
    for j in range(len(chunk) - 3):
        if chunk[j] == 0x55 and chunk[j+1:j+4] == b"\x48\x89\xe5":
            last = base + j
    return last

def disasm_range(rva, n=0x80):
    off = rva2off(secs, rva)
    return list(md.disasm(buf[off:off+n], rva))

def e8_dests_in(rva, n=0x200):
    off = rva2off(secs, rva)
    chunk = buf[off:off+n]
    dests = []
    i = 0
    while i < len(chunk) - 5:
        if chunk[i] == 0xE8:
            rel = struct.unpack_from("<i", chunk, i+1)[0]
            abs_rva = (rva + i + 5) + rel
            # validate dest in .text
            if va <= abs_rva < va+vs:
                dests.append((rva + i, abs_rva))
            i += 5; continue
        i += 1
    return dests

CAPLESS_LO, CAPLESS_HI = 0x576000, 0x578280
SOFT_LO, SOFT_HI = 0x570000, 0x5a0000

# --- A: find real prologue near 0x20a948 ---
print("=== A) Find prologue near @20a948 (thin fill wrapper) ===")
off = rva2off(secs, 0x20a900)
chunk = buf[off:off+0x100]
for j in range(len(chunk)-3):
    if chunk[j]==0x55 and chunk[j+1:j+4]==b"\x48\x89\xe5":
        print(f"  prologue @{0x20a900+j:06x}")
print("disasm @20a960..:")
for insn in disasm_range(0x20a960, 0xa0)[:40]:
    print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Try common entries
for entry in [0x20a948, 0x20a960, 0x20a970, 0x20a980, 0x20a988, 0x20a989]:
    cs = find_e8_callers(entry)
    if cs:
        print(f"  ENTRY @{entry:06x} callers n={len(cs)}: {[hex(c) for c in cs[:15]]}")

# Broader: who calls @1f9619 (primary fill) — group by region
print("\n=== B) Callers of fill @1f9619 / @1f9768 / @1fa9d9 — by region ===")
FILLS = [0x1f9619, 0x1f9768, 0x1f99b2, 0x1fa9d9, 0x207462, 0x20760b, 0x207aef]
for fill in FILLS:
    cs = find_e8_callers(fill)
    regions = Counter()
    soft = []
    cap = []
    outside_1f = []
    for c in cs:
        if CAPLESS_LO <= c < CAPLESS_HI: regions["CAPLESS"] += 1; cap.append(c)
        elif SOFT_LO <= c < SOFT_HI: regions["SOFT"] += 1; soft.append(c)
        elif 0x1f9000 <= c < 0x1fb000: regions["fill-fam"] += 1
        elif 0x20a000 <= c < 0x20b000: regions["wrap20a"] += 1
        elif 0x5d0000 <= c < 0x5e0000: regions["5dxxxx"] += 1
        elif 0x200000 <= c < 0x210000: regions["20xxxx"] += 1
        elif 0x360000 <= c < 0x3a0000: regions["36-39"] += 1
        else: regions["other"] += 1; outside_1f.append(c)
    print(f"  fill @{fill:06x} n={len(cs)} regions={dict(regions)}")
    if soft: print(f"    SOFT={[hex(x) for x in soft]}")
    if cap: print(f"    CAPLESS={[hex(x) for x in cap]}")
    if outside_1f[:8]: print(f"    other sample={[hex(x) for x in outside_1f[:8]]}")

print("\n=== C) @5d276c subsystem: callers of its 2 sites' fns; what fills does it use ===")
# expand @5d276c body for real E8 to fill
print("E8 dests in @5d276c..+0x500 (validated):")
for s,d in e8_dests_in(0x5d276c, 0x500):
    print(f"  @{s:06x} → @{d:06x}")

# callers of the two neighbor fns
for entry in [0x5d276c, 0x5d2c98, 0x5d2eb0]:
    cs = find_e8_callers(entry)
    print(f"entry @{entry:06x} callers n={len(cs)}: {[hex(c) for c in cs[:20]]}")
    for c in cs[:6]:
        f = fn_approx(c)
        print(f"    from @{c:06x} fn≈{hex(f) if f else '?'}")

print("\n=== D) Parent kinded elem FACTORY: who ALLOCs then ensure? ===")
# Scan OUTSIDE ensure fns for call to known alloc @55d730 or small-object makers
# Also look for functions that RETURN a pointer after ensure (eax/rax = result)
# Key question: is there a 'mk_kinded_elem(size)' Isol-native API SoftCap could call once?

# Search for patterns: call ensure; ... store result somewhere with 0x478 — already 0
# Broader: callers of ensure OUTSIDE that themselves are called FROM SoftCap/Capless
ensure_callers = find_e8_callers(0x1f70cf)
ensure_fns = set()
for c in ensure_callers:
    f = fn_approx(c) or c
    ensure_fns.add(f)

print(f"ensure-using fns: {len(ensure_fns)}")
# For each ensure-fn, find WHO calls THAT fn — see if SoftCap reaches
soft_reach = []
cap_reach = []
reach_map = {}
for f in sorted(ensure_fns):
    if time.time() > DEADLINE - 20:
        print("TIME budget break on reach scan"); break
    # skip fill-fam internals
    if 0x1f9000 <= f < 0x1fb000: continue
    cs = find_e8_callers(f)
    soft_c = [c for c in cs if SOFT_LO <= c < SOFT_HI]
    cap_c = [c for c in cs if CAPLESS_LO <= c < CAPLESS_HI]
    if soft_c or cap_c:
        reach_map[f] = (soft_c, cap_c, cs[:8])
        soft_reach.extend(soft_c)
        cap_reach.extend(cap_c)
    # also note if called from 0x20a / 0x5d / Capless-adjacent
    notable = [c for c in cs if (0x20a000<=c<0x20c000) or (0x5d0000<=c<0x5e0000) or (SOFT_LO<=c<SOFT_HI)]
    if notable:
        print(f"  ensure-fn @{f:06x} notable callers={[hex(x) for x in notable[:10]]} total_n={len(cs)}")

print(f"\nSoftCap-reachable ensure-fns: {list(reach_map.keys())}")
print(f"soft_reach sites={ [hex(x) for x in soft_reach] }")
print(f"cap_reach sites={ [hex(x) for x in cap_reach] }")

print("\n=== E) Who calls @20a9xx wrapper that calls fill? scan wrap20a callers ===")
# From B, wrap20a region calls fill — find prologues in 0x20a900-0x20ab00 and their callers
wrap_entries = []
off = rva2off(secs, 0x20a900)
chunk = buf[off:off+0x200]
for j in range(len(chunk)-3):
    if chunk[j]==0x55 and chunk[j+1:j+4]==b"\x48\x89\xe5":
        wrap_entries.append(0x20a900+j)
print(f"wrap prologues: {[hex(x) for x in wrap_entries]}")
for e in wrap_entries:
    cs = find_e8_callers(e)
    print(f"  @{e:06x} callers n={len(cs)} {[hex(c) for c in cs[:15]]}")
    for c in cs[:5]:
        f = fn_approx(c)
        tag = ""
        if CAPLESS_LO<=c<CAPLESS_HI: tag=" CAPLESS"
        elif SOFT_LO<=c<SOFT_HI: tag=" SOFT"
        print(f"    @{c:06x} fn≈{hex(f) if f else '?'}{tag}")

print("\n=== F) Capless +0x478 STORE site @576631 context — any nearby kinded ptr? ===")
for insn in disasm_range(0x576600, 0x80)[:35]:
    print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

print("\n=== G) Is there ANY single E8 in Capless to kinded subsystem 0x1f6xxx-0x205xxx? ===")
cap_off = rva2off(secs, CAPLESS_LO)
cap_raw = buf[cap_off:cap_off+(CAPLESS_HI-CAPLESS_LO)]
kinded_hits = []
i = 0
while i < len(cap_raw)-5:
    if cap_raw[i]==0xE8:
        rel = struct.unpack_from("<i", cap_raw, i+1)[0]
        abs_rva = (CAPLESS_LO+i+5)+rel
        if 0x1f6000 <= abs_rva < 0x210000 or 0x5d2000 <= abs_rva < 0x5d4000:
            kinded_hits.append((CAPLESS_LO+i, abs_rva))
        i += 5; continue
    i += 1
print(f"Capless→kinded/5d hits n={len(kinded_hits)}")
for s,d in kinded_hits:
    print(f"  @{s:06x} → @{d:06x}")

print("\n=== H) @36xxxx / @39xxxx fill callers (prior note) — SoftCap? ===")
for fill in [0x1f9619, 0x1f9768]:
    cs = find_e8_callers(fill)
    for c in cs:
        if 0x360000 <= c < 0x3a0000:
            f = fn_approx(c)
            print(f"  fill@{fill:06x} ← @{c:06x} fn≈{hex(f) if f else '?'}")
            # one level up
            if f:
                ups = find_e8_callers(f)
                soft_ups = [u for u in ups if SOFT_LO<=u<SOFT_HI or CAPLESS_LO<=u<CAPLESS_HI]
                print(f"    ups n={len(ups)} soft/cap={[hex(u) for u in soft_ups[:8]]} sample={[hex(u) for u in ups[:6]]}")

print(f"\nDONE elapsed={time.time()-T0:.1f}s left={int(DEADLINE-time.time())}s")
if time.time() > DEADLINE: sys.exit(2)
