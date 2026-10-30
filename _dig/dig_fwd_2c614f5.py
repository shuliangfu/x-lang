#!/usr/bin/env python3
"""DIG5: SoftCap_site epi GS for return-Call; kind value; Capless post-return.
Ban tip@121278/join/epi-raise/LIVE/mega/[4b0]=1. Budget<=80s.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64)
cave = Path("C:/xlang_tmp/p1060/cave"); os.chdir(str(cave))
T0=time.time(); BUDGET=80
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
    out=cave/f"_tmp_f2c5_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    try:
        r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout,cwd=str(cave))
        return tag_of(r.returncode)
    except subprocess.TimeoutExpired:
        return "TIMEOUT"
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

# === A) SoftCap epi region disasm + INT3 ===
P("=== A SoftCap epi @2be90a ===")
off=rva2off(base,secs,0x2be8e0)
insns=list(md.disasm(bytes(base[off:off+0x50]),0x2be8e0))
for insn in insns:
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")

for rva,lab in [(0x2be734,"miss_eax0"),(0x2be739,"miss_jmp"),(0x2be90a,"epi"),(0x2be90b,"epi+1"),
                (0x2be911,"epi_mid"),(0x2be917,"pop_rbp"),(0x2be918,"ret")]:
    # discover exact epi bytes first
    pass

# find add rsp / pop / ret near 0x2be90a
P("bytes@2be90a="+bytes(base[rva2off(base,secs,0x2be90a):rva2off(base,secs,0x2be90a)+16]).hex())
for insn in insns:
    pe2=bytearray(base); pe2[rva2off(pe2,pe_secs(pe2),insn.address)]=0xCC
    h=save(pe2,f"_dig_epi_{insn.address:x}.exe")
    tf=run(h,"_var_fwd.x"); tl=run(h,"_var_let.x")
    flag=" DIFF" if tf!=tl else ""
    P(f"  @{insn.address:06x} {insn.mnemonic:8s} {insn.op_str[:40]:40s} fwd={tf:8s} let={tl:8s}{flag}")

# === B) SoftCap kind value for fwd vs let (eq probe at @2be6cf) ===
P("\n=== B SoftCap kind eq @2be6cf ===")
o=rva2off(base,secs,0x2be6cf)
P(f"orig@2be6cf={bytes(base[o:o+6]).hex()}")
# 6B: 83 F8 ib; 74 01; CC  for imm8 kinds
for k in [0,1,2,3,0x30,0x31,0x32,0x33,0x36,0x10,0x20,0x40,0xff]:
    if time.time()-T0>BUDGET-35: break
    pe2=bytearray(base)
    pe2[o:o+6]=bytes([0x83,0xF8,k&0xFF,0x74,0x01,0xCC])
    h=save(pe2,f"_dig_skind_{k:x}.exe")
    tf=run(h,"_var_fwd.x"); tl=run(h,"_var_let.x")
    # INT3 => eax!=k; else eax==k
    P(f"  k={k:#x} fwd={tf:8s} let={tl:8s} (INT3=neq)")

# === C) SoftCap skip kind-call @2be6ca: mov eax,imm; then fall to store ===
P("\n=== C SoftCap force kind then miss-exit ===")
o_call=rva2off(base,secs,0x2be6ca)
P(f"call@2be6ca={bytes(base[o_call:o_call+5]).hex()}")
# Replace call with mov eax,0x30 (not in {36,33,3}) → miss → epi
for imm in [0x30,0,0x36,0x33,3]:
    pe2=bytearray(base)
    pe2[o_call:o_call+5]=bytes([0xB8])+struct.pack("<I",imm)
    h=save(pe2,f"_dig_sfk_{imm:x}.exe")
    tf=run(h,"_var_fwd.x"); tl=run(h,"_var_let.x"); tlit=run(h,"p_ret_lit.x")
    P(f"  force_scs_kind={imm:#x} fwd={tf:8s} let={tl:8s} lit={tlit:8s}")

# === D) SoftCap entry → jmp miss eax0 epi directly (skip all body) ===
P("\n=== D SoftCap entry jmp to miss-eax0 @2be734 ===")
pe2=bytearray(base)
# at @2be519: need full epi-equivalent. xor eax; ret breaks frame if Capless expects...
# After prol homes: jmp to @2be734
# At @2be529 (first home): too early. At @2be693 (first cmp): 
o=rva2off(pe2,secs,0x2be693)
pe2[o:o+5]=bytes([0xE9])+struct.pack("<i",0x2be734-(0x2be693+5))
h=save(pe2,"_dig_scs_jmpmiss.exe")
P(f"  jmp_miss@693 fwd={run(h,'_var_fwd.x'):8s} let={run(h,'_var_let.x'):8s} lit={run(h,'p_ret_lit.x'):8s}")

# Direct @2be519: mov eax,0; add rsp,0x150; pop rbp; ret = 3+7+1+1=12B
# 48 81 c4 50 01 00 00 = add rsp,0x150 (7B); 5d pop; c3 ret
pe2=bytearray(base)
o=rva2off(pe2,secs,0x2be519)
# Can't do full epi at entry without push. Entry xor;ret (no push) is correct for no-frame return.
# Try: push rbp already — replace from @2be51a (sub rsp): add rsp already 0; pop; ret? 
# Simplest known: scs_ret0 at entry
pe2=bytearray(base)
pe2[rva2off(pe2,secs,0x2be519):rva2off(pe2,secs,0x2be519)+3]=bytes.fromhex("31c0c3")
h=save(pe2,"_dig_scs_ret0b.exe")
P(f"  scs_ret0      fwd={run(h,'_var_fwd.x'):8s} let={run(h,'_var_let.x'):8s} lit={run(h,'p_ret_lit.x'):8s}")

# === E) under stub: @20cd98 lastHIT deeper (happy path) ===
P("\n=== E stub @20cd98 happy-path walk ===")
stub=bytearray(base)
stub[rva2off(stub,secs,0x2be519):rva2off(stub,secs,0x2be519)+3]=bytes.fromhex("31c0c3")
off=rva2off(stub,secs,0x20cdbb)
insns=list(md.disasm(bytes(stub[off:off+0x80]),0x20cdbb))
last=None
for insn in insns[:30]:
    if time.time()-T0>BUDGET-5: break
    pe2=bytearray(stub); pe2[rva2off(pe2,pe_secs(pe2),insn.address)]=0xCC
    h=save(pe2,f"_dig_kh_{insn.address:x}.exe")
    tf=run(h,"_var_fwd.x"); tl=run(h,"_var_let.x")
    if tf=="INT3": last=insn.address
    flag=" DIFF" if tf!=tl else ""
    P(f"  @{insn.address:06x} {insn.mnemonic:8s} {insn.op_str[:40]:40s} fwd={tf:8s} let={tl:8s}{flag}")
    if last and tf=="GS" and insn.address>last:
        P(f"  >> lastHIT @{last:#x}")
        break
P(f"last_fwd_HIT={last:#x}" if last else "last=None")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_dig_epi_*","_dig_skind_*","_dig_sfk_*","_dig_scs_*","_dig_kh_*","_tmp_f2c5_*","_var_*.x"]:
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
