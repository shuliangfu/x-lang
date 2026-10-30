#!/usr/bin/env python3
"""DIG7: under SoftCap_site xor;ret stub, INT3 Capless post @576697 for return-CallExpr GS.
Also probe wrapper @2be40f. Ban tip@121278/join/epi/LIVE/mega/[4b0]=1. Budget<=85s.
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
    out=cave/f"_tmp_fgs7_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    try:
        r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout,cwd=str(cave))
        return tag_of(r.returncode)
    except subprocess.TimeoutExpired:
        return "TIMEOUT"

FWD="""struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { return mk(x + 1); }
function main(): i32 { let w: W = fw(9); if (w.a != 10) { return 1; } return 0; }
"""
LET="""struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { let v: W = mk(x + 1); return v; }
function main(): i32 { let w: W = fw(9); if (w.a != 10) { return 1; } return 0; }
"""
(cave/"_var_fwd.x").write_text(FWD,encoding="utf-8")
(cave/"_var_let.x").write_text(LET,encoding="utf-8")
(cave/"p_ret_fwd.x").write_text(FWD,encoding="utf-8")

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

# stub SoftCap_site
stub=bytearray(base)
stub[rva2off(stub,pe_secs(stub),0x2be519):rva2off(stub,pe_secs(stub),0x2be519)+3]=bytes.fromhex("31c0c3")
host=cave/"host_scs_ret0b.exe"; host.write_bytes(stub)
P("=== DIG7 Capless post SoftCap under scs_ret0 stub ===")
P(f"stub fwd={run(host,'_var_fwd.x')} let={run(host,'_var_let.x')} lit={run(host,'p_ret_lit.x')}")

def plant_cc(hostb, rva):
    pe2=bytearray(hostb); s=pe_secs(pe2)
    pe2[rva2off(pe2,s,rva)]=0xCC
    out=cave/f"_dig_fgs7_{rva:x}.exe"; out.write_bytes(pe2); return out

# Walk Capless from @576692 under stub for fwd vs let
P("\n=== Capless @576692..@576750 stub: fwd vs let ===")
off=rva2off(stub,pe_secs(stub),0x576680)
insns=list(md.disasm(bytes(stub[off:off+0xe0]),0x576680))
last_fwd=None
for insn in insns:
    if insn.address<0x576692: continue
    if insn.address>0x576760: break
    if time.time()-T0>BUDGET-25: break
    t_fwd=run(plant_cc(stub,insn.address),"_var_fwd.x",timeout=5)
    t_let=run(plant_cc(stub,insn.address),"_var_let.x",timeout=5)
    if t_fwd=="INT3": last_fwd=insn.address
    flag=" DIFF" if t_fwd!=t_let else ""
    P(f"  @{insn.address:06x} {insn.mnemonic:8s} {insn.op_str[:40]:40s} fwd={t_fwd:8s} let={t_let:8s}{flag}")

P(f"last_fwd_HIT={last_fwd:#x}" if last_fwd else "last_fwd_HIT=None")

# Wrapper @2be40f disasm + INT3 under fwd/let/lit on REAL host (not stub)
P("\n=== wrapper @2be40f ===")
ow=rva2off(base,secs,0x2be40f)
for insn in list(md.disasm(bytes(base[ow-0x20:ow+0x40]),0x2be40f-0x20))[:30]:
    P(f"  {insn.address:06x}: {insn.mnemonic} {insn.op_str}")
for rva,lab in [(0x2be40f,"wrap_call"),(0x2be400,"pre_wrap")]:
    # align
    pass
t1=run(plant_cc(base,0x2be40f),"_var_fwd.x")
t2=run(plant_cc(base,0x2be40f),"_var_let.x")
t3=run(plant_cc(base,0x2be40f),"p_ret_lit.x")
P(f"  INT3 @2be40f fwd={t1} let={t2} lit={t3}")

# Under REAL host: INT3 Capless @5766ec call 0x2c614f (next after SoftCap) for let vs fwd
P("\n=== REAL host Capless post SoftCap calls ===")
for rva,lab in [(0x576692,"call_scs"),(0x576697,"store_eax"),(0x5766b0,"cmp0"),
                (0x5766c3,"prep"),(0x5766ec,"call_2c614f"),(0x576700,"after")]:
    if time.time()-T0>BUDGET-5: break
    # align to insn
    offc=rva2off(base,secs,0x576690)
    win=list(md.disasm(bytes(base[offc:offc+0x80]),0x576690))
    target=None
    for insn in win:
        if insn.address>=rva:
            target=insn.address; break
    if not target: continue
    tf=run(plant_cc(base,target),"_var_fwd.x")
    tl=run(plant_cc(base,target),"_var_let.x")
    P(f"  @{target:06x} {lab:12s} fwd={tf:8s} let={tl:8s}")

P(f"elapsed={time.time()-T0:.1f}s")
for pat in ["_dig_fgs7_*","_tmp_fgs7_*","_var_*.x","host_scs_ret0b.exe"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
