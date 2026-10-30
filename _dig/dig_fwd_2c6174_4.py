#!/usr/bin/env python3
"""DIG fwd_2c6174 #4: SoftCap prol cookie?; correct disp patches; 46a4db smash;
triple/chain Isol. Budget<=85s."""
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
    out=cave/f"_t744_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
def gate(h,label):
    sha=hashlib.sha256(h.read_bytes()).hexdigest()[:12]
    P(f"  [{label}] sha={sha}")
    rows=[]
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
        tag,sh,outx=run(h,src)
        rt=run_bin(outx) if tag=="OK" and outx else "-"
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}")
        rows.append((src,tag,rt))
    return rows

for pat in ["_t744_*","_d744_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

def patch_disp32(pe,rva,old_disp,new_disp):
    """Patch disp32 in insn at rva; supports 7-byte mov/lea and 8-byte cmp imm8.
    Disp always at +3 for 4C/48 rex + opcode + modrm forms used here."""
    o=rva2off(pe,secs,rva)
    # detect size via disasm
    ins=list(md.disasm(bytes(pe[o:o+16]),rva))[0]
    assert ins.address==rva
    cur=struct.unpack_from("<i",pe,o+3)[0]
    assert cur==old_disp, (hex(rva),hex(cur),hex(old_disp),ins.mnemonic,ins.op_str,bytes(pe[o:o+ins.size]).hex())
    pe[o+3:o+7]=struct.pack("<i", new_disp)
    return ins

def nop_ins(pe,rva):
    o=rva2off(pe,secs,rva)
    ins=list(md.disasm(bytes(pe[o:o+16]),rva))[0]
    pe[o:o+ins.size]=b"\x90"*ins.size
    return ins

# A) SoftCap full prol — cookie store?
P("=== A SoftCap prol full ===")
off=rva2off(base,secs,0x2be519)
for insn in md.disasm(bytes(base[off:off+0x120]),0x2be519):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x2be630: break

# B) INT3 miss jmp @2be739 — does fwd take miss?
P("\n=== B miss-path hit check ===")
pe=bytearray(base); pe[rva2off(pe,secs,0x2be734)]=0xCC  # mov eax,0 on miss
h=save(pe,"_d744_miss.exe")
P(f"  INT3@2be734(miss) fwd={run(h,'_var_fwd.x')[0]} let={run(h,'_var_let.x')[0]}")
pe=bytearray(base); pe[rva2off(pe,secs,0x2be739)]=0xCC  # jmp epi
h=save(pe,"_d744_jepi.exe")
P(f"  INT3@2be739(jepi) fwd={run(h,'_var_fwd.x')[0]} let={run(h,'_var_let.x')[0]}")

# C) 46a4db frame math + r9d home
P("\n=== C 46a4db smash math ===")
# rbp=call_rsp-0x178; [rbp+0x198]=call_rsp+0x20
P("  [rbp+0x198] = call_rsp+0x20 = Capless[rsp+0x20] (r9d home) ISOMORPHIC")
# find all 0x198 sites in 46a4db..epi
off=rva2off(base,secs,0x46a4db)
# estimate function end ~0x200 bytes or find ret
sites_198=[]
for insn in md.disasm(bytes(base[off:off+0x400]),0x46a4db):
    if "0x198" in insn.op_str:
        sites_198.append(insn)
        P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str} sz={insn.size}")
    if insn.mnemonic=="ret" and insn.address>0x46a520:
        P(f"  RET {insn.address:06x}")
        break

# D) plant: SoftCap 0xf8→0xb0 all + @2c 0x138→0x100 all + 46a4db 0x198→0x160 all
P("\n=== D plant chain_rt: scs+2c+46a4db retarget ===")
pe=bytearray(base)
scs=[0x2be53e,0x2be7f5,0x2be832,0x2be850]
for r in scs:
    ins=patch_disp32(pe,r,0xf8,0xb0); P(f"  scs {ins.address:06x} {ins.mnemonic} →0xb0")
h2c=[0x2c6174,0x2c618f,0x2c6514,0x2c654c,0x2c6668]
for r in h2c:
    ins=patch_disp32(pe,r,0x138,0x100); P(f"  h2c {ins.address:06x} {ins.mnemonic} →0x100")
# 46a4db: retarget 0x198 → 0x160 (call_rsp-0x178+0x160=call_rsp-0x18 = own stack)
for insn in sites_198:
    ins=patch_disp32(pe,insn.address,0x198,0x160); P(f"  c46 {ins.address:06x} {ins.mnemonic} →0x160")
h=save(pe,"host_2c_chain_rt.exe")
rows=gate(h,"chain_rt")
# loci
for rva,name in [(0x2be911,"scs_pop"),(0x2c66a7,"h2c_pop"),(0x57674b,"after_46"),(0x578278,"cap_epi"),(0x123781,"caller")]:
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
    tf,_,_=run(save(pe2,f"_d744_{name}.exe"),"_var_fwd.x")
    tl,_,_=run(save(pe2,f"_d744_{name}.exe"),"_var_let.x")
    P(f"  chain INT3@{rva:06x} {name:10s} fwd={tf:8s} let={tl:8s}")

# E) triple nop SoftCap + 2c + 46a4db r9 home only
P("\n=== E triple nop homes ===")
pe=bytearray(base)
for r in (0x2be53e,0x2c6174,0x46a500):
    ins=nop_ins(pe,r); P(f"  nop {ins.address:06x} {ins.mnemonic} {ins.op_str} sz={ins.size}")
h=save(pe,"host_2c_triple_nop.exe")
gate(h,"triple")
for rva,name in [(0x2be911,"scs_pop"),(0x57674b,"after_46"),(0x578278,"cap_epi"),(0x123781,"caller")]:
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
    tf,_,_=run(save(pe2,f"_d744_t{name}.exe"),"_var_fwd.x")
    tl,_,_=run(save(pe2,f"_d744_t{name}.exe"),"_var_let.x")
    P(f"  triple INT3@{rva:06x} {name:10s} fwd={tf:8s} let={tl:8s}")

# F) next callee after 46a4db success: 0x493d31 — check isomorphic too
P("\n=== F callee 0x493d31 prol ===")
off=rva2off(base,secs,0x493d31)
for insn in md.disasm(bytes(base[off:off+0x40]),0x493d31):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x493d80: break

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t744_*","_d744_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
