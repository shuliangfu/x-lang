#!/usr/bin/env python3
"""DIG6 fwd_gs_root: Capless frame/args into SoftCap_site for return-CallExpr vs let.
Restore p_ret_fwd.x. Find other SoftCap_site callers. Probe [rbp+0x4b0] / home.
Ban tip@121278/join/epi/LIVE/mega/[4b0]=1. Budget<=85s.
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
    out=cave/f"_tmp_fgs6_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    try:
        r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout,cwd=str(cave))
        return tag_of(r.returncode)
    except subprocess.TimeoutExpired:
        return "TIMEOUT"

# restore probes
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
(cave/"p_ret_fwd.x").write_text(FWD, encoding="utf-8")
(cave/"_var_fwd.x").write_text(FWD, encoding="utf-8")
(cave/"_var_let.x").write_text(LET, encoding="utf-8")

host=cave/"host_cmk0_irdx_sub20.exe"
base=bytearray(host.read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)
P("=== DIG6 Capless/SoftCap_site call context ===")
P(f"baseline fwd={run(host,'p_ret_fwd.x')} let={run(host,'_var_let.x')} lit={run(host,'p_ret_lit.x')}")

# find all E8 to SoftCap_site 0x2be519
P("\n=== E8 callers of SoftCap_site @2be519 ===")
# scan .text for E8 rel32 targeting 2be519
text=None
for n,(va,vs,ro,rs) in secs.items():
    if n==b".text" or va<=0x2be519<va+vs:
        pass
# whole image scan for E8
callers=[]
img=bytes(base)
# map file off -> rva helper
def off2rva(off):
    for n,(va,vs,ro,rs) in secs.items():
        if ro<=off<ro+max(vs,rs):
            return va+(off-ro)
    return None
for off in range(len(img)-5):
    if img[off]==0xE8:
        rel=struct.unpack_from("<i",img,off+1)[0]
        rva=off2rva(off)
        if rva is None: continue
        tgt=rva+5+rel
        if tgt==0x2be519:
            callers.append(rva)
P(f"n_callers={len(callers)}")
for c in callers:
    P(f"  E8 @{c:#x}")

# Capless FN frame at @57656c - cookie?
P("\n=== Capless_alt prol/epi cookie? ===")
off=rva2off(base,secs,0x57656c)
for insn in list(md.disasm(bytes(base[off:off+0x40]),0x57656c))[:15]:
    P(f"  {insn.address:06x}: {insn.mnemonic} {insn.op_str}")
# find epi / security
P("--- scan Capless_alt for security_check / gs ---")
body=bytes(base[off:off+0x2e00])
for insn in md.disasm(body,0x57656c):
    if "gs" in insn.op_str or insn.mnemonic=="int" or (insn.mnemonic=="call" and insn.address>0x578000):
        pass
    if insn.mnemonic=="call":
        # show calls near epi (high addresses in FN)
        if insn.address>=0x578200 or "security" in insn.op_str:
            P(f"  {insn.address:06x}: call {insn.op_str}")
    if insn.address>=0x578278 and insn.address<=0x5782a0:
        P(f"  {insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Dump Capless @578278 exit epi
P("\n=== Capless exit @578278 ===")
o2=rva2off(base,secs,0x578270)
for insn in md.disasm(bytes(base[o2:o2+0x40]),0x578270):
    P(f"  {insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    if insn.address>0x5782b0: break

# INT3 at SoftCap_site miss path under fwd: does Capless cookie fail AFTER return?
# Plant: SoftCap_site @2be734 mov eax,0 -> keep; replace jmp epi with int3 to see
# Better: at SoftCap_site entry, save nothing; force immediate `xor eax,eax; ret` WITHOUT frame
# (skip prol/epi entirely) - if Capless gets eax=0 and continues, GS was SoftCap_site frame;
# if still GS, Capless pre-state.
P("\n=== plant SoftCap_site entry ret0 (no frame) ===")
# SoftCap_site starts push rbp. Replace first bytes with: xor eax,eax; ret; nops
# push rbp = 55; need 3 bytes min for 31c0 c3
pe=bytearray(base)
o_scs=rva2off(pe,pe_secs(pe),0x2be519)
orig=bytes(pe[o_scs:o_scs+8])
P(f"SoftCap_site entry orig={orig.hex()}")
pe[o_scs:o_scs+3]=bytes.fromhex("31c0c3")  # xor eax,eax; ret
host2=cave/"host_scs_ret0.exe"; host2.write_bytes(pe)
sha2=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"scs_ret0 sha12={sha2}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    if time.time()-T0>BUDGET-15: break
    tag=run(host2,src,timeout=8)
    P(f"  scs_ret0/{src:14s} -> {tag}")

# Restore and try: SoftCap_site epi only - replace add rsp/pop/ret with xor eax,eax; ret
# after miss already set eax=0. At @2be90a: 31c0c390909090 (xor; ret; nops) over add rsp (7)+pop(1)+ret(1)=9
P("\n=== plant SoftCap_site epi xor;ret (skip add/pop) ===")
pe3=bytearray(base)
o_epi=rva2off(pe3,pe_secs(pe3),0x2be90a)
P(f"epi orig={bytes(pe3[o_epi:o_epi+9]).hex()}")
pe3[o_epi:o_epi+9]=bytes.fromhex("31c0c39090909090")  # xor eax,eax; ret; nop*5  -- BUT this leaks stack!
# Actually if we ret without add rsp/pop, we return with wrong rsp -> Capless GS.
# Instead: keep proper epi but insert cookie-bypass N/A.
# Try fixing frame: SoftCap_site prol sub rsp,0x150 -> sub rsp,0x200 to cover [rbp+0x110]
P("\n=== plant SoftCap_site sub rsp 0x150 -> 0x1d0 (cover +0x110 home) ===")
pe4=bytearray(base)
# @2be51a: sub rsp, 0x150 = 48 81 ec 50 01 00 00
o_sub=rva2off(pe4,pe_secs(pe4),0x2be51a)
P(f"sub orig={bytes(pe4[o_sub:o_sub+7]).hex()}")
assert bytes(pe4[o_sub:o_sub+7])==bytes.fromhex("4881ec50010000")
# lea rbp,[rsp+0x80] at 2be521 - keep. Need [rbp+0x110] within frame:
# rbp+0x110 < rsp+size => 0x80+0x110 < size => size > 0x190. Use 0x1a0.
pe4[o_sub:o_sub+7]=bytes.fromhex("4881eca0010000")  # sub rsp,0x1a0
# epi add rsp,0x150 -> add rsp,0x1a0
o_add=rva2off(pe4,pe_secs(pe4),0x2be90a)
assert bytes(pe4[o_add:o_add+7])==bytes.fromhex("4881c450010000")
pe4[o_add:o_add+7]=bytes.fromhex("4881c4a0010000")
host4=cave/"host_scs_frame1a0.exe"; host4.write_bytes(pe4)
sha4=hashlib.sha256(bytes(pe4)).hexdigest()[:12]
P(f"scs_frame1a0 sha12={sha4}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    if time.time()-T0>BUDGET-5: break
    tag=run(host4,src,timeout=8)
    P(f"  frame1a0/{src:14s} -> {tag}")

# Also scs_ret0 already ran; summarize
P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_dig_fgs6_*","_tmp_fgs6_*","_var_*.x","host_scs_ret0.exe","host_scs_frame1a0.exe","host_fwd_skip_scs.exe"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
