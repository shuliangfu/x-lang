#!/usr/bin/env python3
"""DIG fwd_2c6174 #5: robust disp patch; chain_rt SoftCap+2c+46a4db; next callee.
Budget<=85s."""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys, re
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64); md.detail=True
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
    out=cave/f"_t745_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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

for pat in ["_t745_*","_d745_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

def find_disp_off(pe,rva,expect_disp):
    """Return file offset of disp32 for [rbp+expect_disp] insn at rva."""
    o=rva2off(pe,secs,rva)
    ins=list(md.disasm(bytes(pe[o:o+16]),rva))[0]
    raw=bytes(pe[o:o+ins.size])
    # search for expect_disp as imm32 little-endian inside insn
    needle=struct.pack("<i", expect_disp)
    idx=raw.find(needle)
    assert idx>=0, (hex(rva),raw.hex(),hex(expect_disp),ins.mnemonic,ins.op_str)
    return o+idx, ins

def patch_disp(pe,rva,old_d,new_d):
    off,ins=find_disp_off(pe,rva,old_d)
    pe[off:off+4]=struct.pack("<i", new_d)
    return ins

def nop_ins(pe,rva):
    o=rva2off(pe,secs,rva)
    ins=list(md.disasm(bytes(pe[o:o+16]),rva))[0]
    pe[o:o+ins.size]=b"\x90"*ins.size
    return ins

def collect_disp_sites(start,end,disp):
    off=rva2off(base,secs,start)
    out=[]
    for insn in md.disasm(bytes(base[off:off+(end-start)]),start):
        if f"0x{disp:x}" in insn.op_str or (disp<0 and f"-0x{-disp:x}" in insn.op_str):
            # verify raw contains disp
            o=rva2off(base,secs,insn.address)
            raw=bytes(base[o:o+insn.size])
            if struct.pack("<i",disp) in raw:
                out.append(insn.address)
        if insn.address>=end: break
    return out

# Collect sites
scs=collect_disp_sites(0x2be519,0x2be912,0xf8)
h2c=collect_disp_sites(0x2c614f,0x2c66a8,0x138)
c46=collect_disp_sites(0x46a4db,0x46a4db+0x500,0x198)
P(f"scs 0xf8 sites={[hex(x) for x in scs]}")
P(f"h2c 0x138 sites={[hex(x) for x in h2c]}")
P(f"c46 0x198 sites={[hex(x) for x in c46]}")

# A) chain_rt
P("\n=== A chain_rt scs→0xb0 h2c→0x100 c46→0x160 ===")
pe=bytearray(base)
for r in scs: patch_disp(pe,r,0xf8,0xb0)
for r in h2c: patch_disp(pe,r,0x138,0x100)
for r in c46: patch_disp(pe,r,0x198,0x160)
h=save(pe,"host_2c_chain_rt.exe")
gate(h,"chain_rt")
for rva,name in [(0x2be911,"scs_pop"),(0x57674b,"after_46"),(0x5767a0,"call_493"),(0x578278,"cap_epi"),(0x123781,"caller")]:
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
    tf=run(save(pe2,f"_d745_{name}.exe"),"_var_fwd.x")[0]
    tl=run(save(pe2,f"_d745_{name}.exe"),"_var_let.x")[0]
    P(f"  chain INT3@{rva:06x} {name:10s} fwd={tf:8s} let={tl:8s}")

# B) triple nop
P("\n=== B triple nop ===")
pe=bytearray(base)
for r in (0x2be53e,0x2c6174,0x46a500):
    ins=nop_ins(pe,r); P(f"  nop {ins.address:06x} {ins.mnemonic} {ins.op_str}")
h=save(pe,"host_2c_triple_nop.exe")
gate(h,"triple")
for rva,name in [(0x2be911,"scs_pop"),(0x57674b,"after_46"),(0x578278,"cap_epi"),(0x123781,"caller")]:
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
    tf=run(save(pe2,f"_d745_t{name}.exe"),"_var_fwd.x")[0]
    tl=run(save(pe2,f"_d745_t{name}.exe"),"_var_let.x")[0]
    P(f"  triple INT3@{rva:06x} {name:10s} fwd={tf:8s} let={tl:8s}")

# C) 0x493d31 smash?
P("\n=== C 0x493d31 prol ===")
off=rva2off(base,secs,0x493d31)
for insn in md.disasm(bytes(base[off:off+0x40]),0x493d31):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x493d80: break
# frame math if lea style
# D) if 493d31 also isomorphic, add to chain
P("\n=== D quad chain if 493 isomorphic ===")
# parse sub/lea/r9 home
insns=list(md.disasm(bytes(base[off:off+0x30]),0x493d31))
sub=lea=r9h=None
for i in insns:
    if i.mnemonic=="sub" and "rsp" in i.op_str: sub=i
    if i.mnemonic=="lea" and "rbp" in i.op_str: lea=i
    if i.mnemonic=="mov" and "r9" in i.op_str and "rbp" in i.op_str: r9h=i
P(f"  sub={sub.op_str if sub else None} lea={lea.op_str if lea else None} r9={r9h.op_str if r9h else None}")
if r9h:
    # extract disp from r9h
    o=rva2off(base,secs,r9h.address)
    raw=bytes(base[o:o+r9h.size])
    # find large disp
    m=re.search(r"0x([0-9a-f]+)", r9h.op_str.split("rbp")[-1])
    disp=int(m.group(1),16) if m else None
    P(f"  r9 home disp={hex(disp) if disp else None} raw={raw.hex()}")
    if disp:
        # check call_rsp+0x20: need sub imm and lea imm
        sm=re.search(r"0x([0-9a-f]+)", sub.op_str) if sub else None
        lm=re.search(r"0x([0-9a-f]+)", lea.op_str) if lea else None
        if sm and lm:
            sub_i=int(sm.group(1),16); lea_i=int(lm.group(1),16)
            # [rbp+disp] = call_rsp - 8 - sub + lea + disp = call_rsp+0x20?
            alias = -8 - sub_i + lea_i + disp
            P(f"  alias_off_from_call_rsp={hex(alias)} (want 0x20)")
            if alias==0x20:
                sites=collect_disp_sites(0x493d31,0x493d31+0x600,disp)
                P(f"  493 sites={[hex(x) for x in sites]}")
                pe=bytearray(base)
                for r in scs: patch_disp(pe,r,0xf8,0xb0)
                for r in h2c: patch_disp(pe,r,0x138,0x100)
                for r in c46: patch_disp(pe,r,0x198,0x160)
                # retarget 493 to disp that lands call_rsp-0x18
                # call_rsp-0x18 = -8-sub+lea+new → new = -0x18+8+sub-lea = sub-lea-0x10
                newd = sub_i - lea_i - 0x10
                P(f"  493 retarget {hex(disp)}→{hex(newd)}")
                for r in sites: patch_disp(pe,r,disp,newd)
                h=save(pe,"host_2c_quad_rt.exe")
                gate(h,"quad_rt")
                for rva,name in [(0x2be911,"scs_pop"),(0x5767a5,"after_493"),(0x578278,"cap_epi"),(0x123781,"caller")]:
                    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
                    tf=run(save(pe2,f"_d745_q{name}.exe"),"_var_fwd.x")[0]
                    tl=run(save(pe2,f"_d745_q{name}.exe"),"_var_let.x")[0]
                    P(f"  quad INT3@{rva:06x} {name:10s} fwd={tf:8s} let={tl:8s}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t745_*","_d745_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
