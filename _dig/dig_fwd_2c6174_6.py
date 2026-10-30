#!/usr/bin/env python3
"""DIG fwd_2c6174 #6: Capless prol/cookie; 46a4db AV locus under chain_rt;
Capless save/restore [rsp+0x20] Isol around SoftCap. Budget<=85s."""
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
    out=cave/f"_t746_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
        tag,sh,outx=run(h,src)
        rt=run_bin(outx) if tag=="OK" and outx else "-"
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}")

for pat in ["_t746_*","_d746_*"]:
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
    needle=struct.pack("<i", expect_disp)
    idx=raw.find(needle)
    assert idx>=0, (hex(rva),raw.hex(),hex(expect_disp))
    return o+idx, ins
def patch_disp(pe,rva,old_d,new_d):
    off,ins=find_disp_off(pe,rva,old_d)
    pe[off:off+4]=struct.pack("<i", new_d)
    return ins
def collect_disp_sites(start,end,disp):
    off=rva2off(base,secs,start); out=[]
    for insn in md.disasm(bytes(base[off:off+(end-start)]),start):
        o=rva2off(base,secs,insn.address)
        raw=bytes(base[o:o+insn.size])
        if struct.pack("<i",disp) in raw and "rbp" in insn.op_str:
            out.append(insn.address)
        if insn.address>=end: break
    return out

def make_chain_rt(extra_patches=None):
    pe=bytearray(base)
    for r in collect_disp_sites(0x2be519,0x2be912,0xf8): patch_disp(pe,r,0xf8,0xb0)
    for r in collect_disp_sites(0x2c614f,0x2c66a8,0x138): patch_disp(pe,r,0x138,0x100)
    for r in collect_disp_sites(0x46a4db,0x46a4db+0x500,0x198): patch_disp(pe,r,0x198,0x160)
    if extra_patches:
        for fn in extra_patches: fn(pe)
    return pe

# A) Capless prol — find entry near 576xxx
P("=== A Capless function prol (scan back from SoftCap call) ===")
# Capless alt entry often @57656c from prior DIG notes
for start in [0x576500,0x576560,0x5765a0,0x123700]:
    off=rva2off(base,secs,start)
    P(f"  -- @ {start:06x} --")
    for insn in md.disasm(bytes(base[off:off+0x40]),start):
        P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
        if insn.mnemonic in ("push","sub","lea","mov") and insn.address>start+0x30: break
        if insn.address>=start+0x3f: break

# B) 46a4db under chain_rt — dense INT3
P("\n=== B 46a4db locus under chain_rt ===")
pe=make_chain_rt()
# dump 46a4db body head
off=rva2off(base,secs,0x46a4db)
addrs=[]
for insn in md.disasm(bytes(base[off:off+0x100]),0x46a4db):
    addrs.append(insn.address)
    if insn.address>=0x46a560: break
# probe key points
probes=[0x46a4db,0x46a500,0x46a507,0x46a520,0x46a525]
# add every call in first 0x200
for insn in md.disasm(bytes(base[off:off+0x200]),0x46a4db):
    if insn.mnemonic=="call":
        probes.append(insn.address)
    if insn.mnemonic=="ret":
        probes.append(insn.address); break
probes=sorted(set(probes))[:20]
P(f"  probes={[hex(x) for x in probes]}")
for rva in probes:
    pe2=make_chain_rt()
    pe2[rva2off(pe2,secs,rva)]=0xCC
    tf=run(save(pe2,f"_d746_{rva:x}.exe"),"_var_fwd.x")[0]
    tl=run(save(pe2,f"_d746_{rva:x}.exe"),"_var_let.x")[0]
    P(f"  chain INT3@{rva:06x} fwd={tf:8s} let={tl:8s}")

# C) Isol: Capless save/restore [rsp+0x20] around SoftCap call
# At @57668b: mov [rsp+0x20], ecx  (already writes [4b0])
# SoftCap call @576692. After return @576697 store.
# Plant: before call, we need SoftCap to NOT smash — that's nopr9.
# Alternative Isol: change SoftCap home displacement in ONE place (home only) to
# in-frame slot WITHOUT retargeting reads (miss path doesn't read) — nopr9-equivalent
# but write a harmless in-frame location so lit hit-paths that READ still see stale/zero.
# Prior r9b0 wrote to [rbp+0xb0] AND hit-path reads need same — full retarget.
# Try SoftCap home-only → [rbp+0xb0] (leave reads at 0xf8 = Capless[rsp+0x20] which still has [4b0]!)
P("\n=== C SoftCap HOME-ONLY →[rbp+0xb0] (reads stay 0xf8=[4b0]) ===")
pe=bytearray(base)
patch_disp(pe,0x2be53e,0xf8,0xb0)  # home only
h=save(pe,"host_2c_scs_home_b0.exe")
gate(h,"home_b0")
pe2=bytearray(pe); pe2[rva2off(pe2,secs,0x2be911)]=0xCC
P(f"  home_b0 INT3@scs_pop fwd={run(save(pe2,'_d746_hb0pop.exe'),'_var_fwd.x')[0]} let={run(save(pe2,'_d746_hb0pop.exe'),'_var_let.x')[0]}")
# hit-path reads [rbp+0xf8] which still is Capless[rsp+0x20]=[4b0] — may be wrong type but try

# D) SoftCap home-only nop + @2c home-only →0x100 + 46 home-only →0x160 (reads unpatched)
P("\n=== D homes-only chain (no read retarget) ===")
pe=bytearray(base)
patch_disp(pe,0x2be53e,0xf8,0xb0)
patch_disp(pe,0x2c6174,0x138,0x100)
patch_disp(pe,0x46a500,0x198,0x160)
h=save(pe,"host_2c_homes_only.exe")
gate(h,"homes_only")
for rva,name in [(0x2be911,"scs_pop"),(0x46a520,"c46_call"),(0x57674b,"after_46"),(0x578278,"cap_epi"),(0x123781,"caller")]:
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
    tf=run(save(pe2,f"_d746_h{name}.exe"),"_var_fwd.x")[0]
    tl=run(save(pe2,f"_d746_h{name}.exe"),"_var_let.x")[0]
    P(f"  homes INT3@{rva:06x} {name:10s} fwd={tf:8s} let={tl:8s}")

# E) Capless entry @12377c kind gate — fwd vs let
P("\n=== E Capless kind gate @12377c ===")
off=rva2off(base,secs,0x123760)
for insn in md.disasm(bytes(base[off:off+0x50]),0x123760):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x1237b0: break

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t746_*","_d746_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
