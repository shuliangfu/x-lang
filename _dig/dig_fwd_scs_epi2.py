#!/usr/bin/env python3
"""DIG2 fwd_scs_epi: kind-helper cookie; SoftCap rsp integrity; Capless post-0;
Isol plants for miss-epi GS. Ban force-kind/frame/epi-raise/LIVE/mega/[4b0]. Budget<=85s.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64)
cave = Path("C:/xlang_tmp/p1060/cave"); os.chdir(str(cave))
T0=time.time(); BUDGET=85
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
def run(h,src,timeout=6):
    out=cave/f"_tmp_scs2_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    try:
        r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout,cwd=str(cave))
        b=out.read_bytes() if out.exists() else b""
        sh=hashlib.sha256(b).hexdigest()[:12] if b else "-"
        n868=b.count(bytes.fromhex("4881ec68080000")) if b else 0
        return tag_of(r.returncode), sh, n868, out if b else None, r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT","-",0,None,-1
def run_bin(exe,timeout=4):
    try:
        r=subprocess.run([str(exe)],capture_output=True,timeout=timeout)
        return tag_of(r.returncode), r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT",-1
def save(pe,name):
    p=cave/name; p.write_bytes(bytes(pe)); return p

FWD="""struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { return mk(x + 1); }
function main(): i32 {
  let w: W = fw(9);
  if (w.a != 10) { return 1; }
  if (w.b != 11) { return 2; }
  if (w.c != 12) { return 3; }
  return 0;
}
"""
LET="""struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { let v: W = mk(x + 1); return v; }
function main(): i32 {
  let w: W = fw(9);
  if (w.a != 10) { return 1; }
  if (w.b != 11) { return 2; }
  if (w.c != 12) { return 3; }
  return 0;
}
"""
(cave/"_var_fwd.x").write_text(FWD,encoding="utf-8")
(cave/"_var_let.x").write_text(LET,encoding="utf-8")
(cave/"p_ret_fwd.x").write_text(FWD,encoding="utf-8")

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

# A) @20cd98 epi + cookie?
P("=== A @20cd98 full prol/epi ===")
off=rva2off(base,secs,0x20cd98)
insns=list(md.disasm(bytes(base[off:off+0x90]),0x20cd98))
for insn in insns:
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")

# B) @20bcb5 prol/epi
P("\n=== B @20bcb5 (kind helper callee) ===")
off=rva2off(base,secs,0x20bcb5)
for insn in list(md.disasm(bytes(base[off:off+0x80]),0x20bcb5))[:30]:
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")

# C) Capless after SoftCap return eax=0 path
P("\n=== C Capless @5766b0.. post SoftCap eax=0 ===")
off=rva2off(base,secs,0x5766b0)
for insn in list(md.disasm(bytes(base[off:off+0x80]),0x5766b0))[:35]:
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")

# D) Plant: SoftCap miss path — replace add;pop;ret with leave-equivalent that uses lea-frame
# SoftCap frame: push; sub 0x150; lea rbp,[rsp+0x80]
# Correct epi MUST be: add rsp,0x150; pop rbp; ret  (current) — rsp-based, OK
# Alternative bug: SoftCap zeros [rbp+0xcc]=call_rsp-0xc which is 4 bytes before saved rbp (call_rsp-8).
# dword at call_rsp-0xc overlaps? saved rbp is qword at call_rsp-8. call_rsp-0xc is 4 bytes into the
# padding between locals and saved rbp. OK.
# [rbp+0xc4]=call_rsp-0x14 — fine

# D1: At miss @2be734, instead of jmp epi, do: xor eax,eax; add rsp,0x150; pop rbp; ret INLINE
# (same as epi) — should be identical. Skip.
# D2: SoftCap skip kind call entirely: at @2be6ba (kind setup) jmp miss
P("\n=== D skip SoftCap kind-call → miss (no @20cd98) ===")
pe2=bytearray(base)
# @2be6ba: mov edx,[rbp+0xf0]; ... call @2be6ca. Replace from @2be6ba with jmp miss @2be734
# Or simpler: at @2be6ca call → mov eax,0x30 (keep kind 0x30 natural) — already know that GS
# Skip kind: at @2be6ba jmp @2be734
o=rva2off(pe2,secs,0x2be6ba)
pe2[o:o+5]=bytes([0xE9])+struct.pack("<i",0x2be734-(0x2be6ba+5))
h=save(pe2,"_dig_skipkind.exe")
tf,_,_,_,_=run(h,"_var_fwd.x"); tl,_,_,_,_=run(h,"_var_let.x"); tlit,_,_,_,_=run(h,"p_ret_lit.x")
P(f"  skipkind_miss fwd={tf} let={tl} lit={tlit}")

# D3: SoftCap early miss before ANY zero past [rbp-8]: after arg homes, jmp miss
# After @2be53e store r9, next is zeros. Jmp miss at @2be545
pe2=bytearray(base)
o=rva2off(pe2,secs,0x2be545)
pe2[o:o+5]=bytes([0xE9])+struct.pack("<i",0x2be734-(0x2be545+5))
# but miss does mov eax,0; jmp epi — we jmp to @2be734 which sets eax=0. Good.
# Wait @2be545 is 10B mov dword. Overwriting 5B leaves broken tail — need full replace or jmp at insn boundary
# @2be545 = 48 c7 85 c4 00 00 00 00 00 00 00 (mov dword [rbp+0xc4],0) = 11 bytes? 
raw=bytes(base[rva2off(base,secs,0x2be545):rva2off(base,secs,0x2be545)+16])
P(f"  raw@2be545={raw.hex()}")
ins=list(md.disasm(raw,0x2be545))[0]
P(f"  insn={ins.mnemonic} {ins.op_str} size={ins.size}")
pe2=bytearray(base)
o=rva2off(pe2,secs,0x2be545)
# pad jmp to fill? Just jmp 5B then broken — better jmp from @2be545 and nop rest of insn if size>5
pe2[o:o+5]=bytes([0xE9])+struct.pack("<i",0x2be734-(0x2be545+5))
if ins.size>5:
    pe2[o+5:o+ins.size]=b"\x90"*(ins.size-5)
h=save(pe2,"_dig_earlymiss.exe")
tf,_,_,_,_=run(h,"_var_fwd.x"); tl,_,_,_,_=run(h,"_var_let.x"); tlit,_,_,_,_=run(h,"p_ret_lit.x")
P(f"  earlymiss@545 fwd={tf} let={tl} lit={tlit}")

# D4: even earlier - right after lea rbp, before arg homes: xor eax; jmp epi
# At @2be529 jmp @2be90a but need eax=0. @2be734 sets eax. Jmp @2be734 from @2be529
pe2=bytearray(base)
o=rva2off(pe2,secs,0x2be529)
ins=list(md.disasm(bytes(base[o:o+16]),0x2be529))[0]
pe2[o:o+5]=bytes([0xE9])+struct.pack("<i",0x2be734-(0x2be529+5))
if ins.size>5: pe2[o+5:o+ins.size]=b"\x90"*(ins.size-5)
h=save(pe2,"_dig_postlea_miss.exe")
tf,_,_,_,_=run(h,"_var_fwd.x"); tl,_,_,_,_=run(h,"_var_let.x"); tlit,_,_,_,_=run(h,"p_ret_lit.x")
P(f"  postlea_miss fwd={tf} let={tl} lit={tlit}")

# D5: SoftCap epi: replace pop rbp; ret with: mov rsp, ??? 
# Try: after add rsp, use `mov rbp, [rsp]` style — 
# Actually plant: SoftCap epi pop;ret → int3 already known.
# Try Capless-style leave: SoftCap should NOT use leave (rbp != rsp+?).
# What if SoftCap epi was wrongly compiled and SHOULD be:
#   lea rsp, [rbp-0x80]; add?  lea rsp,[rbp+0x80-0x80]=[rbp]; then need to get to saved rbp
# SoftCap_rbp = call_rsp-0xd8; saved at call_rsp-8 = SoftCap_rbp+0xd0
# Correct rsp-restore: lea rsp, [rbp+0xd0]; pop rbp; ret  (== add rsp from body rsp)
# Body rsp = SoftCap_rbp - 0x80 = call_rsp - 0x158; +0x150 = call_rsp - 8. Yes add is correct.

# E) Differential: is SoftCap entered with bad alignment for fwd?
# Check Capless [rsp+0x20] 5th arg = [4b0]. Ban raising [4b0]. Read natural value via eq probe.
P("\n=== E Capless [4b0] natural eq at SoftCap call site ===")
# Before call, ecx loaded from [4b0] into [rsp+0x20]. SoftCap reads 5th arg at [rbp+0x100]=call_rsp+0x28
# SoftCap may not use 5th on miss path before kind — check if SoftCap reads [rbp+0x100] before miss
off=rva2off(base,secs,0x2be519)
for insn in md.disasm(bytes(base[off:off+0x220]),0x2be519):
    if insn.address>=0x2be734: break
    if "0x100" in insn.op_str or "0x108" in insn.op_str or "0x110" in insn.op_str:
        P(f"  {insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# F) Plant Isol: SoftCap accept kind 0x30 as miss-OK return 0 WITHOUT going through broken epi?
# Already returns 0 via miss epi. The epi itself is the GS site.
# Plant: SoftCap miss @2be739: jmp Capless-return-compatible short path
# Replace epi with: mov eax,0; lea rsp,[rbp+0xd0]; pop rbp; ret
# lea rsp,[rbp+0xd0] = 48 8d a5 d0 00 00 00 (7B); pop=5d; ret=c3; need eax=0 already from @2be734
# Current epi @2be90a: 48 81 c4 50 01 00 00  (7) 5d c3 (2) = 9B
# New: 48 8d a5 d0 00 00 00 5d c3 = 9B exact fit!
P("\n=== F plant SoftCap epi lea-rsp form (same 9B) ===")
pe2=bytearray(base)
o=rva2off(pe2,secs,0x2be90a)
new=bytes.fromhex("488da5d00000005dc3")  # lea rsp,[rbp+0xd0]; pop rbp; ret
assert len(new)==9
P(f"  old={bytes(pe2[o:o+9]).hex()} new={new.hex()}")
pe2[o:o+9]=new
h=save(pe2,"host_scs_lea_epi.exe")
sha=hashlib.sha256(bytes(pe2)).hexdigest()[:12]
P(f"  sha12={sha}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x","_var_fwd.x"]:
    tag,sh,n868,outx,crc=run(h,src)
    rt,rc="-","-"
    if tag=="OK" and outx:
        rt,rc=run_bin(outx)
    P(f"  lea_epi/{src:14s} {tag:8s} USER={sh} n868={n868} run={rt}/{rc}")

# G) Plant: SoftCap miss return via xor; ret WITHOUT unwinding — WRONG for lea-frame
# (would leave rsp wrong). Skip.

# H) INT3 at SoftCap @2be90a under lea-epi plant to see if reached
P("\n=== H reconfirm real epi INT3 under base ===")
pe2=bytearray(base)
pe2[rva2off(pe2,secs,0x2be90a)]=0xCC
h=save(pe2,"_dig_epi_a.exe")
P(f"  INT3@2be90a fwd={run(h,'_var_fwd.x')[0]} let={run(h,'_var_let.x')[0]}")
pe2=bytearray(base)
pe2[rva2off(pe2,secs,0x2be911)]=0xCC
h=save(pe2,"_dig_epi_p.exe")
P(f"  INT3@2be911 fwd={run(h,'_var_fwd.x')[0]} let={run(h,'_var_let.x')[0]}")

# I) After add rsp planted as INT3-skip: single-step theory — maybe fwd double SoftCap
# Count SoftCap entries by patching a counter — hard without shared mem.
# Alternative: INT3 at SoftCap entry AND make second entry different — use 
# SoftCap first-insn push → INT3; if only one entry both INT3. Already know both INT3.

# J) Capless passes 5th arg via [rsp+0x20]. Is Capless rsp 16-aligned at call for both?
# Windows requires 16-byte align at call. Capless: push (8); sub 0x500; total 0x508 misaligned!
# push rbp = -8; sub 0x500 → -0x508 ≡ 8 (mod 16). At call without extra adjust, rsp≡8 (mod 16) — VIOLATION!
# Caller needs rsp≡8 before call so after call push rip rsp≡0. 
# Standard: before call rsp should be ≡8 (mod 16). Capless rsp after prol = entry_rsp-0x508.
# entry_rsp at Capless entry was ≡8 (mod 16) if Capless was called correctly.
# entry_rsp-0x508 ≡ 8-8 ≡ 0 (mod 16). Before SoftCap call rsp≡0 — WRONG (need ≡8)!
# Unless Capless adjusts. We found NO rsp change. So Capless always calls SoftCap misaligned??
# That would affect BOTH fwd and let equally...

# Unless Capless itself is entered with different alignment for return-Call path.
# Outer caller of Capless_alt may differ!

P("\n=== J Capless_alt callers (who calls @57656c) ===")
img=bytes(base)
def off2rva(off):
    for n,(va,vs,ro,rs) in secs.items():
        if ro<=off<ro+max(vs,rs): return va+(off-ro)
    return None
callers=[]
for off in range(len(img)-5):
    if img[off]==0xE8:
        rel=struct.unpack_from("<i",img,off+1)[0]
        rva=off2rva(off)
        if rva is None: continue
        if rva+5+rel==0x57656c:
            callers.append(rva)
P(f"  n={len(callers)} {[hex(c) for c in callers[:20]]}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_dig_skipkind*","_dig_earlymiss*","_dig_postlea*","_dig_epi_*","_tmp_scs2_*","_var_*.x"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
(cave/"p_ret_fwd.x").write_text(FWD,encoding="utf-8")
P("cleaned")
