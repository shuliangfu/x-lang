#!/usr/bin/env python3
"""DIG SoftCap 10.60 beat3: SoftCap→@1ff5c7 ensure path; @5cf→@5d276c chain; wrap20a dead?; plant isolatable?"""
from pathlib import Path
import struct, hashlib, sys, time
from collections import Counter
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

T0 = time.time(); DEADLINE = T0 + 85
ISOL = Path("/tmp/p1060_dig/bins/xlang_isol1060_alt_frame2.exe")
buf = ISOL.read_bytes()
assert hashlib.sha256(buf).hexdigest()[:12] == "9378df517f96"

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

def fn_approx(rva, lookback=0x500):
    try: off = rva2off(secs, rva)
    except ValueError: return None
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
            if va <= abs_rva < va+vs:
                dests.append((rva + i, abs_rva))
            i += 5; continue
        i += 1
    return dests

CAPLESS_LO, CAPLESS_HI = 0x576000, 0x578280
SOFT_LO, SOFT_HI = 0x570000, 0x5a0000

print("=== A) @1ff5c7 body + SoftCap call sites @58f80f / @59447a ===")
for insn in disasm_range(0x1ff5c7, 0xc0)[:45]:
    print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
print("E8 in @1ff5c7..+0x180:")
for s,d in e8_dests_in(0x1ff5c7, 0x180):
    print(f"  @{s:06x} → @{d:06x}")

for site in [0x58f80f, 0x59447a]:
    f = fn_approx(site, 0x800)
    print(f"\n--- SoftCap site @{site:06x} fn≈{hex(f) if f else '?'} ---")
    for insn in disasm_range(site - 0x40, 0xa0)[:40]:
        mark = " <<<" if insn.address == site else ""
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}{mark}")
    # is this SoftMega @57ef78 / Capless / SoftCap-full?
    if f:
        print(f"  fn start @{f:06x}; distance from SoftMega@57ef78={f-0x57ef78 if f else '?'}")
        print(f"  in Capless? {CAPLESS_LO<=f<CAPLESS_HI}; SoftMega-ish 0x57e000..0x5a0000? {0x57e000<=f<0x5a0000}")

print("\n=== B) Does @1ff5c7 produce filled emit-arg? calls fill? returns what? ===")
# already printed E8s; check if any fill
FILLS = {0x1f9619,0x1f9768,0x1f99b2,0x1fa9d9,0x207462,0x20760b,0x207aef,0x20a948,0x20a98a}
ens = e8_dests_in(0x1ff5c7, 0x200)
print("fill∩?", [(hex(s),hex(d)) for s,d in ens if d in FILLS])
print("ensure∩?", [(hex(s),hex(d)) for s,d in ens if d==0x1f70cf])
print("unwrap/push∩?", [(hex(s),hex(d)) for s,d in ens if d in (0x2a5410,0x2a4f6a,0x2a5ca8,0x205068)])

print("\n=== C) @5cf8f6 / @5cfa07 chain upward (who drives @5d276c fill) ===")
for site in [0x5cf8f6, 0x5cfa07]:
    f = fn_approx(site, 0x800)
    print(f"\nsite @{site:06x} fn≈{hex(f) if f else '?'}")
    for insn in disasm_range(site-0x20, 0x50)[:20]:
        mark = " <<<" if insn.address==site else ""
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}{mark}")
    if f:
        ups = find_e8_callers(f)
        print(f"  ups of fn n={len(ups)}: {[hex(u) for u in ups[:15]]}")
        for u in ups[:8]:
            uf = fn_approx(u)
            tag=""
            if CAPLESS_LO<=u<CAPLESS_HI: tag=" CAPLESS"
            elif SOFT_LO<=u<SOFT_HI: tag=" SOFT"
            print(f"    @{u:06x} fn≈{hex(uf) if uf else '?'}{tag}")
            # one more level if small
            if uf and len(ups)<=3:
                ups2 = find_e8_callers(uf)
                print(f"      ups2 n={len(ups2)} {[hex(x) for x in ups2[:8]]}")

print("\n=== D) wrap20a dead? also check qword ptr tables / FF15 / mov rax imm ===")
# scan .rdata/.data for absolute addresses 0x14020a948 etc — PE image base?
e_lfanew = struct.unpack_from("<I", buf, 0x3C)[0]
image_base = struct.unpack_from("<Q", buf, e_lfanew + 24 + 24)[0]  # OptionalHeader.ImageBase for PE32+
print(f"ImageBase={hex(image_base)}")
for entry in [0x20a948, 0x20a98a, 0x20a91a, 0x20a9cc, 0x5d276c]:
    abs_addr = image_base + entry
    pat = struct.pack("<Q", abs_addr)
    hits = []
    # search whole file except the function itself
    idx = 0
    while True:
        j = buf.find(pat, idx)
        if j < 0: break
        hits.append(j)
        idx = j+1
        if len(hits) > 20: break
    print(f"  abs {hex(abs_addr)} (@{entry:06x}) data-refs n={len(hits)} file_offs={[hex(h) for h in hits[:8]]}")

print("\n=== E) @36/@39 fill callers (1fa9d9 / 207462) SoftCap reach? ===")
for fill in [0x1fa9d9, 0x207462, 0x1f99b2, 0x207aef]:
    cs = find_e8_callers(fill)
    for c in cs:
        if 0x360000 <= c < 0x3a0000 or 0x3e0000 <= c < 0x420000:
            f = fn_approx(c)
            print(f"  fill@{fill:06x} ← @{c:06x} fn≈{hex(f) if f else '?'}")
            if f:
                ups = find_e8_callers(f)
                soft = [u for u in ups if SOFT_LO<=u<SOFT_HI or CAPLESS_LO<=u<CAPLESS_HI]
                print(f"    ups n={len(ups)} soft/cap={[hex(x) for x in soft]} sample={[hex(x) for x in ups[:6]]}")

print("\n=== F) Soft sites @58f80f/@59447a — what is stored after ensure call? 0x478? ===")
for site in [0x58f80f, 0x59447a]:
    print(f"\npost-call window @{site:06x}:")
    for insn in disasm_range(site, 0x60)[:25]:
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    # scan fn for 0x478 disp
    f = fn_approx(site, 0x800) or site
    off = rva2off(secs, f)
    chunk = buf[off:off+0x600]
    hits478 = [f+j for j in range(len(chunk)-4) if chunk[j:j+4]==b"\x78\x04\x00\x00"]
    print(f"  0x478 imm in fn: {[hex(h) for h in hits478[:10]]}")

print("\n=== G) Plant isolatable? checklist ===")
print("""
Criteria for isolatable plant:
  1. Single semantic call that produces @205068-compatible filled elem OR filled vec for +0x478
  2. SoftCap/Capless can reach with ONE site change (not mega/arg-loop)
Findings:
  - @20a948 family: E8 callers=0 AND need data-ref check (D)
  - @5d276c: fills yes, but driven by @5cf* subsystem ≠ Capless SoftCap lit path
  - SoftCap→@1ff5c7: ensure path exists at SoftMega-ish @58f/@594 — check if filled emit-arg
  - Capless→fill/ensure/unwrap/push: 0
  - Capless→kinded helpers: only num_args/@20cd98/@201* (known non-fill)
""")

print(f"DONE elapsed={time.time()-T0:.1f}s left={int(DEADLINE-time.time())}s")
