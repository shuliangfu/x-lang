"""DIG fwd_46_967_sret #22: full fixup in INT3 cave @0x559821; trampoline @57bbae.
Capless x+1 plant + c1toc2 + let_sret + main_imm9 → all-green Isol host (no USER post-patch).
"""
from pathlib import Path
import struct, hashlib, subprocess, time
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

CAVE = Path("C:/xlang_tmp/p1060/cave")
BASE = CAVE / "host_967_sret_tr460.exe"
SRCS = ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x", "_var_let.x"]
CAVE_RVA = 0x559821
md = Cs(CS_ARCH_X86, CS_MODE_64)

def P(*a): print(*a, flush=True)
def pe_secs(buf):
    e = struct.unpack_from("<I", buf, 0x3C)[0]
    nsec = struct.unpack_from("<H", buf, e+6)[0]; opt = struct.unpack_from("<H", buf, e+20)[0]
    sec = e+24+opt; secs = {}
    for i in range(nsec):
        o = sec+i*40; n = bytes(buf[o:o+8]).split(b"\0")[0]
        vs,va,rs,ro = struct.unpack_from("<IIII", buf, o+8); secs[n] = (va,vs,ro,rs)
    return secs
def rva2off(buf, secs, r):
    for n,(va,vs,ro,rs) in secs.items():
        if va <= r < va+max(vs,rs): return ro+(r-va)
    raise ValueError(hex(r))
def tag_of(crc):
    return {0:"OK", 0x80000003:"INT3", 0xC0000409:"GS", 0xC0000005:"AV"}.get(crc&0xffffffff, hex(crc&0xffffffff))
def run(h, src, prefix):
    out = CAVE/f"{prefix}_{Path(src).stem}.exe"
    r = subprocess.run([str(h), str(CAVE/src), "-o", str(out)], capture_output=True, timeout=8)
    return r.returncode&0xffffffff, out if out.exists() and out.stat().st_size>0 else None
def run_bin(exe):
    return subprocess.run([str(exe)], capture_output=True, timeout=3).returncode & 0xffffffff
def save(pe, name):
    p = CAVE/name; p.write_bytes(bytes(pe)); return p

def plant_capless(pe, secs, payload):
    n = len(payload); assert 1 <= n <= 16
    pe = bytearray(pe)
    off = rva2off(pe, secs, 0x57ba3b)
    pe[off:off+64] = b"".join(bytes([0xc6,0x43,i,(payload[i] if i<n else 0x90)]) for i in range(16))
    pe[rva2off(pe,secs,0x57ba94):rva2off(pe,secs,0x57ba94)+5] = bytes([0xb8,n,0,0,0])
    return pe

def build_fixup_body(base_r=CAVE_RVA, end_r=0x57bd4e, scan_back=0x180):
    """Same 3-scan fixup as dig21; ends with jmp end_r."""
    f = bytearray()
    def E(h): f.extend(bytes.fromhex(h) if isinstance(h,str) else h)
    def p32(at,tgt): struct.pack_into("<i",f,at+2,tgt-(at+6))
    def p8(at,tgt): f[at+1]=(tgt-(at+2))&0xff
    E("4883ec20")
    E("b800000000"); E("8985e0fdffff")
    E("b830007902"); E("8985dcfdffff")
    E("488b45e8"); E("8b95dcfdffff"); E("4863d2"); E("4801d0"); E("488985d8fdffff")
    E("488b45e8"); E("8b95e0fdffff"); E("4863d2"); E("4801d0"); E("8b00"); E("8985e4fdffff")
    E("3d04000000"); jl0=len(f); E("0f8c00000000")
    # scan1 c1→c2
    E("488b85d8fdffff"); E("8b95e4fdffff"); E("4863d2"); E("488d3410")
    E("4889f7"); E("4881ef"+struct.pack("<I",scan_back).hex())
    E("488b85d8fdffff"); E("4839c7"); E("480f42f8")
    L1=len(f); E("4839f7"); J1=len(f); E("0f8300000000")
    E("803f48"); a1=len(f); E("7500")
    E("807f0189"); a2=len(f); E("7500")
    E("807f02c1"); a3=len(f); E("7500")
    E("807f03e8"); a4=len(f); E("7500")
    E("c64702c2"); E("eb00"); s1=len(f)-1
    N1=len(f); E("48ffc7"); b1=len(f); E("e900000000")
    S1=len(f)
    # scan2 let_sret
    E("488b85d8fdffff"); E("8b95e4fdffff"); E("4863d2"); E("488d3410")
    E("4889f7"); E("4881ef"+struct.pack("<I",scan_back).hex())
    E("488b85d8fdffff"); E("4839c7"); E("480f42f8")
    L2=len(f); E("4839f7"); J2=len(f); E("0f8300000000")
    E("803f48"); c1=len(f); E("7500")
    E("807f018d"); c2=len(f); E("7500")
    E("807f0245"); c3=len(f); E("7500")
    E("807f03c8"); c4=len(f); E("7500")
    E("c647018b"); E("c64703b0"); E("eb00"); s2=len(f)-1
    N2=len(f); E("48ffc7"); b2=len(f); E("e900000000")
    S2=len(f)
    # scan3 main_imm9
    E("488b85d8fdffff"); E("8b95e4fdffff"); E("4863d2"); E("488d3410")
    E("4889f7"); E("4881ef"+struct.pack("<I",scan_back).hex())
    E("488b85d8fdffff"); E("4839c7"); E("480f42f8")
    L3=len(f); E("4839f7"); J3=len(f); E("0f8300000000")
    # 488d45d8
    E("803f48"); d1=len(f); E("7500")
    E("807f018d"); d2=len(f); E("7500")
    E("807f0245"); d3=len(f); E("7500")
    E("807f03d8"); d4=len(f); E("7500")
    # 4889c1
    E("807f0448"); d5=len(f); E("7500")
    E("807f0589"); d6=len(f); E("7500")
    E("807f06c1"); d7=len(f); E("7500")
    # 4883ec20
    E("807f0748"); d8=len(f); E("7500")
    E("807f0883"); d9=len(f); E("7500")
    E("807f09ec"); d10=len(f); E("7500")
    E("807f0a20"); d11=len(f); E("7500")
    # 488b45f0
    E("807f0b48"); d12=len(f); E("7500")
    E("807f0c8b"); d13=len(f); E("7500")
    E("807f0d45"); d14=len(f); E("7500")
    E("807f0ef0"); d15=len(f); E("7500")
    # 48ffc0
    E("807f0f48"); d16=len(f); E("7500")
    E("807f10ff"); d17=len(f); E("7500")
    E("807f11c0"); d18=len(f); E("7500")
    # 4889c2
    E("807f1248"); d19=len(f); E("7500")
    E("807f1389"); d20=len(f); E("7500")
    E("807f14c2"); d21=len(f); E("7500")
    # patch at rdi+0xb: b809000000 4889c2 9090
    E("c6470bb8"); E("c6470c09"); E("c6470d00"); E("c6470e00"); E("c6470f00")
    E("c6471048"); E("c6471189"); E("c64712c2")
    E("c6471390"); E("c6471490")
    E("eb00"); s3=len(f)-1
    N3=len(f); E("48ffc7"); b3=len(f); E("e900000000")
    S3=len(f)
    E("4883c420"); e9=len(f); E("e900000000")
    p32(jl0,S3); p32(J1,S1); p32(J2,S2); p32(J3,S3)
    for a in (a1,a2,a3,a4): p8(a,N1)
    f[s1]=(S1-(s1+1))&0xff; struct.pack_into("<i",f,b1+1,L1-(b1+5))
    for a in (c1,c2,c3,c4): p8(a,N2)
    f[s2]=(S2-(s2+1))&0xff; struct.pack_into("<i",f,b2+1,L2-(b2+5))
    for a in (d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20,d21): p8(a,N3)
    f[s3]=(S3-(s3+1))&0xff; struct.pack_into("<i",f,b3+1,L3-(b3+5))
    struct.pack_into("<i",f,e9+1,end_r-(base_r+e9+5))
    return f

def apply(pe, secs):
    pe = bytearray(pe)
    body = build_fixup_body()
    P(f"  body len={len(body)} @cave {CAVE_RVA:#x}")
    # write body into INT3 cave
    coff = rva2off(pe, secs, CAVE_RVA)
    assert pe[coff:coff+4] == b"\xcc"*4, pe[coff:coff+8].hex()
    pe[coff:coff+len(body)] = body
    # trampoline @57bbae: jmp CAVE_RVA; nop pad to 57bd4e
    tramp = bytearray()
    tramp.append(0xe9)
    tramp.extend(struct.pack("<i", CAVE_RVA - (0x57bbae + 5)))
    pad = 0x57bd4e - 0x57bbae - len(tramp)
    tramp.extend(b"\x90"*pad)
    pe[rva2off(pe,secs,0x57bbae):rva2off(pe,secs,0x57bd4e)] = tramp
    P(f"  trampoline jmp {CAVE_RVA:#x} pad={pad}")
    return pe

def dump(buf, label, start, n=0x70):
    secs=pe_secs(buf); va,vs,ro,rs=secs[b".text"]; w=buf[ro:ro+rs]
    P(f"  dump {label}:")
    for insn in md.disasm(w[start:start+n], start):
        P(f"    {insn.address:06x}: {insn.bytes.hex():18s} {insn.mnemonic} {insn.op_str}")

t0=time.time()
base=bytearray(BASE.read_bytes()); secs=pe_secs(base)
XP1=bytes.fromhex("4883ec20488b45f048ffc04889c2")
P(f"BASE sha={hashlib.sha256(base).hexdigest()[:12]}")
pe=plant_capless(base, secs, XP1)
pe=apply(pe, pe_secs(pe))
h=save(pe,"host_967_s24.exe")
P(f"HOST sha={hashlib.sha256(h.read_bytes()).hexdigest()[:12]}")

for s in SRCS:
    crc, outx = run(h, s, "_g24")
    user="n/a"; rt="-"
    if outx:
        user=hashlib.sha256(outx.read_bytes()).hexdigest()[:12]
        rc=run_bin(outx); rt=tag_of(rc) if rc>3 else str(rc)
    known={"5c6778769c3c":"LIT","36d26fcc9657":"LOC","d9ffcb750e0b":"S19A","677376eba3d0":"LET21B","9439f8857d57":"FWD21B"}
    P(f"  {s:16s} host={tag_of(crc):8s} USER={user} run={rt:8s} {known.get(user,'')}")
    if outx and s in ("_var_let.x","p_ret_fwd.x"):
        dump(outx.read_bytes(), s, 0x4f8 if s=="_var_let.x" else 0x548)


# verify loop-backs in cave
secs2=pe_secs(h.read_bytes()); va2,_,_,_=secs2[b".text"]
w2=h.read_bytes(); ro2=secs2[b".text"][2]; rs2=secs2[b".text"][3]
ww=w2[ro2:ro2+rs2]
P("  verify cave loop-backs:")
for insn in md.disasm(ww[CAVE_RVA-va2:CAVE_RVA-va2+len(build_fixup_body())], CAVE_RVA):
    if insn.mnemonic=="jmp" and insn.bytes[0]==0xeb:
        P(f"    {insn.address:06x}: {insn.bytes.hex()} {insn.mnemonic} {insn.op_str}")

P(f"\n=== SUMMARY elapsed={time.time()-t0:.1f}s ===")
