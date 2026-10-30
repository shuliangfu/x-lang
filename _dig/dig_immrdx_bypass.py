#!/usr/bin/env python3
"""DIG SoftCap 10.60: Isol-native imm->rdx bypass under base_828 (no get-elem / no +0x478 fill).
Plant immrdx_bypass: Capless @578266 mov ecx,[4b0] -> mov ecx,1 (force call-mk [990]=1).
Keep call-mk. Ban tip@121278/join/epi/LIVE/mega/arg-loop/mega-glue.
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
    pat=bytes([0x48,0x8d,0x45,0xd8])  # lea rax,[rbp-0x28]
    i=b.find(pat)
    if i<0:
        for off in (0xd8,0xe0,0xd0,0xc8):
            pat=bytes([0x48,0x8d,0x45,off]); i=b.find(pat)
            if i>=0: break
    if i<0:
        P(f"  {label}: no sret lea"); return False,False,False
    win=b[i:i+0x50]
    P(f"  {label} sret @{i:#x}:")
    for insn in md.disasm(win, i):
        P(f"    @{insn.address:04x}: {insn.mnemonic} {insn.op_str}")
        if insn.address>=i+0x48: break
    has_rdx = (bytes.fromhex("4889c2") in win) or (bytes.fromhex("ba0a000000") in win)
    has_imm = (bytes.fromhex("b80a000000") in win) or (bytes.fromhex("ba0a000000") in win)
    # true imm->rdx: mov eax,imm / mov rdx,rax near lea
    has_mov_rdx = bytes.fromhex("4889c2") in win
    has_cmk = bytes.fromhex("4883ec20") in win  # sub rsp,0x20 before call
    has_call = b"\xe8" in win
    P(f"  {label} has_imm10={has_imm} mov_rdx={has_mov_rdx} sub20={has_cmk} call={has_call}")
    return has_imm and has_mov_rdx, has_cmk and has_call, has_imm

def clean():
    for pat in ["_dig_ibyp_*.exe","_tmp__dig_ibyp_*","host_b828*.exe","host_immrdx_bypass*.exe",
                "host_native_rdx*.exe","_tmp_host_b828*","_tmp_host_immrdx*","_tmp_host_native*"]:
        for p in cave.glob(pat):
            try: p.unlink()
            except: pass

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)

# --- DIG (static on host bytes) ---
P("=== DIG Isol-native imm->rdx bypass (no get-elem / no +0x478) ===")
P("Prior nail: Capless +0x478 empty; pre_last @2a62c9 len=0 skips get-elem; call-mk under base_828.")
P("call-mk @57b98c: [rbp-0x30]<-stack arg0 = Capless [rbp+0x4b0] -> @5752bc [990]")
P("  [990]==0 -> loop then jne @575fa3 skip (HIT SoftCap lit)")
P("  [990]==1 -> Isol-native @575799 corridor (arg-ish; bypass empty get-elem)")
P("Capless @578266: mov ecx,[rbp+0x4b0]; @57826c mov [rsp+0x20],ecx -> call-mk")
o4=rva2off(base,secs,0x578266)
assert bytes(base[o4:o4+6])==bytes.fromhex("8b8db0040000"), bytes(base[o4:o4+6]).hex()
oje=rva2off(base,secs,0x575793)
assert bytes(base[oje:oje+2])==bytes.fromhex("0f85"), bytes(base[oje:oje+6]).hex()
P(f"  @578266 ok={bytes(base[o4:o4+10]).hex()}")
P(f"  @575793 jne @575fa3 ok={bytes(base[oje:oje+6]).hex()}")

# base_828 host
o828=rva2off(base,secs,0x24b9c1)
b828=bytearray(base)
# @24b9c1 was mov eax,[rbp+0xfc] = 8b85fc000000 -> b82808000090
assert bytes(b828[o828:o828+6])==bytes.fromhex("8b85fc000000"), bytes(b828[o828:o828+6]).hex()
b828[o828:o828+6]=bytes.fromhex("b82808000090")
host=cave/"host_b828.exe"; host.write_bytes(b828)
P(f"\nhost_b828={hashlib.sha256(bytes(b828)).hexdigest()[:12]}")

b828_ok=None; b828_sha="-"
for attempt in range(3):
    if time.time()-T0>BUDGET-50: break
    tag,sh,b,n68,n1b8,n868,outp=run(host,"p_ret_lit.x",timeout=8)
    P(f"b828 lit try{attempt} {tag} sha={sh} n868={n868}")
    if tag=="OK" and n868>=1:
        ok_imm, ok_cmk, _=find_sret(b,"b828")
        rtag,rcrc=run_bin(outp,timeout=5) if outp else ("-",-1)
        P(f"  run={rtag}/{rcrc} immrdx={ok_imm} callmk={ok_cmk}")
        b828_ok=b; b828_sha=sh
        break
    time.sleep(0.3)

# --- Plant immrdx_bypass: force Capless [4b0] feed =1 ---
P("\n=== plant immrdx_bypass: @578266 mov ecx,1;nop (force [990]=1) ===")
pe=bytearray(b828)
o=rva2off(pe,pe_secs(pe),0x578266)
old=bytes(pe[o:o+6])
assert old==bytes.fromhex("8b8db0040000"), old.hex()
pe[o:o+6]=bytes.fromhex("b90100000090")  # mov ecx,1; nop
# keep @57826c mov [rsp+0x20],ecx
out=cave/"host_immrdx_bypass.exe"; out.write_bytes(pe)
sha=hashlib.sha256(bytes(pe)).hexdigest()[:12]
P(f"immrdx_bypass sha12={sha}")

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
    ok_imm=ok_cmk=False
    if tag=="OK" and b and "lit" in src:
        ok_imm, ok_cmk, _=find_sret(b,"immrdx_bypass")
    results.append((src,tag,sh,n868,rtag,rcrc,ok_imm,ok_cmk))

# INT3 probe: is @575799 ([990]==1 body) HIT under plant?
if time.time()-T0<BUDGET-12:
    P("\n=== INT3 @575799 ([990]==1 body) under immrdx_bypass ===")
    pe2=bytearray(pe)
    o=rva2off(pe2,pe_secs(pe2),0x575799)
    pe2[o]=0xCC
    probe=cave/"_dig_ibyp_i575799.exe"; probe.write_bytes(pe2)
    tag,_,_,_,_,_,_=run(probe,"p_ret_lit.x",timeout=6)
    P(f"  @575799 -> {tag}")
    if time.time()-T0<BUDGET-6:
        pe3=bytearray(pe); o=rva2off(pe3,pe_secs(pe3),0x575fa3); pe3[o]=0xCC
        probe=cave/"_dig_ibyp_i575fa3.exe"; probe.write_bytes(pe3)
        tag,_,_,_,_,_,_=run(probe,"p_ret_lit.x",timeout=6)
        P(f"  @575fa3 (skip) -> {tag}")

P("\n=== VERDICT ===")
lit=[r for r in results if "lit" in r[0]]
if lit:
    src,tag,sh,n868,rtag,rcrc,ok_imm,ok_cmk=lit[0]
    green = tag=="OK" and rtag=="OK" and rcrc==0 and ok_imm and ok_cmk
    P(f"immrdx_bypass lit: compile={tag} run={rtag}/{rcrc} n868={n868} immrdx={ok_imm} callmk={ok_cmk}")
    P(f"GREEN={green}  (need OK run0 + imm->rdx + call-mk)")
    if sh==b828_sha:
        P("NOTE: USER sha == base_828 => plant did not change emit")
else:
    P("no lit result")
P(f"elapsed={time.time()-T0:.1f}s")

# cleanup leftovers
for pat in ["_dig_ibyp_*.exe","_tmp__dig_ibyp_*","_tmp_host_b828*","_tmp_host_immrdx*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned probes")
