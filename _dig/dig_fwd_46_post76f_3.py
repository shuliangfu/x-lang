#!/usr/bin/env python3
"""DIG fwd_46_post76f #3: smash in 8a5..97a; skip967+skip99d; z1a0; jmp8a5→97a.
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
    out=cave/f"_t763_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
        if not (cave/src).exists(): continue
        tag,sh,outx=run(h,src)
        rt=run_bin(outx) if tag=="OK" and outx else "-"
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}")
    return sha
def hollow_at(pe,secs,hijack,epi=0x46af5d):
    oh=rva2off(pe,secs,hijack)
    rel=epi-(hijack+7)
    pe[oh:oh+7]=bytes([0x31,0xc0,0xe9])+struct.pack("<i",rel)
def skip_call(pe,secs,rva):
    o=rva2off(pe,secs,rva); assert pe[o]==0xE8
    pe[o:o+5]=bytes.fromhex("31c0909090")
def int3_pair(pe,secs,rva,name):
    def one(src,suf):
        pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
        return run(save(pe2,f"_d763_{name}{suf}.exe"),src)[0]
    tf,tl=one("_var_fwd.x","f"),one("_var_let.x","l")
    P(f"  INT3@{rva:06x} {name:14s} fwd={tf:8s} let={tl:8s}")

for pat in ["_t763_*","_d763_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

# blob: xor rax,rax; mov [rbp+0x1a0],rax; mov [rbp+0x1a8],eax  (16B)
BLOB_Z=bytes.fromhex("4831c0488985a00100008985a8010000")
assert len(BLOB_Z)==16

def plant_z1a0(pe):
    o=rva2off(pe,secs,0x46a58d)
    assert bytes(pe[o:o+8])==bytes.fromhex("48c7450000000000")
    pe[o:o+16]=BLOB_Z

# A) refs
P("=== A refs ===")
gate(save(bytearray(base),"host_763_base.exe"),"base")
pe=bytearray(base); hollow_at(pe,secs,0x46a4e3)
gate(save(pe,"host_763_hollow.exe"),"hollow")
pe=bytearray(base); hollow_at(pe,secs,0x46a8a5)
gate(save(pe,"host_763_h8a5.exe"),"h8a5")

# B) jmp 8a5 → 97a (skip middle 8a5..97a body, keep 97a+)
P("\n=== B jmp @46a8a5 → 46a97a ===")
pe=bytearray(base)
o=rva2off(pe,secs,0x46a8a5)
# need 5 bytes for jmp; 8a5 is mov/6 — use jmp + nop
rel=0x46a97a-(0x46a8a5+5)
pe[o:o+6]=bytes([0xe9])+struct.pack("<i",rel)+bytes([0x90])
gate(save(pe,"host_763_jmp97a.exe"),"jmp97a")

# C) skip967 only / skip967+skip99d / skip967+xor_r8
P("\n=== C skip967 variants ===")
pe=bytearray(base); skip_call(pe,secs,0x46a967)
gate(save(pe,"host_763_skip967.exe"),"skip967")
pe=bytearray(base); skip_call(pe,secs,0x46a967); skip_call(pe,secs,0x46a99d)
gate(save(pe,"host_763_s967_99d.exe"),"s967_99d")

# D) z1a0_1a8 (supply zero stack args)
P("\n=== D z1a0_1a8 ===")
pe=bytearray(base); plant_z1a0(pe)
gate(save(pe,"host_763_z1a0.exe"),"z1a0")

# E) z1a0 + skip99d / z1a0 + skip967+99d
P("\n=== E z1a0 combos ===")
pe=bytearray(base); plant_z1a0(pe); skip_call(pe,secs,0x46a99d)
gate(save(pe,"host_763_z_s99.exe"),"z_s99")
pe=bytearray(base); plant_z1a0(pe); skip_call(pe,secs,0x46a967); skip_call(pe,secs,0x46a99d)
gate(save(pe,"host_763_z_s96799.exe"),"z_s96799")

# F) hollow fine bisect in 8a5..97a
P("\n=== F hollow bisect 8a5..97a ===")
for rva,name in [(0x46a8a5,"h8a5b"),(0x46a8ba,"h8ba"),(0x46a8e3,"h8e3"),
                 (0x46a93c,"h93c"),(0x46a958,"h958b"),(0x46a96c,"h96c"),(0x46a97a,"h97ab")]:
    if time.time()-T0>60: break
    pe=bytearray(base); hollow_at(pe,secs,rva)
    gate(save(pe,f"host_763_{name}.exe"),name)

# G) under z1a0: INT3 path + gate if promising
P("\n=== G z1a0 INT3 path (if lit not AV) ===")
pe=bytearray(base); plant_z1a0(pe)
# quick lit check already in D; path probe
for rva,name in [(0x46a967,"z_c469"),(0x46a96c,"z_a469"),(0x46a99d,"z_c47a"),
                 (0x46af65,"z_ret"),(0x57674b,"z_aft46")]:
    int3_pair(pe,secs,rva,name)

# H) jmp8a5→97a + skip99d
P("\n=== H jmp97a + skip99d ===")
pe=bytearray(base)
o=rva2off(pe,secs,0x46a8a5)
rel=0x46a97a-(0x46a8a5+5)
pe[o:o+6]=bytes([0xe9])+struct.pack("<i",rel)+bytes([0x90])
skip_call(pe,secs,0x46a99d)
gate(save(pe,"host_763_j97_s99.exe"),"j97_s99")

# I) Capless: write [rsp+0x28]=0 and [rsp+0x30]=0 by expanding —
# Replace mov rcx,rax (3) + call (5) = 8 bytes with:
#   xor ecx,ecx; mov [rsp+0x28],ecx; mov [rsp+0x30],ecx; mov rcx,rax; call
# Too big. Shorter: mov qword [rsp+0x28], 0 (9B) alone > 8.
# Use dig: change 5th write to movq zero-extend? 
# Alternative Capless plant at 57671d area — skip for now if z1a0 works.

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t763_*","_d763_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
