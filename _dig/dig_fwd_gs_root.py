#!/usr/bin/env python3
"""DIG SoftCap 10.60: fwd_gs_root - nail p_ret_fwd compile GS (0xC0000409).
Prior: cmk0_irdx_sub20 lit green / fwd GS; alt_frame2 alone already lit OK/fwd GS/local OK.
Falsify: call-mk sub20 / imm->rdx alone (already green lit). Ban tip@121278/join/epi/LIVE/mega/[4b0]=1/arg-loop.
Budget<=85s. Win cave.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass
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
def run(h,src,timeout=8):
    srcp = cave/src if not str(src).startswith("C:") and not Path(src).is_absolute() else Path(src)
    if not srcp.is_absolute() and not (cave/src).exists():
        srcp = cave/src
    else:
        srcp = Path(src) if Path(src).is_absolute() else cave/src
    out=cave/f"_tmp_fgs_{h.stem}_{srcp.stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    try:
        r=subprocess.run([str(h),str(srcp),"-o",str(out)],capture_output=True,timeout=timeout,cwd=str(cave))
        crc=r.returncode&0xFFFFFFFF
        err=r.stderr; outb=r.stdout
    except subprocess.TimeoutExpired:
        return "TIMEOUT","-",b"",0,None,b"",b""
    b=out.read_bytes() if out.exists() else b""
    sh=hashlib.sha256(b).hexdigest()[:12] if b else "-"
    n868=b.count(bytes.fromhex("4881ec68080000")) if b else 0
    return tag_of(crc),sh,b,n868,out if b else None,err,outb

alt=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(alt)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(alt)
b828=bytearray(alt)
b828[rva2off(alt,secs,0x24b9c1):rva2off(alt,secs,0x24b9c1)+6]=bytes.fromhex("b82808000090")
host_b828=cave/"host_fgs_b828.exe"; host_b828.write_bytes(b828)
host_sub=cave/"host_cmk0_irdx_sub20.exe"
sha_sub=hashlib.sha256(host_sub.read_bytes()).hexdigest()[:12] if host_sub.exists() else "MISSING"
P("=== DIG fwd_gs_root ===")
P(f"alt_frame2=9378df517f96 host_b828={hashlib.sha256(bytes(b828)).hexdigest()[:12]} host_sub20={sha_sub}")
P("GS=0xC0000409 STATUS_STACK_BUFFER_OVERRUN (cookie/__fastfail)")

VARIANTS={
"lit": """struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function main(): i32 {
  let w: W = mk(10);
  if (w.a != 10) { return 1; }
  if (w.b != 11) { return 2; }
  if (w.c != 12) { return 3; }
  return 0;
}
""",
"fwd": """struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { return mk(x + 1); }
function main(): i32 {
  let w: W = fw(9);
  if (w.a != 10) { return 1; }
  if (w.b != 11) { return 2; }
  if (w.c != 12) { return 3; }
  return 0;
}
""",
"fwd_lit_inner": """struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { return mk(10); }
function main(): i32 {
  let w: W = fw(9);
  if (w.a != 10) { return 1; }
  if (w.b != 11) { return 2; }
  if (w.c != 12) { return 3; }
  return 0;
}
""",
"fwd_pass": """struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { return mk(x); }
function main(): i32 {
  let w: W = fw(10);
  if (w.a != 10) { return 1; }
  if (w.b != 11) { return 2; }
  if (w.c != 12) { return 3; }
  return 0;
}
""",
"main_bin": """struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function main(): i32 {
  let w: W = mk(9 + 1);
  if (w.a != 10) { return 1; }
  if (w.b != 11) { return 2; }
  if (w.c != 12) { return 3; }
  return 0;
}
""",
"two_lit": """struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function main(): i32 {
  let a: W = mk(10);
  let b: W = mk(10);
  if (a.a != 10) { return 1; }
  if (b.a != 10) { return 2; }
  return 0;
}
""",
"fwd_nocal": """struct W { a: i64, b: i64, c: i64 }
function fw(x: i64): W { return W { a: x + 1, b: x + 2, c: x + 3 }; }
function main(): i32 {
  let w: W = fw(9);
  if (w.a != 10) { return 1; }
  if (w.b != 11) { return 2; }
  if (w.c != 12) { return 3; }
  return 0;
}
""",
}
for name,src in VARIANTS.items():
    (cave/f"_var_{name}.x").write_text(src, encoding="utf-8")

hosts=[("b828",host_b828)]
if host_sub.exists():
    hosts.append(("sub20",host_sub))

P("\n=== variant matrix (compile tag) ===")
matrix=[]
for hname,h in hosts:
    if time.time()-T0>BUDGET-25: break
    for vname in ["lit","fwd","fwd_lit_inner","fwd_pass","main_bin","two_lit","fwd_nocal"]:
        if time.time()-T0>BUDGET-20: break
        tag,sh,b,n868,_,_,_=run(h,f"_var_{vname}.x",timeout=7)
        P(f"  {hname:6s}/{vname:14s} -> {tag:8s} sha={sh} n868={n868}")
        matrix.append((hname,vname,tag,sh,n868))

P("\n=== classify ===")
by_v={}
for hname,vname,tag,sh,n868 in matrix:
    by_v.setdefault(vname,[]).append((hname,tag))
for vname,rows in by_v.items():
    tags=sorted(set(t for _,t in rows))
    P(f"  {vname}: {tags} {rows}")

probe_host = host_sub if host_sub.exists() else host_b828
probe_base = bytearray(probe_host.read_bytes())
SITES=[
    (0x57ba3b,"callmk_user_plant"),
    (0x578266,"load_4b0"),
    (0x5752bc,"CapFN_entry"),
    (0x57656c,"Capless_alt"),
    (0x576692,"Capless_SoftCapSite"),
    (0x2be519,"SoftCap_site"),
    (0x59b170,"SoftMega_body"),
    (0x24b49d,"sum_frame"),
    (0x567a30,"get_elem_skipish"),
]
P("\n=== INT3 sites under lit vs fwd ===")
def plant_cc(baseb, rva, label):
    pe2=bytearray(baseb); s=pe_secs(pe2)
    pe2[rva2off(pe2,s,rva)]=0xCC
    out=cave/f"_dig_fgs_{label}.exe"; out.write_bytes(pe2); return out
for rva,lab in SITES:
    if time.time()-T0>BUDGET-8: break
    h=plant_cc(probe_base,rva,f"{lab}_{rva:x}")
    t_lit,_,_,_,_,_,_=run(h,"_var_lit.x",timeout=6)
    t_fwd,_,_,_,_,_,_=run(h,"_var_fwd.x",timeout=6)
    P(f"  @{rva:06x} {lab:22s} lit={t_lit:8s} fwd={t_fwd:8s}")

P("\n=== stock p_ret_* ===")
for hname,h in hosts:
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
        if time.time()-T0>BUDGET-3: break
        if not (cave/src).exists():
            P(f"  missing {src}"); continue
        tag,sh,b,n868,_,_,_=run(h,src,timeout=7)
        P(f"  {hname}/{src:14s} {tag:8s} sha={sh} n868={n868}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_dig_fgs_*.exe","_tmp_fgs_*","_var_*.x"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
