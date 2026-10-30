#!/usr/bin/env python3
"""DIG fwd_2c6174: isomorphic smash @2c6174 / Capless post-2c → caller_after GS.
Find STABLE Isol plant (not nopr9-jitter-as-Isol). Budget<=80s.
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
    out=cave/f"_t74_{h.stem}_{Path(src).stem}.exe"
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
        return tag_of(r.returncode), r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT",-1
def save(pe,name):
    p=cave/name; p.write_bytes(bytes(pe)); return p

# purge temps
for pat in ["_t74_*","_d74_*","_dig_2c*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass

# sources
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

def nop7(pe,rva):
    o=rva2off(pe,secs,rva)
    ins=list(md.disasm(bytes(pe[o:o+16]),rva))[0]
    assert ins.size==7, (hex(rva),ins.size,ins.mnemonic,ins.op_str)
    pe[o:o+7]=b"\x90"*7
    return ins

def retarget7(pe,rva,new_imm32_le):
    """Rewrite mov [rbp+disp32], r9 imm (bytes 3..6) keeping 4c898d prefix."""
    o=rva2off(pe,secs,rva)
    assert bytes(pe[o:o+3])==bytes.fromhex("4c898d"), bytes(pe[o:o+7]).hex()
    pe[o+3:o+7]=struct.pack("<i", new_imm32_le)

P("=== A @2c614f prol / homes / cookie hunt ===")
off=rva2off(base,secs,0x2c614f)
for insn in md.disasm(bytes(base[off:off+0x80]),0x2c614f):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x2c61c8: break

# frame math
P("\n=== B frame math ===")
# SoftCap: push; sub 0x150; lea rbp,[rsp+0x80] → rbp=call_rsp-0xd8; [rbp+0xf8]=call_rsp+0x20
# @2c614f: push; sub 0x190; lea rbp,[rsp+0x80] → rbp=call_rsp-0x118; [rbp+0x138]=call_rsp+0x20
P("  SoftCap [rbp+0xf8] = call_rsp+0x20 = Capless [rsp+0x20]")
P("  @2c614f [rbp+0x138] = call_rsp+0x20 = Capless [rsp+0x20]  (isomorphic)")

# Hunt __security_check_cookie refs near SoftCap / 2c epis
P("\n=== C cookie-call near SoftCap/@2c epis ===")
for start,end,label in [(0x2be8e0,0x2be920,"scs_epi"),(0x2c6670,0x2c66b0,"h2c_epi"),(0x578240,0x5782a0,"cap_epi")]:
    off=rva2off(base,secs,start)
    for insn in md.disasm(bytes(base[off:off+(end-start)]),start):
        if insn.mnemonic=="call" or "gs" in insn.op_str or "security" in insn.op_str:
            P(f"  {label} {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
        if insn.mnemonic in ("xor",) and "rsp" in insn.op_str:
            P(f"  {label} {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")

# Dump full SoftCap epi region
P("\n=== C2 SoftCap epi dump ===")
off=rva2off(base,secs,0x2be8e0)
for insn in md.disasm(bytes(base[off:off+0x50]),0x2be8e0):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x2be920: break

P("\n=== C3 @2c614f epi dump ===")
off=rva2off(base,secs,0x2c6660)
for insn in md.disasm(bytes(base[off:off+0x50]),0x2c6660):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x2c66b0: break

# Capless SoftCap call → after 2c store → epi
P("\n=== D Capless SoftCap-call → post-2c → epi ===")
off=rva2off(base,secs,0x576660)
for insn in md.disasm(bytes(base[off:off+0x120]),0x576660):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x576760: break

P(f"\nelapsed_partial={time.time()-T0:.1f}s")

# Ensure probe sources exist for lit/local too
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
"p_ret_local.x":"""struct W { a: i64, b: i64, c: i64 }
function main(): i32 {
  let w: W = W { a: 1, b: 2, c: 3 };
  if (w.a != 1) { return 1; }
  if (w.b != 2) { return 2; }
  if (w.c != 3) { return 3; }
  return 0;
}
""",
}.items():
    (cave/name).write_text(body,encoding="utf-8")

def plant_dual_nop():
    pe=bytearray(base); nop7(pe,0x2be53e); nop7(pe,0x2c6174); return pe

def plant_scs_nop():
    pe=bytearray(base); nop7(pe,0x2be53e); return pe

def plant_2c_nop():
    pe=bytearray(base); nop7(pe,0x2c6174); return pe

# E) Capless post-2c locus under dual
P("\n=== E dual-nop Capless post-2c locus ===")
pe=plant_dual_nop(); h=save(pe,"_dig_2c_dual.exe")
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"  dual sha={sha}")
# gate
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,outx=run(h,src)
    rt="-";
    if tag=="OK" and outx: rt,_=run_bin(outx)
    P(f"  dual/{src:14s} {tag:8s} USER={sh} run={rt}")

# denser probes between store_2c and Capless return / caller
probes=[
    (0x5766f1,"store_2c"),
    (0x5766f7,"cmp_2c"),
    (0x5766fd,"after_cmp2c"),
    (0x576710,"cap_mid1"),
    (0x576730,"cap_mid2"),
    (0x576750,"cap_mid3"),
    (0x578278,"cap_epi"),
    (0x123781,"caller_after"),
    (0x2be911,"scs_pop"),
    (0x2c66a7,"h2c_pop"),
]
# first dump Capless from 5766f1 to find real labels
P("\n=== E2 Capless @5766f0 dump (find real addrs) ===")
off=rva2off(base,secs,0x5766e0)
addrs=[]
for insn in md.disasm(bytes(base[off:off+0x200]),0x5766e0):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    addrs.append(insn.address)
    if insn.address>=0x5767e0: break

# pick every ~0x10 and key branches for INT3
key=[]
for a in addrs:
    if a in (0x5766f1,0x5766f7) or (a-0x5766f0)%0x10==0:
        key.append(a)
# also find jmp/je/jne targets and ret/epi
off=rva2off(base,secs,0x5766e0)
for insn in md.disasm(bytes(base[off:off+0x200]),0x5766e0):
    if insn.mnemonic in ("jmp","je","jne","ret","call") and insn.address>=0x5766f1:
        key.append(insn.address)
    if insn.address>=0x5767e0: break
key=sorted(set(key))[:18]
P(f"\n=== E3 INT3 probes under dual ({len(key)}) ===")
for rva in key:
    pe2=plant_dual_nop(); pe2[rva2off(pe2,secs,rva)]=0xCC
    h2=save(pe2,f"_d74_{rva:x}.exe")
    tf,_,_=run(h2,"_var_fwd.x"); tl,_,_=run(h2,"_var_let.x")
    P(f"  dual INT3@{rva:06x} fwd={tf:8s} let={tl:8s}")

P(f"\nelapsed={time.time()-T0:.1f}s (part E done)")
