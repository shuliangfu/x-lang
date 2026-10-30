#!/usr/bin/env python3
"""DIG11: verify nopr9 bytes; slow careful gate; try redirect r9 home in-frame.
Budget<=55s.
"""
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
def run(h,src,timeout=10):
    out=cave/f"_t11_{h.stem}_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
    try:
        r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout,cwd=str(cave))
        b=out.read_bytes() if out.exists() else b""
        sh=hashlib.sha256(b).hexdigest()[:12] if b else "-"
        return tag_of(r.returncode), sh, out if b else None, r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT","-",None,-1
def run_bin(exe,timeout=3):
    try:
        r=subprocess.run([str(exe)],capture_output=True,timeout=timeout)
        return tag_of(r.returncode), r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT",-1

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)
o=rva2off(base,secs,0x2be53e)
P(f"base@2be53e={bytes(base[o:o+7]).hex()} disasm={[f'{i.mnemonic} {i.op_str}' for i in md.disasm(bytes(base[o:o+7]),0x2be53e)]}")

# Rebuild nopr9 carefully
pe=bytearray(base)
pe[o:o+7]=b"\x90"*7
P(f"nopr9@2be53e={bytes(pe[o:o+7]).hex()}")
# ensure neighbors intact
P(f"nopr9@2be537={bytes(pe[rva2off(pe,secs,0x2be537):rva2off(pe,secs,0x2be537)+7]).hex()}")
P(f"nopr9@2be545={bytes(pe[rva2off(pe,secs,0x2be545):rva2off(pe,secs,0x2be545)+11]).hex()}")
h=cave/"host_scs_nopr9.exe"; h.write_bytes(bytes(pe))
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"sha12={sha} size={h.stat().st_size}")

P("\n=== nopr9 gate ===")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,outx,rc=run(h,src)
    rt="-";
    if tag=="OK" and outx: rt,_=run_bin(outx)
    P(f"  {src:14s} {tag:8s} rc={rc:#x} USER={sh} run={rt}")

# Redirect r9 home to SoftCap-local [rbp-0x50] (in zero range, SoftCap-owned)
# encoding: 4c 89 8d f8 00 00 00 → 4c 89 8d b0 ff ff ff  ([rbp-0x50])
P("\n=== r9retarget [rbp-0x50] ===")
pe2=bytearray(base)
raw=bytes(base[o:o+7])
P(f"raw={raw.hex()}")
# [rbp-0x50] = 4C 89 8D B0 FF FF FF
pe2[o:o+7]=bytes.fromhex("4c898db0ffffff")
h2=cave/"host_scs_r9ret.exe"; h2.write_bytes(bytes(pe2))
sha2=hashlib.sha256(bytes(pe2)).hexdigest()[:12]
P(f"r9ret sha12={sha2}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,outx,rc=run(h2,src)
    rt="-";
    if tag=="OK" and outx: rt,_=run_bin(outx)
    P(f"  r9ret/{src:14s} {tag:8s} USER={sh} run={rt}")
pe3=bytearray(pe2); pe3[rva2off(pe3,secs,0x2be911)]=0xCC
h3=cave/"_d11_pop.exe"; h3.write_bytes(bytes(pe3))
tf,_,_,_=run(h3,"_var_fwd.x"); tl,_,_,_=run(h3,"_var_let.x")
P(f"  r9ret INT3@pop fwd={tf} let={tl}")

# Redirect r9 home to [rbp+0xb0] (SoftCap zero area, still own frame; Capless[rbp-0xa8])
# SoftCap[rbp+0xb0]=call_rsp-0xd8+0xb0=call_rsp-0x28 = Capless[rsp-0x28] = SoftCap own stack below call
P("\n=== r9retarget [rbp+0xb0] ===")
pe2=bytearray(base)
pe2[o:o+7]=bytes.fromhex("4c898db0000000")  # [rbp+0xb0]
h2=cave/"host_scs_r9b0.exe"; h2.write_bytes(bytes(pe2))
sha2=hashlib.sha256(bytes(pe2)).hexdigest()[:12]
P(f"r9b0 sha12={sha2}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,outx,rc=run(h2,src)
    rt="-";
    if tag=="OK" and outx: rt,_=run_bin(outx)
    P(f"  r9b0/{src:14s} {tag:8s} USER={sh} run={rt}")
pe3=bytearray(pe2); pe3[rva2off(pe3,secs,0x2be911)]=0xCC
h3=cave/"_d11_pop2.exe"; h3.write_bytes(bytes(pe3))
tf,_,_,_=run(h3,"_var_fwd.x"); tl,_,_,_=run(h3,"_var_let.x")
P(f"  r9b0 INT3@pop fwd={tf} let={tl}")

# Capless: after writing [rsp+0x20]=[4b0], save it; SoftCap r9 home overwrites; Capless restores?
# Isol Capless: don't use SoftCap; instead fix SoftCap by not overwriting — already tried nop.
# Isol Capless before SoftCap: mov r9, [rsp+0x20] so SoftCap homes write same value back?
# Capless r9 currently from [rbp+0x460]. SoftCap overwrites Capless[rsp+0x20] which held [4b0].
# If Capless set r9 = [rsp+0x20] (=[4b0]) before SoftCap, SoftCap r9 home would write [4b0] back — no-op smash.
P("\n=== Capless r9=[rsp+0x20] before SoftCap call ===")
# At @576669: mov r9, [rbp+0x460] = 4c 8b 8d 60 04 00 00 (7 bytes)
# Replace with: mov r9d, [rsp+0x20]; movsxd? or mov r9, qword [rsp+0x20]
# [rsp+0x20] holds dword from [4b0]. SoftCap expects qword r9 (pointer from 0x460)!
# Swapping would break SoftCap hit paths that need the pointer.
# Instead: Capless after SoftCap returns, the smash already happened.
# SoftCap epi GS happens DURING SoftCap — Capless restore after won't help SoftCap epi.

# Try: SoftCap r9 home write AFTER saving Capless [rsp+0x20] to SoftCap local, then restore before epi
# Too big for single-point plant.

P(f"\nelapsed={time.time()-T0:.1f}s")
for p in list(cave.glob("_t11_*"))+list(cave.glob("_d11_*")):
    try: p.unlink()
    except: pass
P("cleaned")
