"""DIG SoftCap b828_immrdx2: Capless arg0 imm->rdx before call-mk under base_828.
Nail Capless nargs/sret skip; plant force Isol-native arg0->rdx (template @57012f or nargs gate).
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

def plant_bytes(baseb, patches, label):
    pe2=bytearray(baseb); s=pe_secs(pe2)
    for r,bs in patches:
        o=rva2off(pe2,s,r)
        pe2[o:o+len(bs)]=bs
    out=cave/f"_dig_himm2_{label}.exe"; out.write_bytes(pe2); return out

def plant_int3(baseb,rvas,label):
    return plant_bytes(baseb,[(r,bytes([0xCC])) for r in rvas],label)

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
        if tag=="OK" or tag in("INT3","TIMEOUT") or attempt==2:
            break
        time.sleep(0.3)
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
    for pat in ["_dig_himm2_*.exe","_tmp__dig_himm2_*","host_b828*.exe","host_immrdx*.exe",
                "_tmp_host_b828*","_tmp_host_immrdx*","_dig_himm_*.exe","_tmp__dig_himm_*"]:
        for p in cave.glob(pat):
            try: p.unlink()
            except: pass

def find_sret(b,label):
    if not b: return False
    i=b.find(bytes([0x48,0x8d,0x45,0xd8]))
    if i<0: P(f"  {label}: no sret"); return False
    win=b[i:i+0x40]
    P(f"  {label} sret @{i:#x}:")
    for insn in md.disasm(win, i):
        P(f"    @{insn.address:04x}: {insn.mnemonic} {insn.op_str}")
    has_rdx = bytes.fromhex("4889c2") in win
    has_imm = bytes.fromhex("b80a000000") in win or bytes.fromhex("ba0a000000") in win
    P(f"  {label} has_imm10={has_imm} mov_rdx={has_rdx}")
    return has_imm and has_rdx

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)
o828=rva2off(base,secs,0x24b9c1)
b828=bytearray(base); b828[o828:o828+6]=bytes.fromhex("b82808000090")
host=cave/"host_b828.exe"; host.write_bytes(b828)
P(f"host_b828={hashlib.sha256(bytes(b828)).hexdigest()[:12]}")

# confirm base_828 stable
for attempt in range(3):
    tag,sh,b,n68,n1b8,n868,outp=run(host,"p_ret_lit.x",timeout=8)
    P(f"b828 lit try{attempt} {tag} sha={sh} n868={n868}")
    if tag=="OK":
        find_sret(b,"b828")
        rtag,rcrc=run_bin(outp,timeout=5) if outp else ("-",-1)
        P(f"  run={rtag}/{rcrc}")
        break
    time.sleep(0.4)

text_va=text_ro=text_sz=None
for n,(va,vs,ro,rs) in secs.items():
    if n==b'.text':
        text_va,text_ro,text_sz=va,ro,max(vs,rs); break
region=bytes(b828[text_ro:text_ro+text_sz])

def find_callers(target, lo=0x500000, hi=0x5c0000):
    out=[]
    for i in range(0,len(region)-5):
        if region[i]==0xe8:
            rel=struct.unpack_from("<i",region,i+1)[0]
            rva=text_va+i
            dest=rva+5+rel
            if dest==target and lo<=rva<=hi:
                out.append(rva)
    return out

# imm->rdx templates of interest
P("\n=== imm10->rdx templates disasm + callers ===")
for rva in [0x51f0d9,0x529fb3,0x57012f,0x5acf27,0x5ad405]:
    o=rva2off(b828,secs,rva-0x10 if rva>=0x10 else rva)
    P(f"\n-- around @{rva:06x} --")
    for insn in md.disasm(bytes(b828[o:o+0x40]), (rva-0x10 if rva>=0x10 else rva)):
        P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    callers=find_callers(rva)  # may be mid-insn; also try fn entry by scanning back for push rbp
    # find function entry containing this rva
    entry=None
    for back in range(0,0x80):
        er=rva-back
        eo=rva2off(b828,secs,er)
        if bytes(b828[eo:eo+3])==bytes.fromhex("554889"):  # push rbp; mov rbp
            entry=er; break
    P(f"  likely fn entry={hex(entry) if entry else None}")
    if entry:
        cs=find_callers(entry)
        P(f"  callers of entry: {[hex(c) for c in cs[:12]]} n={len(cs)}")

# Capless pre-call-mk corridor @57803d..@578273
P("\n=== Capless @57803d..@578273 (pre call-mk) ===")
o=rva2off(b828,secs,0x57803d)
for insn in md.disasm(bytes(b828[o:o+0x250]), 0x57803d):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    if insn.address>=0x578280: break

# INT3 key sites in pre-call-mk + imm template callers
P("\n=== INT3 Capless pre-call-mk / arg0 ===")
cands=[]
# collect call sites in corridor
o=rva2off(b828,secs,0x57803d)
for insn in md.disasm(bytes(b828[o:o+0x250]), 0x57803d):
    if insn.mnemonic=="call":
        cands.append((insn.address, f"call {insn.op_str}"))
    if insn.address>=0x578280: break
# add known + template entries
for rva,nm in [(0x57012f,"tmpl_57012f"),(0x51f0d9,"tmpl_51f0d9"),(0x578273,"call_mk"),
               (0x578200,"pre_8200"),(0x578100,"pre_8100"),(0x578050,"pre_8050"),
               (0x20203f,"fn_20203f"),(0x57bb30,"fn_cmk_cont")]:
    cands.append((rva,nm))
# unique preserve order
seen=set(); uniq=[]
for r,n in cands:
    if r not in seen:
        seen.add(r); uniq.append((r,n))
hits=[]
for rva,nm in uniq[:22]:
    if time.time()-T0>BUDGET-35: break
    t1=time.time()
    tag,_,_,_,_,_,_=run(plant_int3(b828,[rva],f"i{rva:x}"),timeout=5)
    mark=" HIT" if tag=="INT3" else f" {tag}"
    if tag=="INT3": hits.append((rva,nm))
    P(f"  @{rva:06x} {nm:24s} ->{mark} ({time.time()-t1:.1f}s)")
P(f"HITs: {[(hex(r),n) for r,n in hits]}")

# Dig call-mk continuation @57bafe.. for arg/reg emit (after sub rsp block)
P("\n=== call-mk @57bafe..@57bc80 (post sub-rsp) ===")
o=rva2off(b828,secs,0x57bafe)
for insn in md.disasm(bytes(b828[o:o+0x1a0]), 0x57bafe):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# INT3 calls inside post-sub-rsp that may emit args
P("\n=== INT3 call-mk post-sub calls ===")
o=rva2off(b828,secs,0x57bafe)
calls=[]
for insn in md.disasm(bytes(b828[o:o+0x1a0]), 0x57bafe):
    if insn.mnemonic=="call":
        calls.append((insn.address, insn.op_str))
    if len(calls)>=12: break
for rva,tgt in calls:
    if time.time()-T0>BUDGET-22: break
    tag,_,_,_,_,_,_=run(plant_int3(b828,[rva],f"pc{rva:x}"),timeout=5)
    P(f"  call @{rva:06x} ->{tgt} -> {tag}")

# Capless @20203f (HIT candidate from corridor) — often emit helper
P("\n=== @20203f body ===")
o=rva2off(b828,secs,0x20203f)
for insn in md.disasm(bytes(b828[o:o+0xa0]), 0x20203f):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

results=[]
def do_plant(name, patches):
    pe=bytearray(b828); s=pe_secs(pe)
    for rva,new,old in patches:
        o=rva2off(pe,s,rva)
        cur=bytes(pe[o:o+len(old)])
        if cur!=old:
            P(f"  {name}: skip bad @{rva:06x} {cur.hex()}!={old.hex()}")
            return None
        pe[o:o+len(new)]=new
    out=cave/f"host_immrdx_{name}.exe"; out.write_bytes(pe)
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
    return sha

# Plant strategy:
# SoftCap lit USER missing imm->rdx means Capless nargs for user args is 0 under sret.
# Find Capless store/cmp of arg count near @57803d..@578273.
# Look for `cmp dword [rbp+X], 0; je` on-path (HIT) that skips arg emit before call-mk.
P("\n=== scan Capless @577f00..@578273 for on-path je-skip ===")
o=rva2off(b828,secs,0x577f00)
je_sites=[]
for insn in md.disasm(bytes(b828[o:o+0x380]), 0x577f00):
    if insn.mnemonic in ("je","jz","jle") and len(insn.bytes) in (2,6):
        je_sites.append((insn.address, f"{insn.mnemonic} {insn.op_str}", bytes(insn.bytes)))
    if insn.address>=0x578273: break

planted=False
# INT3 je sites; if HIT and target jumps forward over calls, nop to force fallthrough
for rva,desc,raw in je_sites:
    if time.time()-T0>BUDGET-14: break
    tag,_,_,_,_,_,_=run(plant_int3(b828,[rva],f"je{rva:x}"),timeout=5)
    P(f"  @{rva:06x} {desc:30s} -> {tag}")
    if tag=="INT3" and not planted and len(raw)==2:
        # only plant if jump target skips forward (likely skip-args)
        # decode rel8
        rel=struct.unpack("b", raw[1:2])[0]
        tgt=rva+2+rel
        if tgt>rva+2+8:  # skips at least some code
            P(f"  -> plant b828_immrdx nop @{rva:06x} (skip to {tgt:#x})")
            do_plant("b828_immrdx", [(rva, b"\x90\x90", raw)])
            planted=True

# Alt plant: force Capless to call Isol imm->rdx template fn if we found Capless-local entry
# @57012f — if in a fn and Capless has a nearby je that skips calling it
if not planted:
    # Look at Capless kind3 success path: after tries all return 0, before call-mk,
    # SoftCap lit may hit `cmp [nargs],0; je call_mk` skipping arg loop.
    # From corridor, @57803d call @20203f — dig if that's arg-related.
    # Plant: at @57ba0f je @57bafe — when ebx!=0 skips sub-rsp. SoftCap lit has ebx==0 (HIT on je? prior: je HIT means taken? INT3 on je means instruction reached; ZF determines take).
    # Prior: @57ba0f je HIT — so SoftCap lit reaches the je. With ebx==0, sete=1, test nz, je NOT taken → emit sub rsp. Good.
    # Arg0 still missing before that.
    #
    # Force emit of mov rdx by patching call-mk to also write ba0a+4889c2 before E8?
    # That would be fabricating USER bytes inside call-mk — possible Isol-native if call-mk already has
    # a code path that writes those bytes for nargs>0.
    # Dig further in @57bafe for mov eax,imm / enc calls that write rdx.
    P("\n=== search call-mk body for imm/rdx byte writes ===")
    o=rva2off(b828,secs,0x57b98c)
    body=bytes(b828[o:o+0x400])
    for pat,nm in [(bytes.fromhex("ba0a000000"),"ba0a"),(bytes.fromhex("4889c2"),"4889c2"),
                   (bytes.fromhex("b80a000000"),"b80a"),(bytes([0xb8,0x0a,0,0,0]),"mov_eax_a")]:
        idx=0; found=[]
        while True:
            i=body.find(pat, idx)
            if i<0: break
            found.append(0x57b98c+i); idx=i+1
        P(f"  {nm}: {[hex(x) for x in found[:8]]}")

# If call-mk has no ba0a, arg0 emit is Capless-side before call @57b98c.
# Plant last resort: Capless @57803d area — force a known nargs slot to 1.
# Search for `mov dword [rbp+disp], 0` then later cmp that slot near CallExpr.
P("\n=== Capless mov dword [rbp+..],0 near pre-call-mk ===")
o=rva2off(b828,secs,0x577c00)
zeros=[]
for insn in md.disasm(bytes(b828[o:o+0x600]), 0x577c00):
    if insn.mnemonic=="mov" and "dword ptr" in insn.op_str and insn.op_str.endswith(", 0"):
        zeros.append((insn.address, insn.op_str, bytes(insn.bytes)))
    if insn.address>=0x578280: break
P(f"  zero-stores n={len(zeros)} sample={[(hex(a),d) for a,d,_ in zeros[:15]]}")

# INT3 zero-stores; if HIT, SoftCap lit zeros a slot — candidate nargs. Plant: change imm 0 -> 1
for rva,desc,raw in zeros[:10]:
    if time.time()-T0>BUDGET-8: break
    tag,_,_,_,_,_,_=run(plant_int3(b828,[rva],f"z{rva:x}"),timeout=5)
    P(f"  @{rva:06x} {desc:40s} -> {tag}")
    if tag=="INT3" and not planted and len(raw)>=7 and raw[-4:]==b"\x00\x00\x00\x00" and raw[0] in (0xc7,):
        # mov dword [rbp+X], 0 — change to 1
        new=bytearray(raw); new[-4]=1
        P(f"  -> plant b828_immrdx mov-1 @{rva:06x}")
        do_plant("b828_immrdx", [(rva, bytes(new), bytes(raw))])
        planted=True
        break

if not planted:
    # Final: nop Capless je @577cb3 was prior plant. Try forcing Capless to invoke
    # arg emit by changing cmp [rbp+0x3e0],0x60 jle — kind size gate — already on path.
    # Plant at call-mk: the block that emits sub rsp is on path; after it @57bafe calls something
    # with nargs. Look at @57bb30 area from prior HIT for cmp nargs.
    P("\n=== @57bb20.. disasm + plant je-nop if HIT skip ===")
    o=rva2off(b828,secs,0x57bb20)
    for insn in md.disasm(bytes(b828[o:o+0x60]), 0x57bb20):
        P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
        if insn.mnemonic in ("je","jz") and len(insn.bytes)==2 and not planted:
            tag,_,_,_,_,_,_=run(plant_int3(b828,[insn.address],f"x{insn.address:x}"),timeout=5)
            P(f"    INT3 -> {tag}")
            if tag=="INT3":
                do_plant("b828_immrdx", [(insn.address, b"\x90\x90", bytes(insn.bytes))])
                planted=True

P(f"\nPLANTED={planted}")
P(f"RESULTS: {results}")
P(f"elapsed={time.time()-T0:.1f}s DONE")
for p in list(cave.glob("_dig_himm2_*.exe"))+list(cave.glob("_tmp__dig_himm2_*")):
    try: p.unlink()
    except: pass
for p in list(cave.glob("host_b828*.exe"))+list(cave.glob("host_immrdx*.exe")):
    try: p.unlink()
    except: pass
for p in list(cave.glob("_tmp_host_b828*"))+list(cave.glob("_tmp_host_immrdx*")):
    try: p.unlink()
    except: pass
P("EXIT:0")
