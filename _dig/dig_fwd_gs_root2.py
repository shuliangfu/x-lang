#!/usr/bin/env python3
"""DIG2 fwd_gs_root: walk Capless_alt @57656c under fwd; find last HIT before GS.
Nail from r1: GS = nested SoftCap sret CallExpr (fw->mk); fwd_nocal/main_bin OK;
call-mk @57ba3b NOT reached on fwd (GS first). Ban tip@121278/join/epi/LIVE/mega/[4b0]=1.
Budget<=85s.
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
    srcp=cave/src
    out=cave/f"_tmp_fgs2_{h.stem}_{srcp.stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    try:
        r=subprocess.run([str(h),str(srcp),"-o",str(out)],capture_output=True,timeout=timeout,cwd=str(cave))
        crc=r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT","-",0
    b=out.read_bytes() if out.exists() else b""
    sh=hashlib.sha256(b).hexdigest()[:12] if b else "-"
    return tag_of(crc),sh,len(b)

# variants
(cave/"_var_fwd.x").write_text("""struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { return mk(x + 1); }
function main(): i32 {
  let w: W = fw(9);
  if (w.a != 10) { return 1; }
  return 0;
}
""", encoding="utf-8")
(cave/"_var_lit.x").write_text("""struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function main(): i32 {
  let w: W = mk(10);
  if (w.a != 10) { return 1; }
  return 0;
}
""", encoding="utf-8")
# nested but only outer SoftCap? fw returns mk via local let then return (like local shape)
(cave/"_var_fwd_let.x").write_text("""struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { let v: W = mk(x + 1); return v; }
function main(): i32 {
  let w: W = fw(9);
  if (w.a != 10) { return 1; }
  return 0;
}
""", encoding="utf-8")
# return-forward of SoftCap result without BinaryExpr
(cave/"_var_fwd_lit_inner.x").write_text("""struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { return mk(10); }
function main(): i32 {
  let w: W = fw(9);
  if (w.a != 10) { return 1; }
  return 0;
}
""", encoding="utf-8")

host=cave/"host_cmk0_irdx_sub20.exe"
assert host.exists()
base=bytearray(host.read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)
P("=== DIG2 fwd_gs_root Capless_alt walk ===")
P(f"host_sub20=3f43f1609d70")

# extra construct checks
P("\n=== extra constructs ===")
for v in ["_var_fwd.x","_var_fwd_let.x","_var_fwd_lit_inner.x","_var_lit.x"]:
    tag,sh,sz=run(host,v,timeout=7)
    P(f"  {v:24s} -> {tag:8s} sha={sh}")

# dump Capless_alt @57656c region
off=rva2off(base,secs,0x57656c)
P("\n=== disasm Capless_alt @57656c +0x200 ===")
insns=list(md.disasm(bytes(base[off:off+0x200]),0x57656c))
for insn in insns[:60]:
    mark=""
    if insn.mnemonic=="call": mark=" CALL"
    if insn.mnemonic.startswith("j"): mark+=" JCC"
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}{mark}")

# INT3 walk every insn in Capless_alt body under fwd (until first AV/GS after HITs, or budget)
P("\n=== INT3 walk @57656c body under fwd ===")
def plant_cc(rva,label):
    pe2=bytearray(base); s=pe_secs(pe2)
    pe2[rva2off(pe2,s,rva)]=0xCC
    out=cave/f"_dig_fgs2_{label}.exe"; out.write_bytes(pe2); return out

last_hit=None; first_bad=None
walked=0
for insn in insns[:50]:
    if time.time()-T0>BUDGET-30: break
    # skip mid-insn risk: only probe insn starts (capstone aligned)
    rva=insn.address
    tag,sh,sz=run(plant_cc(rva,f"w_{rva:x}"),"_var_fwd.x",timeout=5)
    mark=" HIT" if tag=="INT3" else (f" **{tag}**" if tag in("GS","AV") else f" {tag}")
    P(f"  @{rva:06x} {insn.mnemonic:8s} {insn.op_str[:42]:42s} -> {tag}{mark}")
    walked+=1
    if tag=="INT3":
        last_hit=rva
    elif tag in("GS","AV") and last_hit is not None and first_bad is None:
        # continue a bit to see pattern; record first
        first_bad=(rva,tag)
        # don't break immediately - need see if later HITs exist? Actually if GS without INT3,
        # means we didn't reach this insn (crash earlier). So after last_hit, first non-INT3
        # that is GS means crash before this insn OR plant broke encoding.
        # If tag==GS same as unplanted, plant site not reached.
        if tag=="GS":
            P(f"  >> first post-HIT GS/unreached @{rva:#x} after lastHIT @{last_hit:#x}")
            # keep walking a few more HIT candidates that are calls
            break

# Also walk SoftCap-site body @2be519 (fwd HITs entry) - denser call sites
P("\n=== INT3 walk SoftCap_site @2be519 +0x120 under fwd ===")
off2=rva2off(base,secs,0x2be519)
insns2=list(md.disasm(bytes(base[off2:off2+0x120]),0x2be519))
last_hit2=None
for insn in insns2[:35]:
    if time.time()-T0>BUDGET-12: break
    rva=insn.address
    tag,sh,sz=run(plant_cc(rva,f"s_{rva:x}"),"_var_fwd.x",timeout=5)
    mark=" HIT" if tag=="INT3" else f" {tag}"
    P(f"  @{rva:06x} {insn.mnemonic:8s} {insn.op_str[:42]:42s} -> {tag}{mark}")
    if tag=="INT3": last_hit2=rva
    elif tag=="GS" and last_hit2 is not None:
        P(f"  >> SoftCap_site lastHIT @{last_hit2:#x} then GS at probe @{rva:#x}")
        break

# Capless_SoftCapSite @576692 callers/region walk briefly
P("\n=== INT3 sparse Capless @576692..@576700 under fwd/lit ===")
for rva in [0x576692,0x5766a0,0x5766b0,0x5766c0,0x5766d0,0x5766e0,0x5766f0,0x576700,
            0x576710,0x576720,0x576730,0x576740,0x576750,0x576760]:
    if time.time()-T0>BUDGET-5: break
    # align: find insn at/after rva in window
    offx=rva2off(base,secs,0x576692)
    win=list(md.disasm(bytes(base[offx:offx+0x100]),0x576692))
    target=None
    for insn in win:
        if insn.address>=rva:
            target=insn.address; break
    if target is None: continue
    h=plant_cc(target,f"c_{target:x}")
    t_lit,_,_=run(h,"_var_lit.x",timeout=5)
    t_fwd,_,_=run(h,"_var_fwd.x",timeout=5)
    P(f"  @{target:06x} lit={t_lit:8s} fwd={t_fwd:8s}")

P(f"\nlast_hit Capless_alt={last_hit!r} first_bad={first_bad!r} SoftCap last={last_hit2!r}")
P(f"elapsed={time.time()-T0:.1f}s walked={walked}")
for pat in ["_dig_fgs2_*.exe","_tmp_fgs2_*","_var_*.x"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
