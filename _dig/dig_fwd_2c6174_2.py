#!/usr/bin/env python3
"""DIG fwd_2c6174 #2: Capless SoftCap-call dump; post-576746 GS locus;
stable dual-retarget Isol candidates (not nopr9-as-Isol). Budget<=85s."""
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
    out=cave/f"_t742_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
        return tag_of(r.returncode)
    except subprocess.TimeoutExpired:
        return "TIMEOUT"
def save(pe,name):
    p=cave/name; p.write_bytes(bytes(pe)); return p

for pat in ["_t742_*","_d742_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

def nop7(pe,rva):
    o=rva2off(pe,secs,rva)
    ins=list(md.disasm(bytes(pe[o:o+16]),rva))[0]
    assert ins.size==7, (hex(rva),ins.size,ins.mnemonic,ins.op_str)
    pe[o:o+7]=b"\x90"*7

def set_disp32_r9home(pe,rva,disp):
    """4C 89 8D xx xx xx xx  mov [rbp+disp],r9"""
    o=rva2off(pe,secs,rva)
    assert bytes(pe[o:o+3])==bytes.fromhex("4c898d"), bytes(pe[o:o+7]).hex()
    pe[o+3:o+7]=struct.pack("<i", disp)

def set_disp32_at(pe,rva,expected_prefix_hex,disp,size=7):
    o=rva2off(pe,secs,rva)
    pref=bytes.fromhex(expected_prefix_hex)
    assert bytes(pe[o:o+len(pref)])==pref, (hex(rva),bytes(pe[o:o+size]).hex())
    # displacement is last 4 bytes of 7-byte insn for 4c898d / 8b8d etc
    pe[o+size-4:o+size]=struct.pack("<i", disp)

# A) Capless SoftCap call site — find real alignment
P("=== A Capless SoftCap call site (scan) ===")
# known from prior: mov r9,[rbp+0x460] @576669; call SoftCap ~576692
off=rva2off(base,secs,0x576669)
for insn in md.disasm(bytes(base[off:off+0x90]),0x576669):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x5766f5: break

# Capless epi region
P("\n=== A2 Capless epi @578260 ===")
off=rva2off(base,secs,0x578250)
for insn in md.disasm(bytes(base[off:off+0x50]),0x578250):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x578290: break

# B) dense probes after 576746 under dual
P("\n=== B dual post-576746 dense ===")
def dual():
    pe=bytearray(base); nop7(pe,0x2be53e); nop7(pe,0x2c6174); return pe
probes=[0x576746,0x57674b,0x576751,0x576758,0x576764,0x57676b,0x576777,
        0x57679d,0x5767a0,0x5767a5,0x578278,0x123781,
        0x2be911,0x2c66a7,0x576697]
for rva in probes:
    pe=dual(); pe[rva2off(pe,secs,rva)]=0xCC
    h=save(pe,f"_d742_{rva:x}.exe")
    tf,_,_=run(h,"_var_fwd.x"); tl,_,_=run(h,"_var_let.x")
    P(f"  dual INT3@{rva:06x} fwd={tf:8s} let={tl:8s}")

# C) @2c614f r9 uses — confirm read sites
P("\n=== C @2c614f [rbp+0x138] read sites ===")
# scan 2c614f..2c66a8 for 138 displacement
off=rva2off(base,secs,0x2c614f)
end=rva2off(base,secs,0x2c66a8)
chunk=bytes(base[off:end])
# look for 8d 38 01 00 00 or 8b ?? 38 01 00 00 patterns in disasm
for insn in md.disasm(chunk,0x2c614f):
    if "0x138" in insn.op_str:
        P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str} raw={bytes(base[rva2off(base,secs,insn.address):rva2off(base,secs,insn.address)+insn.size]).hex()}")

# SoftCap [rbp+0xf8] reads
P("\n=== C2 SoftCap [rbp+0xf8] sites ===")
off=rva2off(base,secs,0x2be519)
end=rva2off(base,secs,0x2be912)
for insn in md.disasm(bytes(base[off:end]),0x2be519):
    if "0xf8" in insn.op_str:
        P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str} raw={bytes(base[rva2off(base,secs,insn.address):rva2off(base,secs,insn.address)+insn.size]).hex()}")

P(f"\nelapsed_mid={time.time()-T0:.1f}s")

# D) Plant candidates — dual retarget (preserve values, avoid Capless[rsp+0x20])
# SoftCap: [rbp+0xb0] (r9b0 prior) — own frame, call_rsp-0x28
# @2c614f: need slot where home+reads share disp; safe: [rbp+0x100]
#   frame sub 0x190, lea +0x80 → local range roughly [rbp-0x80 .. rbp+0x110]
#   homes use 0x120..0x138; 0x100 is below homes, in zero? check if zeroed
#   Safer: [rbp+0x110] or [rbp+0x118] unused
#   Math: [rbp+0x100]=call_rsp-0x118+0x100=call_rsp-0x18 = Capless[rsp-0x18] = SoftCap/@2c own stack (below Capless rsp) OK
#   Patch: home@2c6174, cmp@2c618f, use@2c6669 — all disp 0x138→0x100

P("\n=== D plant: SoftCap r9→[rbp+0xb0] + @2c r9→[rbp+0x100] (3 sites) ===")
pe=bytearray(base)
set_disp32_r9home(pe,0x2be53e,0xb0)  # SoftCap r9b0
set_disp32_r9home(pe,0x2c6174,0x100) # @2c home
# cmp qword [rbp+0x138],0 @2c618f = 48 83 bd 38 01 00 00 00 (8 bytes)
o=rva2off(pe,secs,0x2c618f)
raw=bytes(pe[o:o+8]); P(f"  cmp@2c618f raw={raw.hex()}")
assert raw[:3]==bytes.fromhex("4883bd") and raw[3:7]==struct.pack("<i",0x138), raw.hex()
pe[o+3:o+7]=struct.pack("<i",0x100)
# mov ecx, [rbp+0x138] @2c6669 = 8b 8d 38 01 00 00 (6 bytes)
o=rva2off(pe,secs,0x2c6669)
raw=bytes(pe[o:o+6]); P(f"  mov@2c6669 raw={raw.hex()}")
assert raw[:2]==bytes.fromhex("8b8d") and raw[2:6]==struct.pack("<i",0x138), raw.hex()
pe[o+2:o+6]=struct.pack("<i",0x100)
h=save(pe,"host_2c_rt100.exe")
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"  sha={sha}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,outx=run(h,src)
    rt=run_bin(outx) if tag=="OK" and outx else "-"
    P(f"  rt100/{src:14s} {tag:8s} USER={sh} run={rt}")

# E) SoftCap r9→[rbp+0xb0] alone + @2c nop (compare)
P("\n=== E SoftCap r9b0 + @2c nop7 ===")
pe=bytearray(base)
set_disp32_r9home(pe,0x2be53e,0xb0)
nop7(pe,0x2c6174)
h=save(pe,"host_2c_r9b0_2cnop.exe")
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"  sha={sha}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,outx=run(h,src)
    rt=run_bin(outx) if tag=="OK" and outx else "-"
    P(f"  r9b0+2cnop/{src:14s} {tag:8s} USER={sh} run={rt}")

# F) dual retarget SoftCap [rbp+0xb0] + @2c [rbp+0x100] with SoftCap also patching any 0xf8 reads (if only home, OK)
# Already D. Try SoftCap [rbp+0xc0] + @2c [rbp+0x100]
P("\n=== F SoftCap r9→[rbp+0xc0] + @2c rt100 ===")
pe=bytearray(base)
set_disp32_r9home(pe,0x2be53e,0xc0)
set_disp32_r9home(pe,0x2c6174,0x100)
o=rva2off(pe,secs,0x2c618f); pe[o+3:o+7]=struct.pack("<i",0x100)
o=rva2off(pe,secs,0x2c6669); pe[o+2:o+6]=struct.pack("<i",0x100)
h=save(pe,"host_2c_r9c0_rt100.exe")
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"  sha={sha}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,outx=run(h,src)
    rt=run_bin(outx) if tag=="OK" and outx else "-"
    P(f"  r9c0+rt100/{src:14s} {tag:8s} USER={sh} run={rt}")

# G) Capless-side: after writing [rsp+0x20]=[4b0], also mov r9, [rsp+0x20] before SoftCap
# so SoftCap r9 home writes [4b0] back (= no-op smash). Prior note: SoftCap needs pointer in r9 for hit paths.
# For miss-only kind 0x30, r9 home value may not matter for SoftCap logic — but smash value matters for Capless.
# Isol: Capless set r9 = dword/qword from [rsp+0x20] before SoftCap (overwrite pointer with [4b0]).
# At @576669: mov r9, [rbp+0x460] = 4c 8b 8d 60 04 00 00
# Replace with: mov r9d, [rsp+0x20]; nop; nop  OR movsxd r9, dword [rsp+0x20]
# mov r9d,[rsp+0x20] = 44 8b 4c 24 20 (5 bytes); need 7: 44 8b 4c 24 20 90 90
P("\n=== G Capless r9=[rsp+0x20] before SoftCap (no SoftCap/@2c patch) ===")
pe=bytearray(base)
o=rva2off(pe,secs,0x576669)
raw=bytes(pe[o:o+7]); P(f"  @576669 raw={raw.hex()}")
assert raw==bytes.fromhex("4c8b8d60040000"), raw.hex()
pe[o:o+7]=bytes.fromhex("448b4c24209090")  # mov r9d,[rsp+0x20]; nop; nop
h=save(pe,"host_2c_cap_r9stack.exe")
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"  sha={sha}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,outx=run(h,src)
    rt=run_bin(outx) if tag=="OK" and outx else "-"
    P(f"  cap_r9stk/{src:14s} {tag:8s} USER={sh} run={rt}")
# locus SoftCap pop
pe2=bytearray(pe); pe2[rva2off(pe2,secs,0x2be911)]=0xCC
h2=save(pe2,"_d742_capr9_pop.exe")
P(f"  cap_r9stk INT3@scs_pop fwd={run(h2,'_var_fwd.x')[0]} let={run(h2,'_var_let.x')[0]}")

# H) Capless r9=[rsp+0x20] + @2c rt100 (no SoftCap nop)
P("\n=== H Capless r9=[rsp+0x20] + @2c rt100 ===")
pe=bytearray(base)
o=rva2off(pe,secs,0x576669); pe[o:o+7]=bytes.fromhex("448b4c24209090")
set_disp32_r9home(pe,0x2c6174,0x100)
o=rva2off(pe,secs,0x2c618f); pe[o+3:o+7]=struct.pack("<i",0x100)
o=rva2off(pe,secs,0x2c6669); pe[o+2:o+6]=struct.pack("<i",0x100)
h=save(pe,"host_2c_capr9_rt100.exe")
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"  sha={sha}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,outx=run(h,src)
    rt=run_bin(outx) if tag=="OK" and outx else "-"
    P(f"  capr9+rt100/{src:14s} {tag:8s} USER={sh} run={rt}")
pe2=bytearray(pe); pe2[rva2off(pe2,secs,0x2be911)]=0xCC
h2=save(pe2,"_d742_h_pop.exe")
P(f"  capr9+rt100 INT3@scs_pop fwd={run(h2,'_var_fwd.x')[0]} let={run(h2,'_var_let.x')[0]}")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t742_*","_d742_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
