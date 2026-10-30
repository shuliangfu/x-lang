#!/usr/bin/env python3
"""DIG8: disasm @2c614f; INT3 walk first window under return-CallExpr (scs_ret0 stub).
Budget<=60s. Ban tip@121278/join/epi/LIVE/mega/[4b0]=1.
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
    out=cave/f"_tmp_fgs8_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    try:
        r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout,cwd=str(cave))
        return tag_of(r.returncode)
    except subprocess.TimeoutExpired:
        return "TIMEOUT"

(cave/"_var_fwd.x").write_text("""struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { return mk(x + 1); }
function main(): i32 { let w: W = fw(9); if (w.a != 10) { return 1; } return 0; }
""",encoding="utf-8")
(cave/"_var_let.x").write_text("""struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { let v: W = mk(x + 1); return v; }
function main(): i32 { let w: W = fw(9); if (w.a != 10) { return 1; } return 0; }
""",encoding="utf-8")

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
stub=bytearray(base)
stub[rva2off(stub,pe_secs(stub),0x2be519):rva2off(stub,pe_secs(stub),0x2be519)+3]=bytes.fromhex("31c0c3")
host=cave/"host_scs_ret0c.exe"; host.write_bytes(stub)
secs=pe_secs(stub)

P("=== DIG8 @2c614f under scs_ret0 ===")
off=rva2off(stub,secs,0x2c614f)
P("--- prol ---")
insns=list(md.disasm(bytes(stub[off:off+0x180]),0x2c614f))
for insn in insns[:40]:
    mark=""
    if insn.mnemonic=="call": mark=" CALL"
    if insn.mnemonic.startswith("j"): mark+=" J"
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}{mark}")

def plant_cc(rva):
    pe2=bytearray(stub); s=pe_secs(pe2)
    pe2[rva2off(pe2,s,rva)]=0xCC
    out=cave/f"_dig_fgs8_{rva:x}.exe"; out.write_bytes(pe2); return out

P("\n=== INT3 walk @2c614f first 35 insn fwd/let ===")
last=None
for insn in insns[:35]:
    if time.time()-T0>BUDGET-5: break
    tf=run(plant_cc(insn.address),"_var_fwd.x")
    tl=run(plant_cc(insn.address),"_var_let.x")
    if tf=="INT3": last=insn.address
    flag=" DIFF" if tf!=tl else ""
    P(f"  @{insn.address:06x} {insn.mnemonic:8s} {insn.op_str[:40]:40s} fwd={tf:8s} let={tl:8s}{flag}")
    if tf=="GS" and last and insn.address>last and insn.mnemonic=="call":
        P(f"  >> lastHIT @{last:#x} GS at call @{insn.address:#x}")
        break
P(f"last_HIT={last:#x}" if last else "last_HIT=None")
P(f"elapsed={time.time()-T0:.1f}s")
for pat in ["_dig_fgs8_*","_tmp_fgs8_*","_var_*.x","host_scs_ret0c.exe"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
# restore p_ret_fwd
(cave/"p_ret_fwd.x").write_text("""struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { return mk(x + 1); }
function main(): i32 {
  let w: W = fw(9);
  if (w.a != 10) { return 1; }
  if (w.b != 11) { return 2; }
  if (w.c != 12) { return 3; }
  return 0;
}
""",encoding="utf-8")
P("cleaned+restored p_ret_fwd")
