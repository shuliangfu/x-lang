"""DIG fwd_46_967_sret #18: slim Capless plant (no hardcoded imm0xa) + c1→c2 fixup.
Exit1 on fix17a = main got fw(10) from USER16 imm; fw→mk rcx=sret already OK.
A: plant only sub rsp,20
B: plant sret reload + sub rsp,20
C: A/B + fix17a c1toc2 @57bbae
"""
from pathlib import Path
import struct, hashlib, subprocess, time
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

CAVE = Path("C:/xlang_tmp/p1060/cave")
BASE = CAVE / "host_967_sret_tr460.exe"  # already has USER16@57ba3b
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
    """Rewrite Capless@57ba3b mov-byte stores + append len to emit payload."""
    # Capless builds at [rbp-0x80] via c643XX then appends len from [rbp-0x90]
    # Current USER16 uses 16 stores + len=0x10. We rewrite stores for len(payload)
    # and set append length immediate.
    n = len(payload)
    assert 1 <= n <= 16, n
    writes = b"".join(bytes([0xc6, 0x43, i, payload[i]]) for i in range(n))
    # After stores, original has more setup; we need to keep path to append with new len.
    # Layout @57ba3b for 16-byte plant occupied through ~57ba3b+74.
    # Pattern from dig5: writes + tail + nop pad to 74 bytes, and len imm at ba94 area.
    # Safer: patch only the 16 store immediates + the mov eax,0x10 length.
    # Find mov eax,0x10 before append: at 57ba94 b810000000
    pe = bytearray(pe)
    # overwrite first n stores; nop remaining store slots (16-n)*4 bytes of c643i XX
    off = rva2off(pe, secs, 0x57ba3b)
    # each store is 4 bytes c643 i imm
    full = b"".join(bytes([0xc6, 0x43, i, (payload[i] if i < n else 0x90)]) for i in range(16))
    # Actually for i>=n write NOP into USER via storing 0x90
    pe[off:off+64] = full
    # set append length = 16 still (with trailing nops) OR set to n
    # length at 57ba94: b8 <len> 000000
    loff = rva2off(pe, secs, 0x57ba94)
    assert pe[loff:loff+5] == bytes.fromhex("b810000000") or pe[loff]==0xb8, pe[loff:loff+5].hex()
    pe[loff:loff+5] = bytes([0xb8, n, 0, 0, 0])
    # Also need lea/setup before stores still points at buffer — unchanged.
    P(f"  {label}: Capless payload={payload.hex()} len={n}")
    return pe

def build_c1toc2(base_r=0x57bbae, end_r=0x57bd4e, scan_back=0x100):
    """Same as fix17a: data=ctx+0x2790030, u32 len, patch 4889c1e8→c2."""
    fixup = bytearray()
    def E(h): fixup.extend(bytes.fromhex(h) if isinstance(h,str) else h)
    E("4883ec20")
    E("b800000000"); E("8985e0fdffff")          # len_field=0
    E("b830007902"); E("8985dcfdffff")          # data_off=0x2790030
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
                     (bytes.fromhex("488b4dd0"),"reload"),
                     (bytes.fromhex("b80a000000"),"imm0a"),
                     (bytes.fromhex("b809000000"),"imm09")]:
        hits=[]; idx=0
        while True:
            j=w.find(pat,idx)
            if j<0: break
            hits.append(j); idx=j+1
            if len(hits)>5: break
        P(f"    {name}@{[hex(h) for h in hits]}")
    # show fw and main windows
    j = w.find(bytes.fromhex("4881ec68080000"))  # fw/main big frame
    for start in [j, j+0x50 if j>=0 else -1]:
        if start is None or start<0: continue
        P(f"    near@{start:#x}:")
        for insn in md.disasm(w[start:start+0x55], start):
            P(f"      {insn.address:06x}: {insn.bytes.hex():18s} {insn.mnemonic} {insn.op_str}")

def gate(h, label):
    out_fwd=None
    for s in SRCS:
        crc, outx = run(h, s, f"_g18_{label}")
        user="n/a"; rt="-"; so=b""
        if outx:
            user=hashlib.sha256(outx.read_bytes()).hexdigest()[:12]
            rc, so = run_bin(outx); rt=tag_of(rc) if rc>3 else str(rc)
            if s=="p_ret_fwd.x": out_fwd=outx
        known={"be679e1a2242":"BE67","4d4d6b4505fb":"FIX17A","5c6778769c3c":"LIT",
               "36d26fcc9657":"LOC","5676e979af61":"LET","e411d7260d78":"HOLLOW"}
        P(f"  {label}/{s:16s} host={tag_of(crc):8s} USER={user} run={rt:8s} {known.get(user,'')} out={so[:40]!r}")
    return out_fwd

t0=time.time()
base=bytearray(BASE.read_bytes()); secs=pe_secs(base)
P(f"BASE sha={hashlib.sha256(base).hexdigest()[:12]}")

# A: only sub rsp,20 + c1toc2
P("\n=== A sub20-only + c1toc2 ===")
pe=plant_capless(base, secs, bytes.fromhex("4883ec20"), "A")
pe=apply_c1toc2(pe, pe_secs(pe))
h=save(pe,"host_967_s18a.exe")
out=gate(h,"s18a")
if out: dump_fwd(out.read_bytes(),"s18a")

# B: sret+sub20 + c1toc2
P("\n=== B sret+sub20 + c1toc2 ===")
pe=plant_capless(base, secs, bytes.fromhex("488b4dd04883ec20"), "B")
pe=apply_c1toc2(pe, pe_secs(pe))
h=save(pe,"host_967_s18b.exe")
out=gate(h,"s18b")
if out: dump_fwd(out.read_bytes(),"s18b")

# C: sub20 + imm from SoftCap? try plant nothing (len=0 skip) — use 1-byte NOP
P("\n=== C nop1 + c1toc2 (no Capless USER bytes) ===")
pe=plant_capless(base, secs, bytes.fromhex("90"), "C")
pe=apply_c1toc2(pe, pe_secs(pe))
h=save(pe,"host_967_s18c.exe")
out=gate(h,"s18c")
if out: dump_fwd(out.read_bytes(),"s18c")

# D: keep USER16 but fix imm 0xa→0x9 for main? too blunt.
# Instead: USER16 without imm: sret+sub20+ (no rdx) + c1toc2
P("\n=== D sret+sub20+nop pad16 + c1toc2 (len=16 with nops) ===")
payload=bytes.fromhex("488b4dd04883ec20") + b"\x90"*8
pe=plant_capless(base, secs, payload, "D")
# force len 16
pe=bytearray(pe); secs2=pe_secs(pe)
pe[rva2off(pe,secs2,0x57ba94):rva2off(pe,secs2,0x57ba94)+5]=bytes.fromhex("b810000000")
pe=apply_c1toc2(pe, pe_secs(pe))
h=save(pe,"host_967_s18d.exe")
out=gate(h,"s18d")
if out: dump_fwd(out.read_bytes(),"s18d")

P(f"\n=== SUMMARY elapsed={time.time()-t0:.1f}s ===")
