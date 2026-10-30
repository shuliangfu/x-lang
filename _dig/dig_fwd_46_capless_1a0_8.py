#!/usr/bin/env python3
"""DIG fwd_46_capless_1a0 #8: restore twin je/jne @82b/@90c; combo with Capless 1a0;
disasm around diffs. Budget<=85s."""
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
    out=cave/f"_t1a08_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
secs=pe_secs(base)
twin=bytearray((cave/"xlang_isol1060_calt_twin.exe").read_bytes())
tsc=pe_secs(twin)
P(f"base sha={hashlib.sha256(base).hexdigest()[:12]}")

# A context around both diffs
P("\n=== A Isol @46a82b ===")
disasm(base,secs,0x46a820,32, stop=0x46a840)
P("\n=== A twin @46a82b ===")
disasm(twin,tsc,0x46a820,32, stop=0x46a840)
P("\n=== A Isol @46a90c ===")
disasm(base,secs,0x46a8f0,48, stop=0x46a930)
P("\n=== A twin @46a90c ===")
disasm(twin,tsc,0x46a8f0,48, stop=0x46a930)

# Full body diff Isol vs twin in 46a4db..46af5d
P("\n=== A2 all body diffs Isol vs twin ===")
nd=0
for rva in range(0x46a4db, 0x46af5d):
    bi=base[rva2off(base,secs,rva)]; ti=twin[rva2off(twin,tsc,rva)]
    if bi!=ti:
        nd+=1
        P(f"  DIFF @{rva:06x}: isol={bi:02x} twin={ti:02x}")
P(f"  total={nd}")

# Also cmk0 vs PROD full body
prod=bytearray((cave/"lab_SoftCap_76795.exe").read_bytes())
psc=pe_secs(prod)
nd=0
for rva in range(0x46a4db, 0x46af5d):
    try:
        if base[rva2off(base,secs,rva)]!=prod[rva2off(prod,psc,rva)]:
            nd+=1
            if nd<=30: P(f"  PROD DIFF @{rva:06x}: isol={base[rva2off(base,secs,rva)]:02x} prod={prod[rva2off(prod,psc,rva)]:02x}")
    except Exception as e:
        P(f"  err @{rva:06x}: {e}"); break
P(f"  PROD total body diffs={nd}")

# B Restore twin conditionals only
P("\n=== B restore je@82b + jne@90c ===")
pe=bytearray(base)
assert pe[rva2off(pe,secs,0x46a82b)]==0xEB
assert pe[rva2off(pe,secs,0x46a90c)]==0xEB
pe[rva2off(pe,secs,0x46a82b)]=0x74  # je
pe[rva2off(pe,secs,0x46a90c)]=0x75  # jne
gate(save(pe,"host_1a0_rest_jejne.exe"),"rest_jejne")

# C restore only 82b
pe=bytearray(base); pe[rva2off(pe,secs,0x46a82b)]=0x74
gate(save(pe,"host_1a0_rest_82b.exe"),"rest_82b")

# D restore only 90c
pe=bytearray(base); pe[rva2off(pe,secs,0x46a90c)]=0x75
gate(save(pe,"host_1a0_rest_90c.exe"),"rest_90c")

# E restore jejne + Capless 6th=[4b0] dword (tr_460 style already known)
# Capless tramp: keep 5th, add 6th=[4b0] — wait 5th already is 4b0. Add 6th=0?
# Actually with restored CF, Capless miss may behave differently.
# Also: Capless write 5th=qword[rbp+0x30]-style — Capless doesn't have that.
# Try rest + Capless 5th dword keep + 6th dword 0
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
_, cave_rva, cave_sz = find_cave(base,secs,need=64)
def make_tramp(ops):
    tramp=bytearray()
    for h in ops: tramp+=bytes.fromhex(h)
    call_at=cave_rva+len(tramp)
    tramp+=bytes([0xE8])+struct.pack("<i",0x46a4db-(call_at+5))
    jmp_at=cave_rva+len(tramp)
    tramp+=bytes([0xE9])+struct.pack("<i",0x57674b-(jmp_at+5))
    return tramp
def apply_rest_cap(tramp, name, rest=True):
    pe=bytearray(base)
    if rest:
        pe[rva2off(pe,secs,0x46a82b)]=0x74
        pe[rva2off(pe,secs,0x46a90c)]=0x75
    pe[rva2off(pe,secs,cave_rva):rva2off(pe,secs,cave_rva)+len(tramp)]=bytes(tramp)
    pe[rva2off(pe,secs,0x57673f):rva2off(pe,secs,0x57673f)+12]=bytes([0xE9])+struct.pack("<i",cave_rva-(0x57673f+5))+bytes([0x90]*7)
    gate(save(pe,f"host_1a0_{name}.exe"), name)

P("\n=== E rest + Capless 6th variants ===")
# orig 5th + 6th=0
apply_rest_cap(make_tramp(["894c2420","c744242800000000","4889c1"]),"rest_4b0_idx0")
# orig 5th + 6th=4b0 (same value twice) — dword at +28
apply_rest_cap(make_tramp(["894c2420","894c2428","4889c1"]),"rest_4b0_4b0")
# 5th=qword[460], 6th=dword[4b0] (caller mirror)
apply_rest_cap(make_tramp([
    "488b8d60040000","48894c2420",
    "8b8db0040000","894c2428",
    "488b8590040000","4889c1",
]),"rest_460_4b0")
# 5th=qword[490], 6th=0
apply_rest_cap(make_tramp(["4889442420","c744242800000000","4889c1"]),"rest_490_idx0")

# F rest + Isol body 1a0=[180]
P("\n=== F rest + body 1a0=[180] ===")
pe=bytearray(base)
pe[rva2off(pe,secs,0x46a82b)]=0x74
pe[rva2off(pe,secs,0x46a90c)]=0x75
pe[rva2off(pe,secs,0x46a58d):rva2off(pe,secs,0x46a58d)+16]=bytes.fromhex("488b8580010000488985a00100009090")
gate(save(pe,"host_1a0_rest_b180.exe"),"rest_b180")

# G Compare: is eb@82b/@90c from cmk0 plant history? Check host_cmk0_irdx (pre-sub20)
P("\n=== G pre-sub20 host branch bytes ===")
for name in ["host_cmk0_irdx.exe","host_46_base.exe","host_skip_1a0_calls.exe"]:
    p=cave/name
    if not p.exists(): continue
    pe=bytearray(p.read_bytes()); sc=pe_secs(pe)
    try:
        b82=pe[rva2off(pe,sc,0x46a82b)]; b90=pe[rva2off(pe,sc,0x46a90c)]
        P(f"  {name}: 82b={b82:02x} 90c={b90:02x}")
    except Exception as e:
        P(f"  {name}: {e}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for p in cave.glob("_t1a08_*"):
    try: p.unlink()
    except: pass
P("cleaned")
