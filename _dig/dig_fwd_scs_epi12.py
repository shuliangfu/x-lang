#!/usr/bin/env python3
"""DIG12: dual SoftCap+2c614f nopr9 diagnostic; Capless@12377c note. Budget<=40s."""
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
    out=cave/f"_t12_{h.stem}_{Path(src).stem}.exe"
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
        return tag_of(r.returncode), r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT",-1

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

def nop7(pe,rva):
    o=rva2off(pe,secs,rva)
    ins=list(md.disasm(bytes(pe[o:o+16]),rva))[0]
    assert ins.size==7, (hex(rva),ins.size,ins.mnemonic,ins.op_str)
    pe[o:o+7]=b"\x90"*7
    return ins

# Confirm @2c6174 is r9 home
o=rva2off(base,secs,0x2c6174)
ins=list(md.disasm(bytes(base[o:o+16]),0x2c6174))[0]
P(f"@2c6174: {ins.mnemonic} {ins.op_str} size={ins.size} raw={bytes(base[o:o+ins.size]).hex()}")

# A) SoftCap nopr9 only (Isol candidate)
pe=bytearray(base); nop7(pe,0x2be53e)
h=cave/"host_scs_nopr9.exe"; h.write_bytes(bytes(pe))
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"\n=== A SoftCap nopr9 sha={sha} ===")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,outx=run(h,src)
    rt="-";
    if tag=="OK" and outx: rt,_=run_bin(outx)
    P(f"  {src:14s} {tag:8s} USER={sh} run={rt}")

# B) dual diagnostic (NOT committing as letter-stack — DIG only)
pe=bytearray(base); nop7(pe,0x2be53e); nop7(pe,0x2c6174)
h=cave/"_dig_dual_nopr9.exe"; h.write_bytes(bytes(pe))
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"\n=== B dual SoftCap+2c nopr9 sha={sha} (DIG only) ===")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,outx=run(h,src)
    rt="-";
    if tag=="OK" and outx: rt,_=run_bin(outx)
    P(f"  {src:14s} {tag:8s} USER={sh} run={rt}")
# locus under dual
for rva,name in [(0x2be911,"scs_pop"),(0x2c66a7,"h2c_pop"),(0x5766f1,"cap_store2c"),(0x123781,"caller_after")]:
    pe2=bytearray(base); nop7(pe2,0x2be53e); nop7(pe2,0x2c6174)
    pe2[rva2off(pe2,secs,rva)]=0xCC
    h2=cave/f"_d12_{rva:x}.exe"; h2.write_bytes(bytes(pe2))
    tf,_,_=run(h2,"_var_fwd.x"); tl,_,_=run(h2,"_var_let.x")
    P(f"  dual INT3@{rva:06x} {name:14s} fwd={tf:8s} let={tl:8s}")

# C) @2c614f nopr9 alone
pe=bytearray(base); nop7(pe,0x2c6174)
h=cave/"_dig_2cnopr9.exe"; h.write_bytes(bytes(pe))
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"\n=== C @2c614f nopr9 alone sha={sha} ===")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,outx=run(h,src)
    rt="-";
    if tag=="OK" and outx: rt,_=run_bin(outx)
    P(f"  {src:14s} {tag:8s} USER={sh} run={rt}")
pe2=bytearray(base); nop7(pe2,0x2c6174); pe2[rva2off(pe2,secs,0x2be911)]=0xCC
h2=cave/"_d12_2c_scspop.exe"; h2.write_bytes(bytes(pe2))
P(f"  2cnop INT3@scs_pop fwd={run(h2,'_var_fwd.x')[0]} let={run(h2,'_var_let.x')[0]}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for p in list(cave.glob("_t12_*"))+list(cave.glob("_d12_*"))+list(cave.glob("_dig_dual*"))+list(cave.glob("_dig_2cnop*")):
    try: p.unlink()
    except: pass
P("cleaned; kept host_scs_nopr9.exe")
