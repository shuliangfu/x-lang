"""DIG Capless→SoftCap lit emit wire v2: enc_prologue / compute_frame / tip@121278.
Base alt_frame2 9378df517f96. Budget<=85s. Ban join/epi / LIVE transplant / arg-loop.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64)

cave = Path("C:/xlang_tmp/p1060/cave")
os.chdir(str(cave))
T0=time.time(); BUDGET=85

def pe_secs(buf):
    e=struct.unpack_from("<I",buf,0x3C)[0]
    nsec=struct.unpack_from("<H",buf,e+6)[0]
    opt=struct.unpack_from("<H",buf,e+20)[0]
    sec=e+24+opt; out={}
    for i in range(nsec):
        o=sec+i*40
        n=bytes(buf[o:o+8]).split(b"\0")[0]
        vs,va,rs,ro=struct.unpack_from("<IIII",buf,o+8)
        out[n]=(va,vs,ro,rs)
    return out

def rva2off(buf,secs,r):
    for n,(va,vs,ro,rs) in secs.items():
        if va<=r<va+max(vs,rs):
            return ro+(r-va)
    raise ValueError(hex(r))

def off2rva(secs,off):
    for n,(va,vs,ro,rs) in secs.items():
        if ro<=off<ro+max(rs,1):
            return va+(off-ro)
    # fallback: any section with file size
    for n,(va,vs,ro,rs) in secs.items():
        if ro<=off<ro+rs+0x1000:
            return va+(off-ro)
    return None

def dump(buf,secs,rva,n=0x50,label=""):
    try:
        o=rva2off(buf,secs,rva)
    except Exception as e:
        print(f"  dump fail @{rva:#x}: {e}", flush=True); return
    print(f"--- {label} @{rva:06x} ---", flush=True)
    for insn in md.disasm(bytes(buf[o:o+n]), rva):
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)

def find_all(buf,pat):
    out=[]; i=0
    while True:
        j=buf.find(pat,i)
        if j<0: break
        out.append(j); i=j+1
    return out

def text_range(secs):
    for k,v in secs.items():
        kn=k.decode() if isinstance(k,bytes) else k
        if kn==".text": return v
    return None

def e8_callers(buf,secs,target,limit=20):
    t=text_range(secs)
    if not t: return []
    va,vs,ro,rs=t
    callers=[]; i=ro; end=ro+rs-5
    while i<=end and len(callers)<limit:
        if buf[i]==0xE8:
            rel=struct.unpack_from("<i",buf,i+1)[0]
            src=va+(i-ro)
            if src+5+rel==target:
                callers.append(src)
        i+=1
    return callers

def lea_xrefs_to(buf,secs,target,limit=8):
    t=text_range(secs)
    if not t: return []
    va,vs,ro,rs=t
    hits=[]; i=ro; end=ro+rs-7
    while i<=end and len(hits)<limit:
        if buf[i]==0x48 and buf[i+1]==0x8D and (buf[i+2]&0xC7)==0x05:
            disp=struct.unpack_from("<i",buf,i+3)[0]
            src=va+(i-ro)
            if src+7+disp==target:
                hits.append(src)
        i+=1
    return hits

def plant_int3(baseb,rvas,label):
    pe2=bytearray(baseb); s=pe_secs(pe2)
    for rva in rvas:
        pe2[rva2off(pe2,s,rva)]=0xCC
    out=cave/f"_dig_host_lw_{label}.exe"
    out.write_bytes(pe2); return out

def run_host(h,src="p_ret_lit.x",timeout=8):
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
    sh=hashlib.sha256(b).hexdigest()[:12] if b else "-"
    return tag,sh,len(b),b

def clean():
    for p in list(cave.glob("_dig_host_lw_*.exe"))+list(cave.glob("_tmp__dig_host_lw_*")):
        try: p.unlink()
        except Exception: pass

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)
print("base ok", flush=True)

# tip@121278 caller context (known sole E8 @1215b9)
print("\n=== tip@121278 + caller @1215b9 ===", flush=True)
dump(base,secs,0x121278,0x50,"tip")
dump(base,secs,0x121580,0x60,"caller@1215b9-ctx")
print("E8->121278", [hex(c) for c in e8_callers(base,secs,0x121278)], flush=True)

# strings + xrefs
print("\n=== enc_prologue / compute_frame strings + lea xrefs ===", flush=True)
str_map={}
for nd in [b"enc_prologue", b"compute_frame_size", b"arch_x86_64_enc_enc_prologue", b"pipeline_asm_compute_frame_size"]:
    offs=find_all(bytes(base),nd)
    print(f"  {nd.decode(errors='replace')}: {len(offs)}", flush=True)
    for o in offs[:4]:
        r=off2rva(secs,o)
        print(f"    off={o:#x} rva={r and hex(r)}", flush=True)
        if r is not None:
            str_map[nd]=str_map.get(nd,[])+[r]

# Prefer longest unique strings
for nd, rvas in list(str_map.items()):
    for r in rvas[:2]:
        if time.time()-T0>40: break
        xrefs=lea_xrefs_to(base,secs,r,limit=6)
        print(f"  lea→{nd.decode()}@{r:#x}: {[hex(x) for x in xrefs]}", flush=True)
        for x in xrefs[:2]:
            dump(base,secs,x-0x18,0x50,f"lea@{x:06x}")

# Also search exact prior DIG string RVAs if present
print("\n=== prior DIG string RVAs @dcd2d9 / @658417 ===", flush=True)
for rva in [0xdcd2d9, 0x658417]:
    try:
        o=rva2off(base,secs,rva)
        ctx=bytes(base[o:o+48])
        print(f"  @{rva:#x}: {ctx!r}", flush=True)
    except Exception as e:
        print(f"  @{rva:#x}: missing ({e})", flush=True)

# SoftCap flag + tip Capless call
print("\n=== SoftCap flag + tip kind0x30 Capless call ===", flush=True)
dump(base,secs,0x1cf074,0x50,"sc_flag")
dump(base,secs,0x123740,0x60,"tip_call")

# Capless FN vs nearby frame-size helpers: search mov eax,0x68 near Capless emit
print("\n=== Capless@57656c + mov eax,0x68 sites near emit helpers ===", flush=True)
dump(base,secs,0x57656c,0x30,"capless")
# find functions that both have enc-related and load 0x68
pat_eax68=b"\xb8\x68\x00\x00\x00"
pat_eax1b8=b"\xb8\xb8\x01\x00\x00"
pat_eax868=b"\xb8\x68\x08\x00\x00"
for pat,name in [(pat_eax68,"eax=0x68"),(pat_eax1b8,"eax=0x1b8"),(pat_eax868,"eax=0x868")]:
    offs=find_all(bytes(base),pat)
    rvas=[]
    for o in offs:
        r=off2rva(secs,o)
        if r is not None:
            rvas.append(r)
    print(f"  mov {name}: n={len(rvas)} sample={[hex(x) for x in rvas[:8]]}", flush=True)

# INT3 reachability under alt_frame2 lit
print("\n=== INT3 frontier lit ===", flush=True)
sites=[
    (0x121278,"tip121278"),
    (0x1215b9,"e8_tip"),
    (0x12377c,"tip_e8_capless"),
    (0x57656c,"capless"),
    (0x1cf0a6,"sc_jne"),
    (0x1cf074,"sc_flag"),
]
# add first lea xref sites if found
extra=[]
for nd,rvas in str_map.items():
    for r in rvas[:1]:
        for x in lea_xrefs_to(base,secs,r,limit=2)[:1]:
            extra.append((x, f"xref_{nd.decode()[:8]}"))
sites=sites+extra[:4]

for rva,name in sites:
    if time.time()-T0>BUDGET-10:
        print("BUDGET", flush=True); break
    t1=time.time()
    tag,sh,sz,_=run_host(plant_int3(base,[rva],name),timeout=5)
    mark=" HIT" if tag=="INT3" else (" **AV**" if tag=="AV" else (" **GS**" if tag=="GS" else (" TIMEOUT" if tag=="TIMEOUT" else f" {tag}")))
    print(f"  @{rva:06x} {name:20s} -> {tag:8s}{mark} ({time.time()-t1:.1f}s)", flush=True)

# baseline frames
pat868=b"\x48\x81\xec"+struct.pack("<I",0x868)
pat68=b"\x48\x81\xec"+struct.pack("<I",0x68)
pat1b8=b"\x48\x81\xec"+struct.pack("<I",0x1b8)
tag,sh,sz,b=run_host(cave/"xlang_isol1060_alt_frame2.exe","p_ret_lit.x",timeout=8)
print(f"\nbaseline lit: {tag} sha={sh} 868={pat868 in b} 68={pat68 in b} 1b8={pat1b8 in b}", flush=True)

# tip_scfull already known crc=0x1 — confirm still
if (cave/"xlang_isol1060_tip_scfull.exe").exists() and time.time()-T0<BUDGET:
    tag,sh,sz,b=run_host(cave/"xlang_isol1060_tip_scfull.exe","p_ret_lit.x",timeout=8)
    print(f"tip_scfull lit: {tag} sha={sh} 868={pat868 in b if b else False}", flush=True)

print(f"\nelapsed={time.time()-T0:.1f}s DONE", flush=True)
clean()
print("PROD/pin untouched", flush=True)
