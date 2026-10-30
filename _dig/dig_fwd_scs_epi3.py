#!/usr/bin/env python3
"""DIG3 fwd_scs_epi: locate GS under postlea_miss; Capless caller diff return-Call vs let;
Isol plant candidates. Ban force-kind/frame/epi-raise/LIVE/mega/[4b0]. Budget<=85s.
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
    out=cave/f"_tmp_scs3_{h.stem}_{Path(src).stem}.exe"
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

def plant_postlea(pe):
    pe=bytearray(pe)
    o=rva2off(pe,secs,0x2be529)
    ins=list(md.disasm(bytes(pe[o:o+16]),0x2be529))[0]
    pe[o:o+5]=bytes([0xE9])+struct.pack("<i",0x2be734-(0x2be529+5))
    if ins.size>5: pe[o+5:o+ins.size]=b"\x90"*(ins.size-5)
    return pe

# A) postlea_miss + INT3 probes to locate GS
P("=== A postlea_miss GS locus ===")
pe=plant_postlea(base)
h=save(pe,"_dig_pl.exe")
P(f"  bare postlea fwd={run(h,'_var_fwd.x')[0]} let={run(h,'_var_let.x')[0]} lit={run(h,'p_ret_lit.x')[0]}")

for rva,lab in [(0x2be90a,"scs_epi_add"),(0x2be911,"scs_epi_pop"),(0x2be912,"scs_epi_ret"),
                (0x576697,"cap_store"),(0x5766b0,"cap_cmp0"),(0x5766c3,"cap_prep2c"),
                (0x5766ec,"cap_call_2c"),(0x2c614f,"helper_2c"),(0x57656c,"cap_entry")]:
    pe2=plant_postlea(base)
    pe2[rva2off(pe2,secs,rva)]=0xCC
    h=save(pe2,f"_dig_pl_{lab}.exe")
    tf=run(h,"_var_fwd.x")[0]; tl=run(h,"_var_let.x")[0]
    flag=" DIFF" if tf!=tl else ""
    P(f"  INT3@{rva:06x} {lab:14s} fwd={tf:8s} let={tl:8s}{flag}")

# B) BASE host same INT3 set for compare
P("\n=== B BASE host INT3 locus ===")
for rva,lab in [(0x2be90a,"scs_epi_add"),(0x2be911,"scs_epi_pop"),
                (0x576697,"cap_store"),(0x5766ec,"cap_call_2c"),(0x2c614f,"helper_2c")]:
    pe2=bytearray(base); pe2[rva2off(pe2,secs,rva)]=0xCC
    h=save(pe2,f"_dig_b_{lab}.exe")
    tf=run(h,"_var_fwd.x")[0]; tl=run(h,"_var_let.x")[0]
    flag=" DIFF" if tf!=tl else ""
    P(f"  INT3@{rva:06x} {lab:14s} fwd={tf:8s} let={tl:8s}{flag}")

# C) scs_ret0 (xor;ret at entry) INT3 Capless post
P("\n=== C scs_ret0 + Capless INT3 ===")
pe=bytearray(base)
pe[rva2off(pe,secs,0x2be519):rva2off(pe,secs,0x2be519)+3]=bytes.fromhex("31c0c3")
h=save(pe,"_dig_ret0.exe")
P(f"  bare ret0 fwd={run(h,'_var_fwd.x')[0]} let={run(h,'_var_let.x')[0]} lit={run(h,'p_ret_lit.x')[0]}")
for rva,lab in [(0x576697,"cap_store"),(0x5766ec,"cap_call_2c"),(0x2c614f,"helper_2c"),
                (0x2c61c1,"helper_postkind"),(0x20cd98,"kind20cd")]:
    pe2=bytearray(base)
    pe2[rva2off(pe2,secs,0x2be519):rva2off(pe2,secs,0x2be519)+3]=bytes.fromhex("31c0c3")
    pe2[rva2off(pe2,secs,rva)]=0xCC
    h=save(pe2,f"_dig_r0_{lab}.exe")
    tf=run(h,"_var_fwd.x")[0]; tl=run(h,"_var_let.x")[0]
    flag=" DIFF" if tf!=tl else ""
    P(f"  INT3@{rva:06x} {lab:16s} fwd={tf:8s} let={tl:8s}{flag}")

# D) Who calls Capless_alt - disasm each caller site briefly; check if return-Call uses different caller
P("\n=== D Capless_alt callers context ===")
img=bytes(base)
def off2rva(off):
    for n,(va,vs,ro,rs) in secs.items():
        if ro<=off<ro+max(vs,rs): return va+(off-ro)
    return None
callers=[]
for off in range(len(img)-5):
    if img[off]==0xE8:
        rel=struct.unpack_from("<i",img,off+1)[0]
        rva=off2rva(off)
        if rva is None: continue
        if rva+5+rel==0x57656c:
            callers.append(rva)
for c in callers:
    off=rva2off(base,secs,c-0x20 if c>=0x20 else c)
    P(f"--- caller {c:#x} ---")
    for insn in list(md.disasm(bytes(base[off:off+0x40]), c-0x20 if c>=0x20 else c))[:12]:
        mark=" <<" if insn.address==c else ""
        P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}{mark}")

# E) Isol plant idea: Capless SoftCap call @576692 — for return path, SoftCap miss is expected;
# Capless when SoftCap returns 0 goes to @2c614f. The REAL fwd GS under stub is @2c614f.
# Under real SoftCap, GS at epi may be BECAUSE SoftCap frame + Capless misalignment for
# return-Call's outer stack, OR because SoftCap is called with rsp that makes pop smash cookie.
#
# Try: Capless SoftCap call site — save/restore rsp around SoftCap with 16-byte align fix
# Before call @576692: check alignment. Plant: sub rsp,8 before call + add rsp,8 after — if misaligned
# Capless rsp after prol ≡ 0 (mod 16). Need ≡8. So sub rsp,8 before call would fix.
P("\n=== E plant Capless align SoftCap call (sub rsp,8 before / add after) ===")
# Need space: before @576692. Look at @57668b mov [rsp+0x20],ecx; mov rcx,rax; call
# Insert sub rsp,8: would shift [rsp+0x20] — BAD unless we adjust.
# Alternative: at Capless entry, sub rsp,0x508 instead of 0x500 to fix alignment
pe2=bytearray(base)
o=rva2off(pe2,secs,0x57656d)  # sub rsp,0x500 = 48 81 ec 00 05 00 00
P(f"  Capless sub bytes={bytes(pe2[o:o+7]).hex()}")
assert bytes(pe2[o:o+7])==bytes.fromhex("4881ec00050000")
pe2[o:o+7]=bytes.fromhex("4881ec08050000")  # sub rsp,0x508
# Must also fix epi add rsp,0x500 → 0x508
o2=rva2off(pe2,secs,0x578278)
P(f"  Capless add bytes={bytes(pe2[o2:o2+7]).hex()}")
assert bytes(pe2[o2:o2+7])==bytes.fromhex("4881c400050000")
pe2[o2:o2+7]=bytes.fromhex("4881c408050000")
# lea rbp,[rsp+0x80] stays — rbp relationship to args changes by 8!
# Capless [rbp+0x490] etc would point 8 bytes differently relative to stack args — BREAKS
# Instead: change lea to [rsp+0x88] to keep rbp same absolute?
# After sub 0x508: rsp' = old_rsp-8. lea rbp,[rsp+0x88] = old_rsp-8+0x88 = old_rsp+0x80 = same rbp. YES!
o3=rva2off(pe2,secs,0x576574)
P(f"  Capless lea bytes={bytes(pe2[o3:o3+8]).hex()}")
# 48 8d ac 24 80 00 00 00 = lea rbp,[rsp+0x80]
assert bytes(pe2[o3:o3+8])==bytes.fromhex("488dac2480000000")
pe2[o3:o3+8]=bytes.fromhex("488dac2488000000")  # lea rbp,[rsp+0x88]
h=save(pe2,"host_cap_align508.exe")
sha=hashlib.sha256(bytes(pe2)).hexdigest()[:12]
P(f"  cap_align508 sha12={sha}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x","_var_fwd.x"]:
    tag,sh,outx=run(h,src)
    rt,rc="-","-"
    if tag=="OK" and outx: rt,rc=run_bin(outx)
    P(f"  align508/{src:14s} {tag:8s} USER={sh} run={rt}/{rc}")

# F) Softer align: only around SoftCap call — push rax; sub/add; but shadow [rsp+0x20] shifts
# Before @57668b: sub rsp,8; then mov [rsp+0x28],ecx (adjust+8); call; add rsp,8
# @57668b is 4B mov [rsp+0x20],ecx = 89 4c 24 20. Change 0x20→0x28 and insert sub/add — needs space (mega).
# Skip if align508 works or fails clearly.

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_dig_pl*","_dig_b_*","_dig_r0_*","_dig_ret0*","_tmp_scs3_*","_var_*.x"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
(cave/"p_ret_fwd.x").write_text(FWD,encoding="utf-8")
P("cleaned")
