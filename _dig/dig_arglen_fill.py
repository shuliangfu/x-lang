"""DIG Capless after +0x478 alloc: where CallExpr args should be pushed before pre_last.
Nail skipped fill; one plant if isolatable. Budget<=85s.
Ban tip@121278/join/epi/LIVE/mega/arg-loop.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64)

cave = Path(r"C:\xlang_tmp\p1060\cave"); os.chdir(str(cave))
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

def plant_bytes(baseb, patches, label):
    pe2=bytearray(baseb); s=pe_secs(pe2)
    for r,bs in patches:
        o=rva2off(pe2,s,r)
        pe2[o:o+len(bs)]=bs
    out=cave/f"_dig_af_{label}.exe"; out.write_bytes(pe2); return out

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

def clean():
    for pat in ["_dig_af_*.exe","_tmp__dig_af_*","host_b828*.exe","host_arglen*.exe",
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

# Disasm Capless from @57664e to @5781c0 (post-alloc to pre call setup) — look for loops / push / get-elem on AST args
P("\n=== DISASM Capless @57664e .. @576900 (post-alloc head) ===")
o=rva2off(b828,secs,0x57664e)
for insn in md.disasm(bytes(b828[o:o+0x2c0]), 0x57664e):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    if insn.address >= 0x576900: break

P("\n=== E8 calls in Capless @57664e..@578200 ===")
o=rva2off(b828,secs,0x57664e)
body=bytes(b828[o:o+(0x578200-0x57664e)])
calls=[]
for i in range(0,len(body)-5):
    if body[i]!=0xe8: continue
    rel=struct.unpack_from("<i",body,i+1)[0]
    site=0x57664e+i
    tgt=site+5+rel
    # filter likely valid .text
    if 0x1000 <= tgt <= 0x700000:
        calls.append((site,tgt))
P(f"n={len(calls)}")
for s,t in calls:
    P(f"  @{s:06x} -> @{t:06x}")

# Disasm @55d730 head (allocator)
P("\n=== DISASM @55d730 alloc head ===")
o=rva2off(b828,secs,0x55d730)
for insn in md.disasm(bytes(b828[o:o+0x50]), 0x55d730):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    if insn.mnemonic=="ret": break

# Search for calls to @2a62c9 / push-like / @2a5ca8 in Capless fill window
P("\n=== Capless calls to len/getelem/push-ish ===")
for tgt,nm in [(0x2a62c9,"len"),(0x2a5ca8,"getelem"),(0x215c68,"len_inner"),
               (0x215bd0,"set_len?"),(0x2a4750,"vec_len"),(0x55d730,"alloc")]:
    hits=[s for s,t in calls if t==tgt]
    # also search full Capless fn
    o=rva2off(b828,secs,0x576000)
    body=bytes(b828[o:o+0x2300])
    hs=[]
    for i in range(0,len(body)-5):
        if body[i]!=0xe8: continue
        rel=struct.unpack_from("<i",body,i+1)[0]
        site=0x576000+i
        if site+5+rel==tgt:
            hs.append(site)
    P(f"  {nm} (@{tgt:06x}): in-window={[hex(x) for x in hits]} all-capless={[hex(x) for x in hs]}")

# INT3 sample of early post-alloc calls (first 8 unique)
P("\n=== INT3 first post-alloc calls ===")
seen=set()
for s,t in calls:
    if time.time()-T0>BUDGET-35: break
    if s in seen: continue
    if s > 0x577000:  # focus earlier first
        continue
    seen.add(s)
    pe=plant_bytes(b828,[(s,bytes([0xCC]))],f"c{s:x}")
    tag,_,_,_,_=run(pe)
    P(f"  @{s:06x}->{t:06x} -> {tag}")
    if len(seen)>=12: break

# Also INT3 a few mid/late before pre_last
P("\n=== INT3 late Capless before pre_last ===")
late=[(s,t) for s,t in calls if 0x577800 <= s < 0x578200]
for s,t in late[-8:]:
    if time.time()-T0>BUDGET-25: break
    pe=plant_bytes(b828,[(s,bytes([0xCC]))],f"l{s:x}")
    tag,_,_,_,_=run(pe)
    P(f"  @{s:06x}->{t:06x} -> {tag}")

# Look for node.args field load — common offsets. Capless has [rbp+0x490]=node.
# Search mov from [reg+imm] after loading +0x490 in post-alloc region
P("\n=== loads from [rbp+0x490] then field in @57664e..@577200 ===")
o=rva2off(b828,secs,0x57664e)
body=bytes(b828[o:o+0xc00])
prev490=None
for insn in md.disasm(body, 0x57664e):
    if "0x490" in insn.op_str and "rbp" in insn.op_str and insn.mnemonic.startswith("mov"):
        prev490=insn.address
        P(f"  load490 @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    # field load patterns shortly after
    if prev490 and insn.address-prev490 < 0x30 and "[" in insn.op_str and ("rax" in insn.op_str or "rcx" in insn.op_str or "rbx" in insn.op_str):
        if any(f"0x{k}" in insn.op_str or f"+ {k}" in insn.op_str for k in ["0x20","0x28","0x30","0x38","0x40","0x48","0x50","0x58","0x60","0x68","0x70","0x78","0x80","0x88","0x90","0x98","0xa0","0xa8","0xb0","0xb8","0xc0"]):
            P(f"    field? @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Plant: if SoftCap lit skips a fill block via je — find je that skip large regions between alloc and pre_last
P("\n=== large forward je/jne in @57664e..@5781c0 ===")
o=rva2off(b828,secs,0x57664e)
jccs=[]
for insn in md.disasm(bytes(b828[o:o+(0x5781c0-0x57664e)]), 0x57664e):
    if insn.mnemonic in ("je","jz","jne","jnz","jg","jle","jl","jge","ja","jb"):
        try:
            tgt=int(insn.op_str,16)
        except: continue
        dist=tgt-insn.address
        if dist > 0x40:  # skip substantial
            jccs.append((insn.address, insn.mnemonic, tgt, dist, bytes(insn.bytes)))
P(f"n={len(jccs)}")
for a,m,t,d,raw in jccs[:25]:
    P(f"  @{a:06x} {m} -> @{t:06x} dist={d:#x} [{raw.hex()}]")

# INT3 on a few large-skip jccs that HIT on SoftCap lit path
P("\n=== INT3 large-skip jccs (first 10) ===")
hits_jcc=[]
for a,m,t,d,raw in jccs[:10]:
    if time.time()-T0>BUDGET-15: break
    pe=plant_bytes(b828,[(a,bytes([0xCC]))],f"j{a:x}")
    tag,_,_,_,_=run(pe)
    P(f"  @{a:06x} {m} -> {tag}")
    if tag=="INT3":
        hits_jcc.append((a,m,t,d,raw))

results=[]
def do_plant(name, patches):
    pe=bytearray(b828); s=pe_secs(pe)
    for rva,new,old in patches:
        oo=rva2off(pe,s,rva)
        cur=bytes(pe[oo:oo+len(old)])
        if cur!=old:
            P(f"  {name}: skip @{rva:06x}"); return
        pe[oo:oo+len(new)]=new
    out=cave/f"host_arglen_{name}.exe"; out.write_bytes(pe)
    sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
    P(f"\n=== plant {name} sha12={sha} ===")
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

# Plant: nop first HIT large je that skips fill (if target skips toward pre_last)
for a,m,t,d,raw in hits_jcc[:2]:
    # If je skips forward a lot, nopping forces fallthrough into skipped body (fill?)
    if m in ("je","jz") and len(raw) in (2,6):
        do_plant(f"fill_nop_{a:x}", [(a, b"\x90"*len(raw), raw)])
    elif m in ("jne","jnz") and len(raw) in (2,6):
        # jne taken = skip? force jmp always take skip — wrong. force nop = always fallthrough
        do_plant(f"fill_nop_{a:x}", [(a, b"\x90"*len(raw), raw)])

P(f"\nRESULTS: {results}")
P(f"elapsed={time.time()-T0:.1f}s DONE")
clean()
P("EXIT:0")
