#!/usr/bin/env python3
"""DIG fwd_46_capless_1a0 #4: 469aa4 expects; Capless 6th=qword ptr; Isol
1a0/1a8 from Capless-shaped sources; USER≠hollow≠f483-GS.
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
    out=cave/f"_t1a04_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
        mark=""
        if sh=="e411d7260d78": mark=" HOLLOW"
        elif sh=="f4839df16ab1": mark=" F483"
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}{mark}")
        rows[src]=(tag,sh,rt)
    return sha,rows
def disasm(pe,secs,rva,n=80,stop=None):
    o=rva2off(pe,secs,rva)
    for insn in md.disasm(bytes(pe[o:o+n]),rva):
        P(f"  {insn.address:06x}: {insn.bytes.hex():24s} {insn.mnemonic} {insn.op_str}")
        if stop is not None and insn.address>=stop: break
def find_cave(pe,secs,need=64, PreferNear=0x576746):
    candidates=[]
    va,vs,ro,rs=secs[b".text"]; blob=bytes(pe[ro:ro+rs]); i=0
    while i < len(blob)-need:
        if blob[i] in (0x00,0x90,0xCC):
            j=i
            while j < len(blob) and blob[j] in (0x00,0x90,0xCC): j+=1
            if j-i>=need: candidates.append((abs(va+i-PreferNear), va+i, j-i))
            i=j
        else: i+=1
    candidates.sort(); return candidates[:3]
def skip_call(pe,secs,rva):
    o=rva2off(pe,secs,rva); assert pe[o]==0xE8; pe[o:o+5]=bytes.fromhex("31c0909090")

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
secs=pe_secs(base)
P(f"base sha={hashlib.sha256(base).hexdigest()[:12]}")

# A 469aa4 prol + how it uses 5th ([rsp+0x20] at its call = 46's 6th)
P("\n=== A 469aa4 prol / 5th use ===")
disasm(base,secs,0x469aa4,96, stop=0x469b40)
P("\n=== A2 47a492 prol ===")
disasm(base,secs,0x47a492,64, stop=0x47a500)
P("\n=== A3 2a6b93 prol (1a0 as rcx) ===")
disasm(base,secs,0x2a6b93,48, stop=0x2a6bd0)
P("\n=== A4 1fe04d prol (1a8 as r8d) ===")
disasm(base,secs,0x1fe04d,40, stop=0x1fe090)

caves=find_cave(base,secs,need=64)
_, cave_rva, cave_sz = caves[0]
P(f"\ncave@{cave_rva:06x} sz={cave_sz}")

def make_tramp(ops):
    tramp=bytearray()
    for h in ops: tramp+=bytes.fromhex(h)
    call_at=cave_rva+len(tramp)
    tramp+=bytes([0xE8])+struct.pack("<i",0x46a4db-(call_at+5))
    jmp_at=cave_rva+len(tramp)
    tramp+=bytes([0xE9])+struct.pack("<i",0x57674b-(jmp_at+5))
    return tramp

def apply_gate(tramp, name):
    pe=bytearray(base)
    P(f"  {name} len={len(tramp)} hex={bytes(tramp).hex()}")
    if len(tramp)>cave_sz: P("  SKIP"); return
    pe[rva2off(pe,secs,cave_rva):rva2off(pe,secs,cave_rva)+len(tramp)]=bytes(tramp)
    pe[rva2off(pe,secs,0x57673f):rva2off(pe,secs,0x57673f)+12]=bytes([0xE9])+struct.pack("<i",cave_rva-(0x57673f+5))+bytes([0x90]*7)
    gate(save(pe,f"host_1a0_{name}.exe"), name)

# B Capless: 5th keep dword[4b0]; 6th = QWORD [490] (rcx obj); 7th = 0
P("\n=== B Capless 6th=qword[490] variants ===")
apply_gate(make_tramp([
    "894c2420",                 # 5th=4b0 dword (orig)
    "4889842428000000",         # mov [rsp+0x28], rax  (=490)  encoding?
    # rax already = [490]. Encoding mov [rsp+0x28],rax = 48 89 44 24 28 (5)
]), "bad")  # fix

apply_gate(make_tramp([
    "894c2420",                 # 5th=4b0
    "4889442428",               # mov [rsp+0x28], rax  (=490 obj)  ← 6th QWORD
    "c744243000000000",         # 7th=0
    "4889c1",
]), "tr_4b0_490_0")

apply_gate(make_tramp([
    "894c2420",
    "4889442428",               # 6th=[490]
    "4489442430",               # 7th=r8d
    "4889c1",
]), "tr_4b0_490_r8")

# 5th=qword[490], 6th=dword[4b0] — EXACT caller mirror with Capless rcx as the ptr
apply_gate(make_tramp([
    "4889442420",               # 5th=rax=[490] as QWORD
    "894c2428",                 # 6th=ecx=[4b0] as DWORD
    "4889c1",                   # rcx=rax — WAIT rax still [490], good for rcx
]), "tr_490q_4b0_no7")

# Same + 7th=0
apply_gate(make_tramp([
    "4889442420",
    "894c2428",
    "c744243000000000",
    "4889c1",
]), "tr_490q_4b0_0")

# 5th=qword[490], 6th=dword[4b0], 7th=r8d
apply_gate(make_tramp([
    "4889442420",
    "894c2428",
    "4489442430",
    "4889c1",
]), "tr_490q_4b0_r8")

# 5th=qword[498]=rdx, 6th=[4b0], no7
apply_gate(make_tramp([
    "4889542420",               # [rsp+0x20]=rdx
    "894c2428",
    "4889c1",
]), "tr_498q_4b0_no7")

# 5th=qword[4a8]=r9, 6th=[4b0], no7 — already tried as tr_r9_4b0_no7 → AV
# 5th=qword[460], 6th=[4b0], 7th=r8d
apply_gate(make_tramp([
    "488b8d60040000",
    "48894c2420",
    "8b8db0040000",
    "894c2428",
    "4489442430",               # 7th=r8d (r8 still live? yes)
    "488b8590040000",
    "4889c1",
]), "tr_460_4b0_r8")

# C Isol: fill 1a0=[180] (rcx) AND 1a8=[198] (r9d) using longer plant
# Need 7+7+6+6=26B. Use cave trampoline FROM 46 body?
# Or patch at clear region more aggressively: 46a58d through 46a5a0+
# Check how many consecutive clear movq we have
P("\n=== C clear region size ===")
disasm(base,secs,0x46a58d,48, stop=0x46a5d0)

# D Under best Capless (tr_490q_4b0_0): INT3 after967 / USER compare
# Also: Capless tr_490q + skip99d
P("\n=== D tr_490q_4b0_0 + skip99d / hollow-after-967 ===")
tramp=make_tramp(["4889442420","894c2428","c744243000000000","4889c1"])
pe=bytearray(base)
pe[rva2off(pe,secs,cave_rva):rva2off(pe,secs,cave_rva)+len(tramp)]=bytes(tramp)
pe[rva2off(pe,secs,0x57673f):rva2off(pe,secs,0x57673f)+12]=bytes([0xE9])+struct.pack("<i",cave_rva-(0x57673f+5))+bytes([0x90]*7)
pe2=bytearray(pe); skip_call(pe2,secs,0x46a99d)
gate(save(pe2,"host_1a0_490q_s99.exe"),"490q_s99")
# hollow at 46a96c (just after call967)
pe2=bytearray(pe)
oh=rva2off(pe2,secs,0x46a96c)
# 85c0 test eax,eax (2) — need 7B for hollow. Use 46a96c area: test+je+mov+jmp = many bytes
# hollow_at style at 46a96c: xor eax; jmp epi — but 46a96c is only test (2B). Use 46a967 call site after it returns: at 46a96c
rel=0x46af5d-(0x46a96c+7)
pe2[oh:oh+7]=bytes([0x31,0xc0,0xe9])+struct.pack("<i",rel)
# may clobber following bytes — check size of next insns
gate(save(pe2,"host_1a0_490q_h96c.exe"),"490q_h96c")

# E: Capless write ONLY 6th as qword[490], keep orig 5th path by not replacing 5th write
# I.e. tramp: mov [rsp+0x20],ecx; mov [rsp+0x28],rax; mov rcx,rax; call
apply_gate(make_tramp([
    "894c2420",
    "4889442428",
    "4889c1",
]), "tr_4b0_490_no7")

# F: body plant — at @46a58d set 1a0=[180], and use @46a54f (10B) to set 1a8=0
P("\n=== F body 1a0=[180] + 1a8=0 ===")
pe=bytearray(base)
pe[rva2off(pe,secs,0x46a58d):rva2off(pe,secs,0x46a58d)+16]=bytes.fromhex("488b8580010000488985a00100009090")
o=rva2off(pe,secs,0x46a54f)
assert bytes(pe[o:o+10])==bytes.fromhex("c7856801000000000000")
# replace mov [168],0 (10B) with mov dword [1a8],0 (10B): c785 a8010000 00000000
pe[o:o+10]=bytes.fromhex("c785a801000000000000")
gate(save(pe,"host_1a0_b180_z1a8.exe"),"b180_z1a8")

# G: body 1a0=[180], 1a8=[198] via two 10B slots — 54f and 559
# 559 is mov [164],0 (10B). 
# For 1a8=[198]: need mov eax,[198]; mov [1a8],eax = 6+6=12 > 10.
# dword: mov eax,[198](6)+mov [1a8],eax(6)=12.
# At 58d 16B: mov rax,[180](7); mov [1a0],rax(7); nop nop = 1a0 only.
# Combine Capless tramp 6th=[490] qword (=same as 180 after home) with 7th=0 already tried.

# H: Compare USER bytes hollow vs f483 — what differs?
P("\n=== H USER hollow vs f483 diff (if files exist) ===")
# compile both
h_skip=cave/"host_skip_1a0_calls.exe"
h_f483=cave/"host_1a0_tr_460_4b0_0.exe"
if not h_f483.exists():
    h_f483=cave/"host_1a0_tr_4b0_490_0.exe"
for label,h in [("skip",h_skip),("f483cand",h_f483)]:
    if not h.exists(): P(f"  missing {h.name}"); continue
    tag,sh,outx=run(h,"p_ret_fwd.x")
    P(f"  {label} compile={tag} USER={sh}")
    if outx and outx.exists():
        b=outx.read_bytes()
        # find .text and show first differing region vs known
        P(f"  {label} size={len(b)}")

# Produce both USERS and binary diff
tag1,sh1,u1=run(cave/"host_skip_1a0_calls.exe","p_ret_fwd.x")
# use a known f483 host
fhost=None
for cand in ["host_1a0_tr_460_4b0_0.exe","host_1a0_cap_tr_r9r8.exe","host_763_z1a0.exe","host_760_skip99d.exe"]:
    if (cave/cand).exists(): fhost=cave/cand; break
if fhost:
    tag2,sh2,u2=run(fhost,"p_ret_fwd.x")
    P(f"  skip USER={sh1} {fhost.name} USER={sh2}")
    if u1 and u2 and u1.exists() and u2.exists():
        b1,b2=u1.read_bytes(),u2.read_bytes()
        # PE .text diff sample
        def text(buf):
            e=struct.unpack_from("<I",buf,0x3C)[0]
            nsec=struct.unpack_from("<H",buf,e+6)[0]
            opt=struct.unpack_from("<H",buf,e+20)[0]
            sec=e+24+opt
            for i in range(nsec):
                o=sec+i*40; n=bytes(buf[o:o+8]).split(b"\0")[0]
                vs,va,rs,ro=struct.unpack_from("<IIII",buf,o+8)
                if n==b".text": return buf[ro:ro+rs],va
            return buf,0
        t1,v1=text(b1); t2,v2=text(b2)
        diffs=[]
        for i,(x,y) in enumerate(zip(t1,t2)):
            if x!=y: diffs.append(i)
        P(f"  .text len {len(t1)} vs {len(t2)}; ndiff={len(diffs)}")
        if diffs:
            i0=diffs[0]
            P(f"  first diff off={i0:#x} rva≈{v1+i0:#x}")
            P(f"  hollow={t1[i0:i0+32].hex()}")
            P(f"  f483  ={t2[i0:i0+32].hex()}")
            # disasm both
            for lab,blob in [("H",t1[i0:i0+48]),("F",t2[i0:i0+48])]:
                P(f"  -- {lab} --")
                for insn in md.disasm(bytes(blob), v1+i0):
                    P(f"    {insn.address:06x}: {insn.mnemonic} {insn.op_str}")
                    if insn.address > v1+i0+24: break

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t1a04_*","_d1a04_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
