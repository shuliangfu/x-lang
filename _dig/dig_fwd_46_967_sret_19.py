"""DIG fwd_46_967_sret #19: Capless plant sub20+imm9→rdx + c1→c2.
fw→mk ABI already green (s18a); main missing rdx=9 → exit1.
Plant imm9: main→fw gets 9; fw Capless 9 overwritten by BinaryExpr→rdx.
"""
from pathlib import Path
import struct, hashlib, subprocess, time
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

CAVE = Path("C:/xlang_tmp/p1060/cave")
BASE = CAVE / "host_967_sret_tr460.exe"
SRCS = ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x", "_var_let.x"]
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
    r = subprocess.run([str(exe)], capture_output=True, timeout=3)
    return r.returncode&0xffffffff, r.stdout[:80]
def save(pe, name):
    p = CAVE/name; p.write_bytes(bytes(pe)); return p

def plant_capless(pe, secs, payload: bytes, label):
    n = len(payload)
    assert 1 <= n <= 16, n
    pe = bytearray(pe)
    off = rva2off(pe, secs, 0x57ba3b)
    full = b"".join(bytes([0xc6, 0x43, i, (payload[i] if i < n else 0x90)]) for i in range(16))
    pe[off:off+64] = full
    loff = rva2off(pe, secs, 0x57ba94)
    assert pe[loff] == 0xb8, pe[loff:loff+5].hex()
    pe[loff:loff+5] = bytes([0xb8, n, 0, 0, 0])
    P(f"  {label}: Capless payload={payload.hex()} len={n}")
    return pe

def build_c1toc2(base_r=0x57bbae, end_r=0x57bd4e, scan_back=0x100):
    fixup = bytearray()
    def E(h): fixup.extend(bytes.fromhex(h) if isinstance(h,str) else h)
    E("4883ec20")
    E("b800000000"); E("8985e0fdffff")
    E("b830007902"); E("8985dcfdffff")
    E("488b45e8"); E("8b95dcfdffff"); E("4863d2"); E("4801d0"); E("488985d8fdffff")
    E("488b45e8"); E("8b95e0fdffff"); E("4863d2"); E("4801d0"); E("8b00"); E("8985e4fdffff")
    E("3d04000000"); jl=len(fixup); E("0f8c00000000")
    E("488b85d8fdffff"); E("8b95e4fdffff"); E("4863d2"); E("488d3410")
    E("4889f7"); E("4881ef"+struct.pack("<I",scan_back).hex())
    E("488b85d8fdffff"); E("4839c7"); E("480f42f8")
    loop=len(fixup)
    E("4839f7"); jae=len(fixup); E("0f8300000000")
    E("803f48"); j1=len(fixup); E("7500")
    E("807f0189"); j2=len(fixup); E("7500")
    E("807f02c1"); j3=len(fixup); E("7500")
    E("807f03e8"); j4=len(fixup); E("7500")
    E("c64702c2"); E("eb00"); js=len(fixup)-1
    nxt=len(fixup); E("48ffc7"); jl2=len(fixup); E("eb00")
    sk=len(fixup); E("4883c420"); e9=len(fixup); E("e900000000")
    def p32(at,tgt): struct.pack_into("<i",fixup,at+2,tgt-(at+6))
    def p8(at,tgt): fixup[at+1]=(tgt-(at+2))&0xff
    p32(jl,sk); p32(jae,sk)
    p8(j1,nxt); p8(j2,nxt); p8(j3,nxt); p8(j4,nxt)
    fixup[js]=(sk-(js+1))&0xff
    fixup[jl2+1]=(loop-(jl2+2))&0xff
    struct.pack_into("<i",fixup,e9+1,end_r-(base_r+e9+5))
    return fixup

def apply_c1toc2(pe, secs):
    fix = build_c1toc2()
    pad = 0x57bd4e-0x57bbae-len(fix)
    assert pad>=0, pad
    pe = bytearray(pe)
    pe[rva2off(pe,secs,0x57bbae):rva2off(pe,secs,0x57bd4e)] = fix+b"\x90"*pad
    return pe

def dump_fwd(buf, label):
    secs = pe_secs(buf); va,vs,ro,rs = secs[b".text"]; w=buf[ro:ro+rs]
    P(f"  dump {label}:")
    for pat,name in [(bytes.fromhex("488b45c04889c2e8"),"sretOK"),
                     (bytes.fromhex("488b45c04889c1e8"),"sretBAD"),
                     (bytes.fromhex("b809000000"),"imm09"),
                     (bytes.fromhex("b80a000000"),"imm0a"),
                     (bytes.fromhex("4889c2e8"),"rdxCALL")]:
        hits=[]; idx=0
        while True:
            j=w.find(pat,idx)
            if j<0: break
            hits.append(j); idx=j+1
            if len(hits)>6: break
        P(f"    {name}@{[hex(h) for h in hits]}")
    # fw @0x4f8 area and main
    for start,tag in [(0x4f8,"fw"), (0x540,"main")]:
        P(f"    === {tag} @{start:#x} ===")
        for insn in md.disasm(w[start:start+0x70], start):
            P(f"      {insn.address:06x}: {insn.bytes.hex():18s} {insn.mnemonic} {insn.op_str}")

def gate(h, label):
    out_fwd=None; results={}
    for s in SRCS:
        crc, outx = run(h, s, f"_g19_{label}")
        user="n/a"; rt="-"; so=b""
        if outx:
            user=hashlib.sha256(outx.read_bytes()).hexdigest()[:12]
            rc, so = run_bin(outx); rt=tag_of(rc) if rc>3 else str(rc)
            if s=="p_ret_fwd.x": out_fwd=outx
        known={"be679e1a2242":"BE67","4d4d6b4505fb":"FIX17A","5c6778769c3c":"LIT",
               "36d26fcc9657":"LOC","5676e979af61":"LET","e411d7260d78":"HOLLOW",
               "8a599561c3d0":"S18A"}
        P(f"  {label}/{s:16s} host={tag_of(crc):8s} USER={user} run={rt:8s} {known.get(user,'')} out={so[:40]!r}")
        results[s]=(user,rt)
    return out_fwd, results

t0=time.time()
base=bytearray(BASE.read_bytes()); secs=pe_secs(base)
P(f"BASE sha={hashlib.sha256(base).hexdigest()[:12]}")

# A: sub20 + imm9→rdx + c1toc2
P("\n=== A sub20+imm9 + c1toc2 ===")
pe=plant_capless(base, secs, bytes.fromhex("4883ec20b8090000004889c2"), "A")
pe=apply_c1toc2(pe, pe_secs(pe))
h=save(pe,"host_967_s19a.exe")
out,res=gate(h,"s19a")
if out: dump_fwd(out.read_bytes(),"s19a")

# B: sret reload + sub20 + imm9→rdx + c1toc2
P("\n=== B sret+sub20+imm9 + c1toc2 ===")
pe=plant_capless(base, secs, bytes.fromhex("488b4dd04883ec20b8090000004889c2"), "B")
pe=apply_c1toc2(pe, pe_secs(pe))
h=save(pe,"host_967_s19b.exe")
out,res=gate(h,"s19b")
if out: dump_fwd(out.read_bytes(),"s19b")

# C: sub20 + imm9→rdx ONLY (len=12), no trailing — same as A
# D: just imm9→rdx no sub20? (SoftCap may need sub20 from Capless)
P("\n=== D imm9 only + c1toc2 (no sub20; SoftCap may provide) ===")
pe=plant_capless(base, secs, bytes.fromhex("b8090000004889c2"), "D")
pe=apply_c1toc2(pe, pe_secs(pe))
h=save(pe,"host_967_s19d.exe")
out,res=gate(h,"s19d")
if out: dump_fwd(out.read_bytes(),"s19d")

P(f"\n=== SUMMARY elapsed={time.time()-t0:.1f}s ===")
