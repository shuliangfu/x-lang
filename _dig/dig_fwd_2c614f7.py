#!/usr/bin/env python3
"""DIG7/plant: SoftCap frame 0x150→0x190 (cover homes rbp+0xe0..0xf8).
Find all add rsp,0x150 in SoftCap; gate lit/fwd/local/let.
Ban tip@121278/join/epi-raise/LIVE/mega/[4b0]=1. Budget<=85s.
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
def off2rva(secs,off):
    for n,(va,vs,ro,rs) in secs.items():
        if ro<=off<ro+max(vs,rs): return va+(off-ro)
    return None
def tag_of(crc):
    return {0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc&0xFFFFFFFF,f"crc={crc&0xFFFFFFFF:#x}")
def run(h,src,timeout=6):
    out=cave/f"_tmp_f2c7_{h.stem}_{Path(src).stem}.exe"
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

# Find all sub rsp,0x150 and add rsp,0x150 in SoftCap range ~0x2be519..0x2be912
SUB=bytes.fromhex("4881ec50010000")
ADD=bytes.fromhex("4881c450010000")
P("=== find sub/add 0x150 near SoftCap ===")
# scan PE .text
text=secs.get(b".text") or secs.get(b"TEXT")
# scan all secs for pattern near SoftCap
hits_sub=[]; hits_add=[]
raw=bytes(base)
start=rva2off(base,secs,0x2be000)
end=rva2off(base,secs,0x2bf000)
idx=start
while True:
    j=raw.find(SUB, idx, end)
    if j<0: break
    hits_sub.append(off2rva(secs,j)); idx=j+1
idx=start
while True:
    j=raw.find(ADD, idx, end)
    if j<0: break
    hits_add.append(off2rva(secs,j)); idx=j+1
P(f"sub rsp,0x150 RVAs: {[hex(x) for x in hits_sub]}")
P(f"add rsp,0x150 RVAs: {[hex(x) for x in hits_add]}")

def plant_frame(new_imm, label):
    pe2=bytearray(base)
    sub_n=bytes([0x48,0x81,0xec])+struct.pack("<I",new_imm)
    add_n=bytes([0x48,0x81,0xc4])+struct.pack("<I",new_imm)
    assert len(sub_n)==7 and len(add_n)==7
    for r in hits_sub:
        pe2[rva2off(pe2,secs,r):rva2off(pe2,secs,r)+7]=sub_n
    for r in hits_add:
        pe2[rva2off(pe2,secs,r):rva2off(pe2,secs,r)+7]=add_n
    h=save(pe2,f"host_scs_frame_{label}.exe")
    sha=hashlib.sha256(bytes(pe2)).hexdigest()[:12]
    P(f"\n=== plant frame 0x{new_imm:x} sha12={sha} ===")
    rows=[]
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x","_var_fwd.x"]:
        if time.time()-T0>BUDGET-10: break
        tag,sh,n868,outx=run(h,src)
        rt,rc=("-","-")
        if tag=="OK" and outx: rt,rc=run_bin(outx)
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} n868={n868} run={rt}/{rc}")
        rows.append((src,tag,sh,n868,rt,rc))
    return sha, rows, h

# Try sizes: 0x180 (min cover 0x178), 0x190 (match @2c614f), 0x1a0 (prior lit OK), 0x1b0
for imm,lab in [(0x180,"180"),(0x190,"190"),(0x1a0,"1a0"),(0x1b0,"1b0")]:
    if time.time()-T0>BUDGET-15: break
    plant_frame(imm, lab)

# Also: only patch SoftCap entry sub @2be51a + epi add @2be90a (not all hits if extras)
P("\n=== plant ONLY entry+epi 0x190 ===")
pe2=bytearray(base)
pe2[rva2off(pe2,secs,0x2be51a):rva2off(pe2,secs,0x2be51a)+7]=bytes.fromhex("4881ec90010000")
pe2[rva2off(pe2,secs,0x2be90a):rva2off(pe2,secs,0x2be90a)+7]=bytes.fromhex("4881c490010000")
h=save(pe2,"host_scs_frame_190_pair.exe")
sha=hashlib.sha256(bytes(pe2)).hexdigest()[:12]
P(f"pair190 sha12={sha}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,n868,outx=run(h,src)
    rt,rc=("-","-")
    if tag=="OK" and outx: rt,rc=run_bin(outx)
    P(f"  pair190/{src:14s} {tag:8s} USER={sh} run={rt}/{rc}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_tmp_f2c7_*","_var_*.x","host_scs_frame_*.exe"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
(cave/"p_ret_fwd.x").write_text(FWD,encoding="utf-8")
P("cleaned")
