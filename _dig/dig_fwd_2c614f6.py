#!/usr/bin/env python3
"""DIG6: verify force SoftCap kind 0x36 USER; dig miss-epi GS; Isol candidate.
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
def tag_of(crc):
    return {0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc&0xFFFFFFFF,f"crc={crc&0xFFFFFFFF:#x}")
def run(h,src,timeout=6):
    out=cave/f"_tmp_f2c6_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    try:
        r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout,cwd=str(cave))
        b=out.read_bytes() if out.exists() else b""
        sh=hashlib.sha256(b).hexdigest()[:12] if b else "-"
        n868=b.count(bytes.fromhex("4881ec68080000")) if b else 0
        # USER marker: look for lit pattern sub20+imm
        has_sub20=b.find(bytes.fromhex("4883ec20"))>=0 if b else False
        return tag_of(r.returncode), sh, n868, has_sub20, out if b else None, b
    except subprocess.TimeoutExpired:
        return "TIMEOUT","-",0,False,None,b""
def run_bin(exe,timeout=4):
    try:
        r=subprocess.run([str(exe)],capture_output=True,timeout=timeout)
        return tag_of(r.returncode), r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT",-1
def save(pe,name):
    p=cave/name; p.write_bytes(bytes(pe)); return p
def u_disasm(buf, rva_base=0xb00, n=40):
    # find .text of USER — naive: disasm from pe entry
    if len(buf)<0x400: return
    secs=pe_secs(buf)
    # try find main-ish: look for sub rsp
    e=struct.unpack_from("<I",buf,0x3C)[0]
    entry_rva=struct.unpack_from("<I",buf,e+0x28)[0]
    try:
        off=rva2off(buf,secs,entry_rva)
    except: return
    insns=list(md.disasm(bytes(buf[off:off+0x80]),entry_rva))
    for insn in insns[:n]:
        P(f"    U {insn.address:06x}: {insn.mnemonic} {insn.op_str}")

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

# baseline host
P("=== baseline cmk0_irdx_sub20 ===")
h0=cave/"host_cmk0_irdx_sub20.exe"
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,n868,sub,outx,b=run(h0,src)
    rt,rc=("-","-")
    if tag=="OK" and outx: rt,rc=run_bin(outx)
    P(f"  base/{src:14s} {tag:8s} sha={sh} n868={n868} sub20={sub} run={rt}/{rc}")

# === A) force SoftCap kind=0x36 (replace call @2be6ca with mov eax,0x36) ===
P("\n=== A force SoftCap kind=0x36 ===")
pe36=bytearray(base)
pe36[rva2off(pe36,secs,0x2be6ca):rva2off(pe36,secs,0x2be6ca)+5]=bytes([0xB8,0x36,0,0,0])
h36=save(pe36,"host_scs_fk36.exe")
P(f"plant sha12={hashlib.sha256(bytes(pe36)).hexdigest()[:12]}")
results={}
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_fwd.x","_var_let.x"]:
    tag,sh,n868,sub,outx,b=run(h36,src)
    rt,rc=("-","-")
    if tag=="OK" and outx: rt,rc=run_bin(outx)
    P(f"  fk36/{src:14s} {tag:8s} sha={sh} n868={n868} sub20={sub} run={rt}/{rc}")
    results[src]=(tag,sh,n868,sub,rt,rc,b)
    if tag=="OK" and b and src in ("p_ret_fwd.x","p_ret_lit.x"):
        P(f"  -- USER head {src} --")
        u_disasm(b)

# === B) force kind=0x30 stay but skip to Capless: SoftCap ret0 AFTER prol (proper frame) ===
# At miss @2be734 already mov eax,0; jmp epi. GS on epi for fwd.
# Try enlarge SoftCap frame 0x150→0x1d0 again + confirm
P("\n=== B SoftCap frame 0x150→0x1d0 + miss path ===")
pe2=bytearray(base)
# sub rsp,0x150 at @2be51a = 48 81 ec 50 01 00 00
o=rva2off(pe2,secs,0x2be51a)
P(f"sub@2be51a={bytes(pe2[o:o+7]).hex()}")
assert bytes(pe2[o:o+7])==bytes.fromhex("4881ec50010000")
pe2[o:o+7]=bytes.fromhex("4881ecd0010000")  # 0x1d0
# also epi add rsp must match
o2=rva2off(pe2,secs,0x2be90a)
P(f"add@2be90a={bytes(pe2[o2:o2+7]).hex()}")
assert bytes(pe2[o2:o2+7])==bytes.fromhex("4881c450010000")
pe2[o2:o2+7]=bytes.fromhex("4881c4d0010000")
h=save(pe2,"host_scs_frame1d0.exe")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,n868,sub,outx,b=run(h,src)
    rt,rc=("-","-")
    if tag=="OK" and outx: rt,rc=run_bin(outx)
    P(f"  frame1d0/{src:14s} {tag:8s} sha={sh} run={rt}/{rc}")

# === C) SoftCap: on kind==0x30, treat as miss but ret via xor;add;pop;ret inline at @2be6d5
# After store kind @2be6cf, cmp 0x36. Plant: cmp eax,0x30 / je to a new fast-ret?
# Simpler Isol: at @2be6d5 (cmp [rbp+0xc4],0x36) also accept 0x30 by changing miss chain.
# Smallest: @2be6d5 cmp imm 0x36 → 0x30, and ensure 0x30 body works — may break lit if lit is 0x36.
P("\n=== C rewrite SoftCap cmp 0x36 → also je for 0x30 (diagnostic) ===")
# At @2be734 miss: instead of epi, we need Capless to continue — miss already returns 0.
# The GS is the problem. Try cookie bypass: nop GS check if any before epi.
# Search security_check_cookie call before epi in SoftCap
off=rva2off(base,secs,0x2be800)
insns=list(md.disasm(bytes(base[off:off+0x120]),0x2be800))
for insn in insns:
    if insn.mnemonic=="call" or "gs" in insn.op_str.lower() or insn.address>=0x2be8e0:
        P(f"  {insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# === D) Capless skip SoftCap call entirely (xor eax at @576692) — known from dig5 ===
P("\n=== D Capless skip SoftCap @576692 (real host) ===")
pe2=bytearray(base)
o=rva2off(pe2,secs,0x576692)
assert pe2[o]==0xE8
pe2[o:o+5]=bytes.fromhex("31c0909090")
h=save(pe2,"host_skip_scs.exe")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x","_var_fwd.x"]:
    tag,sh,n868,sub,outx,b=run(h,src)
    rt,rc=("-","-")
    if tag=="OK" and outx: rt,rc=run_bin(outx)
    P(f"  skip_scs/{src:14s} {tag:8s} sha={sh} n868={n868} sub20={sub} run={rt}/{rc}")

# === E) Combined: skip SoftCap + force30 epi on @2c614f? (fake) — skip
# Instead: skip SoftCap + leave @2c614f natural under return-Call
# Already: skip SoftCap → stub path GS at @2c614f/@20cd98

# === F) Isol candidate: SoftCap kind 0x30 → jmp to kind-3 handler (alias)
# At @2be72b: cmp [rbp+0xc4], 3. Before miss @2be734, insert check for 0x30→treat as 3?
# Space-tight. Alternative: change @2be6d5 from cmp 0x36 to cmp 0x30 so 0x30 takes SoftMega path —
# BREAKS lit if lit needs 0x36.
P("\n=== F lit natural kind (eq probe on lit only via host) ===")
# use fk probe already know lit works with miss (kind not 30?). Check lit kind:
o=rva2off(base,secs,0x2be6cf)
for k in [0x30,0x36,0x33,3,0]:
    pe2=bytearray(base)
    pe2[o:o+6]=bytes([0x83,0xF8,k&0xFF,0x74,0x01,0xCC])
    h=save(pe2,f"_dig_litk_{k:x}.exe")
    tlit=run(h,"p_ret_lit.x")[0]
    tf=run(h,"_var_fwd.x")[0]
    tl=run(h,"_var_let.x")[0]
    P(f"  lit-kind probe k={k:#x} lit={tlit:8s} fwd={tf:8s} let={tl:8s}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_tmp_f2c6_*","_dig_litk_*","_var_*.x","host_scs_fk36.exe","host_scs_frame1d0.exe","host_skip_scs.exe"]:
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
