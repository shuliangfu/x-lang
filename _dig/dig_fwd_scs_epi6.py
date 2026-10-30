#!/usr/bin/env python3
"""DIG6 fwd_scs_epi: nopr9 GS locus; Capless callers via raw E8; try Isol nopr9+@2c614f probe.
Ban force-kind/frame/epi-raise/LIVE/mega/[4b0]. Budget<=85s.
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
    out=cave/f"_tmp_scs6_{h.stem}_{Path(src).stem}.exe"
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

def plant_nopr9(pe):
    pe=bytearray(pe)
    o=rva2off(pe,secs,0x2be53e)
    ins=list(md.disasm(bytes(pe[o:o+16]),0x2be53e))[0]
    pe[o:o+ins.size]=b"\x90"*ins.size
    return pe

def plant_nop239(pe):
    pe=bytearray(pe)
    for rva in (0x2be530,0x2be537,0x2be53e):
        o=rva2off(pe,secs,rva)
        ins=list(md.disasm(bytes(pe[o:o+16]),rva))[0]
        pe[o:o+ins.size]=b"\x90"*ins.size
    return pe

# Find Capless callers via raw E8 rel32
text=secs[b".text"]; raw=bytearray(base[text[2]:text[2]+text[3]]); bva=text[0]
callers=[]
target=0x57656c
for i in range(len(raw)-5):
    if raw[i]==0xE8:
        rel=struct.unpack_from("<i",raw,i+1)[0]
        src=bva+i
        if src+5+rel==target:
            callers.append(src)
P(f"=== Capless callers raw n={len(callers)} {[hex(c) for c in callers]} ===")

# A) Capless caller INT3 under BASE
P("\n=== A Capless caller INT3 (base) ===")
for c in callers:
    if time.time()-T0>BUDGET-60: break
    pe2=bytearray(base); pe2[rva2off(pe2,secs,c)]=0xCC
    h=save(pe2,f"_dig_cc_{c:x}.exe")
    tf,_,_=run(h,"_var_fwd.x"); tl,_,_=run(h,"_var_let.x"); tlit,_,_=run(h,"p_ret_lit.x")
    diff=" DIFF" if (tf=="INT3")!=(tl=="INT3") else ""
    if tf=="INT3" or tl=="INT3" or tlit=="INT3":
        P(f"  HIT INT3@{c:06x} fwd={tf:8s} let={tl:8s} lit={tlit:8s}{diff}")
    else:
        P(f"  miss INT3@{c:06x} fwd={tf:8s} let={tl:8s} lit={tlit:8s}")

# B) nopr9 GS locus
P("\n=== B nopr9 GS locus ===")
pe=plant_nopr9(base)
h=save(pe,"host_scs_nopr9.exe")
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"  nopr9 sha12={sha}")
probes=[
    (0x2be90a,"scs_epi_add"),
    (0x2be911,"scs_epi_pop"),
    (0x576697,"cap_store"),
    (0x5766b0,"cap_cmp0"),
    (0x5766c3,"cap_prep2c"),
    (0x5766ec,"cap_call_2c"),
    (0x2c614f,"helper_2c"),
    (0x2c61c1,"helper_postkind"),
    (0x20cd98,"kind20cd"),
]
for rva,name in probes:
    if time.time()-T0>BUDGET-35: break
    pe2=plant_nopr9(base); pe2[rva2off(pe2,secs,rva)]=0xCC
    h2=save(pe2,f"_dig_nr9_{rva:x}.exe")
    tf,_,_=run(h2,"_var_fwd.x"); tl,_,_=run(h2,"_var_let.x")
    diff=" DIFF" if tf!=tl else ""
    P(f"  nopr9 INT3@{rva:06x} {name:16s} fwd={tf:8s} let={tl:8s}{diff}")

# C) nop239 GS locus (SoftCap returns; where fwd GS?)
P("\n=== C nop239 GS locus ===")
pe=plant_nop239(base)
h=save(pe,"host_scs_nop239.exe")
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"  nop239 sha12={sha}")
for rva,name in probes:
    if time.time()-T0>BUDGET-20: break
    pe2=plant_nop239(base); pe2[rva2off(pe2,secs,rva)]=0xCC
    h2=save(pe2,f"_dig_n239_{rva:x}.exe")
    tf,_,_=run(h2,"_var_fwd.x"); tl,_,_=run(h2,"_var_let.x")
    diff=" DIFF" if tf!=tl else ""
    P(f"  nop239 INT3@{rva:06x} {name:16s} fwd={tf:8s} let={tl:8s}{diff}")

# D) Why r9 home smashes SoftCap epi for fwd: Capless [rbp+0x460] value?
# SoftCap r9 home writes Capless[rsp+0x20]. Capless just put [4b0] there.
# After SoftCap overwrites with r9, SoftCap continues. Does SoftCap READ [rbp+0x100]
# (=call_rsp+0x28 = Capless[rsp+0x28]) as 5th arg before miss?
# SoftCap 5th arg home would be at [rbp+0x100]. Does SoftCap store 5th arg?
P("\n=== D SoftCap 5th-arg / [rbp+0x100] stores before miss ===")
off=rva2off(base,secs,0x2be519)
for insn in md.disasm(bytes(base[off:off+0x220]),0x2be519):
    if "0x100" in insn.op_str or "0x108" in insn.op_str or "0x110" in insn.op_str:
        P(f"  {insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    if insn.address>=0x2be734: break

# E) Capless [rbp+0x460] — what is it? Disasm Capless stores to +0x460
P("\n=== E Capless writes to [rbp+0x460] ===")
off=rva2off(base,secs,0x57656c)
for insn in md.disasm(bytes(base[off:off+0x150]),0x57656c):
    if "0x460" in insn.op_str or insn.address in (0x576669,0x576692):
        P(f"  {insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    if insn.address>=0x5766a0: break

# F) Persist nopr9 as candidate Isol + full gate
P("\n=== F nopr9 full gate ===")
pe=plant_nopr9(base)
h=save(pe,"host_scs_nopr9.exe")
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"  host_scs_nopr9 sha12={sha}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x","_var_fwd.x"]:
    tag,sh,outx=run(h,src)
    rt,rc="-","-"
    if tag=="OK" and outx: rt,rc=run_bin(outx)
    P(f"  nopr9/{src:14s} {tag:8s} USER={sh} run={rt}/{rc}")

# G) Also try: SoftCap r9 home write to SoftCap-local [rbp-0x50] INSTEAD of [rbp+0xf8]
# so kind-hit paths that read [rbp+0xf8] break — lit uses miss so OK?
# Better Isol: Capless don't put live data that SoftCap r9 smash hurts SoftCap itself.
# Real root: SoftCap [rbp+0xf8]=call_rsp+0x20. Writing r9 there. Why GS?
# Hypothesis: for fwd Capless_rsp is 16-byte unaligned / SoftCap frame cookie elsewhere.
# Check SoftCap for security_cookie reference
P("\n=== G SoftCap cookie xref ===")
# MSVC cookie typically xor with rsp at prol and check at epi. SoftCap has neither.
# GS 0xC0000409 can also be CFG / EH / other fastfail.
# Try: SoftCap r9 home → write to [rbp+0xb0] (in SoftCap zero range, within own frame)
pe2=bytearray(base)
o=rva2off(pe2,secs,0x2be53e)
# mov qword [rbp+0xf8], r9 = 48 89 8D F8 00 00 00 — change disp to 0xb0
# 48 89 8D B0 00 00 00
raw=bytes(base[o:o+7])
P(f"  raw r9home={raw.hex()}")
if raw==bytes.fromhex("48898df8000000"):
    pe2[o:o+7]=bytes.fromhex("48898db0000000")  # [rbp+0xb0]
    h=save(pe2,"host_scs_r9tob0.exe")
    sha=hashlib.sha256(bytes(pe2)).hexdigest()[:12]
    P(f"  r9tob0 sha12={sha}")
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
        tag,sh,outx=run(h,src)
        rt="-";
        if tag=="OK" and outx: rt,_=run_bin(outx)
        P(f"  r9tob0/{src:14s} {tag:8s} USER={sh} run={rt}")
    pe3=bytearray(pe2); pe3[rva2off(pe3,secs,0x2be911)]=0xCC
    h3=save(pe3,"_dig_r9b0_pop.exe")
    P(f"  r9tob0 INT3@pop fwd={run(h3,'_var_fwd.x')[0]} let={run(h3,'_var_let.x')[0]}")
else:
    P(f"  unexpected encoding, skip r9tob0")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_dig_cc_*","_dig_nr9_*","_dig_n239_*","_dig_r9b0_*","_tmp_scs6_*","_var_*.x"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
(cave/"p_ret_fwd.x").write_text(FWD,encoding="utf-8")
# KEEP host_scs_nopr9.exe and host_scs_nop239.exe and host_scs_r9tob0.exe on cave for Isol
P("cleaned temps; kept host_scs_nopr9/nop239/r9tob0")
