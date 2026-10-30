"""DIG SoftCap @24b49d summand feeders: why thin base 0x28/0x178 != SoftCap 0x828.
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

def plant_int3(baseb,rvas,label):
    pe2=bytearray(baseb); s=pe_secs(pe2)
    for r in rvas: pe2[rva2off(pe2,s,r)]=0xCC
    out=cave/f"_dig_host_sf_{label}.exe"; out.write_bytes(pe2); return out

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
    for p in list(cave.glob("_dig_host_sf_*.exe"))+list(cave.glob("_tmp__dig_host_sf_*"))+list(cave.glob("xlang_isol1060_f8_800.exe"))+list(cave.glob("xlang_isol1060_base_828.exe"))+list(cave.glob("_tmp_xlang_isol1060_f8_800_*"))+list(cave.glob("_tmp_xlang_isol1060_base_828_*")):
        try: p.unlink()
        except: pass

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)
print("base alt_frame2 sha12=9378df517f96", flush=True)

print("\n=== STATIC sum formula @24b49d ===", flush=True)
print("  [rbp-0x44] starts 0x10 (arg/spill); mutated by @2a3237", flush=True)
print("  [rbp+0xf0] := @2a2ef3  (locals-ish)", flush=True)
print("  [rbp+0xec] := @27fbc5  (spill/stack pool)", flush=True)
print("  [rbp+0xdc] := @2a3077", flush=True)
print("  [rbp+0xd8] := @27ef44", flush=True)
print("  [rbp+0xfc] := (-44)+f0+dc+d8 ; align16", flush=True)
print("  [rbp+0xf8] := from ec: 0 | ec+0x100 | CLAMP 0x800 if ec>0x3ff", flush=True)
print("  eax := fc + f8 + 0x40   (@24b9c7)", flush=True)
print("  DELTA SoftCap_base 0x828 - thin 0x28 = 0x800 == f8 clamp", flush=True)
print("  => thin lit: f8~0 (ec small); SoftCap needs ec>0x3ff path OR forced f8=0x800", flush=True)
print("  NO imm 0x28/0x178/0x828 on-path — all computed", flush=True)

sites=[
    (0x24b88c,"call_mut_2a3237"),
    (0x24b8a1,"call_f0_2a2ef3"),
    (0x24b8bc,"call_ec_27fbc5"),
    (0x24b8e6,"call_dc_2a3077"),
    (0x24b901,"call_d8_27ef44"),
    (0x24b927,"store_fc"),
    (0x24b971,"store_f8"),
    (0x24b998,"clamp_f8_800"),
    (0x24b9bb,"add_f8_to_fc"),
    (0x24b9c1,"load_fc"),
    (0x24b9c7,"add40"),
    (0x2a2ef3,"fn_f0"),
    (0x27fbc5,"fn_ec"),
    (0x2a3077,"fn_dc"),
    (0x27ef44,"fn_d8"),
]
print("\n=== INT3 lit (timeout=5s/site) ===", flush=True)
hits=[]
for rva,name in sites:
    if time.time()-T0>BUDGET-30: print("BUDGET stop", flush=True); break
    t1=time.time()
    tag,sh,b,n68,n1b8,n868=run(plant_int3(base,[rva],name),timeout=5)
    mark=" HIT" if tag=="INT3" else (f" **{tag}**" if tag in("AV","GS","TIMEOUT") else "")
    if tag=="INT3": hits.append((rva,name))
    print(f"  @{rva:06x} {name:22s} -> {tag}{mark} n68={n68} n1b8={n1b8} n868={n868} ({time.time()-t1:.1f}s)", flush=True)

print(f"HITs: {[(hex(r),n) for r,n in hits]}", flush=True)

# Plant f8_800: @24b977 cmp+jle (9B) -> jmp clamp800 @24b998; nops
print("\n=== plant f8_800 @24b977 -> jmp @24b998 ===", flush=True)
o=rva2off(base,secs,0x24b977)
orig=bytes(base[o:o+9])
print(f"  orig @{0x24b977:06x}: {orig.hex()}", flush=True)
# expect 83bdec000000007e35
if orig==bytes.fromhex("83bdec000000007e35"):
    pe2=bytearray(base)
    # jmp rel8 to 0x24b998: from 0x24b979 -> rel=0x1f
    pe2[o:o+9]=bytes.fromhex("eb1f90909090909090")
    outp=cave/"xlang_isol1060_f8_800.exe"
    outp.write_bytes(pe2)
    sha=hashlib.sha256(bytes(pe2)).hexdigest()
    print(f"  plant f8_800 sha12={sha[:12]}", flush=True)
    for insn in md.disasm(bytes(pe2[o:o+12]), 0x24b977):
        print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)
    print("\n=== f8_800 SoftCap p_ret_* (timeout=8s) ===", flush=True)
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
        if time.time()-T0>BUDGET-12: break
        t1=time.time()
        tag,sh,b,n68,n1b8,n868=run(outp,src,timeout=8)
        print(f"  {src:16s} {tag:8s} sha={sh} n68={n68} n1b8={n1b8} n868={n868} ({time.time()-t1:.1f}s)", flush=True)
else:
    print(f"  UNEXPECTED {orig.hex()} — skip f8_800", flush=True)

# Plant base_828: @24b9c1 mov eax,[rbp+0xfc] (6B) -> mov eax,0x828; nop
print("\n=== plant base_828 @24b9c1 ===", flush=True)
o=rva2off(base,secs,0x24b9c1)
orig=bytes(base[o:o+6])
print(f"  orig @{0x24b9c1:06x}: {orig.hex()}", flush=True)
if orig==bytes.fromhex("8b85fc000000"):
    pe2=bytearray(base)
    pe2[o:o+6]=bytes.fromhex("b82808000090")  # mov eax,0x828; nop
    outp=cave/"xlang_isol1060_base_828.exe"
    outp.write_bytes(pe2)
    sha=hashlib.sha256(bytes(pe2)).hexdigest()
    print(f"  plant base_828 sha12={sha[:12]}", flush=True)
    for insn in md.disasm(bytes(pe2[o:o+10]), 0x24b9c1):
        print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)
    print("\n=== base_828 SoftCap p_ret_* (timeout=8s) ===", flush=True)
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
        if time.time()-T0>BUDGET-5: break
        t1=time.time()
        tag,sh,b,n68,n1b8,n868=run(outp,src,timeout=8)
        print(f"  {src:16s} {tag:8s} sha={sh} n68={n68} n1b8={n1b8} n868={n868} ({time.time()-t1:.1f}s)", flush=True)
else:
    print(f"  UNEXPECTED {orig.hex()} — skip base_828", flush=True)

print("\n=== baseline alt_frame2 p_ret_lit ===", flush=True)
tag,sh,b,n68,n1b8,n868=run(cave/"xlang_isol1060_alt_frame2.exe","p_ret_lit.x",timeout=8)
print(f"  lit {tag} sha={sh} n68={n68} n1b8={n1b8} n868={n868}", flush=True)

print(f"\nelapsed={time.time()-T0:.1f}s DONE", flush=True)
clean()
print("EXIT:0", flush=True)
