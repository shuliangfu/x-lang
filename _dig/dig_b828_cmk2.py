"""DIG SoftCap b828_cmk: under base_828, Capless call-mk HIT but USER exit1.
Dump USER main around sub rsp 0x868; INT3 call-mk write sites; plant force
imm->rdx+E8 if Isol-native early-out found.
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

def plant_int3(baseb,rvas,label):
    pe2=bytearray(baseb); s=pe_secs(pe2)
    for r in rvas: pe2[rva2off(pe2,s,r)]=0xCC
    out=cave/f"_dig_host_cmk2_{label}.exe"; out.write_bytes(pe2); return out

def plant_bytes(baseb, patches, label):
    pe2=bytearray(baseb); s=pe_secs(pe2)
    for r,bs in patches:
        o=rva2off(pe2,s,r); pe2[o:o+len(bs)]=bs
    out=cave/f"xlang_isol1060_{label}.exe"; out.write_bytes(pe2); return out

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
    for pat in ["_dig_host_cmk2_*.exe","_tmp__dig_host_cmk2_*",
                "xlang_isol1060_base_828.exe","xlang_isol1060_b828_cmk*.exe",
                "xlang_isol1060_callmk_b828*.exe",
                "_tmp_xlang_isol1060_base_828_*","_tmp_xlang_isol1060_b828_*",
                "_tmp_xlang_isol1060_callmk_*"]:
        for p in cave.glob(pat):
            try: p.unlink()
            except: pass

def dump_main(b, label):
    if not b: P(f"  {label}: no bin"); return None
    # find sub rsp,0x868 or 0x878 or 0x68
    pats=[("868",bytes.fromhex("4881ec68080000")),
          ("878",bytes.fromhex("4881ec78080000")),
          ("68",bytes.fromhex("4881ec68000000")),
          ("1b8",bytes.fromhex("4881ecb8010000")),
          ("20",bytes.fromhex("4883ec20"))]
    found=[]
    for name,pat in pats:
        start=0
        while True:
            i=b.find(pat,start)
            if i<0: break
            found.append((name,i)); start=i+1
    P(f"  {label}: frames={[(n,hex(i)) for n,i in found[:10]]}")
    # Prefer 868/878 main; else largest frame
    prefer=[x for x in found if x[0] in("868","878")]
    if not prefer: prefer=found
    if not prefer: return None
    # dump from first prefer frame for 0xa0 bytes
    name,off=prefer[0]
    # also search backward for function start (push rbp / mov rbp,rsp)
    start=max(0,off-0x10)
    chunk=b[start:off+0xc0]
    P(f"  dump main near {name} @{start:#x}:")
    for insn in md.disasm(chunk, start):
        P(f"    @{insn.address:04x}: {insn.mnemonic} {insn.op_str}")
    # markers
    for nm,pat in [("mov_edx_a",bytes.fromhex("ba0a000000")),
                   ("mov_eax_a",bytes.fromhex("b80a000000")),
                   ("mov_rdx_rax",bytes.fromhex("4889c2")),
                   ("call_rel",bytes([0xE8])),
                   ("lea_rax_rbp",bytes.fromhex("488d45")),
                   ("mov_rax_mem",bytes.fromhex("488b00"))]:
        # count only in main window
        win=b[off:off+0x200]
        P(f"    win[{name}+0x200] {nm}={win.count(pat)}")
    return off

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)
P("base alt_frame2 sha12=9378df517f96")

# rebuild base_828
o828=rva2off(base,secs,0x24b9c1)
assert bytes(base[o828:o828+6])==bytes.fromhex("8b85fc000000")
b828=bytearray(base)
b828[o828:o828+6]=bytes.fromhex("b82808000090")
out_b828=cave/"xlang_isol1060_base_828.exe"
out_b828.write_bytes(b828)
P(f"plant base_828 sha12={hashlib.sha256(bytes(b828)).hexdigest()[:12]}")

# compile lit (+retry once if AV flake)
P("\n=== base_828 lit USER main ===")
tag,sh,b,n68,n1b8,n868,outp=run(out_b828,"p_ret_lit.x",timeout=8)
if tag!="OK":
    P(f"  retry after {tag}")
    time.sleep(0.3)
    tag,sh,b,n68,n1b8,n868,outp=run(out_b828,"p_ret_lit.x",timeout=8)
P(f"  lit {tag} sha={sh} n68={n68} n1b8={n1b8} n868={n868}")
dump_main(b,"base_828")
if outp:
    rtag,rcrc=run_bin(outp,timeout=5)
    P(f"  run -> {rtag} {rcrc}")

# LIVE main
live=cave/"lab_LIVE_pret.exe"
P("\n=== LIVE lit USER main ===")
tagL,shL,bL,_,_,n868L,outL=run(live,"p_ret_lit.x",timeout=8)
P(f"  lit {tagL} sha={shL} n868={n868L}")
dump_main(bL,"LIVE")

# Disasm call-mk entry @57bb30 and body start; find E8 to @5752bc
P("\n=== static call-mk @57bb00.. ===")
o=rva2off(b828,secs,0x57bb00)
for insn in md.disasm(bytes(b828[o:o+0x80]), 0x57bb00):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

P("\n=== static call-mk body @5752a0.. ===")
o=rva2off(b828,secs,0x5752a0)
for insn in md.disasm(bytes(b828[o:o+0x100]), 0x5752a0):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Prior DIG AV sites in call-mk: @5754ed @575645 @575648 @575fa3 @5aaf18
# Also Capless @578273 call @57b98c
P("\n=== INT3 call-mk under base_828 (timeout=5) ===")
sites=[
    (0x57bb30,"cmk_call_5752bc"),
    (0x57bb35,"cmk_after_call"),
    (0x5752bc,"cmk_body"),
    (0x5754ed,"cmk_5754ed"),
    (0x575645,"cmk_575645"),
    (0x575648,"cmk_575648"),
    (0x575fa3,"cmk_575fa3"),
    (0x5aaf18,"cmk_5aaf18"),
    (0x578273,"cap_e8_57b98c"),
    (0x57b98c,"fn_57b98c"),
    # Capless continue after SoftCap miss @5766c3
    (0x5766c3,"calt_continue"),
    (0x5770da,"calt_argloop"),
    (0x577681,"cap_join"),
    (0x577c37,"cap_kind3"),
]
hits=[]
for rva,name in sites:
    if time.time()-T0>BUDGET-35: P("BUDGET stop INT3"); break
    t1=time.time()
    tag,sh,b,n68,n1b8,n868,_=run(plant_int3(b828,[rva],name),timeout=5)
    mark=" HIT" if tag=="INT3" else (f" **{tag}**" if tag in("AV","GS","TIMEOUT") else "")
    if tag=="INT3": hits.append((rva,name))
    P(f"  @{rva:06x} {name:18s} -> {tag}{mark} n868={n868} ({time.time()-t1:.1f}s)")
P(f"HITs: {[(hex(r),n) for r,n in hits]}")

# Look for Capless CallExpr early-out that skips writing args after sret
# Scan Capless region for mov eax,0; jmp near call-mk path when kind=CallExpr
P("\n=== Capless CallExpr @577c00 disasm ===")
o=rva2off(b828,secs,0x577c00)
for insn in md.disasm(bytes(b828[o:o+0x80]), 0x577c00):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

P("\n=== Capless @578250.. (call-mk gate) ===")
o=rva2off(b828,secs,0x578250)
for insn in md.disasm(bytes(b828[o:o+0x50]), 0x578250):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Compare Isol vs LIVE USER for call-mk: search Isol USER for lea+[rbp-0x28] then next 40 bytes
def find_sret_lea(b, label):
    if not b: return
    # lea rax,[rbp-0x28] = 488d45d8 ; lea rax,[rbp-0x20]=488d45e0
    for imm,nm in [(0xd8,"-0x28"),(0xe0,"-0x20"),(0xd0,"-0x30"),(0xc8,"-0x38")]:
        pat=bytes([0x48,0x8d,0x45,imm])
        start=0; n=0
        while n<6:
            i=b.find(pat,start)
            if i<0: break
            P(f"  {label} lea rax,[rbp{nm}] @{i:#x}:")
            for insn in md.disasm(b[i:i+0x40], i):
                P(f"    @{insn.address:04x}: {insn.mnemonic} {insn.op_str}")
            start=i+1; n+=1

P("\n=== sret lea windows Isol base_828 ===")
# recompile fresh
tag,sh,b,n68,n1b8,n868,outp=run(out_b828,"p_ret_lit.x",timeout=8)
if tag!="OK":
    time.sleep(0.3)
    tag,sh,b,n68,n1b8,n868,outp=run(out_b828,"p_ret_lit.x",timeout=8)
P(f"  recompile {tag} sha={sh} n868={n868}")
find_sret_lea(b,"Isol")

P("\n=== sret lea windows LIVE ===")
find_sret_lea(bL,"LIVE")

# Plant candidates based on HITs:
# If call-mk body early-outs with eax=0 without writing — force continue
# Look at @575648 / @575fa3 for mov eax,0; jmp exit patterns from prior DIG

P("\n=== dig early-out in call-mk HIT sites ===")
for rva in [0x575645,0x575648,0x575fa3,0x5754ed,0x5aaf18]:
    o=rva2off(b828,secs,rva)
    chunk=bytes(b828[o:o+24])
    P(f"  @{rva:06x}: {chunk.hex()}")
    for insn in md.disasm(chunk, rva):
        P(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Plant callmk_b828: if we find mov eax,1 early success or jmp skip write — neutralize
# From prior: post @575648 eax==2 branch; @5aaf18
# Try: @5766b7 jle continue — already SoftCap miss path
# Try plant at Capless SoftCap success path: force @5766b7 jle to always continue
# (jle @5766c3 when site<=0; when site>0 takes EXIT). Already site=0.
# Real gap: call-mk runs but USER main has lea->rcx then field read.
# Search Isol enc helpers that write ba0a / 4889c2 near call-mk

P("\n=== scan Isol .text for mov edx,0xa near Capless ===")
# Capless region ~0x560000-0x590000
text_va=None; text_ro=None; text_sz=None
for n,(va,vs,ro,rs) in secs.items():
    if n==b'.text' or (va<=0x576000<va+vs):
        if n==b'.text' or text_va is None:
            text_va,text_ro,text_sz=va,ro,max(vs,rs)
P(f"  text va={text_va:#x} ro={text_ro:#x} sz={text_sz:#x}")
# search mov edx,0xa = ba 0a 00 00 00 in Capless-ish range
pat=bytes.fromhex("ba0a000000")
hits_ba=[]
region=bytes(b828[text_ro:text_ro+text_sz])
start=0
while len(hits_ba)<20:
    i=region.find(pat,start)
    if i<0: break
    rva=text_va+i
    if 0x500000<=rva<=0x5c0000:
        hits_ba.append(rva)
    start=i+1
P(f"  mov edx,0xa in Capless-ish: {[hex(r) for r in hits_ba]}")

# Also mov eax,0xa; ... look for b80a000000 followed within 16B by 4889c2
pat2=bytes.fromhex("b80a000000")
hits_combo=[]
start=0
while len(hits_combo)<30:
    i=region.find(pat2,start)
    if i<0: break
    rva=text_va+i
    if 0x200000<=rva<=0x5c0000:
        win=region[i:i+32]
        if bytes.fromhex("4889c2") in win or bytes.fromhex("89c2") in win:
            hits_combo.append(rva)
    start=i+1
P(f"  mov eax,0xa near mov rdx: {[hex(r) for r in hits_combo[:15]]}")

# Plant: Capless call-mk path — if @578273 is E8 to call-mk and returns success
# without USER write, look at what Capless does after call-mk returns
P("\n=== after call-mk return Capless @578273 ===")
o=rva2off(b828,secs,0x578260)
for insn in md.disasm(bytes(b828[o:o+0x40]), 0x578260):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Final plant attempt: force Capless @5766b7 jle to ALWAYS take continue (nop the jle->uncond jmp to continue)
# jle is 7e0a (if site<=0 -> continue). Change cmp+jle to jmp continue always:
# @5766b0: cmp dword[rbp+0x458],0 (7 bytes 83bd5804000000) ; jle +0x0a (7e0a)
# Force: jmp @5766c3 = eb 0a at @5766b7, and nop cmp? Or just ensure site miss.
# Already site miss. Skip.

# Better plant: at call-mk body, find where it skips writing call for SoftCap lit shape.
# INT3 HITs will tell us. Based on HITs, plant the early-out.

# Also try: plant @5752bc region - if there's `ret` / `mov eax,0; jmp` early for certain kinds
P("\n=== call-mk @5752bc detailed ===")
o=rva2off(b828,secs,0x5752bc)
for insn in md.disasm(bytes(b828[o:o+0x60]), 0x5752bc):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Plant callmk_b828: neutralize SoftCap-site nest @2be781 eax=1->0 (already tried)
# AND force Capless continue even if site>0: @5766b7 jle -> jmp (eb)
# Pattern at @5766b7: 7e0a -> eb0a
o_jle=rva2off(b828,secs,0x5766b7)
jle_b=bytes(b828[o_jle:o_jle+2])
P(f"\n  @5766b7 bytes={jle_b.hex()}")
if jle_b==bytes.fromhex("7e0a"):
    pe=bytearray(b828)
    pe[o_jle]=0xeb  # jmp short (always continue Capless)
    # also nest gate 0
    o781=rva2off(pe,secs,0x2be781)
    if bytes(pe[o781:o781+5])==bytes.fromhex("b801000000"):
        pe[o781:o781+5]=bytes.fromhex("b800000000")
    outp=cave/"xlang_isol1060_callmk_b828.exe"
    outp.write_bytes(pe)
    sha=hashlib.sha256(bytes(pe)).hexdigest()
    P(f"\n=== plant callmk_b828 sha12={sha[:12]} (force Capless continue) ===")
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
        if time.time()-T0>BUDGET-5: break
        t1=time.time()
        tag,sh,b,n68,n1b8,n868,outbin=run(outp,src,timeout=8)
        rtag="-"
        if tag=="OK" and outbin:
            rtag,_=run_bin(outbin,timeout=5)
        P(f"  {src:16s} {tag:8s} sha={sh} n868={n868} run={rtag} ({time.time()-t1:.1f}s)")
        if tag=="OK" and b:
            dump_main(b,f"callmk_b828/{src}")
            find_sret_lea(b,f"callmk_b828/{src}")

P(f"\nelapsed={time.time()-T0:.1f}s DONE")
for p in list(cave.glob("_dig_host_cmk2_*.exe"))+list(cave.glob("_tmp__dig_host_cmk2_*")):
    try: p.unlink()
    except: pass
for p in list(cave.glob("xlang_isol1060_base_828.exe"))+list(cave.glob("xlang_isol1060_b828_cmk*.exe"))+list(cave.glob("xlang_isol1060_callmk_b828*.exe")):
    try: p.unlink()
    except: pass
for p in list(cave.glob("_tmp_xlang_isol1060_base_828_*"))+list(cave.glob("_tmp_xlang_isol1060_b828_*"))+list(cave.glob("_tmp_xlang_isol1060_callmk_*")):
    try: p.unlink()
    except: pass
P("EXIT:0")
