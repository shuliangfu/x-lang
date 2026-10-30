#!/usr/bin/env python3
"""DIG SoftCap 10.60: parent kinded elem constructors + @5d276c/@20a948 fill callers.
Ask: can any single-point feed Capless +0x478?
Ban tip@121278/join/epi/mega/LIVE SoftCap transplant/arg-loop.
"""
from pathlib import Path
import struct, hashlib, sys, time
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

T0 = time.time()
DEADLINE = T0 + 85  # kill before 90s

ISOL = Path("/tmp/p1060_dig/bins/xlang_isol1060_alt_frame2.exe")
buf = ISOL.read_bytes()
sha = hashlib.sha256(buf).hexdigest()
print(f"Isol sha12={sha[:12]} size={len(buf)} left={int(DEADLINE-time.time())}s")
assert sha[:12] == "9378df517f96", sha[:12]

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
md.detail = False

def find_e8_callers(target):
    out = []
    i = 0
    while i < len(raw) - 5:
        if raw[i] == 0xE8:
            rel = struct.unpack_from("<i", raw, i+1)[0]
            abs_rva = (va + i + 5) + rel
            if abs_rva == target:
                out.append(va + i)
            i += 5
            continue
        i += 1
    return out

def fn_approx(rva, lookback=0x200):
    """Walk back for push rbp; mov rbp,rsp prologue."""
    off = rva2off(secs, rva)
    start = max(ro, off - lookback)
    chunk = buf[start:off+1]
    base = rva - (off - start)
    # search last push rbp (55) + mov rbp,rsp (48 89 e5)
    last = None
    for j in range(len(chunk) - 3):
        if chunk[j] == 0x55 and chunk[j+1:j+4] == b"\x48\x89\xe5":
            last = base + j
    return last

def disasm_range(rva, n=0x80):
    off = rva2off(secs, rva)
    return list(md.disasm(buf[off:off+n], rva))

def e8_dests_in(rva, n=0x200):
    """Collect E8 destinations in [rva, rva+n)."""
    off = rva2off(secs, rva)
    chunk = buf[off:off+n]
    dests = []
    i = 0
    while i < len(chunk) - 5:
        if chunk[i] == 0xE8:
            rel = struct.unpack_from("<i", chunk, i+1)[0]
            abs_rva = (rva + i + 5) + rel
            dests.append((rva + i, abs_rva))
            i += 5
            continue
        i += 1
    return dests

CAPLESS_LO, CAPLESS_HI = 0x576000, 0x578280
FILL_FAMILY = {
    0x1f9619, 0x1f9768, 0x1f99b2, 0x1fa9d9,
    0x207462, 0x20760b, 0x207aef,
    0x1f70cf,  # ensure
    0x1f93e3,  # get/make slot
}

print("\n=== A) @20a948 body (thin fill wrapper?) ===")
for insn in disasm_range(0x20a948, 0x60)[:40]:
    print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

print("\n=== B) @5d276c body (fill caller region) ===")
for insn in disasm_range(0x5d276c, 0xa0)[:50]:
    print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

print("\n=== C) E8 callers of @20a948 ===")
c_20 = find_e8_callers(0x20a948)
print(f"n={len(c_20)}")
for c in c_20[:60]:
    f = fn_approx(c)
    tag = " CAPLESS" if CAPLESS_LO <= c < CAPLESS_HI else ""
    soft = " SoftCap-ish" if 0x570000 <= c < 0x5a0000 else ""
    print(f"  caller @{c:06x} fn≈{('0x%06x'%f) if f else '?'}{tag}{soft}")

print("\n=== D) E8 callers of @5d276c ===")
c_5d = find_e8_callers(0x5d276c)
print(f"n={len(c_5d)}")
for c in c_5d[:60]:
    f = fn_approx(c)
    tag = " CAPLESS" if CAPLESS_LO <= c < CAPLESS_HI else ""
    soft = " SoftCap-ish" if 0x570000 <= c < 0x5a0000 else ""
    print(f"  caller @{c:06x} fn≈{('0x%06x'%f) if f else '?'}{tag}{soft}")

print("\n=== E) What does @20a948 call? (E8 dests) ===")
for site, dest in e8_dests_in(0x20a948, 0x80):
    print(f"  @{site:06x} → @{dest:06x}")

print("\n=== F) What does @5d276c call? (E8 dests in 0x200) ===")
for site, dest in e8_dests_in(0x5d276c, 0x200):
    print(f"  @{site:06x} → @{dest:06x}")

# Also try fn start if 5d276c is mid-fn
f5 = fn_approx(0x5d276c, 0x400)
print(f"fn≈ of @5d276c = {('0x%06x'%f5) if f5 else '?'}")
if f5 and f5 != 0x5d276c:
    print("--- from fn start ---")
    for insn in disasm_range(f5, 0x40)[:20]:
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    for site, dest in e8_dests_in(f5, min(0x400, 0x5d276c - f5 + 0x100)):
        print(f"  @{site:06x} → @{dest:06x}")

print(f"\nleft={int(DEADLINE-time.time())}s elapsed={time.time()-T0:.1f}s")
if time.time() > DEADLINE:
    print("TIMEOUT"); sys.exit(2)

print("\n=== G) E8 → @1f70cf (ensure kinded parent) — group by fn ===")
c_ens = find_e8_callers(0x1f70cf)
from collections import Counter
fn_counts = Counter()
fn_sites = {}
for c in c_ens:
    f = fn_approx(c) or c
    fn_counts[f] += 1
    fn_sites.setdefault(f, []).append(c)
print(f"n_call_sites={len(c_ens)} n_fns={len(fn_counts)}")
for f, n in fn_counts.most_common(40):
    in_fill = f in FILL_FAMILY or (0x1f9000 <= f < 0x1fb000) or (0x207000 <= f < 0x208000)
    tag = " FILL-fam" if in_fill else " OUTSIDE"
    soft = " SoftCap-ish" if 0x570000 <= f < 0x5a0000 else ""
    cap = " CAPLESS" if CAPLESS_LO <= f < CAPLESS_HI else ""
    print(f"  fn≈@{f:06x} ×{n}{tag}{soft}{cap}")

outside = [(f,n) for f,n in fn_counts.items()
           if not (f in FILL_FAMILY or (0x1f9000 <= f < 0x1fb000) or (0x207000 <= f < 0x208000))]
print(f"\nOUTSIDE fill-fam ensure callers: {len(outside)}")
for f, n in sorted(outside, key=lambda x: -x[1])[:30]:
    print(f"  OUT fn≈@{f:06x} ×{n} sites={[hex(s) for s in fn_sites[f][:4]]}")

print("\n=== H) Who constructs kinded elem? Look for alloc+ensure patterns near OUTSIDE ===")
# For top outside fns: see if they call @55d730/@24afe0 alloc then ensure
ALLOC_CANDS = {0x55d730, 0x24afe0, 0x1f77e1, 0x1f61f7}
for f, n in sorted(outside, key=lambda x: -x[1])[:12]:
    dests = e8_dests_in(f, 0x300)
    interesting = [(s,d) for s,d in dests if d in ALLOC_CANDS or d == 0x1f70cf or d in FILL_FAMILY
                   or (0x1f9000 <= d < 0x1fb000) or d in (0x20a948, 0x5d276c, 0x2a5410, 0x2a4f6a, 0x205068)]
    print(f"  fn≈@{f:06x}: interesting E8={[('@%06x→@%06x'%(s,d)) for s,d in interesting[:12]]}")

print("\n=== I) Capless window E8 ∩ {fill, ensure, unwrap, push, 20a948, 5d276c} ===")
TARGETS = FILL_FAMILY | {0x20a948, 0x5d276c, 0x2a5410, 0x2a4f6a, 0x2a5ca8, 0x205068, 0x20374e, 0x1f70cf}
cap_off = rva2off(secs, CAPLESS_LO)
cap_len = CAPLESS_HI - CAPLESS_LO
cap_raw = buf[cap_off:cap_off+cap_len]
hits = []
i = 0
while i < len(cap_raw) - 5:
    if cap_raw[i] == 0xE8:
        rel = struct.unpack_from("<i", cap_raw, i+1)[0]
        abs_rva = (CAPLESS_LO + i + 5) + rel
        if abs_rva in TARGETS:
            hits.append((CAPLESS_LO + i, abs_rva))
        i += 5
        continue
    i += 1
print(f"Capless hits n={len(hits)}")
for s, d in hits:
    print(f"  @{s:06x} → @{d:06x}")

print("\n=== J) SoftCap-ish 0x570000..0x5a0000 callers of fill wrappers ===")
for name, callers in [("@20a948", c_20), ("@5d276c", c_5d)]:
    soft_c = [c for c in callers if 0x570000 <= c < 0x5a0000]
    print(f"  {name} soft-ish callers n={len(soft_c)}: {[hex(c) for c in soft_c[:20]]}")

print("\n=== K) Disasm SoftCap-ish callers of @20a948 / @5d276c (context) ===")
for c in ([x for x in c_20 if 0x570000 <= x < 0x5a0000] + [x for x in c_5d if 0x570000 <= x < 0x5a0000])[:8]:
    f = fn_approx(c, 0x300) or (c - 0x40)
    print(f"\n--- around caller @{c:06x} fn≈@{f:06x} ---")
    for insn in disasm_range(max(f, c-0x30), 0x60)[:25]:
        mark = " <<<" if insn.address == c else ""
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}{mark}")

print("\n=== L) Does any fill-result STORE into [reg+0x478]? scan fill callers for 0x478 disp ===")
# In fns that call @20a948 or @5d276c, look for mov [r+0x478], *
DISP478 = []
for c in (c_20 + c_5d)[:80]:
    f = fn_approx(c, 0x400) or c
    # scan 0x400 bytes from fn
    try:
        off = rva2off(secs, f)
    except ValueError:
        continue
    chunk = buf[off:off+0x400]
    # look for disp32 = 0x478 in ModRM sib forms: C7 87 78 04 00 00 / 89 87 78 04 00 00 / 48 89 xx 78 04 00 00
    for j in range(len(chunk) - 6):
        # any 78 04 00 00 as little-endian 0x478
        if chunk[j:j+4] == b"\x78\x04\x00\x00":
            DISP478.append((f, f+j, c))
            break
print(f"fns with 0x478 imm near fill-caller: n={len(DISP478)}")
for f, site, c in DISP478[:20]:
    print(f"  fn≈@{f:06x} imm478@{site:06x} (via fill-call @{c:06x})")

print("\n=== M) @1f70cf body (ensure) brief ===")
for insn in disasm_range(0x1f70cf, 0x60)[:30]:
    print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

print(f"\nDONE elapsed={time.time()-T0:.1f}s left={int(DEADLINE-time.time())}s")
if time.time() > DEADLINE:
    sys.exit(2)
