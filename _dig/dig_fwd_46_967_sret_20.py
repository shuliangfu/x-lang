"""DIG fwd_46_967_sret #20: Capless plant sub20+x+1([rbp-0x10])→rdx + let sret→caller + c1toc2.
s19a greened lit/fwd/local; let red = Capless imm9 + local &v + no copy-out.
A: plant x+1 from [rbp-0x10] (fw/let); may break main
B: A + patch lea &v → mov rcx,[rbp-0x50] (caller sret)
C: keep s19a imm9 + only let sret patch (arg still wrong → still exit1 expected)
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
    n = len(payload); assert 1 <= n <= 16, n
    pe = bytearray(pe)
    off = rva2off(pe, secs, 0x57ba3b)
    full = b"".join(bytes([0xc6, 0x43, i, (payload[i] if i < n else 0x90)]) for i in range(16))
    pe[off:off+64] = full
    loff = rva2off(pe, secs, 0x57ba94)
    assert pe[loff] == 0xb8
    pe[loff:loff+5] = bytes([0xb8, n, 0, 0, 0])
    P(f"  {label}: Capless payload={payload.hex()} len={n}")
    return pe

def build_c1toc2(base_r=0x57bbae, end_r=0x57bd4e, scan_back=0x100, let_sret=False):
    """c1→c2; optional also patch lea [rbp-0x38];mov rcx → mov rax,[rbp-0x50];mov rcx."""
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
    # pattern 4889c1e8 → c2
    E("803f48"); j1=len(fixup); E("7500")
    E("807f0189"); j2=len(fixup); E("7500")
    E("807f02c1"); j3=len(fixup); E("7500")
    E("807f03e8"); j4=len(fixup); E("7500")
    E("c64702c2")
    # optional: also look for 488d45c8 (lea [rbp-0x38]) at rdi-4? skip — separate scan below
    E("eb00"); js=len(fixup)-1
    nxt=len(fixup); E("48ffc7"); jl2=len(fixup); E("eb00")
    sk=len(fixup)
    if let_sret:
        # second scan: 488d45c8 4889c1 → 488b45b0 4889c1 (caller sret)
        E("488b85d8fdffff"); E("8b95e4fdffff"); E("4863d2"); E("488d3410")  # end
        E("4889f7"); E("4881ef"+struct.pack("<I",scan_back).hex())
        E("488b85d8fdffff"); E("4839c7"); E("480f42f8")
        loop2=len(fixup)
        E("4839f7"); jae2=len(fixup); E("0f8300000000")
        E("803f48"); k1=len(fixup); E("7500")
        E("807f018d"); k2=len(fixup); E("7500")
        E("807f0245"); k3=len(fixup); E("7500")
        E("807f03c8"); k4=len(fixup); E("7500")  # lea [rbp-0x38]
        E("807f0448"); k5=len(fixup); E("7500")
        E("807f0589"); k6=len(fixup); E("7500")
        E("807f06c1"); k7=len(fixup); E("7500")
        # patch: 488d45c8 → 488b45b0
        E("c647018b"); E("c64703b0")
        E("eb00"); js2=len(fixup)-1
        nxt2=len(fixup); E("48ffc7"); jl3=len(fixup); E("eb00")
        sk2=len(fixup); E("4883c420"); e9=len(fixup); E("e900000000")
        def p32(at,tgt): struct.pack_into("<i",fixup,at+2,tgt-(at+6))
        def p8(at,tgt): fixup[at+1]=(tgt-(at+2))&0xff
        p32(jl,sk); p32(jae,sk)
        p8(j1,nxt); p8(j2,nxt); p8(j3,nxt); p8(j4,nxt)
        fixup[js]=(sk-(js+1))&0xff
        fixup[jl2+1]=(loop-(jl2+2))&0xff
        p32(jae2,sk2)
        p8(k1,nxt2); p8(k2,nxt2); p8(k3,nxt2); p8(k4,nxt2)
        p8(k5,nxt2); p8(k6,nxt2); p8(k7,nxt2)
        fixup[js2]=(sk2-(js2+1))&0xff
        fixup[jl3+1]=(loop2-(jl3+2))&0xff
        struct.pack_into("<i",fixup,e9+1,end_r-(base_r+e9+5))
    else:
        E("4883c420"); e9=len(fixup); E("e900000000")
        def p32(at,tgt): struct.pack_into("<i",fixup,at+2,tgt-(at+6))
        def p8(at,tgt): fixup[at+1]=(tgt-(at+2))&0xff
        p32(jl,sk); p32(jae,sk)
        p8(j1,nxt); p8(j2,nxt); p8(j3,nxt); p8(j4,nxt)
        fixup[js]=(sk-(js+1))&0xff
        fixup[jl2+1]=(loop-(jl2+2))&0xff
        struct.pack_into("<i",fixup,e9+1,end_r-(base_r+e9+5))
    return fixup

def apply_fix(pe, secs, let_sret=False):
    fix = build_c1toc2(let_sret=let_sret)
    pad = 0x57bd4e-0x57bbae-len(fix)
    P(f"  fixup len={len(fix)} pad={pad} let_sret={let_sret}")
    assert pad>=0, pad
    pe = bytearray(pe)
    pe[rva2off(pe,secs,0x57bbae):rva2off(pe,secs,0x57bd4e)] = fix+b"\x90"*pad
    return pe

def dump_let(buf, label):
    secs = pe_secs(buf); va,vs,ro,rs = secs[b".text"]; w=buf[ro:ro+rs]
    P(f"  dump let {label}:")
    for insn in md.disasm(w[0x4f8:0x540], 0x4f8):
        P(f"    {insn.address:06x}: {insn.bytes.hex():18s} {insn.mnemonic} {insn.op_str}")

def gate(h, label):
    out_let=None
    for s in SRCS:
        crc, outx = run(h, s, f"_g20_{label}")
        user="n/a"; rt="-"
        if outx:
            user=hashlib.sha256(outx.read_bytes()).hexdigest()[:12]
            rc, so = run_bin(outx); rt=tag_of(rc) if rc>3 else str(rc)
            if s=="_var_let.x": out_let=outx
        known={"5c6778769c3c":"LIT","36d26fcc9657":"LOC","d9ffcb750e0b":"S19A_FWD"}
        P(f"  {label}/{s:16s} host={tag_of(crc):8s} USER={user} run={rt:8s} {known.get(user,'')}")
    return out_let

t0=time.time()
base=bytearray(BASE.read_bytes()); secs=pe_secs(base)
# x+1 plant: sub20; mov rax,[rbp-0x10]; inc rax; mov rdx,rax
XP1=bytes.fromhex("4883ec20488b45f048ffc04889c2")  # 14
IMM9=bytes.fromhex("4883ec20b8090000004889c2")  # s19a

P("\n=== A x+1 plant + c1toc2 ===")
pe=plant_capless(base, secs, XP1, "A")
pe=apply_fix(pe, pe_secs(pe), let_sret=False)
out=gate(save(pe,"host_967_s20a.exe"),"s20a")
if out: dump_let(out.read_bytes(),"s20a")

P("\n=== B x+1 plant + c1toc2 + let_sret ===")
pe=plant_capless(base, secs, XP1, "B")
pe=apply_fix(pe, pe_secs(pe), let_sret=True)
out=gate(save(pe,"host_967_s20b.exe"),"s20b")
if out: dump_let(out.read_bytes(),"s20b")

P("\n=== C imm9 (s19a) + let_sret ===")
pe=plant_capless(base, secs, IMM9, "C")
pe=apply_fix(pe, pe_secs(pe), let_sret=True)
out=gate(save(pe,"host_967_s20c.exe"),"s20c")
if out: dump_let(out.read_bytes(),"s20c")

P(f"\n=== SUMMARY elapsed={time.time()-t0:.1f}s ===")
