#!/usr/bin/env python3
"""DIG fwd_46a500 #3: Capless /GS cookie; 46a4db epi; path 46a9e3→ret;
re-verify after_46 vs ret; smash vs [4b0]; plant restore-[4b0] DIG.
Budget<=85s."""
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
    out=cave/f"_t503_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
def save(pe,name):
    p=cave/name; p.write_bytes(bytes(pe)); return p
def gate(h,label):
    sha=hashlib.sha256(h.read_bytes()).hexdigest()[:12]
    P(f"  [{label}] sha={sha}")
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
        tag,sh,_=run(h,src)
        P(f"  {label}/{src:14s} {tag:8s} USER={sh}")
    return sha

for pat in ["_t503_*","_d503_*"]:
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
    assert idx>=0, (hex(rva),raw.hex(),hex(expect_disp))
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
def make_b0_h2c():
    pe=bytearray(base)
    patch_disp(pe,0x2be53e,0xf8,0xb0)
    for r in collect_disp_sites(0x2c614f,0x200,0x138):
        patch_disp(pe,r,0x138,0x100)
    return pe
def int3_pair(pe,rva,name):
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
    tf=run(save(pe2,f"_d503_{name}.exe"),"_var_fwd.x")[0]
    tl=run(save(pe2,f"_d503_{name}l.exe"),"_var_let.x")[0]
    P(f"  INT3@{rva:06x} {name:14s} fwd={tf:8s} let={tl:8s}")
    return tf,tl
def scan_gs(start,nbytes,label):
    o=rva2off(base,secs,start); hits=[]
    for insn in md.disasm(bytes(base[o:o+nbytes]),start):
        s=(insn.mnemonic+" "+insn.op_str).lower()
        if "gs:" in s or "security" in s:
            hits.append(f"{insn.address:06x}:{insn.mnemonic} {insn.op_str}")
    P(f"  [{label}] gs/security={hits[:10]} n={len(hits)}")
    return hits

pe_bh=make_b0_h2c()
gate(save(pe_bh,"host_46_b0_h2c.exe"),"b0_h2c")

# A) Capless prol + cookie + epi
P("\n=== A Capless @57656c prol/epi/cookie ===")
o=rva2off(base,secs,0x57656c)
for insn in md.disasm(bytes(base[o:o+0x80]),0x57656c):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x5765e0: break
scan_gs(0x57656c,0x3000,"capless_body")
# epi around 578278
P("  -- epi @578250 --")
o=rva2off(base,secs,0x578250)
for insn in md.disasm(bytes(base[o:o+0x50]),0x578250):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")

# B) 46a4db epi before first ret
P("\n=== B 46a4db epi near 46af40 ===")
o=rva2off(base,secs,0x46af20)
for insn in md.disasm(bytes(base[o:o+0x80]),0x46af20):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x46af80: break
scan_gs(0x46a4db,0xc00,"c46_body")

# C) re-verify critical INT3
P("\n=== C re-verify ret / after_46 / caller / cap_epi ===")
for rva,name in [(0x46af5d,"jmp_ret"),(0x46af65,"ret1"),(0x57674b,"after_46"),
                 (0x576764,"after_cmp"),(0x5767a0,"call_493"),(0x578278,"cap_epi"),
                 (0x123781,"caller")]:
    int3_pair(pe_bh,rva,name)

# D) dense path 46a9e3 → 46af65
P("\n=== D path after 46a9e3 ===")
o=rva2off(base,secs,0x46a9c0)
for insn in md.disasm(bytes(base[o:o+0x200]),0x46a9c0):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x46ab80: break

P("\n=== D2 probes 46a9e3..46af65 ===")
probes=[]
o=rva2off(base,secs,0x46a9e3)
for insn in md.disasm(bytes(base[o:o+0x600]),0x46a9e3):
    if insn.mnemonic=="call" or insn.mnemonic=="ret" or (insn.mnemonic=="jmp" and insn.op_str.startswith("0x")):
        probes.append(insn.address)
    if insn.address>=0x46af65: break
# unique limited
seen=set(); pl=[]
for a in probes:
    if a not in seen:
        seen.add(a); pl.append(a)
for rva in pl[:25]:
    if time.time()-T0>55: break
    int3_pair(pe_bh,rva,f"d{rva:x}"[-10:])

# E) Capless: does it read [rsp+0x20] between after_46 and restore@576799?
P("\n=== E Capless 57674b..5767a5 detail ===")
o=rva2off(base,secs,0x57674b)
for insn in md.disasm(bytes(base[o:o+0x60]),0x57674b):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")

# F) plant DIG: on BASE (no b0_h2c) — only nop @46a500; and only home160 @46a500
P("\n=== F BASE-only 46 plants (no SoftCap/2c retarget) ===")
pe=bytearray(base)
o=rva2off(pe,secs,0x46a500)
ins=list(md.disasm(bytes(pe[o:o+16]),0x46a500))[0]
pe[o:o+ins.size]=b"\x90"*ins.size
gate(save(pe,"host_46_base_nop500.exe"),"base_nop500")

pe=bytearray(base)
patch_disp(pe,0x46a500,0x198,0x160)
gate(save(pe,"host_46_base_home160.exe"),"base_home160")

# G) plant: b0_h2c + force Capless to set r9=[4b0] before call_46
# Find bytes at 576739..576746: mov ecx,[4b0]; mov [rsp+0x20],ecx; mov rcx,rax; call
# Want also: mov r9d, ecx (or mov r9,[4b0]) before call — but space tight.
# DIG only: INT3 just before call after manually checking r9 home effect by
# patching 46a500 to read from a slot that won't smash: already tried.
# Alternative Isol: nop the READ use path? too broad.
# Try: b0_h2c + patch @46a500 to mov [rbp+0x164],r9d (final use slot) skipping smash
P("\n=== G b0_h2c + home write→0x164 (use-slot, no smash) ===")
pe=make_b0_h2c()
# 0x164 is used as dest at 46a8c0; frame: rbp+0x164 = call_rsp-0x178+0x164 = call_rsp-0x14 (INSIDE frame, not +0x20)
patch_disp(pe,0x46a500,0x198,0x164)
gate(save(pe,"host_46_home164.exe"),"home164")
for rva,name in [(0x2be911,"scs_pop"),(0x57674b,"after_46"),(0x46af65,"ret1"),(0x123781,"caller")]:
    if time.time()-T0>78: break
    int3_pair(pe,rva,name)

# H) b0_h2c + home→0x16c (also in-frame)
P("\n=== H b0_h2c + home write→0x170 (pad) ===")
pe=make_b0_h2c()
patch_disp(pe,0x46a500,0x198,0x170)
gate(save(pe,"host_46_home170.exe"),"home170")
for rva,name in [(0x57674b,"after_46"),(0x46af65,"ret1"),(0x46a8ba,"rd198"),(0x123781,"caller")]:
    if time.time()-T0>85: break
    int3_pair(pe,rva,name)

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t503_*","_d503_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
