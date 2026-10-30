#!/usr/bin/env python3
"""DIG8 fwd_scs_epi: pin nopr9 GS after @2c61c7 kind==0x30; Capless [rbp+0x460] source.
Ban force-kind/frame/epi-raise/LIVE/mega/[4b0]. Budget<=60s.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64)
cave = Path("C:/xlang_tmp/p1060/cave"); os.chdir(str(cave))
T0=time.time(); BUDGET=60
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
    out=cave/f"_tmp_scs8_{h.stem}_{Path(src).stem}.exe"
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

def plant_nopr9(pe=base):
    pe=bytearray(pe)
    o=rva2off(pe,secs,0x2be53e)
    ins=list(md.disasm(bytes(pe[o:o+16]),0x2be53e))[0]
    assert ins.size==7
    pe[o:o+7]=b"\x90"*7
    return pe

# A) nopr9 locus at correct @2c61xx addrs
P("=== A nopr9 @2c614f kind-0x30 path ===")
probes=[
    (0x2c61c1,"store_kind"),
    (0x2c61c7,"cmp_30"),
    (0x2c61ce,"je_30"),
    (0x2c61d0,"cmp_31"),
    (0x2c61e3,"join_0x30"),
    (0x2c61ea,"sete_31"),
    (0x2c61f6,"cmp_f0"),
    (0x2c61fd,"je_not31"),
    (0x2c621c,"path_30_body"),
    (0x2c622c,"call_1ff2ef"),
    (0x2c6231,"store_f8"),
    (0x2c66a0,"epi_2c"),
]
for rva,name in probes:
    pe2=plant_nopr9(); pe2[rva2off(pe2,secs,rva)]=0xCC
    h=save(pe2,f"_dig_p_{rva:x}.exe")
    tf,_,_=run(h,"_var_fwd.x"); tl,_,_=run(h,"_var_let.x")
    diff=" DIFF" if tf!=tl else ""
    P(f"  INT3@{rva:06x} {name:14s} fwd={tf:8s} let={tl:8s}{diff}")

# B) Capless [rbp+0x460] writes — scan Capless function
P("\n=== B Capless [rbp+0x460] stores/loads ===")
off=rva2off(base,secs,0x57656c)
for insn in md.disasm(bytes(base[off:off+0x200]),0x57656c):
    if "0x460" in insn.op_str:
        P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x576700: break

# C) Final nopr9 gate + sha persist
P("\n=== C final nopr9 gate ===")
pe=plant_nopr9()
h=save(pe,"host_scs_nopr9.exe")
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"  sha12={sha}")
assert sha=="f52f77a7ffb1"
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
    tag,sh,outx=run(h,src)
    rt,rc="-","-"
    if tag=="OK" and outx: rt,rc=run_bin(outx)
    P(f"  {src:14s} compile={tag:8s} USER={sh} run={rt}/{rc}")
# epi align confirm
pe3=plant_nopr9(); pe3[rva2off(pe3,secs,0x2be911)]=0xCC
h3=save(pe3,"_dig_pop.exe")
P(f"  INT3@scs_pop fwd={run(h3,'_var_fwd.x')[0]} let={run(h3,'_var_let.x')[0]}")

# D) BASE (no nopr9) confirm SoftCap epi still GS for fwd
P("\n=== D base SoftCap epi (control) ===")
pe2=bytearray(base); pe2[rva2off(pe2,secs,0x2be911)]=0xCC
h=save(pe2,"_dig_base_pop.exe")
P(f"  base INT3@scs_pop fwd={run(h,'_var_fwd.x')[0]} let={run(h,'_var_let.x')[0]}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_dig_p_*","_dig_pop*","_dig_base_*","_tmp_scs8_*","_var_*.x"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
(cave/"p_ret_fwd.x").write_text(FWD,encoding="utf-8")
P("cleaned; kept host_scs_nopr9.exe")
