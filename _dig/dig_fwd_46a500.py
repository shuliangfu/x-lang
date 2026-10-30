#!/usr/bin/env python3
"""DIG fwd_46a500 #1: under b0_h2c (after_46=GS), nail GS locus inside 0x46a4db;
prol/cookie/homes; home-only vs nop plant. No chain-extend to 493. Budget<=85s."""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64)
cave = Path("C:/xlang_tmp/p1060/cave"); os.chdir(str(cave))
T0=time.time()
def P(*a): print(*a, flush=True)
def pe_secs(buf):
    e=struct.unpack_from("<I",buf,0x3C)[0]
    nsec=struct.unpack_from("<H",buf,e+6)[0]
    opt=struct.unpack_from("<H",buf,e+20)[0]
    sec=e+24+opt; out={}
    for i in range(nsec):
        o=sec+i*40; n=bytes(buf[o:o+8]).split(b"\0")[0]
        vs,va,rs,ro=struct.unpack_from("<IIII",buf,o+8); out[n]=(va,vs,ro,rs)
    return out
def rva2off(buf,secs,r):
    for n,(va,vs,ro,rs) in secs.items():
        if va<=r<va+max(vs,rs): return ro+(r-va)
    raise ValueError(hex(r))
def tag_of(crc):
    return {0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc&0xFFFFFFFF,f"crc={crc&0xFFFFFFFF:#x}")
def run(h,src,timeout=8):
    out=cave/f"_t500_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    try:
        r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout,cwd=str(cave))
        b=out.read_bytes() if out.exists() else b""
        sh=hashlib.sha256(b).hexdigest()[:12] if b else "-"
        return tag_of(r.returncode), sh, out if b else None
    except subprocess.TimeoutExpired:
        return "TIMEOUT","-",None
def run_bin(exe,timeout=3):
    try:
        r=subprocess.run([str(exe)],capture_output=True,timeout=timeout)
        return tag_of(r.returncode)
    except subprocess.TimeoutExpired:
        return "TIMEOUT"
def save(pe,name):
    p=cave/name; p.write_bytes(bytes(pe)); return p
def gate(h,label):
    sha=hashlib.sha256(h.read_bytes()).hexdigest()[:12]
    P(f"  [{label}] sha={sha}")
    out={}
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
        tag,sh,outx=run(h,src)
        rt=run_bin(outx) if tag=="OK" and outx else "-"
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}")
        out[src]=(tag,rt,sh)
    return sha,out

for pat in ["_t500_*","_d500_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

def find_disp_off(pe,rva,expect_disp):
    o=rva2off(pe,secs,rva)
    ins=list(md.disasm(bytes(pe[o:o+16]),rva))[0]
    raw=bytes(pe[o:o+ins.size])
    idx=raw.find(struct.pack("<i", expect_disp))
    assert idx>=0, (hex(rva),raw.hex(),hex(expect_disp),ins.op_str)
    return o+idx, ins
def patch_disp(pe,rva,old_d,new_d):
    off,ins=find_disp_off(pe,rva,old_d)
    pe[off:off+4]=struct.pack("<i", new_d)
    return ins
def collect_disp_sites(start,nbytes,disp):
    off=rva2off(base,secs,start); out=[]
    for insn in md.disasm(bytes(base[off:off+nbytes]),start):
        o=rva2off(base,secs,insn.address)
        raw=bytes(base[o:o+insn.size])
        if struct.pack("<i",disp) in raw and "rbp" in insn.op_str:
            out.append(insn.address)
    return out
def nop_ins(pe,rva):
    o=rva2off(pe,secs,rva)
    ins=list(md.disasm(bytes(pe[o:o+16]),rva))[0]
    pe[o:o+ins.size]=b"\x90"*ins.size
    return ins
def make_b0_h2c(extra=None):
    pe=bytearray(base)
    patch_disp(pe,0x2be53e,0xf8,0xb0)
    for r in collect_disp_sites(0x2c614f,0x200,0x138):
        patch_disp(pe,r,0x138,0x100)
    if extra:
        for fn in extra: fn(pe)
    return pe
def int3_pair(pe,rva,name):
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
    tf=run(save(pe2,f"_d500_{name}.exe"),"_var_fwd.x")[0]
    tl=run(save(pe2,f"_d500_{name}l.exe"),"_var_let.x")[0]
    P(f"  INT3@{rva:06x} {name:12s} fwd={tf:8s} let={tl:8s}")
    return tf,tl

# A) dump 0x46a4db prol + first 0x80 + homes
P("=== A 0x46a4db prol / homes / cookie scan ===")
off=rva2off(base,secs,0x46a4db)
for insn in md.disasm(bytes(base[off:off+0xa0]),0x46a4db):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x46a560: break
sites_198=collect_disp_sites(0x46a4db,0x800,0x198)
sites_security=[]
# scan for xor rcx,gs / __security_check_cookie / mov rax,[rip+...] patterns
chunk=bytes(base[off:off+0x800])
for insn in md.disasm(chunk,0x46a4db):
    s=insn.op_str.lower()
    if "gs:" in s or "security" in s or (insn.mnemonic=="xor" and "gs" in s):
        sites_security.append(insn)
    if insn.mnemonic=="call" and ("__security" in s or "check_cookie" in s):
        sites_security.append(insn)
P(f"  0x198 sites={[hex(x) for x in sites_198]}")
P(f"  security-ish count={len(sites_security)}")
for insn in sites_security[:8]:
    P(f"    {insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Find ret / epi of 0x46a4db
P("\n=== A2 find rets / likely epi in first 0x1000 ===")
rets=[]; jmps=[]
for insn in md.disasm(bytes(base[off:off+0x1000]),0x46a4db):
    if insn.mnemonic=="ret": rets.append(insn.address)
    if insn.mnemonic in ("jmp","jne","je","jz","jnz") and insn.op_str.startswith("0x"):
        pass
P(f"  rets_first8={[hex(x) for x in rets[:8]]} n={len(rets)}")
# dump around first ret
if rets:
    r0=rets[0]
    o2=rva2off(base,secs,max(0x46a4db,r0-0x40))
    for insn in md.disasm(bytes(base[o2:o2+0x60]),max(0x46a4db,r0-0x40)):
        P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
        if insn.address>=r0+4: break

# B) confirm b0_h2c baseline + binary search GS inside 46a4db
P("\n=== B b0_h2c baseline + INT3 binary search inside 46a4db ===")
pe_bh=make_b0_h2c()
sha_bh,_=gate(save(pe_bh,"host_46_b0_h2c.exe"),"b0_h2c")
# known anchors
for rva,name in [(0x2be911,"scs_pop"),(0x2c66a7,"h2c_pop"),(0x576746,"call_46"),(0x57674b,"after_46")]:
    int3_pair(pe_bh,rva,name)

# binary-search style probe points through 46a4db body (under b0_h2c, GS expected)
# From prior dig under chain_rt: HIT through 46a6fc, AV@46a741. Under b0_h2c expect GS somewhere.
probes=[
    (0x46a4db,"entry"),
    (0x46a500,"home_r9"),
    (0x46a520,"c1"),
    (0x46a544,"c2"),
    (0x46a6e3,"c3"),
    (0x46a6fc,"c4"),
    (0x46a720,"pre741"),
    (0x46a725,"mov_ecx"),
    (0x46a738,"mov_r9d"),
    (0x46a741,"call_1fb0"),
    (0x46a746,"post_call"),
    (0x46a76f,"call_1fb1"),
    (0x46a8a0,"late_jmp"),
]
P("\n=== B2 probes under b0_h2c ===")
for rva,name in probes:
    if time.time()-T0>70: P("  BUDGET stop probes"); break
    int3_pair(pe_bh,rva,name)

# C) dump around GS-candidate windows (46a6xx-46a75)
P("\n=== C dump 46a6d0..46a780 ===")
o3=rva2off(base,secs,0x46a6d0)
for insn in md.disasm(bytes(base[o3:o3+0xb0]),0x46a6d0):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x46a780: break

# D) plant: b0_h2c + 46 home-ONLY (write @46a500 → non-smash slot; reads stay)
P("\n=== D plant b0_h2c + 46 home-only 0x198→0x160 (write site only) ===")
pe=make_b0_h2c()
patch_disp(pe,0x46a500,0x198,0x160)  # home write only
sha_d,_=gate(save(pe,"host_46_home160.exe"),"home160")
for rva,name in [(0x2be911,"scs_pop"),(0x576746,"call_46"),(0x57674b,"after_46"),(0x46a741,"c46_741"),(0x123781,"caller")]:
    if time.time()-T0>78: break
    int3_pair(pe,rva,name)

# E) plant: b0_h2c + nop @46a500 only (DIG; like SoftCap nopr9)
P("\n=== E plant b0_h2c + nop @46a500 (DIG) ===")
pe=make_b0_h2c()
ins=nop_ins(pe,0x46a500)
P(f"  nop {ins.address:06x} sz={ins.size} {ins.mnemonic} {ins.op_str}")
sha_e,_=gate(save(pe,"host_46_nop500.exe"),"nop500")
for rva,name in [(0x2be911,"scs_pop"),(0x576746,"call_46"),(0x57674b,"after_46"),(0x46a741,"c46_741"),(0x123781,"caller")]:
    if time.time()-T0>82: break
    int3_pair(pe,rva,name)

# F) plant: b0_h2c + all 0x198 → 0x160 (full rt of 46 only; no 493)
P("\n=== F plant b0_h2c + 46 full 0x198→0x160 (no 493) ===")
pe=make_b0_h2c()
for r in sites_198:
    patch_disp(pe,r,0x198,0x160)
    P(f"  rt {r:06x} 0x198→0x160")
sha_f,_=gate(save(pe,"host_46_full160.exe"),"full160")
for rva,name in [(0x57674b,"after_46"),(0x46a741,"c46_741"),(0x5767a0,"call_493"),(0x123781,"caller")]:
    if time.time()-T0>85: break
    int3_pair(pe,rva,name)

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t500_*","_d500_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
