#!/usr/bin/env python3
"""DIG fwd_46_capless_1a0 #3: Capless prol/[4b0] origin; Isol fill 1a0/1a8
from body-native sources; bisect f483 GS after call967.
Budget<=85s. Ban tip@121278/join/epi/LIVE/mega/letter-heap/force-kind."""
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
    out=cave/f"_t1a03_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
def disasm(pe,secs,rva,n=64,stop=None):
    o=rva2off(pe,secs,rva)
    for insn in md.disasm(bytes(pe[o:o+n]),rva):
        P(f"  {insn.address:06x}: {insn.bytes.hex():24s} {insn.mnemonic} {insn.op_str}")
        if stop is not None and insn.address>=stop: break
def int3_at(pe,secs,rva,src):
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
    return run(save(pe2,f"_d1a03_{rva:06x}.exe"),src)[0]
def find_cave(pe,secs,need=64, PreferNear=0x576746):
    candidates=[]
    for name,(va,vs,ro,rs) in secs.items():
        if name!=b".text": continue
        blob=bytes(pe[ro:ro+rs]); i=0
        while i < len(blob)-need:
            if blob[i] in (0x00,0x90,0xCC):
                j=i
                while j < len(blob) and blob[j] in (0x00,0x90,0xCC): j+=1
                if j-i>=need: candidates.append((abs(va+i-PreferNear), va+i, j-i))
                i=j
            else: i+=1
    candidates.sort(); return candidates[:3]
def skip_call(pe,secs,rva):
    o=rva2off(pe,secs,rva)
    assert pe[o]==0xE8, hex(pe[o])
    pe[o:o+5]=bytes.fromhex("31c0909090")

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
secs=pe_secs(base)
P(f"base sha={hashlib.sha256(base).hexdigest()[:12]}")

# A Capless prologue + where 4b0 lives relative to Capless frame
P("\n=== A Capless prol + 4b0 frame math ===")
disasm(base,secs,0x57656c,48, stop=0x5765c0)
# Find Capless lea rbp / sub rsp
o=rva2off(base,secs,0x576560)
for insn in md.disasm(bytes(base[o:o+0x40]),0x576560):
    P(f"  {insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    if insn.address>=0x5765a0: break

# Scan WHOLE .text for writes to disp 0x4b0 with rbp
P("\n=== A2 global writers of [rbp+0x4b0] ===")
va,vs,ro,rs=secs[b".text"]
blob=bytes(base[ro:ro+rs])
# pattern: C7 85 B0 04 00 00 (mov dword) or 89 xx B0 04 00 00 or 48 89 xx B0 04 00 00
disp=struct.pack("<i",0x4b0)
writers=[]
i=0
while True:
    j=blob.find(disp, i)
    if j<0: break
    # back up to find insn start — disasm window
    start=max(0,j-8)
    for insn in md.disasm(blob[start:j+8], va+start):
        off=insn.address-(va+start)
        raw=insn.bytes
        if disp in raw and insn.mnemonic.startswith("mov"):
            dst=insn.op_str.split(",")[0]
            if "[" in dst:
                writers.append((insn.address, insn.mnemonic, insn.op_str))
    i=j+1
P(f"  writers count≈{len(writers)}")
for a,m,op in writers[:30]:
    P(f"    @{a:06x} {m} {op}")

# B Who calls Capless @57656c — what 5th they pass?
P("\n=== B callers of Capless entry (E8→0x57656c or near) ===")
# Capless may be entered via multiple; find E8 to 57656c
callers=[]
for i in range(len(blob)-5):
    if blob[i]==0xE8:
        rel=struct.unpack_from("<i",blob,i+1)[0]
        src=va+i; tgt=src+5+rel
        if tgt==0x57656c:
            callers.append(src)
P(f"  direct callers of 57656c: {list(map(hex,callers))[:20]} count={len(callers)}")
# Also SoftCap twin calls SoftMega not Capless; Capless from kind dispatch.
# Check a few callers' stack setup
for c in callers[:4]:
    P(f"  -- Capless caller @{c:06x} --")
    disasm(base,secs,c-0x28,0x30, stop=c+5)

# C Nail: callers write 6th dword at +0x28, NOT 7th. So [rbp+0x1a8] for those
# callers = whatever was at call_rsp+0x30. Often MSVC allocates home for
# spilled args. Check: maybe 7th should equal Capless's [4b0] moved to +0x30,
# and 6th should be a pointer object.
# Look at mid body @46a7cd use of 1a0
P("\n=== C mid use @46a7cd of 1a0 ===")
disasm(base,secs,0x46a7b0,48, stop=0x46a820)

# D Plant: Capless trampoline EXACT mirror of @46bac7/@46bda6:
#   [rsp+0x20] = qword from Capless [460] or [478] or [4a8]
#   [rsp+0x28] = dword from [4b0]
#   NO write to +0x30 (leave as-is / or explicit 0)
# Prior tr_460_4b0_0 wrote +0x30=0 and got f483/GS.
# Try WITHOUT writing +0x30 (leave stack garbage — match real callers)
caves=find_cave(base,secs,need=48)
_, cave_rva, cave_sz = caves[0]
P(f"\n=== D plants cave@{cave_rva:06x} ===")

def make_tramp(ops):
    tramp=bytearray()
    for h in ops: tramp += bytes.fromhex(h)
    call_at=cave_rva+len(tramp)
    tramp += bytes([0xE8])+struct.pack("<i",0x46a4db-(call_at+5))
    jmp_at=cave_rva+len(tramp)
    tramp += bytes([0xE9])+struct.pack("<i",0x57674b-(jmp_at+5))
    return tramp

def apply_gate(tramp, name):
    pe=bytearray(base)
    P(f"  {name} len={len(tramp)}")
    if len(tramp)>cave_sz: P("  SKIP"); return None
    pe[rva2off(pe,secs,cave_rva):rva2off(pe,secs,cave_rva)+len(tramp)]=bytes(tramp)
    oh=rva2off(pe,secs,0x57673f)
    pe[oh:oh+12]=bytes([0xE9])+struct.pack("<i",cave_rva-(0x57673f+5))+bytes([0x90]*7)
    return gate(save(pe,f"host_1a0_{name}.exe"), name)

# D1: mirror callers — 5th=qword[4a8], 6th=dword[4b0], no 7th write
apply_gate(make_tramp([
    "4c894c2420",     # mov [rsp+0x20], r9
    "894c2428",       # mov [rsp+0x28], ecx (=4b0)
    "4889c1",         # mov rcx, rax
]), "tr_r9_4b0_no7")

# D2: 5th=[460], 6th=[4b0], no 7th
apply_gate(make_tramp([
    "488b8d60040000", # rcx=[460]
    "48894c2420",
    "8b8db0040000",
    "894c2428",
    "488b8590040000", # reload rax
    "4889c1",
]), "tr_460_4b0_no7")

# D3: 5th=[478], 6th=[4b0], no 7th
apply_gate(make_tramp([
    "488b8d78040000",
    "48894c2420",
    "8b8db0040000",
    "894c2428",
    "488b8590040000",
    "4889c1",
]), "tr_478_4b0_no7")

# D4: keep original Capless 5th=dword[4b0] at +0x20, add 6th=0 at +0x28 only (no 7th)
apply_gate(make_tramp([
    "894c2420",             # [rsp+0x20]=ecx=4b0 (orig)
    "c744242800000000",     # [rsp+0x28]=0
    "4889c1",
]), "tr_4b0_0_no7")

# D5: orig 5th + 6th=r9 dword low? + no 7th — 6th as dword from r9d
apply_gate(make_tramp([
    "894c2420",
    "44894c2428",           # mov [rsp+0x28], r9d
    "4889c1",
]), "tr_4b0_r9d_no7")

# E Isol-side: at 46 entry AFTER homes, force [1a0]/[1a8] from known good
# Homes end at 46a507 which READS 1a8. Before that, at 46a4eb we could
# inject — but prol is tight. Use clear slots @46a58d (16B) to set:
#   mov rax, [rbp+0x180]  ; original rcx home = Capless's rcx = [490] object
#   mov [rbp+0x1a0], rax  ; 6th = object ptr (like caller's [rbp+0x30]?)
#   mov eax, [rbp+0x198]  ; r9d home
#   mov [rbp+0x1a8], eax  ; 7th = r9d
# Sizes: 488b8580010000 (7) + 488985a0010000 (7) = 14, + 8b8598010000 (6) + 8985a8010000 (6) = 26 > 16
# Smaller: only set 1a0 from 180 (7+7=14):
P("\n=== E Isol body fill 1a0 from rcx-home ===")
blob=bytes.fromhex("488b8580010000488985a00100009090")  # mov rax,[180]; mov [1a0],rax; nop nop
assert len(blob)==16
pe=bytearray(base)
o=rva2off(pe,secs,0x46a58d)
assert bytes(pe[o:o+8])==bytes.fromhex("48c7450000000000")
pe[o:o+16]=blob
gate(save(pe,"host_1a0_b180.exe"),"b180")

# E2: fill 1a0 from 180 AND 1a8 from 4b0-equivalent. 4b0 isn't in 46 frame.
# Capless 5th was overwritten by r9 home into [198]. Original Capless 5th lost.
# Callers' 6th is a small int. Try 1a8=0 via dword store in remaining — need more space.
# Use two slots: 46a58d (8) and continue — we already use 16.
# Alternate at @46a54f (10B mov [rbp+0x168],0 area) — check bytes
P("\n=== E3 slot @46a54f ===")
disasm(base,secs,0x46a540,40, stop=0x46a5a0)

# F: under Capless tr_460_4b0_no7 (or best), skip99d only — if run greens → 99d args wrong
P("\n=== F Capless mirror+skip99d / skip967 ===")
tramp=make_tramp([
    "488b8d60040000","48894c2420","8b8db0040000","894c2428",
    "488b8590040000","4889c1",
])
pe=bytearray(base)
pe[rva2off(pe,secs,cave_rva):rva2off(pe,secs,cave_rva)+len(tramp)]=bytes(tramp)
pe[rva2off(pe,secs,0x57673f):rva2off(pe,secs,0x57673f)+12]=bytes([0xE9])+struct.pack("<i",cave_rva-(0x57673f+5))+bytes([0x90]*7)
pe2=bytearray(pe); skip_call(pe2,secs,0x46a99d)
gate(save(pe2,"host_1a0_460_s99.exe"),"460_s99")
pe2=bytearray(pe); skip_call(pe2,secs,0x46a967)
gate(save(pe2,"host_1a0_460_s967.exe"),"460_s967")

# G: Capless mirror + body fill 1a8=0 at entry read site — patch 46a507 to xor ecx,ecx
P("\n=== G force 1a8-read → xor ecx (entry) under Capless 460 mirror ===")
pe2=bytearray(pe)
o=rva2off(pe2,secs,0x46a507)
# 8b8da8010000 (6) → 31c990909090 (xor ecx,ecx; nops)
assert bytes(pe2[o:o+6])==bytes.fromhex("8b8da8010000")
pe2[o:o+6]=bytes.fromhex("31c990909090")
gate(save(pe2,"host_1a0_460_z7rd.exe"),"460_z7rd")

# H: also patch ALL 1a8 reads to xor ecx? too heavy. Try only entry+52b first chain.
# Better: Capless write 7th=[4b0], 6th=0, 5th=[460] — 7th is the mode dword used as r8d
apply_gate(make_tramp([
    "488b8d60040000",
    "48894c2420",           # 5th=[460]
    "c744242800000000",     # 6th=0
    "8b8db0040000",
    "894c2430",             # 7th=[4b0]
    "488b8590040000",
    "4889c1",
]), "tr_460_0_4b0")

# I: 5th=[460], 6th=[4b0], 7th=[4b0] (same)
apply_gate(make_tramp([
    "488b8d60040000",
    "48894c2420",
    "8b8db0040000",
    "894c2428",
    "894c2430",
    "488b8590040000",
    "4889c1",
]), "tr_460_4b0_4b0")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t1a03_*","_d1a03_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
