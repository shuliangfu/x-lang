"""Isol-WW quick: TT + force SoftCap twin (0x31) branch by NOPing jne after cmp 0x31."""
from pathlib import Path
import struct, hashlib, subprocess, time, os
os.chdir(r"C:/xlang_tmp/p1060/cave")
pe=bytearray(Path("xlang_isol1060_TT.exe").read_bytes())
assert hashlib.sha256(pe).hexdigest()[:12]=="1f836615e0fc"

def pe_secs(buf):
    e=struct.unpack_from("<I",buf,0x3C)[0]
    nsec=struct.unpack_from("<H",buf,e+6)[0]
    opt=struct.unpack_from("<H",buf,e+20)[0]
    sec=e+24+opt
    out={}
    for i in range(nsec):
        o=sec+i*40
        n=bytes(buf[o:o+8]).split(b"\0")[0]
        vs,va,rs,ro=struct.unpack_from("<IIII",buf,o+8)
        out[n]=(va,vs,ro,rs)
    return out
def rva2off(buf,secs,r):
    for n,(va,vs,ro,rs) in secs.items():
        if va<=r<va+max(vs,rs): return ro+(r-va)
    raise ValueError(hex(r))
Isec=pe_secs(pe)
# cmp [rbp-0x2c],0x31 ; jne <capless>  at known sites — NOP the jne (2B)
sites=[0x1d9a45,0x1d9c47,0x1d9cc1]  # dispatch sites that call Capless on jne
# Also SoftCap host wrappers at 0x123751 cmp 0x30?
for site in sites:
    off=rva2off(pe,Isec,site)
    assert pe[off:off+4]==bytes([0x83,0x7d,0xd4,0x31]), (hex(site),pe[off:off+4].hex())
    # next insn should be jne rel8
    assert pe[off+4] in (0x75,0x0f), hex(pe[off+4])
    if pe[off+4]==0x75:
        print(f"NOP jne @{site+4:#x} was 75 {pe[off+5]:02x}")
        pe[off+4]=0x90; pe[off+5]=0x90
    else:
        print(f"skip long jne @{site:#x}")

out=Path("xlang_isol1060_WW.exe")
out.write_bytes(pe)
sha=hashlib.sha256(pe).hexdigest()
print("Isol-WW",sha[:12])
outdir=Path("out_ww"); outdir.mkdir(exist_ok=True)
def find(name):
    for root in [Path(r"C:/xlang_tmp/p1060"), Path(r"C:/Users/shuliangfu/worker/xlang/x-lang/tests")]:
        if not root.exists(): continue
        for dp,_,fs in os.walk(root):
            if name in fs: return str(Path(dp)/name)
    return None
for label,fname in [("p_ret_lit","p_ret_lit.x")]:
    src=find(fname); dst=str((outdir/(label+".exe")).resolve())
    r=subprocess.run([str(out.resolve()),src,"-o",dst],capture_output=True,timeout=180)
    rec=dict(crc=r.returncode&0xffffffff)
    if r.returncode==0 and Path(dst).exists():
        raw=Path(dst).read_bytes()
        rec["sha"]=hashlib.sha256(raw).hexdigest()[:12]
        rec["n868"]=raw.count(bytes.fromhex("4881ec68080000"))
        rec["n878"]=raw.count(bytes.fromhex("4881ec78080000"))
        rec["n1b8"]=raw.count(bytes.fromhex("4881ecb8010000"))
        try:
            rr=subprocess.run([dst],capture_output=True,timeout=30)
            rec["run"]=rr.returncode&0xffffffff
        except Exception as e:
            rec["run"]=str(e)
    else:
        rec["fail"]=True
        rec["err"]=(r.stderr or b"")[-300:]
    print(label,rec)
print("DONE")
