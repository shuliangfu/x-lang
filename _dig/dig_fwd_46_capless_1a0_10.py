#!/usr/bin/env python3
"""DIG fwd_46_capless_1a0 #10: Isol 1a0=[150] after set; 1a8 from Capless;
f483 USER GS site; twin vs Isol wider diff; final plant candidates.
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
    out=cave/f"_t1a10_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
        return tag_of(r.returncode), r.returncode
    except subprocess.TimeoutExpired:
        return "TIMEOUT", None
def save(pe,name):
    p=cave/name; p.write_bytes(bytes(pe)); return p
def gate(h,label,srcs=None):
    sha=hashlib.sha256(h.read_bytes()).hexdigest()[:12]
    P(f"  [{label}] sha={sha}")
    for src in (srcs or ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]):
        if not (cave/src).exists(): continue
        tag,sh,outx=run(h,src)
        rt,rc = (run_bin(outx) if tag=="OK" and outx else ("-",None))
        mark=""
        if sh=="e411d7260d78": mark=" HOLLOW"
        elif sh=="f4839df16ab1": mark=" F483"
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}{mark}")
        if tag=="OK" and src=="p_ret_fwd.x" and rt=="OK" and sh not in ("e411d7260d78","-"):
            P(f"  *** NON-HOLLOW RUN-OK USER={sh} ***")
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
def skip_call(pe,secs,rva):
    o=rva2off(pe,secs,rva); assert pe[o]==0xE8
    pe[o:o+5]=bytes.fromhex("31c0909090")

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
secs=pe_secs(base)
P(f"base sha={hashlib.sha256(base).hexdigest()[:12]}")

# A After [150] set @46a525: plant 1a0=[150] (zero-ext dword→qword) in clear @58d
# Encoding: mov eax,[150](6); mov [1a0],rax(7) = 13; +nops
P("\n=== A Isol 1a0=[150] / [164] / [134] ===")
def plant_mov_1a0_from_dword(src_disp, name):
    pe=bytearray(base)
    # mov eax,[rbp+src] = 8b 85 XX XX XX XX (6)
    # mov [rbp+0x1a0], rax = 48 89 85 a0 01 00 00 (7)  — zero-extends via eax load
    code=bytes.fromhex("8b85")+struct.pack("<I",src_disp)
    code+=bytes.fromhex("488985a0010000")
    assert len(code)==13
    code+=b"\x90"*3
    pe[rva2off(pe,secs,0x46a58d):rva2off(pe,secs,0x46a58d)+16]=bytes(code)
    gate(save(pe,f"host_1a0_{name}.exe"), name)

plant_mov_1a0_from_dword(0x150, "b150")
plant_mov_1a0_from_dword(0x164, "b164")
plant_mov_1a0_from_dword(0x134, "b134")  # may be 0 early
plant_mov_1a0_from_dword(0x190, "b190d")  # r8d home

# B Capless: 5th=dword[4b0], 6th=dword[4b0] (same), 7th=0 — AND Isol 1a0 stays from 6th
# Already tried similar. Try Capless 7th=[4b0] too with 6th=0
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
    pe[rva2off(pe,secs,cave_rva):rva2off(pe,secs,cave_rva)+len(tramp)]=bytes(tramp)
    pe[rva2off(pe,secs,0x57673f):rva2off(pe,secs,0x57673f)+12]=bytes([0xE9])+struct.pack("<i",cave_rva-(0x57673f+5))+bytes([0x90]*7)
    return pe

P("\n=== B Capless 6th=idx 7th variants + body 1a0=[150] ===")
# Capless: 5th=[4b0], 6th=0, 7th=0
tramp=make_tramp(["894c2420","c744242800000000","c744243000000000","4889c1"])
pe=apply_cap(tramp,"tmp")
# also body 1a0=[150] AFTER homes — overwrites Capless 6th with [150]
code=bytes.fromhex("8b85")+struct.pack("<I",0x150)+bytes.fromhex("488985a0010000")+b"\x90"*3
pe[rva2off(pe,secs,0x46a58d):rva2off(pe,secs,0x46a58d)+16]=bytes(code)
gate(save(pe,"host_1a0_cap0_b150.exe"),"cap0_b150")

# C f483 USER — find GS: run under debugger? Or check security_cookie / call mk args
P("\n=== C f483 USER full main+mk disasm ===")
tag,sh,outx=run(cave/"host_1a0_tr_460_4b0_0.exe","p_ret_fwd.x")
P(f"  compile={tag} USER={sh}")
if outx:
    rt,rc=run_bin(outx); P(f"  run={rt} rc={rc}")
    buf=outx.read_bytes()
    e=struct.unpack_from("<I",buf,0x3C)[0]
    nsec=struct.unpack_from("<H",buf,e+6)[0]
    opt=struct.unpack_from("<H",buf,e+20)[0]
    sec=e+24+opt
    for i in range(nsec):
        o=sec+i*40; n=bytes(buf[o:o+8]).split(b"\0")[0]
        vs,va,rs,ro=struct.unpack_from("<IIII",buf,o+8)
        if n==b".text":
            t=bytearray(buf[ro:ro+rs]); tv=va; break
    # disasm 1490..1600
    for insn in md.disasm(bytes(t[0x1490-tv:0x1620-tv]), 0x1490):
        P(f"  {insn.address:06x}: {insn.bytes.hex():20s} {insn.mnemonic} {insn.op_str}")

# D hollow USER same range for compare
P("\n=== D hollow USER 1490..1600 ===")
tag,sh,outx=run(cave/"host_skip_1a0_calls.exe","p_ret_fwd.x")
if outx:
    buf=outx.read_bytes()
    e=struct.unpack_from("<I",buf,0x3C)[0]
    nsec=struct.unpack_from("<H",buf,e+6)[0]
    opt=struct.unpack_from("<H",buf,e+20)[0]
    sec=e+24+opt
    for i in range(nsec):
        o=sec+i*40; n=bytes(buf[o:o+8]).split(b"\0")[0]
        vs,va,rs,ro=struct.unpack_from("<IIII",buf,o+8)
        if n==b".text":
            t=bytearray(buf[ro:ro+rs]); tv=va; break
    for insn in md.disasm(bytes(t[0x1490-tv:0x1620-tv]), 0x1490):
        P(f"  {insn.address:06x}: {insn.bytes.hex():20s} {insn.mnemonic} {insn.op_str}")

# E twin vs Isol: diffs in Capless + call-mk region
P("\n=== E twin vs Isol wider .text diffs (sample) ===")
twin=bytearray((cave/"xlang_isol1060_calt_twin.exe").read_bytes())
tsc=pe_secs(twin)
regions=[(0x46a4db,0x46af5d,"body46"),(0x57656c,0x576800,"capless"),
         (0x57b000,0x57c000,"cmk"),(0x574000,0x575000,"near574")]
for lo,hi,lab in regions:
    nd=0; first=[]
    for rva in range(lo,hi):
        try:
            bi=base[rva2off(base,secs,rva)]; ti=twin[rva2off(twin,tsc,rva)]
        except Exception:
            continue
        if bi!=ti:
            nd+=1
            if len(first)<8: first.append(f"{rva:06x}:{bi:02x}/{ti:02x}")
    P(f"  {lab}: ndiff={nd} first={first}")

# F Try: Capless write 6th=dword 3 (type path?), 7th=0, 5th keep
P("\n=== F Capless 6th=small indices ===")
for idx,name in [(0,"idx0b"),(2,"idx2"),(3,"idx3"),(10,"idx10"),(0x27,"idx27")]:
    tramp=make_tramp([
        "894c2420",  # 5th=4b0
        "c7442428"+struct.pack("<I",idx).hex(),  # 6th=idx
        "4889c1",
    ])
    gate(save(apply_cap(tramp,name),f"host_1a0_{name}.exe"), name)

# G Capless 6th=[4a0] (r8d home = Capless 3rd arg) as dword
tramp=make_tramp([
    "894c2420",
    "4489842428000000",  # mov [rsp+0x28], r8d  — check encoding
    "4889c1",
])
# Correct encoding mov dword [rsp+0x28], r8d = 44 89 44 24 28
tramp=make_tramp(["894c2420","4489442428","4889c1"])
gate(save(apply_cap(tramp,"r8d6"),"r8d6"))

# H: plant at @46a525 right after mov [150],eax — also mov [1a0],eax
# 46a525: 898550010000 (6). Next is 46a52b. Check what's there.
P("\n=== H after [150] store ===")
disasm(base,secs,0x46a520,40, stop=0x46a560)
# Can't easily insert. Use 58d clear which is after 525 chronologically? 
# 58d is AFTER 525 in code order yes (525 < 58d). Good — b150 plant is valid.

P(f"\nelapsed={time.time()-T0:.1f}s")
for p in cave.glob("_t1a10_*"):
    try: p.unlink()
    except: pass
P("cleaned")
