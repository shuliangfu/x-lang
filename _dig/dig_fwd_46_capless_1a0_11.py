#!/usr/bin/env python3
"""DIG fwd_46_capless_1a0 #11: 4538f4 5th role; Capless 6th=sret-ish;
confirm f483 fw bug; try Isol fill 1a0 from Capless r9/[4a8] via home.
Budget<=70s."""
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
    out=cave/f"_t1a11_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
        if tag=="OK" and src=="p_ret_fwd.x" and rt=="OK" and sh not in ("e411d7260d78","-"):
            P(f"  *** NON-HOLLOW RUN-OK USER={sh} ***")
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
    candidates.sort(); return candidates[0]

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
secs=pe_secs(base)
P(f"base sha={hashlib.sha256(base).hexdigest()[:12]}")

# A 4538f4 prol — how 5th used
P("\n=== A 4538f4 ===")
disasm(base,secs,0x4538f4,100, stop=0x453980)
# scan 5th
fn=bytes(base[rva2off(base,secs,0x4538f4):rva2off(base,secs,0x4538f4)+0x120])
for i in range(len(fn)-3):
    if fn[i:i+4] in (b'\x48\x8b\x45\x30',b'\x48\x8b\x4d\x30',b'\x48\x8b\x55\x30') or fn[i:i+3] in (b'\x8b\x45\x30',b'\x8b\x4d\x30'):
        P(f"  5th @{0x4538f4+i:06x}: {fn[i:i+8].hex()}")

# B 45411e / 4694c1 briefly
P("\n=== B 45411e ===")
disasm(base,secs,0x45411e,40, stop=0x454160)
P("\n=== B2 4694c1 ===")
disasm(base,secs,0x4694c1,40, stop=0x469500)

# C Confirm: hollow USER also has mk+fw? Check call target in main
P("\n=== C hollow main call target ===")
tag,sh,outx=run(cave/"host_skip_1a0_calls.exe","p_ret_fwd.x")
P(f"  hollow USER={sh}")
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
if outx:
    t,v=get_text(outx.read_bytes())
    # find all E8 in 1548..1619 and show targets
    for off in range(0x1548-v, 0x1620-v):
        if t[off]==0xE8:
            rel=struct.unpack_from("<i",t,off+1)[0]
            at=v+off; tgt=at+5+rel
            P(f"  call @{at:06x} → {tgt:06x}")

# D f483 calls
P("\n=== D f483 calls in main/fw ===")
tag,sh,outx=run(cave/"host_1a0_tr_460_4b0_0.exe","p_ret_fwd.x")
if outx:
    t,v=get_text(outx.read_bytes())
    for off in range(0x1490-v, 0x1620-v):
        if t[off]==0xE8:
            rel=struct.unpack_from("<i",t,off+1)[0]
            at=v+off; tgt=at+5+rel
            P(f"  call @{at:06x} → {tgt:06x}")

# E lit USER for reference
P("\n=== E lit USER calls (cmk0) ===")
tag,sh,outx=run(cave/"host_cmk0_irdx_sub20.exe","p_ret_lit.x")
P(f"  lit USER={sh}")
if outx:
    t,v=get_text(outx.read_bytes())
    # show .text size and any call
    P(f"  .text len={len(t)}")
    for off in range(0, min(len(t)-5, 0x800)):
        if t[off]==0xE8:
            rel=struct.unpack_from("<i",t,off+1)[0]
            at=v+off; tgt=at+5+rel
            if v <= tgt < v+len(t):
                P(f"  call @{at:06x} → {tgt:06x}")

# F Final plant: Capless 5th=qword[4a8](r9), 6th=dword[4b0], 7th=0
# (r9 often carries type/info in these ABIs)
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
    gate(save(pe,f"host_1a0_{name}.exe"), name)

P("\n=== F last Capless plants ===")
# 5th=[4a8] qword, 6th=[4b0] dword, 7th=0
apply_cap(make_tramp([
    "4c894c2420",      # [rsp+0x20]=r9
    "894c2428",        # [rsp+0x28]=ecx=[4b0]
    "c744243000000000",
    "4889c1",
]), "4a8_4b0_0")

# Capless only add 6th=[4a0] (r8d) + 7th=0, keep 5th
apply_cap(make_tramp([
    "894c2420",
    "4489442428",      # 6th=r8d
    "c744243000000000",
    "4889c1",
]), "4b0_r8_0")

# Isol: at entry AFTER r9 home, copy [198] (r9d) zero-ext to [1a0] — already tried b198 AV
# because [198] at 58d time is r9d but we used qword read from wrong timing?
# b198 was mov rax,[198]; mov [1a0],rax — [198] is dword home, high garbage → AV
# Use dword load:
pe=bytearray(base)
code=bytes.fromhex("8b8598010000488985a0010000909090")  # mov eax,[198]; mov [1a0],rax; nops
pe[rva2off(pe,secs,0x46a58d):rva2off(pe,secs,0x46a58d)+16]=bytes(code)
gate(save(pe,"host_1a0_b198d.exe"),"b198d")

# G Write dig summary note material
P("\n=== G SUMMARY ===")
P("Capless miss 6th/7th confirmed; many supply plants → USER f483 run GS")
P("f483 fw@14f8: rcx=x+1 (value) not sret dest; rdx=imm 0xa — call mk broken")
P("hollow skips 967: main calls mk(10) direct with correct sret — run OK but hollow-shaped")
P("1a0 value often does not change USER sha (same f483) ⇒ 967 emit path broken independent of many 1a0")
P("next: fwd_46_967_sret OR fwd_fw_cmk_sret — fix SoftCap fw call-mk sret rcx")

P(f"\nelapsed={time.time()-T0:.1f}s")
for p in cave.glob("_t1a11_*"):
    try: p.unlink()
    except: pass
P("cleaned")
