#!/usr/bin/env python3
"""DIG4 fwd_scs_epi: bisect SoftCap zero-range causing epi GS for return-Call;
test Isol skip-zeros plant vs p_ret_fwd. Ban force-kind/frame/epi-raise/LIVE/mega/[4b0].
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
    out=cave/f"_tmp_scs4_{h.stem}_{Path(src).stem}.exe"
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

def jmp_to_miss_from(pe, rva):
    """Replace insn at rva with jmp @2be734 (miss eax0), nop rest of insn."""
    pe=bytearray(pe)
    o=rva2off(pe,secs,rva)
    ins=list(md.disasm(bytes(pe[o:o+16]),rva))[0]
    pe[o:o+5]=bytes([0xE9])+struct.pack("<i",0x2be734-(rva+5))
    if ins.size>5: pe[o+5:o+ins.size]=b"\x90"*(ins.size-5)
    elif ins.size<5:
        # need at least 5 bytes - only use if next insn can be eaten
        raise ValueError(f"insn too small {ins.size} at {rva:#x}")
    return pe

# Collect SoftCap insn starts from @2be529 to @2be693
off=rva2off(base,secs,0x2be529)
insns=[]
for insn in md.disasm(bytes(base[off:off+0x180]),0x2be529):
    if insn.address>=0x2be693: break
    insns.append(insn)
P(f"=== SoftCap body insns @2be529..@2be693 n={len(insns)} ===")

# Bisect: jmp-to-miss from various points; check SoftCap epi return via INT3@2be911
# and bare fwd/let/lit
checkpoints=[]
for insn in insns:
    # prefer mov [rbp±] zero boundaries
    if insn.mnemonic=="mov" and "[rbp" in insn.op_str and (", 0" in insn.op_str or ",0" in insn.op_str.replace(" ","")):
        checkpoints.append(insn.address)
# also add a few non-zero points
checkpoints = sorted(set(checkpoints + [0x2be529,0x2be545,0x2be56d,0x2be5bd,0x2be63d,0x2be67f,0x2be693]))
P(f"checkpoints={[hex(c) for c in checkpoints]}")

P("\n=== A bisect jmp-miss: SoftCap epi pop INT3 + bare ===")
for rva in checkpoints:
    if time.time()-T0>BUDGET-40: break
    pe2=jmp_to_miss_from(base, rva)
    # bare
    h=save(pe2,f"_dig_jm_{rva:x}.exe")
    tf,_,_,_=run(h,"_var_fwd.x"); tl,_,_,_=run(h,"_var_let.x"); tlit,_,_,_=run(h,"p_ret_lit.x")
    # INT3 at epi pop
    pe3=bytearray(pe2); pe3[rva2off(pe3,secs,0x2be911)]=0xCC
    h3=save(pe3,f"_dig_jm_i_{rva:x}.exe")
    tf3,_,_,_=run(h3,"_var_fwd.x"); tl3,_,_,_=run(h3,"_var_let.x")
    P(f"  miss@{rva:06x} bare fwd={tf:8s} let={tl:8s} lit={tlit:8s} | epi_pop fwd={tf3:8s} let={tl3:8s}")

# B) Isol plant: skip SoftCap zeros that smash — jmp from @2be545 (after arg homes) to @2be693 (cmp args)
# Keep arg homes + kind path; skip zero init of [rbp].. 
P("\n=== B plant skip SoftCap zero-init @2be545→@2be693 ===")
pe2=bytearray(base)
o=rva2off(pe2,secs,0x2be545)
ins=list(md.disasm(bytes(pe2[o:o+16]),0x2be545))[0]
pe2[o:o+5]=bytes([0xE9])+struct.pack("<i",0x2be693-(0x2be545+5))
if ins.size>5: pe2[o+5:o+ins.size]=b"\x90"*(ins.size-5)
h=save(pe2,"host_scs_skipz.exe")
sha=hashlib.sha256(bytes(pe2)).hexdigest()[:12]
P(f"  skipz sha12={sha}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x","_var_fwd.x"]:
    tag,sh,n868,outx=run(h,src)
    rt,rc="-","-"
    if tag=="OK" and outx: rt,rc=run_bin(outx)
    P(f"  skipz/{src:14s} {tag:8s} USER={sh} n868={n868} run={rt}/{rc}")
# epi locus under skipz
pe3=bytearray(pe2); pe3[rva2off(pe3,secs,0x2be911)]=0xCC
h3=save(pe3,"_dig_skipz_pop.exe")
P(f"  skipz INT3@pop fwd={run(h3,'_var_fwd.x')[0]} let={run(h3,'_var_let.x')[0]}")
pe3=bytearray(pe2); pe3[rva2off(pe3,secs,0x576697)]=0xCC
h3=save(pe3,"_dig_skipz_cap.exe")
P(f"  skipz INT3@cap_store fwd={run(h3,'_var_fwd.x')[0]} let={run(h3,'_var_let.x')[0]}")
pe3=bytearray(pe2); pe3[rva2off(pe3,secs,0x2c614f)]=0xCC
h3=save(pe3,"_dig_skipz_2c.exe")
P(f"  skipz INT3@2c614f fwd={run(h3,'_var_fwd.x')[0]} let={run(h3,'_var_let.x')[0]}")

# C) Also try skip only HIGH zeros [rbp+0].. (keep neg locals): jmp @2be5bd → @2be693
P("\n=== C plant skip SoftCap [rbp+] zeros @2be5bd→@2be693 ===")
pe2=bytearray(base)
o=rva2off(pe2,secs,0x2be5bd)
ins=list(md.disasm(bytes(pe2[o:o+16]),0x2be5bd))[0]
pe2[o:o+5]=bytes([0xE9])+struct.pack("<i",0x2be693-(0x2be5bd+5))
if ins.size>5: pe2[o+5:o+ins.size]=b"\x90"*(ins.size-5)
h=save(pe2,"host_scs_skipz_hi.exe")
sha=hashlib.sha256(bytes(pe2)).hexdigest()[:12]
P(f"  skipz_hi sha12={sha}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,n868,outx=run(h,src)
    rt,rc="-","-"
    if tag=="OK" and outx: rt,rc=run_bin(outx)
    P(f"  skipz_hi/{src:14s} {tag:8s} USER={sh} run={rt}/{rc}")
pe3=bytearray(pe2); pe3[rva2off(pe3,secs,0x2be911)]=0xCC
h3=save(pe3,"_dig_szh_pop.exe")
P(f"  skipz_hi INT3@pop fwd={run(h3,'_var_fwd.x')[0]} let={run(h3,'_var_let.x')[0]}")

# D) skip only [rbp+0x80].. high smash near saved: @2be63d→@2be693
P("\n=== D plant skip SoftCap [rbp+0x80..] @2be63d→@2be693 ===")
pe2=bytearray(base)
o=rva2off(pe2,secs,0x2be63d)
ins=list(md.disasm(bytes(pe2[o:o+16]),0x2be63d))[0]
pe2[o:o+5]=bytes([0xE9])+struct.pack("<i",0x2be693-(0x2be63d+5))
if ins.size>5: pe2[o+5:o+ins.size]=b"\x90"*(ins.size-5)
h=save(pe2,"host_scs_skipz_top.exe")
sha=hashlib.sha256(bytes(pe2)).hexdigest()[:12]
P(f"  skipz_top sha12={sha}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,n868,outx=run(h,src)
    rt,rc="-","-"
    if tag=="OK" and outx: rt,rc=run_bin(outx)
    P(f"  skipz_top/{src:14s} {tag:8s} USER={sh} run={rt}/{rc}")
pe3=bytearray(pe2); pe3[rva2off(pe3,secs,0x2be911)]=0xCC
h3=save(pe3,"_dig_szt_pop.exe")
P(f"  skipz_top INT3@pop fwd={run(h3,'_var_fwd.x')[0]} let={run(h3,'_var_let.x')[0]}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_dig_jm_*","_dig_skipz*","_dig_szh_*","_dig_szt_*","_tmp_scs4_*","_var_*.x"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
(cave/"p_ret_fwd.x").write_text(FWD,encoding="utf-8")
P("cleaned")
