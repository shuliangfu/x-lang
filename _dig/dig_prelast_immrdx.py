"""DIG SoftCap prelast_immrdx: pre_last@567a30 second half / [rbp+0x260]
USER imm->rdx emit under base_828; keep call-mk.
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
    out=cave/f"_dig_plimm_{label}.exe"; out.write_bytes(pe2); return out

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
    for pat in ["_dig_plimm_*.exe","_tmp__dig_plimm_*","host_b828*.exe","host_prelast*.exe",
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
    has_sub20 = bytes.fromhex("4883ec20") in win or bytes.fromhex("4883ec20") in b[i:i+0x30]
    has_call = b"\xe8" in win
    # true imm->rdx: mov eax/edx,0xa then mov rdx,rax before call (not cmp expect after)
    true_immrdx = False
    # look for b8 0a / ba 0a before first E8 in window, and 4889c2 before that E8
    e8pos = win.find(b"\xe8")
    if e8pos>0:
        pre=win[:e8pos]
        true_immrdx = (bytes.fromhex("4889c2") in pre) and (
            bytes.fromhex("b80a000000") in pre or bytes.fromhex("ba0a000000") in pre
            or bytes.fromhex("b80a000000") in b[max(0,i-0x20):i+e8pos])
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

b828_ok=None; base_sha=None
for attempt in range(4):
    tag,sh,b,n68,n1b8,n868,outp=run(host,"p_ret_lit.x",timeout=8)
    P(f"b828 lit try{attempt} {tag} sha={sh} n868={n868}")
    if tag=="OK" and n868>=1:
        ok_immrdx, ok_cmk, _=find_sret(b,"b828")
        rtag,rcrc=run_bin(outp,timeout=5) if outp else ("-",-1)
        P(f"  run={rtag}/{rcrc} immrdx={ok_immrdx} callmk={ok_cmk}")
        b828_ok=b; base_sha=sh
        break
    time.sleep(0.4)

text_va=text_ro=text_sz=None
for n,(va,vs,ro,rs) in secs.items():
    if n==b'.text':
        text_va,text_ro,text_sz=va,ro,max(vs,rs); break

# --- DIG1: full pre_last@567a30 body (find end via ret) ---
P("\n=== pre_last@567a30 disasm (to first ret / 0x400) ===")
o=rva2off(b828,secs,0x567a30)
body=bytes(b828[o:o+0x400])
pl_end=None
for insn in md.disasm(body, 0x567a30):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    if insn.mnemonic=="ret":
        pl_end=insn.address; break
    if insn.address>=0x567a30+0x3f0: break
P(f"  pre_last_end={hex(pl_end) if pl_end else '?'}")

# Second half: from mid to end (or +0x200..+0x400)
mid = 0x567a30 + ((pl_end-0x567a30)//2 if pl_end else 0x100)
P(f"\n=== pre_last SECOND HALF from @{mid:06x} ===")
o2=rva2off(b828,secs,mid)
half=bytes(b828[o2:o2+0x280])
for insn in md.disasm(half, mid):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    if pl_end and insn.address>=pl_end: break
    if insn.address>=mid+0x270: break

# E8 in whole pre_last (to end+0x20)
scan_len = (pl_end-0x567a30+0x40) if pl_end else 0x400
body=bytes(b828[o:o+scan_len])
e8s=[]
for i in range(0,len(body)-5):
    if body[i]==0xe8:
        rel=struct.unpack_from("<i",body,i+1)[0]
        src=0x567a30+i; dst=src+5+rel
        # filter bogus (dst in .text roughly)
        if text_va <= dst < text_va+text_sz:
            e8s.append((src,dst))
P(f"\n=== pre_last E8 (valid .text) n={len(e8s)} ===")
for s,d in e8s[:30]:
    P(f"  @{s:06x} -> @{d:06x}")

# --- DIG2: [rbp+0x260] corridor uses ---
P("\n=== Capless [rbp+0x260] refs near @578000..@578400 ===")
o=rva2off(b828,secs,0x578000)
chunk=bytes(b828[o:o+0x400])
# disp32 = 0x260: 85/8d/8b ... 60 02 00 00  OR c785/8985
refs260=[]
for i in range(0,len(chunk)-7):
    # look for 60 02 00 00 with rbp-relative opcode nearby
    if chunk[i:i+4]==bytes.fromhex("60020000"):
        # back up to find insn start (capstone from i-3..i)
        for back in range(1,8):
            try:
                insns=list(md.disasm(chunk[i-back:i+8], 0x578000+i-back))
                if insns and "0x260" in insns[0].op_str:
                    refs260.append((insns[0].address, f"{insns[0].mnemonic} {insns[0].op_str}", bytes(insns[0].bytes).hex()))
                    break
            except Exception:
                pass
# also known zero site
for insn in md.disasm(bytes(b828[rva2off(b828,secs,0x578060):rva2off(b828,secs,0x578060)+0x40]), 0x578060):
    if "0x260" in insn.op_str or "0x4a0" in insn.op_str:
        refs260.append((insn.address, f"{insn.mnemonic} {insn.op_str}", bytes(insn.bytes).hex()))
    if insn.address>=0x5780a0: break
# unique
seen=set(); uniq260=[]
for a,d,h in refs260:
    if a not in seen:
        seen.add(a); uniq260.append((a,d,h))
P(f"  refs260 n={len(uniq260)}")
for a,d,h in uniq260[:20]:
    P(f"  @{a:06x}: {d} [{h}]")

# corridor decode @578071..@578280
P("\n=== corridor @578071..@578280 ===")
o=rva2off(b828,secs,0x578071)
for insn in md.disasm(bytes(b828[o:o+0x220]), 0x578071):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    if insn.address>=0x578280: break

# --- DIG3: INT3 second-half + 260-related + key gates ---
P("\n=== INT3 pre_last 2nd half / 260 / emit-ish ===")
cands=[]
# second half sites: every ~0x20 from mid, plus control-flow sites
if pl_end:
    for rva in range(mid, pl_end, 0x18):
        cands.append((rva, f"pl2_{rva:x}"))
    # also last 0x40 of function at denser spacing for ret path
    for rva in range(max(mid, pl_end-0x60), pl_end, 0x10):
        cands.append((rva, f"plret_{rva:x}"))
# 260 refs
for a,d,_ in uniq260[:8]:
    cands.append((a, f"r260_{a:x}"))
# known HIT anchors + second-half control
cands += [
    (0x567aea,"pl_je_stk"),
    (0x578071,"zero_260"),
    (0x5781f4,"lea_buf"),
    (0x578238,"mov_rdx_498"),
    (0x578250,"lea_buf_cmk"),
]
# E8 call sites in pre_last (second half preferred)
for s,d in e8s:
    if s >= mid:
        cands.append((s, f"pl_e8_{d:x}"))
# unique keep order
seen=set(); uniq=[]
for r,n in cands:
    if r not in seen and 0x1000 < r < 0x700000:
        seen.add(r); uniq.append((r,n))

hits=[]
for rva,nm in uniq:
    if time.time()-T0>BUDGET-38: break
    t1=time.time()
    tag,_,_,_,_,_,_=run(plant_int3(b828,[rva],f"i{rva:x}"),timeout=5)
    mark=" HIT" if tag=="INT3" else f" {tag}"
    if tag=="INT3": hits.append((rva,nm))
    P(f"  @{rva:06x} {nm:22s} ->{mark} ({time.time()-t1:.1f}s)")
P(f"HITs: {[(hex(r),n) for r,n in hits]}")

# Decode HIT sites in second half for plant candidates
P("\n=== decode HIT 2nd-half / plant cands ===")
hit_set={r for r,_ in hits}
plant_sites=[]
for rva,nm in hits:
    if rva < mid and "260" not in nm and rva not in (0x567aea,0x578071,0x5781f4,0x578238,0x578250):
        continue
    o=rva2off(b828,secs,rva)
    insns=list(md.disasm(bytes(b828[o:o+24]), rva))
    if not insns: continue
    insn=insns[0]
    P(f"  @{rva:06x} {nm}: {insn.mnemonic} {insn.op_str} [{bytes(insn.bytes).hex()}]")
    plant_sites.append((rva,nm,insn))

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
                P(f"  NOTE: lit sha==base ({base_sha}) — no USER change")
        res.append((src,tag,sh,n868,rtag,rcrc))
    results.append((name,sha,res))
    return sha

# --- Plant strategy (ONE semantic) ---
# Prefer: force a je/jz in pre_last 2nd half that may skip arg-imm emit -> jmp (take emit)
# Or: at lea_buf / mov_rdx_498 force a known Isol-native path
# Or: rbp260 — if zero_260 HIT, skip zeroing so residual drives emit (risky)
planted=False
plant_name=None

# A) Find je/jz/jne in HIT second-half sites; force jmp (always take) or nop (fallthrough)
for rva,nm,insn in plant_sites:
    if planted: break
    if insn.mnemonic in ("je","jz","jne","jnz","jg","jle","jl","jge") and len(insn.bytes) in (2,6):
        raw=bytes(insn.bytes)
        if len(raw)==2:
            # short jcc -> jmp short (EB rel8) to SAME target (force taken)
            new=bytes([0xeb, raw[1]])
            plant_name=f"prelast_immrdx"
            P(f"  -> plant {plant_name}: {insn.mnemonic}->jmp @{rva:06x} ({raw.hex()}->{new.hex()})")
            do_plant(plant_name, [(rva, new, raw)])
            planted=True
            break
        elif len(raw)==6 and raw[0]==0x0f:
            # near jcc 0F 8x -> NOP sled then keep? better: change to near jmp E9
            # 0F 8x rel32 -> E9 rel32 + NOP (same rel)
            new=bytes([0xe9])+raw[2:]+b"\x90"
            plant_name=f"prelast_immrdx"
            P(f"  -> plant {plant_name}: near {insn.mnemonic}->jmp @{rva:06x}")
            do_plant(plant_name, [(rva, new, raw)])
            planted=True
            break

# B) If no jcc plant: at @578238 mov rdx,[rbp+0x498] — if this is arg0 ptr, force rdx=imm path differently
#    Alternative semantic rbp260_rdx: nop the zero of [rbp+0x260] so buffer not cleared
if not planted:
    # try lea_buf @5781f4 or mov rdx @578238 if in hits or prior known
    for rva, label in [(0x578238,"rbp260_rdx"), (0x5781f4,"rbp260_rdx")]:
        if planted: break
        o=rva2off(b828,secs,rva)
        insn=next(md.disasm(bytes(b828[o:o+16]), rva))
        raw=bytes(insn.bytes)
        P(f"  cand @{rva:06x}: {insn.mnemonic} {insn.op_str} [{raw.hex()}]")
        # For mov rdx,[rbp+0x498]: if it's loading arg0 value slot — can't invent imm easily.
        # For lea: skip.
    # Force pl_je_stk always-fallthrough (nop je) — prior HIT; may change pre_last ret path
    o=rva2off(b828,secs,0x567aea)
    insn=next(md.disasm(bytes(b828[o:o+8]), 0x567aea))
    raw=bytes(insn.bytes)
    if insn.mnemonic in ("je","jz","jne","jnz") and len(raw)==2 and not planted:
        # nop the conditional so fallthrough (opposite of force-jmp)
        new=b"\x90"*len(raw)
        plant_name="prelast_immrdx"
        P(f"  -> plant {plant_name}: nop {insn.mnemonic} @567aea ({raw.hex()})")
        do_plant(plant_name, [(0x567aea, new, raw)])
        planted=True

# C) Fallback rbp260_rdx: nop zero of buffer @578071 (keep residual) — single semantic alt
if not planted:
    o=rva2off(b828,secs,0x578071)
    # find the zeroing insn(s) — may be a call or mov/rep stos
    insn=next(md.disasm(bytes(b828[o:o+16]), 0x578071))
    raw=bytes(insn.bytes)
    P(f"  zero_260 @{0x578071:06x}: {insn.mnemonic} {insn.op_str} [{raw.hex()}]")
    if len(raw)>=1:
        new=b"\x90"*len(raw)
        plant_name="rbp260_rdx"
        P(f"  -> plant {plant_name}: nop zero_260")
        do_plant(plant_name, [(0x578071, new, raw)])
        planted=True

P(f"\nPLANTED={planted} name={plant_name}")
P(f"RESULTS: {results}")
P(f"elapsed={time.time()-T0:.1f}s DONE")
clean()
P("EXIT:0")
