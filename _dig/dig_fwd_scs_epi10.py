#!/usr/bin/env python3
"""DIG10: restore-correct p_ret_* gate for base + nopr9; Capless-after-2c return GS.
Budget<=45s.
"""
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
    out=cave/f"_t10_{h.stem}_{Path(src).stem}.exe"
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
(cave/"_var_let.x").write_text(LET,encoding="utf-8")
(cave/"_var_fwd.x").write_text(FWD,encoding="utf-8")
P(f"lit head={ (cave/'p_ret_lit.x').read_text(encoding='utf-8')[:80]!r}")

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

def plant_nopr9():
    pe=bytearray(base)
    o=rva2off(pe,secs,0x2be53e)
    pe[o:o+7]=b"\x90"*7
    return pe

P("=== CTRL base ===")
hb=cave/"host_cmk0_irdx_sub20.exe"
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,outx=run(hb,src)
    rt="-";
    if tag=="OK" and outx: rt,_=run_bin(outx)
    P(f"  base/{src:14s} {tag:8s} USER={sh} run={rt}")

P("\n=== nopr9 ===")
pe=plant_nopr9(); h=save(pe,"host_scs_nopr9.exe")
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"  sha12={sha}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x","_var_fwd.x"]:
    tag,sh,outx=run(h,src)
    rt="-";
    if tag=="OK" and outx: rt,_=run_bin(outx)
    P(f"  nopr9/{src:14s} {tag:8s} USER={sh} run={rt}")

# Confirm SoftCap epi + Capless-after-2c
P("\n=== nopr9 locus ===")
for rva,name in [(0x2be911,"scs_pop"),(0x2c66a0,"h2c_epi"),(0x5766f1,"cap_store2c"),(0x576697,"cap_store_scs")]:
    pe2=plant_nopr9(); pe2[rva2off(pe2,secs,rva)]=0xCC
    h2=save(pe2,f"_d10_{rva:x}.exe")
    tf,_,_=run(h2,"_var_fwd.x"); tl,_,_=run(h2,"_var_let.x")
    P(f"  INT3@{rva:06x} {name:14s} fwd={tf:8s} let={tl:8s}")

# @2c614f epi bytes
P("\n=== @2c614f epi ===")
off=rva2off(base,secs,0x2c6690)
for insn in md.disasm(bytes(base[off:off+0x30]),0x2c6690):
    P(f"  {insn.address:06x} size={insn.size} {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x2c66b0: break

P(f"\nelapsed={time.time()-T0:.1f}s")
for p in cave.glob("_d10_*"):
    try: p.unlink()
    except: pass
for p in cave.glob("_t10_*"):
    try: p.unlink()
    except: pass
P("cleaned")
