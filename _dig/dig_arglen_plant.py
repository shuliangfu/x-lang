"""Plant fill_args: Capless +0x478 = CallExpr node.args (+0x20) instead of empty @55d730 alloc.
Prior DIG: +0x478 fresh empty -> pre_last @2a62c9 len=0. Budget<=60s.
Ban tip@121278/join/epi/LIVE/mega/arg-loop.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64)

cave = Path(r"C:\xlang_tmp\p1060\cave"); os.chdir(str(cave))
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
            return "TIMEOUT","-",b"",0,None
        tag={0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc,f"crc={crc:#x}")
        if tag=="OK" or tag in("INT3","TIMEOUT") or attempt==2: break
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
    if not b: return
    i=b.find(bytes([0x48,0x8d,0x45,0xd8]))
    if i<0: P(f"  {label}: no sret"); return
    win=b[i:i+0x50]; e8=win.find(b"\xe8"); ti=False
    if e8>0:
        pre=win[:e8]
        ti=(bytes.fromhex("4889c2") in pre) and (bytes.fromhex("b80a000000") in pre or bytes.fromhex("ba0a000000") in pre)
    cmk=bytes.fromhex("4883ec20") in b[i:i+0x30] and b"\xe8" in win
    P(f"  {label} true_immrdx={ti} callmk={cmk}")
    for insn in md.disasm(win[:0x30], i):
        P(f"    @{insn.address:04x}: {insn.mnemonic} {insn.op_str}")

def clean():
    for pat in ["_dig_ap_*.exe","_tmp__dig_ap_*","host_b828*.exe","host_arglen*.exe",
                "_tmp_host_b828*","_tmp_host_arglen*"]:
        for p in cave.glob(pat):
            try: p.unlink()
            except: pass

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)
o828=rva2off(base,secs,0x24b9c1)
b828=bytearray(base); b828[o828:o828+6]=bytes.fromhex("b82808000090")
host=cave/"host_b828.exe"; host.write_bytes(b828)
P(f"host_b828={hashlib.sha256(bytes(b828)).hexdigest()[:12]}")
base_sha=None
for attempt in range(6):
    tag,sh,b,n868,_=run(host)
    P(f"b828 lit try{attempt} {tag} sha={sh} n868={n868}")
    if tag=="OK" and n868>=1:
        find_sret(b,"b828"); base_sha=sh; break
    time.sleep(0.5)

# Verify region @57661d..@576637
o=rva2off(b828,secs,0x57661d)
reg=bytes(b828[o:o+0x20])
P(f"region @57661d: {reg.hex()}")
for insn in md.disasm(reg, 0x57661d):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str} [{bytes(insn.bytes).hex()}]")
    if insn.address>=0x576637: break

# Expected old: mov rax,[rbp+0x4a8]; mov edx,0x568; mov rcx,rax; call; mov [rbp+0x478],rax
old = bytes(b828[o:o+27])
P(f"old27={old.hex()} len={len(old)}")

# new: mov rax,[rbp+0x490]; mov rax,[rax+OFF]; mov [rbp+0x478],rax; nops
def build_patch(off):
    # 488b8590040000 = mov rax,[rbp+0x490]
    # 488b40XX or 488b80XXXXXXXX for larger off
    if off < 0x80:
        load_field = bytes.fromhex("488b40") + bytes([off])  # mov rax,[rax+off8]
    else:
        load_field = bytes.fromhex("488b80") + struct.pack("<I", off)
    body = (bytes.fromhex("488b8590040000") + load_field +
            bytes.fromhex("48898578040000"))
    if len(body) > 27:
        raise ValueError("too long")
    return body + b"\x90"*(27-len(body))

results=[]
def do_plant(name, new):
    pe=bytearray(b828)
    oo=rva2off(pe,secs,0x57661d)
    cur=bytes(pe[oo:oo+27])
    if cur!=old:
        P(f"  {name}: region mismatch {cur.hex()}"); return
    pe[oo:oo+27]=new
    out=cave/f"host_arglen_{name}.exe"; out.write_bytes(pe)
    sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
    P(f"\n=== plant {name} sha12={sha} patch={new.hex()} ===")
    for insn in md.disasm(new, 0x57661d):
        P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    res=[]
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
        if time.time()-T0>BUDGET-5: break
        tag,sh,b,n868,outp=run(out,src,timeout=8)
        rtag="-"; rcrc=-1
        if tag=="OK" and outp: rtag,rcrc=run_bin(outp)
        P(f"  {src:16s} {tag:8s} sha={sh} n868={n868} run={rtag}/{rcrc}")
        if tag=="OK" and b and "lit" in src:
            find_sret(b,name)
            if base_sha and sh==base_sha: P("  NOTE sha==base")
        res.append((src,tag,sh,n868,rtag))
    results.append((name,sha,res))

# offsets: async uses 32; also try 0x18/0x28/0x38 common
for off,nm in [(0x20,"ast20"),(0x28,"ast28"),(0x18,"ast18")]:
    if time.time()-T0>BUDGET-15: break
    do_plant(f"fill_args_{nm}", build_patch(off))

P(f"\nRESULTS: {results}")
P(f"elapsed={time.time()-T0:.1f}s DONE")
clean()
P("EXIT:0")
