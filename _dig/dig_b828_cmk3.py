"""DIG SoftCap callmk_b828: base_828 + force call-mk eax==2 path @575648.
Under base_828 Capless call-mk HIT @575645 cmp eax,2; jne skip.
Plant: nop jne -> fallthrough write path (Isol-native).
Budget<=85s. Ban tip@121278/join/epi/LIVE/mega/arg-loop.
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

def plant_int3(baseb,rvas,label):
    pe2=bytearray(baseb); s=pe_secs(pe2)
    for r in rvas: pe2[rva2off(pe2,s,r)]=0xCC
    out=cave/f"_dig_h3_{label}.exe"; out.write_bytes(pe2); return out

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
        crc=r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT",-1
    tag={0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc,f"crc={crc:#x}")
    return tag, crc

def clean():
    for pat in ["_dig_h3_*.exe","_tmp__dig_h3_*","host_b828*.exe","host_callmk*.exe",
                "_tmp_host_b828*","_tmp_host_callmk*"]:
        for p in cave.glob(pat):
            try: p.unlink()
            except: pass

def dump_main(b,label):
    if not b: P(f"  {label}: no bin"); return
    for name,pat in [("868",bytes.fromhex("4881ec68080000")),
                     ("878",bytes.fromhex("4881ec78080000"))]:
        i=b.find(pat)
        if i<0: continue
        start=max(0,i-0x10)
        P(f"  {label} {name} @{i:#x}:")
        for insn in md.disasm(b[start:i+0xd0], start):
            P(f"    @{insn.address:04x}: {insn.mnemonic} {insn.op_str}")
        return
    # thin
    for name,pat in [("68",bytes.fromhex("4881ec68000000")),
                     ("1b8",bytes.fromhex("4881ecb8010000"))]:
        i=b.find(pat)
        if i<0: continue
        start=max(0,i-0x10)
        P(f"  {label} {name} @{i:#x}:")
        for insn in md.disasm(b[start:i+0xd0], start):
            P(f"    @{insn.address:04x}: {insn.mnemonic} {insn.op_str}")
        return
    P(f"  {label}: no frame found")

def find_sret(b,label):
    if not b: return
    pat=bytes([0x48,0x8d,0x45,0xd8])  # lea rax,[rbp-0x28]
    i=b.find(pat)
    if i<0:
        P(f"  {label}: no lea -0x28"); return
    P(f"  {label} sret @{i:#x}:")
    for insn in md.disasm(b[i:i+0x50], i):
        P(f"    @{insn.address:04x}: {insn.mnemonic} {insn.op_str}")

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)
P("base alt_frame2 sha12=9378df517f96")

# base_828 as host_b828.exe (unique name)
o828=rva2off(base,secs,0x24b9c1)
assert bytes(base[o828:o828+6])==bytes.fromhex("8b85fc000000")
b828=bytearray(base)
b828[o828:o828+6]=bytes.fromhex("b82808000090")
host_b828=cave/"host_b828.exe"
host_b828.write_bytes(b828)
P(f"host_b828 sha12={hashlib.sha256(bytes(b828)).hexdigest()[:12]}")

P("\n=== host_b828 SoftCap p_ret_* ===")
b828_ok=None
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
    if time.time()-T0>BUDGET-50: break
    t1=time.time()
    tag,sh,b,n68,n1b8,n868,outp=run(host_b828,src,timeout=8)
    if tag!="OK":
        time.sleep(0.2)
        tag,sh,b,n68,n1b8,n868,outp=run(host_b828,src,timeout=8)
    rtag="-"
    if tag=="OK" and outp:
        rtag,_=run_bin(outp,timeout=5)
        if src=="p_ret_lit.x": b828_ok=b
    P(f"  {src:16s} {tag:8s} sha={sh} n68={n68} n1b8={n1b8} n868={n868} run={rtag} ({time.time()-t1:.1f}s)")
if b828_ok:
    dump_main(b828_ok,"b828")
    find_sret(b828_ok,"b828")

# Verify @575648 jne bytes
o=rva2off(b828,secs,0x575648)
jne=bytes(b828[o:o+6])
P(f"\n  @575648 jne bytes={jne.hex()}")
assert jne==bytes.fromhex("0f852a010000"), f"unexpected jne {jne.hex()}"

# INT3 confirm @57564e (first insn of eax==2 path) under b828
P("\n=== INT3 eax==2 path / skip path under b828 ===")
for rva,name in [(0x57564e,"eax2_body"),(0x575778,"eax_ne2_skip"),
                 (0x575645,"cmp_eax2"),(0x5aaf18,"helper_5aaf18")]:
    if time.time()-T0>BUDGET-40: break
    t1=time.time()
    tag,sh,b,n68,n1b8,n868,_=run(plant_int3(b828,[rva],name),timeout=5)
    mark=" HIT" if tag=="INT3" else (f" **{tag}**" if tag in("AV","GS","TIMEOUT") else "")
    P(f"  @{rva:06x} {name:16s} -> {tag}{mark} ({time.time()-t1:.1f}s)")

# Plant callmk_b828: base_828 + nop @575648 jne (6B -> 6x nop)
P("\n=== plant callmk_b828 = b828 + nop jne @575648 ===")
pe=bytearray(b828)
pe[o:o+6]=bytes([0x90]*6)
host_cmk=cave/"host_callmk_b828.exe"
host_cmk.write_bytes(pe)
sha=hashlib.sha256(bytes(pe)).hexdigest()
P(f"  sha12={sha[:12]}")
for insn in md.disasm(bytes(pe[o-3:o+16]), 0x575645):
    P(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

results=[]
cmk_lit=None
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
    if time.time()-T0>BUDGET-12: break
    t1=time.time()
    tag,sh,b,n68,n1b8,n868,outp=run(host_cmk,src,timeout=8)
    if tag!="OK":
        time.sleep(0.2)
        tag,sh,b,n68,n1b8,n868,outp=run(host_cmk,src,timeout=8)
    rtag="-"; rcrc=-1
    if tag=="OK" and outp:
        rtag,rcrc=run_bin(outp,timeout=5)
        if src=="p_ret_lit.x": cmk_lit=b
    P(f"  {src:16s} {tag:8s} sha={sh} n68={n68} n1b8={n1b8} n868={n868} run={rtag}/{rcrc} ({time.time()-t1:.1f}s)")
    results.append((src,tag,sh,n868,rtag,rcrc))
if cmk_lit:
    dump_main(cmk_lit,"callmk_b828")
    find_sret(cmk_lit,"callmk_b828")

# Alt plant: force jmp to eax==2 path from cmp (replace cmp+jne with nop+jmp to @57564e)
# @575645: 83f802 (cmp eax,2) =3; jne=6; total 9. Replace with nop*3 + jmp @57564e (eb 07? from 575648)
# Simpler alt: @575645 cmp -> mov eax,2 (b802000000) then jne becomes not-taken
P("\n=== plant callmk_b828b = b828 + mov eax,2 @575645 (overwrite cmp) ===")
o_cmp=rva2off(b828,secs,0x575645)
cmp_b=bytes(b828[o_cmp:o_cmp+3])
P(f"  @575645 cmp={cmp_b.hex()}")
if cmp_b==bytes.fromhex("83f802"):
    pe2=bytearray(b828)
    # cmp eax,2 is 3 bytes; mov eax,2 is 5 bytes — would clobber jne.
    # Instead: patch jne to je inverted? Or nop jne only (already callmk_b828).
    # Patch: change jne to jno-equivalent always-fallthrough already done.
    # Try force eax=2 BEFORE cmp: find who sets eax. Dig @575645-0x20
    P("  pre-cmp context:")
    for insn in md.disasm(bytes(b828[o_cmp-0x30:o_cmp+12]), 0x575645-0x30):
        P(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Alt: plant at @575648 change jne (0f85) to je (0f84) — invert: take eax==2 when eax!=2
# That might be wrong. Stick with nop jne.

# Third plant: base_828 + force Capless SoftCap miss already true + 
# at call-mk @575fa3 (cmp [rbp+0x990],0; jne skip) — if HIT needed
P("\n=== INT3 @575fa3 under b828 ===")
tag,sh,b,n68,n1b8,n868,_=run(plant_int3(b828,[0x575fa3],"cmk_fa3"),timeout=5)
P(f"  @575fa3 -> {tag}")

# If callmk_b828 still exit1 / no imm->rdx, try plant @5aaf18-related
# Disasm call-mk after eax==2 fallthrough
P("\n=== call-mk eax==2 path @57564e.. ===")
o2=rva2off(b828,secs,0x57564e)
for insn in md.disasm(bytes(b828[o2:o2+0x80]), 0x57564e):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

P(f"\n=== RESULTS callmk_b828 ===")
P(f"  {results}")
P(f"elapsed={time.time()-T0:.1f}s DONE")

# cleanup
for p in list(cave.glob("_dig_h3_*.exe"))+list(cave.glob("_tmp__dig_h3_*")):
    try: p.unlink()
    except: pass
for p in list(cave.glob("host_b828*.exe"))+list(cave.glob("host_callmk*.exe")):
    try: p.unlink()
    except: pass
for p in list(cave.glob("_tmp_host_b828*"))+list(cave.glob("_tmp_host_callmk*")):
    try: p.unlink()
    except: pass
P("EXIT:0")
