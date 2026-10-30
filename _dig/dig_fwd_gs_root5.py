#!/usr/bin/env python3
"""DIG5/plant probe fwd_gs_root: SoftCap_site miss-eax0 then GS at epi pop rbp
for return-CallExpr only. Probe: skip Capless call SoftCap_site @576692
(xor eax,eax + nops) Isol on host_cmk0_irdx_sub20. Ban tip@121278/join/epi-raise/
LIVE/mega/[4b0]=1. Budget<=85s.
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
def run(h,src,timeout=8):
    srcp=cave/src
    out=cave/f"_tmp_fgs5_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    try:
        r=subprocess.run([str(h),str(srcp),"-o",str(out)],capture_output=True,timeout=timeout,cwd=str(cave))
        crc=r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT","-",b"",0,None
    b=out.read_bytes() if out.exists() else b""
    sh=hashlib.sha256(b).hexdigest()[:12] if b else "-"
    n868=b.count(bytes.fromhex("4881ec68080000")) if b else 0
    return tag_of(crc),sh,b,n868,out if b else None
def run_bin(exe,timeout=5):
    try:
        r=subprocess.run([str(exe)],capture_output=True,timeout=timeout)
        return tag_of(r.returncode), r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT",-1

# sources
(cave/"p_ret_fwd.x").write_text(open("p_ret_fwd.x",encoding="utf-8").read() if False else "",encoding="utf-8")
# keep existing probes; write variants
(cave/"_var_fwd.x").write_text("""struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { return mk(x + 1); }
function main(): i32 {
  let w: W = fw(9);
  if (w.a != 10) { return 1; }
  if (w.b != 11) { return 2; }
  if (w.c != 12) { return 3; }
  return 0;
}
""", encoding="utf-8")
(cave/"_var_let.x").write_text("""struct W { a: i64, b: i64, c: i64 }
function mk(x: i64): W { return W { a: x, b: x + 1, c: x + 2 }; }
function fw(x: i64): W { let v: W = mk(x + 1); return v; }
function main(): i32 {
  let w: W = fw(9);
  if (w.a != 10) { return 1; }
  if (w.b != 11) { return 2; }
  if (w.c != 12) { return 3; }
  return 0;
}
""", encoding="utf-8")

base_host=cave/"host_cmk0_irdx_sub20.exe"
base=bytearray(base_host.read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

# Verify call @576692 is E8 to SoftCap_site
o=rva2off(base,secs,0x576692)
call_bytes=bytes(base[o:o+5])
P(f"=== DIG5 skip SoftCap_site @576692 ===")
P(f"bytes @576692={call_bytes.hex()}")
assert call_bytes[0]==0xE8, call_bytes.hex()
rel=struct.unpack_from("<i",call_bytes,1)[0]
target=0x576692+5+rel
P(f"call target={target:#x} (expect SoftCap_site 0x2be519)")
assert target==0x2be519

# Plant: xor eax,eax (31 c0) + nop nop nop  replacing E8 xx xx xx xx (5 bytes)
plant=bytearray(base)
plant[o:o+5]=bytes.fromhex("31c0909090")  # xor eax,eax; nop; nop; nop
# also need [rbp+0x458]=eax path: next insn is mov [rbp+0x458],eax @576697 - good
host=cave/"host_fwd_skip_scs.exe"
host.write_bytes(plant)
sha=hashlib.sha256(bytes(plant)).hexdigest()[:12]
P(f"plant skip SoftCap_site sha12={sha}")

# Also plant2: SoftCap_site kind-miss already eax=0; maybe GS is from Capless AFTER return?
# Force SoftCap_site to ret immediately at entry (xor eax,eax; add rsp; pop; ret) - too big.
# Try INT3 at Capless @576697 under skip plant to see continuation.

P("\n=== gates ===")
results=[]
for label,h in [("sub20",base_host),("skip_scs",host)]:
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_fwd.x","_var_let.x"]:
        if time.time()-T0>BUDGET-10: break
        if not (cave/src).exists() and not src.startswith("_var"):
            P(f"  missing {src}"); continue
        tag,sh,b,n868,outx=run(h,src,timeout=8)
        rtag,rcrc="-","-1"
        if tag=="OK" and outx:
            rtag,rcrc=run_bin(outx,timeout=5)
        P(f"  {label:8s}/{src:14s} compile={tag:8s} sha={sh} n868={n868} run={rtag}/{rcrc}")
        results.append((label,src,tag,sh,n868,rtag,rcrc))

# If skip greened fwd compile, dump USER sret
P("\n=== USER peek skip_scs fwd/lit ===")
for src in ["p_ret_lit.x","p_ret_fwd.x","_var_let.x"]:
    tag,sh,b,n868,outx=run(host,src,timeout=8)
    if b:
        i=b.find(bytes([0x48,0x8d,0x45,0xd8]))
        if i>=0:
            P(f"  {src} sret @{i:#x}:")
            for insn in md.disasm(b[i:i+0x40], i):
                P(f"    @{insn.address:04x}: {insn.mnemonic} {insn.op_str}")
                if insn.address>=i+0x30: break
        else:
            P(f"  {src}: no lea rbp-0x28")
    else:
        P(f"  {src}: no bin tag={tag}")

# Dig: why epi GS - dump SoftCap_site epi bytes; check for cookie call
P("\n=== SoftCap_site epi raw ===")
oe=rva2off(base,secs,0x2be900)
P(bytes(base[oe:oe+0x20]).hex())
for insn in md.disasm(bytes(base[oe:oe+0x20]),0x2be900):
    P(f"  {insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Capless frame at SoftCap call - 5th arg home
P("\n=== Capless pre-call @576685.. ===")
oc=rva2off(base,secs,0x576660)
for insn in md.disasm(bytes(base[oc:oc+0x50]),0x576660):
    P(f"  {insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    if insn.address>=0x5766b0: break

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_dig_fgs5_*","_tmp_fgs5_*","_var_*.x"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
