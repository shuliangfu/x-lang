"""DIG SoftCap immrdx_578: Capless @578071..@578273 emit arg0 imm->rdx, keep call-mk.
Under base_828: call-mk writes only sub rsp+E8; nail Capless corridor / pre_last@567a30
arg0 gate; one plant immrdx_578 / arg0_rdx.
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
    out=cave/f"_dig_i578_{label}.exe"; out.write_bytes(pe2); return out

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
    for pat in ["_dig_i578_*.exe","_tmp__dig_i578_*","host_b828*.exe","host_immrdx*.exe",
                "_tmp_host_b828*","_tmp_host_immrdx*","_dig_himm*.exe","_tmp__dig_himm*"]:
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
    # call-mk shape: sub rsp,0x20 then E8 near sret
    has_sub20 = bytes.fromhex("4883ec20") in win or bytes.fromhex("4883ec20") in b[i:i+0x30]
    has_call = b"\xe8" in win
    P(f"  {label} has_imm10={has_imm} mov_rdx={has_rdx} sub20={has_sub20} call={has_call}")
    return has_imm and has_rdx, has_sub20 and has_call, has_imm

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)
o828=rva2off(base,secs,0x24b9c1)
b828=bytearray(base); b828[o828:o828+6]=bytes.fromhex("b82808000090")
host=cave/"host_b828.exe"; host.write_bytes(b828)
P(f"host_b828={hashlib.sha256(bytes(b828)).hexdigest()[:12]}")

b828_ok=None
for attempt in range(4):
    tag,sh,b,n68,n1b8,n868,outp=run(host,"p_ret_lit.x",timeout=8)
    P(f"b828 lit try{attempt} {tag} sha={sh} n868={n868}")
    if tag=="OK" and n868>=1:
        ok_immrdx, ok_cmk, _=find_sret(b,"b828")
        rtag,rcrc=run_bin(outp,timeout=5) if outp else ("-",-1)
        P(f"  run={rtag}/{rcrc} immrdx={ok_immrdx} callmk={ok_cmk}")
        b828_ok=b
        break
    time.sleep(0.4)

if b828_ok is None:
    P("WARN: bare host_b828 flaky AV; continue with plants (prior: plant host may OK)")

text_va=text_ro=text_sz=None
for n,(va,vs,ro,rs) in secs.items():
    if n==b'.text':
        text_va,text_ro,text_sz=va,ro,max(vs,rs); break
region=bytes(b828[text_ro:text_ro+text_sz])

# --- DIG: Capless corridor @578071..@578273 ---
P("\n=== Capless corridor @578071..@578273 ===")
o=rva2off(b828,secs,0x578071)
for insn in md.disasm(bytes(b828[o:o+0x210]), 0x578071):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    if insn.address>=0x578280: break

# pre_last@567a30: find internal emit / imm / enc calls (first 0x200 + scan E8)
P("\n=== pre_last@567a30 E8 targets (first 0x800) ===")
o=rva2off(b828,secs,0x567a30)
body=bytes(b828[o:o+0x800])
e8s=[]
for i in range(0,len(body)-5):
    if body[i]==0xe8:
        rel=struct.unpack_from("<i",body,i+1)[0]
        src=0x567a30+i; dst=src+5+rel
        e8s.append((src,dst))
P(f"  E8 n={len(e8s)} sample={[(hex(s),hex(d)) for s,d in e8s[:24]]}")
# classify: emit_raw @2a7f07, enc band, Capless
emit_hits=[(s,d) for s,d in e8s if d in (0x2a7f07,0x511018,0x5110f8,0x50f3e0,0x524944,0x521f10,0x521d78)]
P(f"  emit/enc E8: {[(hex(s),hex(d)) for s,d in emit_hits[:20]]}")

# Scan pre_last for byte-write imm patterns: mov eax, 0xb8 / 0xba / 0x48 then mov byte [rbx]
P("\n=== pre_last byte-imm templates (mov eax, imm8-ish) ===")
for i in range(0,len(body)-8):
    # B8 xx 00 00 00  (mov eax, imm32) where imm is opcode byte
    if body[i]==0xb8 and body[i+2:i+5]==b"\x00\x00\x00":
        imm=body[i+1]
        if imm in (0xb8,0xba,0x48,0x89,0xc2,0x8b,0x8d):
            rva=0x567a30+i
            P(f"  @{rva:06x}: mov eax, {imm:#x}")

# INT3 corridor + pre_last gates
P("\n=== INT3 corridor / pre_last / arg0 ===")
cands=[
    (0x578071,"zero_260"),
    (0x5781d1,"load_r9"),
    (0x5781df,"mov_edx_4a0"),
    (0x5781ec,"imm_100"),
    (0x5781f4,"lea_buf"),
    (0x578200,"mov_rcx_478"),
    (0x57820f,"call_567a30"),
    (0x578214,"store_3d4"),
    (0x578221,"jg_3d4"),
    (0x57822a,"load_r9_cmk"),
    (0x578231,"mov_r8d_4a0"),
    (0x578238,"mov_rdx_498"),
    (0x578250,"lea_buf_cmk"),
    (0x57825c,"mov_ecx_3e0"),
    (0x578266,"mov_ecx_4b0"),
    (0x578273,"call_cmk"),
    (0x567a30,"pre_last"),
    (0x567a8a,"pl_je_null"),
    (0x567abc,"pl_je_r8"),
    (0x567aea,"pl_je_stk"),
]
# also first few emit E8 sites inside pre_last
for s,d in emit_hits[:6]:
    cands.append((s, f"pl_e8_{d:x}"))
# unique
seen=set(); uniq=[]
for r,n in cands:
    if r not in seen:
        seen.add(r); uniq.append((r,n))

hits=[]
for rva,nm in uniq:
    if time.time()-T0>BUDGET-40: break
    t1=time.time()
    tag,_,_,_,_,_,_=run(plant_int3(b828,[rva],f"i{rva:x}"),timeout=5)
    mark=" HIT" if tag=="INT3" else f" {tag}"
    if tag=="INT3": hits.append((rva,nm))
    P(f"  @{rva:06x} {nm:20s} ->{mark} ({time.time()-t1:.1f}s)")
P(f"HITs: {[(hex(r),n) for r,n in hits]}")

# Dig: who writes [rbp+0x4a0] before corridor (Capless stores)
P("\n=== Capless stores to [rbp+0x4a0] near CallExpr ===")
o=rva2off(b828,secs,0x576000)
chunk=bytes(b828[o:o+0x2800])
# C7 85 a0 04 00 00 imm32  OR  89 85 a0 04 00 00
stores=[]
for i in range(0,len(chunk)-10):
    if chunk[i:i+6]==bytes.fromhex("c785a0040000"):
        imm=struct.unpack_from("<I",chunk,i+6)[0]
        stores.append((0x576000+i, f"mov dword[rbp+0x4a0],{imm:#x}", chunk[i:i+10]))
    if chunk[i:i+6]==bytes.fromhex("8985a0040000"):
        stores.append((0x576000+i, "mov [rbp+0x4a0],eax", chunk[i:i+6]))
P(f"  stores n={len(stores)}: {[(hex(a),d) for a,d,_ in stores[:16]]}")
for rva,desc,raw in stores[:8]:
    if time.time()-T0>BUDGET-28: break
    tag,_,_,_,_,_,_=run(plant_int3(b828,[rva],f"s4a0_{rva:x}"),timeout=5)
    P(f"  store @{rva:06x} {desc:40s} -> {tag}")

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

# --- Plant strategy (single semantic) ---
# Capless @5781df: mov edx, dword [rbp+0x4a0]  = 8B? decode actual
P("\n=== decode plant sites ===")
for rva in (0x5781df, 0x578231, 0x578221, 0x57820f, 0x578273):
    o=rva2off(b828,secs,rva)
    insns=list(md.disasm(bytes(b828[o:o+16]), rva))
    if insns:
        insn=insns[0]
        P(f"  @{rva:06x}: {insn.mnemonic} {insn.op_str} bytes={bytes(insn.bytes).hex()} len={len(insn.bytes)}")

planted=False
# Plant A immrdx_578: force edx=1 at @5781df (nargs into pre_last) IF site HIT
hit_set={r for r,_ in hits}
if 0x5781df in hit_set or 0x578200 in hit_set or 0x57820f in hit_set:
    o=rva2off(b828,secs,0x5781df)
    insn=next(md.disasm(bytes(b828[o:o+16]), 0x5781df))
    raw=bytes(insn.bytes)
    P(f"  plant cand @5781df len={len(raw)} {raw.hex()}")
    # mov edx,1 = ba 01 00 00 00; pad with nop to same length
    if len(raw)>=5 and not planted:
        new=bytes.fromhex("ba01000000") + b"\x90"*(len(raw)-5)
        P(f"  -> plant immrdx_578: mov edx,1 @5781df ({raw.hex()} -> {new.hex()})")
        do_plant("immrdx_578", [(0x5781df, new, raw)])
        planted=True

# Plant B arg0_rdx: also force r8d=1 at @578231 into call-mk (if A not planted or as alt)
if not planted:
    o=rva2off(b828,secs,0x578231)
    insn=next(md.disasm(bytes(b828[o:o+16]), 0x578231))
    raw=bytes(insn.bytes)
    if len(raw)>=6:
        # mov r8d,1 = 41 b8 01 00 00 00
        new=bytes.fromhex("41b801000000") + b"\x90"*(len(raw)-6)
        P(f"  -> plant arg0_rdx: mov r8d,1 @578231")
        do_plant("arg0_rdx", [(0x578231, new, raw)])
        planted=True

# If corridor mov_edx not HIT, try forcing jg @578221 always (pre_last ret>0 path) — only if HIT
if not planted and 0x578221 in hit_set:
    o=rva2off(b828,secs,0x578221)
    insn=next(md.disasm(bytes(b828[o:o+8]), 0x578221))
    raw=bytes(insn.bytes)
    if insn.mnemonic=="jg" and len(raw)==2:
        # jg -> jmp (force take success path)  EB rel8
        rel=raw[1]
        new=bytes([0xeb, rel])
        P(f"  -> plant immrdx_578: jg->jmp @578221")
        do_plant("immrdx_578", [(0x578221, new, raw)])
        planted=True

# Fallback: if @5781df not HIT but corridor reached (@578200 HIT), still try mov edx,1
# (prior: @578200 HIT even when call AV)
if not planted:
    o=rva2off(b828,secs,0x5781df)
    insn=next(md.disasm(bytes(b828[o:o+16]), 0x5781df))
    raw=bytes(insn.bytes)
    if len(raw)>=5:
        new=bytes.fromhex("ba01000000") + b"\x90"*(len(raw)-5)
        P(f"  -> fallback plant immrdx_578 mov edx,1 @5781df")
        do_plant("immrdx_578", [(0x5781df, new, raw)])
        planted=True

P(f"\nPLANTED={planted}")
P(f"RESULTS: {results}")
P(f"elapsed={time.time()-T0:.1f}s DONE")
clean()
P("EXIT:0")
