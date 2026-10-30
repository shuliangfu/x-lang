#!/usr/bin/env python3
"""DIG7 fwd_scs_epi: SoftCap callers; Capless@12377c vs let path; clean nopr9/noprdx gate.
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
def run(h,src,timeout=5):
    out=cave/f"_tmp_scs7_{h.stem}_{Path(src).stem}.exe"
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
text=secs[b".text"]; raw=bytearray(base[text[2]:text[2]+text[3]]); bva=text[0]

def find_callers(target):
    out=[]
    for i in range(len(raw)-5):
        if raw[i]==0xE8:
            rel=struct.unpack_from("<i",raw,i+1)[0]
            src=bva+i
            if src+5+rel==target: out.append(src)
    return out

scs_callers=find_callers(0x2be519)
P(f"=== SoftCap callers n={len(scs_callers)} {[hex(c) for c in scs_callers]} ===")

# A) SoftCap caller INT3
P("\n=== A SoftCap caller INT3 ===")
for c in scs_callers:
    pe2=bytearray(base); pe2[rva2off(pe2,secs,c)]=0xCC
    h=save(pe2,f"_dig_sc_{c:x}.exe")
    tf,_,_=run(h,"_var_fwd.x"); tl,_,_=run(h,"_var_let.x"); tlit,_,_=run(h,"p_ret_lit.x")
    P(f"  INT3@{c:06x} fwd={tf:8s} let={tl:8s} lit={tlit:8s}")

# B) Capless entry INT3 @57656c
P("\n=== B Capless entry / SoftCap call INT3 ===")
for rva,name in [(0x57656c,"cap_entry"),(0x576692,"cap_call_scs"),(0x12377c,"caller_12377c"),
                 (0x123781,"after_12377c"),(0x270317,"caller_270317")]:
    pe2=bytearray(base); pe2[rva2off(pe2,secs,rva)]=0xCC
    h=save(pe2,f"_dig_x_{rva:x}.exe")
    tf,_,_=run(h,"_var_fwd.x"); tl,_,_=run(h,"_var_let.x"); tlit,_,_=run(h,"p_ret_lit.x")
    P(f"  INT3@{rva:06x} {name:16s} fwd={tf:8s} let={tl:8s} lit={tlit:8s}")

# C) Disasm Capless caller @12377c function start (find push rbp before it)
P("\n=== C caller @12377c context ===")
off=rva2off(base,secs,0x123740)
for insn in md.disasm(bytes(base[off:off+0x80]),0x123740):
    mark=" <<<" if insn.address in (0x12377c,0x123781) else ""
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}{mark}")
    if insn.address>=0x1237a0: break

# Find function containing 12377c — scan back for typical prol
P("\n=== C2 scan back for prol before 12377c ===")
for start in range(0x12377c, 0x12377c-0x200, -1):
    o=rva2off(base,secs,start)
    if base[o]==0x55 and base[o+1]==0x48:  # push rbp
        P(f"  possible prol @{start:#x}")
        for insn in md.disasm(bytes(base[o:o+0x40]),start):
            P(f"    {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
            if insn.address>=start+0x30: break
        break

# D) Clean Isol plants — one at a time, verify sha
def nop_rva(pe, rva):
    pe=bytearray(pe)
    o=rva2off(pe,secs,rva)
    ins=list(md.disasm(bytes(pe[o:o+16]),rva))[0]
    pe[o:o+ins.size]=b"\x90"*ins.size
    return pe, ins

P("\n=== D clean plants gate ===")
# D1 nopr9
pe,ins=nop_rva(base,0x2be53e)
P(f"  nopr9 nop {ins.mnemonic} {ins.op_str} size={ins.size}")
h=save(pe,"host_scs_nopr9.exe")
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"  nopr9 sha12={sha}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x","_var_fwd.x"]:
    tag,sh,outx=run(h,src)
    rt="-";
    if tag=="OK" and outx: rt,_=run_bin(outx)
    P(f"  nopr9/{src:14s} {tag:8s} USER={sh} run={rt}")

# D2 nop only rdx home @2be530
pe,ins=nop_rva(base,0x2be530)
P(f"\n  noprdx nop {ins.mnemonic} {ins.op_str} size={ins.size}")
h=save(pe,"host_scs_noprdx.exe")
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"  noprdx sha12={sha}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,outx=run(h,src)
    rt="-";
    if tag=="OK" and outx: rt,_=run_bin(outx)
    P(f"  noprdx/{src:14s} {tag:8s} USER={sh} run={rt}")
pe3=bytearray(pe); pe3[rva2off(pe3,secs,0x2be911)]=0xCC
h3=save(pe3,"_dig_nrdx_pop.exe")
P(f"  noprdx INT3@pop fwd={run(h3,'_var_fwd.x')[0]} let={run(h3,'_var_let.x')[0]}")

# D3 nop only r8 home @2be537
pe,ins=nop_rva(base,0x2be537)
P(f"\n  nopr8 nop {ins.mnemonic} {ins.op_str} size={ins.size}")
h=save(pe,"host_scs_nopr8.exe")
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"  nopr8 sha12={sha}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,outx=run(h,src)
    rt="-";
    if tag=="OK" and outx: rt,_=run_bin(outx)
    P(f"  nopr8/{src:14s} {tag:8s} USER={sh} run={rt}")
pe3=bytearray(pe); pe3[rva2off(pe3,secs,0x2be911)]=0xCC
h3=save(pe3,"_dig_nr8_pop.exe")
P(f"  nopr8 INT3@pop fwd={run(h3,'_var_fwd.x')[0]} let={run(h3,'_var_let.x')[0]}")

# D4 nopr9 INT3@pop + @2c61c1 confirm
pe,_=nop_rva(base,0x2be53e)
pe3=bytearray(pe); pe3[rva2off(pe3,secs,0x2be911)]=0xCC
h3=save(pe3,"_dig_nr9_pop2.exe")
P(f"\n  nopr9 INT3@pop fwd={run(h3,'_var_fwd.x')[0]} let={run(h3,'_var_let.x')[0]}")
pe3=bytearray(pe); pe3[rva2off(pe3,secs,0x2c61c1)]=0xCC
h3=save(pe3,"_dig_nr9_2c61.exe")
P(f"  nopr9 INT3@2c61c1 fwd={run(h3,'_var_fwd.x')[0]} let={run(h3,'_var_let.x')[0]}")
# Find last HIT after 2c61c1 for nopr9 fwd — probe a few more @2c614f body
P("\n=== E @2c614f body after postkind under nopr9 ===")
off=rva2off(base,secs,0x2c61c0)
insns=[]
for insn in md.disasm(bytes(base[off:off+0x80]),0x2c61c0):
    insns.append(insn)
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x2c6220: break
pe_base_nop,_=nop_rva(base,0x2be53e)
for insn in insns[:12]:
    if time.time()-T0>BUDGET-10: break
    pe2=bytearray(pe_base_nop); pe2[rva2off(pe2,secs,insn.address)]=0xCC
    h2=save(pe2,f"_dig_2c_{insn.address:x}.exe")
    tf,_,_=run(h2,"_var_fwd.x"); tl,_,_=run(h2,"_var_let.x")
    diff=" DIFF" if tf!=tl else ""
    P(f"  nopr9 INT3@{insn.address:06x} fwd={tf:8s} let={tl:8s}{diff}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_dig_sc_*","_dig_x_*","_dig_nrdx_*","_dig_nr8_*","_dig_nr9_*","_dig_2c_*","_tmp_scs7_*","_var_*.x"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
(cave/"p_ret_fwd.x").write_text(FWD,encoding="utf-8")
P("cleaned")
