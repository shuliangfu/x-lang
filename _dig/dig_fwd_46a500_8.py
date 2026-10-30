#!/usr/bin/env python3
"""DIG fwd_46a500 #8: surgical plants — Capless 6th=0; 46 read 1a0; body bisect;
hollow±b0_h2c gates. Budget<=85s."""
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
    out=cave/f"_t508_{Path(src).stem}_{int(time.time()*1000)%100000}.exe"
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
    rows={}
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x","_var_fwd.x"]:
        if not (cave/src).exists(): continue
        tag,sh,outx=run(h,src)
        rt=run_bin(outx) if tag=="OK" and outx else "-"
        P(f"  {label}/{src:14s} {tag:8s} USER={sh} run={rt}")
        rows[src]=(tag,rt)
    return sha,rows
def find_disp_off(pe,secs,rva,expect_disp):
    o=rva2off(pe,secs,rva)
    ins=list(md.disasm(bytes(pe[o:o+16]),rva))[0]
    raw=bytes(pe[o:o+ins.size])
    idx=raw.find(struct.pack("<i", expect_disp))
    assert idx>=0, (hex(rva),ins.op_str,raw.hex())
    return o+idx, ins
def patch_disp(pe,secs,rva,old_d,new_d):
    off,ins=find_disp_off(pe,secs,rva,old_d)
    pe[off:off+4]=struct.pack("<i", new_d)
    return ins
def collect_disp_sites(pe,secs,start,nbytes,disp):
    off=rva2off(pe,secs,start); out=[]
    for insn in md.disasm(bytes(pe[off:off+nbytes]),start):
        o=rva2off(pe,secs,insn.address)
        raw=bytes(pe[o:o+insn.size])
        if struct.pack("<i",disp) in raw and "rbp" in insn.op_str:
            out.append(insn.address)
    return out
def make_b0_h2c(pe,secs):
    patch_disp(pe,secs,0x2be53e,0xf8,0xb0)
    for r in collect_disp_sites(pe,secs,0x2c614f,0x200,0x138):
        patch_disp(pe,secs,r,0x138,0x100)
    return pe
def hollow_at(pe,secs,hijack,epi=0x46af5d):
    """xor eax,eax; jmp epi at hijack (7 bytes)."""
    oh=rva2off(pe,secs,hijack)
    rel=epi-(hijack+7)
    pe[oh:oh+7]=bytes([0x31,0xc0,0xe9])+struct.pack("<i",rel)
    return pe
def int3_pair(pe,secs,rva,name):
    pe2=bytearray(pe); pe2[rva2off(pe2,secs,rva)]=0xCC
    tf=run(save(pe2,f"_d508_{name}.exe"),"_var_fwd.x")[0]
    tl=run(save(pe2,f"_d508_{name}l.exe"),"_var_let.x")[0]
    P(f"  INT3@{rva:06x} {name:14s} fwd={tf:8s} let={tl:8s}")
    return tf,tl

for pat in ["_t508_*","_d508_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass

base=bytearray((cave/"host_cmk0_irdx_sub20.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="3f43f1609d70"
secs=pe_secs(base)

# A) baselines
P("=== A baselines ===")
gate(save(bytearray(base),"host_46_base.exe"),"base")
pe=make_b0_h2c(bytearray(base),secs)
gate(save(pe,"host_46_b0_h2c.exe"),"b0_h2c")

# B) hollow alone (no b0_h2c) at 46a4e3
P("\n=== B hollow@46a4e3 alone ===")
pe=hollow_at(bytearray(base),secs,0x46a4e3)
gate(save(pe,"host_46_hollow_only.exe"),"hollow_only")

# C) b0_h2c + hollow (confirm green)
P("\n=== C b0_h2c+hollow@46a4e3 ===")
pe=make_b0_h2c(bytearray(base),secs)
hollow_at(pe,secs,0x46a4e3)
gate(save(pe,"host_46_b0h2c_hollow.exe"),"b0h2c_hollow")

# D) Capless plant: zero 6th arg [rsp+0x28] before call_46
# Fit: after `mov [rsp+0x20],ecx` (57673f) / before mov rcx,rax (576743) — only 4 bytes.
# Expand: overwrite mov rcx,rax (2) + call (5) = 7 bytes? Need more.
# At 57673f: 894c2420 (4) 4889c1 (3) e8... (5) = 12 bytes window
# Plant: mov [rsp+0x20],ecx; mov dword [rsp+0x28],0; mov rcx,rax; call
# 894c2420  c744242800000000  4889c1  e8rel
# 4 + 8 + 3 + 5 = 20 — too big, only 12 available.
# Smaller: change 46's read 1a8→1a0 (use 5th as the ecx source)
P("\n=== D plant 46: [rbp+0x1a8]→[rbp+0x1a0] at first read @46a507 ===")
pe=make_b0_h2c(bytearray(base),secs)
# find all [rbp+0x1a8] in 46 function (46a4db..46af65)
sites_1a8=collect_disp_sites(pe,secs,0x46a4db,0x46af66-0x46a4db,0x1a8)
P(f"  1a8 sites in 46: {[hex(s) for s in sites_1a8]}")
for s in sites_1a8:
    patch_disp(pe,secs,s,0x1a8,0x1a0)
gate(save(pe,"host_46_1a8to1a0.exe"),"1a8to1a0")

# E) Capless: zero 5th to 0 as well? Or set [rsp+0x28]=[rsp+0x20]
# Steal: replace `mov rcx,rax; call` with `xor ecx,ecx; mov [rsp+0x28],ecx; call` — loses rcx!
# rcx must be rax (arg0). 
# Use: at 46 entry after homes stored, `mov dword [rbp+0x1a8], 0`
P("\n=== E b0_h2c + zero [rbp+0x1a8] early in 46 ===")
# At 46a54f: mov dword [rbp+0x168], 0  already (7+imm = 10 bytes c7856801000000000000)
# Overwrite 46a507 block: after storing r9, instead of reading 1a8, zero it then continue?
# Surgical: patch first insn using 1a8: `mov ecx, [rbp+0x1a8]` (6 bytes 8b8da8010000)
# → `xor ecx,ecx; nop*4` (31c9 + 90909090) = 6 bytes. Forces 6th=0 for that use.
pe=make_b0_h2c(bytearray(base),secs)
o=rva2off(pe,secs,0x46a507)
assert bytes(pe[o:o+6])==bytes.fromhex("8b8da8010000")
pe[o:o+6]=bytes.fromhex("31c990909090")  # xor ecx,ecx; nop*4
# Also need other 1a8 reads — patch all to xor or to 1a0
# For other sites, patch disp 1a8→1a0 still, but first is xor
sites=collect_disp_sites(pe,secs,0x46a4db,0x46af66-0x46a4db,0x1a8)
P(f"  remaining 1a8 after xor-first: {[hex(s) for s in sites]}")
for s in sites:
    patch_disp(pe,secs,s,0x1a8,0x1a0)
gate(save(pe,"host_46_z6th.exe"),"z6th")

# F) body bisect: hollow at successive call sites inside 46
P("\n=== F bisect hollow points in 46 under b0_h2c ===")
# After each major call returns, try hollow to epi
points=[
    (0x46a525,"after_1fe04d"),  # after first call
    (0x46a549,"after_1fe07b"),
    (0x46a774,"after_1fb198"),  # @46a76f call return
    (0x46af58,"before_epi"),    # mov eax,0 already at epi-ish
]
for rva,name in points:
    pe=make_b0_h2c(bytearray(base),secs)
    # need 7 bytes at rva for xor+jmp
    hollow_at(pe,secs,rva)
    gate(save(pe,f"host_46_h_{name}.exe"),f"h_{name}")

# G) b0_h2c + nop the call @46a76f (the post-locus call)
P("\n=== G b0_h2c + skip call@46a76f (xor eax;nop*3) ===")
pe=make_b0_h2c(bytearray(base),secs)
o=rva2off(pe,secs,0x46a76f)
assert pe[o]==0xE8
pe[o:o+5]=bytes.fromhex("31c0909090")
gate(save(pe,"host_46_skip76f.exe"),"skip76f")
for rva,name in [(0x46a774,"aft76f"),(0x46af5d,"add_rsp"),(0x46af65,"ret1"),(0x57674b,"after_46")]:
    int3_pair(pe,secs,rva,name)

# H) Capless write 6th: steal bytes from cmp/jcc after store_2c path — too far.
# Try overwrite at 57673f window with shorter encoding:
# mov [rsp+0x20], ecx (4); mov [rsp+0x28], ecx (4) — same value for 5th and 6th; mov rcx,rax (3); but call needs 5 → 16 > 12
# mov [rsp+0x20],ecx (4); push rcx; mov [rsp+0x30],ecx; pop rcx — mess.
# Use dig: patch Capless `mov dword [rsp+0x20],ecx` to also cover via 
# `mov qword [rsp+0x20], rcx` zero-extending — still one slot.
P("\n=== H Capless widen: mov qword [rsp+0x20], rcx (zeros upper=6th half?) ===")
# 894c2420 is mov dword. rcx has pointer in high — bad.
# mov qword [rsp+0x20], 0 = 48c744242000000000 (9 bytes) — kills 5th too.

# I) Confirm: does let need 46 body? hollow zeros it — let still OK means tests don't need 46 work.
P("\n=== I INT3 path under b0h2c_hollow ===")
pe=make_b0_h2c(bytearray(base),secs); hollow_at(pe,secs,0x46a4e3)
for rva,name in [(0x57674b,"after_46"),(0x5767a0,"call_493"),(0x5767a5,"aft_493"),
                 (0x5767fa,"call_49c"),(0x578278,"cap_epi"),(0x123781,"caller")]:
    int3_pair(pe,secs,rva,name)

P(f"\nelapsed={time.time()-T0:.1f}s")
for pat in ["_t508_*","_d508_*"]:
    for p in cave.glob(pat):
        try: p.unlink()
        except: pass
P("cleaned")
