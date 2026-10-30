"""Plant SoftCap prelast_immrdx: nop je@5688b7 so SoftCap always call @2a5ca8 get-elem.
Prior DIG: @2a62c9 HIT but @2a5ca8 miss (len==0 skip). Keep call-mk. Budget<=60s.
Ban tip@121278/join/epi/LIVE/mega/arg-loop.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64)
cave = Path("C:/xlang_tmp/p1060/cave"); os.chdir(str(cave))
T0=time.time(); BUDGET=60

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

def plant_bytes(baseb, patches, label):
    pe2=bytearray(baseb); s=pe_secs(pe2)
    for r,bs in patches:
        o=rva2off(pe2,s,r)
        pe2[o:o+len(bs)]=bs
    out=cave/f"_dig_pl3_{label}.exe"; out.write_bytes(pe2); return out

def run(h,src="p_ret_lit.x",timeout=5):
    out=cave/f"_tmp_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    for attempt in range(3):
        try:
            r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout)
            crc=r.returncode&0xFFFFFFFF
        except subprocess.TimeoutExpired:
            return "TIMEOUT","-",b"",0,0,0,None
        tag={0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc,f"crc={crc:#x}")
        if tag=="OK" or tag in("INT3","TIMEOUT") or attempt==2: break
        time.sleep(0.3)
    b=out.read_bytes() if out.exists() else b""
    sh=hashlib.sha256(b).hexdigest()[:12] if b else "-"
    n868=b.count(bytes.fromhex("4881ec68080000")) if b else 0
    return tag,sh,b,0,0,n868,out if b else None

def run_bin(exe,timeout=5):
    try:
        r=subprocess.run([str(exe)],capture_output=True,timeout=timeout)
        crc=r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT",-1
    tag={0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc,f"crc={crc:#x}")
    return tag, crc

def clean():
    for pat in ["_dig_pl3_*.exe","_tmp__dig_pl3_*","host_b828*.exe","host_prelast*.exe",
                "_tmp_host_b828*","_tmp_host_prelast*"]:
        for p in cave.glob(pat):
            try: p.unlink()
            except: pass

def find_sret(b,label):
    if not b: return False, False
    i=b.find(bytes([0x48,0x8d,0x45,0xd8]))
    if i<0:
        P(f"  {label}: no sret lea"); return False, False
    win=b[i:i+0x50]
    P(f"  {label} sret @{i:#x}:")
    for insn in md.disasm(win, i):
        P(f"    @{insn.address:04x}: {insn.mnemonic} {insn.op_str}")
    has_rdx = bytes.fromhex("4889c2") in win
    has_imm = (bytes.fromhex("b80a000000") in win) or (bytes.fromhex("ba0a000000") in win)
    has_sub20 = bytes.fromhex("4883ec20") in b[i:i+0x30]
    has_call = b"\xe8" in win
    e8pos = win.find(b"\xe8")
    true_immrdx=False
    if e8pos>0:
        pre=win[:e8pos]
        true_immrdx = (bytes.fromhex("4889c2") in pre) and (
            bytes.fromhex("b80a000000") in pre or bytes.fromhex("ba0a000000") in pre)
    P(f"  {label} has_imm10={has_imm} mov_rdx={has_rdx} sub20={has_sub20} call={has_call} true_immrdx={true_immrdx}")
    return true_immrdx, has_sub20 and has_call

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)
o828=rva2off(base,secs,0x24b9c1)
b828=bytearray(base); b828[o828:o828+6]=bytes.fromhex("b82808000090")
host=cave/"host_b828.exe"; host.write_bytes(b828)
P(f"host_b828={hashlib.sha256(bytes(b828)).hexdigest()[:12]}")

base_sha=None
for attempt in range(4):
    tag,sh,b,_,_,n868,outp=run(host,"p_ret_lit.x",timeout=8)
    P(f"b828 lit try{attempt} {tag} sha={sh} n868={n868}")
    if tag=="OK" and n868>=1:
        find_sret(b,"b828"); base_sha=sh
        break
    time.sleep(0.4)

# INT3 confirm gate @5688b7 + get-elem
P("\n=== INT3 gate @5688b7 / @5688d2 / @5688f9 ===")
for rva,nm in [(0x5688b7,"je_idx_ge_len"),(0x5688d2,"call_2a5ca8"),(0x568870,"je_null_30"),(0x5688f9,"je_null_elem")]:
    pe=plant_bytes(b828,[(rva,bytes([0xCC]))],f"i{rva:x}")
    tag,_,_,_,_,_,_=run(pe,timeout=5)
    P(f"  @{rva:06x} {nm:18s} -> {tag}")

# decode plant site
o=rva2off(b828,secs,0x5688b7)
insn=next(md.disasm(bytes(b828[o:o+16]), 0x5688b7))
raw=bytes(insn.bytes)
P(f"\nplant site @5688b7: {insn.mnemonic} {insn.op_str} [{raw.hex()}] len={len(raw)}")

results=[]
def do_plant(name, patches):
    pe=bytearray(b828); s=pe_secs(pe)
    for rva,new,old in patches:
        oo=rva2off(pe,s,rva)
        cur=bytes(pe[oo:oo+len(old)])
        if cur!=old:
            P(f"  {name}: skip bad @{rva:06x} got={cur.hex()} want={old.hex()}")
            return None
        pe[oo:oo+len(new)]=new
    out=cave/f"host_prelast_{name}.exe"; out.write_bytes(pe)
    sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
    P(f"\n=== plant {name} sha12={sha} ===")
    res=[]
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
        if time.time()-T0>BUDGET-5: break
        t1=time.time()
        tag,sh,b,_,_,n868,outp=run(out,src,timeout=8)
        rtag="-"; rcrc=-1
        if tag=="OK" and outp:
            rtag,rcrc=run_bin(outp,timeout=5)
        P(f"  {src:16s} {tag:8s} sha={sh} n868={n868} run={rtag}/{rcrc} ({time.time()-t1:.1f}s)")
        if tag=="OK" and b and "lit" in src:
            find_sret(b,name)
            if base_sha and sh==base_sha:
                P(f"  NOTE: lit sha==base ({base_sha})")
        res.append((src,tag,sh,n868,rtag,rcrc))
    results.append((name,sha,res))
    return sha

# Plant prelast_immrdx: nop je@5688b7 (force get-elem @2a5ca8 even when len==0/idx>=len)
if insn.mnemonic in ("je","jz") and len(raw)==6:
    new=b"\x90"*6
    P(f"  -> plant prelast_immrdx: nop {insn.mnemonic} @5688b7 ({raw.hex()}->{new.hex()})")
    do_plant("prelast_immrdx", [(0x5688b7, new, raw)])
elif insn.mnemonic in ("je","jz") and len(raw)==2:
    new=b"\x90"*2
    P(f"  -> plant prelast_immrdx: nop short je @5688b7")
    do_plant("prelast_immrdx", [(0x5688b7, new, raw)])
else:
    P(f"  UNEXPECTED insn at plant site")

P(f"\nRESULTS: {results}")
P(f"elapsed={time.time()-T0:.1f}s DONE")
clean()
P("EXIT:0")
