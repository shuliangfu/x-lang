"""DIG2 SoftCap prelast_immrdx: post-zero @56814a / @201f36 / store@576583 [498]
One plant prelast_immrdx; keep call-mk. Budget<=85s.
Ban tip@121278/join/epi/LIVE/mega/arg-loop.
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
    out=cave/f"_dig_pl2_{label}.exe"; out.write_bytes(pe2); return out

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
    for pat in ["_dig_pl2_*.exe","_tmp__dig_pl2_*","host_b828*.exe","host_prelast*.exe",
                "_tmp_host_b828*","_tmp_host_prelast*"]:
        for p in cave.glob(pat):
            try: p.unlink()
            except: pass

def find_sret(b,label):
    if not b: return False, False, False
    i=b.find(bytes([0x48,0x8d,0x45,0xd8]))
    if i<0:
        P(f"  {label}: no sret lea"); return False, False, False
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
    return true_immrdx, has_sub20 and has_call, has_imm

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
    tag,sh,b,n68,n1b8,n868,outp=run(host,"p_ret_lit.x",timeout=8)
    P(f"b828 lit try{attempt} {tag} sha={sh} n868={n868}")
    if tag=="OK" and n868>=1:
        find_sret(b,"b828"); base_sha=sh
        rtag,rcrc=run_bin(outp,timeout=5) if outp else ("-",-1)
        P(f"  run={rtag}/{rcrc}")
        break
    time.sleep(0.4)

# decode @576583 neighborhood + post-zero key
P("\n=== decode @576580 / Capless store 498+4a0 ===")
o=rva2off(b828,secs,0x576570)
for insn in md.disasm(bytes(b828[o:o+0x40]), 0x576570):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    if insn.address>=0x5765b0: break

P("\n=== INT3 post-zero / emit-ish / store498 ===")
cands=[
    (0x56814a,"pz_sub20"),
    (0x56815c,"call_20203f"),
    (0x568183,"pz_je_le0"),
    (0x5681b5,"pz_je_gtff"),
    (0x5681f9,"call_201f36"),
    (0x56822a,"call_1933d8"),
    (0x568251,"je_null_tok"),
    (0x568273,"je_tok0"),
    (0x568523,"call_23030e"),
    (0x568587,"call_205068"),
    (0x5687b8,"call_5adf04"),
    (0x568829,"call_1ffe34"),
    (0x56888d,"call_2a62c9"),
    (0x5688d2,"call_2a5ca8"),
    (0x576583,"store_498"),
    (0x57658b,"store_4a0"),
    (0x578238,"load_rdx_498"),
]
hits=[]
for rva,nm in cands:
    if time.time()-T0>BUDGET-40: break
    t1=time.time()
    tag,_,_,_,_,_,_=run(plant_int3(b828,[rva],f"i{rva:x}"),timeout=5)
    mark=" HIT" if tag=="INT3" else f" {tag}"
    if tag=="INT3": hits.append((rva,nm))
    P(f"  @{rva:06x} {nm:18s} ->{mark} ({time.time()-t1:.1f}s)")
P(f"HITs: {[(hex(r),n) for r,n in hits]}")

# decode HIT jcc for plant
P("\n=== decode HIT sites ===")
hit_set={r for r,_ in hits}
plant_jccs=[]
for rva,nm in hits:
    o=rva2off(b828,secs,rva)
    insn=next(md.disasm(bytes(b828[o:o+16]), rva))
    P(f"  @{rva:06x} {nm}: {insn.mnemonic} {insn.op_str} [{bytes(insn.bytes).hex()}]")
    if insn.mnemonic.startswith("j") and insn.mnemonic not in ("jmp","jecxz"):
        plant_jccs.append((rva,nm,insn))

results=[]
def do_plant(name, patches):
    pe=bytearray(b828); s=pe_secs(pe)
    for rva,new,old in patches:
        o=rva2off(pe,s,rva)
        cur=bytes(pe[o:o+len(old)])
        if cur!=old:
            P(f"  {name}: skip bad @{rva:06x} got={cur.hex()} want={old.hex()}")
            return None
        pe[o:o+len(new)]=new
    out=cave/f"host_prelast_{name}.exe"; out.write_bytes(pe)
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
            if base_sha and sh==base_sha:
                P(f"  NOTE: lit sha==base ({base_sha})")
        res.append((src,tag,sh,n868,rtag,rcrc))
    results.append((name,sha,res))
    return sha

planted=False; plant_name=None

# Plant A prelast_immrdx: force a HIT je in post-zero that may gate arg-fill
# Prefer je_null_tok / je_tok0 / pz_je — force taken (jmp) to explore alternate fill
# OR nop to force fallthrough into fill body
priority=[0x568251,0x568273,0x568183,0x5681b5]
for want in priority:
    if planted: break
    for rva,nm,insn in plant_jccs:
        if rva!=want: continue
        raw=bytes(insn.bytes)
        if len(raw)==2:
            # nop je -> fallthrough into body that was skipped when condition true
            # For je X: if we nop, we fall through (don't jump) = take "condition false" path
            # For SoftCap we want the SUCCESS/fill path. je_null at 568251 jumps TO 5684f2 when null
            # — success is FALLTHROUGH (je not taken). So nop is wrong; already falling through if HIT means we reach the je with non-null.
            # If site HIT, we execute the je. Force JMP would skip fill. Force NOP keeps fallthrough always.
            # Better: if je jumps to FAIL/skip, nop it (always fill). If je jumps to SUCCESS, force jmp.
            # 568251 je 0x5684f2 — likely skip/fail path when null. On SoftCap HIT means we REACH je;
            # if token non-null, fallthrough fills. Nopping forces fill even if null — may AV.
            # 568183 je 0x56819d — je when NOT le0 (success continue). Force jmp = always continue.
            new=bytes([0xeb, raw[1]])  # force taken
            plant_name="prelast_immrdx"
            P(f"  -> plant {plant_name}: {insn.mnemonic}->jmp @{rva:06x} ({nm})")
            do_plant(plant_name, [(rva, new, raw)])
            planted=True
            break

# Plant B: if no jcc, force store_498 path — can't invent ptr; try call_201f36 always via nop prior je
if not planted and 0x5681f9 in hit_set:
    # look at je before call_201f36
    o=rva2off(b828,secs,0x5681b5)
    insn=next(md.disasm(bytes(b828[o:o+8]), 0x5681b5))
    raw=bytes(insn.bytes)
    if insn.mnemonic.startswith("j") and len(raw)==2:
        new=bytes([0xeb, raw[1]])
        plant_name="prelast_immrdx"
        P(f"  -> plant {plant_name}: force {insn.mnemonic}->jmp @5681b5 before @201f36")
        do_plant(plant_name, [(0x5681b5, new, raw)])
        planted=True

# Plant C semantic rbp260_rdx2: at HIT @578238, the rdx into call-mk is [498].
# Capless @576583 stores rdx->[498]. Dig what rdx is there; plant can't easily force USER imm.
# Alternative: nop @568251 je (force enter token loop even if null) 
if not planted and 0x568251 in hit_set:
    o=rva2off(b828,secs,0x568251)
    insn=next(md.disasm(bytes(b828[o:o+8]), 0x568251))
    raw=bytes(insn.bytes)
    if len(raw)==2:
        new=b"\x90"*2  # nop: never skip to 5684f2
        plant_name="prelast_immrdx"
        P(f"  -> plant {plant_name}: nop je_null_tok @568251 (force enter)")
        do_plant(plant_name, [(0x568251, new, raw)])
        planted=True

# Plant D: force @568183 continue (already success path if HIT) — try @56888d emit call if HIT
if not planted:
    for rva,nm in [(0x56888d,"call_2a62c9"),(0x5688d2,"call_2a5ca8")]:
        if rva in hit_set:
            P(f"  emit-ish HIT @{rva:06x} {nm} but no jcc plant; leave as DIG nail")
            break
    # last resort: jmp->force at pz_je_le0 if present in binary even if AV
    o=rva2off(b828,secs,0x568183)
    insn=next(md.disasm(bytes(b828[o:o+8]), 0x568183))
    raw=bytes(insn.bytes)
    if insn.mnemonic.startswith("j") and len(raw)==2:
        new=bytes([0xeb, raw[1]])
        plant_name="prelast_immrdx"
        P(f"  -> fallback plant {plant_name}: {insn.mnemonic}->jmp @568183")
        do_plant(plant_name, [(0x568183, new, raw)])
        planted=True

P(f"\nPLANTED={planted} name={plant_name}")
P(f"RESULTS: {results}")
P(f"elapsed={time.time()-T0:.1f}s DONE")
clean()
P("EXIT:0")
