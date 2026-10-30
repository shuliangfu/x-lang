#!/usr/bin/env python3
"""DIG fwd_46a500 #6: Capless path into call_46 (r9@57671d); why ret HIT but
after_46 GS for fwd; stack at epi; plant Capless-side. Budget<=85s."""
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
    out=cave/f"_t506_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
        tag,sh,outx=run(h,src)
        rt=run_bin(outx) if tag=="OK" and outx else "-"
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}")
    return sha

for pat in ["_t506_*","_d506_*"]:
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
    assert idx>=0
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
    tf=run(save(pe2,f"_d506_{name}.exe"),"_var_fwd.x")[0]
    tl=run(save(pe2,f"_d506_{name}l.exe"),"_var_let.x")[0]
    P(f"  INT3@{rva:06x} {name:14s} fwd={tf:8s} let={tl:8s}")
    return tf,tl

# A) Capless path store_2c → call_46
P("=== A Capless 5766f0..576750 ===")
o=rva2off(base,secs,0x5766e0)
for insn in md.disasm(bytes(base[o:o+0x80]),0x5766e0):
    raw=bytes(base[rva2off(base,secs,insn.address):rva2off(base,secs,insn.address)+insn.size])
    P(f"  {insn.address:06x}: {raw.hex():24s} {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x576750: break

# B) under b0_h2c: INT3 at 57671d (mov r9) and path nodes
P("\n=== B path INT3 under b0_h2c ===")
pe=make_b0_h2c()
gate(save(pe,"host_46_b0_h2c.exe"),"b0_h2c")
for rva,name in [(0x5766f1,"store_2c"),(0x57671d,"mov_r9"),(0x576724,"mov_r8"),
                 (0x576746,"call_46"),(0x57674b,"after_46"),
                 (0x46af5d,"add_rsp"),(0x46af64,"pop_rbp"),(0x46af65,"ret1")]:
    int3_pair(pe,rva,name)

# C) KEY experiment: replace `ret` at 46af65 with `int3` already done.
# Now: replace ret with `jmp` to a known INT3 at Capless after_46 — if jmp lands, retaddr was the issue?
# Actually: overwrite retaddr slot? 
# Better: change epi `ret` to `jmp 57674b` (direct absolute via ff25 or E9 rel32)
# E9 rel32: rel = 57674b - (46af65+5) = 57674b - 46af6a
P("\n=== C plant epi ret→jmp after_46 (bypass retaddr) under b0_h2c ===")
pe=make_b0_h2c()
ret_rva=0x46af65
# ret is 1 byte C3; need 5 bytes for E9. Steal pop rbp (1) + ret (1) = 2, not enough.
# Use: at 46af5d add rsp,0x1f0 (7 bytes 4881c4f0010000) + pop (1) + ret (1) = 9 bytes
# Replace epi with: add rsp,0x1f0 (7); jmp rel after_46 
# But skip pop rbp — Capless rbp won't restore! Capless uses rbp heavily → AV.
# Replace only ret (C3) with CC we know HIT.
# Alternative: at start of 46, save real retaddr to a safe local; at epi restore it.
# DIG: read what [rbp+0x178] is at pop_rbp time via... can't easily.
# Try INT3 at MANY Capless addresses after return — maybe ret goes to wrong place that GS's
P("\n=== C2 spray INT3 Capless after likely bad ret targets? ===")
# If retaddr corrupted to point near security_check_cookie
# Search PE for security_check_cookie / __report_gsfailure
pe_raw=bytes(base)
# find string
for needle in [b"security_check_cookie", b"__report_gsfailure", b"Stack around"]:
    idx=pe_raw.find(needle)
    P(f"  str {needle!r} file_off={idx:#x}" if idx>=0 else f"  str {needle!r} MISSING")

# Find calls to typical GS helper: pattern E8 ?? ?? ?? ?? often; look for fn that does xor rcx, qword ptr gs:[0x58] or similar from entry
P("  scanning .text for gs:[48] / gs:[58] (x64 PE cookie TLS) first 20...")
gs_sites=[]
# walk executable section — use secs .text
text=secs.get(b".text") or secs.get(b"TEXT")
if not text:
    # pick largest exec-like by scanning all
    for n,v in secs.items():
        P(f"  sec {n} va={v[0]:#x} sz={v[1]:#x}")
    text=list(secs.values())[0]
va,vs,ro,rs=text if isinstance(text,tuple) else (0,0,0,0)
# search all secs for gs: use
for n,(va,vs,ro,rs) in secs.items():
    chunk=bytes(base[ro:ro+min(vs,rs)])
    # capstone in chunks of 0x10000 is slow; byte scan for 65 48 (gs rex) or 65 33
    for i in range(len(chunk)-3):
        if chunk[i]==0x65 and chunk[i+1] in (0x48,0x4c,0x33,0x8b,0x48):
            # verify
            at=va+i
            try:
                ins=list(md.disasm(chunk[i:i+16],at))[0]
            except Exception:
                continue
            if ins.address==at and "gs:" in ins.op_str:
                gs_sites.append((at, ins.mnemonic, ins.op_str))
                if len(gs_sites)>=15: break
    if len(gs_sites)>=15: break
for a,m,o in gs_sites[:15]:
    P(f"  gs {a:06x}: {m} {o}")

# D) Hypothesis: fwd returns eax>0 → Capless takes 57676d mov eax,0; jmp epi — let returns 0
# Capless after_46:
#   mov [450],eax; cmp; jns; ...; cmp [450],0; jle 576777; mov eax,0; jmp epi
# If eax>0: early exit Capless with 0 WITHOUT calling 493. That still REACHES after_46 mov!
# So after_46 INT3 must HIT if we return at all. Unless we don't return to 57674b.
P("\n=== D confirm: if retaddr wrong, where? patch 46 to save retaddr to [rbp-0x40] DIG ===")
# At 46 entry after lea rbp, read [rbp+0x178] — can't without adding instrs.
# Simpler: overwrite Capless call's return: replace `call 46a4db` with `call` to trampoline
# that INT3s on way back — too heavy.
# PRACTICAL: under b0_h2c, replace 46's ret with:
#   push imm32_of_57674b; ret  — forces return to after_46
# push imm32 = 68 <imm32> (5 bytes). Only 1 byte at ret.
# At 46af5d (7+1+1=9 bytes epi):
#   68 4b677500   push 0x57674b  (5)  NOTE: need VA not RVA! PE may rebase.
# ASLR! Absolute VA won't work. Need relative.
# E9 rel to 57674b from after the jmp insn.
# epi rebuild (9 bytes available at 46af5d..46af65 inclusive = 9 bytes):
#   4881c4f0010000  add rsp,0x1f0 (7)
#   5d              pop rbp (1)
#   c3              ret (1)
# For forced jmp without pop (8 bytes): 
#   4881c4f0010000  add rsp,0x1f0 (7)
#   c3              ret (1)  — skip pop, leave rbp as 46's rbp
# Capless then uses wrong rbp (46's) → likely AV not GS.
#
# Try: add rsp,0x1f0; pop rbp; int3 — already know int3 on ret HIT.
# The mystery stands: we reach ret, retaddr should be 57674b, but after_46 not HIT.
#
# UNLESS: pop rbp with CORRUPTED saved rbp, and somehow ret is fine, but
# Windows Control Flow Guard checks return and fails with... not typically GS.
#
# OR: there are TWO threads? No.
#
# OR: INT3 at after_46 changes instruction and the RETURN ADDRESS was computed
# pointing into the middle of the mov instruction? Retaddr is set at call time
# to 57674b — fixed.
#
# WAIT. ASLR + our PE patch: we patch the HOST pe file. When host runs, base may
# differ. INT3 at file offset maps to correct RVA. call pushes VA=base+57674b.
# ret goes to base+57674b. INT3 at that RVA should hit.
#
# Unless fwd's call to 46 is NOT from 576746! Another caller of 0x46a4db?
P("\n=== E find all E8 callers of 0x46a4db ===")
target=0x46a4db
callers=[]
for n,(va,vs,ro,rs) in secs.items():
    chunk=bytearray(base[ro:ro+min(vs,rs)])
    # scan E8
    i=0
    while i < len(chunk)-4:
        if chunk[i]==0xE8:
            # rel32
            rel=struct.unpack_from("<i",chunk,i+1)[0]
            at=va+i
            dest=at+5+rel
            if dest==target:
                callers.append(at)
            i+=1
        else:
            i+=1
P(f"  callers={[hex(c) for c in callers]}")

# F) under b0_h2c INT3 each caller after
P("\n=== F INT3 after each caller ===")
pe=make_b0_h2c()
for c in callers:
    after=c+5
    int3_pair(pe,after,f"ac{c:x}"[-12:])

# G) plant: skip call_46 entirely under b0_h2c — nop call / mov eax,0
# If fwd then progresses past after_46 → 46 is the GS source (during call, not after)
P("\n=== G b0_h2c + skip call_46 (mov eax,0; nop pad) ===")
pe=make_b0_h2c()
# call at 576746 is E8 90 3d ef ff (5 bytes). Replace with 31c0 90 90 90 (xor eax,eax; nop*3)
o=rva2off(pe,secs,0x576746)
pe[o:o+5]=bytes.fromhex("31c0909090")
gate(save(pe,"host_46_skip46.exe"),"skip46")
for rva,name in [(0x57674b,"after_46"),(0x5767a0,"call_493"),(0x578278,"cap_epi"),(0x123781,"caller")]:
    int3_pair(pe,rva,name)

# H) b0_h2c + call_46 replaced with call to ret0 stub: find nearby ret-only
# or call SoftCap miss ret0 — DIG: call 2be90a? messy.
# Simpler: call a `xor eax,eax; ret` gadget
P("\n=== H find xor eax,eax; ret gadget ===")
gadget=None
for n,(va,vs,ro,rs) in secs.items():
    chunk=bytes(base[ro:ro+min(vs,rs)])
    needle=bytes.fromhex("31c0c3")
    j=chunk.find(needle)
    if j>=0:
        gadget=va+j; break
P(f"  gadget={gadget:#x}" if gadget else "  no gadget")
if gadget:
    pe=make_b0_h2c()
    o=rva2off(pe,secs,0x576746)
    # E8 rel32
    rel=gadget-(0x576746+5)
    pe[o]=0xE8
    pe[o+1:o+5]=struct.pack("<i", rel)
    gate(save(pe,"host_46_call_ret0.exe"),"call_ret0")
    for rva,name in [(0x57674b,"after_46"),(0x5767a0,"call_493"),(0x123781,"caller")]:
        int3_pair(pe,rva,name)

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t506_*","_d506_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
