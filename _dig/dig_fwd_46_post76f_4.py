#!/usr/bin/env python3
"""DIG fwd_46_post76f #4: confirm Isol plant skip_1a0_calls (s967_99d); save host.
Budget<=60s."""
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
    out=cave/f"_t764_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
def save(pe,name):
    p=cave/name; p.write_bytes(bytes(pe)); return p
def gate(h,label):
    sha=hashlib.sha256(h.read_bytes()).hexdigest()[:12]
    P(f"  [{label}] sha={sha}")
    rows={}
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x","_var_fwd.x"]:
        if not (cave/src).exists(): continue
        tag,sh,outx=run(h,src)
        rt=run_bin(outx) if tag=="OK" and outx else "-"
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}")
        rows[src]=(tag,rt,sh)
    return sha,rows
def skip_call(pe,secs,rva):
    o=rva2off(pe,secs,rva); assert pe[o]==0xE8
    pe[o:o+5]=bytes.fromhex("31c0909090")

for pat in ["_t764_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

P("=== confirm skip_1a0_calls (nop call@46a967 + call@46a99d) ===")
pe=bytearray(base)
skip_call(pe,secs,0x46a967)
skip_call(pe,secs,0x46a99d)
h=save(pe,"host_skip_1a0_calls.exe")
sha,rows=gate(h,"skip_1a0_calls")
assert sha=="79f39a84ead4", sha
assert rows["p_ret_fwd.x"][0]=="OK" and rows["p_ret_fwd.x"][1]=="OK"
assert rows["p_ret_lit.x"][0]=="OK" and rows["p_ret_lit.x"][1]=="OK"
assert rows["p_ret_local.x"][0]=="OK" and rows["p_ret_local.x"][1]=="OK"
P("CONFIRMED green skip_1a0_calls sha=79f39a84ead4")
P(f"elapsed={time.time()-T0:.1f}s")
for p in cave.glob("_t764_*"):
    try: p.unlink()
    except: pass
P("cleaned")
