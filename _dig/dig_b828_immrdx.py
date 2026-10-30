"""DIG SoftCap b828_immrdx: under base_828 CallExpr has call mk, missing arg0 imm->rdx.
Find Isol-native Capless/call-mk gate that skips user-arg0 (rdx) under sret; one plant force imm->rdx.
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
    out=cave/f"_dig_himm_{label}.exe"; out.write_bytes(pe2); return out

def plant_int3(baseb,rvas,label):
    return plant_bytes(baseb,[(r,bytes([0xCC])) for r in rvas],label)

def run(h,src="p_ret_lit.x",timeout=5):
    out=cave/f"_tmp_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    for attempt in range(2):
        try:
            r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout)
            crc=r.returncode&0xFFFFFFFF
        except subprocess.TimeoutExpired:
            return "TIMEOUT","-",b"",0,0,0,None
        tag={0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc,f"crc={crc:#x}")
        if tag=="OK" or tag in("INT3","TIMEOUT") or attempt==1:
            break
        time.sleep(0.2)
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
    for pat in ["_dig_himm_*.exe","_tmp__dig_himm_*","host_b828*.exe","host_immrdx*.exe",
                "_tmp_host_b828*","_tmp_host_immrdx*"]:
        for p in cave.glob(pat):
            try: p.unlink()
            except: pass

def find_sret(b,label):
    if not b: return False
    # SoftCap/Isol sret: lea rax,[rbp-0x28] = 488d45d8
    pat=bytes([0x48,0x8d,0x45,0xd8])
    i=b.find(pat)
    if i<0:
        # also try -0x38 etc
        for off in (0xd8,0xe0,0xd0,0xc8):
            pat=bytes([0x48,0x8d,0x45,off]); i=b.find(pat)
            if i>=0: break
    if i<0: P(f"  {label}: no sret lea"); return False
    win=b[i:i+0x40]
    P(f"  {label} sret @{i:#x}:")
    for insn in md.disasm(win, i):
        P(f"    @{insn.address:04x}: {insn.mnemonic} {insn.op_str}")
    has_rdx = (bytes.fromhex("4889c2") in win) or (bytes.fromhex("4889d0") in win)
    has_imm = (bytes.fromhex("b80a000000") in win) or (bytes.fromhex("ba0a000000") in win) or (bytes.fromhex("b80a000000") in b[i:i+0x60])
    has_call = b"\xe8" in win
    P(f"  {label} has_imm10={has_imm} mov_rdx={has_rdx} call_near={has_call}")
    return has_imm and has_rdx

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)
o828=rva2off(base,secs,0x24b9c1)
# base_828: mov eax,0x828; nop  at frame size load
assert bytes(base[o828:o828+6])  # just touch
b828=bytearray(base); b828[o828:o828+6]=bytes.fromhex("b82808000090")
host=cave/"host_b828.exe"; host.write_bytes(b828)
P(f"host_b828={hashlib.sha256(bytes(b828)).hexdigest()[:12]}")

tag,sh,b,n68,n1b8,n868,outp=run(host,"p_ret_lit.x",timeout=8)
P(f"b828 lit {tag} sha={sh} n68={n68} n1b8={n1b8} n868={n868}")
find_sret(b,"b828")
rtag="-"; rcrc=-1
if tag=="OK" and outp:
    rtag,rcrc=run_bin(outp,timeout=5)
P(f"b828 lit run={rtag}/{rcrc}")

# LIVE ref (read-only compare; no transplant)
live=cave/"lab_LIVE_pret.exe"
if live.exists():
    P("\n=== LIVE SoftCap lit ref (read-only) ===")
    tagL,shL,bL,_,_,n868L,outL=run(live,"p_ret_lit.x",timeout=8)
    P(f"LIVE lit {tagL} sha={shL} n868={n868L}")
    find_sret(bL,"LIVE")

# === DIG: Capless CallExpr USER-emit of args under base_828 ===
# Prior: call-mk HIT @578273/@57b98c/@57bb30/@575645; skip @575786→@575fa3
# USER under b828: lea rcx; sub rsp,0x20; call — who emits sub rsp / call without rdx?
# Search Isol .text for template bytes that Capless copies: 4883ec20 (sub rsp,0x20) near call emitters

text_va=text_ro=text_sz=None
for n,(va,vs,ro,rs) in secs.items():
    if n==b'.text':
        text_va,text_ro,text_sz=va,ro,max(vs,rs); break
region=bytes(b828[text_ro:text_ro+text_sz])

P("\n=== Isol templates: ba0a / 4889c2 / sub rsp,0x20 near Capless ===")
# Capless window roughly 0x554000..0x57c000
hits_ba=[]
hits_rdx=[]
hits_sub20=[]
for i in range(0,len(region)-5):
    rva=text_va+i
    if not (0x550000<=rva<=0x585000): continue
    if region[i:i+5]==bytes.fromhex("ba0a000000"): hits_ba.append(rva)
    if region[i:i+3]==bytes.fromhex("4889c2"): hits_rdx.append(rva)
    if region[i:i+4]==bytes.fromhex("4883ec20"): hits_sub20.append(rva)
P(f"  ba0a in Capless-ish: {[hex(r) for r in hits_ba[:20]]} (n={len(hits_ba)})")
P(f"  4889c2 in Capless-ish: {[hex(r) for r in hits_rdx[:20]]} (n={len(hits_rdx)})")
P(f"  4883ec20 in Capless-ish: {[hex(r) for r in hits_sub20[:20]]} (n={len(hits_sub20)})")

# Disasm enc helpers known HIT under b828
for rva,nm in [(0x524944,"enc_524944"),(0x521f10,"enc_521f10"),(0x521d78,"enc_521d78"),
               (0x5aaf18,"helper_5aaf18")]:
    P(f"\n=== {nm} @{rva:06x} ===")
    o=rva2off(b828,secs,rva)
    for insn in md.disasm(bytes(b828[o:o+0x60]), rva):
        P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Dig Capless CallExpr around where USER call is composed.
# Prior nail: after sret lea->rcx Capless may treat nargs=0.
# Look at Capless try / call-mk entry for arg-count cmp / je skip-args.
P("\n=== Capless CallExpr / call-mk arg region disasm ===")
for rva in [0x577c80,0x578200,0x57b98c,0x57bb00,0x5752bc,0x575600,0x575780,0x575fa3]:
    o=rva2off(b828,secs,rva)
    P(f"\n-- @{rva:06x} --")
    for insn in md.disasm(bytes(b828[o:o+0x50]), rva):
        P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# INT3: Capless sites that may gate arg0 emit (NOT arg-loop force)
# Focus: after sret setup, before call-mk E8 write; arg-count / first-arg emit
P("\n=== INT3 arg0-gate candidates under b828 ===")
cands=[
    (0x524944,"enc_524944"),
    (0x521f10,"enc_521f10"),
    (0x521d78,"enc_521d78"),
    (0x5aaf18,"h_5aaf18"),
    (0x575fa3,"cmk_fa3"),
    (0x57605c,"cmk_jmp_loop"),
    (0x5762a2,"cmk_loop"),
    (0x578273,"call_57b98c"),
    (0x57bb30,"call_cmk"),
    (0x575645,"cmp_eax2"),
    (0x575786,"skip_jns"),
    (0x577681,"cap_join"),
    (0x577c47,"kind3"),
    (0x1ff2ef,"post_kind3"),
    # Capless CallExpr arg emit suspects from prior (non arg-loop)
    (0x555ed8,"try_555ed8"),
    (0x55483c,"try_55483c"),
    (0x563e0c,"eax2_src"),
]
hits=[]
for rva,nm in cands:
    if time.time()-T0>BUDGET-40: break
    t1=time.time()
    tag,_,_,_,_,_,_=run(plant_int3(b828,[rva],nm),timeout=5)
    mark=" HIT" if tag=="INT3" else f" {tag}"
    if tag=="INT3": hits.append((rva,nm))
    P(f"  @{rva:06x} {nm:16s} ->{mark} ({time.time()-t1:.1f}s)")
P(f"HITs: {[(hex(r),n) for r,n in hits]}")

# Search Capless for cmp-with-0 / je that skips a call to enc (arg emit skip under nargs==0)
# Practical: scan @57b98c..@57bc00 and @5752bc..@575700 for `test/cmp` + `je` skipping call
P("\n=== scan call-mk for je-skip-call (arg emit gate) ===")
gates=[]
for start,end in [(0x57b98c,0x57bd00),(0x5752bc,0x575800),(0x577b00,0x578400)]:
    o=rva2off(b828,secs,start)
    chunk=bytes(b828[o:o+(end-start)])
    for insn in md.disasm(chunk, start):
        if insn.mnemonic in ("je","jz","jne","jnz","jle","jg","jns","js") and "0x" in insn.op_str:
            # peek next few for call
            gates.append((insn.address, insn.mnemonic, insn.op_str))
P(f"  branch sites n={len(gates)} sample={[ (hex(a),m,t) for a,m,t in gates[:30] ]}")

# Dense INT3 on Capless CallExpr between kind3 and call-mk that might be arg emit
P("\n=== INT3 Capless kind3->call-mk corridor ===")
corridor=[]
o=rva2off(b828,secs,0x577c47)
for insn in md.disasm(bytes(b828[o:o+0x200]), 0x577c47):
    if insn.mnemonic=="call":
        corridor.append((insn.address, insn.op_str))
    if insn.address>0x578300: break
P(f"  calls: {[(hex(a),t) for a,t in corridor[:20]]}")
for rva,tgt in corridor[:10]:
    if time.time()-T0>BUDGET-28: break
    tag,_,_,_,_,_,_=run(plant_int3(b828,[rva],f"c{rva:x}"),timeout=5)
    P(f"  call @{rva:06x} ->{tgt} -> {tag}")

# === Plant b828_immrdx ===
# Hypothesis: Capless under sret sets nargs=0 / skips first-arg encode.
# From LIVE: after lea rcx, emit mov eax,imm; spill; mov rdx,rax before call.
# Isol has enc helpers @521f10/@524944 (HIT) — if call-mk reaches them for rdx under SoftCap lit?
# If enc HIT but USER has no rdx, enc writes OTHER things (frame/sub rsp), not arg0.
#
# Alternative plant: at USER-template level inside Capless emit_call —
# find where Capless emits `sub rsp,0x20` then immediately `call` without rdx insert.
# SoftCap lit USER pattern under b828 is produced by Capless codegen templates.
#
# Look for Isol immediate template sequence: 4883ec20 e8.... (sub+call) — Capless may memcpy
P("\n=== search Isol for sub rsp,0x20 ; call template ===")
sub_call=[]
for i in range(0,len(region)-8):
    if region[i:i+4]==bytes.fromhex("4883ec20") and region[i+4]==0xe8:
        rva=text_va+i
        if 0x500000<=rva<=0x5c0000:
            sub_call.append(rva)
P(f"  sub20+call templates: {[hex(r) for r in sub_call[:25]]} (n={len(sub_call)})")
for rva in sub_call[:8]:
    o=rva2off(b828,secs,rva)
    P(f"  @{rva:06x}:")
    for insn in md.disasm(bytes(b828[o:o+0x18]), rva):
        P(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# LIVE SoftCap has mov eax,0xa template near call — Isol Capless SoftCap lit path may have
# a gate `if arg_idx>=nargs: skip` with nargs wrongly 0 under sret.
# Plant candidate: force a known Capless cmp nargs / je-skip to fallthrough.
# From prior dig_b828_cmk: @57578c cmp [rbp+0x990],1 ; !=1 → @575fa3 (skip eax==2 body)
# eax==2 path AV when forced — that path is NOT Isol-native arg0.
#
# New angle: Capless @1ff2ef (post kind3 HIT) — dig that fn for arg emit
P("\n=== post_kind3 @1ff2ef disasm + INT3 children ===")
o=rva2off(b828,secs,0x1ff2ef)
for insn in md.disasm(bytes(b828[o:o+0x80]), 0x1ff2ef):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Plant1 b828_immrdx: if Capless emits call via a path that has optional arg0 block
# gated by `test reg,reg; je skip`, force je→jmp into arg block OR nop the je to fall into emit.
# Concrete from corridor HITs — pick first je before a call to enc that is on-path.
# Safer known-on-path plant from DIG: SoftCap lit hits skip@575786 then @575fa3 clear.
# Under @575fa3 the loop @5762a2 AV'd mid-insn when forced — ban that.
#
# Instead: look at Capless emit of rcx (sret) — after that, is there a skipped call to mov_rdx?
# Search Capless for call @521f10 / @524944 / @521d78 sites and INT3 them (already did — HIT means used).
# If enc HIT but no USER rdx, enc is used for OTHER opcodes (sub rsp / call E8 / lea).
#
# Check what enc@521f10 writes — if it's generic emit_bytes, Capless may call it with rdx template
# only when nargs>0. Force Capless nargs spill.
#
# Find Capless store of nargs near CallExpr: look for mov [rbp+X],0 then later cmp that slot.
# SoftCap lit CallExpr: 1 user arg (imm 10) + sret. Isol may store nargs=0 because sret_shift.
# Prior leftover note: sret_shift — Capless may decrement nargs or skip arg0 when sret_shift set.
#
# Search Isol for pipeline_asm_emit_call_sret_reg_shift string / nearby code
P("\n=== search sret_shift / nargs markers in Isol ===")
# string refs often near; scan for immediate 0x990 (known call-mk flag slot) already used
# Look Capless for `mov dword [rbp+??], 0` then call emit — too broad.
# Practical plant: Capless @577c47 kind3 path — after kind3, before call @57b98c,
# if there's `cmp [nargs],0; je skip_args`, force that je to fallthrough.
o=rva2off(b828,secs,0x577c47)
chunk=bytes(b828[o:o+0x400])
P("-- corridor disasm calls+branches --")
for insn in md.disasm(chunk, 0x577c47):
    if insn.mnemonic.startswith("j") or insn.mnemonic=="call" or (insn.mnemonic=="cmp" and "0x" in insn.op_str):
        P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    if insn.address>0x5782c0: break

# Plant: force Capless to take path that emits args.
# From dig_b828_cmk: SoftCap-site @2be734 already mov eax,0 (miss) → Capless continue HIT.
# Capless try returns 0 → continue → kind3 → call-mk. Args should be emitted in call-mk.
# USER has call but no rdx ⇒ call-mk writes E8 but skips arg0 encode under Isol SoftCap lit.
#
# Dig call-mk @57b98c for where it decides to emit args vs only call
P("\n=== call-mk @57b98c body (arg decision) ===")
o=rva2off(b828,secs,0x57b98c)
for insn in md.disasm(bytes(b828[o:o+0x180]), 0x57b98c):
    P(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# INT3 denser inside @57b98c for arg-related calls
P("\n=== INT3 inside @57b98c ===")
o=rva2off(b828,secs,0x57b98c)
addrs=[]
for insn in md.disasm(bytes(b828[o:o+0x120]), 0x57b98c):
    if insn.mnemonic in ("call","je","jne","jz","jnz","cmp","test"):
        addrs.append((insn.address,f"{insn.mnemonic} {insn.op_str}"))
    if len(addrs)>=14: break
for rva,desc in addrs:
    if time.time()-T0>BUDGET-18: break
    tag,_,_,_,_,_,_=run(plant_int3(b828,[rva],f"mk{rva:x}"),timeout=5)
    P(f"  @{rva:06x} {desc:40s} -> {tag}")

# === Plant b828_immrdx ===
# Based on static: find a je that skips a call likely to be arg emit; force fallthrough (je→jmp to next)
# OR: nop a `mov dword [nargs],0` that zeros user args under sret.
# Fallback plant if we see on-path `cmp reg,0; je skip`: change je to nop*2 so fallthrough emits.
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

# Plant A: at call-mk @575648 jne @575fa3 — already tried (AV). Skip.
# Plant B: Capless kind3 path — if SoftCap lit has a `cmp [argn],0; je` before enc call, force.
# Look specifically for pattern near @578200: often Capless does:
#   mov eax, [nargs]; test eax,eax; je no_args; ... emit arg0 ...
# From corridor disasm printed above, pick first on-path je whose target skips a call.

# Concrete Isol-native plant from known structure:
# @57578c: cmp dword [rbp+0x990], 1 ;  then jne/je
# When ==1 takes eax==2-ish path; SoftCap lit has !=1 → fa3.
# That is NOT arg0.
#
# Better: encode path @521f10 — if it's mov-reg encoder, Capless may call with dst=rdx src=imm
# only when enabled. Search callers of @521f10 in Capless range.
P("\n=== callers of enc@521f10 / @524944 in Capless ===")
def find_callers(target):
    out=[]
    for i in range(0,len(region)-5):
        if region[i]==0xe8:
            rel=struct.unpack_from("<i",region,i+1)[0]
            rva=text_va+i
            dest=rva+5+rel
            if dest==target and 0x550000<=rva<=0x585000:
                out.append(rva)
    return out
c521=find_callers(0x521f10); c524=find_callers(0x524944); c521d=find_callers(0x521d78)
P(f"  call @521f10: {[hex(r) for r in c521[:15]]} n={len(c521)}")
P(f"  call @524944: {[hex(r) for r in c524[:15]]} n={len(c524)}")
P(f"  call @521d78: {[hex(r) for r in c521d[:15]]} n={len(c521d)}")

# INT3 a few Capless callers of enc (arg-ish)
for rva in (c521+c524+c521d)[:8]:
    if time.time()-T0>BUDGET-12: break
    tag,_,_,_,_,_,_=run(plant_int3(b828,[rva],f"encc{rva:x}"),timeout=5)
    P(f"  enc-caller @{rva:06x} -> {tag}")

# Plant C b828_immrdx: force Capless SoftCap-site early claim? already miss.
# Plant: at Capless where sret_shift causes arg0 skip —
# Search for `lea` of sret then immediate `jmp` over arg block in Capless emit.
# From USER bytes under b828: after mov rcx,rax comes sub rsp — Capless emit_call sequence.
# Isol Capless may have flag `emit_arg0=0` when sret. Find cmp of that flag.
#
# Minimal semantic plant: nop the `sub rsp,0x20` emission's preceding "skip args" by
# forcing Capless to use LIVE-shaped path that includes mov rdx — WITHOUT transplanting LIVE.
# Isol must already have the code.
#
# Search Isol for sequence that emits both 4889c1 (mov rcx,rax) and later 4889c2 (mov rdx,rax)
# as consecutive template blobs (LIVE USER shape).
P("\n=== Isol nearby 4889c1 then 4889c2 templates ===")
idx=0; pair_hits=[]
while True:
    i=region.find(bytes.fromhex("4889c1"), idx)
    if i<0: break
    j=region.find(bytes.fromhex("4889c2"), i, i+0x40)
    if j>=0:
        rva=text_va+i
        if 0x500000<=rva<=0x5c0000:
            pair_hits.append(rva)
    idx=i+1
    if len(pair_hits)>30: break
P(f"  rcx+rdx template pairs: {[hex(r) for r in pair_hits[:20]]} (n={len(pair_hits)})")

# Also ba0a within 0x30 of 4889c2
idx=0; imm_rdx=[]
while True:
    i=region.find(bytes.fromhex("ba0a000000"), idx)
    if i<0:
        i=region.find(bytes.fromhex("b80a000000"), idx)
        if i<0: break
        # check rdx near
        win=region[i:i+0x30]
        if bytes.fromhex("4889c2") in win or bytes.fromhex("4889d0") in win:
            rva=text_va+i
            if 0x500000<=rva<=0x5c0000: imm_rdx.append(rva)
        idx=i+1
    else:
        rva=text_va+i
        if 0x500000<=rva<=0x5c0000: imm_rdx.append(rva)
        idx=i+1
    if len(imm_rdx)>40: break
P(f"  imm10->rdx-ish templates: {[hex(r) for r in imm_rdx[:20]]} (n={len(imm_rdx)})")

# If Isol has imm->rdx template in Capless range, find who calls the emitter and whether SoftCap lit hits it.
# Plant: retarget a near Capless fallthrough that currently emits only sub+call to also call the
# imm->rdx helper — but that risks mega. Prefer flip a je that skips existing Isol-native call.
#
# Final plant attempt: Capless @578273 is call @57b98c (HIT). Inside 57b98c, before writing call,
# there should be arg emit. If SoftCap lit INT3 inside shows which branches taken,
# plant the skip-branch to fallthrough.

# From INT3 inside @57b98c results (printed), pick a je that was NOT HIT (off-path = skip taken)
# vs HIT (on-path). Force an off-path je's opposite (je→jmp to the skipped block) ONLY if
# the skipped block is Isol-native arg emit — carefully.

# Simpler plant used across prior DIG when arg0 missing under sret:
# Capless stores nargs; under sret SoftCap lit nargs may be read as 0.
# Find Capless `mov eax, [nargs_slot]; test eax,eax; jle/je skip` on-path under b828.
# We INT3 the test/je — if HIT, SoftCap lit sees nargs and may be 0.
# Force: before that cmp, `mov eax,1` (claim 1 user arg) — Isol-native slot write.

# Locate on-path nargs test near call-mk entry by scanning @57b98c for `test eax,eax` / `cmp eax,0`
P("\n=== plant scan: on-path nargs test in @57b98c ===")
o=rva2off(b828,secs,0x57b98c)
nargs_sites=[]
for insn in md.disasm(bytes(b828[o:o+0x200]), 0x57b98c):
    if insn.mnemonic in ("test","cmp") and ("eax" in insn.op_str or "rax" in insn.op_str):
        nargs_sites.append((insn.address, f"{insn.mnemonic} {insn.op_str}", bytes(insn.bytes)))
P(f"  cmp/test: {[(hex(a),d,b.hex()) for a,d,b in nargs_sites[:12]]}")

# Plant b828_immrdx: if we find `cmp eax,0` / `test eax,eax` then `je/jle` on path,
# patch preceding to `mov eax,1; nop...` matching size — force nargs>=1.
# Only if INT3 on that cmp HIT under SoftCap lit.
planted=False
for rva,desc,raw in nargs_sites[:8]:
    if time.time()-T0>BUDGET-10: break
    tag,_,_,_,_,_,_=run(plant_int3(b828,[rva],f"nt{rva:x}"),timeout=5)
    P(f"  nargs-site @{rva:06x} {desc} -> {tag}")
    if tag=="INT3" and not planted:
        # look at next insn — must be je/jle/jz
        o2=rva2off(b828,secs,rva)
        it=list(md.disasm(bytes(b828[o2:o2+0x20]), rva))
        if len(it)>=2 and it[1].mnemonic in ("je","jz","jle","jle","jne","jnz"):
            # Force eax=1 before cmp: overwrite a prior mov/xor if short; else change je to jmp-never
            # Safest Isol-native: change je/jz skip to nop nop (fallthrough = emit args)
            j=it[1]
            if j.mnemonic in ("je","jz","jle") and len(j.bytes)==2:
                P(f"  -> plant b828_immrdx: nop je @{j.address:06x} ({j.mnemonic} {j.op_str})")
                do_plant("b828_immrdx", [(j.address, b"\x90\x90", bytes(j.bytes))])
                planted=True
            elif j.mnemonic in ("jne","jnz") and len(j.bytes)==2:
                # jne means skip when !=0; to force take body when eax==0, change to jmp always to body? 
                # Actually jne skip: if eax==0 ZF=1, jne not taken → fallthrough body. So eax=0 already enters body.
                # If HIT on test and jne, SoftCap lit has eax!=0 and jumps skip — force nop jne to fallthrough.
                P(f"  -> plant b828_immrdx: nop jne @{j.address:06x} ({j.mnemonic} {j.op_str})")
                do_plant("b828_immrdx", [(j.address, b"\x90\x90", bytes(j.bytes))])
                planted=True

# Fallback plant: Capless @575786 jns — already HIT. 
# If no plant yet: force enc path by patching Capless early `mov eax,0` success that skips args.
if not planted:
    P("\n=== fallback plant b828_immrdx: Capless @577cbc jns -> nop (don't early-exit try>0) ===")
    # Prior b828_cmk changed je@577cb3; here change jns success-exit to fall into -1? bad.
    # Better fallback: at USER-facing Capless emit after sret, force call to Isol helper that
    # writes imm->rdx if we found a template pair.
    # Use: SoftCap lit hits @1ff2ef; if that fn has je skip over rdx emit, nop it.
    o=rva2off(b828,secs,0x1ff2ef)
    for insn in md.disasm(bytes(b828[o:o+0x100]), 0x1ff2ef):
        if insn.mnemonic in ("je","jz") and len(insn.bytes)==2:
            # INT3 first
            tag,_,_,_,_,_,_=run(plant_int3(b828,[insn.address],f"pk{insn.address:x}"),timeout=5)
            P(f"  @1ff2ef-je @{insn.address:06x} -> {tag}")
            if tag=="INT3":
                do_plant("b828_immrdx", [(insn.address, b"\x90\x90", bytes(insn.bytes))])
                planted=True
                break
        if time.time()-T0>BUDGET-6: break

# Last fallback: plant at Capless call-mk path @57bb30 area — force a known
# `cmp dword [rbp+disp],0; je` on-path to fallthrough (nop je)
if not planted:
    P("\n=== last fallback: scan @57bb00.. for on-path je skip ===")
    o=rva2off(b828,secs,0x57bb00)
    for insn in md.disasm(bytes(b828[o:o+0x80]), 0x57bb00):
        if insn.mnemonic in ("je","jz") and len(insn.bytes)==2:
            tag,_,_,_,_,_,_=run(plant_int3(b828,[insn.address],f"bb{insn.address:x}"),timeout=5)
            P(f"  @{insn.address:06x} {insn.mnemonic} {insn.op_str} -> {tag}")
            if tag=="INT3":
                do_plant("b828_immrdx", [(insn.address, b"\x90\x90", bytes(insn.bytes))])
                planted=True
                break
        if time.time()-T0>BUDGET-4: break

P(f"\nPLANTED={planted}")
P(f"RESULTS: {results}")
P(f"elapsed={time.time()-T0:.1f}s DONE")
for p in list(cave.glob("_dig_himm_*.exe"))+list(cave.glob("_tmp__dig_himm_*")):
    try: p.unlink()
    except: pass
for p in list(cave.glob("host_b828*.exe"))+list(cave.glob("host_immrdx*.exe")):
    try: p.unlink()
    except: pass
for p in list(cave.glob("_tmp_host_b828*"))+list(cave.glob("_tmp_host_immrdx*")):
    try: p.unlink()
    except: pass
P("EXIT:0")
