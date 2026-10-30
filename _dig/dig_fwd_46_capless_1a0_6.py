#!/usr/bin/env python3
"""DIG fwd_46_capless_1a0 #6: 4698c0; LIVE/twin Capless→46; Isol 1a0=[188]/[180]/lea.
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
    out=cave/f"_t1a06_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}{mark}")
        # if new non-hollow OK USER, keep
        if tag=="OK" and src=="p_ret_fwd.x" and sh not in ("e411d7260d78","f4839df16ab1","-") and rt=="OK":
            P(f"  *** CANDIDATE semantic USER={sh} ***")
def disasm(pe,secs,rva,n=96,stop=None):
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
    candidates.sort(); return candidates[0]

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
secs=pe_secs(base)
P(f"base sha={hashlib.sha256(base).hexdigest()[:12]}")

# A 4698c0 prol + 5th use
P("\n=== A 4698c0 ===")
disasm(base,secs,0x4698c0,120, stop=0x4699a0)

# B Where body sets [188] and [150]
P("\n=== B writers of [rbp+0x188] / [0x150] in Isol body ===")
body=bytes(base[rva2off(base,secs,0x46a4db):rva2off(base,secs,0x46af5d)])
base_r=0x46a4db
# look for 8985 88010000 / 488985 88010000 / c785 50010000
for i in range(len(body)-6):
    if body[i:i+6]==bytes.fromhex("898588010000") or body[i:i+7]==bytes.fromhex("48898588010000"):
        P(f"  write [188] @{base_r+i:06x}: {body[i:i+10].hex()}")
    if body[i:i+6]==bytes.fromhex("898550010000") or body[i:i+7]==bytes.fromhex("48898550010000") or body[i:i+10]==bytes.fromhex("c7855001000000000000"):
        P(f"  write [150] @{base_r+i:06x}: {body[i:i+10].hex()}")
    if body[i:i+6]==bytes.fromhex("898564010000") or body[i:i+10]==bytes.fromhex("c7856401000000000000"):
        P(f"  write [164] @{base_r+i:06x}: {body[i:i+10].hex()}")

# C LIVE SoftCap / twin Capless call_46 site
P("\n=== C twin/softcap Capless→46 ===")
for name in ["xlang_isol1060_calt_twin.exe","xlang_softcap_1060_isol.exe","lab_SoftCap_76795.exe","xlang_isol1060_twin_probe.exe"]:
    p=cave/name
    if not p.exists(): P(f"  missing {name}"); continue
    pe=bytearray(p.read_bytes()); sc=pe_secs(pe)
    sha=hashlib.sha256(pe).hexdigest()[:12]
    P(f"  {name} sha={sha}")
    # find call to 46a4db or E8 rel
    if b".text" not in sc: continue
    va,vs,ro,rs=sc[b".text"]; blob=bytes(pe[ro:ro+rs])
    hits=[]
    for i in range(len(blob)-5):
        if blob[i]==0xE8:
            rel=struct.unpack_from("<i",blob,i+1)[0]
            tgt=va+i+5+rel
            if tgt==0x46a4db:
                hits.append(va+i)
    P(f"    calls to 46a4db: {[hex(h) for h in hits[:12]]} n={len(hits)}")
    # Capless range ~0x576000 if same layout
    for h in hits:
        if 0x570000 <= h <= 0x580000 or 0x550000 <= h <= 0x590000:
            P(f"    -- Capless-ish call @{h:06x} --")
            disasm(pe,sc,h-0x40,80, stop=h+8)

# D Isol plants: 1a0 = [188] (rdx-object for 469aa4)
P("\n=== D Isol 1a0 from body locals ===")
def plant_1a0_from(src_disp, name):
    # at 46a58d (16B clear): mov rax,[rbp+src]; mov [rbp+0x1a0],rax
    pe=bytearray(base)
    code=bytearray()
    # mov rax, [rbp+src_disp]
    code += bytes.fromhex("488b85")+struct.pack("<I", src_disp)
    # mov [rbp+0x1a0], rax
    code += bytes.fromhex("488985a0010000")
    assert len(code)==14
    code += b"\x90\x90"
    pe[rva2off(pe,secs,0x46a58d):rva2off(pe,secs,0x46a58d)+16]=bytes(code)
    gate(save(pe,f"host_1a0_{name}.exe"), name)

plant_1a0_from(0x188, "b188")   # rdx-object
plant_1a0_from(0x180, "b180b")  # rcx (redo)
plant_1a0_from(0x190, "b190")   # used as edx at 99d
plant_1a0_from(0x198, "b198")   # r9 home (dword zero-ext)

# 1a0 = lea rbp+X — pointer into frame (sometimes used as out-param)
def plant_1a0_lea(disp, name):
    pe=bytearray(base)
    # lea rax,[rbp+disp] (7 or 8); mov [1a0],rax (7)
    # lea rax,[rbp+disp]: 48 8d 85 XX XX XX XX (7)
    code=bytes.fromhex("488d85")+struct.pack("<I", disp & 0xFFFFFFFF)
    code+=bytes.fromhex("488985a0010000")  # 7 → total 14
    code+=b"\x90\x90"
    pe[rva2off(pe,secs,0x46a58d):rva2off(pe,secs,0x46a58d)+16]=bytes(code)
    gate(save(pe,f"host_1a0_{name}.exe"), name)

plant_1a0_lea(0x1a0, "lea1a0")  # pointless
plant_1a0_lea(0x168, "lea168")
plant_1a0_lea(0x150, "lea150")
plant_1a0_lea(0x128, "lea128")

# E Capless: 5th=qword from Capless [460] (derived), 6th=dword 0 (index 0)
# Real callers: 5th=ptr, 6th=index. Capless currently: 5th=dword[4b0].
# Mirror: 5th=[460] qword, 6th=0 dword
_, cave_rva, cave_sz = find_cave(base,secs,need=64)
def make_tramp(ops):
    tramp=bytearray()
    for h in ops: tramp+=bytes.fromhex(h)
    call_at=cave_rva+len(tramp)
    tramp+=bytes([0xE8])+struct.pack("<i",0x46a4db-(call_at+5))
    jmp_at=cave_rva+len(tramp)
    tramp+=bytes([0xE9])+struct.pack("<i",0x57674b-(jmp_at+5))
    return tramp
def apply_cap(tramp, name):
    pe=bytearray(base)
    P(f"  {name} len={len(tramp)}")
    if len(tramp)>cave_sz: return
    pe[rva2off(pe,secs,cave_rva):rva2off(pe,secs,cave_rva)+len(tramp)]=bytes(tramp)
    pe[rva2off(pe,secs,0x57673f):rva2off(pe,secs,0x57673f)+12]=bytes([0xE9])+struct.pack("<i",cave_rva-(0x57673f+5))+bytes([0x90]*7)
    gate(save(pe,f"host_1a0_{name}.exe"), name)

P("\n=== E Capless 5th=ptr 6th=index0 ===")
# 5th=[460], 6th=0
apply_cap(make_tramp([
    "488b8d60040000",  # mov rcx,[460]
    "48894c2420",      # 5th=rcx
    "c744242800000000",# 6th=0
    "488b8590040000",  # rax=[490]
    "4889c1",
]), "tr_460_idx0")

# 5th=[490], 6th=0
apply_cap(make_tramp([
    "4889442420",      # 5th=rax=[490]
    "c744242800000000",# 6th=0
    "4889c1",
]), "tr_490_idx0")

# 5th=[498], 6th=0
apply_cap(make_tramp([
    "4889542420",
    "c744242800000000",
    "4889c1",
]), "tr_498_idx0")

# 5th=[4a8]=r9, 6th=0
apply_cap(make_tramp([
    "4c894c2420",      # mov [rsp+0x20], r9
    "c744242800000000",
    "4889c1",
]), "tr_4a8_idx0")

# 5th=[460], 6th=[4b0] (already similar to tr_460_4b0_no7 → f483)
# 5th=[460], 6th=1
apply_cap(make_tramp([
    "488b8d60040000",
    "48894c2420",
    "c744242801000000",
    "488b8590040000",
    "4889c1",
]), "tr_460_idx1")

# F: Also check Capless [4b0] writers INSIDE Capless function after prol
P("\n=== F Capless body writes to [4b0]? ===")
cap_start=0x57656c; cap_end=0x578300
cap=bytes(base[rva2off(base,secs,cap_start):rva2off(base,secs,cap_end)])
for i in range(len(cap)-6):
    if cap[i:i+6]==bytes.fromhex("898db0040000") or cap[i:i+7]==bytes.fromhex("48898db0040000") or cap[i:i+7]==bytes.fromhex("488985b0040000") or cap[i:i+6]==bytes.fromhex("8985b0040000") or cap[i:i+10]==bytes.fromhex("c785b004000000000000"):
        P(f"  Capless write [4b0] @{cap_start+i:06x}: {cap[i:i+12].hex()}")
# also dword via other regs
for i in range(len(cap)-7):
    if b"\xb0\x04\x00\x00" in cap[i:i+7] and cap[i] in (0x89,0x48,0x44,0xC7):
        # filter
        if cap[i+2:i+6]==bytes.fromhex("b0040000") or cap[i+3:i+7]==bytes.fromhex("b0040000"):
            P(f"  near [4b0] @{cap_start+i:06x}: {cap[i:i+12].hex()}")

# G Compare USER f483 helper @14f8 vs hollow @1490 — what is each?
P("\n=== G USER helpers @1490 vs @14f8 ===")
tag1,sh1,u1=run(cave/"host_skip_1a0_calls.exe","p_ret_fwd.x")
tag2,sh2,u2=run(cave/"host_1a0_tr_460_4b0_0.exe","p_ret_fwd.x")
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
if u1 and u2:
    t1,v1=get_text(u1.read_bytes()); t2,v2=get_text(u2.read_bytes())
    # hollow calls 0x1490; f483 calls 0x14f8. Disasm both targets + the gap
    for lab,t,tgt in [("H@1490",t1,0x1490),("F@14f8",t2,0x14f8),("F@1490",t2,0x1490)]:
        off=tgt-v1
        P(f"  -- {lab} --")
        if 0<=off<len(t)-32:
            for insn in md.disasm(bytes(t[off:off+48]), tgt):
                P(f"    {insn.address:06x}: {insn.bytes.hex():20s} {insn.mnemonic} {insn.op_str}")
                if insn.address>=tgt+32: break
    # size of inserted block = 0x68. Show f483[0x1490:0x14f8]
    P("  -- F inserted [1490..14f8) --")
    for insn in md.disasm(bytes(t2[0x1490-v2:0x14f8-v2]), 0x1490):
        P(f"    {insn.address:06x}: {insn.bytes.hex():20s} {insn.mnemonic} {insn.op_str}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for p in cave.glob("_t1a06_*"):
    try: p.unlink()
    except: pass
P("cleaned")
