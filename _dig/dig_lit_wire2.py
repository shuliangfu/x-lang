"""DIG lit_wire follow-up: on-path thin frame imm + enc_868 plant candidate.
Base alt_frame2. Budget<=85s. Ban join/epi / LIVE transplant / arg-loop.
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
def off2rva(secs,off):
    for n,(va,vs,ro,rs) in secs.items():
        if ro<=off<ro+rs: return va+(off-ro)
    return None
def dump(buf,secs,rva,n=0x40,label=""):
    o=rva2off(buf,secs,rva)
    print(f"--- {label} @{rva:06x} ---", flush=True)
    for insn in md.disasm(bytes(buf[o:o+n]),rva):
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)
def find_all(buf,pat):
    out=[]; i=0
    while True:
        j=buf.find(pat,i)
        if j<0: break
        out.append(j); i=j+1
    return out
def plant_int3(baseb,rvas,label):
    pe2=bytearray(baseb); s=pe_secs(pe2)
    for rva in rvas: pe2[rva2off(pe2,s,rva)]=0xCC
    out=cave/f"_dig_host_lw2_{label}.exe"; out.write_bytes(pe2); return out
def run_host(h,src="p_ret_lit.x",timeout=6):
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
    for p in list(cave.glob("_dig_host_lw2_*.exe"))+list(cave.glob("_tmp__dig_host_lw2_*")):
        try: p.unlink()
        except Exception: pass

clean()
base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12]=="9378df517f96"
secs=pe_secs(base)

# Fix caller @1215b9 true insn
print("=== disasm around @1215b0 ===", flush=True)
dump(base,secs,0x1215a0,0x40,"near1215b9")

# tip kind0x31 SoftMega path (next after 0x30)
print("\n=== tip kind0x31 after Capless ===", flush=True)
dump(base,secs,0x12378c,0x50,"kind31")

# INT3 thin-frame imm sites: pick plausible codegen ones (avoid random early)
# From sample: focus on higher RVAs that may be emit helpers near Capless era
candidates=[]
for imm,pat in [(0x68,b"\xb8\x68\x00\x00\x00"),(0x1b8,b"\xb8\xb8\x01\x00\x00")]:
    for o in find_all(bytes(base),pat):
        r=off2rva(secs,o)
        if r is None: continue
        # prefer .text high / mid codegen band used before: 0x1e0000-0x250000 or near 0x4xxxx emit
        if 0x180000 <= r <= 0x250000 or 0x40000 <= r <= 0x60000 or 0x520000 <= r <= 0x580000:
            candidates.append((r,imm))

print(f"candidate imm sites filtered={len(candidates)}", flush=True)
# INT3 sample up to ~12 sites
print("\n=== INT3 mov eax,imm thin-frame (lit) ===", flush=True)
hits=[]
seen=set()
for rva,imm in candidates:
    if rva in seen: continue
    seen.add(rva)
    if len(hits)+len([1 for _ in hits])>0 and time.time()-T0>BUDGET-25: break
    if len(seen)>40: break
    # only probe a spaced sample
    if len(seen) % 3 != 1: continue
    if time.time()-T0>BUDGET-25: break
    tag,sh,sz,_=run_host(plant_int3(base,[rva],f"i{rva:x}"),timeout=4)
    mark=" HIT" if tag=="INT3" else ""
    if tag=="INT3":
        hits.append((rva,imm))
        print(f"  @{rva:06x} imm={imm:#x} -> INT3 HIT", flush=True)
        dump(base,secs,rva-0x10,0x30,f"HIT@{rva:06x}")
    elif tag not in ("OK","AV","GS","TIMEOUT") or tag=="TIMEOUT":
        print(f"  @{rva:06x} imm={imm:#x} -> {tag}", flush=True)

print(f"thin-imm INT3 HITs: {[(hex(a),hex(b)) for a,b in hits]}", flush=True)

# Also INT3 tip kind gate @12374a cmp 0x30 and kind31 call
print("\n=== INT3 tip kind gates ===", flush=True)
for rva,name in [(0x12374a,"cmp30"),(0x123751,"jne30"),(0x12378c,"cmp31"),(0x123793,"jne31"),
                 (0x12377c,"call_capless"),(0x21b5fa,"tip_callee")]:
    if time.time()-T0>BUDGET-12: break
    tag,_,_,_=run_host(plant_int3(base,[rva],name),timeout=4)
    mark=" HIT" if tag=="INT3" else (" **AV**" if tag=="AV" else (" TIMEOUT" if tag=="TIMEOUT" else f" {tag}"))
    print(f"  @{rva:06x} {name:14s} -> {tag}{mark}", flush=True)

# Semantic plant enc_868: if we found on-path mov eax,0x68 for mk-like, patch to 0x868
print("\n=== plant enc_868 attempt ===", flush=True)
# Prefer HIT sites with imm 0x68; else known thin emit uses 0x68 at mk - search emit of baseline for pattern origin is host-side
# Strategy: patch ALL mov eax,0x68 in a narrow Capless-adjacent band? Too broad.
# Narrow: patch HIT 0x68 sites only.
pe=bytearray(base)
npatch=0
for rva,imm in hits:
    if imm!=0x68: continue
    o=rva2off(pe,secs,rva)
    assert pe[o]==0xB8 and struct.unpack_from("<I",pe,o+1)[0]==0x68
    struct.pack_into("<I",pe,o+1,0x868)
    npatch+=1
    print(f"  patch @{rva:06x} mov eax,0x68 -> 0x868", flush=True)

if npatch==0:
    # fallback semantic: force tip kind0x30 Capless call to stay but after Capless success
    # cannot invent SoftCap body. Instead document no isolatable HIT.
    print("  no HIT 0x68 site to patch; try single known compute-adjacent?", flush=True)
    # From prior: arch enc uses passed frame_sz. Find call sites to a function that encodes sub rsp,imm
    # Look for template bytes emission of 48 81 ec — encoder writing those bytes
    # Search for push of opcode pattern: C7 05 or mov of 0xec8148
    # Pattern: often enc emits byte-by-byte. Look for 0x81 / 0xEC immediates near enc_prologue xref dcd2d9
    # Skip mega; report gap.
else:
    sha=hashlib.sha256(pe).hexdigest()
    print(f"Isol-enc_868 sha12={sha[:12]} patches={npatch}", flush=True)
    host=cave/"xlang_isol1060_enc_868.exe"; host.write_bytes(pe)
    pat868=b"\x48\x81\xec"+struct.pack("<I",0x868)
    pat68=b"\x48\x81\xec"+struct.pack("<I",0x68)
    for src in ["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x"]:
        if time.time()-T0>BUDGET: break
        tag,sh,sz,b=run_host(host,src,timeout=8)
        has868=pat868 in b if b else False
        has68=pat68 in b if b else False
        run_tag="-"
        if tag=="OK" and b:
            outp=cave/f"_tmp_{host.stem}_{Path(src).stem}.exe"
            try:
                rr=subprocess.run([str(outp)],capture_output=True,timeout=5); run_tag=f"rc={rr.returncode}"
            except subprocess.TimeoutExpired: run_tag="RUN_TIMEOUT"
            except Exception: run_tag="run_err"
        print(f"  {src:16s} compile={tag:8s} sha={sh} 868={has868} 68={has68} run={run_tag}", flush=True)

print(f"\nelapsed={time.time()-T0:.1f}s DONE", flush=True)
clean()
print("PROD/pin untouched", flush=True)
