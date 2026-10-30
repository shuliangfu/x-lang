#!/usr/bin/env python3
"""DIG3 fwd_gs_root: SoftCap_site deep walk under return-CallExpr GS.
Nail r2: return mk(...) GS; let v=mk(...); return v OK; GS after call @576692
inside SoftCap_site (post +0x120). Ban tip@121278/join/epi/LIVE/mega/[4b0]=1.
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
def run(h,src,timeout=5):
    srcp=cave/src
    out=cave/f"_tmp_fgs3_{h.stem}_{srcp.stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    try:
        r=subprocess.run([str(h),str(srcp),"-o",str(out)],capture_output=True,timeout=timeout,cwd=str(cave))
        crc=r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT"
    return tag_of(crc)

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
(cave/"_var_lit.x").write_text("""struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function main(): i32 { let w: W = mk(10); if (w.a != 10) { return 1; } return 0; }
""", encoding="utf-8")

host=cave/"host_cmk0_irdx_sub20.exe"
base=bytearray(host.read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)
P("=== DIG3 SoftCap_site deep under return-CallExpr ===")

def plant_cc(rva):
    pe2=bytearray(base); s=pe_secs(pe2)
    pe2[rva2off(pe2,s,rva)]=0xCC
    out=cave/f"_dig_fgs3_{rva:x}.exe"; out.write_bytes(pe2); return out

# disasm SoftCap_site more
off=rva2off(base,secs,0x2be519)
insns=list(md.disasm(bytes(base[off:off+0x400]),0x2be519))
P(f"SoftCap_site insns={len(insns)} in +0x400")
# print calls and important branches
P("--- calls/jcc in SoftCap_site ---")
for insn in insns:
    if insn.mnemonic=="call" or insn.mnemonic.startswith("j") or insn.mnemonic in("ret","int3"):
        P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")

# Walk from +0x100 onward under fwd until GS-after-HIT
P("\n=== INT3 walk SoftCap_site from +0x100 (fwd) ===")
start_i=0
for i,insn in enumerate(insns):
    if insn.address>=0x2be519+0x100:
        start_i=i; break
last_hit=None
gs_sites=[]
for insn in insns[start_i:start_i+80]:
    if time.time()-T0>BUDGET-35: break
    rva=insn.address
    tag=run(plant_cc(rva),"_var_fwd.x",timeout=5)
    mark=" HIT" if tag=="INT3" else f" {tag}"
    P(f"  @{rva:06x} {insn.mnemonic:8s} {insn.op_str[:44]:44s} -> {tag}{mark}")
    if tag=="INT3":
        last_hit=rva
    elif tag=="GS":
        gs_sites.append(rva)
        if last_hit is not None and len(gs_sites)>=1:
            # check if this is unreached (expected) - keep going only for CALLs after last_hit
            if insn.mnemonic=="call" or True:
                P(f"  >> lastHIT @{last_hit:#x}; GS-probe @{rva:#x} ({insn.mnemonic})")
                # don't break on first GS (many unreached); break when we have a call that GS after HIT streak ends
                if insn.mnemonic=="call":
                    break
                # if we've seen 3 consecutive GS after a HIT, stop
                if len(gs_sites)>=3 and all(True for _ in gs_sites[-3:]):
                    # check last 3 probes were all GS
                    break

# Differential: same probes under let (OK) vs fwd (GS) for key SoftCap_site calls
P("\n=== SoftCap_site CALL sites: lit/let/fwd ===")
calls=[insn for insn in insns if insn.mnemonic=="call"]
P(f"n_calls={len(calls)}")
for insn in calls[:25]:
    if time.time()-T0>BUDGET-10: break
    rva=insn.address
    t_lit=run(plant_cc(rva),"_var_lit.x",timeout=5)
    t_let=run(plant_cc(rva),"_var_let.x",timeout=5)
    t_fwd=run(plant_cc(rva),"_var_fwd.x",timeout=5)
    flag=""
    if t_fwd!=t_let: flag=" DIFF_let"
    if t_fwd!=t_lit: flag+=" DIFF_lit"
    P(f"  @{rva:06x} call {insn.op_str:20s} lit={t_lit:8s} let={t_let:8s} fwd={t_fwd:8s}{flag}")

# Also probe Capless after SoftCap return value use - @576697 store and beyond under let vs fwd
P("\n=== Capless post SoftCap_site call: let vs fwd ===")
post=[0x576692,0x576697,0x57669d,0x5766a4,0x5766a6,0x5766ab,0x5766b0]
# re-disasm to align
offc=rva2off(base,secs,0x576690)
wins=list(md.disasm(bytes(base[offc:offc+0x80]),0x576690))
for insn in wins[:20]:
    if time.time()-T0>BUDGET-3: break
    rva=insn.address
    t_let=run(plant_cc(rva),"_var_let.x",timeout=5)
    t_fwd=run(plant_cc(rva),"_var_fwd.x",timeout=5)
    flag=" DIFF" if t_let!=t_fwd else ""
    P(f"  @{rva:06x} {insn.mnemonic:8s} {insn.op_str[:40]:40s} let={t_let:8s} fwd={t_fwd:8s}{flag}")

P(f"\nlast_hit={last_hit!r} elapsed={time.time()-T0:.1f}s")
for pat in ["_dig_fgs3_*.exe","_tmp_fgs3_*","_var_*.x"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
