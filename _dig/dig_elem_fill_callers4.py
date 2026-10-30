#!/usr/bin/env python3
"""DIG SoftCap 10.60 beat4: Capless-already-called @201* helpers vs fill/emit-arg; pin SoftCap @1ff5c7 parent."""
from pathlib import Path
import struct, hashlib, time, sys
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

T0=time.time(); DEADLINE=T0+85
ISOL=Path("/tmp/p1060_dig/bins/xlang_isol1060_alt_frame2.exe")
buf=ISOL.read_bytes()
assert hashlib.sha256(buf).hexdigest()[:12]=="9378df517f96"

def pe_secs(b):
    e=struct.unpack_from("<I",b,0x3C)[0]
    nsec=struct.unpack_from("<H",b,e+6)[0]
    opt=struct.unpack_from("<H",b,e+20)[0]
    sec=e+24+opt; out={}
    for i in range(nsec):
        o=sec+i*40; n=bytes(b[o:o+8]).split(b"\0")[0]
        vs,va,rs,ro=struct.unpack_from("<IIII",b,o+8); out[n]=(va,vs,ro,rs)
    return out
def rva2off(secs,r):
    for n,(va,vs,ro,rs) in secs.items():
        if va<=r<va+max(vs,rs): return ro+(r-va)
    raise ValueError(hex(r))
secs=pe_secs(buf); va,vs,ro,rs=secs[b".text"]; raw=buf[ro:ro+rs]
md=Cs(CS_ARCH_X86,CS_MODE_64)

def e8_dests_in(rva,n=0x120):
    off=rva2off(secs,rva); chunk=buf[off:off+n]; out=[]
    i=0
    while i<len(chunk)-5:
        if chunk[i]==0xE8:
            rel=struct.unpack_from("<i",chunk,i+1)[0]
            abs_rva=(rva+i+5)+rel
            if va<=abs_rva<va+vs: out.append((rva+i,abs_rva))
            i+=5; continue
        i+=1
    return out

def disasm_range(rva,n=0x60):
    off=rva2off(secs,rva); return list(md.disasm(buf[off:off+n],rva))

FILLS={0x1f9619,0x1f9768,0x1f99b2,0x1fa9d9,0x207462,0x20760b,0x207aef}
CHAIN={0x1f70cf,0x1f93e3,0x2a5410,0x2a4f6a,0x2a5ca8,0x205068,0x20374e,0x20a948,0x5d276c}|FILLS

# Capless already calls these kinded-adjacent
CANDS=[0x1ff2a3,0x1ffefe,0x20cd98,0x201d9f,0x200ff7,0x1ff2ef,0x201eeb,0x20203f,0x201f36,0x201ea0,0x201ddf]
print("=== Capless-called helpers: E8∩fill/chain? brief role ===")
for fn in CANDS:
    dests=e8_dests_in(fn,0x200)
    hit=[(hex(s),hex(d)) for s,d in dests if d in CHAIN]
    print(f"\n@{fn:06x} chain∩={hit if hit else 'NONE'}")
    for insn in disasm_range(fn,0x40)[:12]:
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    # also show first few E8 dests
    print(f"  E8 sample={[hex(d) for _,d in dests[:8]]}")

print("\n=== SoftCap @1ff5c7: rcx parent — who is [rbp-0x10] at @58f80f? ===")
# look back in @58f* for what sets [rbp-0x10]
for insn in disasm_range(0x58f700, 0x120)[:50]:
    if "rbp - 0x10" in insn.op_str or insn.address in (0x58f80f,):
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

print("\n=== Verdict summary ===")
print("""
parent kinded elem:
  - ensure API @1f70cf; constructors = fill-fam + @1fb/@1fd/@1ff/@200/@202/@203 kinded subsystem
  - SoftCap-reachable: SoftMega-ish @58f80f/@59447a → @1ff5c7 → ensure; RETURNS STATUS eax, NOT emit-arg ptr; NO fill/unwrap/push; NO +0x478
  - Capless: ZERO ensure/fill

@20a948:
  - thin wrappers → @1f9619/@1f9768; E8 callers=0; ImageBase data-refs=0 → DEAD; cannot single-point hook

@5d276c:
  - DOES fill (@1f9619/@1f9768); callers only @5d2c98/@5d2eb0 ← @5cf8f6/@5cfa07 (encoder writes [+0x124]); NOT Capless SoftCap lit; no Soft/Capless ups

Capless-called @201*/@1ff2*:
  - chain∩ fill/ensure/unwrap/push = (see above); prior known num_args/@20cd98 only

⇒ plant elem_fill / fill_5d / fill_20a: NOT isolatable (dead wrap OR wrong subsystem OR ensure≠filled emit-arg).
⇒ no p_ret_* this beat.
""")
print(f"DONE {time.time()-T0:.1f}s")
