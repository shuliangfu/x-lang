#!/usr/bin/env python3
"""DIG3 fwd_2c614f: early-ret @2c614f body; SoftCap_site INT3 walk for real-host fwd GS.
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
    out=cave/f"_tmp_f2c3_{h.stem}_{Path(src).stem}.exe"
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
LIT=open(cave/"p_ret_lit.x",encoding="utf-8").read() if (cave/"p_ret_lit.x").exists() else """struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function main(): i32 { let w: W = mk(10); if (w.a != 10) { return 1; } return 0; }
"""
(cave/"_var_fwd.x").write_text(FWD,encoding="utf-8")
(cave/"_var_let.x").write_text(LET,encoding="utf-8")

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

# === A) under stub: early-ret @2c614f at entry / after prol / after kind ===
P("=== A early-ret @2c614f under SoftCap stub ===")
stub=bytearray(base)
stub[rva2off(stub,secs,0x2be519):rva2off(stub,secs,0x2be519)+3]=bytes.fromhex("31c0c3")

def early_ret_at(pe, rva, label):
    """Plant xor eax,eax; add rsp,0x190; pop rbp; ret — BUT only valid if frame already set.
    At entry before prol: just xor; ret (3B).
    After prol (after push/sub/lea): need full epi.
    """
    return pe

# A1: @2c614f entry = xor eax,eax; ret  (skip whole helper)
pe2=bytearray(stub)
pe2[rva2off(pe2,secs,0x2c614f):rva2off(pe2,secs,0x2c614f)+3]=bytes.fromhex("31c0c3")
h=save(pe2,"_dig_er_entry.exe")
P(f"  entry xor;ret  fwd={run(h,'_var_fwd.x'):8s} let={run(h,'_var_let.x'):8s} lit={run(h,'p_ret_lit.x'):8s}")

# A2: after prol @2c615f (first home store): jump to epi @2c66a0
# short jump may not reach; use mov eax,0; jmp rel32 to epi
# @2c615f bytes: replace with B8 00000000 E9 rel32
pe2=bytearray(stub)
o=rva2off(pe2,secs,0x2c615f)
target=0x2c66a0
rel=target-(0x2c615f+5+5)  # after mov eax + jmp
# B8 00 00 00 00 | E9 xx xx xx xx = 10B
pe2[o:o+10]=bytes([0xB8,0,0,0,0,0xE9])+struct.pack("<i", target-(0x2c615f+10))
h=save(pe2,"_dig_er_postprol.exe")
P(f"  postprol jmp epi fwd={run(h,'_var_fwd.x'):8s} let={run(h,'_var_let.x'):8s}")

# A3: @2c61c1 -> mov eax,0; jmp epi (skip body after kind)
pe2=bytearray(stub)
o=rva2off(pe2,secs,0x2c61c1)
pe2[o:o+10]=bytes([0xB8,0,0,0,0,0xE9])+struct.pack("<i", 0x2c66a0-(0x2c61c1+10))
h=save(pe2,"_dig_er_postkind.exe")
P(f"  postkind jmp epi fwd={run(h,'_var_fwd.x'):8s} let={run(h,'_var_let.x'):8s}")

# A4: @2c61bc call -> mov eax,0x30; mov [rbp+0xf4],eax; jmp epi
# 5B call + 6B store = need more space: at @2c61bc: B8 30 000000 | 89 85 f4 000000 | E9 ...
pe2=bytearray(stub)
o=rva2off(pe2,secs,0x2c61bc)
patch=bytes([0xB8,0x30,0,0,0])+bytes.fromhex("8985f4000000")+bytes([0xE9])+struct.pack("<i",0x2c66a0-(0x2c61bc+5+6+5))
pe2[o:o+len(patch)]=patch
h=save(pe2,"_dig_er_force30_epi.exe")
P(f"  force30+epi   fwd={run(h,'_var_fwd.x'):8s} let={run(h,'_var_let.x'):8s}")

# === B) Capless skip call @2c614f entirely under stub (xor eax at @5766ec) ===
P("\n=== B Capless skip @5766ec call @2c614f ===")
pe2=bytearray(stub)
o=rva2off(pe2,secs,0x5766ec)
assert pe2[o]==0xE8, bytes(pe2[o:o+5]).hex()
pe2[o:o+5]=bytes.fromhex("31c0909090")  # xor eax,eax; nop*3
h=save(pe2,"_dig_skip_2c614f.exe")
P(f"  skip_2c614f   fwd={run(h,'_var_fwd.x'):8s} let={run(h,'_var_let.x'):8s} lit={run(h,'p_ret_lit.x'):8s}")

# === C) REAL host SoftCap_site INT3 walk (fwd GS root) ===
P("\n=== C REAL SoftCap_site @2be519 INT3 walk ===")
off=rva2off(base,secs,0x2be519)
insns=list(md.disasm(bytes(base[off:off+0x220]),0x2be519))
P("--- SoftCap_site prol/head ---")
for insn in insns[:45]:
    mark=""
    if insn.mnemonic=="call": mark=" CALL"
    if insn.mnemonic.startswith("j"): mark+=" J"
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}{mark}")

last_f=last_l=None
P("\n--- INT3 walk SoftCap_site (fwd vs let) ---")
for insn in insns[:50]:
    if time.time()-T0>BUDGET-15: break
    pe2=bytearray(base)
    pe2[rva2off(pe2,pe_secs(pe2),insn.address)]=0xCC
    h=save(pe2,f"_dig_scs_{insn.address:x}.exe")
    tf=run(h,"_var_fwd.x",timeout=4); tl=run(h,"_var_let.x",timeout=4)
    if tf=="INT3": last_f=insn.address
    if tl=="INT3": last_l=insn.address
    flag=" DIFF" if tf!=tl else ""
    # print all until fwd leaves INT3, plus calls
    if tf=="INT3" or tl=="INT3" or tf!=tl or insn.mnemonic=="call":
        P(f"  @{insn.address:06x} {insn.mnemonic:8s} {insn.op_str[:42]:42s} fwd={tf:8s} let={tl:8s}{flag}")
    if last_f and tf!="INT3" and insn.address>last_f:
        # first non-HIT after last for fwd
        if flag or insn.mnemonic=="call":
            pass
P(f"last_fwd_HIT={last_f:#x}" if last_f else "last_fwd_HIT=None")
P(f"last_let_HIT={last_l:#x}" if last_l else "last_let_HIT=None")

# === D) SoftCap_site early xor;ret already known; try early eax=1;ret and frame epi ===
P("\n=== D SoftCap_site quick plants (real host) ===")
# kind-miss path already eax=0; entry xor;ret
pe2=bytearray(base)
pe2[rva2off(pe2,secs,0x2be519):rva2off(pe2,secs,0x2be519)+3]=bytes.fromhex("31c0c3")
h=save(pe2,"_dig_scs_ret0.exe")
P(f"  scs_ret0      fwd={run(h,'_var_fwd.x'):8s} let={run(h,'_var_let.x'):8s} lit={run(h,'p_ret_lit.x'):8s}")

# find SoftCap epi: look for add rsp / pop rbp near end of function
# from prior notes: epi at area with add rsp,0x150
for insn in list(md.disasm(bytes(base[rva2off(base,secs,0x2be6e0):rva2off(base,secs,0x2be6e0)+0x80]),0x2be6e0)):
    if insn.mnemonic in ("ret","add") and ("rsp" in insn.op_str or insn.mnemonic=="ret"):
        P(f"  scs_tail {insn.address:06x}: {insn.mnemonic} {insn.op_str}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_dig_er_*","_dig_skip_*","_dig_scs_*","_tmp_f2c3_*","_var_*.x"]:
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
