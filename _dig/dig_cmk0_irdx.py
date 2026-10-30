#!/usr/bin/env python3
"""DIG SoftCap 10.60: cmk0_irdx — Isol-native 8B imm->rdx (no LIVE spill).
USER=b80a0000004889c2; c643 x8; @57ba94 4->8; keep [rbp-0x68]=0x20.
Ban tip@121278/join/epi/LIVE spill/mega/+0x478/[4b0]=1. Budget<=85s.
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
def run(h,src="p_ret_lit.x",timeout=8):
    out=cave/f"_tmp_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    for attempt in range(2):
        try:
            r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout,cwd=str(cave))
            crc=r.returncode&0xFFFFFFFF
        except subprocess.TimeoutExpired:
            return "TIMEOUT","-",b"",0,None
        tag={0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc,f"crc={crc:#x}")
        if tag=="OK" or tag in("INT3","TIMEOUT") or attempt==1: break
        time.sleep(0.3)
    b=out.read_bytes() if out.exists() else b""
    sh=hashlib.sha256(b).hexdigest()[:12] if b else "-"
    n868=b.count(bytes.fromhex("4881ec68080000")) if b else 0
    return tag,sh,b,n868,out if b else None
def run_bin(exe,timeout=5):
    try:
        r=subprocess.run([str(exe)],capture_output=True,timeout=timeout)
        crc=r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT",-1
    return {0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc,f"crc={crc:#x}"), crc
def find_sret(b,label):
    if not b: return False,False
    i=b.find(bytes([0x48,0x8d,0x45,0xd8]))
    if i<0:
        P(f"  {label}: no lea rbp-0x28"); return False,False
    win=b[i:i+0x40]
    P(f"  {label} sret @{i:#x}:")
    for insn in md.disasm(win, i):
        P(f"    @{insn.address:04x}: {insn.mnemonic} {insn.op_str}")
        if insn.address>=i+0x30: break
    has_mov_rdx = bytes.fromhex("4889c2") in win
    has_imm = bytes.fromhex("b80a000000") in win
    has_spill = bytes.fromhex("488945c8") in win
    has_call = b"\xe8" in win
    true = has_imm and has_mov_rdx and not has_spill
    P(f"  {label} imm={has_imm} rdx={has_mov_rdx} spill={has_spill} call={has_call} true_irdx={true}")
    return true, has_call

base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)
P("=== DIG/plant cmk0_irdx ===")
assert bytes(base[rva2off(base,secs,0x57ba34):rva2off(base,secs,0x57ba34)+7])==bytes.fromhex("488d45804889c3")
assert bytes(base[rva2off(base,secs,0x578266):rva2off(base,secs,0x578266)+6])==bytes.fromhex("8b8db0040000")
P("  capacity [rbp-0x80]..[rbp-0x68)=24B; USER8 fits; window 74B; rbx live")

b828=bytearray(base)
b828[rva2off(base,secs,0x24b9c1):rva2off(base,secs,0x24b9c1)+6]=bytes.fromhex("b82808000090")
USER8=bytes.fromhex("b80a0000004889c2"); assert len(USER8)==8
writes=b"".join(bytes([0xc6,0x43,i,x]) for i,x in enumerate(USER8))
tail=bytes.fromhex("b82000000048894598"); pad=74-len(writes)-len(tail)
patch=writes+tail+b"\x90"*pad; assert len(patch)==74
pe=bytearray(b828)
pe[rva2off(pe,pe_secs(pe),0x57ba3b):rva2off(pe,pe_secs(pe),0x57ba3b)+74]=patch
pe[rva2off(pe,pe_secs(pe),0x57ba94):rva2off(pe,pe_secs(pe),0x57ba94)+5]=bytes.fromhex("b808000000")
host=cave/"host_cmk0_irdx.exe"; host.write_bytes(pe)
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"cmk0_irdx sha12={sha} USER8={USER8.hex()} append=8")
time.sleep(1.0)
results=[]
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
    if time.time()-T0>BUDGET-8: break
    tag=sh="-"; n868=0; outx=None; ok_imm=ok_call=False; rtag="-"; rcrc=-1
    for attempt in range(6):
        tag,sh,b,n868,outx=run(host,src,timeout=8)
        if tag=="OK": break
        time.sleep(0.4)
    if tag=="OK" and outx:
        rtag,rcrc=run_bin(outx,timeout=5)
        if "lit" in src: ok_imm, ok_call=find_sret(b,"cmk0_irdx")
    P(f"  {src:16s} {tag:8s} sha={sh} n868={n868} run={rtag}/{rcrc}")
    results.append((src,tag,sh,n868,rtag,rcrc,ok_imm,ok_call))
if time.time()-T0<BUDGET-10:
    pe2=bytearray(pe); pe2[rva2off(pe2,pe_secs(pe2),0x57ba3b)]=0xCC
    probe=cave/"_dig_cmk0i_i57ba3b.exe"; probe.write_bytes(pe2)
    tag,_,_,_,_=run(probe,"p_ret_lit.x",timeout=6)
    P(f"INT3 @57ba3b -> {tag}")
lit=[r for r in results if "lit" in r[0]]
P("=== VERDICT ===")
if lit:
    src,tag,sh,n868,rtag,rcrc,ok_imm,ok_call=lit[0]
    green = tag=="OK" and rtag=="OK" and rcrc==0 and ok_imm and ok_call
    P(f"cmk0_irdx lit compile={tag} run={rtag}/{rcrc} immrdx={ok_imm} GREEN={green}")
P(f"elapsed={time.time()-T0:.1f}s")
for pat in ["_dig_cmk0i_*","_tmp_host_cmk0*","_tmp__dig_cmk0i_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
