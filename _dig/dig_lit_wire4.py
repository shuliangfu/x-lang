"""DIG lit_wire4: dump HIT SoftCap sibling callers @1203ae..; confirm vs tip@121278 off-path.
Budget<=60s.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md=Cs(CS_ARCH_X86, CS_MODE_64)
cave=Path("C:/xlang_tmp/p1060/cave"); os.chdir(str(cave))
T0=time.time()

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
def dump(buf,secs,rva,n=0x50,label=""):
    o=rva2off(buf,secs,rva)
    print(f"--- {label} @{rva:06x} ---", flush=True)
    for insn in md.disasm(bytes(buf[o:o+n]),rva):
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)

base=bytearray((cave/"xlang_isol1060_alt_frame2.exe").read_bytes())
secs=pe_secs(base)
# find function starts: walk back for push rbp; sub rsp,0x868 pattern near each HIT caller
hits=[0x1203ae,0x1204eb,0x1205a5,0x12063b,0x1206d1,0x120a40]
for c in hits:
    # scan back up to 0x80 for push rbp
    o=rva2off(base,secs,c)
    start=c
    for back in range(0,0xa0):
        at=c-back
        try:
            oo=rva2off(base,secs,at)
        except Exception:
            break
        if base[oo]==0x55:  # push rbp
            start=at; break
    dump(base,secs,start,0x55,f"fn_of_caller@{c:06x}_start@{start:06x}")
    # check if this fn has sub rsp,0x868
    chunk=bytes(base[rva2off(base,secs,start):rva2off(base,secs,start)+0x20])
    has868=b"\x48\x81\xec\x68\x08\x00\x00" in chunk or b"\x48\x81\xec"+struct.pack("<I",0x868) in bytes(base[rva2off(base,secs,start):rva2off(base,secs,start)+0x40])
    print(f"  host_frame_0x868_near_prol={has868}", flush=True)

# Compare tip@121278 off-path vs SoftCap flag again quickly
print("\n=== confirm tip@121278 OK / SoftCap flag OK / Capless TIMEOUT ===", flush=True)

def plant(rva,label):
    pe2=bytearray(base); pe2[rva2off(pe2,secs,rva)]=0xCC
    out=cave/f"_dig_host_lw4_{label}.exe"; out.write_bytes(pe2); return out
def run(h,timeout=4):
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

for rva,name in [(0x121278,"tip"),(0x1212aa,"tip_call"),(0x1cf0a6,"sc_jne"),(0x57656c,"capless"),(0x12374a,"cmp30")]:
    print(f"  @{rva:06x} {name}: {run(plant(rva,name))}", flush=True)

# cleanup
for p in list(cave.glob("_dig_host_lw4_*.exe"))+list(cave.glob("_tmp__dig_host_lw4_*")):
    try: p.unlink()
    except Exception: pass
print(f"elapsed={time.time()-T0:.1f}s DONE", flush=True)
