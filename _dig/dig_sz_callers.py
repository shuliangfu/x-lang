"""DIG SoftCap @523600 callers / edx size: which on-path; how 0x68/0x1b8 vs 0x868.
Base alt_frame2 9378df517f96. Budget<=85s. Ban tip@121278/join/epi/LIVE/mega/arg-loop.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64)

cave = Path("C:/xlang_tmp/p1060/cave"); os.chdir(str(cave))
T0=time.time(); BUDGET=85
CALLERS=[0x20ee89,0x20f08a,0x238694,0x5b0d49]
STORE828=0x20efaf
LOAD828=0x20f077
HELPER=0x24b49d
ADD40=0x24b9c7  # add eax, 0x40 before ret
CFN=0x523600
PROL=0x50f3e0

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

def plant(baseb,rvas,label):
    pe2=bytearray(baseb); s=pe_secs(pe2)
    for r in rvas: pe2[rva2off(pe2,s,r)]=0xCC
    out=cave/f"_dig_host_szc_{label}.exe"; out.write_bytes(pe2); return out

def run(h,src="p_ret_lit.x",timeout=5):
    out=cave/f"_tmp_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    try:
        r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout)
        crc=r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT","-",b"",0,0,0
    tag={0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc,f"crc={crc:#x}")
    b=out.read_bytes() if out.exists() else b""
    sh=hashlib.sha256(b).hexdigest()[:12] if b else "-"
    n68=b.count(bytes.fromhex("4881ec68000000")) if b else 0
    n1b8=b.count(bytes.fromhex("4881ecb8010000")) if b else 0
    n868=b.count(bytes.fromhex("4881ec68080000")) if b else 0
    return tag,sh,b,n68,n1b8,n868

def clean():
    for p in list(cave.glob("_dig_host_szc_*.exe"))+list(cave.glob("_tmp__dig_host_szc_*"))+list(cave.glob("xlang_isol1060_edx_868.exe"))+list(cave.glob("_tmp_xlang_isol1060_edx_868_*")):
        try: p.unlink()
        except: pass

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)
print(f"base alt_frame2 sha12=9378df517f96", flush=True)

# Static confirm edx at callers (already DIG'd on Mac; reprint key)
print("\n=== STATIC nails (edx into @523600) ===", flush=True)
print("  @20ee89: edx=0 (mode=[rbp+0x7fc]); size-zero path", flush=True)
print("  @20f08a: edx=[rbp+0x828] (mode=[rbp+0x7fc]); REAL size path", flush=True)
print("  @238694: edx=0 (mode=[rbp+0xd4]); size-zero path", flush=True)
print("  @5b0d49: rdx=0x10; small/other use", flush=True)
print("  [rbp+0x828] <- eax from @24b49d (@20efaf); final eax=[rbp+0xfc]+0x40 (@24b9c7)", flush=True)
print("  NO on-path imm 0x68/0x1b8 — thin sizes are computed sum+0x40", flush=True)

# INT3 sites
sites=[
    (0x20ee89,"c_20ee89"),
    (0x20f08a,"c_20f08a"),
    (0x238694,"c_238694"),
    (0x5b0d49,"c_5b0d49"),
    (STORE828,"store828"),
    (LOAD828,"load828"),
    (HELPER,"helper_24b49d"),
    (ADD40,"add40"),
    (CFN,"cfn_523600"),
    (PROL,"prol"),
]
print("\n=== INT3 lit (timeout=5s/site) ===", flush=True)
hits=[]
for rva,name in sites:
    if time.time()-T0>BUDGET-25: print("BUDGET stop", flush=True); break
    t1=time.time()
    tag,sh,b,n68,n1b8,n868=run(plant(base,[rva],name),timeout=5)
    mark=" HIT" if tag=="INT3" else (f" **{tag}**" if tag in("AV","GS","TIMEOUT") else "")
    if tag=="INT3": hits.append((rva,name))
    print(f"  @{rva:06x} {name:20s} -> {tag}{mark} n68={n68} n1b8={n1b8} n868={n868} ({time.time()-t1:.1f}s)", flush=True)

print(f"HITs: {[(hex(r),n) for r,n in hits]}", flush=True)

# Plant edx_868: at @20f077 replace mov edx,[rbp+0x828] (6B) with mov edx,0x868; nop (5+1)
print("\n=== plant edx_868 @20f077 ===", flush=True)
o=rva2off(base,secs,LOAD828)
orig=bytes(base[o:o+6])
print(f"  orig @{LOAD828:06x}: {orig.hex()}", flush=True)
# expect 8b9528080000
if orig==bytes.fromhex("8b9528080000"):
    pe2=bytearray(base)
    pe2[o:o+6]=bytes.fromhex("ba6808000090")  # mov edx,0x868; nop
    outp=cave/"xlang_isol1060_edx_868.exe"
    outp.write_bytes(pe2)
    sha=hashlib.sha256(bytes(pe2)).hexdigest()
    print(f"  plant sha12={sha[:12]}", flush=True)
    # verify disasm
    for insn in md.disasm(bytes(pe2[o:o+8]), LOAD828):
        print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)
    print("\n=== edx_868 SoftCap p_ret_* (timeout=8s) ===", flush=True)
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
        if time.time()-T0>BUDGET-5: break
        if not (cave/src).exists():
            print(f"  {src}: MISSING", flush=True); continue
        t1=time.time()
        tag,sh,b,n68,n1b8,n868=run(outp,src,timeout=8)
        print(f"  {src:16s} {tag:8s} sha={sh} n68={n68} n1b8={n1b8} n868={n868} ({time.time()-t1:.1f}s)", flush=True)
else:
    print(f"  UNEXPECTED bytes {orig.hex()} — skip plant", flush=True)

# baseline confirm
print("\n=== baseline alt_frame2 p_ret_lit ===", flush=True)
tag,sh,b,n68,n1b8,n868=run(cave/"xlang_isol1060_alt_frame2.exe","p_ret_lit.x",timeout=8)
print(f"  lit {tag} sha={sh} n68={n68} n1b8={n1b8} n868={n868}", flush=True)

print(f"\nelapsed={time.time()-T0:.1f}s DONE", flush=True)
clean()
print("EXIT:0", flush=True)
