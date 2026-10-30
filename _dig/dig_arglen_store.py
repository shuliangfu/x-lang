"""DIG who writes [rbp-0x30] CallExpr args container in pre_last@567a30.
Also find push/append into that vec. Budget<=70s.
Ban tip@121278/join/epi/LIVE/mega/arg-loop.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64)

cave = Path(r"C:\xlang_tmp\p1060\cave"); os.chdir(str(cave))
T0=time.time(); BUDGET=70

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
    out=cave/f"_dig_as_{label}.exe"; out.write_bytes(pe2); return out

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
            return "TIMEOUT","-",b"",0
        tag={0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc,f"crc={crc:#x}")
        if tag=="OK" or tag in("INT3","TIMEOUT") or attempt==2: break
        time.sleep(0.3)
    b=out.read_bytes() if out.exists() else b""
    sh=hashlib.sha256(b).hexdigest()[:12] if b else "-"
    n868=b.count(bytes.fromhex("4881ec68080000")) if b else 0
    return tag,sh,b,n868

def run_bin(exe,timeout=5):
    try:
        r=subprocess.run([str(exe)],capture_output=True,timeout=timeout)
        crc=r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT",-1
    tag={0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc,f"crc={crc:#x}")
    return tag, crc

def find_sret(b,label):
    if not b: return
    i=b.find(bytes([0x48,0x8d,0x45,0xd8]))
    if i<0: P(f"  {label}: no sret"); return
    win=b[i:i+0x50]
    true_immrdx=False
    e8pos=win.find(b"\xe8")
    if e8pos>0:
        pre=win[:e8pos]
        true_immrdx = (bytes.fromhex("4889c2") in pre) and (
            bytes.fromhex("b80a000000") in pre or bytes.fromhex("ba0a000000") in pre)
    has_cmk = bytes.fromhex("4883ec20") in b[i:i+0x30] and b"\xe8" in win
    P(f"  {label} true_immrdx={true_immrdx} callmk={has_cmk}")

def clean():
    for pat in ["_dig_as_*.exe","_tmp__dig_as_*","host_b828*.exe","host_arglen*.exe",
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
for attempt in range(3):
    tag,sh,b,n868=run(host)
    P(f"b828 lit try{attempt} {tag} sha={sh} n868={n868}")
    if tag=="OK" and n868>=1:
        find_sret(b,"b828"); base_sha=sh; break
    time.sleep(0.3)

# Scan pre_last body @567a30 .. ~@56ab50 for refs to [rbp-0x30] / [rbp+0x??] that set container
# Also Capless caller that sets up pre_last args
P("\n=== SCAN pre_last for [rbp-0x30] / rbp-0x30 refs ===")
o=rva2off(b828,secs,0x567a30)
# find ret end
body=bytes(b828[o:o+0x3200])
end=None
for insn in md.disasm(body, 0x567a30):
    if insn.mnemonic=="ret":
        end=insn.address; break
P(f"pre_last end={hex(end) if end else '?'}")
scan_end = (end or 0x56ab50) + 0x20
scan_len = scan_end - 0x567a30
body=bytes(b828[o:o+scan_len])

stores30=[]; loads30=[]; all30=[]
for insn in md.disasm(body, 0x567a30):
    op=insn.op_str
    if "rbp" in op and ("0x30" in op or "-0x30" in op):
        # filter true -0x30 (not -0x300 etc)
        if "-0x30]" in op or "+0x30]" in op or "rbp - 0x30" in op or "rbp + 0x30" in op:
            all30.append((insn.address, insn.mnemonic, op))
            if insn.mnemonic.startswith("mov") and op.startswith("qword ptr") or (insn.mnemonic.startswith("mov") and "[" in op.split(",")[0]):
                # store if dest is mem
                left=op.split(",")[0].strip()
                if "[" in left:
                    stores30.append((insn.address, insn.mnemonic, op, bytes(insn.bytes).hex()))
            if insn.mnemonic.startswith("mov") and "[" in op and op.find("[")>op.find(","):
                loads30.append((insn.address, insn.mnemonic, op))

P(f"all rbp±0x30 refs n={len(all30)}")
for a,m,op in all30:
    P(f"  @{a:06x}: {m} {op}")
P(f"stores to [rbp-0x30] n={len(stores30)}")
for a,m,op,hx in stores30:
    P(f"  STORE @{a:06x}: {m} {op} [{hx}]")

# Also scan for zeroing of [rbp-0x30] via xor/mov 0
P("\n=== nearby context for each STORE ===")
for a,m,op,hx in stores30:
    oo=rva2off(b828,secs,a-0x20)
    P(f"--- around STORE @{a:06x} ---")
    for insn in md.disasm(bytes(b828[oo:oo+0x50]), a-0x20):
        mark=" <<<" if insn.address==a else ""
        P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}{mark}")
        if insn.address > a+8: break

# Who calls pre_last @567a30 — Capless corridor may pass args container
P("\n=== callers of pre_last @567a30 ===")
text=None
for k,v in secs.items():
    kn = k.decode() if isinstance(k,bytes) else k
    if kn.startswith(".text"):
        text=v; break
va,vs,ro,rs=text
body=bytes(b828[ro:ro+min(vs,rs)])
hits=[]
for i in range(0,len(body)-5):
    if body[i]!=0xe8: continue
    rel=struct.unpack_from("<i",body,i+1)[0]
    site=va+i
    if site+5+rel==0x567a30:
        hits.append(site)
P(f"n={len(hits)}")
for c in hits[:10]:
    P(f"  @{c:06x}")
    oo=rva2off(b828,secs,c-0x40)
    for insn in md.disasm(bytes(b828[oo:oo+0x60]), c-0x40):
        mark=" <<<" if insn.address==c else ""
        P(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}{mark}")
        if insn.address>c+5: break

# INT3 on each store of [rbp-0x30]
P("\n=== INT3 on [rbp-0x30] STOREs ===")
for a,m,op,hx in stores30:
    if time.time()-T0>BUDGET-20: break
    pe=plant_bytes(b828,[(a,bytes([0xCC]))],f"s{a:x}")
    tag,_,_,_=run(pe)
    P(f"  @{a:06x} -> {tag}")

# Look for vec push helpers called with container — common pattern call after loading [rbp-0x30]
# Search E8 targets from sites that have rcx=[rbp-0x30] shortly before
P("\n=== calls with rcx from [rbp-0x30] in pre_last (push candidates) ===")
# walk and note call after mov rcx, [rbp-0x30]
prev_load30=None
push_cands=[]
for insn in md.disasm(bytes(b828[rva2off(b828,secs,0x567a30):rva2off(b828,secs,0x567a30)+scan_len]), 0x567a30):
    if insn.mnemonic=="mov" and "rcx" in insn.op_str.split(",")[0] and "rbp" in insn.op_str and "-0x30" in insn.op_str:
        prev_load30=insn.address
    if insn.mnemonic=="call" and prev_load30 and insn.address-prev_load30 < 0x20:
        # resolve target
        raw=bytes(insn.bytes)
        if raw[0]==0xe8:
            rel=struct.unpack_from("<i",raw,1)[0]
            tgt=insn.address+5+rel
            push_cands.append((insn.address, tgt, prev_load30))
        prev_load30=None
P(f"push-ish n={len(push_cands)}")
for site,tgt,ld in push_cands:
    P(f"  load@{ld:06x} -> call@{site:06x} -> @{tgt:06x}")

# Plant: if we find a store that zeros [rbp-0x30], nop it? Or force a known live container — hard.
# Better plant: at @568876 idx=0 path, AFTER len call — already tried force1.
# Try plant: skip the je_null by making [rbp-0x30] check always pass AND force len — still empty get-elem AV.
# Semantic fill: find where Capless SHOULD append CallExpr arg0 into the vec.
# Look at @568587 call@205068 and @56822a — prior HIT. Disasm those helpers briefly.

P("\n=== DISASM @205068 (HIT call from pre_last) head ===")
oo=rva2off(b828,secs,0x205068)
for insn in md.disasm(bytes(b828[oo:oo+0x60]), 0x205068):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    if insn.mnemonic=="ret": break

P("\n=== DISASM @1933d8 head ===")
oo=rva2off(b828,secs,0x1933d8)
for insn in md.disasm(bytes(b828[oo:oo+0x40]), 0x1933d8):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    if insn.mnemonic=="ret": break

# Where is [rbp-0x30] first assigned — likely early in pre_last after args setup
# Also check Capless @5781xx that calls pre_last — what it puts in registers/stack

P("\n=== Capless call-pre_last site @5781f4 area ===")
for start in [0x5781c0, 0x578220, 0x578070]:
    oo=rva2off(b828,secs,start)
    P(f"-- @{start:06x} --")
    for insn in md.disasm(bytes(b828[oo:oo+0x80]), start):
        P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
        if insn.address > start+0x70: break

# Plant fill: if store zeros container early, try nop zero-store of [rbp-0x30]
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
        tag,sh,b,n868=run(out,src,timeout=8)
        rtag="-"; rcrc=-1
        outp=cave/f"_tmp_{out.stem}_{Path(src).stem}.exe"
        if tag=="OK" and outp.exists():
            rtag,rcrc=run_bin(outp)
        P(f"  {src:16s} {tag:8s} sha={sh} n868={n868} run={rtag}/{rcrc}")
        if tag=="OK" and b and "lit" in src:
            find_sret(b,name)
            if base_sha and sh==base_sha: P(f"  NOTE sha==base")
        res.append((src,tag,sh,n868,rtag))
    results.append((name,sha,res))

# If we have a zeroing store mov qword [rbp-0x30], 0 — nop it (may keep stale — unlikely help)
# Better: look for je that skips push-arg loop
P("\n=== dig je near first store / push ===")
if stores30:
    first=stores30[0][0]
    # scan ±0x100 for je
    oo=rva2off(b828,secs,max(0x567a30, first-0x100))
    for insn in md.disasm(bytes(b828[oo:oo+0x200]), max(0x567a30, first-0x100)):
        if insn.mnemonic in ("je","jz","jne","jnz") and abs(insn.address-first)<0x80:
            P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str} [{bytes(insn.bytes).hex()}]")

P(f"\nRESULTS: {results}")
P(f"elapsed={time.time()-T0:.1f}s DONE")
clean()
P("EXIT:0")
