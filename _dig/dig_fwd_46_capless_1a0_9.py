#!/usr/bin/env python3
"""DIG fwd_46_capless_1a0 #9: 1a8 writers; 4698c0 5th; force type≠need-967;
combo skip99d with good-967 path; live USER from twin_probe.
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
    out=cave/f"_t1a09_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
        if tag=="OK" and src=="p_ret_fwd.x" and rt=="OK" and sh not in ("e411d7260d78","-"):
            P(f"  *** NON-HOLLOW RUN-OK USER={sh} ***")
    return sha,rows
def disasm(pe,secs,rva,n=96,stop=None):
    o=rva2off(pe,secs,rva)
    for insn in md.disasm(bytes(pe[o:o+n]),rva):
        P(f"  {insn.address:06x}: {insn.bytes.hex():24s} {insn.mnemonic} {insn.op_str}")
        if stop is not None and insn.address>=stop: break
def skip_call(pe,secs,rva):
    o=rva2off(pe,secs,rva); assert pe[o]==0xE8
    pe[o:o+5]=bytes.fromhex("31c0909090")
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
    candidates.sort(); return candidates[0]

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
secs=pe_secs(base)
P(f"base sha={hashlib.sha256(base).hexdigest()[:12]}")

# A writers of [1a8] in Isol body
P("\n=== A [1a8] writers in body ===")
body_off=rva2off(base,secs,0x46a4db)
body_end=rva2off(base,secs,0x46af5d)
body=bytes(base[body_off:body_end])
for i in range(len(body)-6):
    # disp a8 01 00 00
    if body[i:i+4]==bytes.fromhex("a8010000"):
        start=max(0,i-4)
        P(f"  @{0x46a4db+start:06x}: {body[start:i+4].hex()}")

# B 4698c0: scan for [rbp+0x30] / 5th
P("\n=== B 4698c0 5th ([rbp+0x30]) reads ===")
fn=bytes(base[rva2off(base,secs,0x4698c0):rva2off(base,secs,0x469aa4)])
for i in range(len(fn)-3):
    if fn[i:i+3] in (b'\x45\x30\x00',) or (fn[i]==0x8b and i+2<len(fn) and fn[i+1] in (0x45,0x4d,0x55,0x5d) and fn[i+2]==0x30):
        P(f"  hit @{0x4698c0+i:06x}: {fn[i:i+8].hex()}")
    if fn[i:i+4] in (b'\x48\x8b\x45\x30',b'\x48\x8b\x4d\x30',b'\x48\x8b\x55\x30',b'\x4c\x8b\x45\x30',b'\x4c\x8b\x4d\x30'):
        P(f"  hitq @{0x4698c0+i:06x}: {fn[i:i+8].hex()}")
# also any 0x30 disp with rbp
for i in range(len(fn)-2):
    if fn[i:i+2]==b'\x45\x30' or fn[i:i+2]==b'\x4d\x30':
        P(f"  disp30 @{0x4698c0+i:06x}: {fn[max(0,i-2):i+4].hex()}")

# C Disasm more of 4698c0 where it might use 5th
P("\n=== C 4698c0 continued toward end ===")
disasm(base,secs,0x4699b4,120, stop=0x469a50)
disasm(base,secs,0x469a50,80, stop=0x469aa0)

# D Capless tramp 460_4b0 + skip99d only (967 runs) — already know f483
# Try: Capless 460_4b0 + zero 1a8 in body + keep 99d
P("\n=== D Capless 460 mirror + Isol 1a8=0 ===")
_, cave_rva, cave_sz = find_cave(base,secs,need=64)
def make_tramp(ops):
    tramp=bytearray()
    for h in ops: tramp+=bytes.fromhex(h)
    call_at=cave_rva+len(tramp)
    tramp+=bytes([0xE8])+struct.pack("<i",0x46a4db-(call_at+5))
    jmp_at=cave_rva+len(tramp)
    tramp+=bytes([0xE9])+struct.pack("<i",0x57674b-(jmp_at+5))
    return tramp

tramp=make_tramp([
    "488b8d60040000","48894c2420",  # 5th=[460]
    "8b8db0040000","894c2428",      # 6th=[4b0]
    "488b8590040000","4889c1",
])
pe=bytearray(base)
pe[rva2off(pe,secs,cave_rva):rva2off(pe,secs,cave_rva)+len(tramp)]=bytes(tramp)
pe[rva2off(pe,secs,0x57673f):rva2off(pe,secs,0x57673f)+12]=bytes([0xE9])+struct.pack("<i",cave_rva-(0x57673f+5))+bytes([0x90]*7)
# zero 1a8 at 46a54f (10B slot was mov [168],0)
o=rva2off(pe,secs,0x46a54f)
pe[o:o+10]=bytes.fromhex("c785a801000000000000")  # mov dword [1a8],0
gate(save(pe,"host_1a0_460_z1a8.exe"),"460_z1a8")

# E: same but also skip99d
pe2=bytearray(pe); skip_call(pe2,secs,0x46a99d)
gate(save(pe2,"host_1a0_460_z1a8_s99.exe"),"460_z1a8_s99")

# F: Force cmp eax,3 path — at 46a909, the eax from 20cd98. 
# Instead force always take twin's fallthrough (nop the jne → always do 90e path)
# Isol has jmp; change to nop nop (90 90) so ALWAYS fall through 90e like eax==3
P("\n=== F force fallthrough @90c (nop jmp) + Capless 460 ===")
pe=bytearray(base)
pe[rva2off(pe,secs,0x46a90c)]=0x90
pe[rva2off(pe,secs,0x46a90d)]=0x90  # was eb 2e → 90 90; falls through
pe[rva2off(pe,secs,cave_rva):rva2off(pe,secs,cave_rva)+len(tramp)]=bytes(tramp)
pe[rva2off(pe,secs,0x57673f):rva2off(pe,secs,0x57673f)+12]=bytes([0xE9])+struct.pack("<i",cave_rva-(0x57673f+5))+bytes([0x90]*7)
gate(save(pe,"host_1a0_ft90_460.exe"),"ft90_460")

# G: Only force fallthrough @90c (no Capless change)
pe=bytearray(base)
pe[rva2off(pe,secs,0x46a90c):rva2off(pe,secs,0x46a90c)+2]=b'\x90\x90'
gate(save(pe,"host_1a0_ft90.exe"),"ft90")

# H: twin_probe USER 546a4c6d02df — save and compare to f483/hollow
P("\n=== H twin_probe USER vs hollow/f483 ===")
tag,sh,outx=run(cave/"xlang_isol1060_twin_probe.exe","p_ret_fwd.x")
P(f"  twin_probe compile={tag} USER={sh}")
if outx:
    rt=run_bin(outx); P(f"  twin_probe run={rt}")
    # diff vs hollow
    tag1,sh1,u1=run(cave/"host_skip_1a0_calls.exe","p_ret_fwd.x")
    def get_text(buf):
        e=struct.unpack_from("<I",buf,0x3C)[0]
        nsec=struct.unpack_from("<H",buf,e+6)[0]
        opt=struct.unpack_from("<H",buf,e+20)[0]
        sec=e+24+opt
        for i in range(nsec):
            o=sec+i*40; n=bytes(buf[o:o+8]).split(b"\0")[0]
            vs,va,rs,ro=struct.unpack_from("<IIII",buf,o+8)
            if n==b".text": return bytearray(buf[ro:ro+rs]),va
        return None,0
    if u1 and outx:
        t1,v1=get_text(u1.read_bytes()); t2,v2=get_text(outx.read_bytes())
        if t1 and t2:
            diffs=[i for i,(a,b) in enumerate(zip(t1,t2)) if a!=b]
            P(f"  hollow vs twin_probe: len {len(t1)}/{len(t2)} ndiff={len(diffs)}")
            if diffs:
                i0=diffs[0]
                P(f"  first@{i0:#x}")
                for insn in md.disasm(bytes(t2[max(0,i0-16):i0+48]), v2+max(0,i0-16)):
                    P(f"    {insn.address:06x}: {insn.bytes.hex():20s} {insn.mnemonic} {insn.op_str}")
                    if insn.address > v2+i0+24: break

# I: Read p_ret_fwd.x source — what are we compiling?
P("\n=== I p_ret_fwd.x ===")
p=cave/"p_ret_fwd.x"
if p.exists():
    txt=p.read_text(encoding="utf-8",errors="replace")
    P(txt[:1500])

# J: Dig entry — where 1a8 first read; is there a write of 1a8 from 5th before overwrite?
P("\n=== J Isol entry homes + 1a8 first use ===")
disasm(base,secs,0x46a4db,80, stop=0x46a560)

# K: Capless — after writing 5th, does Capless have a local that should be 46's 6th?
# Search Capless for mov [rsp+0x28] near call_46 — none currently.
# Check Capless [4b0] reads — what is the semantic of 4b0?
P("\n=== K Capless [4b0] reads context ===")
for rva in [0x576739,0x5775ba,0x577b8b]:
    P(f"  -- @{rva:06x} --")
    disasm(base,secs,rva-0x10,48, stop=rva+20)

P(f"\nelapsed={time.time()-T0:.1f}s")
for p in cave.glob("_t1a09_*"):
    try: p.unlink()
    except: pass
P("cleaned")
