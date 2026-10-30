"""DIG SoftCap b828_cmk: Capless arg0->rdx under base_828 (call mk present, no imm->rdx).
INT3 skip@575786 chain; dig enc@524944/@521f10; plant force rdx write if Isol-native gate found.
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
    out=cave/f"_dig_h5_{label}.exe"; out.write_bytes(pe2); return out

def run(h,src="p_ret_lit.x",timeout=5):
    out=cave/f"_tmp_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    for attempt in range(2):
        try:
            r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout)
            crc=r.returncode&0xFFFFFFFF
        except subprocess.TimeoutExpired:
            return "TIMEOUT","-",b"",0,0,0,None
        tag={0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc,f"crc={crc:#x}")
        if tag=="OK" or tag in("INT3","TIMEOUT") or attempt==1:
            break
        time.sleep(0.25)
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
    for pat in ["_dig_h5_*.exe","_tmp__dig_h5_*","host_b828*.exe","host_cmk*.exe",
                "_tmp_host_b828*","_tmp_host_cmk*"]:
        for p in cave.glob(pat):
            try: p.unlink()
            except: pass

def find_sret(b,label):
    if not b: return False
    pat=bytes([0x48,0x8d,0x45,0xd8])
    i=b.find(pat)
    if i<0: P(f"  {label}: no sret"); return False
    win=b[i:i+0x30]
    P(f"  {label} sret @{i:#x}:")
    for insn in md.disasm(win, i):
        P(f"    @{insn.address:04x}: {insn.mnemonic} {insn.op_str}")
    ok = (bytes.fromhex("4889c2") in win) or (bytes.fromhex("ba0a000000") in win)
    P(f"  {label} has_imm_rdx={ok}")
    return ok

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)
o828=rva2off(base,secs,0x24b9c1)
b828=bytearray(base); b828[o828:o828+6]=bytes.fromhex("b82808000090")
host=cave/"host_b828.exe"; host.write_bytes(b828)
P(f"host_b828={hashlib.sha256(bytes(b828)).hexdigest()[:12]}")

tag,sh,b,n68,n1b8,n868,outp=run(host,"p_ret_lit.x",timeout=8)
P(f"b828 lit {tag} sha={sh} n868={n868}")
find_sret(b,"b828")

# Disasm skip path from HIT @575786
P("\n=== skip path @575786.. ===")
o=rva2off(b828,secs,0x575786)
for insn in md.disasm(bytes(b828[o:o+0x120]), 0x575786):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# enc helpers
for rva,nm in [(0x524944,"enc_524944"),(0x521f10,"enc_521f10"),(0x521d78,"enc_521d78")]:
    P(f"\n=== {nm} @{rva:06x} ===")
    o=rva2off(b828,secs,rva)
    for insn in md.disasm(bytes(b828[o:o+0x50]), rva):
        P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Dense INT3 along skip path insn starts
P("\n=== INT3 skip chain ===")
o=rva2off(b828,secs,0x575786)
addrs=[]
for insn in md.disasm(bytes(b828[o:o+0x100]), 0x575786):
    addrs.append((insn.address, f"{insn.mnemonic}"))
    if len(addrs)>=16: break
hits=[]
for rva,mn in addrs:
    if time.time()-T0>BUDGET-35: break
    t1=time.time()
    tag,_,_,_,_,_,_=run(plant_int3(b828,[rva],f"s{rva:x}"),timeout=5)
    mark=" HIT" if tag=="INT3" else f" {tag}"
    if tag=="INT3": hits.append(rva)
    P(f"  @{rva:06x} {mn:8s} ->{mark} ({time.time()-t1:.1f}s)")
P(f"skip HITs: {[hex(r) for r in hits]}")

# Look for Capless CallExpr arg-count / sret: search callers of enc that write mov_rdx
# Isol mov rdx,rax encode: typically helper taking reg ids
# Search Capless for 4889c2 as IMMEDIATE template (emit copies these bytes)
text_va=text_ro=text_sz=None
for n,(va,vs,ro,rs) in secs.items():
    if n==b'.text':
        text_va,text_ro,text_sz=va,ro,max(vs,rs); break
region=bytes(b828[text_ro:text_ro+text_sz])
# Find E8 call sites near Capless that might be emit_mov_rdx
# Practical: dig Capless @555ed8 / @557974 / @55483c (try handlers) INT3
P("\n=== INT3 Capless try-handlers / join ===")
for rva,nm in [(0x555ed8,"try_555ed8"),(0x557974,"try_557974"),(0x55483c,"try_55483c"),
               (0x577ca1,"call_try1"),(0x577cfb,"call_try2"),(0x577d55,"call_try3"),
               (0x578273,"call_57b98c"),(0x57b98c,"fn_57b98c"),(0x57bb30,"call_cmk")]:
    if time.time()-T0>BUDGET-25: break
    t1=time.time()
    tag,_,_,_,_,_,_=run(plant_int3(b828,[rva],nm),timeout=5)
    mark=" HIT" if tag=="INT3" else f" {tag}"
    P(f"  @{rva:06x} {nm:16s} ->{mark} ({time.time()-t1:.1f}s)")

# Plant: Capless @577cc8 / early success after try — if SoftCap lit takes try that returns
# success without writing args... 
# From disasm: try returns !=0 then if jns -> mov eax,0; jmp EXIT (claim success!)
# @577cb3: je continue; @577cbc jns -> eax=0 EXIT
# So if try returns >0, Capless EARLY EXITS success without call-mk args!
# SoftCap lit: which try returns?

P("\n=== INT3 Capless try result exits ===")
for rva,nm in [(0x577cb3,"je_try1"),(0x577cc8,"ok_exit1"),(0x577d0d,"je_try2"),
               (0x577d22,"ok_exit2"),(0x577d67,"je_try3"),(0x577d7c,"ok_exit3")]:
    if time.time()-T0>BUDGET-18: break
    tag,_,_,_,_,_,_=run(plant_int3(b828,[rva],nm),timeout=5)
    P(f"  @{rva:06x} {nm} -> {tag}")

# If ok_exit HIT — Capless claims success after try without full call-mk write
# Plant: nop the success EXIT — force fallthrough to real emit
# e.g. @577cc8 mov eax,0; jmp EXIT -> nop / jmp to continue path

P("\n=== Capless try1 result region ===")
o=rva2off(b828,secs,0x577ca6)
for insn in md.disasm(bytes(b828[o:o+0x40]), 0x577ca6):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Plant b828_cmk: if SoftCap lit hits ok_exit after try with partial write,
# change jns-success to always continue (force je-equivalent fallthrough to more emits)
# @577cb5: cmp; @577cbc: jns ok_exit. Change jns (790a?) to jmp to je-target continue? 
# Structure:
#   cmp [3dc],0
#   je continue          # try returned 0 -> keep going
#   cmp [3dc],0
#   jns ok_exit          # try returned >0 -> success EXIT
#   mov eax,-1; jmp EXIT # try returned <0 -> fail
# Plant: make jns into js or nop-jmp-to-continue so >0 also continues? 
# Better: change je continue to jmp continue (always continue regardless of try)
# That might AV if try already wrote partial. Safer: change ok_exit mov eax,0;jmp into jmp continue

# First see which ok_exit HIT

# Also plant: at USER-emitting enc, force mov_rdx
# Look at @521f10 - often mov reg encode

P("\n=== plant attempts ===")
# Plant1: base_828 + @577cbc jns -> jmp to continue (@577cd2)
# Need exact bytes at jns
o_jns=rva2off(b828,secs,0x577cbc)
jns_b=bytes(b828[o_jns:o_jns+2])
P(f"  @577cbc bytes={jns_b.hex()}")
# jns rel8: 79 XX. Target continue @577cd2: from 577cbe -> rel=0x14
# Or change to js (78) so >0 falls to -1 fail — bad.
# Change to nop+nop and let it fall to mov eax,-1 — also bad.
# Change preceding je @577cb3 to jmp always continue:
o_je=rva2off(b828,secs,0x577cb3)
je_b=bytes(b828[o_je:o_je+2])
P(f"  @577cb3 bytes={je_b.hex()}")

results=[]
def do_plant(name, patches):
    pe=bytearray(b828); s=pe_secs(pe)
    for rva,new,old in patches:
        o=rva2off(pe,s,rva)
        cur=bytes(pe[o:o+len(old)])
        if cur!=old:
            P(f"  {name}: skip bad @{rva:06x} {cur.hex()}!={old.hex()}")
            return
        pe[o:o+len(new)]=new
    out=cave/f"host_cmk_{name}.exe"; out.write_bytes(pe)
    sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
    P(f"\n=== plant {name} sha12={sha} ===")
    res=[]
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
        if time.time()-T0>BUDGET-5: break
        t1=time.time()
        tag,sh,b,n68,n1b8,n868,outp=run(out,src,timeout=8)
        rtag="-"; rcrc=-1
        if tag=="OK" and outp:
            rtag,rcrc=run_bin(outp,timeout=5)
        P(f"  {src:16s} {tag:8s} sha={sh} n868={n868} run={rtag}/{rcrc} ({time.time()-t1:.1f}s)")
        if tag=="OK" and b and "lit" in src:
            find_sret(b,name)
        res.append((src,tag,sh,n868,rtag,rcrc))
    results.append((name,sha,res))

# je @577cb3: 74 XX -> eb XX (jmp always continue past try1 success)
if je_b[0]==0x74:
    do_plant("b828_cmk", [(0x577cb3, bytes([0xeb, je_b[1]]), je_b)])

# Also try same for try2 je @577d0d
o_je2=rva2off(b828,secs,0x577d0d)
je2=bytes(b828[o_je2:o_je2+2])
P(f"  @577d0d bytes={je2.hex()}")
if je2[0]==0x74:
    do_plant("b828_cmk_t2", [(0x577d0d, bytes([0xeb, je2[1]]), je2)])

# Combined: force continue past try1 and try2
if je_b[0]==0x74 and je2[0]==0x74:
    do_plant("b828_cmk_t12", [
        (0x577cb3, bytes([0xeb, je_b[1]]), je_b),
        (0x577d0d, bytes([0xeb, je2[1]]), je2),
    ])

P(f"\nRESULTS: {results}")
P(f"elapsed={time.time()-T0:.1f}s DONE")
for p in list(cave.glob("_dig_h5_*.exe"))+list(cave.glob("_tmp__dig_h5_*")):
    try: p.unlink()
    except: pass
for p in list(cave.glob("host_b828*.exe"))+list(cave.glob("host_cmk*.exe")):
    try: p.unlink()
    except: pass
for p in list(cave.glob("_tmp_host_b828*"))+list(cave.glob("_tmp_host_cmk*")):
    try: p.unlink()
    except: pass
P("EXIT:0")
