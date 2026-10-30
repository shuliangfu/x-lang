"""DIG Capless [rbp+0x478] = CallExpr args container fed to pre_last as arg5.
Who writes/clears it; SoftCap lit why len=0; plant fill if isolatable.
Budget<=80s. Ban tip@121278/join/epi/LIVE/mega/arg-loop.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64)

cave = Path(r"C:\xlang_tmp\p1060\cave"); os.chdir(str(cave))
T0=time.time(); BUDGET=80

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
    out=cave/f"_dig_a4_{label}.exe"; out.write_bytes(pe2); return out

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
    tag={0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc,f"crc={crc:#x}")
    return tag, crc

def find_sret(b,label):
    if not b: return False, False
    i=b.find(bytes([0x48,0x8d,0x45,0xd8]))
    if i<0:
        P(f"  {label}: no sret"); return False, False
    win=b[i:i+0x50]
    e8pos=win.find(b"\xe8"); true_immrdx=False
    if e8pos>0:
        pre=win[:e8pos]
        true_immrdx=(bytes.fromhex("4889c2") in pre) and (
            bytes.fromhex("b80a000000") in pre or bytes.fromhex("ba0a000000") in pre)
    cmk=bytes.fromhex("4883ec20") in b[i:i+0x30] and b"\xe8" in win
    P(f"  {label} true_immrdx={true_immrdx} callmk={cmk}")
    return true_immrdx, cmk

def clean():
    for pat in ["_dig_a4_*.exe","_tmp__dig_a4_*","host_b828*.exe","host_arglen*.exe",
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
for attempt in range(5):
    tag,sh,b,n868,_=run(host)
    P(f"b828 lit try{attempt} {tag} sha={sh} n868={n868}")
    if tag=="OK" and n868>=1:
        find_sret(b,"b828"); base_sha=sh; break
    time.sleep(0.5)

# Capless function containing @57820f — find its start (look back for push rbp / typical prologue)
P("\n=== find Capless fn start before @57820f ===")
# scan back for int3 padding or push rbp pattern
o=rva2off(b828,secs,0x576000)
chunk=bytes(b828[o:o+0x2300])
# find last 'push rbp; mov rbp,rsp' before 0x57820f
cands=[]
for i in range(0, len(chunk)-3):
    if chunk[i]==0x55 and chunk[i+1]==0x48 and chunk[i+2]==0x89 and chunk[i+3]==0xe5:
        rva=0x576000+i
        if rva < 0x57820f:
            cands.append(rva)
P(f"prologues before call n={len(cands)} last5={[hex(x) for x in cands[-5:]]}")
fn_start = cands[-1] if cands else 0x57656c
P(f"Capless-ish start guess={hex(fn_start)}")

# Scan fn_start .. @578214 for [rbp+0x478] refs
P(f"\n=== SCAN [{fn_start:06x}..578214] for rbp+0x478 ===")
o=rva2off(b828,secs,fn_start)
body=bytes(b828[o:o+(0x578220-fn_start)])
refs=[]
for insn in md.disasm(body, fn_start):
    if "0x478" in insn.op_str and "rbp" in insn.op_str:
        refs.append((insn.address, insn.mnemonic, insn.op_str, bytes(insn.bytes).hex()))
P(f"refs n={len(refs)}")
stores=[]; loads=[]
for a,m,op,hx in refs:
    P(f"  @{a:06x}: {m} {op} [{hx}]")
    left=op.split(",")[0]
    if "[" in left and "0x478" in left:
        stores.append((a,m,op,hx))
    else:
        loads.append((a,m,op,hx))
P(f"STORES n={len(stores)} LOADS n={len(loads)}")

for a,m,op,hx in stores:
    P(f"\n--- STORE context @{a:06x} ---")
    oo=rva2off(b828,secs,a-0x30)
    for insn in md.disasm(bytes(b828[oo:oo+0x60]), a-0x30):
        mark=" <<<" if insn.address==a else ""
        P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}{mark}")
        if insn.address>a+10: break

# Also scan whole Capless for 0x478 including zeros
P("\n=== INT3 on +0x478 stores / key loads before pre_last ===")
for a,m,op,hx in stores:
    if time.time()-T0>BUDGET-30: break
    pe=plant_bytes(b828,[(a,bytes([0xCC]))],f"s{a:x}")
    tag,_,_,_,_=run(pe)
    P(f"  STORE @{a:06x} -> {tag}")

# INT3 on the load used as arg5 @578200
for rva,nm in [(0x578200,"load478_arg5"),(0x57820f,"call_prelast"),
               (0x567a5c,"pl_load_arg5"),(0x567a60,"pl_store_local30"),
               (0x56888d,"call_len"),(0x5688b7,"je_ge_len")]:
    if time.time()-T0>BUDGET-25: break
    pe=plant_bytes(b828,[(rva,bytes([0xCC]))],f"i{rva:x}")
    tag,_,_,_,_=run(pe)
    P(f"  @{rva:06x} {nm:20s} -> {tag}")

# Who produces the value stored into +0x478? Look for field offset 0x478 on AST node
# Search mov/lea with +0x478 elsewhere in binary Capless region 0x570000-0x580000
P("\n=== broader Capless-region +0x478 refs ===")
o=rva2off(b828,secs,0x570000)
body=bytes(b828[o:o+0x10000])
refs2=[]
for insn in md.disasm(body, 0x570000):
    if insn.address>=0x580000: break
    if "0x478" in insn.op_str:
        refs2.append((insn.address, insn.mnemonic, insn.op_str))
P(f"n={len(refs2)}")
for a,m,op in refs2[:40]:
    P(f"  @{a:06x}: {m} {op}")

# Also check node field: Capless often does mov rax,[node+off]; mov [rbp+0x478],rax
# Search for displacement 0x478 as raw in Capless
P("\n=== raw disp32=0x478 in Capless 570000..580000 ===")
raw_hits=[]
for i in range(0,len(body)-4):
    if body[i:i+4]==struct.pack("<I", 0x478):
        raw_hits.append(0x570000+i)
P(f"raw n={len(raw_hits)} {[hex(x) for x in raw_hits[:30]]}")

# Plant candidates:
# A) If a store zeros +0x478, nop the zero
# B) If a je skips filling +0x478 from node.args, nop/jmp
results=[]
def do_plant(name, patches):
    pe=bytearray(b828); s=pe_secs(pe)
    for rva,new,old in patches:
        oo=rva2off(pe,s,rva)
        cur=bytes(pe[oo:oo+len(old)])
        if cur!=old:
            P(f"  {name}: skip @{rva:06x} got={cur.hex()} want={old.hex()}")
            return
        pe[oo:oo+len(new)]=new
    out=cave/f"host_arglen_{name}.exe"; out.write_bytes(pe)
    sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
    P(f"\n=== plant {name} sha12={sha} ===")
    res=[]
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
        if time.time()-T0>BUDGET-5: break
        tag,sh,b,n868,outp=run(out,src,timeout=8)
        rtag="-"; rcrc=-1
        if tag=="OK" and outp:
            rtag,rcrc=run_bin(outp)
        P(f"  {src:16s} {tag:8s} sha={sh} n868={n868} run={rtag}/{rcrc}")
        if tag=="OK" and b and "lit" in src:
            find_sret(b,name)
            if base_sha and sh==base_sha: P("  NOTE sha==base")
        res.append((src,tag,sh,n868,rtag))
    results.append((name,sha,res))

# Plant: nop zero-stores of +0x478
for a,m,op,hx in stores:
    if "0x0]" in op or op.endswith(", 0") or ", 0" in op:
        raw=bytes.fromhex(hx)
        P(f"zero-store candidate @{a:06x} {op}")
        do_plant(f"nop_z478_{a:x}", [(a, b"\x90"*len(raw), raw)])

# If store is mov [rbp+0x478], rax from a load — the fill may be earlier skipped.
# Look for je shortly before each store
for a,m,op,hx in stores:
    oo=rva2off(b828,secs,a-0x40)
    for insn in md.disasm(bytes(b828[oo:oo+0x40]), a-0x40):
        if insn.mnemonic in ("je","jz","jne","jnz") and insn.address < a:
            raw=bytes(insn.bytes)
            P(f"jcc before store: @{insn.address:06x} {insn.mnemonic} {insn.op_str} [{raw.hex()}]")
            # Prefer nop je that jumps OVER the store (skip fill)
            # Can't easily know without target; if target > a, it's skipping past store — force jmp? 
            # If je target > store addr, nopping forces fallthrough into store — good if store is fill.
            try:
                # parse target from op_str
                tgt=int(insn.op_str, 16) if insn.op_str.startswith("0x") else None
            except: tgt=None
            if tgt and tgt > a and len(raw) in (2,6):
                P(f"  -> plant nop jcc (was skip-over-store)")
                do_plant(f"fill478_nop_{insn.address:x}", [(insn.address, b"\x90"*len(raw), raw)])

P(f"\nRESULTS: {results}")
P(f"elapsed={time.time()-T0:.1f}s DONE")
clean()
P("EXIT:0")
