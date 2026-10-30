#!/usr/bin/env python3
"""DIG fwd_2c614f: Capless @2c614f return-Call vs let after kind@20cd98.
Under SoftCap_site scs_ret0 stub. Capture kind, force 0x30/0x31, deeper walk,
arg homes. Ban tip@121278/join/epi/LIVE/mega/[4b0]=1/arg-loop. Budget<=85s.
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
    out=cave/f"_tmp_f2c_{h.stem}_{Path(src).stem}.exe"
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

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

# SoftCap_site stub xor eax,eax; ret
stub=bytearray(base)
stub[rva2off(stub,secs,0x2be519):rva2off(stub,secs,0x2be519)+3]=bytes.fromhex("31c0c3")
host_stub=cave/"host_scs_ret0_f2c.exe"; host_stub.write_bytes(stub)
P(f"=== DIG fwd_2c614f under scs_ret0 ===")
P(f"stub baseline fwd={run(host_stub,'_var_fwd.x')} let={run(host_stub,'_var_let.x')} lit={run(host_stub,'p_ret_lit.x')}")

# --- A) disasm @2c614f window past kind to ~0x2c6300 + epi ---
P("\n=== A disasm @2c614f ---")
off=rva2off(stub,secs,0x2c614f)
insns=list(md.disasm(bytes(stub[off:off+0x200]),0x2c614f))
for insn in insns:
    if insn.address>0x2c6280 and insn.address<0x2c6650:
        continue
    mark=""
    if insn.mnemonic=="call": mark=" CALL"
    if insn.mnemonic.startswith("j"): mark+=" J"
    if insn.address>=0x2c6650 or insn.address<=0x2c6280:
        P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}{mark}")
# epi region
off_e=rva2off(stub,secs,0x2c6680)
for insn in list(md.disasm(bytes(stub[off_e:off_e+0x40]),0x2c6680))[:20]:
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")

# --- B) kind ladder: after call @2c61bc, replace store with cmp eax,imm; int3 variants ---
# Plant at @2c61c1 (6B: 89 85 f4 00 00 00): 3D imm32 CC  = cmp eax,imm32; int3  (6B)
P("\n=== B kind ladder @2c61c1 cmp eax,imm;int3 ===")
# orig @2c61c1
o61c1=rva2off(stub,secs,0x2c61c1)
P(f"orig@2c61c1={bytes(stub[o61c1:o61c1+6]).hex()}")
kind_cands=[0,1,2,3,0x30,0x31,0x32,0x33,0x36,0x10,0x20,0x40,0xff,0x100]
for k in kind_cands:
    if time.time()-T0>BUDGET-40: break
    pe2=bytearray(stub)
    # cmp eax, imm32; int3  (3D ii ii ii ii CC)
    pe2[o61c1:o61c1+6]=bytes([0x3D])+struct.pack("<I",k)+bytes([0xCC])
    out=cave/f"_dig_kind_{k:x}.exe"; out.write_bytes(pe2)
    tf=run(out,"_var_fwd.x"); tl=run(out,"_var_let.x")
    # INT3 means eax==k was compared then hit int3 (always hits int3 after cmp)
    # Actually cmp doesn't branch - always falls to int3. So always INT3 if reached.
    # Better: cmp eax,imm; je +1; int3; int3  — if equal skip first int3 to second? 
    # Use: cmp eax,imm32; je +1 (74 01); int3  — if equal, skip int3 → fall into broken next → AV/GS
    # if not equal, INT3. So INT3 => eax!=k; non-INT3 => eax==k
    flag=""
    P(f"  (always-int3 probe) k={k:#x} fwd={tf} let={tl}")

# Better kind equality probe
P("\n=== B2 kind eq probe: cmp eax,imm; je+1; int3 ===")
for k in [0,1,2,3,0x30,0x31,0x32,0x33,0x36]:
    if time.time()-T0>BUDGET-30: break
    pe2=bytearray(stub)
    # 3D imm32 | 74 01 | CC  = 8 bytes; orig store is 6 bytes — OVERFLOW into next
    # Use 6B only: 3D imm32 CC — always int3; useless for eq
    # 5B option at call return site: overwrite call's next differently
    # Plant BEFORE store: at @2c61bc call is 5B. After call eax=kind.
    # Overwrite @2c61c1.. with: 83 F8 imm8 | 74 01 | CC | 90  
    # 83 F8 ib = cmp eax,imm8 (3B); 74 01 (2B); CC (1B) = 6B exact!
    if k>0x7f and k<0xffffff80:
        # only imm8-fit for 6B plant; for 0x30/0x31 OK
        pass
    if k>0xff:
        continue
    pe2[o61c1:o61c1+6]=bytes([0x83,0xF8,k&0xFF, 0x74,0x01, 0xCC])
    out=cave/f"_dig_keq_{k:x}.exe"; out.write_bytes(pe2)
    tf=run(out,"_var_fwd.x"); tl=run(out,"_var_let.x")
    # INT3 => eax!=k (took int3); other => eax==k (skipped int3 into next insn which is cmp@2c61c7 broken)
    P(f"  k={k:#x} fwd={tf:8s} let={tl:8s}  (INT3=eax!=k; else eax==k then fall)")

# --- C) force kind after call: mov eax,imm8; mov [rbp+0xf4],eax truncated ---
# 6B at @2c61c1: B8 imm32 90 90 = mov eax,imm32; nop; nop — 6B but loses store
# Then fall into cmp [rbp+0xf4] which has OLD value — bad
# Better 10B plant spanning @2c61c1..@2c61ca: B8 imm32 | 89 85 f4 00 00 00 = mov eax; store (10B)
# @2c61c1 is 6B, @2c61c7 is 7B (83 bd f4 00 00 00 30) — total to @2c61ce = 13B
P("\n=== C force kind mov eax,imm; store [rbp+0xf4] ===")
# Plant 10B: B8 ii ii ii ii  89 85 f4 00 00 00  at @2c61c1, eats into cmp
# Remaining at @2c61cb need to re-sync. Orig @2c61c7=83 bd f4 00 00 00 30 (7B) -> @2c61ce
# After 10B plant ends at @2c61cb. Need nop slide to @2c61ce then keep je.
# 10B + 3 nop = 13B covers to @2c61ce exactly.
o61ce=rva2off(stub,secs,0x2c61ce)
for k in [0x30,0x31,0x33,0x36,0]:
    if time.time()-T0>BUDGET-20: break
    pe2=bytearray(stub)
    patch=bytes([0xB8])+struct.pack("<I",k)+bytes.fromhex("8985f4000000")  # 10B
    assert len(patch)==10
    pe2[o61c1:o61c1+10]=patch
    pe2[o61c1+10:o61c1+13]=b"\x90\x90\x90"  # nop to @2c61ce
    # verify @2c61ce still je
    P(f"  @2c61ce after force={bytes(pe2[o61ce:o61ce+2]).hex()} (expect 74)")
    out=cave/f"_dig_fk_{k:x}.exe"; out.write_bytes(pe2)
    tf=run(out,"_var_fwd.x"); tl=run(out,"_var_let.x")
    P(f"  force_kind={k:#x} fwd={tf:8s} let={tl:8s}")

# --- D) deeper INT3 walk from @2c61c1 for let (expect continue) and key calls ---
P("\n=== D INT3 walk @2c61c1..@2c6280 ===")
def plant_cc(rva):
    pe2=bytearray(stub); s=pe_secs(pe2)
    pe2[rva2off(pe2,s,rva)]=0xCC
    out=cave/f"_dig_f2c_{rva:x}.exe"; out.write_bytes(pe2); return out

last_f=last_l=None
for insn in insns:
    if insn.address<0x2c61c1: continue
    if insn.address>0x2c6280: break
    if time.time()-T0>BUDGET-8: break
    tf=run(plant_cc(insn.address),"_var_fwd.x",timeout=4)
    tl=run(plant_cc(insn.address),"_var_let.x",timeout=4)
    if tf=="INT3": last_f=insn.address
    if tl=="INT3": last_l=insn.address
    flag=" DIFF" if tf!=tl else ""
    if tf!=tl or tl=="INT3" or insn.mnemonic=="call":
        P(f"  @{insn.address:06x} {insn.mnemonic:8s} {insn.op_str[:42]:42s} fwd={tf:8s} let={tl:8s}{flag}")
P(f"last_fwd_HIT={last_f:#x}" if last_f else "last_fwd_HIT=None")
P(f"last_let_HIT={last_l:#x}" if last_l else "last_let_HIT=None")

# --- E) arg null-check divergence: force skip null checks (always take jg path) ---
P("\n=== E force take happy path @2c61a0 jg -> nop nop ===")
# @2c61a0: jg 0x2c61ac (7C? or 0F8F?) — check bytes
oa0=rva2off(stub,secs,0x2c61a0)
P(f"bytes@2c61a0={bytes(stub[oa0:oa0+6]).hex()}")
# From dig8: jg 0x2c61ac — short jg is 7F xx (2B)
pe2=bytearray(stub)
pe2[oa0:oa0+2]=b"\x90\x90"  # nop nop — fall through to mov eax,0 miss path!
# Actually we want ALWAYS take happy: replace jg with jmp short
pe2=bytearray(stub)
pe2[oa0:oa0+2]=bytes([0xEB, stub[oa0+1]])  # jmp short same rel
out=cave/"_dig_force_jg.exe"; out.write_bytes(pe2)
P(f"  force_jmp_happy fwd={run(out,'_var_fwd.x')} let={run(out,'_var_let.x')}")

# Force miss path: @2c61a0 -> jmp to miss @2c61a2
pe2=bytearray(stub)
pe2[oa0:oa0+2]=bytes([0xEB, 0x00])  # jmp +0 -> @2c61a2
out=cave/"_dig_force_miss.exe"; out.write_bytes(pe2)
P(f"  force_miss fwd={run(out,'_var_fwd.x')} let={run(out,'_var_let.x')}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_dig_f2c_*","_dig_kind_*","_dig_keq_*","_dig_fk_*","_dig_force_*","_tmp_f2c_*","_var_*.x","host_scs_ret0_f2c.exe"]:
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
P("cleaned+restored")
