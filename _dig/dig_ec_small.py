"""DIG SoftCap: why lit @27fbc5 ec stays small (no 0x800 clamp); plant ec_400.
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
LOG=[]
def P(*a):
    s=" ".join(str(x) for x in a)
    print(s, flush=True); LOG.append(s)

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
    out=cave/f"_dig_host_ec_{label}.exe"; out.write_bytes(pe2); return out

def run(h,src="p_ret_lit.x",timeout=5):
    out=cave/f"_tmp_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    try:
        r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout)
        crc=r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT","-",b"",0,0,0,None
    tag={0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc,f"crc={crc:#x}")
    b=out.read_bytes() if out.exists() else b""
    sh=hashlib.sha256(b).hexdigest()[:12] if b else "-"
    n68=b.count(bytes.fromhex("4881ec68000000")) if b else 0
    n1b8=b.count(bytes.fromhex("4881ecb8010000")) if b else 0
    n868=b.count(bytes.fromhex("4881ec68080000")) if b else 0
    return tag,sh,b,n68,n1b8,n868,out if b else None

def run_bin(exe,timeout=5):
    try:
        r=subprocess.run([str(exe)],capture_output=True,timeout=timeout)
        return r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return 0xDEAD0001
    except Exception as e:
        return -1

def clean():
    for p in list(cave.glob("_dig_host_ec_*.exe"))+list(cave.glob("_tmp__dig_host_ec_*"))+list(cave.glob("xlang_isol1060_ec_400.exe"))+list(cave.glob("_tmp_xlang_isol1060_ec_400_*"))+list(cave.glob("_chk_lit_base.exe")):
        try: p.unlink()
        except: pass

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)
P("base alt_frame2 sha12=9378df517f96")

P("\n=== STATIC @27fbc5 ec (spill pool) ===")
P("  sole caller E8 @24b8bc -> store [rbp+0xec]")
P("  body: walk worklist (seeded by mode edx); per-node call @27ea1e (accum spill bytes into globals)")
P("  ret @2804dc: mov eax,[rip+0x8f51ca]  (= global spill counter RVA 0xb756ac)")
P("  => ec = GLOBAL counter after walk; NOT an imm size")
P("  sum @24b49d: f8 from ec: 0 | ec+0x100 | CLAMP 0x800 if ec>0x3ff && f8<=0x7ff")
P("  lit thin: ec small (<=0x3ff) => no clamp; SoftCap pad needs ec>0x3ff OR forced f8")

# INT3 probes
sites=[
    (0x27fbc5,"fn_ec_entry"),
    (0x24b8bc,"call_ec"),
    (0x24b8c1,"store_ec"),   # may be mid-insn; check
    (0x2804dc,"ret_load_global"),
    (0x27ea1e,"acc_27ea1e"),
    (0x24b998,"clamp_f8_800"),
    (0x24b9a4,"ec_plus_100"),
    (0x24b97e,"jle_ec_le0"),
]
# verify store_ec is real insn start
o=rva2off(base,secs,0x24b8bc)
P(f"\nbytes @24b8bc: {bytes(base[o:o+16]).hex()}")
for insn in md.disasm(bytes(base[o:o+24]),0x24b8bc):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    if insn.address>=0x24b8d0: break

P("\n=== INT3 lit (timeout=5s/site) ===")
hits=[]
for rva,name in sites:
    if time.time()-T0>BUDGET-35: P("BUDGET stop"); break
    t1=time.time()
    tag,sh,b,n68,n1b8,n868,_=run(plant_int3(base,[rva],name),timeout=5)
    mark=" HIT" if tag=="INT3" else (f" **{tag}**" if tag in("AV","GS","TIMEOUT") else "")
    if tag=="INT3": hits.append((rva,name))
    P(f"  @{rva:06x} {name:18s} -> {tag}{mark} n68={n68} n1b8={n1b8} n868={n868} ({time.time()-t1:.1f}s)")
P(f"HITs: {[(hex(r),n) for r,n in hits]}")

# Plant ec_400: @2804dc mov eax,[rip+..] (6B) -> mov eax,0x400; nop
P("\n=== plant ec_400 @2804dc ===")
o=rva2off(base,secs,0x2804dc)
orig=bytes(base[o:o+6])
P(f"  orig @{0x2804dc:06x}: {orig.hex()}")
assert orig==bytes.fromhex("8b05ca518f00"), orig.hex()
pe2=bytearray(base)
pe2[o:o+6]=bytes.fromhex("b80004000090")  # mov eax,0x400; nop
outp=cave/"xlang_isol1060_ec_400.exe"
outp.write_bytes(pe2)
sha=hashlib.sha256(bytes(pe2)).hexdigest()
P(f"  plant ec_400 sha12={sha[:12]}")
for insn in md.disasm(bytes(pe2[o:o+12]),0x2804dc):
    P(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

P("\n=== ec_400 SoftCap p_ret_* compile (timeout=8s) + run (<=8s) ===")
plant_results=[]
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
    if time.time()-T0>BUDGET-8: P("BUDGET stop plants"); break
    t1=time.time()
    tag,sh,b,n68,n1b8,n868,out=run(outp,src,timeout=8)
    run_rc="-"
    rdx=n48b00=n4889d8=0
    if b:
        rdx=b.count(bytes.fromhex("4889c2"))
        n48b00=b.count(bytes.fromhex("488b00"))
        n4889d8=b.count(bytes.fromhex("4889d8"))
    if tag=="OK" and out is not None:
        run_rc=run_bin(out,timeout=5)
        run_tag={0:"GREEN",0xC0000005:"AV",0xC0000409:"GS",1:"exit1"}.get(run_rc,f"rc={run_rc:#x}" if isinstance(run_rc,int) and run_rc!=0xDEAD0001 else ("TIMEOUT" if run_rc==0xDEAD0001 else str(run_rc)))
    else:
        run_tag="-"
    plant_results.append((src,tag,sh,n868,run_tag))
    P(f"  {src:14s} compile={tag:8s} sha={sh} n68={n68} n1b8={n1b8} n868={n868} rdx,rax={rdx} 488b00={n48b00} 4889d8={n4889d8} run={run_tag} ({time.time()-t1:.1f}s)")

P("\n=== baseline alt_frame2 p_ret_lit ===")
tag,sh,b,n68,n1b8,n868,out=run(cave/"xlang_isol1060_alt_frame2.exe","p_ret_lit.x",timeout=8)
run_tag="-"
if tag=="OK" and out is not None:
    rc=run_bin(out,timeout=5)
    run_tag={0:"GREEN",1:"exit1",0xC0000005:"AV"}.get(rc,f"rc={rc:#x}")
P(f"  lit compile={tag} sha={sh} n68={n68} n1b8={n1b8} n868={n868} run={run_tag}")

P("\n=== DIG nail ===")
P("  lit @27fbc5 ec SMALL because ret loads GLOBAL spill counter (RVA 0xb756ac);")
P("  Capless SoftCap lit walk adds little/no spill via @27ea1e => ec<=0x3ff => clamp @24b998 OFF-path.")
P("  Delta SoftCap 0x828-thin0x28 = 0x800 == f8 clamp; forcing ec=0x400 takes natural clamp path.")
P(f"  plant ec_400 results: {plant_results}")

clean()
# keep plant host? remove probes only — also remove plant host per prior style (probe hosts removed)
for p in list(cave.glob("xlang_isol1060_ec_400.exe"))+list(cave.glob("_tmp_xlang_isol1060_ec_400_*")):
    try: p.unlink()
    except: pass

P(f"\nelapsed={time.time()-T0:.1f}s DONE")
P("EXIT:0")
(cave/"dig_ec_small.log").write_text("\n".join(LOG)+"\n", encoding="utf-8")
