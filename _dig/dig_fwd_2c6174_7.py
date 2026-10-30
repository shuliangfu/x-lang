#!/usr/bin/env python3
"""DIG fwd_2c6174 #7: Capless real prol; 46a4db deep locus; home_b0+2c plant;
stable re-gate. Budget<=85s."""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys, re
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
    out=cave/f"_t747_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
def gate(h,label,srcs=None):
    sha=hashlib.sha256(h.read_bytes()).hexdigest()[:12]
    P(f"  [{label}] sha={sha}")
    out={}
    for src in (srcs or ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]):
        tag,sh,outx=run(h,src)
        rt=run_bin(outx) if tag=="OK" and outx else "-"
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}")
        out[src]=(tag,rt,sh)
    return sha,out

for pat in ["_t747_*","_d747_*"]:
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
def collect_disp_sites(start,end,disp):
    off=rva2off(base,secs,start); out=[]
    for insn in md.disasm(bytes(base[off:off+(end-start)]),start):
        o=rva2off(base,secs,insn.address)
        raw=bytes(base[o:o+insn.size])
        if struct.pack("<i",disp) in raw and "rbp" in insn.op_str:
            out.append(insn.address)
    return out

# A) Capless real entry bytes @57656c
P("=== A Capless entry raw @57656c ===")
o=rva2off(base,secs,0x57656c)
P(f"  raw16={bytes(base[o:o+32]).hex()}")
for insn in md.disasm(bytes(base[o:o+0x50]),0x57656c):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x5765b0: break

# B) 46a4db find ret + deep probes under chain_rt
P("\n=== B 46a4db deep under chain_rt ===")
def chain_rt():
    pe=bytearray(base)
    for r in collect_disp_sites(0x2be519,0x2be912,0xf8): patch_disp(pe,r,0xf8,0xb0)
    for r in collect_disp_sites(0x2c614f,0x2c66a8,0x138): patch_disp(pe,r,0x138,0x100)
    for r in collect_disp_sites(0x46a4db,0x46a4db+0x500,0x198): patch_disp(pe,r,0x198,0x160)
    return pe
off=rva2off(base,secs,0x46a4db)
calls=[]; rets=[]; jmps=[]
for insn in md.disasm(bytes(base[off:off+0x500]),0x46a4db):
    if insn.mnemonic=="call": calls.append(insn.address)
    if insn.mnemonic=="ret": rets.append(insn.address); break
    if insn.mnemonic in ("jmp",) and insn.address>0x46a560: jmps.append(insn.address)
P(f"  calls({len(calls)})={[hex(x) for x in calls[:12]]} ...")
P(f"  rets={list(map(hex,rets))} jmps_sample={list(map(hex,jmps[:6]))}")
# epi region near ret
if rets:
    er=rets[0]
    P(f"  epi dump near {er:#x}:")
    for insn in md.disasm(bytes(base[rva2off(base,secs,er-0x30):rva2off(base,secs,er)+4]),er-0x30):
        P(f"    {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
        if insn.address>=er: break
probes=calls[:8]+([rets[0]-7,rets[0]] if rets else [])+jmps[:4]
probes=sorted(set(probes))
for rva in probes:
    pe=chain_rt(); pe[rva2off(pe,secs,rva)]=0xCC
    tf=run(save(pe,f"_d747_{rva:x}.exe"),"_var_fwd.x")[0]
    tl=run(save(pe,f"_d747_{rva:x}.exe"),"_var_let.x")[0]
    P(f"  chain INT3@{rva:06x} fwd={tf:8s} let={tl:8s}")

# C) plant home_b0 + @2c full rt (no 46)
P("\n=== C plant scs_home_b0 + h2c_rt100 ===")
pe=bytearray(base)
patch_disp(pe,0x2be53e,0xf8,0xb0)
for r in collect_disp_sites(0x2c614f,0x2c66a8,0x138): patch_disp(pe,r,0x138,0x100)
h=save(pe,"host_2c_b0_h2c.exe")
sha,rows=gate(h,"b0_h2c")
for rva,name in [(0x2be911,"scs_pop"),(0x2c66a7,"h2c_pop"),(0x5766f1,"store_2c"),(0x576746,"call_46"),(0x57674b,"after_46"),(0x123781,"caller")]:
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
    tf=run(save(pe2,f"_d747_c{name}.exe"),"_var_fwd.x")[0]
    tl=run(save(pe2,f"_d747_c{name}.exe"),"_var_let.x")[0]
    P(f"  b0_h2c INT3@{rva:06x} {name:10s} fwd={tf:8s} let={tl:8s}")

# D) plant home_b0 + h2c_rt + c46_rt (homes+reads) = chain_rt, re-gate x3 for stability
P("\n=== D chain_rt stability x3 ===")
for i in range(3):
    pe=chain_rt(); h=save(pe,f"host_2c_chain_rt.exe")
    gate(h,f"chain_t{i}",srcs=["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"])

# E) Capless [rsp+0x20] save/restore around SoftCap using free scratch
# Before SoftCap: at 57668b mov [rsp+0x20],ecx already. SoftCap smashes.
# After SoftCap @576697: restore [rsp+0x20] from [rbp+0x4b0] again before anything else?
# Capless already doesn't use [rsp+0x20] until next call setup.
# SoftCap home smash causes SoftCap epi GS — restore after SoftCap can't help SoftCap epi.
# Confirmed: need SoftCap home retarget (home_b0), not Capless restore.

# F) Try SoftCap home → [rbp+0x68] (zeroed area in SoftCap prol) + h2c + c46 + 493 chain
P("\n=== E quad homes-only SoftCap→0x68 ===")
pe=bytearray(base)
patch_disp(pe,0x2be53e,0xf8,0x68)
patch_disp(pe,0x2c6174,0x138,0x100)
patch_disp(pe,0x46a500,0x198,0x160)
# 493 home only
patch_disp(pe,0x493d56,0x208,0x1d0)
h=save(pe,"host_2c_quad_homes.exe")
gate(h,"quad_homes")
for rva,name in [(0x2be911,"scs_pop"),(0x57674b,"after_46"),(0x5767a5,"after_493"),(0x578278,"cap_epi"),(0x123781,"caller")]:
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
    tf=run(save(pe2,f"_d747_q{name}.exe"),"_var_fwd.x")[0]
    tl=run(save(pe2,f"_d747_q{name}.exe"),"_var_let.x")[0]
    P(f"  qhomes INT3@{rva:06x} {name:10s} fwd={tf:8s} let={tl:8s}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t747_*","_d747_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
