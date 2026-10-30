#!/usr/bin/env python3
"""DIG fwd_46_capless_1a0 #2: nail Capless missing [rsp+0x28]/[rsp+0x30]
vs caller@46bda6; find [4b0] writer; plant Capless 5th=qword + 6th + 7th
from Isol-native sources. Budget<=85s.
Ban: tip@121278/join/epi/LIVE/mega/letter-heap/force-kind/arg-loop/[4b0]=1."""
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
    out=cave/f"_t1a02_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
        hollowish = (sh=="e411d7260d78")
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}{' HOLLOW' if hollowish else ''}")
        rows[src]=(tag,sh,rt,hollowish)
    return sha,rows
def disasm(pe,secs,rva,n=64,stop=None):
    o=rva2off(pe,secs,rva)
    for insn in md.disasm(bytes(pe[o:o+n]),rva):
        P(f"  {insn.address:06x}: {insn.bytes.hex():24s} {insn.mnemonic} {insn.op_str}")
        if stop is not None and insn.address>=stop: break
def int3_pair(pe,secs,rva,name):
    def one(src):
        pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
        return run(save(pe2,f"_d1a02_{rva:06x}_{src[:3]}.exe"),src)[0]
    tf,tl=one("_var_fwd.x"),one("_var_let.x")
    P(f"  INT3@{rva:06x} {name:14s} fwd={tf:8s} let={tl:8s}")
    return tf,tl
def find_cave(pe,secs,need=64, PreferNear=0x576746):
    candidates=[]
    for name,(va,vs,ro,rs) in secs.items():
        if name not in (b".text",): continue
        blob=bytes(pe[ro:ro+rs]); i=0
        while i < len(blob)-need:
            if blob[i] in (0x00,0x90,0xCC):
                j=i
                while j < len(blob) and blob[j] in (0x00,0x90,0xCC): j+=1
                if j-i >= need:
                    rva=va+i; candidates.append((abs(rva-PreferNear), rva, j-i))
                i=j
            else: i+=1
    candidates.sort(); return candidates[:5]

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
secs=pe_secs(base)
P(f"base sha={hashlib.sha256(base).hexdigest()[:12]}")

# A) who WRITES [rbp+0x4b0] in Capless / SoftCap chain?
P("\n=== A writers of [rbp+0x4b0] (disp 0x4b0) near Capless ===")
# scan large region covering SoftCap twin + Capless
for start,span,label in [(0x57656c,0x800,"Capless"),(0x57ef78,0x200,"SoftCapTwin"),
                         (0x59b170,0x800,"SoftMega"),(0x2c614f,0x400,"fn2c")]:
    try:
        o=rva2off(base,secs,start)
    except: continue
    hits=[]
    for insn in md.disasm(bytes(base[o:o+span]),start):
        raw=bytes(base[rva2off(base,secs,insn.address):rva2off(base,secs,insn.address)+insn.size])
        if struct.pack("<i",0x4b0) not in raw: continue
        if insn.mnemonic.startswith("mov") and "[" in insn.op_str.split(",")[0]:
            hits.append((insn.address, insn.mnemonic, insn.op_str, insn.bytes.hex()))
    P(f"  {label} writes 4b0: {len(hits)}")
    for a,m,op,hx in hits[:12]:
        P(f"    @{a:06x} {m} {op} [{hx}]")

# B) Capless earlier SoftCap-ish calls at 576685 / 5766df — stack args?
P("\n=== B Capless mid calls stack setup @576670 / @5766c3 ===")
disasm(base,secs,0x576670,48, stop=0x576700)
P("  --")
disasm(base,secs,0x5766c0,48, stop=0x576720)

# C) caller @46bda6 clean disasm + what is [rbp+0x30]/[0x38] relative
P("\n=== C caller @46bda6 full arg setup ===")
disasm(base,secs,0x46bd83,48, stop=0x46bdb0)
# also @46bac7 with aligned start
P("\n=== C2 caller @46bac7 ===")
# find start of arg setup by scanning back for mov r9
o=rva2off(base,secs,0x46ba80)
for insn in md.disasm(bytes(base[o:o+0x60]),0x46ba80):
    if insn.address > 0x46bad0: break
    P(f"  {insn.address:06x}: {insn.bytes.hex():24s} {insn.mnemonic} {insn.op_str}")

# D) early body after 1a8 read — first call
P("\n=== D body entry after homes through first call ===")
disasm(base,secs,0x46a4eb,80, stop=0x46a560)

# E) Capless: what SoftCap/@2c stores into Capless-visible slots before call_46?
# Scan stores to [rbp+0x4xx] in Capless from SoftCap return paths
P("\n=== E Capless locals 0x4b0-0x4d0 any presence ===")
for disp in [0x4b0,0x4b4,0x4b8,0x4bc,0x4c0,0x4c8,0x4d0,0x480,0x488]:
    sites=[]
    o=rva2off(base,secs,0x57656c)
    for insn in md.disasm(bytes(base[o:o+0xd00]),0x57656c):
        raw=bytes(base[rva2off(base,secs,insn.address):rva2off(base,secs,insn.address)+insn.size])
        if struct.pack("<i",disp) in raw and "rbp" in insn.op_str:
            sites.append((insn.address, insn.mnemonic, insn.op_str))
    P(f"  disp 0x{disp:x}: {len(sites)} sites; first={sites[:3]}")

# F) Compare: SoftCap call to 46a4db? already only 3 callers.
# Mirror 46bda6 pattern onto Capless:
#   [rsp+0x20] = qword X
#   [rsp+0x28] = dword Y
# And also need [rsp+0x30] = dword Z for 7th (1a8)
# Capless has: [4a8]=r9 qword, [4a0]=r8d, [498]=rdx, [490]=rcx, [4b0]=5th dword
# Hypothesis from 46bda6: 5th=qword ptr-like, 6th=dword
# Capless currently puts dword[4b0] at 5th — maybe 5th should be qword [4a8] or [460]/[478]?
# And 6th = [4b0], 7th = something?

P("\n=== F plant variants via Capless trampoline ===")
caves=find_cave(base,secs,need=48)
assert caves, "need cave"
_, cave_rva, cave_sz = caves[0]
P(f"  cave@{cave_rva:06x} sz={cave_sz}")

def plant_tramp(pe, tramp_bytes, label):
    pe=bytearray(pe)
    assert len(tramp_bytes)<=cave_sz
    oc=rva2off(pe,secs,cave_rva)
    pe[oc:oc+len(tramp_bytes)]=bytes(tramp_bytes)
    oh=rva2off(pe,secs,0x57673f)
    # expect original or already patched — restore from base first for each plant
    return pe, oc, oh

def make_tramp(ops_hex_list):
    """ops then call 46 then jmp 57674b. ops run with rax=[490], ecx=[4b0], rdx,r8,r9 live."""
    tramp=bytearray()
    for h in ops_hex_list:
        tramp += bytes.fromhex(h)
    call_at = cave_rva + len(tramp)
    tramp += bytes([0xE8]) + struct.pack("<i", 0x46a4db-(call_at+5))
    jmp_at = cave_rva + len(tramp)
    tramp += bytes([0xE9]) + struct.pack("<i", 0x57674b-(jmp_at+5))
    return tramp

def apply_and_gate(tramp, name):
    pe=bytearray(base)
    P(f"  tramp {name} len={len(tramp)} hex={bytes(tramp).hex()}")
    if len(tramp)>cave_sz:
        P(f"  SKIP too big"); return
    oc=rva2off(pe,secs,cave_rva)
    pe[oc:oc+len(tramp)]=bytes(tramp)
    oh=rva2off(pe,secs,0x57673f)
    pe[oh:oh+12]=bytes([0xE9])+struct.pack("<i", cave_rva-(0x57673f+5))+bytes([0x90]*7)
    gate(save(pe,f"host_1a0_{name}.exe"), name)

# F1: mirror 46bda6: [rsp+0x20]=qword r9([4a8]), [rsp+0x28]=dword [4b0], [rsp+0x30]=0
# At trampoline entry we still have rax=[490], ecx=[4b0], r9, r8, rdx loaded.
apply_and_gate(make_tramp([
    "4c894c2420",           # mov [rsp+0x20], r9
    "894c2428",             # mov [rsp+0x28], ecx  (=4b0)
    "c744243000000000",     # mov dword [rsp+0x30], 0
    "4889c1",               # mov rcx, rax
]), "tr_r9_4b0_0")

# F2: [rsp+0x20]=qword r9, [rsp+0x28]=r8d, [rsp+0x30]=4b0
apply_and_gate(make_tramp([
    "4c894c2420",           # [rsp+0x20]=r9
    "4489442428",           # mov [rsp+0x28], r8d
    "894c2430",             # mov [rsp+0x30], ecx (=4b0 as 7th!)
    "4889c1",
]), "tr_r9_r8_4b0")

# F3: keep Capless 5th=[4b0] dword, add 6th=r9 qword at +0x28, 7th=r8d at +0x30
# (prior cap_tr_r9r8 put r9 at +28 and r8 at +30 WITH 5th=4b0 — got f483/GS)
# Try 5th as qword zero-extend of 4b0:
apply_and_gate(make_tramp([
    "48894c2420",           # mov [rsp+0x20], rcx  but rcx not yet=rax; ecx is 4b0 zero-ext in rcx? 
    # Wait: at this point rcx is NOT loaded — Capless does mov rcx,rax AFTER. ecx=[4b0] so rcx high garbage?
    # Use: movsxd rcx,ecx; mov [rsp+0x20],rcx; then restore rcx from rax later
]), "tr_dummy")  # placeholder — fix below

# F3 fixed: movsxd rcx,ecx; mov [rsp+0x20],rcx; mov [rsp+0x28],r9; mov [rsp+0x30],r8d; mov rcx,rax
apply_and_gate(make_tramp([
    "4863c9",               # movsxd rcx, ecx
    "48894c2420",           # mov [rsp+0x20], rcx
    "4c894c2428",           # mov [rsp+0x28], r9
    "4489442430",           # mov [rsp+0x30], r8d
    "4889c1",               # mov rcx, rax
]), "tr_sx_r9_r8")

# F4: like 46bda6 — 5th=qword from [460] (Capless derived), 6th=[4b0], 7th=0
# need to load [460]: mov rax already=[490]; use: mov rcx,[rbp+0x460]; mov [rsp+0x20],rcx; ...
# But trampoline is Capless-local — rbp is Capless rbp. Good.
apply_and_gate(make_tramp([
    "488b8d60040000",       # mov rcx, [rbp+0x460]
    "48894c2420",           # mov [rsp+0x20], rcx
    "8b8db0040000",         # mov ecx, [rbp+0x4b0]
    "894c2428",             # mov [rsp+0x28], ecx
    "c744243000000000",     # [rsp+0x30]=0
    "488b8590040000",       # mov rax, [rbp+0x490]  (reload; tramp may have clobbered? rax still ok)
    "4889c1",               # mov rcx, rax
]), "tr_460_4b0_0")

# F5: 5th=[478], 6th=[4b0], 7th=0
apply_and_gate(make_tramp([
    "488b8d78040000",       # mov rcx, [rbp+0x478]
    "48894c2420",
    "8b8db0040000",
    "894c2428",
    "c744243000000000",
    "488b8590040000",
    "4889c1",
]), "tr_478_4b0_0")

# F6: 5th=r9, 6th=0, 7th=[4b0]  — swap: maybe 7th is the mode/kind 4b0
apply_and_gate(make_tramp([
    "4c894c2420",           # [rsp+0x20]=r9
    "48c744242800000000",   # qword [rsp+0x28]=0
    "894c2430",             # [rsp+0x30]=ecx=4b0
    "4889c1",
]), "tr_r9_0_4b0")

# F7: INT3 under best candidates after gates — defer

P("\n=== G INT3 path under tr_r9_r8_4b0 if compile-ok ===")
# rebuild tr_r9_r8_4b0 pe for INT3
tramp=make_tramp([
    "4c894c2420",
    "4489442428",
    "894c2430",
    "4889c1",
])
pe=bytearray(base)
oc=rva2off(pe,secs,cave_rva); pe[oc:oc+len(tramp)]=bytes(tramp)
oh=rva2off(pe,secs,0x57673f)
pe[oh:oh+12]=bytes([0xE9])+struct.pack("<i",cave_rva-(0x57673f+5))+bytes([0x90]*7)
for rva,name in [(0x46a507,"rd1a8_entry"),(0x46a967,"call967"),(0x46a99d,"call99d"),
                 (0x46af65,"ret1"),(0x57674b,"after46"),(0x46a7cd,"rd1a0_mid")]:
    if time.time()-T0>75: break
    int3_pair(pe,secs,rva,name)

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t1a02_*","_d1a02_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
