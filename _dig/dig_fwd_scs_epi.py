#!/usr/bin/env python3
"""DIG fwd_scs_epi: SoftCap kind=0x30 miss-epi @2be90a/@2be911 fwd=GS vs let OK.
Map SoftCap homes vs Capless frame; find Isol plant (not force-kind/frame/epi-raise).
Ban tip@121278/join/epi-raise/LIVE/mega/[4b0]=1/force-kind/frame enlarge. Budget<=85s.
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
    out=cave/f"_tmp_scs_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    try:
        r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout,cwd=str(cave))
        b=out.read_bytes() if out.exists() else b""
        sh=hashlib.sha256(b).hexdigest()[:12] if b else "-"
        n868=b.count(bytes.fromhex("4881ec68080000")) if b else 0
        return tag_of(r.returncode), sh, n868, out if b else None
    except subprocess.TimeoutExpired:
        return "TIMEOUT","-",0,None
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
P("=== DIG fwd_scs_epi ===")
P(f"base lit={run(cave/'host_cmk0_irdx_sub20.exe','p_ret_lit.x')[0]} fwd={run(cave/'host_cmk0_irdx_sub20.exe','p_ret_fwd.x')[0]} let={run(cave/'host_cmk0_irdx_sub20.exe','_var_let.x')[0]}")

# A) SoftCap prol + home-arg store
P("\n=== A SoftCap_site prol @2be519 ===")
off=rva2off(base,secs,0x2be519)
for insn in list(md.disasm(bytes(base[off:off+0x100]),0x2be519))[:40]:
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")

# B) Capless pre SoftCap call: how args placed for SoftCap
P("\n=== B Capless pre-call SoftCap @576660..@5766a0 ===")
off=rva2off(base,secs,0x576640)
for insn in list(md.disasm(bytes(base[off:off+0x80]),0x576640)):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x5766b0: break

# C) Confirm miss path both; dump cookie-like in SoftCap (xor GS cookie?)
P("\n=== C SoftCap scan for gs/cookie/security ===")
off=rva2off(base,secs,0x2be519)
body=bytes(base[off:off+0x400])
for insn in md.disasm(body,0x2be519):
    s=(insn.op_str+" "+insn.mnemonic).lower()
    if "gs:" in s or "security" in s or insn.mnemonic=="ud2" or (insn.mnemonic=="call" and "0x" in insn.op_str):
        # filter only interesting
        if "gs:" in s or insn.bytes[0:1]==b"\x0f":
            P(f"  {insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# D) INT3 reconfirm epi divergence + Capless post-return under miss-only soft stub
# SoftCap: at miss @2be734 already eax=0 jmp epi. Plant: replace SoftCap body zeros of HIGH homes?
# Hypothesis: SoftCap writes [rbp+0x60..] into Capless locals; for return-Call Capless uses those slots.
# Map SoftCap_rbp vs Capless_rbp:
# Capless: push rbp; sub rsp,0x500; lea rbp,[rsp+0x80]
# SoftCap: push rbp; mov rbp,rsp  => SoftCap_rbp = Capless_rsp_at_call - 8
# If Capless_rsp_at_call == Capless_rbp - 0x80: SoftCap_rbp = Capless_rbp - 0x88
# SoftCap [rbp+K] = Capless_rbp + (K - 0x88)

P("\n=== D SoftCap home write map → Capless_rbp offset ===")
# collect mov [rbp+imm],* in SoftCap before miss @2be734
off=rva2off(base,secs,0x2be519)
writes=[]
for insn in md.disasm(bytes(base[off:off+0x220]),0x2be519):
    if insn.address>=0x2be734: break
    if insn.mnemonic=="mov" and "[rbp +" in insn.op_str and insn.op_str.startswith("qword ptr [rbp +") or insn.op_str.startswith("dword ptr [rbp +"):
        # parse imm
        try:
            part=insn.op_str.split("[rbp + ")[1].split("]")[0]
            imm=int(part,16) if part.startswith("0x") else int(part)
            writes.append((insn.address, imm, insn.op_str, insn.mnemonic))
        except: pass
    elif insn.mnemonic=="mov" and "[rbp +" in insn.op_str:
        try:
            part=insn.op_str.split("[rbp + ")[1].split("]")[0]
            imm=int(part,16) if part.startswith("0x") else int(part)
            writes.append((insn.address, imm, insn.op_str[:50], insn.mnemonic))
        except: pass
for a,imm,s,_ in writes:
    cap_off = imm - 0x88  # SoftCap_rbp = Capless_rbp - 0x88 assumption
    P(f"  SoftCap@{a:06x} [rbp+{imm:#x}] → Capless[rbp{cap_off:+#x}]  {s}")

# E) Capless slots used near SoftCap call / sret for return-Call
P("\n=== E Capless slots touched near SoftCap @57656c..@5766f0 ===")
off=rva2off(base,secs,0x57656c)
slots=set()
for insn in md.disasm(bytes(base[off:off+0x200]),0x57656c):
    if "[rbp +" in insn.op_str or "[rbp -" in insn.op_str:
        P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x5766f0: break

# F) Plant candidates (Isol, not force-kind):
# F1: SoftCap miss path - skip ZERO of high homes that collide? Too broad.
# F2: SoftCap at entry: after prol, if kind would miss - but we don't know kind yet.
# F3: Capless: for return SoftCapCallExpr path, adjust rsp so SoftCap homes land elsewhere - mega?
# F4: SoftCap: nop-out zeroing of [rbp+0x60].. that collide with Capless cookie/sret
# F5: At SoftCap miss @2be739 jmp epi: instead do proper Capless-compatible return
#     Already does add rsp; pop; ret. GS means stack already corrupted BEFORE epi.
# So corruption is from SoftCap body WRITES before miss. Which writes differ? Same code path!
# Same SoftCap code for fwd and let - so WHY does let survive?

P("\n=== F Why let survives same SoftCap writes? Capless rsp at call may differ ===")
# Diff Capless path into SoftCap for return-Call vs let: maybe different rsp / different arg homes filled
# INT3 Capless sites that set SoftCap args - compare hit sets
# Find mov to SoftCap-relevant Capless slots before call

# Probe: how many times SoftCap entered
P("\n=== F1 SoftCap entry count (INT3 @2be519) ===")
pe2=bytearray(base); pe2[rva2off(pe2,secs,0x2be519)]=0xCC
h=save(pe2,"_dig_scs_ent.exe")
P(f"  entry INT3 fwd={run(h,'_var_fwd.x')[0]} let={run(h,'_var_let.x')[0]} lit={run(h,'p_ret_lit.x')[0]}")

# Probe Capless rsp relationship: INT3 just before SoftCap call, dump would need debugger.
# Alternative: SoftCap prol stores args from rcx/rdx/... into [rbp+..]
P("\n=== F2 SoftCap first arg homes (rcx/rdx/r8/r9 store) ===")
off=rva2off(base,secs,0x2be519)
for insn in list(md.disasm(bytes(base[off:off+0x80]),0x2be519))[:25]:
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")

# G) Key DIG: Capless [rbp-0x??] cookie? Capless has NO security_check_cookie in epi (just add rsp; pop; ret).
# So GS=0xC0000409 must come from SOMEWHERE that calls __fastfail / __report_gsfailure.
# Search image for callers of known GS fail, or int 0x29 / mov ecx,2; int 0x29
P("\n=== G find __fastfail / report_gsfailure patterns near SoftCap/Capless ===")
# Windows GS: often `mov ecx,2; int 0x29` or call __report_gsfailure
img=bytes(base)
# int 0x29 = CD 29
hits=[]
idx=0
while True:
    j=img.find(b"\xcd\x29", idx)
    if j<0: break
    def off2rva(off):
        for n,(va,vs,ro,rs) in secs.items():
            if ro<=off<ro+max(vs,rs): return va+(off-ro)
        return None
    r=off2rva(j)
    if r and (0x2be000<=r<0x2bf000 or 0x576000<=r<0x579000 or 0x2c6000<=r<0x2c7000 or 0x20c000<=r<0x20e000):
        hits.append(r)
    idx=j+1
P(f"  int29 near SoftCap/Capless/2c614f: {[hex(x) for x in hits[:20]]}")

# Also: GS can be from CRT when heap/stack check. SoftCap add rsp then pop - if stack cookie
# of SoftCap itself was smashed... but SoftCap has NO cookie load in prol!
# Unless GS comes from a CALLEE of SoftCap that has cookie - kind getter @2be6ca.

P("\n=== H kind-call target @2be6ca ===")
o=rva2off(base,secs,0x2be6ca)
cb=bytes(base[o:o+5]); P(f"bytes={cb.hex()}")
assert cb[0]==0xE8
rel=struct.unpack_from("<i",cb,1)[0]
kt=0x2be6ca+5+rel
P(f"kind call target={kt:#x}")
off=rva2off(base,secs,kt)
for insn in list(md.disasm(bytes(base[off:off+0x60]),kt))[:20]:
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")

# I) Plant: SoftCap miss @2be734: instead of jmp epi, jmp a SAFE return that doesn't add rsp?
# If SoftCap never did meaningful sub... it did sub at entry. Must add.
# Plant: SoftCap skip ZERO loop of [rbp+high] that smash Capless - NOP the zeros of homes
# that Capless return-Call uses as cookie/sret.
# First: which Capless slots does return-Call use that let doesn't?
# Diff INT3 Capless between SoftCap return and next GS under... already know @576697 not reached for fwd.

# J) Concrete plant try: SoftCap after prol, jmp miss immediately (skip all home zeros + kind)
# This was dig5 jmp_miss@693: fwd=GS let=OK lit=OK — STILL GS for fwd!
# And scs_ret0 (xor;ret at entry, NO frame): fwd=GS let=AV lit=AV — different
# jmp_miss@693 skips homes but still does prol sub+add epi: fwd STILL GS.
# So GS is NOT from SoftCap home writes! SoftCap frame enter/exit itself breaks fwd.

P("\n=== J reconfirm jmp_miss (skip body, keep prol/epi) ===")
pe2=bytearray(base)
# after prol homes start ~@2be529; dig5 used @2be693
# Try earliest after sub: find first insn after sub rsp
off=rva2off(base,secs,0x2be519)
insns=list(md.disasm(bytes(base[off:off+0x40]),0x2be519))
for insn in insns:
    P(f"  prol {insn.address:06x}: {insn.mnemonic} {insn.op_str}")
# jmp from first insn after sub rsp to miss @2be734
# SoftCap: push rbp; sub rsp,0x150  (no mov rbp,rsp?!)
# WAIT - dig showed @2be519 - need exact

# K) If SoftCap has NO `mov rbp, rsp`, then rbp is Capless rbp still!
# That would make SoftCap [rbp+0xe0] = Capless [rbp+0xe0] directly!
P("\n=== K CRITICAL: does SoftCap set rbp? ===")
off=rva2off(base,secs,0x2be519)
raw=bytes(base[off:off+16])
P(f"entry16={raw.hex()}")
for insn in list(md.disasm(raw,0x2be519)):
    P(f"  {insn.address:06x}: {insn.mnemonic} {insn.op_str}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_dig_scs_*","_tmp_scs_*","_var_*.x"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
# restore p_ret_fwd
(cave/"p_ret_fwd.x").write_text(FWD,encoding="utf-8")
P("cleaned")
