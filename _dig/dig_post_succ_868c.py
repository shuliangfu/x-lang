"""DIG Capless last-call @57b98c + USER thin-frame enc origin. Budget<=60s. Ban tip@121278/join/epi/LIVE."""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md=Cs(CS_ARCH_X86, CS_MODE_64)
cave=Path("C:/xlang_tmp/p1060/cave"); os.chdir(str(cave))
T0=time.time(); BUDGET=55

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
def dump(buf,secs,rva,n=0x50,label=""):
    o=rva2off(buf,secs,rva)
    print(f"--- {label} @{rva:06x} ---", flush=True)
    for insn in md.disasm(bytes(buf[o:o+n]),rva):
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)
def e8_callers(buf,secs,target,limit=20):
    t=text_range(secs)
    if not t: return []
    va,vs,ro,rs=t; out=[]; i=ro; end=ro+rs-5
    while i<=end and len(out)<limit:
        if buf[i]==0xE8:
            rel=struct.unpack_from("<i",buf,i+1)[0]
            src=va+(i-ro)
            if src+5+rel==target: out.append(src)
        i+=1
    return out
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
    out=cave/f"_dig_host_psc_{label}.exe"; out.write_bytes(pe2); return out
def run(h,timeout=5):
    out=cave/f"_tmp_{h.stem}_lit.exe"
    if out.exists():
        try: out.unlink()
        except Exception: pass
    try:
        r=subprocess.run([str(h),str(cave/"p_ret_lit.x"),"-o",str(out)],capture_output=True,timeout=timeout)
        crc=r.returncode&0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT"
    return {0x80000003:"INT3",0xC0000005:"AV",0xC0000409:"GS",0:"OK"}.get(crc,f"crc={crc:#x}")
def clean():
    for p in list(cave.glob("_dig_host_psc_*.exe"))+list(cave.glob("_tmp__dig_host_psc_*")):
        try: p.unlink()
        except Exception: pass

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)

print("=== Capless last-call @57b98c ===", flush=True)
dump(base,secs,0x57b98c,0x60,"fn57b98c")
print("E8→57b98c", [hex(c) for c in e8_callers(base,secs,0x57b98c)], flush=True)
# prol frame?
o=rva2off(base,secs,0x57b98c)
print(f"  bytes: {bytes(base[o:o+16]).hex()}", flush=True)

# Search Capless body for E8 to known enc-ish / compute_frame / mov_imm writers
# Prior: mov_imm_w @53ff24, arch_E8 @5264bc, E8enc @51a534, @57464c post_args
print("\n=== Capless body calls to known emit helpers? ===", flush=True)
known={0x53ff24:"mov_imm_w",0x5264bc:"arch_E8",0x51a534:"E8enc",0x57464c:"post_args",
       0x5752bc:"CapFN",0x522c0c:"CE",0x55ab88:"clc68a",0x57b98c:"last",
       0x567a30:"pre_last",0x1ffefe:"early_cl"}
o0=rva2off(base,secs,0x57656c)
hits_call=[]
i=o0; end=o0+0x1d00
while i<end-5:
    if base[i]==0xE8:
        rel=struct.unpack_from("<i",base,i+1)[0]
        src=0x57656c+(i-o0); tgt=src+5+rel
        if tgt in known:
            hits_call.append((src,tgt,known[tgt]))
    i+=1
print(f"  known calls: {[(hex(a),hex(b),n) for a,b,n in hits_call]}", flush=True)

# USER emit: find where host writes bytes 48 81 EC 68 00 00 00 into output buffer
# Often: mov dword [rdi], 0x68EC8148 or piecemeal. Search imm32 0x00000068 near enc byte writers
# Search for "sub rsp" encoding constants as immediate stores: C7 07 / C7 00 with 0x68
print("\n=== template imm stores of 0x68 / 0x1b8 / 0x868 (C7 mov-dword) band ===", flush=True)
# C7 xx imm32 — too many; look for EC 68 00 00 00 (modrm of sub rsp form as data)
for imm,name in [(0x68,"68"),(0x1b8,"1b8"),(0x868,"868")]:
    # bytes of "81 EC xx xx xx xx" as potential template in .rdata/.text
    pat=b"\x81\xec"+struct.pack("<I",imm)
    offs=find_all(bytes(base),pat)
    rvas=[off2rva(secs,o) for o in offs]
    rvas=[r for r in rvas if r]
    print(f"  template 81 EC {name}: n={len(rvas)} sample={[hex(x) for x in rvas[:8]]}", flush=True)

# INT3 last call + pre_last + tip post + softmega confirm
print("\n=== INT3 last-call / pre_last / kind31 ===", flush=True)
sites=[(0x57b98c,"last57b98c"),(0x578273,"call_last"),(0x567a30,"pre567a30"),
       (0x57820f,"call_pre"),(0x123781,"tip_store_eax"),(0x123787,"tip_jmp_post")]
for rva,name in sites:
    if time.time()-T0>BUDGET-5: break
    t1=time.time(); tag=run(plant(base,[rva],name),timeout=5)
    mark=" HIT" if tag=="INT3" else (" TIMEOUT" if tag=="TIMEOUT" else (f" **{tag}**" if tag in ("AV","GS") else f" {tag}"))
    print(f"  @{rva:06x} {name:16s} -> {tag}{mark} ({time.time()-t1:.1f}s)", flush=True)

print(f"elapsed={time.time()-T0:.1f}s DONE", flush=True)
clean()
