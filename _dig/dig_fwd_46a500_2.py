#!/usr/bin/env python3
"""DIG fwd_46a500 #2: under b0_h2c, nail GS after @46a76f HIT; dump late body;
probe calls/jmps; check callees for /GS. No chain-extend. Budget<=85s."""
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
    out=cave/f"_t502_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
def save(pe,name):
    p=cave/name; p.write_bytes(bytes(pe)); return p
def gate(h,label):
    sha=hashlib.sha256(h.read_bytes()).hexdigest()[:12]
    P(f"  [{label}] sha={sha}")
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]:
        tag,sh,outx=run(h,src)
        P(f"  {label}/{src:14s} {tag:8s} USER={sh}")
    return sha

for pat in ["_t502_*","_d502_*"]:
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
    assert idx>=0, (hex(rva),raw.hex(),hex(expect_disp))
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
def make_b0_h2c():
    pe=bytearray(base)
    patch_disp(pe,0x2be53e,0xf8,0xb0)
    for r in collect_disp_sites(0x2c614f,0x200,0x138):
        patch_disp(pe,r,0x138,0x100)
    return pe
def int3_pair(pe,rva,name):
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
    tf=run(save(pe2,f"_d502_{name}.exe"),"_var_fwd.x")[0]
    tl=run(save(pe2,f"_d502_{name}l.exe"),"_var_let.x")[0]
    P(f"  INT3@{rva:06x} {name:14s} fwd={tf:8s} let={tl:8s}")
    return tf,tl

pe_bh=make_b0_h2c()
gate(save(pe_bh,"host_46_b0_h2c.exe"),"b0_h2c")

# A) dump 46a76f .. first ret
P("\n=== A dump from 46a76f toward epi ===")
off=rva2off(base,secs,0x46a76f)
end=0x46af70
for insn in md.disasm(bytes(base[off:off+(end-0x46a76f)]),0x46a76f):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x46a900 and insn.mnemonic=="ret":
        break
    if insn.address>=0x46a9c0: break

# B) collect calls after 46a76f in body
P("\n=== B calls/jmps after 46a76f ===")
calls=[]; jmps=[]
for insn in md.disasm(bytes(base[off:off+0x800]),0x46a76f):
    if insn.mnemonic=="call":
        calls.append((insn.address, insn.op_str))
    if insn.mnemonic in ("jmp","je","jne","jle","jg","ja","jb","jz","jnz") and insn.op_str.startswith("0x"):
        jmps.append((insn.address, insn.mnemonic, insn.op_str))
P(f"  calls({len(calls)})={[ (hex(a),t) for a,t in calls[:20] ]}")
P(f"  jmps_sample={[(hex(a),m,t) for a,m,t in jmps[:15]]}")

# C) dense INT3 probes after 46a76f
P("\n=== C dense probes after 46a76f under b0_h2c ===")
probe_rvas=[0x46a76f,0x46a774]
# add every call site + a few landmarks
for a,t in calls[:18]:
    probe_rvas.append(a)
# landmarks from dump expectation
for a in [0x46a800,0x46a820,0x46a840,0x46a860,0x46a880,0x46a8a0,0x46a8ba,0x46a8c0,
          0x46a900,0x46a950,0x46a9a0,0x46aa00,0x46ab00,0x46ac00,0x46ae00,0x46af00,0x46af65]:
    probe_rvas.append(a)
# unique sorted
seen=set(); probes=[]
for a in probe_rvas:
    if a not in seen:
        seen.add(a); probes.append(a)

for rva in probes:
    if time.time()-T0>55: P("  BUDGET stop C"); break
    # verify valid insn start roughly
    try:
        o=rva2off(base,secs,rva)
        ins=list(md.disasm(bytes(base[o:o+16]),rva))[0]
        if ins.address!=rva:
            # snap to nearby?
            continue
    except Exception:
        continue
    int3_pair(pe_bh,rva,f"p{rva:x}"[-10:])

# D) check callee 0x1fb198 / 0x439b41 / 0x2b49f3 for /GS cookie in prol
P("\n=== D callee prol cookie scan ===")
for entry in [0x1fb198,0x1fb0ec,0x439b41,0x2b49f3,0x1fe04d,0x1fe07b]:
    o=rva2off(base,secs,entry)
    P(f"  -- callee {entry:06x} --")
    for insn in md.disasm(bytes(base[o:o+0x60]),entry):
        P(f"    {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
        if insn.address>=entry+0x50: break
    # scan 0x200 for gs: or security_check
    hits=[]
    for insn in md.disasm(bytes(base[o:o+0x400]),entry):
        s=(insn.op_str+" "+insn.mnemonic).lower()
        if "gs:" in s or "security" in s:
            hits.append(f"{insn.address:06x}:{insn.mnemonic} {insn.op_str}")
        if insn.mnemonic=="ret": break
    P(f"    gs/security hits={hits[:6]}")

# E) Capless [rsp+0x20] restore before call_46 — does Capless re-save after 2c?
P("\n=== E Capless around call_46 (576730..576760) ===")
o=rva2off(base,secs,0x576720)
for insn in md.disasm(bytes(base[o:o+0x80]),0x576720):
    P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
    if insn.address>=0x5767b0: break

# F) Does 0x46a4db READ [rbp+0x198] (=smashed slot) before GS?
P("\n=== F all [rbp+0x198] uses + nearby ===")
for r in collect_disp_sites(0x46a4db,0x1000,0x198):
    o=rva2off(base,secs,r)
    for insn in md.disasm(bytes(base[o:o+16]),r):
        P(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}")
        break
    # context -10..+20
    o2=rva2off(base,secs,r-0x10 if r>0x46a4db+0x10 else r)
    start=r-0x10 if r>0x46a4eb else r
    o2=rva2off(base,secs,start)
    for insn in md.disasm(bytes(base[o2:o2+0x30]),start):
        mark=" <<<" if insn.address==r else ""
        P(f"    {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}{mark}")
        if insn.address>=r+0x10: break

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t502_*","_d502_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
