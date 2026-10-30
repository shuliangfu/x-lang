"""DIG SoftCap base_828 + Isol-native CallExpr call-mk (b828_cmk).
Rebuild base_828 @24b9c1; under SoftCap-shaped frame, plant force Capless
SoftCap early-claim miss so CallExpr can emit imm->rdx+call mk.
Base alt_frame2 9378df517f96. Budget<=85s.
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

def P(*a):
    print(*a, flush=True)

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
    """patches: list of (rva, bytes)"""
    pe2=bytearray(baseb); s=pe_secs(pe2)
    for r,bs in patches:
        o=rva2off(pe2,s,r)
        pe2[o:o+len(bs)]=bs
    out=cave/f"_dig_host_cmk_{label}.exe"; out.write_bytes(pe2); return out

def plant_int3(baseb,rvas,label):
    return plant_bytes(baseb,[(r,bytes([0xCC])) for r in rvas],label)

def run(h,src="p_ret_lit.x",timeout=5):
    out=cave/f"_tmp_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    try:
        r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout)
        crc=r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT","-",b"",0,0,0,None
    tag={0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc,f"crc={crc:#x}")
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
    for pat in ["_dig_host_cmk_*.exe","_tmp__dig_host_cmk_*","xlang_isol1060_base_828.exe",
                "xlang_isol1060_b828_cmk*.exe","_tmp_xlang_isol1060_base_828_*","_tmp_xlang_isol1060_b828_*"]:
        for p in cave.glob(pat):
            try: p.unlink()
            except: pass

def dump_user(b, label, lim=0x80):
    """Find main-ish: lea rcx after sub rsp, or first .text-ish USER region."""
    if not b or len(b)<0x200: P(f"  {label}: no bin"); return
    # PE USER .text typically around entry; look for lea rcx,[rbp-..] then nearby
    # SoftCap USER pattern: 488d45 / 4889c1 (lea+mov rcx)
    sig=bytes.fromhex("4889c1")  # mov rcx,rax after lea
    hits=[]
    start=0
    while True:
        i=b.find(sig, start)
        if i<0: break
        hits.append(i); start=i+1
        if len(hits)>8: break
    P(f"  {label}: mov rcx,rax hits offs={[hex(h) for h in hits[:6]]} n868={b.count(bytes.fromhex('4881ec68080000'))}")
    # also look for call-mk markers: ba0a000000 (mov edx,0xa) or b80a000000 (mov eax,0xa) + 4889c2
    for name,pat in [("mov_edx_a",bytes.fromhex("ba0a000000")),
                     ("mov_eax_a",bytes.fromhex("b80a000000")),
                     ("mov_rdx_rax",bytes.fromhex("4889c2")),
                     ("lea_rcx",bytes.fromhex("4889c1")),
                     ("mov_rax_mem",bytes.fromhex("488b00"))]:
        P(f"    {name} count={b.count(pat)}")
    # dump around first mov rcx,rax
    if hits:
        off=max(0,hits[0]-0x20)
        chunk=b[off:off+lim]
        P(f"  dump @{off:#x}:")
        for insn in md.disasm(chunk, off):
            P(f"    @{insn.address:04x}: {insn.mnemonic} {insn.op_str}")

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)
P("base alt_frame2 sha12=9378df517f96")

# --- rebuild base_828 ---
P("\n=== plant base_828 @24b9c1 ===")
o828=rva2off(base,secs,0x24b9c1)
orig828=bytes(base[o828:o828+6])
P(f"  orig @{0x24b9c1:06x}: {orig828.hex()}")
assert orig828==bytes.fromhex("8b85fc000000"), f"unexpected {orig828.hex()}"
b828=bytearray(base)
b828[o828:o828+6]=bytes.fromhex("b82808000090")  # mov eax,0x828; nop
out_b828=cave/"xlang_isol1060_base_828.exe"
out_b828.write_bytes(b828)
sha_b828=hashlib.sha256(bytes(b828)).hexdigest()
P(f"  plant base_828 sha12={sha_b828[:12]}")
for insn in md.disasm(bytes(b828[o828:o828+10]), 0x24b9c1):
    P(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# confirm base_828 SoftCap frame
P("\n=== base_828 SoftCap p_ret_lit compile ===")
tag,sh,b,n68,n1b8,n868,outp=run(out_b828,"p_ret_lit.x",timeout=8)
P(f"  lit {tag} sha={sh} n68={n68} n1b8={n1b8} n868={n868}")
dump_user(b, "base_828 lit USER")
if outp:
    rtag,rcrc=run_bin(outp,timeout=5)
    P(f"  run lit -> {rtag} exit={rcrc}")

# LIVE reference USER (if available)
live=cave/"lab_LIVE_pret.exe"
if live.exists():
    P("\n=== LIVE SoftCap p_ret_lit (ref) ===")
    tagL,shL,bL,n68L,n1b8L,n868L,outL=run(live,"p_ret_lit.x",timeout=8)
    P(f"  lit {tagL} sha={shL} n68={n68L} n1b8={n1b8L} n868={n868L}")
    dump_user(bL, "LIVE lit USER")

# --- INT3 under base_828: SoftCap claim / Capless EXIT / CallExpr ---
# Sites from prior DIG (SoftCap early-claim / Capless continue / call-mk entry)
sites=[
    (0x576692,"calt_softcap"),      # Capless-alt -> SoftCap-site
    (0x5766b9,"calt_site_ok"),      # site>0 -> eax=0; jmp EXIT
    (0x2be519,"site_entry"),        # SoftCap-site entry
    (0x2be6b0,"site_null_claim"),   # null -> eax=1
    (0x2be734,"site_kind_gate"),    # kind gate eax=1
    (0x2be781,"site_nest_gate"),    # nest kind eax=1
    (0x577c37,"cap_kind3"),         # Capless CALL kind3
    (0x578273,"cap_call_mk_gate"),  # Capless -> call-mk
    (0x57bb30,"callmk_entry"),      # call-mk entry
    (0x5752bc,"callmk_body"),       # call-mk body
]
P("\n=== INT3 under base_828 lit (timeout=5s/site) ===")
hits=[]
for rva,name in sites:
    if time.time()-T0>BUDGET-40: P("BUDGET stop INT3"); break
    t1=time.time()
    tag,sh,b,n68,n1b8,n868,_=run(plant_int3(b828,[rva],name),timeout=5)
    mark=" HIT" if tag=="INT3" else (f" **{tag}**" if tag in("AV","GS","TIMEOUT") else "")
    if tag=="INT3": hits.append((rva,name))
    P(f"  @{rva:06x} {name:18s} -> {tag}{mark} n868={n868} ({time.time()-t1:.1f}s)")
P(f"HITs: {[(hex(r),n) for r,n in hits]}")

# --- Plants: base_828 + Isol-native call-mk force ---
# P1 b828_cmk_miss: SoftCap-site kind-gate @2be734 mov eax,1 -> mov eax,0
#    (force miss so Capless continues; prior alone AV — retest UNDER base_828)
# P2 b828_cmk_exit: Capless @5766b9 early EXIT after site>0 — nop the jmp EXIT
#    so Capless falls into arg/call path
# P3 b828_cmk_both: base_828 + miss + skip EXIT

def disasm_at(pe,rva,n=12):
    o=rva2off(pe,secs,rva)
    for insn in md.disasm(bytes(pe[o:o+n]), rva):
        P(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

plants=[]

# Inspect @2be734 and @5766b9 originals
P("\n=== static SoftCap claim / Capless EXIT ===")
for rva,n in [(0x2be734,"site_kind_gate"),(0x2be781,"site_nest_gate"),
              (0x2be6b0,"site_null_claim"),(0x5766b9,"calt_site_ok")]:
    o=rva2off(b828,secs,rva)
    chunk=bytes(b828[o:o+16])
    P(f"  @{rva:06x} {n}: {chunk.hex()}")
    disasm_at(b828,rva,16)

# Expect @2be734: mov eax,1 ; jmp ...  = b801000000 e9...
# Expect @5766b9: after test; mov eax,0; jmp EXIT

def try_plant(name, patches):
    if time.time()-T0>BUDGET-15:
        P(f"  BUDGET skip {name}"); return
    pe=bytearray(b828)
    s=pe_secs(pe)
    ok=True
    for rva,bs,expect_prefix in patches:
        o=rva2off(pe,s,rva)
        cur=bytes(pe[o:o+len(expect_prefix)])
        if cur!=expect_prefix:
            P(f"  {name}: UNEXPECTED @{rva:06x} got {cur.hex()} want {expect_prefix.hex()} — skip")
            ok=False; break
        pe[o:o+len(bs)]=bs
    if not ok: return
    outp=cave/f"xlang_isol1060_{name}.exe"
    outp.write_bytes(pe)
    sha=hashlib.sha256(bytes(pe)).hexdigest()
    P(f"\n=== plant {name} sha12={sha[:12]} ===")
    for rva,bs,_ in patches:
        P(f"  patched @{rva:06x}:")
        disasm_at(pe,rva,max(12,len(bs)+4))
    results=[]
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
        if time.time()-T0>BUDGET-5: break
        t1=time.time()
        tag,sh,b,n68,n1b8,n868,outbin=run(outp,src,timeout=8)
        rtag="-"; rcrc=-1
        if tag=="OK" and outbin:
            rtag,rcrc=run_bin(outbin,timeout=5)
        P(f"  {src:16s} compile={tag:8s} sha={sh} n68={n68} n1b8={n1b8} n868={n868} run={rtag} ({time.time()-t1:.1f}s)")
        if tag=="OK" and b:
            dump_user(b, f"{name}/{src}", lim=0x60)
        results.append((src,tag,sh,n868,rtag,rcrc))
    plants.append((name,sha[:12],results))
    return results

# P1: @2be734 mov eax,1 -> mov eax,0  (5 bytes b8 01 00 00 00 -> b8 00 00 00 00)
# First verify exact bytes
o=rva2off(b828,secs,0x2be734)
gate_bytes=bytes(b828[o:o+5])
P(f"\n  gate @2be734 first5={gate_bytes.hex()}")

o2=rva2off(b828,secs,0x5766b9)
exit_bytes=bytes(b828[o2:o+16-o+o2] if False else b828[o2:o2+16])
P(f"  exit @5766b9 first16={exit_bytes.hex()}")

# Common pattern: b801000000 = mov eax,1
if gate_bytes==bytes.fromhex("b801000000"):
    try_plant("b828_cmk", [
        (0x2be734, bytes.fromhex("b800000000"), bytes.fromhex("b801000000")),
    ])
elif gate_bytes[0:1]==bytes([0xb8]):
    # mov eax,imm — force imm=0
    try_plant("b828_cmk", [
        (0x2be734, bytes([0xb8,0,0,0,0]), gate_bytes),
    ])
else:
    P(f"  gate pattern unexpected; try Capless EXIT plant")

# Also try: if Capless @5766b9 is `mov eax,0; jmp rel` after test — change to fallthrough
# Look for je/jne to EXIT then mov eax,0
# From prior: Capless-alt @5766b9: site>0 -> mov eax,0; jmp EXIT
# Disasm more carefully
P("\n=== Capless @5766a0..@5766d0 disasm ===")
disasm_at(b828, 0x5766a0, 0x40)

# P2 alternative: if P1 not enough, also neutralize @2be781 nest gate
o781=rva2off(b828,secs,0x2be781)
g781=bytes(b828[o781:o781+5])
P(f"  nest @2be781 first5={g781.hex()}")
if g781==bytes.fromhex("b801000000") or (g781[0]==0xb8 and g781[1]==1):
    try_plant("b828_cmk2", [
        (0x2be734, bytes.fromhex("b800000000"), bytes.fromhex("b801000000") if gate_bytes==bytes.fromhex("b801000000") else gate_bytes),
        (0x2be781, bytes.fromhex("b800000000"), g781),
    ])

# P3: Capless EXIT bypass — if pattern is `test/cmp; jcc; mov eax,0; jmp EXIT`
# From dig: @5766b9 mov eax,0; jmp EXIT when site>0
# Force the jcc that leads to site-ok success to fall through instead.
# Need to see preceding insn
P("\n=== Capless @576680.. disasm (pre site_ok) ===")
disasm_at(b828, 0x576680, 0x50)

P(f"\n=== PLANT SUMMARY ===")
for name,sha,res in plants:
    P(f"  {name} sha12={sha} -> {res}")

P("\n=== baseline alt_frame2 lit ===")
tag,sh,b,n68,n1b8,n868,_=run(cave/"xlang_isol1060_alt_frame2.exe","p_ret_lit.x",timeout=8)
P(f"  lit {tag} sha={sh} n68={n68} n1b8={n1b8} n868={n868}")

P(f"\nelapsed={time.time()-T0:.1f}s DONE")
# cleanup probe hosts; keep plant hosts briefly then clean all dig hosts
for p in list(cave.glob("_dig_host_cmk_*.exe"))+list(cave.glob("_tmp__dig_host_cmk_*")):
    try: p.unlink()
    except: pass
# remove plant hosts per prior style (probe-only keep notes)
for p in list(cave.glob("xlang_isol1060_b828_cmk*.exe"))+list(cave.glob("xlang_isol1060_base_828.exe")):
    try: p.unlink()
    except: pass
for p in list(cave.glob("_tmp_xlang_isol1060_b828_*"))+list(cave.glob("_tmp_xlang_isol1060_base_828_*")):
    try: p.unlink()
    except: pass
P("EXIT:0")
