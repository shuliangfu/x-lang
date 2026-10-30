#!/usr/bin/env python3
"""DIG fwd_2c6174 #3: SoftCap miss path; fix @2c ALL 0x138 sites retarget;
probe 0x46a4db smash; Capless save/restore Isol. Budget<=85s."""
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
    out=cave/f"_t743_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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

for pat in ["_t743_*","_d743_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

def nop7(pe,rva):
    o=rva2off(pe,secs,rva)
    ins=list(md.disasm(bytes(pe[o:o+16]),rva))[0]
    assert ins.size==7,(hex(rva),ins.size)
    pe[o:o+7]=b"\x90"*7

def gate(h,label):
    sha=hashlib.sha256(h.read_bytes()).hexdigest()[:12] if hasattr(h,'read_bytes') else "-"
    if isinstance(h,Path):
        sha=hashlib.sha256(h.read_bytes()).hexdigest()[:12]
    P(f"  [{label}] sha={sha}")
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
        tag,sh,outx=run(h,src)
        rt=run_bin(outx) if tag=="OK" and outx else "-"
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}")

# A) SoftCap miss path from kind cmp
P("=== A SoftCap kind/miss path ===")
off=rva2off(base,secs,0x2be700)
for insn in md.disasm(bytes(base[off:off+0x80]),0x2be700):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x2be780: break
P("--- miss target region ---")
# find jmp to miss from earlier dig @2be734
off=rva2off(base,secs,0x2be720)
for insn in md.disasm(bytes(base[off:off+0x100]),0x2be720):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x2be820: break

# B) 0x46a4db prol — isomorphic smash?
P("\n=== B callee 0x46a4db prol ===")
off=rva2off(base,secs,0x46a4db)
for insn in md.disasm(bytes(base[off:off+0x50]),0x46a4db):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x46a530: break

# C) Fix @2c614f ALL 0x138 → 0x100; SoftCap ALL 0xf8 → 0xb0
P("\n=== C plant rt_all: SoftCap 0xf8→0xb0 (all sites) + @2c 0x138→0x100 (all) ===")
pe=bytearray(base)
scs_sites=[(0x2be53e,"4c898d",7),(0x2be7f5,"488b95",7),(0x2be832,"4883bd",8),(0x2be850,"488b85",7)]
for rva,pref,sz in scs_sites:
    o=rva2off(pe,secs,rva)
    raw=bytes(pe[o:o+sz]); P(f"  scs@{rva:06x} raw={raw.hex()}")
    assert raw[:len(bytes.fromhex(pref))]==bytes.fromhex(pref), raw.hex()
    # disp at end-4 for these
    old=struct.unpack_from("<i",pe,o+sz-4)[0]
    assert old==0xf8, (hex(rva),old)
    pe[o+sz-4:o+sz]=struct.pack("<i",0xb0)

h2c_sites=[(0x2c6174,"4c898d",7),(0x2c618f,"4883bd",8),(0x2c6514,"488b95",7),(0x2c654c,"488b95",7),(0x2c6668,"488b8d",7)]
for rva,pref,sz in h2c_sites:
    o=rva2off(pe,secs,rva)
    raw=bytes(pe[o:o+sz]); P(f"  h2c@{rva:06x} raw={raw.hex()}")
    assert raw[:len(bytes.fromhex(pref))]==bytes.fromhex(pref), raw.hex()
    old=struct.unpack_from("<i",pe,o+sz-4)[0]
    assert old==0x138, (hex(rva),old)
    pe[o+sz-4:o+sz]=struct.pack("<i",0x100)

h=save(pe,"host_2c_rt_all.exe")
gate(h,"rt_all")
# SoftCap pop locus
pe2=bytearray(pe); pe2[rva2off(pe2,secs,0x2be911)]=0xCC
h2=save(pe2,"_d743_rt_pop.exe")
P(f"  rt_all INT3@scs_pop fwd={run(h2,'_var_fwd.x')[0]} let={run(h2,'_var_let.x')[0]}")
pe2=bytearray(pe); pe2[rva2off(pe2,secs,0x576746)]=0xCC
h2=save(pe2,"_d743_rt_746.exe")
P(f"  rt_all INT3@576746 fwd={run(h2,'_var_fwd.x')[0]} let={run(h2,'_var_let.x')[0]}")
pe2=bytearray(pe); pe2[rva2off(pe2,secs,0x57674b)]=0xCC
h2=save(pe2,"_d743_rt_74b.exe")
P(f"  rt_all INT3@57674b fwd={run(h2,'_var_fwd.x')[0]} let={run(h2,'_var_let.x')[0]}")

# D) Also nop r9 home of 0x46a4db if isomorphic
P("\n=== D 0x46a4db r9 home hunt ===")
off=rva2off(base,secs,0x46a4db)
homes=[]
for insn in md.disasm(bytes(base[off:off+0x40]),0x46a4db):
    if insn.mnemonic=="mov" and "r9" in insn.op_str and "rbp" in insn.op_str:
        homes.append(insn)
        P(f"  HOME {insn.address:06x}: {insn.mnemonic} {insn.op_str} size={insn.size}")
    if insn.address>=0x46a520: break

# If found, dual+triple: SoftCap nop + 2c nop + 46a4db nop
if homes:
    r9h=homes[-1].address  # usually last of rcx/rdx/r8/r9
    pe=bytearray(base); nop7(pe,0x2be53e); nop7(pe,0x2c6174)
    o=rva2off(pe,secs,r9h)
    ins=list(md.disasm(bytes(pe[o:o+16]),r9h))[0]
    P(f"  nop @{r9h:06x} {ins.mnemonic} {ins.op_str} size={ins.size}")
    pe[o:o+ins.size]=b"\x90"*ins.size
    h=save(pe,"host_2c_triple_nop.exe")
    gate(h,"triple")
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,0x57674b)]=0xCC
    P(f"  triple INT3@57674b fwd={run(save(pe2,'_d743_t74b.exe'),'_var_fwd.x')[0]} let={run(save(pe2,'_d743_t74b.exe'),'_var_let.x')[0]}")

# E) Capless: rewrite SoftCap call to use a trampoline that saves/restores [rsp+0x20]
# Too big. Instead: after SoftCap homes would smash, Capless already restores before @2c.
# SoftCap epi GS with write but not with nop → try SoftCap home to [rbp+0xd0] (last owned = saved-rbp area — BAD)
# SoftCap home to [rbp+0x48] deep in zeros
P("\n=== E SoftCap r9→[rbp+0x48] all sites + @2c rt100 all ===")
pe=bytearray(base)
for rva,pref,sz in scs_sites:
    o=rva2off(pe,secs,rva)
    pe[o+sz-4:o+sz]=struct.pack("<i",0x48)
for rva,pref,sz in h2c_sites:
    o=rva2off(pe,secs,rva)
    pe[o+sz-4:o+sz]=struct.pack("<i",0x100)
h=save(pe,"host_2c_r948_rt100.exe")
gate(h,"r948")
pe2=bytearray(pe); pe2[rva2off(pe2,secs,0x2be911)]=0xCC
P(f"  r948 INT3@scs_pop fwd={run(save(pe2,'_d743_r948pop.exe'),'_var_fwd.x')[0]} let={run(save(pe2,'_d743_r948pop.exe'),'_var_let.x')[0]}")

# F) Only SoftCap full retarget 0xf8→0xb0 (no @2c) — compare to nopr9
P("\n=== F SoftCap-only full retarget 0xf8→0xb0 ===")
pe=bytearray(base)
for rva,pref,sz in scs_sites:
    o=rva2off(pe,secs,rva)
    pe[o+sz-4:o+sz]=struct.pack("<i",0xb0)
h=save(pe,"host_scs_r9b0_all.exe")
gate(h,"scs_b0all")
pe2=bytearray(pe); pe2[rva2off(pe2,secs,0x2be911)]=0xCC
P(f"  scs_b0all INT3@scs_pop fwd={run(save(pe2,'_d743_b0pop.exe'),'_var_fwd.x')[0]} let={run(save(pe2,'_d743_b0pop.exe'),'_var_let.x')[0]}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t743_*","_d743_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
