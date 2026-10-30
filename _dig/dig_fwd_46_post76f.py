#!/usr/bin/env python3
"""DIG fwd_46_post76f: surgical smash locus in 0x46a4db body after @46a774.
Keep 46 body (not hollow_only). Budget<=85s. Ban: tip@121278/join/epi-raise/
LIVE/mega/letter-heap/force-kind/nopr9/arg-loop/[4b0]=1."""
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
    out=cave/f"_t760_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
    rows={}
    for src in (srcs or ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]):
        if not (cave/src).exists(): continue
        tag,sh,outx=run(h,src)
        rt=run_bin(outx) if tag=="OK" and outx else "-"
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}")
        rows[src]=(tag,rt)
    return sha,rows
def hollow_at(pe,secs,hijack,epi=0x46af5d):
    oh=rva2off(pe,secs,hijack)
    rel=epi-(hijack+7)
    pe[oh:oh+7]=bytes([0x31,0xc0,0xe9])+struct.pack("<i",rel)
    return pe
def int3_at(pe,secs,rva,name,src="_var_fwd.x"):
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
    tag=run(save(pe2,f"_d760_{name}.exe"),src)[0]
    return tag
def int3_pair(pe,secs,rva,name):
    tf=int3_at(pe,secs,rva,name+"_f","_var_fwd.x")
    tl=int3_at(pe,secs,rva,name+"_l","_var_let.x")
    P(f"  INT3@{rva:06x} {name:14s} fwd={tf:8s} let={tl:8s}")
    return tf,tl
def find_disp_off(pe,secs,rva,expect_disp):
    o=rva2off(pe,secs,rva)
    ins=list(md.disasm(bytes(pe[o:o+16]),rva))[0]
    raw=bytes(pe[o:o+ins.size])
    idx=raw.find(struct.pack("<i", expect_disp))
    assert idx>=0, (hex(rva),ins.op_str,raw.hex())
    return o+idx, ins
def patch_disp(pe,secs,rva,old_d,new_d):
    off,ins=find_disp_off(pe,secs,rva,old_d)
    pe[off:off+4]=struct.pack("<i", new_d)
    return ins
def collect_disp_sites(pe,secs,start,nbytes,disp):
    off=rva2off(pe,secs,start); out=[]
    for insn in md.disasm(bytes(pe[off:off+nbytes]),start):
        o=rva2off(pe,secs,insn.address)
        raw=bytes(pe[o:o+insn.size])
        if struct.pack("<i",disp) in raw and "rbp" in insn.op_str:
            out.append(insn.address)
    return out
def zero_slot_at_entry(pe,secs,disp,hijack=0x46a4e3):
    """At lea rbp slot (8B): lea rbp,[rsp+0x80] (8) → keep lea? Too tight.
    Instead after homes: overwrite first use or plant at 46a54f-style.
    At 46a54f there is mov [rbp+0x168],0 (10B). We use a dedicated plant:
    after r9 home @46a500 (7B mov), we need elsewhere.
    Plant at @46a507 (6B mov ecx,[rbp+0x1a8]): if we want zero [rbp+disp],
    use window at 46a54f (10B) to also zero another slot — or patch specific.
    Simpler: at @46a58d `mov qword [rbp],0` (7B) region — too many clears.
    Use: replace first insn of post-76f path that loads [rbp+0x1a0] with xor+nop.
    """
    return pe

for pat in ["_t760_*","_d760_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

# A) baselines + hollow_only confirm
P("=== A baselines ===")
gate(save(bytearray(base),"host_760_base.exe"),"base")
pe=hollow_at(bytearray(base),secs,0x46a4e3)
gate(save(pe,"host_760_hollow.exe"),"hollow_only")

# B) INT3 path after @46a774 under baseline (fwd/let)
P("\n=== B INT3 post-76f under base ===")
pe=bytearray(base)
for rva,name in [
    (0x46a774,"aft76f"),
    (0x46a781,"jle8a5"),
    (0x46a8a5,"at8a5"),
    (0x46a8ba,"rd198"),
    (0x46a93c,"set_r9"),
    (0x46a958,"rd1a0"),
    (0x46a967,"call_469"),
    (0x46a96c,"aft_469"),
    (0x46a97a,"cont97a"),
    (0x46a99d,"call_47a"),
    (0x46a9c6,"aft_fe0"),
    (0x46aa14,"call_451"),
    (0x46aa27,"at_aa27"),
    (0x46aa3c,"aft_44c"),
    (0x46ab77,"at_ab77"),
    (0x46af29,"at_af29"),
    (0x46af58,"eax0"),
    (0x46af5d,"add_rsp"),
    (0x46af65,"ret1"),
    (0x57674b,"after_46"),
]:
    if time.time()-T0 > 55:
        P("  INT3 budget cut"); break
    int3_pair(pe,secs,rva,name)

# C) hollow bisect after 46a774 (keep body up to hijack)
P("\n=== C hollow bisect post-76f ===")
points=[
    (0x46a774,"h774"),
    (0x46a8a5,"h8a5"),
    (0x46a958,"h958"),
    (0x46a967,"h967"),
    (0x46a97a,"h97a"),
    (0x46a9c6,"h9c6"),
    (0x46aa27,"haa27"),
    (0x46ab77,"hab77"),
    (0x46af29,"haf29"),
    (0x46af58,"haf58"),
]
for rva,name in points:
    if time.time()-T0 > 72:
        P("  hollow budget cut"); break
    pe=hollow_at(bytearray(base),secs,rva)
    gate(save(pe,f"host_760_{name}.exe"),name,srcs=["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"])

# D) surgical: zero [rbp+0x1a0] early (6th stack) after homes
# At 46a54f: mov dword [rbp+0x168],0 = 10 bytes c7856801000000000000
# Replace with: mov qword [rbp+0x1a0],0 (8B: 48c785a001000000000000) + nop*2
P("\n=== D plant z1a0 @46a54f (zero 6th stack home) ===")
pe=bytearray(base)
o=rva2off(pe,secs,0x46a54f)
assert bytes(pe[o:o+10])==bytes.fromhex("c7856801000000000000"), bytes(pe[o:o+10]).hex()
pe[o:o+10]=bytes.fromhex("48c785a001000000000000")  # mov qword [rbp+0x1a0],0 — 11? 
# 48 c7 85 a0 01 00 00 00 00 00 00 = 11 bytes — too long for 10
# Use dword zero: c785a001000000000000 = mov dword [rbp+0x1a0],0 (10B) — zeros low half only
pe=bytearray(base)
o=rva2off(pe,secs,0x46a54f)
pe[o:o+10]=bytes.fromhex("c785a001000000000000")  # mov dword [rbp+0x1a0],0
gate(save(pe,"host_760_z1a0d.exe"),"z1a0d")

# E) zero both 1a0 and 1a8 via two early slots 46a54f + 46a559
P("\n=== E plant z1a0d+z1a8d @54f/@559 ===")
pe=bytearray(base)
o=rva2off(pe,secs,0x46a54f)
pe[o:o+10]=bytes.fromhex("c785a001000000000000")
o=rva2off(pe,secs,0x46a559)
assert bytes(pe[o:o+10])==bytes.fromhex("c7856401000000000000"), bytes(pe[o:o+10]).hex()
pe[o:o+10]=bytes.fromhex("c785a801000000000000")  # mov dword [rbp+0x1a8],0
gate(save(pe,"host_760_z6th7th.exe"),"z6th7th")

# F) force jle to 8a5 always at 46a781 (skip buffer-fill path) — diagnostic
P("\n=== F force jle@46a781 → jmp 46a8a5 (skip 1fb1e2 path) ===")
pe=bytearray(base)
o=rva2off(pe,secs,0x46a781)
# 0f8e1e010000 = jle +0x11e → 46a8a5; make jmp rel32: e9 1f 01 00 00 + nop
# jle is 6 bytes; jmp rel32 is 5; pad nop
rel=0x46a8a5-(0x46a781+5)
pe[o:o+6]=bytes([0xe9])+struct.pack("<i",rel)+bytes([0x90])
gate(save(pe,"host_760_force8a5.exe"),"force8a5")

# G) if C shows green hollow before smash and red after: try nop smash call
# Placeholder: nop call @46a967 (uses [rbp+0x1a0])
P("\n=== G skip call@46a967 (uses [rbp+0x1a0]) ===")
pe=bytearray(base)
o=rva2off(pe,secs,0x46a967)
assert pe[o]==0xE8
pe[o:o+5]=bytes.fromhex("31c0909090")  # xor eax,eax; nop*3
gate(save(pe,"host_760_skip967.exe"),"skip967")

# H) skip call@46a99d (also uses 1a0)
P("\n=== H skip call@46a99d ===")
pe=bytearray(base)
o=rva2off(pe,secs,0x46a99d)
assert pe[o]==0xE8
pe[o:o+5]=bytes.fromhex("31c0909090")
gate(save(pe,"host_760_skip99d.exe"),"skip99d")

# I) combined: z1a0d + z1a8d + skip967 (surgical keep most body)
P("\n=== I z6th7th + skip967 ===")
pe=bytearray(base)
o=rva2off(pe,secs,0x46a54f); pe[o:o+10]=bytes.fromhex("c785a001000000000000")
o=rva2off(pe,secs,0x46a559); pe[o:o+10]=bytes.fromhex("c785a801000000000000")
o=rva2off(pe,secs,0x46a967); pe[o:o+5]=bytes.fromhex("31c0909090")
gate(save(pe,"host_760_zskip967.exe"),"zskip967")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t760_*","_d760_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
