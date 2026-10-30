#!/usr/bin/env python3
"""DIG fwd_46a500 #4: nail [rbp+0x168]=saved-rbp alias; plant retarget 0x168→safe;
combine with b0_h2c. Budget<=85s."""
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
    out=cave/f"_t504_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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

for pat in ["_t504_*","_d504_*"]:
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
            out.append((insn.address, insn.mnemonic, insn.op_str))
    return out
def make_b0_h2c(pe=None):
    if pe is None: pe=bytearray(base)
    patch_disp(pe,0x2be53e,0xf8,0xb0)
    for r,_,_ in collect_disp_sites(0x2c614f,0x200,0x138):
        patch_disp(pe,r,0x138,0x100)
    return pe
def int3_pair(pe,rva,name):
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
    tf=run(save(pe2,f"_d504_{name}.exe"),"_var_fwd.x")[0]
    tl=run(save(pe2,f"_d504_{name}l.exe"),"_var_let.x")[0]
    P(f"  INT3@{rva:06x} {name:14s} fwd={tf:8s} let={tl:8s}")
    return tf,tl

# A) frame math nail + all 0x168/0x170/0x164 sites
P("=== A frame math + 0x168/170/164 sites in 0x46a4db ===")
P("  rbp=call_rsp-0x178; saved_rbp=[rbp+0x168]; retaddr=[rbp+0x170]; 5tharg=[rbp+0x198]")
for disp in [0x168,0x170,0x164,0x160,0x15c,0x150]:
    sites=collect_disp_sites(0x46a4db,0xc00,disp)
    P(f"  disp 0x{disp:x} n={len(sites)}: {[(hex(a),m,o) for a,m,o in sites[:12]]}")

# B) plant: ONLY 0x168→0x100 (all sites) on BASE
P("\n=== B BASE plant s168: 0x168→0x100 ===")
sites168=[a for a,_,_ in collect_disp_sites(0x46a4db,0xc00,0x168)]
pe=bytearray(base)
for r in sites168:
    patch_disp(pe,r,0x168,0x100)
    P(f"  rt {r:06x} 0x168→0x100")
sha_b,res_b=gate(save(pe,"host_46_s168.exe"),"s168")
for rva,name in [(0x2be911,"scs_pop"),(0x57674b,"after_46"),(0x46af65,"ret1"),(0x123781,"caller")]:
    int3_pair(pe,rva,name)

# C) plant: b0_h2c + s168
P("\n=== C plant b0_h2c + s168 ===")
pe=make_b0_h2c()
for r in sites168:
    patch_disp(pe,r,0x168,0x100)
h=save(pe,"host_46_b0h2c_s168.exe")
sha_c,res_c=gate(h,"b0h2c_s168")
for rva,name in [(0x2be911,"scs_pop"),(0x2c66a7,"h2c_pop"),(0x576746,"call_46"),
                 (0x57674b,"after_46"),(0x5767a0,"call_493"),(0x578278,"cap_epi"),
                 (0x46af65,"ret1"),(0x123781,"caller")]:
    if time.time()-T0>55: break
    int3_pair(pe,rva,name)

# D) also try 0x168→0x110 and 0x120 under b0_h2c (alt safe slots)
P("\n=== D b0_h2c + s168→0x110 ===")
pe=make_b0_h2c()
for r in sites168: patch_disp(pe,r,0x168,0x110)
gate(save(pe,"host_46_b0h2c_s110.exe"),"s110")

# E) b0_h2c + s168 + home500→0x160 (stop smash too)? may be letter — DIG only if C still GS
if res_c.get("p_ret_fwd.x",("GS",))[0] != "OK":
    P("\n=== E DIG b0_h2c+s168+nop500 (only if still red) ===")
    pe=make_b0_h2c()
    for r in sites168: patch_disp(pe,r,0x168,0x100)
    o=rva2off(pe,secs,0x46a500)
    ins=list(md.disasm(bytes(pe[o:o+16]),0x46a500))[0]
    pe[o:o+ins.size]=b"\x90"*ins.size
    gate(save(pe,"host_46_b0h2c_s168_nop500.exe"),"s168_nop500")

# F) confirm 0x168 write sites disasm
P("\n=== F 0x168 site context ===")
for r in sites168:
    o=rva2off(base,secs,max(0x46a4db,r-0xc))
    start=max(0x46a4db,r-0xc)
    for insn in md.disasm(bytes(base[o:o+0x28]),start):
        mark=" <<<" if insn.address==r else ""
        P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}{mark}")
        if insn.address>=r+8: break

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t504_*","_d504_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
