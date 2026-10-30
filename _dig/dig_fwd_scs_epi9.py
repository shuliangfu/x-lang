#!/usr/bin/env python3
"""DIG9 fwd_scs_epi: clean nopr9 gate alone; Capless-after-2c614f locus; why lit flaky.
Budget<=50s.
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
    out=cave/f"_t9_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    try:
        r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout,cwd=str(cave))
        b=out.read_bytes() if out.exists() else b""
        sh=hashlib.sha256(b).hexdigest()[:12] if b else "-"
        err=(r.stderr or b"")[-200:]
        return tag_of(r.returncode), sh, out if b else None, err
    except subprocess.TimeoutExpired:
        return "TIMEOUT","-",None,b""
def run_bin(exe,timeout=3):
    try:
        r=subprocess.run([str(exe)],capture_output=True,timeout=timeout)
        return tag_of(r.returncode), r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT",-1
def save(pe,name):
    p=cave/name; p.write_bytes(bytes(pe)); return p

# Ensure sources
for name,body in {
"p_ret_lit.x":"""struct W { a: i64, b: i64, c: i64 }
function mk(): W { return W { a: 1, b: 2, c: 3 }; }
function main(): i32 {
  let w: W = mk();
  if (w.a != 1) { return 1; }
  if (w.b != 2) { return 2; }
  if (w.c != 3) { return 3; }
  return 0;
}
""",
"p_ret_fwd.x":"""struct W { a: i64, b: i64, c: i64 }
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
"p_ret_local.x":"""struct W { a: i64, b: i64, c: i64 }
function main(): i32 {
  let w: W = W { a: 1, b: 2, c: 3 };
  if (w.a != 1) { return 1; }
  if (w.b != 2) { return 2; }
  if (w.c != 3) { return 3; }
  return 0;
}
""",
"_var_let.x":"""struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { let v: W = mk(x + 1); return v; }
function main(): i32 {
  let w: W = fw(9);
  if (w.a != 10) { return 1; }
  if (w.b != 11) { return 2; }
  if (w.c != 12) { return 3; }
  return 0;
}
""",
"_var_fwd.x":"""struct W { a: i64, b: i64, c: i64 }
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
}.items():
    (cave/name).write_text(body,encoding="utf-8")

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

def plant_nopr9():
    pe=bytearray(base)
    o=rva2off(pe,secs,0x2be53e)
    pe[o:o+7]=b"\x90"*7
    return pe

# Control: base host gate
P("=== CTRL base host ===")
hb=cave/"host_cmk0_irdx_sub20.exe"
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
    tag,sh,outx,err=run(hb,src)
    rt="-";
    if tag=="OK" and outx: rt,_=run_bin(outx)
    P(f"  base/{src:14s} {tag:8s} USER={sh} run={rt}")

# nopr9 gate x3 for flaky check
P("\n=== nopr9 gate x3 ===")
pe=plant_nopr9()
h=save(pe,"host_scs_nopr9.exe")
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"  sha12={sha}")
for trial in range(3):
    P(f"  -- trial {trial} --")
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
        tag,sh,outx,err=run(h,src)
        rt="-";
        if tag=="OK" and outx: rt,_=run_bin(outx)
        P(f"  {src:14s} {tag:8s} USER={sh} run={rt}")

# Capless after @2c614f under nopr9
P("\n=== Capless after @2c614f under nopr9 ===")
probes=[
    (0x5766f1,"store_2c_eax"),
    (0x5766f7,"cmp_2c"),
    (0x578278,"cap_epi"),
    (0x123781,"caller_after"),
    (0x2be519,"scs_entry"),
    (0x2be911,"scs_pop"),
    (0x2c66a0,"h2c_epi"),
]
for rva,name in probes:
    pe2=plant_nopr9(); pe2[rva2off(pe2,secs,rva)]=0xCC
    h2=save(pe2,f"_d9_{rva:x}.exe")
    tf,_,_,_=run(h2,"_var_fwd.x"); tl,_,_,_=run(h2,"_var_let.x")
    P(f"  INT3@{rva:06x} {name:14s} fwd={tf:8s} let={tl:8s}")

# Capless [rbp+0x460] context
P("\n=== Capless @576616 context ===")
off=rva2off(base,secs,0x5765e0)
for insn in md.disasm(bytes(base[off:off+0xa0]),0x5765e0):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x576670: break

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_d9_*","_t9_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
