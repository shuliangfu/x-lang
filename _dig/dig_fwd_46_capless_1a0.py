#!/usr/bin/env python3
"""DIG fwd_46_capless_1a0: Capless supply real 6th/7th ([rsp+0x28]/[rsp+0x30]
→ [rbp+0x1a0]/[rbp+0x1a8] in 0x46a4db) so call@46a967/@46a99d can run without
skip; USER must diverge from hollow e411. Budget<=85s.
Ban: tip@121278/join/epi-raise/LIVE/mega/letter-heap/force-kind/arg-loop/
[4b0]=1/LIVE spill/hollow_only or skip_1a0 as close."""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64); md.detail = False
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
    out=cave/f"_t1a0_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}")
        rows[src]=(tag,sh,rt)
    return sha,rows
def int3_at(pe,secs,rva,src="_var_fwd.x"):
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
    return run(save(pe2,f"_d1a0_{rva:06x}.exe"),src)[0]
def int3_pair(pe,secs,rva,name):
    tf=int3_at(pe,secs,rva,"_var_fwd.x")
    tl=int3_at(pe,secs,rva,"_var_let.x")
    P(f"  INT3@{rva:06x} {name:14s} fwd={tf:8s} let={tl:8s}")
    return tf,tl
def disasm(pe,secs,rva,n=48,stop=None):
    o=rva2off(pe,secs,rva)
    for insn in md.disasm(bytes(pe[o:o+n]),rva):
        P(f"  {insn.address:06x}: {insn.bytes.hex():24s} {insn.mnemonic} {insn.op_str}")
        if stop is not None and insn.address>=stop: break
def find_cave(pe,secs,need=64, PreferNear=0x576746):
    """Find NOP/zero run in .text executable for trampoline."""
    text=secs.get(b".text") or secs.get(b"CODE")
    # scan end of .text for 00/90/CC runs
    candidates=[]
    for name,(va,vs,ro,rs) in secs.items():
        if name not in (b".text", b"CODE"): continue
        blob=bytes(pe[ro:ro+rs])
        i=0
        while i < len(blob)-need:
            if blob[i] in (0x00,0x90,0xCC):
                j=i
                while j < len(blob) and blob[j] in (0x00,0x90,0xCC):
                    j+=1
                if j-i >= need:
                    rva=va+i
                    candidates.append((abs(rva-PreferNear), rva, j-i))
                i=j
            else:
                i+=1
    candidates.sort()
    return candidates[:8]

# ---- load base ----
base_path = cave/"host_cmk0_irdx_sub20.exe"
if not base_path.exists():
    # fallback names
    for cand in ["host_skip_1a0_calls.exe","host_46_base.exe","host_cmk0_irdx.exe"]:
        if (cave/cand).exists():
            P(f"WARN missing host_cmk0_irdx_sub20; using {cand}")
            base_path = cave/cand
            break
base=bytearray(base_path.read_bytes())
secs=pe_secs(base)
P(f"base={base_path.name} sha={hashlib.sha256(base).hexdigest()[:12]} size={len(base)}")

# ---- A frame math + body uses of 1a0/1a8 ----
P("\n=== A frame + 1a0/1a8 sites in 0x46a4db ===")
P("  prol:")
disasm(base,secs,0x46a4db,24)
# collect rbp+0x1a0 / 0x1a8 sites
sites_1a0=[]; sites_1a8=[]
o=rva2off(base,secs,0x46a4db)
for insn in md.disasm(bytes(base[o:o+0xb00]),0x46a4db):
    raw=bytes(base[rva2off(base,secs,insn.address):rva2off(base,secs,insn.address)+insn.size])
    if struct.pack("<i",0x1a0) in raw and "rbp" in insn.op_str:
        sites_1a0.append((insn.address, insn.mnemonic, insn.op_str, insn.bytes.hex()))
    if struct.pack("<i",0x1a8) in raw and "rbp" in insn.op_str:
        sites_1a8.append((insn.address, insn.mnemonic, insn.op_str, insn.bytes.hex()))
P(f"  1a0 sites ({len(sites_1a0)}):")
for a,m,op,hx in sites_1a0: P(f"    @{a:06x} {m} {op}  [{hx}]")
P(f"  1a8 sites ({len(sites_1a8)}):")
for a,m,op,hx in sites_1a8: P(f"    @{a:06x} {m} {op}  [{hx}]")

# ---- B body around calls that use 1a0 ----
P("\n=== B body @46a8a5..46a9d0 (pre/post 967/99d) ===")
disasm(base,secs,0x46a8a5,0x140, stop=0x46a9d0)

# ---- C Capless call_46 setup + Capless locals near 4b0 ----
P("\n=== C Capless call_46 setup ===")
disasm(base,secs,0x576700,0x60, stop=0x576760)
P("  Capless stores to [rbp+0x4xx] near call (scan 57656c..576746):")
o=rva2off(base,secs,0x57656c)
for insn in md.disasm(bytes(base[o:o+0x200]),0x57656c):
    if insn.address>=0x576750: break
    if "rbp +" in insn.op_str or "rbp+" in insn.op_str.replace(" ",""):
        # show mov to/from high locals
        if any(f"0x4{k}" in insn.op_str for k in "0123456789abcdef") or "0x4" in insn.op_str:
            P(f"    {insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# ---- D other callers of 0x46a4db ----
P("\n=== D callers of 0x46a4db stack setup ===")
text=secs[b".text"]
va,vs,ro,rs=text
blob=bytes(base[ro:ro+rs])
# find E8 rel32 to 0x46a4db
callers=[]
for i in range(len(blob)-5):
    if blob[i]==0xE8:
        rel=struct.unpack_from("<i",blob,i+1)[0]
        src=va+i
        tgt=src+5+rel
        if tgt==0x46a4db:
            callers.append(src)
P(f"  callers={list(map(hex,callers))}")
for c in callers:
    P(f"  -- caller @{c:06x} setup (back 0x30) --")
    disasm(base,secs,c-0x30,0x40, stop=c+5)

# ---- E callees 469aa4 / 47a492 prol ----
P("\n=== E callee prol 0x469aa4 / 0x47a492 ===")
disasm(base,secs,0x469aa4,32)
P("  --")
disasm(base,secs,0x47a492,40)

# ---- F Capless free cave near call ----
P("\n=== F .text cave candidates (>=48B near 576746) ===")
caves=find_cave(base,secs,need=48, PreferNear=0x576746)
for dist,rva,sz in caves:
    P(f"  cave@{rva:06x} size={sz} dist={dist}")

# also look for known prior cave @0x116e30 style in PE
for probe in [0x116e30, 0x117000, 0x118000, 0x2ff000, 0x300000]:
    try:
        o=rva2off(base,secs,probe)
        P(f"  probe@{probe:06x} bytes={bytes(base[o:o+16]).hex()}")
    except Exception as e:
        P(f"  probe@{probe:06x} ERR {e}")

# ---- G Capless locals: what is at 4b8/4c0/4c8 after SoftCap path? ----
P("\n=== G Capless [rbp+0x4b0..] writers in Capless fn ===")
# Capless fn starts ~0x57656c; scan whole-ish for writes to 4b0+
writers=[]
o=rva2off(base,secs,0x57656c)
for insn in md.disasm(bytes(base[o:o+0x800]),0x57656c):
    if insn.address>=0x576d00: break
    if insn.mnemonic.startswith("mov") and ("0x4b" in insn.op_str or "0x4c" in insn.op_str or "0x4d" in insn.op_str):
        writers.append((insn.address, insn.mnemonic, insn.op_str))
for a,m,op in writers[:40]:
    P(f"  {a:06x}: {m} {op}")

P(f"\nelapsed_dig={time.time()-T0:.1f}s")
# stop before plants if over 40s dig — plants next
if time.time()-T0 > 50:
    P("DIG budget hot; plants deferred")
    sys.exit(0)

# ---- H plants: Capless write 6th/7th ----
# Strategy:
# 1) rewrite Capless call setup window to include [rsp+0x28]/[rsp+0x30]
#    Need more bytes → trampoline cave.
# 2) Inside 46: at early clear slots, fill 1a0/1a8 from known homes (5th, r9, etc.)
# 3) Retarget loads at 46a958/46a97a to use [rbp+0x198] (5th) or another live slot

P("\n=== H plant: fill 1a0/1a8 from 5th (copy [rbp+0x198] → 1a0, zero 1a8) ===")
# At buffer-clear @46a58d (16B available as two movq clears) — prior z1a0 used xor+store zero.
# Now: mov rax,[rbp+0x198]; mov [rbp+0x1a0],rax; mov [rbp+0x1a8],eax(=low)  — sizes:
#   48 8b 85 98 01 00 00 = mov rax,[rbp+0x198] (7)
#   48 89 85 a0 01 00 00 = mov [rbp+0x1a0],rax (7)
#   89 85 a8 01 00 00    = mov [rbp+0x1a8],eax (6)  total 20 > 16 — too big
# Smaller: mov eax,[rbp+0x198]; mov [rbp+0x1a0],eax; mov [rbp+0x1a8],eax
#   8b 85 98 01 00 00 = 6
#   89 85 a0 01 00 00 = 6
#   89 85 a8 01 00 00 = 6  total 18 > 16
# Or: mov rax,[rbp+0x198]; mov [rbp+0x1a0],rax  (7+7=14) + nop*2 — only fill 6th from 5th
blob_copy5=bytes.fromhex("488b8598010000488985a00100009090")  # 16B
assert len(blob_copy5)==16
pe=bytearray(base)
o=rva2off(pe,secs,0x46a58d)
assert bytes(pe[o:o+8])==bytes.fromhex("48c7450000000000"), bytes(pe[o:o+8]).hex()
pe[o:o+16]=blob_copy5
gate(save(pe,"host_1a0_copy5.exe"),"copy5")

P("\n=== I plant: Capless trampoline write [rsp+0x28]=[4b0], [rsp+0x30]=0 ===")
# Find a cave; if none usable, skip
caves=find_cave(base,secs,need=40, PreferNear=0x576746)
if caves:
    _, cave_rva, cave_sz = caves[0]
    P(f"  using cave@{cave_rva:06x} sz={cave_sz}")
    pe=bytearray(base)
    # trampoline:
    #   mov [rsp+0x20], ecx   ; keep 5th (ecx already loaded)
    #   mov [rsp+0x28], ecx   ; 6th = same as 5th (trial)
    #   mov dword [rsp+0x30], 0 ; 7th = 0
    #   mov rcx, rax
    #   call 0x46a4db
    #   jmp back to 57674b
    # Sizes:
    #   894c2420 (4) 894c2428 (4) c744243000000000 (8) 4889c1 (3) E8rel (5) E9rel (5) = 29B
    tramp=[]
    tramp += bytes.fromhex("894c2420")           # mov [rsp+0x20],ecx
    tramp += bytes.fromhex("894c2428")           # mov [rsp+0x28],ecx
    tramp += bytes.fromhex("c744243000000000")   # mov dword [rsp+0x30],0
    tramp += bytes.fromhex("4889c1")             # mov rcx,rax
    # call 46a4db — trampoline at cave_rva; after these bytes call site = cave_rva+len
    call_at = cave_rva + len(tramp)
    rel = 0x46a4db - (call_at + 5)
    tramp += bytes([0xE8]) + struct.pack("<i", rel)
    # jmp 57674b
    jmp_at = cave_rva + len(tramp)
    relj = 0x57674b - (jmp_at + 5)
    tramp += bytes([0xE9]) + struct.pack("<i", relj)
    P(f"  tramp len={len(tramp)} hex={bytes(tramp).hex()}")
    assert len(tramp) <= cave_sz
    oc=rva2off(pe,secs,cave_rva)
    pe[oc:oc+len(tramp)]=bytes(tramp)
    # hijack Capless: replace mov[rsp+0x20],ecx; mov rcx,rax; call  (=12B) with jmp cave; nops
    # 57673f..57674a = 12 bytes
    oh=rva2off(pe,secs,0x57673f)
    assert bytes(pe[oh:oh+4])==bytes.fromhex("894c2420"), bytes(pe[oh:oh+4]).hex()
    relh = cave_rva - (0x57673f + 5)
    pe[oh:oh+12]=bytes([0xE9])+struct.pack("<i",relh)+bytes([0x90]*7)
    gate(save(pe,"host_1a0_cap_tr_same5.exe"),"cap_tr_same5")
else:
    P("  NO cave found; skip Capless trampoline")

P("\n=== J plant: Capless inline — steal mov rcx,rax+call for only [rsp+0x28]=ecx via different approach ===")
# Alternative without cave: change body loads 1a0→198 (5th home) at 46a958 and related.
# At 46a958: typically mov something,[rbp+0x1a0] — patch disp 0x1a0→0x198
pe=bytearray(base)
patched=0
for a,m,op,hx in sites_1a0:
    # only read sites before/at calls (not writes if any)
    if a >= 0x46a900:  # the miss-arg region
        o=rva2off(pe,secs,a)
        raw=bytearray(pe[o:o+16])
        # find disp
        idx=bytes(raw).find(struct.pack("<i",0x1a0))
        if idx>=0:
            raw[idx:idx+4]=struct.pack("<i",0x198)
            pe[o:o+16]=raw
            patched+=1
            P(f"  patch 1a0→198 @{a:06x} {m} {op}")
for a,m,op,hx in sites_1a8:
    if a >= 0x46a900:
        o=rva2off(pe,secs,a)
        raw=bytearray(pe[o:o+16])
        idx=bytes(raw).find(struct.pack("<i",0x1a8))
        if idx>=0:
            # map 7th → 5th as well (or keep — try 198)
            raw[idx:idx+4]=struct.pack("<i",0x198)
            pe[o:o+16]=raw
            patched+=1
            P(f"  patch 1a8→198 @{a:06x} {m} {op}")
P(f"  patched={patched}")
gate(save(pe,"host_1a0_rd198.exe"),"rd198")

P("\n=== K plant: fill 1a0/1a8 from r9 home [rbp+0x190]? check homes ===")
# homes after prol: typically rcx@+0x180 rdx@+0x188 r8@+0x190 r9@+0x198 5th@+0x198 wait
# From dig: r9d home @46a500 [rbp+0x198] = 5th/rcx-shadow. Let's disasm homes.
P("  homes:")
disasm(base,secs,0x46a4f0,48, stop=0x46a540)

# Try Capless: before call, also write [rsp+0x28] by overwriting a longer window
# Rewrite 576739..57674a (18B): mov ecx,[4b0](6); mov[rsp+20],ecx(4); mov[rsp+28],ecx(4); mov rcx,rax(3); call needs 5 → 22 > 18
# Or drop separate mov ecx: assume ecx already? No, 576739 loads it.
# Use cave trampoline already done.

P("\n=== L plant: Capless trampoline 6th=[4a8](r9), 7th=[4a0](r8d) ===")
if caves:
    _, cave_rva, cave_sz = caves[0]
    pe=bytearray(base)
    # Need r9/r8 still live: Capless set r9@57671d, r8d@576724 — still in regs at 57673f? 
    # Between: rdx,rax,ecx loaded — r8d/r9 NOT clobbered. Good.
    # tramp:
    #   mov [rsp+0x20], ecx
    #   mov [rsp+0x28], r9     ; 4c 89 4c 24 28 (5)
    #   mov [rsp+0x30], r8     ; 4c 89 44 24 30 (5)
    #   mov rcx, rax
    #   call 46
    #   jmp back
    tramp=bytearray()
    tramp += bytes.fromhex("894c2420")             # mov [rsp+0x20],ecx
    tramp += bytes.fromhex("4c894c2428")           # mov [rsp+0x28],r9
    tramp += bytes.fromhex("4c89442430")           # mov [rsp+0x30],r8
    tramp += bytes.fromhex("4889c1")               # mov rcx,rax
    call_at = cave_rva + len(tramp)
    tramp += bytes([0xE8]) + struct.pack("<i", 0x46a4db-(call_at+5))
    jmp_at = cave_rva + len(tramp)
    tramp += bytes([0xE9]) + struct.pack("<i", 0x57674b-(jmp_at+5))
    P(f"  tramp2 len={len(tramp)} hex={bytes(tramp).hex()}")
    if len(tramp)<=cave_sz:
        oc=rva2off(pe,secs,cave_rva)
        pe[oc:oc+len(tramp)]=bytes(tramp)
        oh=rva2off(pe,secs,0x57673f)
        relh = cave_rva - (0x57673f + 5)
        pe[oh:oh+12]=bytes([0xE9])+struct.pack("<i",relh)+bytes([0x90]*7)
        gate(save(pe,"host_1a0_cap_tr_r9r8.exe"),"cap_tr_r9r8")
    else:
        P(f"  tramp2 too big for cave {cave_sz}")

P("\n=== M plant: Capless trampoline 6th=rdx, 7th=0 ===")
if caves:
    _, cave_rva, cave_sz = caves[0]
    pe=bytearray(base)
    tramp=bytearray()
    tramp += bytes.fromhex("894c2420")             # mov [rsp+0x20],ecx
    tramp += bytes.fromhex("4889542428")           # mov [rsp+0x28],rdx
    tramp += bytes.fromhex("48c744243000000000")   # mov qword [rsp+0x30],0 (9) — may be tight
    # 4+6+9+3+5+5=32
    tramp=bytearray()
    tramp += bytes.fromhex("894c2420")
    tramp += bytes.fromhex("4889542428")           # [rsp+0x28]=rdx
    tramp += bytes.fromhex("c744243000000000")     # dword [rsp+0x30]=0
    tramp += bytes.fromhex("4889c1")
    call_at = cave_rva + len(tramp)
    tramp += bytes([0xE8]) + struct.pack("<i", 0x46a4db-(call_at+5))
    jmp_at = cave_rva + len(tramp)
    tramp += bytes([0xE9]) + struct.pack("<i", 0x57674b-(jmp_at+5))
    P(f"  tramp3 len={len(tramp)}")
    if len(tramp)<=cave_sz:
        oc=rva2off(pe,secs,cave_rva)
        pe[oc:oc+len(tramp)]=bytes(tramp)
        oh=rva2off(pe,secs,0x57673f)
        pe[oh:oh+12]=bytes([0xE9])+struct.pack("<i",cave_rva-(0x57673f+5))+bytes([0x90]*7)
        gate(save(pe,"host_1a0_cap_tr_rdx0.exe"),"cap_tr_rdx0")

# ---- N compare hollow USER ----
P("\n=== N refs hollow / skip_1a0 ===")
for name in ["host_46_hollow_only.exe","host_skip_1a0_calls.exe","host_cmk0_irdx_sub20.exe"]:
    p=cave/name
    if p.exists():
        gate(p, name.replace("host_","").replace(".exe",""), srcs=["p_ret_fwd.x"])

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t1a0_*","_d1a0_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
