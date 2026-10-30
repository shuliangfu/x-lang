"""DIG: precise edx feed into prol call@52364b; FN body; Capless link.
Budget<=60s.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64); md.detail=True

cave = Path("C:/xlang_tmp/p1060/cave"); os.chdir(str(cave))
T0=time.time(); BUDGET=60
PROL=0x50f3e0

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

def dump_from(buf,secs,rva,n=0x100,label=""):
    o=rva2off(buf,secs,rva)
    print(f"--- {label} @{rva:06x} ---", flush=True)
    for insn in md.disasm(bytes(buf[o:o+n]), rva):
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)

def e8_callers(buf,secs,target,limit=40):
    e=struct.unpack_from("<I",buf,0x3C)[0]
    # use .text only
    for n,(va,vs,ro,rs) in secs.items():
        kn=n.decode() if isinstance(n,bytes) else n
        if kn!=".text": continue
        out=[]; i=ro; end=ro+rs-5
        while i<=end and len(out)<limit:
            if buf[i]==0xE8:
                rel=struct.unpack_from("<i",buf,i+1)[0]
                src=va+(i-ro)
                if src+5+rel==target: out.append(src)
            i+=1
        return out
    return []

def plant(baseb,rvas,label):
    pe2=bytearray(baseb); s=pe_secs(pe2)
    for r in rvas: pe2[rva2off(pe2,s,r)]=0xCC
    out=cave/f"_dig_host_fuf_{label}.exe"; out.write_bytes(pe2); return out

def run(h,src="p_ret_lit.x",timeout=5):
    out=cave/f"_tmp_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except: pass
    try:
        r=subprocess.run([str(h),str(cave/src),"-o",str(out)],capture_output=True,timeout=timeout)
        crc=r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT","-",b""
    tag={0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc,f"crc={crc:#x}")
    b=out.read_bytes() if out.exists() else b""
    sh=hashlib.sha256(b).hexdigest()[:12] if b else "-"
    return tag,sh,b

def clean():
    for p in list(cave.glob("_dig_host_fuf_*.exe"))+list(cave.glob("_tmp__dig_host_fuf_*")):
        try: p.unlink()
        except: pass

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
secs=pe_secs(base)

# Linear sweep decode from several candidate starts near 523600
print("=== linear sweep to find aligned decode reaching call@52364b ===", flush=True)
call=0x52364b
for start in range(call-0x80, call-0x10, 1):
    o=rva2off(base,secs,start)
    ok=False; last=None
    for insn in md.disasm(bytes(base[o:o+0xa0]), start):
        if insn.address==call and insn.mnemonic=="call":
            ok=True; break
        if insn.address>call: break
        last=insn
    if ok:
        print(f"  aligned start @{start:06x}", flush=True)
        dump_from(base,secs,start, n=call-start+8, label=f"aligned_{start:06x}")
        break

# Also dump both call sites with start = call-0x30 trying every offset until call decodes as call
print("\n=== edx/rcx setup immediately before calls ===", flush=True)
for c in e8_callers(base,secs,PROL):
    found=False
    for back in range(0x8, 0x50):
        start=c-back
        o=rva2off(base,secs,start)
        insns=list(md.disasm(bytes(base[o:o+back+8]), start))
        # check last insn before/at call
        if any(i.address==c and i.mnemonic=="call" for i in insns):
            print(f"\n  call@{c:06x} window from @{start:06x}:", flush=True)
            for i in insns:
                if i.address>c+5: break
                print(f"    @{i.address:06x}: {i.mnemonic} {i.op_str}", flush=True)
            found=True
            break
    if not found:
        print(f"  call@{c:06x}: no aligned window", flush=True)
        # raw bytes
        o=rva2off(base,secs,c-0x20)
        print(f"    raw {(c-0x20):06x}: {bytes(base[o:o+0x28]).hex()}", flush=True)

# Who calls the FN containing @52364b? Find push rbp by scanning with alignment
print("\n=== find FN containing @52364b ===", flush=True)
# search backwards for 55 48 89 E5
o_call=rva2off(base,secs,call)
for back in range(0, 0x400):
    o=o_call-back
    if o<0: break
    if base[o]==0x55 and base[o+1:o+4]==bytes([0x48,0x89,0xE5]):
        fe = call-back  # wait, need RVA
        # convert
        for n,(va,vs,ro,rs) in secs.items():
            kn=n.decode() if isinstance(n,bytes) else n
            if kn==".text" and ro<=o<ro+rs:
                fe=va+(o-ro)
                print(f"  prol candidate @{fe:06x} (back={back})", flush=True)
                dump_from(base,secs,fe, n=min(0x150, back+0x30), label=f"fn_{fe:06x}")
                # E8 callers of this FN
                cs=e8_callers(base,secs,fe,limit=20)
                print(f"  E8 callers of FN: {list(map(hex,cs))}", flush=True)
                for cc in cs[:6]:
                    # INT3 later
                    pass
                break
        break

# INT3: prol, call@52364b (known HIT), FN entry, and any mov edx,imm in FN body for 0x68/0x1b8
print("\n=== scan FN body for size imms / edx loads ===", flush=True)
# re-find fe
fe=None
for back in range(0,0x400):
    o=o_call-back
    if o>=0 and base[o]==0x55 and base[o+1:o+4]==bytes([0x48,0x89,0xE5]):
        for n,(va,vs,ro,rs) in secs.items():
            kn=n.decode() if isinstance(n,bytes) else n
            if kn==".text" and ro<=o<ro+rs:
                fe=va+(o-ro); break
        break
print(f"  fe={fe and hex(fe)}", flush=True)

sites=[(PROL,"prol"), (0x52364b,"e8_prol")]
if fe:
    sites.append((fe,"cfn"))
    # scan for mov edx/eax, imm sizes in FN
    o=rva2off(base,secs,fe)
    for insn in md.disasm(bytes(base[o:o+0x200]), fe):
        if "edx" in insn.op_str or (insn.mnemonic.startswith("mov") and "eax" in insn.op_str):
            op=insn.op_str.lower()
            if any(f"0x{x:x}" in op for x in (0x68,0x1b8,0x868,0x40,0x28,0x20)):
                print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)
                sites.append((insn.address, f"imm_{insn.address:06x}"))

hits=[]
for rva,name in sites:
    if time.time()-T0>BUDGET-10: break
    t1=time.time()
    tag,sh,b=run(plant(base,[rva],name),timeout=5)
    mark=" HIT" if tag=="INT3" else (f" **{tag}**" if tag in("AV","GS","TIMEOUT") else "")
    if tag=="INT3": hits.append((rva,name))
    print(f"  @{rva:06x} {name:24s} -> {tag}{mark} ({time.time()-t1:.1f}s)", flush=True)

print(f"HITs: {[(hex(r),n) for r,n in hits]}", flush=True)
print(f"elapsed={time.time()-T0:.1f}s DONE", flush=True)
clean()
