#!/usr/bin/env python3
"""DIG13: stable nopr9/r9b0 re-gate x5; kill interference. Budget<=50s."""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
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
    out=cave/f"_t13_{Path(src).stem}.exe"
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

# purge temp hosts
for p in cave.glob("_dig_*.exe"):
    try: p.unlink()
    except: pass
for p in cave.glob("_t*.exe"):
    try: p.unlink()
    except: pass
for p in cave.glob("_d*.exe"):
    try: p.unlink()
    except: pass

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)
o=rva2off(base,secs,0x2be53e)
assert bytes(base[o:o+7])==bytes.fromhex("4c898df8000000")

def rebuild_nopr9():
    pe=bytearray(base); pe[o:o+7]=b"\x90"*7
    p=cave/"host_scs_nopr9.exe"; p.write_bytes(bytes(pe))
    return p, hashlib.sha256(bytes(pe)).hexdigest()[:12]

def rebuild_r9b0():
    pe=bytearray(base); pe[o:o+7]=bytes.fromhex("4c898db0000000")
    p=cave/"host_scs_r9b0.exe"; p.write_bytes(bytes(pe))
    return p, hashlib.sha256(bytes(pe)).hexdigest()[:12]

P("=== base ctrl ===")
hb=cave/"host_cmk0_irdx_sub20.exe"
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
    tag,sh,outx=run(hb,src)
    rt=run_bin(outx) if tag=="OK" and outx else "-"
    P(f"  base/{src:14s} {tag:8s} USER={sh} run={rt}")

h,sha=rebuild_nopr9()
P(f"\n=== nopr9 sha={sha} x3 ===")
for i in range(3):
    h,_=rebuild_nopr9()  # fresh write each trial
    row=[]
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
        tag,sh,outx=run(h,src)
        rt=run_bin(outx) if tag=="OK" and outx else "-"
        row.append(f"{Path(src).stem}:{tag}/{rt}")
    P(f"  t{i}: {' | '.join(row)}")

h,sha=rebuild_r9b0()
P(f"\n=== r9b0 sha={sha} x2 ===")
for i in range(2):
    h,_=rebuild_r9b0()
    row=[]
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
        tag,sh,outx=run(h,src)
        rt=run_bin(outx) if tag=="OK" and outx else "-"
        row.append(f"{Path(src).stem}:{tag}/{rt}")
    P(f"  t{i}: {' | '.join(row)}")

# SoftCap epi under nopr9
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
pe=bytearray(base); pe[o:o+7]=b"\x90"*7
pe[rva2off(pe,secs,0x2be911)]=0xCC
p=cave/"_t13_pop.exe"; p.write_bytes(bytes(pe))
(cave/"_var_fwd.x").write_text(Path("p_ret_fwd.x").read_text(encoding="utf-8"),encoding="utf-8")
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
(cave/"_var_let.x").write_text(LET,encoding="utf-8")
tf,_,_=run(p,"_var_fwd.x"); tl,_,_=run(p,"_var_let.x")
P(f"\nnopr9 INT3@scs_pop fwd={tf} let={tl}")
# base control pop
pe=bytearray(base); pe[rva2off(pe,secs,0x2be911)]=0xCC
p=cave/"_t13_bpop.exe"; p.write_bytes(bytes(pe))
tf,_,_=run(p,"_var_fwd.x"); tl,_,_=run(p,"_var_let.x")
P(f"base  INT3@scs_pop fwd={tf} let={tl}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for p in list(cave.glob("_t13_*")):
    try: p.unlink()
    except: pass
P("cleaned")
