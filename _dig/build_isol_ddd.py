"""Isol-DDD: Capless CapFN SoftCap @576b71 + CapFN=0 @576b7b → h_emit @578184.

Tip CallExpr kind=48 → Capless (not SoftCap twin 0x31). Capless SoftCap CapFN SoftCap
early-out OR CapFN=0 SoftCap Capless paths return 0 before CALL/h_emit; CALL helpers
may early-success without emit. Force SoftCap Capless CallExpr to Capless h_emit.
"""
from pathlib import Path
import struct, hashlib, subprocess, os, time
CAVE_DIR = Path(r"C:/xlang_tmp/p1060/cave")
cands = [CAVE_DIR/"xlang_isol1060_TT.exe", Path("/tmp/p1060_dig/bins/xlang_isol1060_TT.exe")]
TT = next(p for p in cands if p.exists())
if CAVE_DIR.exists(): os.chdir(CAVE_DIR)
pe = bytearray(TT.read_bytes())
assert hashlib.sha256(pe).hexdigest()[:12]=="1f836615e0fc"
def pe_secs(buf):
    e=struct.unpack_from("<I",buf,0x3C)[0]; nsec=struct.unpack_from("<H",buf,e+6)[0]; opt=struct.unpack_from("<H",buf,e+20)[0]
    sec=e+24+opt; out={}
    for i in range(nsec):
        o=sec+i*40; n=bytes(buf[o:o+8]).split(b"\0")[0]
        vs,va,rs,ro=struct.unpack_from("<IIII",buf,o+8); out[n]=(va,vs,ro,rs)
    return out
def rva2off(buf,secs,r):
    for n,(va,vs,ro,rs) in secs.items():
        if va<=r<va+max(vs,rs): return ro+(r-va)
    raise ValueError(hex(r))
Isec=pe_secs(pe)
HEMIT=0x578184
off=rva2off(pe,Isec,0x576b71)
assert pe[off:off+10]==bytes.fromhex("b800000000e9fd160000")
pe[off:off+10]=bytes([0xE9])+struct.pack("<i",HEMIT-(0x576b71+5))+b"\x90"*5
off=rva2off(pe,Isec,0x576b7b)
assert pe[off:off+7]==bytes.fromhex("83bd5c0400002c")
pe[off:off+7]=bytes([0xE9])+struct.pack("<i",HEMIT-(0x576b7b+5))+b"\x90"*2
out_name="xlang_isol1060_DDD.exe"
out=(CAVE_DIR/out_name) if CAVE_DIR.exists() else Path("/tmp/p1060_dig/bins")/out_name
out.write_bytes(pe)
sha=hashlib.sha256(pe).hexdigest()
print("Isol-DDD", sha[:12], "Capless CapFN SoftCap/CapFN=0→h_emit")
Path("/tmp/p1060_dig/bins").mkdir(parents=True, exist_ok=True)
(Path("/tmp/p1060_dig/bins")/out_name).write_bytes(pe)
if not CAVE_DIR.exists():
    print("no Win cave — plant only"); raise SystemExit(0)
outdir=Path("out_ddd"); outdir.mkdir(exist_ok=True)
def find(name):
    p=Path(r"C:/xlang_tmp/p1060")/name
    return str(p) if p.exists() else None
for label,fname in [("p_ret_lit","p_ret_lit.x"),("p_ret_fwd","p_ret_fwd.x"),("p_ret_local","p_ret_local.x")]:
    src=find(fname); dst=str((outdir/(label+".exe")).resolve()); rec={"src":src}
    if not src: print(label,{"fail":"missing"}); continue
    t0=time.time()
    r=subprocess.run([str(out.resolve()),src,"-o",dst],capture_output=True,timeout=180)
    rec["crc"]=r.returncode&0xffffffff; rec["dt"]=round(time.time()-t0,2)
    if r.returncode==0 and Path(dst).exists():
        raw=Path(dst).read_bytes()
        rec["sha"]=hashlib.sha256(raw).hexdigest()[:12]
        rec["n868"]=raw.count(bytes.fromhex("4881ec68080000"))
        rec["n878"]=raw.count(bytes.fromhex("4881ec78080000"))
        rec["n1b8"]=raw.count(bytes.fromhex("4881ecb8010000"))
        rec["ba0a"]=raw.count(bytes.fromhex("ba0a000000"))
        try: rec["run"]=subprocess.run([dst],capture_output=True,timeout=30).returncode&0xffffffff
        except Exception as e: rec["run"]=str(e)
    else:
        rec["fail"]=True; rec["err"]=(r.stderr or b"")[-400:]
    print(label, rec)
print("DONE", sha[:12])
