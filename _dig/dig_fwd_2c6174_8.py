#!/usr/bin/env python3
"""DIG fwd_2c6174 #8: widen 46a4db sites; nail iso-chain; plant b0+h2c+c46wide;
AV locus @46a741. Budget<=85s."""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64)
cave = Path("C:/xlang_tmp/p1060/cave"); os.chdir(str(cave))
T0=time.time()
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
    out=cave/f"_t748_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
def run_bin(exe,timeout=3):
    try:
        r=subprocess.run([str(exe)],capture_output=True,timeout=timeout)
        return tag_of(r.returncode)
    except subprocess.TimeoutExpired:
        return "TIMEOUT"
def save(pe,name):
    p=cave/name; p.write_bytes(bytes(pe)); return p
def gate(h,label):
    sha=hashlib.sha256(h.read_bytes()).hexdigest()[:12]
    P(f"  [{label}] sha={sha}")
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
        tag,sh,outx=run(h,src)
        rt=run_bin(outx) if tag=="OK" and outx else "-"
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}")
    return sha

for pat in ["_t748_*","_d748_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

def find_disp_off(pe,rva,expect_disp):
    o=rva2off(pe,secs,rva)
    ins=list(md.disasm(bytes(pe[o:o+16]),rva))[0]
    raw=bytes(pe[o:o+ins.size])
    idx=raw.find(struct.pack("<i", expect_disp))
    assert idx>=0, (hex(rva),raw.hex(),hex(expect_disp),ins.op_str)
    return o+idx, ins
def patch_disp(pe,rva,old_d,new_d):
    off,ins=find_disp_off(pe,rva,old_d)
    pe[off:off+4]=struct.pack("<i", new_d)
    return ins
def collect_disp_sites(start,nbytes,disp):
    off=rva2off(base,secs,start); out=[]
    for insn in md.disasm(bytes(base[off:off+nbytes]),start):
        o=rva2off(base,secs,insn.address)
        raw=bytes(base[o:o+insn.size])
        if struct.pack("<i",disp) in raw and "rbp" in insn.op_str:
            out.append(insn.address)
    return out
def byte_scan_disp(start,nbytes,disp):
    """Raw scan for disp32 as imm, then verify disasm uses rbp+disp."""
    off=rva2off(base,secs,start)
    chunk=bytes(base[off:off+nbytes])
    needle=struct.pack("<i",disp)
    sites=[]
    i=0
    while True:
        j=chunk.find(needle,i)
        if j<0: break
        # try disasm a few bytes before
        for back in range(0,8):
            at=start+j-back
            if at<start: continue
            try:
                ins=list(md.disasm(bytes(base[rva2off(base,secs,at):rva2off(base,secs,at)+16]),at))[0]
            except Exception:
                continue
            if ins.address==at and "rbp" in ins.op_str and struct.pack("<i",disp) in bytes(base[rva2off(base,secs,at):rva2off(base,secs,at)+ins.size]):
                sites.append(at); break
        i=j+1
    return sorted(set(sites))

# A) widen 46a4db 0x198 sites
P("=== A 46a4db 0x198 sites widen ===")
sites_500=collect_disp_sites(0x46a4db,0x500,0x198)
sites_2000=byte_scan_disp(0x46a4db,0x2000,0x198)
P(f"  disasm500={[hex(x) for x in sites_500]}")
P(f"  raw2000={[hex(x) for x in sites_2000]}")

# B) dump around 46a741 (fwd AV under chain)
P("\n=== B @46a730 context ===")
off=rva2off(base,secs,0x46a720)
for insn in md.disasm(bytes(base[off:off+0x60]),0x46a720):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x46a780: break

# C) plant: SoftCap home-only 0xb0 + h2c all 0x100 + c46 all widened 0x160
P("\n=== C plant iso3: scs_home_b0 + h2c_rt + c46wide_rt ===")
pe=bytearray(base)
patch_disp(pe,0x2be53e,0xf8,0xb0)
for r in collect_disp_sites(0x2c614f,0x200,0x138):
    patch_disp(pe,r,0x138,0x100)
for r in sites_2000:
    patch_disp(pe,r,0x198,0x160)
h=save(pe,"host_2c_iso3.exe")
sha=gate(h,"iso3")
for rva,name in [(0x2be911,"scs_pop"),(0x57674b,"after_46"),(0x46a741,"c46_741"),(0x5767a0,"call_493"),(0x5767a5,"after_493"),(0x578278,"cap_epi"),(0x123781,"caller")]:
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
    tf=run(save(pe2,f"_d748_{name}.exe"),"_var_fwd.x")[0]
    tl=run(save(pe2,f"_d748_{name}.exe"),"_var_let.x")[0]
    P(f"  iso3 INT3@{rva:06x} {name:10s} fwd={tf:8s} let={tl:8s}")

# D) iso3 + 493 full rt
P("\n=== D plant iso4: iso3 + 493 rt ===")
sites_493=byte_scan_disp(0x493d31,0x2000,0x208)
P(f"  493 sites={[hex(x) for x in sites_493]}")
pe=bytearray(base)
patch_disp(pe,0x2be53e,0xf8,0xb0)
for r in collect_disp_sites(0x2c614f,0x200,0x138): patch_disp(pe,r,0x138,0x100)
for r in sites_2000: patch_disp(pe,r,0x198,0x160)
for r in sites_493: patch_disp(pe,r,0x208,0x1d0)
h=save(pe,"host_2c_iso4.exe")
sha=gate(h,"iso4")
for rva,name in [(0x2be911,"scs_pop"),(0x57674b,"after_46"),(0x5767a5,"after_493"),(0x578278,"cap_epi"),(0x123781,"caller")]:
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
    tf=run(save(pe2,f"_d748_4{name}.exe"),"_var_fwd.x")[0]
    tl=run(save(pe2,f"_d748_4{name}.exe"),"_var_let.x")[0]
    P(f"  iso4 INT3@{rva:06x} {name:10s} fwd={tf:8s} let={tl:8s}")

# E) Compare: only SoftCap nopr9 + @2c nopr9 + 46a500 nop (homes only) — DIG dual+1
P("\n=== E triple home-nop (DIG) ===")
pe=bytearray(base)
for rva,sz_expect in [(0x2be53e,7),(0x2c6174,7),(0x46a500,7)]:
    o=rva2off(pe,secs,rva)
    ins=list(md.disasm(bytes(pe[o:o+16]),rva))[0]
    pe[o:o+ins.size]=b"\x90"*ins.size
    P(f"  nop {ins.address:06x} sz={ins.size} {ins.mnemonic} {ins.op_str}")
h=save(pe,"host_2c_trip_nop.exe")
gate(h,"trip_nop")
for rva,name in [(0x2be911,"scs_pop"),(0x57674b,"after_46"),(0x5767a5,"after_493"),(0x123781,"caller")]:
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
    tf=run(save(pe2,f"_d748_t{name}.exe"),"_var_fwd.x")[0]
    tl=run(save(pe2,f"_d748_t{name}.exe"),"_var_let.x")[0]
    P(f"  trip INT3@{rva:06x} {name:10s} fwd={tf:8s} let={tl:8s}")

# F) Capless after_46 path under iso3 — what next after 46 returns for let vs fwd
P("\n=== F Capless after SoftCap success path summary ===")
P("  SoftCap@576692 → @2c614f@5766ec → 0x46a4db@576746 → 0x493d31@5767a0 → ... → epi@578278")
P("  each lea-frame r9 home aliases Capless[rsp+0x20] ISOMORPHIC smash chain")

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t748_*","_d748_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
