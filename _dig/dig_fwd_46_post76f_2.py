#!/usr/bin/env python3
"""DIG fwd_46_post76f #2: nail call@46a99d; surgical plants for USER run GS.
Budget<=85s."""
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
    out=cave/f"_t762_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
def gate(h,label,srcs=None):
    sha=hashlib.sha256(h.read_bytes()).hexdigest()[:12]
    P(f"  [{label}] sha={sha}")
    rows={}
    for src in (srcs or ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]):
        if not (cave/src).exists(): continue
        tag,sh,outx=run(h,src)
        rt=run_bin(outx) if tag=="OK" and outx else "-"
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}")
        rows[src]=(tag,rt,sh)
    return sha,rows
def hollow_at(pe,secs,hijack,epi=0x46af5d):
    oh=rva2off(pe,secs,hijack)
    rel=epi-(hijack+7)
    pe[oh:oh+7]=bytes([0x31,0xc0,0xe9])+struct.pack("<i",rel)
    return pe
def skip_call(pe,secs,rva):
    o=rva2off(pe,secs,rva)
    assert pe[o]==0xE8, hex(rva)
    pe[o:o+5]=bytes.fromhex("31c0909090")
def find_disp_off(pe,secs,rva,expect_disp):
    o=rva2off(pe,secs,rva)
    ins=list(md.disasm(bytes(pe[o:o+16]),rva))[0]
    raw=bytes(pe[o:o+ins.size])
    idx=raw.find(struct.pack("<i", expect_disp))
    assert idx>=0, (hex(rva),ins.op_str,raw.hex())
    return o+idx, ins
def patch_disp(pe,secs,rva,old_d,new_d):
    off,_=find_disp_off(pe,secs,rva,old_d)
    pe[off:off+4]=struct.pack("<i", new_d)
def collect_disp_sites(pe,secs,start,nbytes,disp):
    off=rva2off(pe,secs,start); out=[]
    for insn in md.disasm(bytes(pe[off:off+nbytes]),start):
        o=rva2off(pe,secs,insn.address)
        raw=bytes(pe[o:o+insn.size])
        if struct.pack("<i",disp) in raw and "rbp" in insn.op_str:
            out.append(insn.address)
    return out
def make_b0_h2c(pe,secs):
    patch_disp(pe,secs,0x2be53e,0xf8,0xb0)
    for r in collect_disp_sites(pe,secs,0x2c614f,0x200,0x138):
        patch_disp(pe,secs,r,0x138,0x100)
    return pe

for pat in ["_t762_*","_d762_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

def plant_skip99d(pe):
    skip_call(pe,secs,0x46a99d); return pe

# A) confirm skip99d + hollow_only refs
P("=== A refs ===")
gate(save(bytearray(base),"host_762_base.exe"),"base")
pe=hollow_at(bytearray(base),secs,0x46a4e3)
gate(save(pe,"host_762_hollow.exe"),"hollow_only")
pe=plant_skip99d(bytearray(base))
gate(save(pe,"host_762_skip99d.exe"),"skip99d")

# B) skip99d + b0_h2c
P("\n=== B skip99d + b0_h2c ===")
pe=make_b0_h2c(bytearray(base),secs); plant_skip99d(pe)
gate(save(pe,"host_762_s99_b0.exe"),"s99_b0")

# C) at 46a97a: xor r8,r8; nop*4  (kill bad ptr into call 47a492) — keep call
P("\n=== C xor_r8 @46a97a (keep call 47a492) ===")
pe=bytearray(base)
o=rva2off(pe,secs,0x46a97a)
assert bytes(pe[o:o+7])==bytes.fromhex("4c8b85a0010000"), bytes(pe[o:o+7]).hex()
pe[o:o+7]=bytes.fromhex("4d31c090909090")  # xor r8,r8; nop*4
gate(save(pe,"host_762_xor_r8.exe"),"xor_r8")

# D) xor r8 @97a + zero 1a8 load at 46a981: mov ecx,[rbp+0x1a8] (6) → xor ecx,ecx; nop*4
P("\n=== D xor_r8 + z_ecx @981 ===")
pe=bytearray(base)
o=rva2off(pe,secs,0x46a97a); pe[o:o+7]=bytes.fromhex("4d31c090909090")
o=rva2off(pe,secs,0x46a981)
assert bytes(pe[o:o+6])==bytes.fromhex("8b8da8010000"), bytes(pe[o:o+6]).hex()
pe[o:o+6]=bytes.fromhex("31c990909090")
gate(save(pe,"host_762_xor_r8_z1a8.exe"),"xor_r8_z1a8")

# E) skip99d + hollow bisect after 99d (USER run GS locus)
P("\n=== E skip99d + hollow after ===")
for rva,name in [(0x46a9c6,"s99_h9c6"),(0x46aa27,"s99_haa27"),
                 (0x46ab77,"s99_hab77"),(0x46af29,"s99_haf29"),(0x46a4e3,"s99_hollow")]:
    if time.time()-T0>55: break
    pe=plant_skip99d(bytearray(base))
    if rva!=0x46a4e3:
        hollow_at(pe,secs,rva)
    else:
        # skip99d alone already; also full hollow for USER compare
        hollow_at(pe,secs,0x46a4e3)
    gate(save(pe,f"host_762_{name}.exe"),name)

# F) Capless write 6th=0: steal — overwrite `mov rcx,rax` (576743: 4889c1) + call
# Better: before call_46, at 57673f window use longer cave elsewhere.
# Plant Capless: change `mov dword [rsp+0x20],ecx` to also set [rsp+0x28] via
# rewrite block 576732..576746 (21 bytes):
#   mov rax,[rbp+0x490] (7)
#   mov ecx,[rbp+0x4b0] (6)
#   mov [rsp+0x20],ecx (4)
#   mov rcx,rax (3)
#   call (5) = 25? Let me measure
P("\n=== F Capless stack args dig sizes ===")
o=rva2off(base,secs,0x576732)
for insn in md.disasm(bytes(base[o:o+40]),0x576732):
    P(f"  {insn.address:06x}: {insn.bytes.hex():20s} {insn.mnemonic} {insn.op_str}")
    if insn.address>=0x57674b: break

# G) Capless: after mov [rsp+0x20],ecx — we need [rsp+0x28] and [rsp+0x30].
# Use: patch call target? No.
# At 46 entry after r9 home, use 8-byte clear at 46a58d to zero 1a0 as qword:
# 48c7450000000000 (mov qword [rbp],0) → 48c785a001000000 (mov qword [rbp+0x1a0],0) 
# wait encoding: 48 c7 85 a0 01 00 00 00 00 00 00 = 11 bytes
# 48 31 c0 48 89 85 a0 01 00 00 = xor rax,rax; mov [rbp+0x1a0],rax = 10 bytes
# Available at 46a58d is 8 bytes only.
# Use TWO consecutive clears 46a58d (8) + 46a595 (8) = 16:
#   xor rax,rax (3: 4831c0); mov [rbp+0x1a0],rax (7: 488985a0010000); mov [rbp+0x1a8],eax (6: 8985a8010000); nop
# 3+7+6=16. Perfect — replaces clears of [rbp] and [rbp+8] (buffer start). Buffer still mostly cleared by following stores.
P("\n=== G zero 1a0/1a8 via buffer-clear slots @58d/@595 ===")
pe=bytearray(base)
o=rva2off(pe,secs,0x46a58d)
assert bytes(pe[o:o+8])==bytes.fromhex("48c7450000000000"), bytes(pe[o:o+8]).hex()
o2=rva2off(pe,secs,0x46a595)
assert bytes(pe[o2:o2+8])==bytes.fromhex("48c7450800000000"), bytes(pe[o2:o2+8]).hex()
# write 16 bytes at 58d:
blob=bytes.fromhex("4831c0488985a00100008985a801000090")  # xor rax,rax; mov [rbp+0x1a0],rax; mov [rbp+0x1a8],eax; nop
assert len(blob)==16
pe[o:o+16]=blob
gate(save(pe,"host_762_z1a0_1a8.exe"),"z1a0_1a8")

# H) z1a0_1a8 + skip99d (belt+suspenders)
P("\n=== H z1a0_1a8 + skip99d ===")
pe=bytearray(base)
o=rva2off(pe,secs,0x46a58d); pe[o:o+16]=blob
plant_skip99d(pe)
gate(save(pe,"host_762_z_s99.exe"),"z_s99")

# I) z1a0_1a8 alone was the surgical hope — also try xor_r8 + z1a0_1a8
P("\n=== I z1a0_1a8 + xor_r8 (no skip) ===")
pe=bytearray(base)
o=rva2off(pe,secs,0x46a58d); pe[o:o+16]=blob
o=rva2off(pe,secs,0x46a97a); pe[o:o+7]=bytes.fromhex("4d31c090909090")
gate(save(pe,"host_762_z_xor.exe"),"z_xor")

# J) if z1a0_1a8 greens compile, hollow leftover for run GS
P("\n=== J z1a0_1a8 + b0_h2c ===")
pe=make_b0_h2c(bytearray(base),secs)
o=rva2off(pe,secs,0x46a58d); pe[o:o+16]=blob
gate(save(pe,"host_762_z_b0.exe"),"z_b0")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t762_*","_d762_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
