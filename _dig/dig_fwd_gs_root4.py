#!/usr/bin/env python3
"""DIG4 fwd_gs_root: SoftCap_site @2be6fb.. last HIT before GS on return-CallExpr.
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
def run(h,src,timeout=5):
    srcp=cave/src
    out=cave/f"_tmp_fgs4_{h.stem}_{srcp.stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    try:
        r=subprocess.run([str(h),str(srcp),"-o",str(out)],capture_output=True,timeout=timeout,cwd=str(cave))
        return tag_of(r.returncode)
    except subprocess.TimeoutExpired:
        return "TIMEOUT"

(cave/"_var_fwd.x").write_text("""struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { return mk(x + 1); }
function main(): i32 { let w: W = fw(9); if (w.a != 10) { return 1; } return 0; }
""", encoding="utf-8")
(cave/"_var_let.x").write_text("""struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { let v: W = mk(x + 1); return v; }
function main(): i32 { let w: W = fw(9); if (w.a != 10) { return 1; } return 0; }
""", encoding="utf-8")

host=cave/"host_cmk0_irdx_sub20.exe"
base=bytearray(host.read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

def plant_cc(rva):
    pe2=bytearray(base); s=pe_secs(pe2)
    pe2[rva2off(pe2,s,rva)]=0xCC
    out=cave/f"_dig_fgs4_{rva:x}.exe"; out.write_bytes(pe2); return out

off=rva2off(base,secs,0x2be519)
insns=list(md.disasm(bytes(base[off:off+0x400]),0x2be519))
P("=== DIG4 SoftCap_site @2be6fb.. under fwd/let ===")
P("\n--- disasm @2be6dc..@2be920 ---")
for insn in insns:
    if 0x2be6dc <= insn.address <= 0x2be920:
        P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")

P("\n=== INT3 every insn @2be6fb..@2be920 fwd vs let ===")
last_hit_fwd=None; last_hit_let=None
first_gs_after=None
for insn in insns:
    if insn.address < 0x2be6fb: continue
    if insn.address > 0x2be920: break
    if time.time()-T0>BUDGET-8: break
    rva=insn.address
    t_fwd=run(plant_cc(rva),"_var_fwd.x",timeout=5)
    t_let=run(plant_cc(rva),"_var_let.x",timeout=5)
    if t_fwd=="INT3": last_hit_fwd=rva
    if t_let=="INT3": last_hit_let=rva
    if t_fwd=="GS" and last_hit_fwd and first_gs_after is None and rva>last_hit_fwd:
        first_gs_after=rva
    flag=""
    if t_fwd!=t_let: flag=" DIFF"
    P(f"  @{rva:06x} {insn.mnemonic:8s} {insn.op_str[:40]:40s} fwd={t_fwd:8s} let={t_let:8s}{flag}")

P(f"\nlast_hit_fwd={last_hit_fwd:#x}" if last_hit_fwd else "\nlast_hit_fwd=None")
P(f"last_hit_let={last_hit_let:#x}" if last_hit_let else "last_hit_let=None")
P(f"first_gs_after_hit={first_gs_after:#x}" if first_gs_after else "first_gs_after=None")

# Confirm baseline
P("\n=== baseline confirm ===")
P(f"  fwd unplanted -> {run(host,'_var_fwd.x')}")
P(f"  let unplanted -> {run(host,'_var_let.x')}")

P(f"elapsed={time.time()-T0:.1f}s")
for pat in ["_dig_fgs4_*.exe","_tmp_fgs4_*","_var_*.x"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
