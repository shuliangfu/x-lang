#!/usr/bin/env python3
"""DIG fwd_46a500 #5: corrected frame math; Capless miss-r9 before call_46;
plant set-r9 / read 0x198→0x1a0; find GS callee. Budget<=85s."""
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
    out=cave/f"_t505_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
def gate(h,label):
    sha=hashlib.sha256(h.read_bytes()).hexdigest()[:12]
    P(f"  [{label}] sha={sha}")
    out={}
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
        tag,sh,outx=run(h,src)
        rt=run_bin(outx) if tag=="OK" and outx else "-"
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}")
        out[src]=(tag,rt,sh)
    return sha,out

for pat in ["_t505_*","_d505_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

def find_disp_off(pe,rva,expect_disp):
    o=rva2off(pe,secs,rva)
    ins=list(md.disasm(bytes(pe[o:o+16]),rva))[0]
    raw=bytes(pe[o:o+ins.size])
    idx=raw.find(struct.pack("<i", expect_disp))
    assert idx>=0, (hex(rva),raw.hex(),hex(expect_disp),ins.op_str)
    return o+idx, ins
def patch_disp(pe,rva,old_d,new_d):
    off,ins=find_disp_off(pe,rva,old_d)
    pe[off:off+4]=struct.pack("<i", new_d)
    return ins
def collect_disp_sites(start,nbytes,disp):
    off=rva2off(base,secs,start); out=[]
    for insn in md.disasm(bytes(base[off:off+nbytes]),start):
        o=rva2off(base,secs,insn.address)
        raw=bytes(base[o:o+insn.size])
        if struct.pack("<i",disp) in raw and "rbp" in insn.op_str:
            out.append(insn.address)
    return out
def make_b0_h2c(pe=None):
    if pe is None: pe=bytearray(base)
    patch_disp(pe,0x2be53e,0xf8,0xb0)
    for r in collect_disp_sites(0x2c614f,0x200,0x138):
        patch_disp(pe,r,0x138,0x100)
    return pe
def int3_pair(pe,rva,name):
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
    tf=run(save(pe2,f"_d505_{name}.exe"),"_var_fwd.x")[0]
    tl=run(save(pe2,f"_d505_{name}l.exe"),"_var_let.x")[0]
    P(f"  INT3@{rva:06x} {name:14s} fwd={tf:8s} let={tl:8s}")
    return tf,tl

P("=== A corrected frame math ===")
P("  after push+sub0x1f0+lea: rbp=CALL_RSP-0x180")
P("  saved_rbp=[rbp+0x170]; retaddr=[rbp+0x178]")
P("  shadow: +0x180..+0x198 (=CALL_RSP+0..+0x18); 5tharg=[rbp+0x1a0]=CALL_RSP+0x20")
P("  @46a500 r9d home → shadow r9 (NOT 5th arg); SoftCap @2be53e → 5th arg (different)")
for d in [0x170,0x178,0x1a0,0x198,0x180]:
    sites=collect_disp_sites(0x46a4db,0xc00,d)
    P(f"  0x{d:x} sites={[hex(x) for x in sites]}")

# B) dump Capless call_46 setup bytes; find patch window for mov r9
P("\n=== B Capless call_46 setup raw ===")
o=rva2off(base,secs,0x576720)
chunk=bytes(base[o:o+0x40])
for insn in md.disasm(chunk,0x576720):
    raw=bytes(base[rva2off(base,secs,insn.address):rva2off(base,secs,insn.address)+insn.size])
    P(f"  {insn.address:06x}: {raw.hex():24s} {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x57674b: break

# Compare call_493 setup for r9
P("  -- call_493 setup --")
o=rva2off(base,secs,0x576777)
for insn in md.disasm(bytes(base[o:o+0x40]),0x576777):
    raw=bytes(base[rva2off(base,secs,insn.address):rva2off(base,secs,insn.address)+insn.size])
    P(f"  {insn.address:06x}: {raw.hex():24s} {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x5767a5: break

# C) plant: b0_h2c + read@46a8ba 0x198→0x1a0 (use real 5th=[4b0])
P("\n=== C b0_h2c + rd198→0x1a0 ===")
pe=make_b0_h2c()
patch_disp(pe,0x46a8ba,0x198,0x1a0)
gate(save(pe,"host_46_rd1a0.exe"),"rd1a0")
for rva,name in [(0x57674b,"after_46"),(0x46af65,"ret1"),(0x46a8ba,"rd"),(0x123781,"caller")]:
    int3_pair(pe,rva,name)

# D) plant: b0_h2c + nop home500 + rd198→0x1a0
P("\n=== D b0_h2c + nop500 + rd1a0 ===")
pe=make_b0_h2c()
o=rva2off(pe,secs,0x46a500)
ins=list(md.disasm(bytes(pe[o:o+16]),0x46a500))[0]
pe[o:o+ins.size]=b"\x90"*ins.size
patch_disp(pe,0x46a8ba,0x198,0x1a0)
gate(save(pe,"host_46_nop_rd1a0.exe"),"nop_rd1a0")
for rva,name in [(0x57674b,"after_46"),(0x46af65,"ret1"),(0x123781,"caller")]:
    int3_pair(pe,rva,name)

# E) plant: Capless set r9 before call_46
# Replace from 576739:
#   mov ecx,[rbp+0x4b0]; mov [rsp+0x20],ecx; mov rcx,rax; call
# with sequence that also sets r9. call_493 does: mov r9,[rbp+0x4a8].
# Try: use [4b0] as r9d zero-extend or mov r9,[rbp+0x4a8] like sibling.
# Byte budget 576739..576745 (before call at 576746):
#   8b8db0040000  mov ecx,[rbp+0x4b0]  (6)
#   894c2420      mov [rsp+0x20],ecx   (4)
#   4889c1        mov rcx,rax         (3)
#   total 13 bytes
# Want also mov r9d,ecx or mov r9,[rbp+0x4a8].
# Option E1: mov r9d,ecx instead of mov [rsp+0x20],ecx — keep 5th? 
# Option E2: expand by stealing from earlier movs — DIG: overwrite
#   mov ecx,[4b0]; mov r9d,ecx; mov [rsp+0x20],ecx; mov rcx,rax
#   8b8db0040000 (6) + 4189c9 (3) + 894c2420 (4) + 4889c1 (3) = 16 > 13. Need 3 more bytes.
# Steal 576732 mov rax,[rbp+0x490] = 488b8540040000 (7) — keep it, look earlier.
# Full block 576724..576746:
P("\n=== E design Capless r9-set patch ===")
# Encode: after mov rax,[490], do:
#   mov r9, [rbp+0x4a8]   # 4c8b8da8040000 (7) — same as call_493
#   mov ecx, [rbp+0x4b0]
#   mov [rsp+0x20], ecx
#   mov rcx, rax
#   call
# Need to fit. Current 576724..576745 length:
o1=rva2off(base,secs,0x576724)
o2=rva2off(base,secs,0x576746)
P(f"  window 576724..576746 len={o2-o1} bytes hex={bytes(base[o1:o2]).hex()}")

# Build replacement that fits same 0x22 bytes (34):
# 576724: 448b85a0040000  mov r8d,[rbp+0x4a0]  (7)
# 57672b: 488b9548040000  mov rdx,[rbp+0x498]  (7)
# 576732: 488b8540040000  mov rax,[rbp+0x490]  (7)
# 576739: 8b8db0040000    mov ecx,[rbp+0x4b0]  (6)
# 57673f: 894c2420        mov [rsp+0x20],ecx   (4)
# 576743: 4889c1          mov rcx,rax         (3)
# total 34
# Replace with adding mov r9,[rbp+0x4a8] — need +7, must shrink.
# Shrink: mov r9d,[rbp+0x4b0]; mov [rsp+0x20],r9d; use r9 for both 4th and reload 5th from r9d
# New:
#  mov r8d,[4a0]         7
#  mov rdx,[498]         7
#  mov rax,[490]         7
#  mov r9d,[4b0]         6  (448b8db0040000)
#  mov [rsp+0x20],r9d    5  (44894c2420)
#  mov rcx,rax           3
# total 35 — 1 over!
# 
# Drop mov [rsp+0x20] and only set r9d=[4b0]; 5th stays stale/uninitialized for this call?
# SoftCap path may need 5th. Capless restores 5th before EVERY callee from [4b0] — keep it.
#
# Alternative: mov r9, [rbp+0x4a8] (incoming r9 home) — 7 bytes, replace mov ecx+[rsp+0x20]+mov rcx
# with: mov r9,[4a8]; mov ecx,[4b0]; mov [rsp+0x20],ecx; mov rcx,rax = 7+6+4+3=20 > 13
# Need steal from mov rax (keep rax in rcx path differently).
#
# Compact encoding using rax still in rcx at end:
# 448b85a0040000	mov r8d,[4a0]	7
# 488b9548040000	mov rdx,[498]	7
# 4c8b8da8040000	mov r9,[4a8]	7   NEW
# 488b8540040000	mov rax,[490]	7
# 8b8db0040000	mov ecx,[4b0]	6
# 894c2420	mov [rsp+0x20],ecx	4
# 4889c1	mov rcx,rax	3
# total 41 — way over 34
#
# Must shorten. Use 32-bit r9d from [4a8]:
# 448b8da8040000 mov r9d,[4a8] 6
# Try replace only the middle: from 576732 (mov rax) through 576745 (13+7=20 bytes available from 576732)
# 576732..576746 = 0x14 = 20 bytes
# Want: mov rax,[490] (7); mov r9d,[4a8] (6); mov ecx,[4b0] (6); mov [rsp+0x20],ecx (4); mov rcx,rax (3) = 26 > 20
#
# Skip mov [rsp+0x20] — Capless already wrote 5th on previous call and 46 smash is shadow r9 not 5th:
# Actually before call_46 Capless DOES write [rsp+0x20]=[4b0]. If we skip, 5th may be from previous @2c call's leftover.
# @2c also writes homes. With h2c retarget, 5th preserved from Capless write before @2c... Capless writes before each call. Before @2c:
# Need check. Safer keep [rsp+0x20].
#
# Smallest add: xor r9d,r9d (3 bytes 4533c9) — zero 4th arg
# Fit into 57673f..576745 (7 bytes: mov [rsp+0x20],ecx; mov rcx,rax):
#   894c2420  mov [rsp+0x20],ecx (4)
#   4533c9    xor r9d,r9d (3)
#   4889c1    mov rcx,rax (3) = 10 > 7. Over by 3.
#
# Replace mov ecx,[4b0]; mov [rsp+0x20],ecx; mov rcx,rax (13)
# with: xor r9d,r9d (3); mov ecx,[4b0] (6); mov [rsp+0x20],ecx (4); mov rcx,rax (3) = 16 > 13. Over 3.
#
# Use NOP hole: look at 576720 test/add junk before 576724 — may be padding misdecode.
P("  -- bytes before 576724 --")
o=rva2off(base,secs,0x576710)
for insn in md.disasm(bytes(base[o:o+0x20]),0x576710):
    raw=bytes(base[rva2off(base,secs,insn.address):rva2off(base,secs,insn.address)+insn.size])
    P(f"  {insn.address:06x}: {raw.hex():24s} {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x576730: break

# F) plant xor-r9 by overwriting 57673f-area carefully:
# Change to: mov ecx,[4b0](6); mov r9d,ecx(3); mov [rsp+0x20],ecx(4); mov rcx,rax(3)=16
# Steal 3 bytes: shorten mov rax,[490] — can't.
# Patch call_46's first instructions inside 46: at entry after homes, zero is already...
# SIMPLER plant inside 46: at @46a500 change to `mov dword [rbp+0x198], 0` (zero r9 home)
# Bytes: currently 44898d98010000 (7) mov [rbp+0x198],r9d
# Want: c7859801000000000000 (10) mov dword [rbp+0x198],0 — too big
# Or: 31c0 (xor eax,eax) + 898598010000 (mov [rbp+0x198],eax) = 2+6=8 > 7
# 44898d98010000 → 4489b598010000 would be mov [rbp+0x198],r14d if r14=0? unknown.
# nop home (7×90) already tried → AV with b0_h2c.
#
# Try: mov [rbp+0x198], r8d  (reuse r8d which Capless SET) — same size 44898598010000 vs 44898d... 
# r9d opcode 8d vs r8d 85: change one byte 8d→85
P("\n=== F b0_h2c + home r9d→r8d (Capless-set) ===")
pe=make_b0_h2c()
o=rva2off(pe,secs,0x46a500)
raw=bytearray(pe[o:o+7])
P(f"  before {raw.hex()}")
# 44 89 8d 98 01 00 00 → 44 89 85 98 01 00 00 (r8d)
assert raw[0]==0x44 and raw[1]==0x89
pe[o+2]=0x85  # ModRM: r8d instead of r9d (8d→85)
P(f"  after  {bytes(pe[o:o+7]).hex()}")
ins=list(md.disasm(bytes(pe[o:o+7]),0x46a500))[0]
P(f"  disasm {ins.mnemonic} {ins.op_str}")
gate(save(pe,"host_46_home_r8d.exe"),"home_r8d")
for rva,name in [(0x57674b,"after_46"),(0x46af65,"ret1"),(0x46a8ba,"rd198"),(0x123781,"caller")]:
    if time.time()-T0>60: break
    int3_pair(pe,rva,name)

# G) GS callee hunt: INT3 at hit calls' targets that might have cookie
P("\n=== G scan deep callees for gs: ===")
for entry in [0x45198d,0x44ce03,0x44f7e8,0x469aa4,0x47a492,0x452df5,0x45234b,0x1a80b0,0x1a5bd0,0x44e0d1,0x47a34f]:
    try:
        o=rva2off(base,secs,entry)
    except Exception as e:
        P(f"  {entry:06x} no rva {e}"); continue
    hits=[]
    for insn in md.disasm(bytes(base[o:o+0x800]),entry):
        s=(insn.mnemonic+" "+insn.op_str).lower()
        if "gs:" in s:
            hits.append(f"{insn.address:06x}:{insn.mnemonic} {insn.op_str}")
        if insn.mnemonic=="ret" and insn.address>entry+0x20:
            break
    # also prol
    prol=[]
    for insn in md.disasm(bytes(base[o:o+0x30]),entry):
        prol.append(f"{insn.mnemonic} {insn.op_str}")
        if insn.address>=entry+0x28: break
    P(f"  {entry:06x} gs={hits[:4]} prol={prol[:4]}")

# H) critical: under b0_h2c, is GS inside ret's *target*? Patch ret to jmp to INT3 landing
# Instead: INT3 at 57674a (byte before after_46) and 57674c
P("\n=== H after_46 neighborhood INT3 ===")
pe=make_b0_h2c()
for rva,name in [(0x57674a,"b_after"),(0x57674b,"after_46"),(0x57674c,"a_after"),
                 (0x46af64,"pop_rbp"),(0x46af65,"ret1"),(0x46af66,"after_ret")]:
    int3_pair(pe,rva,name)

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t505_*","_d505_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
