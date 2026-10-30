#!/usr/bin/env python3
"""DIG SoftCap 10.60: cmk0_rdx — call-mk [4b0]==0 Isol-native imm->rdx.
Keep call-mk path (do NOT force [4b0]=1). Ban tip@121278/join/epi/LIVE transplant/
mega/arg-loop/mega-glue/+0x478 fill.
Plant: extend call-mk @57ba3b byte-assembler (on [4b0]==0) to emit LIVE-shaped
  mov eax,0xa; mov [rbp-0x38],rax; mov rax,[rbp-0x38]; mov rdx,rax
instead of only sub rsp,0x20; append len 4->16 via existing @2a7f07.
Budget<=85s. Win cave SoftCap p_ret_*.
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

def run(h,src="p_ret_lit.x",timeout=8):
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

def find_sret(b,label):
    if not b: return False,False,False
    pat=bytes([0x48,0x8d,0x45,0xd8])
    i=b.find(pat)
    if i<0:
        for off in (0xd8,0xe0,0xd0,0xc8):
            pat=bytes([0x48,0x8d,0x45,off]); i=b.find(pat)
            if i>=0: break
    if i<0:
        P(f"  {label}: no sret lea"); return False,False,False
    win=b[i:i+0x60]
    P(f"  {label} sret @{i:#x}:")
    for insn in md.disasm(win, i):
        P(f"    @{insn.address:04x}: {insn.mnemonic} {insn.op_str}")
        if insn.address>=i+0x50: break
    has_mov_rdx = bytes.fromhex("4889c2") in win
    has_imm = (bytes.fromhex("b80a000000") in win) or (bytes.fromhex("ba0a000000") in win)
    # true imm->rdx before call: b80a near 4889c2 in first 0x20 after lea→rcx
    has_cmk = bytes.fromhex("4883ec20") in win  # sub20 (may be absent if replaced)
    has_call = b"\xe8" in win
    # LIVE shape: imm then rdx then call (no requirement for sub20)
    true_immrdx = has_imm and has_mov_rdx
    P(f"  {label} has_imm10={has_imm} mov_rdx={has_mov_rdx} sub20={has_cmk} call={has_call}")
    return true_immrdx, has_call, has_imm

def clean():
    for pat in ["_dig_cmk0_*.exe","_tmp__dig_cmk0_*","host_b828*.exe","host_cmk0_rdx*.exe",
                "_tmp_host_b828*","_tmp_host_cmk0*"]:
        for p in cave.glob(pat):
            try: p.unlink()
            except: pass

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)

P("=== DIG call-mk [4b0]==0 Isol-native imm->rdx (cmk0_rdx) ===")
P("Prior: immrdx_bypass force [4b0]=1 -> AV; base_828 keeps call-mk / missing imm->rdx")
P("call-mk @57b98c: [rbp-0x30]<-Capless [4b0]")
P("  [4b0]==0: @57ba0f fallthrough -> @57ba3b byte-asm USER 48 83 ec 20 -> append @2a7f07 -> @57bafe")
P("  [4b0]!=0: je @57bafe skip byte-asm")
P("Nail: do NOT force [4b0]=1; plant on ==0 byte-asm path only")

# verify sites
o_gate=rva2off(base,secs,0x57ba0f)
assert bytes(base[o_gate:o_gate+6])==bytes.fromhex("0f84e9000000"), bytes(base[o_gate:o_gate+6]).hex()
o_asm=rva2off(base,secs,0x57ba3b)
assert bytes(base[o_asm:o_asm+5])==bytes.fromhex("b848000000"), bytes(base[o_asm:o_asm+5]).hex()
o_len=rva2off(base,secs,0x57ba94)
assert bytes(base[o_len:o_len+5])==bytes.fromhex("b804000000"), bytes(base[o_len:o_len+5]).hex()
# @578266 must stay untouched (no force [4b0]=1)
o4=rva2off(base,secs,0x578266)
assert bytes(base[o4:o4+6])==bytes.fromhex("8b8db0040000"), bytes(base[o4:o4+6]).hex()
P(f"  @57ba0f je skip ok; @57ba3b mov eax,0x48 ok; @57ba94 mov eax,4 ok; @578266 intact")

# base_828 host
o828=rva2off(base,secs,0x24b9c1)
b828=bytearray(base)
assert bytes(b828[o828:o828+6])==bytes.fromhex("8b85fc000000"), bytes(b828[o828:o828+6]).hex()
b828[o828:o828+6]=bytes.fromhex("b82808000090")
host=cave/"host_b828.exe"; host.write_bytes(b828)
P(f"\nhost_b828={hashlib.sha256(bytes(b828)).hexdigest()[:12]}")

b828_ok=None; b828_sha="-"
for attempt in range(3):
    if time.time()-T0>BUDGET-55: break
    tag,sh,b,n68,n1b8,n868,outp=run(host,"p_ret_lit.x",timeout=8)
    P(f"b828 lit try{attempt} {tag} sha={sh} n868={n868}")
    if tag=="OK" and n868>=1:
        ok_imm, ok_call, _=find_sret(b,"b828")
        rtag,rcrc=run_bin(outp,timeout=5) if outp else ("-",-1)
        P(f"  run={rtag}/{rcrc} immrdx={ok_imm} call={ok_call}")
        b828_ok=b; b828_sha=sh
        break
    time.sleep(0.3)

# --- Plant cmk0_rdx ---
# Replace @57ba3b..@57ba84 (74 bytes) with compact writes of LIVE imm->rdx (16B)
#   b8 0a 00 00 00 | 48 89 45 c8 | 48 8b 45 c8 | 48 89 c2
# then mov eax,0x20; mov [rbp-0x68],rax (preserve original side field) + nop pad
# and @57ba94 mov eax,4 -> mov eax,16 (append len)
P("\n=== plant cmk0_rdx: [4b0]==0 byte-asm -> LIVE imm->rdx (len=16); keep call-mk ===")
USER16=bytes.fromhex("b80a000000488945c8488b45c84889c2")
assert len(USER16)==16

def build_compact_writes(seq):
    """c6 43 disp imm  per byte; rbx already &buf."""
    out=bytearray()
    for i,b in enumerate(seq):
        out += bytes([0xc6, 0x43, i, b])
    return bytes(out)

writes=build_compact_writes(USER16)  # 64 bytes
tail=bytes.fromhex("b820000000") + bytes.fromhex("48894598")  # mov eax,0x20; mov [rbp-0x68],rax
pad_n = 74 - len(writes) - len(tail)
assert pad_n >= 0, pad_n
patch74 = writes + tail + (b"\x90"*pad_n)
assert len(patch74)==74

pe=bytearray(b828)
# apply @57ba3b patch
o=rva2off(pe,pe_secs(pe),0x57ba3b)
old74=bytes(pe[o:o+74])
# sanity: starts with mov eax,0x48
assert old74[:5]==bytes.fromhex("b848000000"), old74[:5].hex()
pe[o:o+74]=patch74
# append len 4 -> 16
o=rva2off(pe,pe_secs(pe),0x57ba94)
assert bytes(pe[o:o+5])==bytes.fromhex("b804000000")
pe[o:o+5]=bytes.fromhex("b810000000")  # mov eax, 16
# verify @578266 untouched
o=rva2off(pe,pe_secs(pe),0x578266)
assert bytes(pe[o:o+6])==bytes.fromhex("8b8db0040000")

out=cave/"host_cmk0_rdx.exe"; out.write_bytes(pe)
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"cmk0_rdx sha12={sha}")
P(f"  USER16={USER16.hex()}")
P(f"  patch74_len={len(patch74)} append_len=16; [4b0] force=NO")

results=[]
for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
    if time.time()-T0>BUDGET-8:
        P(f"BUDGET skip {src}"); break
    t1=time.time()
    tag,sh,b,n68,n1b8,n868,outp=run(out,src,timeout=8)
    rtag="-"; rcrc=-1
    if tag=="OK" and outp:
        rtag,rcrc=run_bin(outp,timeout=5)
    P(f"  {src:16s} {tag:8s} sha={sh} n868={n868} run={rtag}/{rcrc} ({time.time()-t1:.1f}s)")
    ok_imm=ok_call=False
    if tag=="OK" and b and "lit" in src:
        ok_imm, ok_call, _=find_sret(b,"cmk0_rdx")
    results.append((src,tag,sh,n868,rtag,rcrc,ok_imm,ok_call))

# INT3: still on [4b0]==0 path? @57ba3b should HIT (our plant); @575799 ([990]==1) should NOT
if time.time()-T0<BUDGET-12:
    P("\n=== INT3 path check under cmk0_rdx ===")
    pe2=bytearray(pe)
    # INT3 first byte of our plant @57ba3b
    o=rva2off(pe2,pe_secs(pe2),0x57ba3b); pe2[o]=0xCC
    probe=cave/"_dig_cmk0_i57ba3b.exe"; probe.write_bytes(pe2)
    tag,_,_,_,_,_,_=run(probe,"p_ret_lit.x",timeout=6)
    P(f"  @57ba3b (plant/[4b0]==0 asm) -> {tag}")
    if time.time()-T0<BUDGET-6:
        pe3=bytearray(pe); o=rva2off(pe3,pe_secs(pe3),0x575799); pe3[o]=0xCC
        probe=cave/"_dig_cmk0_i575799.exe"; probe.write_bytes(pe3)
        tag,_,_,_,_,_,_=run(probe,"p_ret_lit.x",timeout=6)
        P(f"  @575799 ([990]==1 body) -> {tag}  (expect not INT3 if [4b0] stayed 0)")

P("\n=== VERDICT ===")
lit=[r for r in results if "lit" in r[0]]
if lit:
    src,tag,sh,n868,rtag,rcrc,ok_imm,ok_call=lit[0]
    green = tag=="OK" and rtag=="OK" and rcrc==0 and ok_imm and ok_call
    P(f"cmk0_rdx lit: compile={tag} run={rtag}/{rcrc} n868={n868} immrdx={ok_imm} call={ok_call}")
    P(f"GREEN={green}  (need OK run0 + imm->rdx + call)")
    if sh==b828_sha:
        P("NOTE: USER sha == base_828 => plant did not change emit")
    elif tag=="OK" and ok_imm:
        P("NOTE: USER gained imm->rdx vs base_828")
else:
    P("no lit result")
P(f"elapsed={time.time()-T0:.1f}s")

for pat in ["_dig_cmk0_*.exe","_tmp__dig_cmk0_*","_tmp_host_b828*","_tmp_host_cmk0*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned probes")
