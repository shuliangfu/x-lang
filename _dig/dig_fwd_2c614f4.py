#!/usr/bin/env python3
"""DIG4: nail @20cd98 under stub; continue SoftCap_site walk; check force30+epi USER.
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
    out=cave/f"_tmp_f2c4_{h.stem}_{Path(src).stem}.exe"
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
function main(): i32 { let w: W = fw(9); if (w.a != 10) { return 1; } return 0; }
"""
LET="""struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { let v: W = mk(x + 1); return v; }
function main(): i32 { let w: W = fw(9); if (w.a != 10) { return 1; } return 0; }
"""
(cave/"_var_fwd.x").write_text(FWD,encoding="utf-8")
(cave/"_var_let.x").write_text(LET,encoding="utf-8")

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)
stub=bytearray(base)
stub[rva2off(stub,secs,0x2be519):rva2off(stub,secs,0x2be519)+3]=bytes.fromhex("31c0c3")

# === A) force30+epi USER check + skip-kind-only-then-miss-exit ===
P("=== A force30+epi USER + variants ===")
pe2=bytearray(stub)
o=rva2off(pe2,secs,0x2c61bc)
patch=bytes([0xB8,0x30,0,0,0])+bytes.fromhex("8985f4000000")+bytes([0xE9])+struct.pack("<i",0x2c66a0-(0x2c61bc+5+6+5))
pe2[o:o+len(patch)]=patch
h=save(pe2,"host_force30_epi.exe")
for src in ["_var_fwd.x","_var_let.x","p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
    if not (cave/src).exists() and not src.startswith("_"): continue
    tag,sh,n868,outx=run(h,src)
    rt,rc="-","-"
    if tag=="OK" and outx: rt,rc=run_bin(outx)
    P(f"  force30+epi/{src:14s} compile={tag:8s} sha={sh} n868={n868} run={rt}/{rc}")

# A2: skip kind call only (mov eax,0x30), then immediately jmp miss-exit @2c61d9 path via jmp @2c61d9
# @2c61d9: mov eax,0; jmp epi — early miss return 0
pe2=bytearray(stub)
o=rva2off(pe2,secs,0x2c61bc)
# mov eax,0x30 (5B) replaces call; fall into store — instead jmp to @2c61d9
pe2[o:o+5]=bytes([0xE9])+struct.pack("<i",0x2c61d9-(0x2c61bc+5))  # jmp miss
h=save(pe2,"_dig_jmp_miss.exe")
tag,sh,n868,outx=run(h,"_var_fwd.x")
P(f"  jmp_miss_no_kind fwd={tag} sha={sh}")
tag2,_,_,_=run(h,"_var_let.x")
P(f"  jmp_miss_no_kind let={tag2}")

# A3: skip kind: mov eax,0; jmp epi from @2c61bc (5+5 need 10B)
pe2=bytearray(stub)
o=rva2off(pe2,secs,0x2c61bc)
pe2[o:o+10]=bytes([0xB8,0,0,0,0,0xE9])+struct.pack("<i",0x2c66a0-(0x2c61bc+10))
h=save(pe2,"_dig_sk_epi0.exe")
tf,sh,n868,outx=run(h,"_var_fwd.x"); tl,_,_,_=run(h,"_var_let.x")
rt,rc=("-","-")
if tf=="OK" and outx: rt,rc=run_bin(outx)
P(f"  skip_kind+epi0 fwd={tf} let={tl} sha={sh} n868={n868} run={rt}/{rc}")

# === B) INT3 @20cd98 under stub ===
P("\n=== B @20cd98 under stub ===")
off=rva2off(stub,secs,0x20cd98)
insns=list(md.disasm(bytes(stub[off:off+0x100]),0x20cd98))
for insn in insns[:25]:
    mark=" CALL" if insn.mnemonic=="call" else ""
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}{mark}")
# INT3 entry + a few
for rva in [0x20cd98,0x20cd99,0x20cda0,0x20cdb0,0x20cdc0]:
    pe2=bytearray(stub); pe2[rva2off(pe2,pe_secs(pe2),rva)]=0xCC
    h=save(pe2,f"_dig_k_{rva:x}.exe")
    tf,_,_,_=run(h,"_var_fwd.x",); tl,_,_,_=run(h,"_var_let.x")
    # fix run signature - run returns 4-tuple always
P("(re-run INT3 properly)")
for insn in insns[:20]:
    if time.time()-T0>BUDGET-40: break
    pe2=bytearray(stub); pe2[rva2off(pe2,pe_secs(pe2),insn.address)]=0xCC
    h=save(pe2,f"_dig_k_{insn.address:x}.exe")
    tf,_,_,_=run(h,"_var_fwd.x"); tl,_,_,_=run(h,"_var_let.x")
    flag=" DIFF" if tf!=tl else ""
    P(f"  @{insn.address:06x} {insn.mnemonic:8s} {insn.op_str[:40]:40s} fwd={tf:8s} let={tl:8s}{flag}")
    if tf!="INT3" and insn.address>0x20cd98:
        P(f"  >> fwd left INT3 at @{insn.address:#x}")
        break

# === C) SoftCap_site continue walk from @2be6a7 (real host) ===
P("\n=== C SoftCap_site walk from @2be6a0 ===")
off=rva2off(base,secs,0x2be6a0)
insns=list(md.disasm(bytes(base[off:off+0x180]),0x2be6a0))
for insn in insns[:40]:
    mark=""
    if insn.mnemonic=="call": mark=" CALL"
    if insn.mnemonic.startswith("j"): mark+=" J"
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}{mark}")
last_f=None
P("--- INT3 ---")
for insn in insns[:45]:
    if time.time()-T0>BUDGET-8: break
    pe2=bytearray(base); pe2[rva2off(pe2,pe_secs(pe2),insn.address)]=0xCC
    h=save(pe2,f"_dig_scs4_{insn.address:x}.exe")
    tf,_,_,_=run(h,"_var_fwd.x"); tl,_,_,_=run(h,"_var_let.x")
    if tf=="INT3": last_f=insn.address
    flag=" DIFF" if tf!=tl else ""
    if tf!=tl or tf=="INT3" or insn.mnemonic=="call" or tf=="GS":
        P(f"  @{insn.address:06x} {insn.mnemonic:8s} {insn.op_str[:40]:40s} fwd={tf:8s} let={tl:8s}{flag}")
    if last_f and tf=="GS" and insn.address>last_f:
        P(f"  >> last_fwd_HIT @{last_f:#x}; GS at @{insn.address:#x}")
        # don't break immediately — collect a few more DIFFs
P(f"last_fwd_HIT={last_f:#x}" if last_f else "last_fwd_HIT=None")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_dig_jmp_*","_dig_sk_*","_dig_k_*","_dig_scs4_*","_tmp_f2c4_*","_var_*.x","host_force30_epi.exe"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
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
P("cleaned")
