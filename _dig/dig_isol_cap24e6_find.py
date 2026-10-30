"""Find Isol Cap@0024e6-class: sub rsp,0x180 + kind0x30 SoftCap dispatch."""
from pathlib import Path
import struct, hashlib, os
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

cave = Path("C:/xlang_tmp/p1060/cave")
os.chdir(str(cave))
TT = bytearray((cave / "xlang_isol1060_TT.exe").read_bytes())
LIVE = bytearray((cave / "lab_LIVE_pret.exe").read_bytes())

def pe_secs(buf):
    e = struct.unpack_from("<I", buf, 0x3C)[0]
    nsec = struct.unpack_from("<H", buf, e + 6)[0]
    opt = struct.unpack_from("<H", buf, e + 20)[0]
    sec = e + 24 + opt
    out = {}
    for i in range(nsec):
        o = sec + i * 40
        n = bytes(buf[o:o+8]).split(b"\0")[0]
        vs, va, rs, ro = struct.unpack_from("<IIII", buf, o + 8)
        out[n] = (va, vs, ro, rs)
    return out

def off2rva(secs, off):
    for n, (va, vs, ro, rs) in secs.items():
        if ro <= off < ro + rs:
            return va + (off - ro)
    return None

def rva2off(buf, secs, r):
    for n, (va, vs, ro, rs) in secs.items():
        if va <= r < va + max(vs, rs):
            return ro + (r - va)
    raise ValueError(hex(r))

secs = pe_secs(TT)
md = Cs(CS_ARCH_X86, CS_MODE_64)
va, vs, ro, rs = secs[b".text"]
blob = bytes(TT[ro:ro+rs])

pat = bytes.fromhex("4881ec80010000")
print("=== Isol sub rsp,0x180 sites ===")
idx = 0
n = 0
while True:
    i = blob.find(pat, idx)
    if i < 0: break
    rva = va + i
    entry = None
    for back in range(1, 0x20):
        if TT[ro+i-back] == 0x55:
            ins0 = next(md.disasm(bytes(TT[ro+i-back:ro+i-back+4]), rva-back), None)
            if ins0 and ins0.mnemonic == "push":
                entry = rva - back
                break
    has30 = False
    kind30_at = None
    calls = []
    for insn in md.disasm(bytes(TT[ro+i:ro+i+0x200]), rva):
        if ", 0x30" in insn.op_str:
            has30 = True
            kind30_at = insn.address
        if insn.mnemonic == "call" and insn.op_str.startswith("0x"):
            calls.append((insn.address, int(insn.op_str, 16)))
    ent_s = f"{entry:06x}" if entry else "------"
    print(f"  sub@{rva:06x} entry=@{ent_s} has_kind30={has30}" + (f" @{kind30_at:06x}" if kind30_at else "") + f" ncalls={len(calls)}")
    if has30:
        print(f"    calls: {[(hex(a), hex(t)) for a,t in calls[:8]]}")
        for j in range(ro, ro+rs-5):
            if TT[j] != 0xE8: continue
            rel = struct.unpack_from("<i", TT, j+1)[0]
            src = off2rva(secs, j)
            if src is None: continue
            if entry and src + 5 + rel == entry:
                print(f"    caller @{src:06x} → entry")
            elif src + 5 + rel == rva:
                print(f"    caller @{src:06x} → sub")
    n += 1
    idx = i + 1
print(f"TOTAL sub rsp,0x180: {n}")

# Cap@0024e6 prologue signature
sig = bytes.fromhex("554881ec80010000488d6c2480")
print("\n=== Isol Cap@0024e6 prologue (push;sub 0x180;lea rbp) ===")
idx = 0
while True:
    i = blob.find(sig, idx)
    if i < 0: break
    rva = va + i
    print(f"  MATCH @{rva:06x}")
    for insn in md.disasm(bytes(TT[ro+i:ro+i+0xc0]), rva):
        print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    for j in range(ro, ro+rs-5):
        if TT[j] != 0xE8: continue
        rel = struct.unpack_from("<i", TT, j+1)[0]
        src = off2rva(secs, j)
        if src and src + 5 + rel == rva:
            print(f"    caller @{src:06x}")
    idx = i + 1

# LIVE Cap@0024e6 callers
secs_l = pe_secs(LIVE)
va_l, _, ro_l, rs_l = secs_l[b".text"]
print("\n=== LIVE Cap@0024e6 callers ===")
for j in range(ro_l, ro_l+rs_l-5):
    if LIVE[j] != 0xE8: continue
    rel = struct.unpack_from("<i", LIVE, j+1)[0]
    src = None
    for n2,(v,vs2,r,rs2) in secs_l.items():
        if r <= j < r+rs2:
            src = v + (j - r); break
    if src is None: continue
    if src + 5 + rel == 0x24e6:
        print(f"  LIVE @{src:06x} call Cap@0024e6")
        # disasm context
        o = j - 0x30
        for insn in md.disasm(bytes(LIVE[o:j+5]), src - 0x30):
            print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Isol SoftCap-site prologue
print("\n=== Isol SoftCap-site @2be519 prologue ===")
o = rva2off(TT, secs, 0x2be519)
for insn in md.disasm(bytes(TT[o:o+0x60]), 0x2be519):
    print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Capless @576f5e call @201f36 — name lookup used after SoftCap-site?
print("\n=== Capless mid-body SoftCap-related calls (576690..576900) ===")
o0 = rva2off(TT, secs, 0x576690)
for insn in md.disasm(bytes(TT[o0:o0+0x280]), 0x576690):
    if insn.mnemonic in ("call", "jmp", "je", "jne", "jle", "jg", "js", "jns") or "eax" in insn.op_str and insn.mnemonic == "mov":
        if insn.mnemonic == "call" or insn.address in range(0x5766b0, 0x5766d0) or insn.address in range(0x576740, 0x576760):
            print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# site_emit_pass root: what size query SoftCap lit hits
print("\n=== SoftCap-site size query path @2be760..2be7c0 ===")
o = rva2off(TT, secs, 0x2be760)
for insn in md.disasm(bytes(TT[o:o+0x60]), 0x2be760):
    print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

print("\nDONE")
