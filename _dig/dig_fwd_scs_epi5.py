#!/usr/bin/env python3
"""DIG5 fwd_scs_epi: which Capless caller for fwd vs let; SoftCap home smash probe;
Isol plant: SoftCap miss path skip-homes OR Capless rsp align before SoftCap.
Ban force-kind/frame/epi-raise/LIVE/mega/[4b0]. Budget<=85s.
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
def tag_of(crc):
    return {0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc&0xFFFFFFFF,f"crc={crc&0xFFFFFFFF:#x}")
def run(h,src,timeout=6):
    out=cave/f"_tmp_scs5_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    try:
        r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout,cwd=str(cave))
        b=out.read_bytes() if out.exists() else b""
        sh=hashlib.sha256(b).hexdigest()[:12] if b else "-"
        return tag_of(r.returncode), sh, out if b else None
    except subprocess.TimeoutExpired:
        return "TIMEOUT","-",None
def run_bin(exe,timeout=4):
    try:
        r=subprocess.run([str(exe)],capture_output=True,timeout=timeout)
        return tag_of(r.returncode), r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT",-1
def save(pe,name):
    p=cave/name; p.write_bytes(bytes(pe)); return p

FWD="""struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { return mk(x + 1); }
function main(): i32 {
  let w: W = fw(9);
  if (w.a != 10) { return 1; }
  if (w.b != 11) { return 2; }
  if (w.c != 12) { return 3; }
  return 0;
}
"""
LET="""struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { let v: W = mk(x + 1); return v; }
function main(): i32 {
  let w: W = fw(9);
  if (w.a != 10) { return 1; }
  if (w.b != 11) { return 2; }
  if (w.c != 12) { return 3; }
  return 0;
}
"""
(cave/"_var_fwd.x").write_text(FWD,encoding="utf-8")
(cave/"_var_let.x").write_text(LET,encoding="utf-8")
(cave/"p_ret_fwd.x").write_text(FWD,encoding="utf-8")

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

# Find all E8 callers of Capless_alt @57656c
text=secs[b".text"]; raw=bytes(base[text[2]:text[2]+text[3]]); bva=text[0]
callers=[]
for insn in md.disasm(raw, bva):
    if insn.mnemonic=="call" and insn.op_str=="0x57656c":
        callers.append(insn.address)
P(f"=== Capless_alt callers n={len(callers)} {[hex(c) for c in callers]} ===")

# A) INT3 at each Capless caller — which HIT for fwd/let/lit?
P("\n=== A Capless caller INT3 HIT ===")
for c in callers:
    if time.time()-T0>BUDGET-55: break
    pe2=bytearray(base); pe2[rva2off(pe2,secs,c)]=0xCC
    h=save(pe2,f"_dig_cc_{c:x}.exe")
    tf,_,_=run(h,"_var_fwd.x"); tl,_,_=run(h,"_var_let.x"); tlit,_,_=run(h,"p_ret_lit.x")
    diff=" DIFF" if tf!=tl else ""
    P(f"  INT3@{c:06x} fwd={tf:8s} let={tl:8s} lit={tlit:8s}{diff}")

# B) SoftCap home smash: after SoftCap prol, save retaddr/saved_rbp; after homes check
# Plant: SoftCap @2be545 (after homes) INT3 — both should HIT if homes don't fault
P("\n=== B SoftCap after-homes INT3 ===")
pe2=bytearray(base); pe2[rva2off(pe2,secs,0x2be545)]=0xCC
h=save(pe2,"_dig_ah.exe")
P(f"  INT3@2be545 fwd={run(h,'_var_fwd.x')[0]} let={run(h,'_var_let.x')[0]}")

# C) Verify postlea plant (dig3 style) + GS locus under it again; also try
# Isol: SoftCap miss early AFTER homes but ZERO the home qword writes (nop homes)
# Nop SoftCap arg homes (replace each store with nops), keep rest → miss still via kind
P("\n=== C Isol nop SoftCap arg-home stores ===")
pe2=bytearray(base)
for rva in (0x2be529,0x2be530,0x2be537,0x2be53e):
    o=rva2off(pe2,secs,rva)
    ins=list(md.disasm(bytes(base[o:o+16]),rva))[0]
    pe2[o:o+ins.size]=b"\x90"*ins.size
    P(f"  nop@{rva:06x} size={ins.size} was {ins.mnemonic} {ins.op_str}")
h=save(pe2,"host_scs_nophome.exe")
sha=hashlib.sha256(bytes(pe2)).hexdigest()[:12]
P(f"  nophome sha12={sha}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x","_var_fwd.x"]:
    tag,sh,outx=run(h,src)
    rt,rc="-","-"
    if tag=="OK" and outx: rt,rc=run_bin(outx)
    P(f"  nophome/{src:14s} {tag:8s} USER={sh} run={rt}/{rc}")
# epi locus
pe3=bytearray(pe2); pe3[rva2off(pe3,secs,0x2be911)]=0xCC
h3=save(pe3,"_dig_nh_pop.exe")
P(f"  nophome INT3@pop fwd={run(h3,'_var_fwd.x')[0]} let={run(h3,'_var_let.x')[0]}")

# D) Isol: SoftCap homes write to SoftCap-local slots instead of [rbp+0xe0]
# i.e. redirect homes to [rbp-0x50].. which SoftCap zeros anyway — keep kind reads working
# SoftCap kind path reads [rbp+0xe0] and [rbp+0xf0]. So we MUST keep values at those slots
# for kind to work. Can't redirect.
# Alternative Isol: Capless before SoftCap call — sub rsp,0x28 to give SoftCap more shadow?
# Capless already has sub 0x500. SoftCap writes Capless[rsp+8..+20].
# Try Capless: before SoftCap call, zero Capless[rsp+8..+28] so SoftCap homes write clean?
# That shouldn't matter for SoftCap epi GS.

# E) Differ SoftCap incoming args fwd vs let via INT3 dump — use eq plants
# SoftCap @2be529: cmp rcx, known; or plant: SoftCap after homes cmp [rbp+0xe0],0 / je
P("\n=== E SoftCap rcx null? after entry ===")
# At @2be529 replace mov [rbp+0xe0],rcx with: test rcx,rcx; jz +5; int3; nop... 
# Simpler: INT3 if rcx==0 at entry — replace push with int3 already know entry HIT.
# Plant SoftCap: after lea, `cmp rcx, [something]`.
# Use: SoftCap first home: keep mov; then at @2be530 insert check — too hard.
# Instead: SoftCap stub-ret0 AFTER writing homes (homes+xor+jmp epi) — known dig: ret0 after entry AV for let.
# SoftCap: jmp miss from @2be545 (after homes) — dig4: fwd GS at epi, let OK.
# SoftCap: jmp miss from @2be529 (before homes) — dig3: SoftCap returns both; dig4 flaky let AV.
# Reconfirm dig3 postlea exactly:
pe2=bytearray(base)
o=rva2off(pe2,secs,0x2be529)
ins=list(md.disasm(bytes(base[o:o+16]),0x2be529))[0]
pe2[o:o+5]=bytes([0xE9])+struct.pack("<i",0x2be734-(0x2be529+5))
if ins.size>5: pe2[o+5:o+ins.size]=b"\x90"*(ins.size-5)
h=save(pe2,"_dig_postlea2.exe")
tf,_,_=run(h,"_var_fwd.x"); tl,_,_=run(h,"_var_let.x"); tlit,_,_=run(h,"p_ret_lit.x")
P(f"  reconf postlea bare fwd={tf} let={tl} lit={tlit}")
pe3=bytearray(pe2); pe3[rva2off(pe3,secs,0x2be911)]=0xCC
h3=save(pe3,"_dig_pl_pop.exe")
P(f"  reconf postlea INT3@pop fwd={run(h3,'_var_fwd.x')[0]} let={run(h3,'_var_let.x')[0]}")
pe3=bytearray(pe2); pe3[rva2off(pe3,secs,0x2c614f)]=0xCC
h3=save(pe3,"_dig_pl_2c.exe")
P(f"  reconf postlea INT3@2c614f fwd={run(h3,'_var_fwd.x')[0]} let={run(h3,'_var_let.x')[0]}")

# F) Isol plant candidate: SoftCap accept kind 0x30 as miss-but-clean same as let
# BANNED force-kind to 0x36. What about making kind 0x30 take the SAME miss path but
# ensure SoftCap doesn't smash — already on miss path.
# Try: Capless after SoftCap returns 0, skip @2c614f for return-Call? That would be Capless change.
# Look at Capless: when SoftCap returns 0, calls @2c614f. @2c614f is the REAL work for kind 0x30.
# SoftCap miss means SoftCap doesn't handle 0x30; Capless delegates to @2c614f.
# For fwd, SoftCap never returns (GS at epi). Fix SoftCap epi for fwd WITH homes.

# G) Probe: SoftCap homes write rcx only (nop rdx/r8/r9 homes)
P("\n=== G nop SoftCap rdx/r8/r9 homes; keep rcx ===")
pe2=bytearray(base)
for rva in (0x2be530,0x2be537,0x2be53e):
    o=rva2off(pe2,secs,rva)
    ins=list(md.disasm(bytes(base[o:o+16]),rva))[0]
    pe2[o:o+ins.size]=b"\x90"*ins.size
h=save(pe2,"host_scs_nop239.exe")
sha=hashlib.sha256(bytes(pe2)).hexdigest()[:12]
P(f"  nop239 sha12={sha}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,outx=run(h,src)
    rt="-"; 
    if tag=="OK" and outx: rt,_=run_bin(outx)
    P(f"  nop239/{src:14s} {tag:8s} USER={sh} run={rt}")
pe3=bytearray(pe2); pe3[rva2off(pe3,secs,0x2be911)]=0xCC
h3=save(pe3,"_dig_n239_pop.exe")
P(f"  nop239 INT3@pop fwd={run(h3,'_var_fwd.x')[0]} let={run(h3,'_var_let.x')[0]}")

# H) nop only r9 home @2be53e (overwrites Capless [rsp+0x20] stack arg!)
P("\n=== H nop SoftCap r9 home only ===")
pe2=bytearray(base)
o=rva2off(pe2,secs,0x2be53e)
ins=list(md.disasm(bytes(base[o:o+16]),0x2be53e))[0]
pe2[o:o+ins.size]=b"\x90"*ins.size
h=save(pe2,"host_scs_nopr9.exe")
sha=hashlib.sha256(bytes(pe2)).hexdigest()[:12]
P(f"  nopr9 sha12={sha}")
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
    tag,sh,outx=run(h,src)
    rt="-";
    if tag=="OK" and outx: rt,_=run_bin(outx)
    P(f"  nopr9/{src:14s} {tag:8s} USER={sh} run={rt}")
pe3=bytearray(pe2); pe3[rva2off(pe3,secs,0x2be911)]=0xCC
h3=save(pe3,"_dig_nr9_pop.exe")
P(f"  nopr9 INT3@pop fwd={run(h3,'_var_fwd.x')[0]} let={run(h3,'_var_let.x')[0]}")

# I) Capless: after SoftCap call site, ensure [rsp+0x20] restored — already re-written.
# Capless: BEFORE SoftCap, sub rsp 0x20 extra to isolate SoftCap homes from Capless shadow?
# Capless prol sub 0x500 → try sub 0x520 (extra 0x20) + adjust lea rbp keep [rsp+0x80]?
# Ban frame enlarge on SoftCap; Capless frame enlarge was align508 (lit OK fwd GS).
# align508 was Capless sub 0x508 + lea [rsp+0x88]. Didn't fix SoftCap epi GS.

# J) Key DIG: under miss@545 (homes+miss), SoftCap GS for fwd. Is retaddr smashed?
# Plant SoftCap: after homes, before jmp miss, compare [rbp+0xd8] with expected?
# Can't easily. Plant: SoftCap epi use lea rsp,[rbp+0xd0];pop;ret instead of add — dig2 tried AV.

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_dig_cc_*","_dig_ah*","_dig_nh_*","_dig_pl_*","_dig_n239_*","_dig_nr9_*","_dig_postlea*","_tmp_scs5_*","_var_*.x"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
(cave/"p_ret_fwd.x").write_text(FWD,encoding="utf-8")
P("cleaned")
