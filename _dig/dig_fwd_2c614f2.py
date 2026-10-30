#!/usr/bin/env python3
"""DIG2 fwd_2c614f: kind==0x30 both; dig post-kind GS root for return-Call.
Skip/force kind call, nop store, epi HIT, deeper let walk, cookie.
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
def run(h,src,timeout=5):
    out=cave/f"_tmp_f2c2_{h.stem}_{Path(src).stem}.exe"
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
stub=bytearray(base)
stub[rva2off(stub,secs,0x2be519):rva2off(stub,secs,0x2be519)+3]=bytes.fromhex("31c0c3")
P("=== DIG2 fwd_2c614f (kind=0x30 both) ===")
P(f"stub fwd={run(cave/'host_cmk0_irdx_sub20.exe','_var_fwd.x')} (real host, expect GS)")
# write stub host
host=cave/"host_scs_f2c2.exe"; host.write_bytes(stub)
P(f"stub fwd={run(host,'_var_fwd.x')} let={run(host,'_var_let.x')}")

def save(pe, name):
    p=cave/name; p.write_bytes(pe); return p

# --- A) confirm kind eq 0x30 with clean fall (mov eax dump via je ladder) ---
# already done DIG1

# --- B) skip kind call @2c61bc: replace E8.. with mov eax,0x30 (B8 30 00 00 00) ---
P("\n=== B skip @20cd98 force eax=0x30 ===")
o_call=rva2off(stub,secs,0x2c61bc)
P(f"call@2c61bc={bytes(stub[o_call:o_call+5]).hex()}")
assert stub[o_call]==0xE8
for imm in [0x30,0x31,0,0x36]:
    pe2=bytearray(stub)
    pe2[o_call:o_call+5]=bytes([0xB8])+struct.pack("<I",imm)  # mov eax,imm
    h=save(pe2,f"_dig_skcall_{imm:x}.exe")
    P(f"  skip_kind eax={imm:#x} fwd={run(h,'_var_fwd.x'):8s} let={run(h,'_var_let.x'):8s}")

# --- C) nop store @2c61c1 (6B nops) — keep eax; cmp uses stale [rbp+0xf4] ---
P("\n=== C nop store @2c61c1 ===")
o_st=rva2off(stub,secs,0x2c61c1)
pe2=bytearray(stub)
pe2[o_st:o_st+6]=b"\x90"*6
h=save(pe2,"_dig_nopstore.exe")
P(f"  nopstore fwd={run(h,'_var_fwd.x'):8s} let={run(h,'_var_let.x'):8s}")

# nop store + force [rbp+0xf4]=0x30 before cmp:
# at @2c61c1 plant: C7 85 f4 00 00 00 30 00 00 00 = mov dword [rbp+0xf4],0x30 (10B)
# covers @2c61c1..@2c61ca; need align to @2c61ce (13B from @2c61c1): +3 nop
P("\n=== C2 force [rbp+0xf4]=0x30 via mov-imm (skip eax) ===")
pe2=bytearray(stub)
patch=bytes.fromhex("c785f400000030000000")  # 10B
pe2[o_st:o_st+10]=patch
pe2[o_st+10:o_st+13]=b"\x90\x90\x90"
h=save(pe2,"_dig_force_slot30.exe")
P(f"  force_slot30 fwd={run(h,'_var_fwd.x'):8s} let={run(h,'_var_let.x'):8s}")

# --- D) INT3 at epi @2c66a0 / @2c66a8 ret / mid path ---
P("\n=== D INT3 epi / key points ===")
pts=[
    0x2c61c1,"store_kind",
    0x2c61c7,"cmp30",
    0x2c61e3,"match_path",
    0x2c61f0,"set_is31",
    0x2c620f,"call_1fff7e",
    0x2c622c,"call_1ff2ef",
    0x2c6237,"cmp_f8_2",
    0x2c624a,"after_arity",
    0x2c6263,"call_1fffbe",
    0x2c66a0,"epi_add",
    0x2c66a8,"epi_ret",
]
# also find first call after 0x2c6280 in body
off=rva2off(stub,secs,0x2c6280)
insns_mid=list(md.disasm(bytes(stub[off:off+0x400]),0x2c6280))
calls=[]
for insn in insns_mid:
    if insn.mnemonic=="call" and len(calls)<8:
        calls.append(insn.address)
        pts.extend([insn.address, f"call_{insn.op_str}"])
for i in range(0,len(pts),2):
    if time.time()-T0>BUDGET-25: break
    rva,lab=pts[i],pts[i+1]
    pe2=bytearray(stub); pe2[rva2off(pe2,pe_secs(pe2),rva)]=0xCC
    h=save(pe2,f"_dig_cc_{rva:x}.exe")
    tf=run(h,"_var_fwd.x",timeout=4); tl=run(h,"_var_let.x",timeout=4)
    flag=" DIFF" if tf!=tl else ""
    P(f"  @{rva:06x} {lab:20s} fwd={tf:8s} let={tl:8s}{flag}")

# --- E) let-only deeper walk: find last_let_HIT past arity ---
P("\n=== E let walk selected + fwd (post 0x2c6280 calls/jmps) ===")
last_l=None
for insn in insns_mid[:60]:
    if time.time()-T0>BUDGET-10: break
    if insn.mnemonic not in ("call","jmp","je","jne","jle","jg","jns","ret","mov") and insn.address not in calls:
        if insn.address & 0xF: # sparse
            continue
    pe2=bytearray(stub); pe2[rva2off(pe2,pe_secs(pe2),insn.address)]=0xCC
    h=save(pe2,f"_dig_w_{insn.address:x}.exe")
    tl=run(h,"_var_let.x",timeout=3)
    tf=run(h,"_var_fwd.x",timeout=3)
    if tl=="INT3": last_l=insn.address
    if tl=="INT3" or tf!=tl:
        P(f"  @{insn.address:06x} {insn.mnemonic:8s} {insn.op_str[:40]:40s} fwd={tf:8s} let={tl:8s}")
P(f"last_let_HIT≈{last_l:#x}" if last_l else "last_let_HIT=None")

# --- F) real SoftCap (no stub): INT3 @2c614f entry — does fwd reach Capless helper? ---
P("\n=== F real host (no stub) reach @2c614f? ===")
pe2=bytearray(base); pe2[rva2off(pe2,pe_secs(pe2),0x2c614f)]=0xCC
h=save(pe2,"_dig_real_cc_2c614f.exe")
P(f"  real INT3@2c614f fwd={run(h,'_var_fwd.x')} let={run(h,'_var_let.x')} lit={run(h,'p_ret_lit.x')}")
pe2=bytearray(base); pe2[rva2off(pe2,pe_secs(pe2),0x5766ec)]=0xCC
h=save(pe2,"_dig_real_cc_5766ec.exe")
P(f"  real INT3@5766ec fwd={run(h,'_var_fwd.x')} let={run(h,'_var_let.x')}")
pe2=bytearray(base); pe2[rva2off(pe2,pe_secs(pe2),0x2be519)]=0xCC
h=save(pe2,"_dig_real_cc_scs.exe")
P(f"  real INT3@SoftCap fwd={run(h,'_var_fwd.x')} let={run(h,'_var_let.x')}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_dig_skcall_*","_dig_nopstore*","_dig_force_*","_dig_cc_*","_dig_w_*","_dig_real_*","_tmp_f2c2_*","_var_*.x","host_scs_f2c2.exe"]:
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
