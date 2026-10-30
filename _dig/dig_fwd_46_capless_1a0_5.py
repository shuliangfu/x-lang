#!/usr/bin/env python3
"""DIG fwd_46_capless_1a0 #5: call@967 full args; USER .text+0x568 context;
LIVE SoftCap Capless→46; Isol fill 1a0 with 469aa4-shaped 5th.
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
    out=cave/f"_t1a05_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
    for src in (srcs or ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]):
        if not (cave/src).exists(): continue
        tag,sh,outx=run(h,src)
        rt=run_bin(outx) if tag=="OK" and outx else "-"
        mark=""
        if sh=="e411d7260d78": mark=" HOLLOW"
        elif sh=="f4839df16ab1": mark=" F483"
        elif sh=="5c6778769c3c": mark=" LIT"
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}{mark}")
def disasm(pe,secs,rva,n=96,stop=None):
    o=rva2off(pe,secs,rva)
    for insn in md.disasm(bytes(pe[o:o+n]),rva):
        P(f"  {insn.address:06x}: {insn.bytes.hex():24s} {insn.mnemonic} {insn.op_str}")
        if stop is not None and insn.address>=stop: break

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
secs=pe_secs(base)
P(f"base sha={hashlib.sha256(base).hexdigest()[:12]}")

# A Full call@967 setup
P("\n=== A call@46a967 full arg setup ===")
disasm(base,secs,0x46a900,120, stop=0x46a9b0)

# B call@99d full
P("\n=== B call@46a99d full ===")
disasm(base,secs,0x46a970,80, stop=0x46a9c0)

# C 469aa4: does it USE its 5th ([rbp+0x30]/)?
P("\n=== C 469aa4 rest — 5th use? ===")
disasm(base,secs,0x469af8,100, stop=0x469b80)
# scan for [rbp+0x30] / [rbp+48]
blob=bytes(base[rva2off(base,secs,0x469aa4):rva2off(base,secs,0x469aa4)+0x100])
for i in range(len(blob)-3):
    # 8b 45 30 / 48 8b 45 30 / 8b 4d 30 etc
    if blob[i:i+3] in (b'\x8b\x45\x30',b'\x8b\x4d\x30',b'\x8b\x55\x30') or blob[i:i+4] in (b'\x48\x8b\x45\x30',b'\x48\x8b\x4d\x30',b'\x4c\x8b\x45\x30'):
        P(f"  hit 5th-read @469aa4+{i:#x}: {blob[i:i+8].hex()}")

# D USER .text+0x568 context — hollow vs f483
P("\n=== D USER emit context around .text+0x568 ===")
tag1,sh1,u1=run(cave/"host_skip_1a0_calls.exe","p_ret_fwd.x")
tag2,sh2,u2=run(cave/"host_1a0_tr_460_4b0_0.exe","p_ret_fwd.x")
P(f"  hollow USER={sh1} f483 USER={sh2}")
def get_text(buf):
    e=struct.unpack_from("<I",buf,0x3C)[0]
    nsec=struct.unpack_from("<H",buf,e+6)[0]
    opt=struct.unpack_from("<H",buf,e+20)[0]
    sec=e+24+opt
    for i in range(nsec):
        o=sec+i*40; n=bytes(buf[o:o+8]).split(b"\0")[0]
        vs,va,rs,ro=struct.unpack_from("<IIII",buf,o+8)
        if n==b".text": return bytearray(buf[ro:ro+rs]),va,ro
    return None,0,0
if u1 and u2:
    t1,v1,_=get_text(u1.read_bytes())
    t2,v2,_=get_text(u2.read_bytes())
    P(f"  byte@568: hollow={t1[0x568]:02x} f483={t2[0x568]:02x}")
    # disasm from 0x540..0x5a0 both
    for lab,t in [("HOLLOW",t1),("F483",t2)]:
        P(f"  -- {lab} @rva {v1+0x540:#x} --")
        for insn in md.disasm(bytes(t[0x540:0x5a0]), v1+0x540):
            mark=" <<<" if insn.address==v1+0x568 else ""
            P(f"    {insn.address:06x}: {insn.bytes.hex():20s} {insn.mnemonic} {insn.op_str}{mark}")

# Also check LIVE SoftCap host if present
P("\n=== E LIVE SoftCap hosts in cave ===")
for p in sorted(cave.glob("host*.exe"))[:40]:
    pass
lives=[]
for p in cave.glob("*.exe"):
    n=p.name.lower()
    if "live" in n or "prod" in n or "softcap" in n or "7a2cf" in n:
        lives.append(p)
for p in cave.glob("host_*"):
    if "live" in p.name.lower() or "twin" in p.name.lower() or "mega" in p.name.lower():
        lives.append(p)
P(f"  candidates: {[p.name for p in lives[:20]]}")
# Also list any SoftCap Twin PE
for pat in ["*Twin*","*twin*","*LIVE*","*live*","*softcap*","*SoftCap*","host_cmk*","host_46*"]:
    xs=list(cave.glob(pat))
    if xs: P(f"  {pat}: {[x.name for x in xs[:8]]}")

# F Capless itself: what does it put in rcx/rdx/r8/r9 at call_46?
P("\n=== F Capless call_46 full setup @576700..746 ===")
disasm(base,secs,0x5766e0,120, stop=0x576760)

# G What do real 46 callers pass as rdx/r8/r9 + 5th/6th?
P("\n=== G real caller @46bac7 full ===")
disasm(base,secs,0x46ba90,80, stop=0x46bb00)
P("\n=== G2 real caller @46bda6 full ===")
disasm(base,secs,0x46bd70,80, stop=0x46be00)

# H: 469aa4 5th arg — Capless path passes [1a0] as 5th. Does 469aa4 even READ it?
# From C scan. Also check home: with push rbp; mov rbp,rsp; sub rsp,0x40
# 5th at call_rsp+0x20 = [rbp+0x28]? Wait:
# push rbp: rsp-=8; mov rbp,rsp → rbp=call_rsp-8
# 5th = call_rsp+0x20 = [rbp+0x28] — BUT they home r9d at [rbp+0x28]!
# So 5th stack arg is OVERWRITTEN by r9 home — 469aa4 NEVER sees the 5th we pass!
# Unless frame math differs: push rbp; mov rbp,rsp means [rbp+0x10]=rcx (first after ret),
# [rbp+0x18]=rdx, [rbp+0x20]=r8, [rbp+0x28]=r9, [rbp+0x30]=5th!
# They home r9d at [rbp+0x28] which is the REGISTER home (same as incoming r9),
# and 5th is at [rbp+0x30]!
P("\n=== H 469aa4 frame: 5th should be [rbp+0x30] ===")
# rescan for 0x30
blob=bytes(base[rva2off(base,secs,0x469aa4):rva2off(base,secs,0x469aa4)+0x120])
for i in range(len(blob)-2):
    if blob[i+1:i+3]==b'\x45\x30' or blob[i+1:i+3]==b'\x4d\x30' or blob[i+1:i+3]==b'\x55\x30' or blob[i+2:i+4]==b'\x45\x30':
        P(f"  @{0x469aa4+i:06x}+{i:#x}: {blob[i:i+8].hex()}")

# I: So call@967 passes 1a0 as 5th to 469aa4 — if unread, then 1a0 only matters for:
#    - mid call 2a6b93 (rcx=[1a0])
#    - call@99d (uses 1a0+1a8)
# Confirm: hollow after mid 2a6b93 path vs before
# Bisect: INT3 / hollow just before call@967 vs after mid@46a7cd
P("\n=== I bisect: skip mid 2a6b93 call; skip both mid+967 ===")
def skip_call(pe,secs,rva):
    o=rva2off(pe,secs,rva); assert pe[o]==0xE8
    pe[o:o+5]=bytes.fromhex("31c0909090")

# Find call@46a7d7 → 2a6b93
pe=bytearray(base); skip_call(pe,secs,0x46a7d7)
gate(save(pe,"host_1a0_skip_2a6.exe"),"skip_2a6")
pe=bytearray(base); skip_call(pe,secs,0x46a7d7); skip_call(pe,secs,0x46a967)
gate(save(pe,"host_1a0_skip_2a6_967.exe"),"skip_2a6_967")
pe=bytearray(base); skip_call(pe,secs,0x46a7d7); skip_call(pe,secs,0x46a967); skip_call(pe,secs,0x46a99d)
gate(save(pe,"host_1a0_skip_mid_both.exe"),"skip_mid_both")

# J: Under Capless 460 mirror, also zero 1a0 AFTER homes in body (so mid sees 0 → 2a6b93 returns -1 early)
# 2a6b93: if rcx==0 return -1. So 1a0=0 is safe for mid!
# Then call@967 passes 0 as 5th (unread?) — and rdx/r8 from body locals.
# What if Capless writes 6th=0 (dword), which is what zeros do — we know zeros → AV.
# Unless mid path with 1a0=0 is taken AND we skip 967... that's skip_1a0-ish.

# K: Look at what rdx/r8/r9 are at call@967 — they come from body state.
# If 469aa4 checks rdx (object)+r8d (index), the GS in USER may mean 469aa4 wrote bad emit.
# hollow skips 967 → never calls 469aa4 → different emit (1 byte: 0x24 vs 0x8c = -0xdc vs -0x74 relative?)
# The byte is likely a rel8 or part of a displacement in USER codegen.
# 0x24 vs 0x8c: if it's `and al, imm8` mis-decode — look at insn properly.
# From earlier: hollow=24ffffff → could be `and al,0xff` then garbage, OR end of previous insn.
P("\n=== J re-disasm USER from earlier aligned insn ===")
if u1 and u2:
    t1,_,_=get_text(u1.read_bytes()); t2,_,_=get_text(u2.read_bytes())
    for lab,t in [("HOLLOW",t1),("F483",t2)]:
        P(f"  -- {lab} wider window --")
        for insn in md.disasm(bytes(t[0x550:0x580]), 0x1550):
            mark=" <<<" if 0x1560 <= insn.address <= 0x1570 else ""
            P(f"    {insn.address:06x}: {insn.bytes.hex():24s} {insn.mnemonic} {insn.op_str}{mark}")

# L: Capless write 6th=0 qword + keep body; vs Isol force 1a0=0 early AND skip only 99d
P("\n=== L Isol 1a0=0 early + skip99d only ===")
pe=bytearray(base)
# at 46a58d: mov qword [rbp+0x1a0], 0  (8B) + nops
pe[rva2off(pe,secs,0x46a58d):rva2off(pe,secs,0x46a58d)+16]=bytes.fromhex("48c785a0010000000000009090909090")
skip_call(pe,secs,0x46a99d)
gate(save(pe,"host_1a0_z1a0_s99.exe"),"z1a0_s99")

# Isol 1a0=0, keep both calls
pe=bytearray(base)
pe[rva2off(pe,secs,0x46a58d):rva2off(pe,secs,0x46a58d)+16]=bytes.fromhex("48c785a0010000000000009090909090")
gate(save(pe,"host_1a0_z1a0_keep.exe"),"z1a0_keep")

# M: Does LIVE SoftCap exist as host_softcap_twin or similar?
for p in sorted(cave.glob("host*.exe")):
    if any(k in p.name for k in ("twin","Twin","LIVE","live","prod","Prod","soft","Soft","capless","Capless","cmk0")):
        P(f"  host: {p.name} sha={hashlib.sha256(p.read_bytes()).hexdigest()[:12]}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for p in cave.glob("_t1a05_*"):
    try: p.unlink()
    except: pass
P("cleaned")
