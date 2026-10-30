"""DIG SoftCap b828_cmk: under base_828 USER has call mk but NO imm->rdx.
Find Capless/call-mk site that skips arg0(rdx) under sret; plant force imm->rdx.
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
    out=cave/f"_dig_h4_{label}.exe"; out.write_bytes(pe2); return out

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
    for pat in ["_dig_h4_*.exe","_tmp__dig_h4_*","host_b828*.exe","host_cmk*.exe",
                "_tmp_host_b828*","_tmp_host_cmk*"]:
        for p in cave.glob(pat):
            try: p.unlink()
            except: pass

def find_sret(b,label):
    if not b: return
    pat=bytes([0x48,0x8d,0x45,0xd8])
    i=b.find(pat)
    if i<0: P(f"  {label}: no sret lea"); return
    P(f"  {label} sret @{i:#x}:")
    for insn in md.disasm(b[i:i+0x40], i):
        P(f"    @{insn.address:04x}: {insn.mnemonic} {insn.op_str}")
    has_rdx = bytes.fromhex("4889c2") in b[i:i+0x30]
    has_imm = bytes.fromhex("b80a000000") in b[i:i+0x30] or bytes.fromhex("ba0a000000") in b[i:i+0x30]
    P(f"  {label} near-sret mov_rdx_rax={has_rdx} imm10={has_imm}")

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)

o828=rva2off(base,secs,0x24b9c1)
b828=bytearray(base)
b828[o828:o828+6]=bytes.fromhex("b82808000090")
host=cave/"host_b828.exe"; host.write_bytes(b828)
P(f"host_b828 sha12={hashlib.sha256(bytes(b828)).hexdigest()[:12]}")

# confirm baseline gap
tag,sh,b,n68,n1b8,n868,outp=run(host,"p_ret_lit.x",timeout=8)
if tag!="OK":
    time.sleep(0.2); tag,sh,b,n68,n1b8,n868,outp=run(host,"p_ret_lit.x",timeout=8)
P(f"b828 lit {tag} sha={sh} n868={n868}")
find_sret(b,"b828")

# Disasm call-mk skip path after jne @575778
P("\n=== call-mk skip path @575770.. ===")
o=rva2off(b828,secs,0x575770)
for insn in md.disasm(bytes(b828[o:o+0xc0]), 0x575770):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Disasm @5aaf18 helper (HIT) - might be arg/call writer
P("\n=== helper @5aaf18 ===")
o=rva2off(b828,secs,0x5aaf18)
for insn in md.disasm(bytes(b828[o:o+0x80]), 0x5aaf18):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Find who writes E8 (call) into USER buffer - Capless enc helpers
# Known Isol enc: @524944, @521f10, @521d78, @1cd1e5 from prior
# Also search call-mk for E8 emit of relative call
P("\n=== INT3 skip-path / enc under b828 ===")
sites=[
    (0x575778,"skip_575778"),
    (0x575790,"skip_575790"),
    (0x5757c0,"skip_5757c0"),
    (0x575800,"skip_575800"),
    (0x575900,"skip_575900"),
    (0x575a00,"skip_575a00"),
    (0x575b00,"skip_575b00"),
    (0x575c00,"skip_575c00"),
    # Capless CallExpr arg / call emit suspects
    (0x577c47,"cap_call_1ff2ef"),
    (0x1ff2ef,"fn_1ff2ef"),
    (0x524944,"enc_524944"),
    (0x521f10,"enc_521f10"),
    (0x521d78,"enc_521d78"),
    # sret_shift / park suspects from Capless
    (0x5766c3,"calt_cont"),
    (0x577681,"cap_join"),
]
hits=[]
for rva,name in sites:
    if time.time()-T0>BUDGET-40: P("BUDGET INT3"); break
    t1=time.time()
    tag,sh,_,_,_,_,_=run(plant_int3(b828,[rva],name),timeout=5)
    mark=" HIT" if tag=="INT3" else (f" **{tag}**" if tag in("AV","GS","TIMEOUT") else "")
    if tag=="INT3": hits.append((rva,name))
    P(f"  @{rva:06x} {name:18s} -> {tag}{mark} ({time.time()-t1:.1f}s)")
P(f"HITs: {[(hex(r),n) for r,n in hits]}")

# Scan skip path for early mov eax,0; jmp / ret that skips arg emit
# Also look for call to enc helpers in skip path - need full skip disasm first from HIT refine

# Dig: Capless CallExpr after kind3 @577c37 — @1ff2ef then later call-mk
# When sret_shift set, does Capless skip arg0?
# Search Isol Capless region for call_sret_reg_shift / read of g_call_sret
# g_call_sret in .data — find RIP-relative loads near Capless CALL

P("\n=== Capless @577c78.. (after kind3 gates) ===")
o=rva2off(b828,secs,0x577c78)
for insn in md.disasm(bytes(b828[o:o+0x100]), 0x577c78):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# LIVE SoftCap writer region for comparison - lab_LIVE SoftCap call-mk
# Find in LIVE PE the bytes that encode mov eax,0xa near SoftCap
live=bytearray((cave/"lab_LIVE_pret.exe").read_bytes())
ls=pe_secs(live)
P("\n=== LIVE SoftCap scan mov eax,0xa near call writer ===")
# SoftCap@289dcb area
for rva in [0x289dcb, 0x28a000, 0x28b000, 0x28be7f]:
    try:
        o=rva2off(live,ls,rva)
        P(f"  LIVE @{rva:06x}:")
        for insn in md.disasm(bytes(live[o:o+0x40]), rva):
            P(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    except Exception as e:
        P(f"  LIVE @{rva:06x}: {e}")

# Plant candidates for imm->rdx:
# 1) Find Capless site that emits `sub rsp,0x20; call` without rdx — that's USER pattern
#    The compiler emits those bytes via enc helpers. Find enc of shadow+call.
# 2) Capless CallExpr arg loop: if arg count treated as 0 under sret, force +1

# Search Isol for encoding of 4883ec20 (sub rsp,0x20) followed soon by E8 — the thin call writer
P("\n=== Isol scan enc sites writing sub rsp,0x20 ===")
# Look for imm 0x20 being passed to enc_sub_rsp or similar near Capless
# Practical: INT3 Capless helpers that emit call

# From USER gap: after lea→rcx, next is sub rsp,0x20; call.
# Glue already wrote lea→rcx. Capless emit_expr wrote sub+call only.
# So Capless CallExpr with sret thinks 0 user args.

# Check: pipeline_asm_emit_call_sret_reg_shift — Capless may read it and skip arg0
# Find Isol Capless reads of sret shift flag
# g_call_sret_reg_shift in runtime — search for known setter @ pattern
# Simpler plant: Capless CallExpr arg-count / first-arg index under sret

# Look at @1ff2ef (called from Capless kind3)
P("\n=== fn @1ff2ef ===")
o=rva2off(b828,secs,0x1ff2ef)
for insn in md.disasm(bytes(b828[o:o+0x60]), 0x1ff2ef):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Plant: under b828, force Capless to emit mov rdx before call
# If we find Capless early-out `if sret: skip arg0`, nop that skip.
# Search Capless call-mk / CallExpr for cmp with sret-ish and je skip

# Dig skip path more carefully with denser INT3 after confirming @575778
P("\n=== refine skip path INT3 ===")
# First get exact insn starts from disasm at 575778
o=rva2off(b828,secs,0x575778)
chunk=bytes(b828[o:o+0x100])
addrs=[]
for insn in md.disasm(chunk, 0x575778):
    addrs.append(insn.address)
    if len(addrs)>=12: break
P(f"  insn addrs: {[hex(a) for a in addrs]}")
for rva in addrs[:8]:
    if time.time()-T0>BUDGET-25: break
    t1=time.time()
    tag,_,_,_,_,_,_=run(plant_int3(b828,[rva],f"sk_{rva:x}"),timeout=5)
    mark=" HIT" if tag=="INT3" else f" {tag}"
    P(f"  @{rva:06x} ->{mark} ({time.time()-t1:.1f}s)")

# Plant b828_cmk: if SoftCap lit takes skip path and we find early success
# without arg write — force into a path that calls enc for rdx.
# Practical plant from eax==2 path knowledge: SoftCap lit has eax!=2.
# What if we plant BEFORE cmp to force eax=2? Find eax source.
P("\n=== pre-cmp @575620.. ===")
o=rva2off(b828,secs,0x575620)
for insn in md.disasm(bytes(b828[o:o+0x40]), 0x575620):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Force eax=2: find `mov eax, <something>` before cmp; or patch cmp to `cmp eax,eax` (always eq)
# cmp eax,2 = 83f802 (3B). Replace with cmp eax,eax = 39c0 (2B) + nop = always ZF=1, jne not taken.
P("\n=== plant b828_cmk: cmp eax,eax @575645 (force eax==2 path) ===")
o_cmp=rva2off(b828,secs,0x575645)
assert bytes(b828[o_cmp:o_cmp+3])==bytes.fromhex("83f802")
pe=bytearray(b828)
pe[o_cmp:o_cmp+3]=bytes.fromhex("39c090")  # cmp eax,eax; nop
host_cmk=cave/"host_cmk_b828.exe"
host_cmk.write_bytes(pe)
sha=hashlib.sha256(bytes(pe)).hexdigest()
P(f"  sha12={sha[:12]}")
for insn in md.disasm(bytes(pe[o_cmp:o_cmp+12]), 0x575645):
    P(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

results=[]
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
    if time.time()-T0>BUDGET-8: break
    t1=time.time()
    tag,sh,b,n68,n1b8,n868,outp=run(host_cmk,src,timeout=8)
    if tag!="OK":
        time.sleep(0.2); tag,sh,b,n68,n1b8,n868,outp=run(host_cmk,src,timeout=8)
    rtag="-"; rcrc=-1
    if tag=="OK" and outp:
        rtag,rcrc=run_bin(outp,timeout=5)
    P(f"  {src:16s} {tag:8s} sha={sh} n868={n868} run={rtag}/{rcrc} ({time.time()-t1:.1f}s)")
    if tag=="OK" and b and src=="p_ret_lit.x":
        find_sret(b,"b828_cmk")
    results.append((src,tag,sh,n868,rtag,rcrc))

# Alt plant: Capless CallExpr — force arg emit
# If @577c1a mov eax,0; jmp EXIT is early success for some kind — check INT3
P("\n=== Capless early exits INT3 ===")
for rva,name in [(0x577c1a,"cap_early0"),(0x577c10,"cap_early_m1"),
                 (0x5766b9,"calt_site_ok")]:
    if time.time()-T0>BUDGET-5: break
    tag,_,_,_,_,_,_=run(plant_int3(b828,[rva],name),timeout=5)
    P(f"  @{rva:06x} {name} -> {tag}")

P(f"\nRESULTS: {results}")
P(f"elapsed={time.time()-T0:.1f}s DONE")
for p in list(cave.glob("_dig_h4_*.exe"))+list(cave.glob("_tmp__dig_h4_*")):
    try: p.unlink()
    except: pass
for p in list(cave.glob("host_b828*.exe"))+list(cave.glob("host_cmk*.exe")):
    try: p.unlink()
    except: pass
for p in list(cave.glob("_tmp_host_b828*"))+list(cave.glob("_tmp_host_cmk*")):
    try: p.unlink()
    except: pass
P("EXIT:0")
