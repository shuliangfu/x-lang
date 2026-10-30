#!/usr/bin/env python3
"""DIG fwd_46_capless_1a0 #7: gate twin/PROD SoftCap; dig why 967 emits;
body path to 967; 1a8 role at 99d; force 469aa4 fail-early (skip emit).
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
    out=cave/f"_t1a07_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    try:
        r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout,cwd=str(cave))
        b=out.read_bytes() if out.exists() else b""
        sh=hashlib.sha256(b).hexdigest()[:12] if b else "-"
        return tag_of(r.returncode), sh, out if b else None, r.returncode
    except subprocess.TimeoutExpired:
        return "TIMEOUT","-",None,None
def run_bin(exe,timeout=3):
    try:
        r=subprocess.run([str(exe)],capture_output=True,timeout=timeout)
        return tag_of(r.returncode)
    except subprocess.TimeoutExpired:
        return "TIMEOUT"
def save(pe,name):
    p=cave/name; p.write_bytes(bytes(pe)); return p
def gate(h,label,srcs=None):
    if isinstance(h, (str,Path)): h=Path(h)
    if not h.exists(): P(f"  [{label}] MISSING"); return
    sha=hashlib.sha256(h.read_bytes()).hexdigest()[:12]
    P(f"  [{label}] sha={sha} name={h.name}")
    for src in (srcs or ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]):
        if not (cave/src).exists(): continue
        tag,sh,outx,_=run(h,src)
        rt=run_bin(outx) if tag=="OK" and outx else "-"
        mark=""
        if sh=="e411d7260d78": mark=" HOLLOW"
        elif sh=="f4839df16ab1": mark=" F483"
        elif sh=="dbaab1c7ce70": mark=" LIVE?"
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}{mark}")
        if tag=="OK" and src=="p_ret_fwd.x" and rt=="OK" and sh not in ("e411d7260d78","-"):
            P(f"  *** NON-HOLLOW RUN-OK USER={sh} ***")

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
secs=pe_secs(base)
P(f"base sha={hashlib.sha256(base).hexdigest()[:12]}")

# A Gate twin / PROD / softcap isol / skip baseline
P("\n=== A gate reference hosts ===")
for name,lab in [
    ("host_cmk0_irdx_sub20.exe","cmk0"),
    ("host_skip_1a0_calls.exe","skip1a0"),
    ("host_46_hollow_only.exe","hollow"),
    ("xlang_isol1060_calt_twin.exe","twin"),
    ("xlang_isol1060_twin_probe.exe","twin_probe"),
    ("xlang_softcap_1060_isol.exe","sc_isol"),
    ("lab_SoftCap_76795.exe","PROD"),
]:
    gate(cave/name, lab)

# B Path conditions to reach 967 — disasm 46a774..967 focusing branches
P("\n=== B path 46a774 → 967 ===")
def disasm(pe,secs,rva,n=96,stop=None):
    o=rva2off(pe,secs,rva)
    for insn in md.disasm(bytes(pe[o:o+n]),rva):
        P(f"  {insn.address:06x}: {insn.bytes.hex():24s} {insn.mnemonic} {insn.op_str}")
        if stop is not None and insn.address>=stop: break
disasm(base,secs,0x46a770,200, stop=0x46a900)

# C 469aa4: force fail before 4698c0 by zeroing rdx check inputs
# At call@967, rdx=[188]. If we zero [188] before call, 469aa4 returns 0 early — no emit.
# Plant at 46a58d: can't zero 188 if it's needed elsewhere.
# Instead patch call@967 site: mov qword [rsp+0x20],0 (null 5th) AND keep rdx — still may emit.
# Better: skip only the inner call 4698c0 by patching 469aa4's call — too invasive.
# Force 469aa4 early return: at 46a94a replace mov rdx,[188] with xor edx,edx (3B vs 7B)
P("\n=== C force 469aa4 fail (rdx=0 at 967) ===")
pe=bytearray(base)
# 46a94a: 488b9588010000 (7) → 31d2 9090909090 (xor edx; nop*5)
o=rva2off(pe,secs,0x46a94a)
assert bytes(pe[o:o+7])==bytes.fromhex("488b9588010000")
pe[o:o+7]=bytes.fromhex("31d29090909090")
gate(save(pe,"host_1a0_rdx0_967.exe"),"rdx0_967")

# D force r8d=[150]=0 so jle fail in 469aa4
pe=bytearray(base)
# 46a943: 448b8550010000 (7) → 4531c0 90909090 (xor r8d,r8d; nops)
o=rva2off(pe,secs,0x46a943)
assert bytes(pe[o:o+7])==bytes.fromhex("448b8550010000"), pe[o:o+7].hex()
pe[o:o+7]=bytes.fromhex("4531c090909090")
gate(save(pe,"host_1a0_r8z_967.exe"),"r8z_967")

# E: What writes [188]? Search broader
P("\n=== E [188] setup in body ===")
body_off=rva2off(base,secs,0x46a4db)
body=bytes(base[body_off:rva2off(base,secs,0x46af5d)])
for i in range(len(body)-3):
    if body[i:i+4]==bytes.fromhex("88010000"):
        # show preceding opcode
        start=max(0,i-4)
        P(f"  @{0x46a4db+start:06x}: {body[start:i+4].hex()}")

# F twin Capless vs Isol Capless byte-diff around call and [4b0] source
P("\n=== F twin vs Isol Capless call site bytes ===")
twin=bytearray((cave/"xlang_isol1060_calt_twin.exe").read_bytes())
tsc=pe_secs(twin)
for rva in range(0x57671d, 0x576750):
    bi=base[rva2off(base,secs,rva)]
    ti=twin[rva2off(twin,tsc,rva)]
    if bi!=ti:
        P(f"  DIFF @{rva:06x}: isol={bi:02x} twin={ti:02x}")
# Also compare Isol body 46a4db..46a9c0
nd=0
for rva in range(0x46a4db, 0x46a9c0):
    if base[rva2off(base,secs,rva)]!=twin[rva2off(twin,tsc,rva)]:
        nd+=1
        if nd<=20:
            P(f"  body DIFF @{rva:06x}: isol={base[rva2off(base,secs,rva)]:02x} twin={twin[rva2off(twin,tsc,rva)]:02x}")
P(f"  body diffs in 46a4db..46a9c0: {nd}")

# G Compare Isol body vs PROD around 967
prod=bytearray((cave/"lab_SoftCap_76795.exe").read_bytes())
psc=pe_secs(prod)
nd=0
for rva in range(0x46a4db, 0x46a9c0):
    try:
        if base[rva2off(base,secs,rva)]!=prod[rva2off(prod,psc,rva)]:
            nd+=1
            if nd<=15:
                P(f"  PROD body DIFF @{rva:06x}")
    except Exception:
        pass
P(f"  PROD body diffs: {nd}")

# H Dig Capless who WRITES [4b0] before Capless is called — i.e. Capless callers' +0x28
P("\n=== H Capless callers: write +0x28 before call? ===")
for crva in [0x12377c,0x126cda,0x1d9a89,0x1d9c8b,0x1d9d0e,0x1da455,0x1dd9b3,0x270317]:
    P(f"  -- caller @{crva:06x} --")
    disasm(base,secs,crva-0x30,60, stop=crva+6)

# I: After call@967, eax tested; if nonzero → return -1. f483 means 967 returned 0 (success).
# So 469aa4 "succeeds" and emits. We need it to emit CORRECTLY.
# Look at 4698c0's use of 5th [rbp+0x30]
P("\n=== I 4698c0 5th use continued ===")
disasm(base,secs,0x469925,160, stop=0x469a50)

P(f"\nelapsed={time.time()-T0:.1f}s")
for p in cave.glob("_t1a07_*"):
    try: p.unlink()
    except: pass
P("cleaned")
