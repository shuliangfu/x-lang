"""DIG follow-up: Capless epi HIT @578278 post-success → who encodes frame; @521f10 miss path; enc callers.
Budget<=70s. Ban tip@121278/join/epi/LIVE.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md=Cs(CS_ARCH_X86, CS_MODE_64)
cave=Path("C:/xlang_tmp/p1060/cave"); os.chdir(str(cave))
T0=time.time(); BUDGET=70

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
def off2rva(secs,off):
    for n,(va,vs,ro,rs) in secs.items():
        if ro<=off<ro+max(rs,1): return va+(off-ro)
    return None
def text_range(secs):
    for k,v in secs.items():
        kn=k.decode() if isinstance(k,bytes) else k
        if kn==".text": return v
    return None
def dump(buf,secs,rva,n=0x60,label=""):
    o=rva2off(buf,secs,rva)
    print(f"--- {label} @{rva:06x} ---", flush=True)
    for insn in md.disasm(bytes(buf[o:o+n]),rva):
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)
def e8_callers(buf,secs,target,limit=25):
    t=text_range(secs)
    if not t: return []
    va,vs,ro,rs=t; callers=[]; i=ro; end=ro+rs-5
    while i<=end and len(callers)<limit:
        if buf[i]==0xE8:
            rel=struct.unpack_from("<i",buf,i+1)[0]
            src=va+(i-ro)
            if src+5+rel==target: callers.append(src)
        i+=1
    return callers
def find_all(buf,pat):
    out=[]; i=0
    while True:
        j=buf.find(pat,i)
        if j<0: break
        out.append(j); i=j+1
    return out
def plant(baseb,rvas,label):
    pe2=bytearray(baseb); s=pe_secs(pe2)
    for rva in rvas: pe2[rva2off(pe2,s,rva)]=0xCC
    out=cave/f"_dig_host_psb_{label}.exe"; out.write_bytes(pe2); return out
def run(h,timeout=5):
    out=cave/f"_tmp_{h.stem}_lit.exe"
    if out.exists():
        try: out.unlink()
        except Exception: pass
    try:
        r=subprocess.run([str(h),str(cave/"p_ret_lit.x"),"-o",str(out)],capture_output=True,timeout=timeout)
        crc=r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT","-",b""
    tag={0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc,f"crc={crc:#x}")
    b=out.read_bytes() if out.exists() else b""
    return tag, hashlib.sha256(b).hexdigest()[:12] if b else "-", b
def clean():
    for p in list(cave.glob("_dig_host_psb_*.exe"))+list(cave.glob("_tmp__dig_host_psb_*")):
        try: p.unlink()
        except Exception: pass

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)

# Capless epi HIT region + walk back for frame teardown / success eax
print("=== Capless epi @578278 context (HIT) ===", flush=True)
dump(base,secs,0x578250,0x80,"capless_epi")
# find add rsp before epi
o0=rva2off(base,secs,0x57656c)
for off in range(0x1c00,0x1d00):
    at=o0+off
    if base[at]==0x48 and base[at+1]==0x81 and base[at+2]==0xC4:
        imm=struct.unpack_from("<I",base,at+3)[0]
        print(f"  add rsp @{0x57656c+off:#x} imm={imm:#x}", flush=True)
        dump(base,secs,0x57656c+off-0x20,0x50,f"add_rsp")

# Capless success: before epi, mov eax,?
print("\n=== Capless pre-epi success eax (scan back 0x80) ===", flush=True)
dump(base,secs,0x578200,0x80,"pre_epi")

# Post Capless tip path @127212 — does it touch frame/enc?
print("\n=== tip Capless-success land @127212 ===", flush=True)
dump(base,secs,0x127212,0x60,"tip_post_cl_succ")

# Miss-path helper @521f10 (Capless eax==0 at @126cda/@1d9d0e)
print("\n=== Capless-miss helper @521f10 + callers ===", flush=True)
dump(base,secs,0x521f10,0x50,"h521f10")
print("E8→521f10", [hex(c) for c in e8_callers(base,secs,0x521f10)], flush=True)
dump(base,secs,0x521d78,0x40,"h521d78")
dump(base,secs,0x524944,0x40,"h524944")

# Who emits USER thin 0x68? Search for encoding of sub rsp,0x68 as data template
# Pattern often: push imm / or mov r32,0x68 then call enc
# Find call sites that pass 0x68 near Capless FN body calls
print("\n=== Capless FN E8 callees that might be enc (sample first 40 unique) ===", flush=True)
# scan Capless body for E8
callees=set(); i=o0; end=o0+0x1d00
while i<end-5:
    if base[i]==0xE8:
        rel=struct.unpack_from("<i",base,i+1)[0]
        src=0x57656c+(i-o0)
        tgt=src+5+rel
        callees.add(tgt)
    i+=1
print(f"  unique E8 targets in Capless body: n={len(callees)}", flush=True)
# Filter targets whose prol has sub rsp with small OR that contain mov eax,0x68 nearby
interesting=[]
for t in sorted(callees):
    try:
        oo=rva2off(base,secs,t)
    except Exception:
        continue
    prol=bytes(base[oo:oo+0x30])
    # look for frame-related or enc-ish
    if b"\xb8\x68\x00\x00\x00" in bytes(base[oo:oo+0x200]) or b"\xb8\xb8\x01\x00\x00" in bytes(base[oo:oo+0x200]):
        interesting.append(t)
    if b"\x48\x81\xec" in prol[:20]:
        imm=None
        for j in range(min(20,len(prol)-7)):
            if prol[j:j+3]==b"\x48\x81\xec":
                imm=struct.unpack_from("<I",prol,j+3)[0]; break
        if imm in (0x68,0x1b8,0x868,0xa8,0x28,0x48):
            interesting.append(t)
print(f"  enc-ish callees: {[hex(x) for x in interesting[:20]]}", flush=True)
for t in interesting[:8]:
    dump(base,secs,t,0x40,f"cl_callee@{t:06x}")

# INT3: Capless epi neighbors, tip post-success, miss helpers, enc-ish
print("\n=== INT3 post-success wire sites ===", flush=True)
sites=[
    (0x578278,"cl_epi"),
    (0x578270,"cl_pre_epi"),
    (0x578200,"cl_pre80"),
    (0x127212,"tip_post_succ"),
    (0x521f10,"miss_521f10"),
    (0x521d78,"miss_521d78"),
    (0x524944,"miss_524944"),
    (0x1cd1e5,"miss_1cd1e5"),
]
# add interesting callees
for t in interesting[:6]:
    sites.append((t,f"clc_{t:06x}"))
# Capless-band 0x1b8
for o in find_all(bytes(base), b"\xb8\xb8\x01\x00\x00"):
    r=off2rva(secs,o)
    if r and 0x500000<=r<0x5a0000:
        sites.append((r,f"eax1b8_{r:06x}"))
sites=sites[:18]

hits=[]
for rva,name in sites:
    if time.time()-T0>BUDGET-8:
        print("BUDGET", flush=True); break
    t1=time.time()
    tag,sh,b=run(plant(base,[rva],name),timeout=5)
    mark=""
    if tag=="INT3": mark=" HIT"; hits.append((rva,name))
    elif tag=="TIMEOUT": mark=" TIMEOUT"
    elif tag in ("AV","GS"): mark=f" **{tag}**"
    print(f"  @{rva:06x} {name:20s} -> {tag:8s}{mark} ({time.time()-t1:.1f}s)", flush=True)

print(f"\nHITs: {[(hex(a),n) for a,n in hits]}", flush=True)

# Dump HIT sites context for wire conclusion
for rva,name in hits:
    dump(base,secs,rva-0x18,0x50,f"HIT_{name}")

# Does Capless body itself contain mov eax,0x68?
print("\n=== mov eax,0x68/0x1b8 INSIDE Capless FN body ===", flush=True)
body=bytes(base[o0:o0+0x1d00])
for imm,pat in [(0x68,b"\xb8\x68\x00\x00\x00"),(0x1b8,b"\xb8\xb8\x01\x00\x00"),(0x868,b"\xb8\x68\x08\x00\x00")]:
    locs=[0x57656c+j for j in find_all(body,pat)]
    print(f"  mov eax,{imm:#x} in Capless: {[hex(x) for x in locs]}", flush=True)
    for r in locs[:3]:
        dump(base,secs,r-0x10,0x40,f"cl_imm@{r:06x}")

print(f"elapsed={time.time()-T0:.1f}s DONE", flush=True)
clean()
