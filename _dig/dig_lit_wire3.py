"""DIG lit_wire3: callers of @21b5fa; enc_prologue lea@dcd2d9; Capless frame path.
Budget<=85s. Ban join/epi / transplant / arg-loop.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md=Cs(CS_ARCH_X86, CS_MODE_64)

cave=Path("C:/xlang_tmp/p1060/cave"); os.chdir(str(cave))
T0=time.time(); BUDGET=85

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
def dump(buf,secs,rva,n=0x40,label=""):
    o=rva2off(buf,secs,rva)
    print(f"--- {label} @{rva:06x} ---", flush=True)
    for insn in md.disasm(bytes(buf[o:o+n]),rva):
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)
def text_sec(secs):
    for k,v in secs.items():
        kn=k.decode() if isinstance(k,bytes) else k
        if kn==".text": return v
    return None
def e8_callers(buf,secs,target,limit=40):
    t=text_sec(secs); va,vs,ro,rs=t
    out=[]; i=ro; end=ro+rs-5
    while i<=end and len(out)<limit:
        if buf[i]==0xE8:
            rel=struct.unpack_from("<i",buf,i+1)[0]
            src=va+(i-ro)
            if src+5+rel==target: out.append(src)
        i+=1
    return out
def lea_xrefs(buf,secs,target,limit=12):
    t=text_sec(secs); va,vs,ro,rs=t
    out=[]; i=ro; end=ro+rs-7
    while i<=end and len(out)<limit:
        if buf[i]==0x48 and buf[i+1]==0x8D and (buf[i+2]&0xC7)==0x05:
            disp=struct.unpack_from("<i",buf,i+3)[0]
            src=va+(i-ro)
            if src+7+disp==target: out.append(src)
        i+=1
    return out
def plant_int3(baseb,rvas,label):
    pe2=bytearray(baseb); s=pe_secs(pe2)
    for rva in rvas: pe2[rva2off(pe2,s,rva)]=0xCC
    out=cave/f"_dig_host_lw3_{label}.exe"; out.write_bytes(pe2); return out
def run_host(h,src="p_ret_lit.x",timeout=5):
    out=cave/f"_tmp_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except Exception: pass
    try:
        r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout)
        crc=r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT","-",0,b""
    tag={0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc,f"crc={crc:#x}")
    b=out.read_bytes() if out.exists() else b""
    return tag, hashlib.sha256(b).hexdigest()[:12] if b else "-", len(b), b
def clean():
    for p in list(cave.glob("_dig_host_lw3_*.exe"))+list(cave.glob("_tmp__dig_host_lw3_*")):
        try: p.unlink()
        except Exception: pass

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)
print("base ok", flush=True)

print("\n=== @21b5fa prologue + E8 callers ===", flush=True)
dump(base,secs,0x21b5fa,0x40,"21b5fa")
callers=e8_callers(base,secs,0x21b5fa,limit=50)
print(f"E8 callers n={len(callers)}: {[hex(c) for c in callers[:20]]}", flush=True)
# Is 1212aa among them?
print(f"  from tip@1212aa? {0x1212aa in callers}", flush=True)

print("\n=== enc_prologue str @dcd2d9 lea xrefs ===", flush=True)
xrefs=lea_xrefs(base,secs,0xdcd2d9,limit=12)
print(f"lea→enc_prologue: {[hex(x) for x in xrefs]}", flush=True)
for x in xrefs[:3]:
    dump(base,secs,x-0x20,0x50,f"enc_xref@{x:06x}")

print("\n=== arch_x86_64_enc_enc_prologue str — find exact ===", flush=True)
# find full name
idx=bytes(base).find(b"arch_x86_64_enc_enc_prologue")
print(f"full name off={idx:#x}" if idx>=0 else "missing", flush=True)
# use known @dcd2d9 - also search lea to nearby unique
# INT3 enc xrefs + a few @21b5fa callers that look SoftCap-ish
print("\n=== INT3 enc_prologue xrefs + select 21b5fa callers ===", flush=True)
sites=[(x,f"enc_{x:x}") for x in xrefs[:4]]
# SoftCap-ish callers: tip 1212aa, and any in 0x12xxxx / 0x50xxxx / Capless-adjacent
for c in callers:
    if c in (0x1212aa,) or (0x120000<=c<=0x130000) or (0x50f000<=c<=0x510000) or (0x1e0000<=c<=0x1f0000):
        sites.append((c,f"c21_{c:x}"))
# also first 5 callers for reachability sample
for c in callers[:6]:
    sites.append((c,f"c_{c:x}"))
# dedupe
seen=set(); usites=[]
for r,n in sites:
    if r in seen: continue
    seen.add(r); usites.append((r,n))

hits=[]
for rva,name in usites:
    if time.time()-T0>BUDGET-15: break
    tag,_,_,_=run_host(plant_int3(base,[rva],name),timeout=4)
    mark=" HIT" if tag=="INT3" else (" **AV**" if tag=="AV" else (" TIMEOUT" if tag=="TIMEOUT" else f" {tag}"))
    print(f"  @{rva:06x} {name:16s} -> {tag}{mark}", flush=True)
    if tag=="INT3": hits.append(rva)

print(f"HIT sites: {[hex(h) for h in hits]}", flush=True)

# Capless post-success: look for call enc inside Capless @57656c body — search E8 targets named?
# Disasm Capless for calls to enc-ish: scan first 0x200 bytes of Capless for E8
print("\n=== Capless@57656c early E8 targets ===", flush=True)
o=rva2off(base,secs,0x57656c)
for insn in md.disasm(bytes(base[o:o+0x120]),0x57656c):
    if insn.mnemonic=="call":
        print(f"  @{insn.address:06x}: call {insn.op_str}", flush=True)

# tip SoftCap-full @50f8a0 (prior tip_sc50f → TT thin)
print("\n=== SoftCap-full @50f8a0 head ===", flush=True)
dump(base,secs,0x50f8a0,0x30,"scfull50f")

print(f"\nelapsed={time.time()-T0:.1f}s", flush=True)
clean()
print("PROD/pin untouched", flush=True)
