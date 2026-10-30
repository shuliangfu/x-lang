#!/usr/bin/env python3
"""DIG fwd_46a500 #7: 46 frame/retaddr smash; force-restore retaddr plant; Capless post-493.
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
    out=cave/f"_t507_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
    rows={}
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
        tag,sh,outx=run(h,src)
        rt=run_bin(outx) if tag=="OK" and outx else "-"
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}")
        rows[src]=(tag,rt)
    return sha,rows
def find_disp_off(pe,secs,rva,expect_disp):
    o=rva2off(pe,secs,rva)
    ins=list(md.disasm(bytes(pe[o:o+16]),rva))[0]
    raw=bytes(pe[o:o+ins.size])
    idx=raw.find(struct.pack("<i", expect_disp))
    assert idx>=0, (hex(rva),ins.op_str)
    return o+idx, ins
def patch_disp(pe,secs,rva,old_d,new_d):
    off,ins=find_disp_off(pe,secs,rva,old_d)
    pe[off:off+4]=struct.pack("<i", new_d)
    return ins
def collect_disp_sites(pe,secs,start,nbytes,disp):
    off=rva2off(pe,secs,start); out=[]
    for insn in md.disasm(bytes(pe[off:off+nbytes]),start):
        o=rva2off(pe,secs,insn.address)
        raw=bytes(pe[o:o+insn.size])
        if struct.pack("<i",disp) in raw and "rbp" in insn.op_str:
            out.append(insn.address)
    return out
def make_b0_h2c(pe,secs):
    patch_disp(pe,secs,0x2be53e,0xf8,0xb0)
    for r in collect_disp_sites(pe,secs,0x2c614f,0x200,0x138):
        patch_disp(pe,secs,r,0x138,0x100)
    return pe
def int3_pair(pe,secs,rva,name):
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
    tf=run(save(pe2,f"_d507_{name}.exe"),"_var_fwd.x")[0]
    tl=run(save(pe2,f"_d507_{name}l.exe"),"_var_let.x")[0]
    P(f"  INT3@{rva:06x} {name:14s} fwd={tf:8s} let={tl:8s}")
    return tf,tl

for pat in ["_t507_*","_d507_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

# A) 46 prologue + frame math + early body + @46a76f locus + epi
P("=== A 46a4db prologue / @46a76f / epi ===")
for start,n in [(0x46a4db,0x80),(0x46a740,0x60),(0x46af40,0x40)]:
    P(f"  -- {start:06x} --")
    o=rva2off(base,secs,start)
    for insn in md.disasm(bytes(base[o:o+n]),start):
        raw=bytes(base[rva2off(base,secs,insn.address):rva2off(base,secs,insn.address)+insn.size])
        P(f"  {insn.address:06x}: {raw.hex():28s} {insn.mnemonic:8s} {insn.op_str}")
        if insn.address>=start+n-8: break

# B) Capless after call_493 through epi
P("\n=== B Capless 5767a0..578290 (skim call_493→epi) ===")
o=rva2off(base,secs,0x5767a0)
count=0
for insn in md.disasm(bytes(base[o:o+0x200]),0x5767a0):
    raw=bytes(base[rva2off(base,secs,insn.address):rva2off(base,secs,insn.address)+insn.size])
    interesting = insn.mnemonic in ("call","jmp","ret","int3") or "rbp + 0x4" in insn.op_str or insn.address in (0x5767a0,0x578278)
    if interesting or count<30:
        P(f"  {insn.address:06x}: {raw.hex():24s} {insn.mnemonic:8s} {insn.op_str}")
    count+=1
    if insn.address>=0x578290: break

# C) Force-restore retaddr plant at 46 epi
# Frame: need confirm lea rbp. Dig5 said rbp = CALL_RSP - 0x180; saved_rbp=[rbp+0x170]; ret=[rbp+0x178]
# After add rsp,0x1f0: if CALL_RSP was S, rbp=S-0x180, then add rsp 0x1f0 from current rsp.
# At epi entry rsp = ? Typically rsp ≈ rbp - something.
P("\n=== C plant: at 46 entry save retaddr to [rbp+0x168]; at epi restore ===")
# Prologue dig first from A output — we'll craft based on what we see.
# Alternative simpler plant: replace Capless call with:
#   lea rax, [rip+after] ; push rax; jmp 46   — but call already does that.
# Corruption is inside 46 → save at entry.
#
# Entry plant window: look at first instructions size.

# D) Under b0_h2c: INT3 inside 46 after @46a76f and stack-smashing suspects
P("\n=== D path INT3 inside 46 under b0_h2c ===")
pe=make_b0_h2c(bytearray(base),secs)
# will fill after seeing A

# E) Capless skip46 path: INT3 denser between call_493 and epi
P("\n=== E skip46 denser Capless path ===")
pe_s=make_b0_h2c(bytearray(base),secs)
o=rva2off(pe_s,secs,0x576746)
pe_s[o:o+5]=bytes.fromhex("31c0909090")
gate(save(pe_s,"host_46_skip46.exe"),"skip46")
# INT3 at key Capless nodes after 493 — discover by disasm jam
# Find all calls between 5767a0 and 578278
calls=[]
o=rva2off(base,secs,0x5767a0)
for insn in md.disasm(bytes(base[o:o+0xb00]),0x5767a0):
    if insn.mnemonic=="call":
        calls.append(insn.address)
    if insn.address>=0x578278: break
P(f"  calls between 493 and epi: {[hex(c) for c in calls[:20]]} n={len(calls)}")
for c in calls[:12]:
    int3_pair(pe_s,secs,c,f"c{c:x}"[-10:])
    int3_pair(pe_s,secs,c+5 if True else c,f"a{c:x}"[-10:])

# F) Force plant attempt: rewrite 46 epi to add rsp / pop rbp / int3 already known.
# New: at 46a4db+prologue, after `mov [rbp+..],..` first stores, insert via overwrite
# a `mov rax,[rbp+0x178]; mov [rbp-0x8],rax` style — need free stack slot.
# PRACTICAL isol: overwrite `ret` sequence with code that loads retaddr from a FIXED
# relative offset that Capless call pushed — IF frame math known.
#
# If at `pop rbp` time rsp points to retaddr, and retaddr was smashed, we need the
# ORIGINAL value. Capless call pushed it — only copy is on stack at [rbp+0x178].
# If THAT slot was smashed, we're dead unless we saved earlier.
#
# Save at entry: first insn of 46 after establishing rbp.
P("\n=== F craft entry+epi retaddr save/restore ===")
# Disassemble first 0x30 of 46 for plant window
o=rva2off(base,secs,0x46a4db)
pro=[]
for insn in md.disasm(bytes(base[o:o+0x40]),0x46a4db):
    pro.append(insn)
    P(f"  pro {insn.address:06x}: {insn.mnemonic} {insn.op_str} sz={insn.size}")
    if len(pro)>=12: break

# Expect something like:
#  push rbp / mov rbp,rsp / sub rsp,XXX  OR  lea rbp,[rsp-XXX]; sub rsp,...
# We'll build plant after seeing.

P(f"\nelapsed_so_far={time.time()-T0:.1f}s — continuing plants after prologue parse in-script")

# ---- build save/restore based on typical Capless callee shape ----
# From prior digs SoftCap callees often: 
#   55 push rbp; 4889e5 mov rbp,rsp; 4881ec.. sub rsp
# OR lea-frame without push.
# Read bytes:
raw46=bytes(base[o:o+16])
P(f"  first16={raw46.hex()}")

# G) Key experiment: NOP out body of 46 leaving only prologue+xor eax,eax+epi
# If after_46 then HIT for fwd → body smashes retaddr
P("\n=== G hollow-46: keep prologue, xor eax,eax, jump epi ===")
# Need prologue end and epi start. From prior: epi at 46af5d.
# Find where real work starts — after initial stack setup.
# Simpler: at 46a500 (first interesting), patch to `xor eax,eax; jmp 46af5d`
pe_h=make_b0_h2c(bytearray(base),secs)
# Find a good hijack point AFTER rbp is set. Use @46a500 if it's early.
# Disasm to find lea rbp / sub rsp completion
hijack=None
for insn in md.disasm(bytes(base[rva2off(base,secs,0x46a4db):rva2off(base,secs,0x46a4db)+0x80]),0x46a4db):
    P(f"  hscan {insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    if insn.mnemonic=="sub" and "rsp" in insn.op_str:
        hijack=insn.address+insn.size
        break
    if insn.mnemonic=="lea" and "rbp" in insn.op_str and "rsp" in insn.op_str:
        # lea-frame; next may be more setup
        pass
if hijack:
    P(f"  hijack@{hijack:06x}")
    oh=rva2off(pe_h,secs,hijack)
    # xor eax,eax; jmp rel32 to 46af5d
    # 31 c0 ; e9 rel
    rel=0x46af5d-(hijack+2+5)
    pe_h[oh:oh+7]=bytes([0x31,0xc0,0xe9]) + struct.pack("<i", rel)
    gate(save(pe_h,"host_46_hollow.exe"),"hollow")
    for rva,name in [(0x57674b,"after_46"),(0x5767a0,"call_493"),(0x578278,"cap_epi"),(0x123781,"caller")]:
        int3_pair(pe_h,secs,rva,name)
else:
    P("  NO hijack point found")

# H) If hollow still GS at after_46 for fwd → prologue itself or arg setup before call smashes?
# Also try: at Capless, replace call with push+jmp that uses SAME stack discipline
P("\n=== H b0_h2c + INT3 mid-46 body samples ===")
pe=make_b0_h2c(bytearray(base),secs)
for rva,name in [(0x46a500,"at500"),(0x46a520,"at520"),(0x46a760,"at760"),
                 (0x46a76f,"at76f"),(0x46a780,"at780"),(0x46a800,"at800"),
                 (0x46af00,"atf00"),(0x46af50,"atf50")]:
    try:
        int3_pair(pe,secs,rva,name)
    except Exception as e:
        P(f"  skip {name}: {e}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t507_*","_d507_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
