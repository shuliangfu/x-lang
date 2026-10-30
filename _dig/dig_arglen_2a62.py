"""DIG SoftCap lit arg container @2a62c9 len=0.
Who writes/clears CallExpr args; how to fill so len>=1 enters @2a5ca8 for imm->rdx.
Under base_828. Budget<=85s. Ban tip@121278/join/epi/LIVE/mega/arg-loop.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64); md.detail = True

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
    out=cave/f"_dig_al_{label}.exe"; out.write_bytes(pe2); return out

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
    for pat in ["_dig_al_*.exe","_tmp__dig_al_*","host_b828*.exe","host_arglen*.exe",
                "_tmp_host_b828*","_tmp_host_arglen*"]:
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

def disasm_range(buf, secs, rva, n=0x80, label=""):
    o=rva2off(buf,secs,rva)
    P(f"\n=== DISASM {label} @{rva:06x} +{n:#x} ===")
    for insn in md.disasm(bytes(buf[o:o+n]), rva):
        P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
        if insn.mnemonic=="ret":
            break

def find_calls_to(buf, secs, target, scan_start=0x1000, scan_end=None):
    """Find E8 call sites targeting `target` RVA in .text."""
    text = secs.get(b".text") or secs.get(".text")
    if text is None:
        # try bytes keys
        for k in secs:
            if k == b".text" or k == ".text" or (isinstance(k,bytes) and k.startswith(b".text")):
                text=secs[k]; break
    if text is None:
        # first large section
        text=max(secs.values(), key=lambda t: t[1])
    va,vs,ro,rs = text
    end = scan_end or (va+min(vs,rs))
    start = max(va, scan_start)
    o0 = ro + (start - va)
    body = bytes(buf[o0:o0+(end-start)])
    hits=[]
    for i in range(0, len(body)-5):
        if body[i]!=0xe8: continue
        rel=struct.unpack_from("<i", body, i+1)[0]
        site = start+i
        dest = site+5+rel
        if dest==target:
            hits.append(site)
    return hits

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

# --- DIG1: disasm @2a62c9 (len helper) ---
disasm_range(b828, secs, 0x2a62c9, 0xa0, "len_helper_2a62c9")

# --- DIG2: disasm @2a5ca8 (get-elem) ---
disasm_range(b828, secs, 0x2a5ca8, 0x80, "getelem_2a5ca8")

# --- DIG3: caller context around @568870..@568900 (setup [rbp-0x30], call len, je, get-elem) ---
disasm_range(b828, secs, 0x568850, 0xc0, "caller_pre_len_getelem")

# --- DIG4: wider pre_last post-zero from @56814a looking for container setup ---
disasm_range(b828, secs, 0x56814a, 0x200, "post_zero_to_mid")

# --- DIG5: find all callers of @2a62c9 ---
P("\n=== CALLERS of @2a62c9 ===")
callers = find_calls_to(b828, secs, 0x2a62c9)
P(f"  n={len(callers)}")
for c in callers[:20]:
    P(f"  call-site @{c:06x}")
    # show 0x30 before each
    o=rva2off(b828,secs,max(c-0x30,0x1000))
    for insn in md.disasm(bytes(b828[o:o+0x40]), max(c-0x30,0x1000)):
        mark = " <<<" if insn.address==c else ""
        P(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}{mark}")
        if insn.address > c+5: break

# --- DIG6: find callers of @2a5ca8 ---
P("\n=== CALLERS of @2a5ca8 (get-elem) ===")
callers2 = find_calls_to(b828, secs, 0x2a5ca8)
P(f"  n={len(callers2)}")
for c in callers2[:12]:
    P(f"  @{c:06x}")

# --- DIG7: look for vec/array push / append patterns near SoftCap CallExpr Capless
# Search for stores that write to [reg+0x??] size/len fields near Capless CallExpr path
# Focus: @201f36 after-path and Capless corridor that should fill args
P("\n=== Capless CallExpr corridor refs to 2a62 / vec helpers ===")
# scan Capless region 0x576000..0x579000 for E8 to 2a62c9 / 2a5ca8 / push-like
for tgt,nm in [(0x2a62c9,"len"),(0x2a5ca8,"getelem"),(0x2a5d00,"getelem+"),(0x201f36,"201f36")]:
    cs=find_calls_to(b828, secs, tgt, scan_start=0x567000, scan_end=0x579800)
    P(f"  calls->{nm}(@{tgt:06x}) in Capless-ish: n={len(cs)} {[hex(x) for x in cs[:8]]}")

# --- DIG8: INT3 probe: capture eax after @2a62c9 return (replace next insn with int3) ---
# Prior: call@56888d HIT, then je@5688b7 HIT (taken=skip). Confirm eax==0 at return.
P("\n=== INT3 after @2a62c9 / at je / at container setup ===")
probes = [
    (0x56888d, "call_2a62c9"),
    (0x568892, "after_len_ret"),  # likely next insn after call
    (0x5688b7, "je_idx_ge_len"),
    (0x568870, "je_null_30"),
    (0x568850, "setup_850"),
    (0x568860, "setup_860"),
]
# decode exact after-call
o=rva2off(b828,secs,0x56888d)
insns=list(md.disasm(bytes(b828[o:o+0x40]), 0x56888d))
P("  decode @56888d..:")
after=None
for i,insn in enumerate(insns):
    P(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    if i==1: after=insn.address
for rva,nm in probes:
    if time.time()-T0 > BUDGET-25: break
    pe=plant_bytes(b828,[(rva,bytes([0xCC]))],f"i{rva:x}")
    tag,_,_,_,_,_,_=run(pe,timeout=5)
    P(f"  @{rva:06x} {nm:18s} -> {tag}")

# Also INT3 at known arg-fill candidates in pre_last that may write container
# From dig2: @568587 call@205068, @56822a call@1933d8, @5681f9 call@201f36
P("\n=== INT3 arg-fill candidate calls (HIT/miss) ===")
for rva,nm in [
    (0x5681f9,"call_201f36"),
    (0x56822a,"call_1933d8"),
    (0x568587,"call_205068"),
    (0x568829,"call_1ffe34"),
    (0x5684f2,"alt_fill_tgt"),
]:
    if time.time()-T0 > BUDGET-20: break
    pe=plant_bytes(b828,[(rva,bytes([0xCC]))],f"i{rva:x}")
    tag,_,_,_,_,_,_=run(pe,timeout=5)
    P(f"  @{rva:06x} {nm:18s} -> {tag}")

# --- DIG9: plant arglen — force eax=1 after @2a62c9 so je falls through to get-elem ---
# After call @56888d, next should use eax as len. Plant: mov eax,1 (b801000000) over whatever
# stores len, OR at after-call overwrite first use.
P("\n=== PLANT arglen / fill_args ===")
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
    out=cave/f"host_arglen_{name}.exe"; out.write_bytes(pe)
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

# Decode after call to choose plant
# Typical: call; mov [rbp-0x30], eax; cmp ...; je
# Or: call; test eax; je
# Plant A: after call, force mov eax,1 if next uses eax — find first insn after call
if after is not None:
    o=rva2off(b828,secs,after)
    insn=next(md.disasm(bytes(b828[o:o+16]), after))
    raw=bytes(insn.bytes)
    P(f"after_len @{after:06x}: {insn.mnemonic} {insn.op_str} [{raw.hex()}]")
    # If it's mov dword/qword [rbp-xx], eax — patch to mov eax,1; mov [..],eax  may be longer.
    # Safer: at call site, replace CALL with `mov eax,1; nop*` same length (5 bytes: b8 01 00 00 00)
    # That forces len=1 WITHOUT calling len helper — may get-elem on empty -> AV like prelast.
    # Better semantic: force after-call `mov eax,1` if the store is separate.
    # Plant arglen_force1: replace 5-byte CALL @56888d with mov eax,1
    call_raw = bytes(b828[rva2off(b828,secs,0x56888d):rva2off(b828,secs,0x56888d)+5])
    P(f"call@56888d bytes={call_raw.hex()}")
    if call_raw[0]==0xe8:
        do_plant("arglen_force1", [(0x56888d, bytes.fromhex("b801000000"), call_raw)])

# Plant B: if after is `mov [rbp-0x30], eax` (89 45 d0 or 8945d0), insert isn't easy;
# instead nop the je@5688b7 was already AV. Try: force cmp to always see len>=1 by
# patching the compare source — disasm will tell.

# Plant C fill_args: look for earlier skip of args-push. From dig2 HIT je@568273 je_tok0 —
# if that skips token/arg fill, nop it to force fill path.
o=rva2off(b828,secs,0x568273)
insn=next(md.disasm(bytes(b828[o:o+16]), 0x568273))
raw=bytes(insn.bytes)
P(f"je_tok0 @{0x568273:06x}: {insn.mnemonic} {insn.op_str} [{raw.hex()}] -> {insn.op_str}")
if insn.mnemonic in ("je","jz") and len(raw)==2:
    # nop = always fallthrough (fill?)
    do_plant("fill_args_tok0", [(0x568273, b"\x90"*2, raw)])
elif insn.mnemonic in ("je","jz") and len(raw)==6:
    do_plant("fill_args_tok0", [(0x568273, b"\x90"*6, raw)])

# Also try je_null before container @568870 — if HIT AV when int3, it's on path;
# force jmp (always skip null check) or nop (always fallthrough)
o=rva2off(b828,secs,0x568870)
insn=next(md.disasm(bytes(b828[o:o+16]), 0x568870))
raw=bytes(insn.bytes)
P(f"je_null_30 @{0x568870:06x}: {insn.mnemonic} {insn.op_str} [{raw.hex()}]")
# Prior INT3 at je_null_30 was AV — so SoftCap lit may take null path OR AV at int3 means reached.
# If container ptr null, forcing fill elsewhere is needed.

P(f"\nRESULTS: {results}")
P(f"elapsed={time.time()-T0:.1f}s DONE")
clean()
P("EXIT:0")
