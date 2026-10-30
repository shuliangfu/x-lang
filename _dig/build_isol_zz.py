"""Isol-ZZ: Capless CapFN SoftCap early-out → CALL fallthrough when kind==3 + YY SoftCap-full→Capless.

True SoftCap CallExpr early-out (non-@56d014):
  Capless CapFN SoftCap success @576b71 mov eax,0; jmp exit — skips CALL kind=3 @577c24.
  SoftCap twin→SoftMega→SoftCap-full also lacks CALL kind=3 (YY retargets to Capless).

Minimal: cave stub at @116998; retarget @576b71→stub (kind==3 → @576b7b else success);
plus SoftMega bridge @59ab11 SoftCap-full→Capless.
"""
from pathlib import Path
import struct, hashlib, subprocess, os, time

CAVE_DIR = Path(r"C:/xlang_tmp/p1060/cave")
cands = [CAVE_DIR/"xlang_isol1060_TT.exe", Path("/tmp/p1060_dig/bins/xlang_isol1060_TT.exe")]
TT = next(p for p in cands if p.exists())
if CAVE_DIR.exists():
    os.chdir(CAVE_DIR)
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

# YY: SoftMega SoftCap-full → Capless
SITE_YY, NEW_CAP = 0x59ab11, 0x57656c
off=rva2off(pe,Isec,SITE_YY)
pe[off:off+5]=bytes([0xE8])+struct.pack("<i", NEW_CAP-(SITE_YY+5))

SITE_EO, JMP, EXIT, CALL_PATH = 0x576b71, 0x576b76, 0x578278, 0x576b7b
CAVE=0x116998
coff=rva2off(pe,Isec,CAVE)
assert pe[coff:coff+16]==b"\xcc"*16
stub=CAVE
code=bytearray()
code += bytes([0x83,0xBD,0x5C,0x04,0x00,0x00,0x03])  # cmp [rbp+0x45c],3
jne_pos=len(code); code += bytes([0x0F,0x85,0,0,0,0])
jmp_call_pos=len(code); code += bytes([0xE9,0,0,0,0])
success_off=len(code); code += bytes([0xB8,0,0,0,0])
jmp_exit_pos=len(code); code += bytes([0xE9,0,0,0,0])

def patch_rel32(buf, pos, insn_len, target_rva, stub_rva):
    src=stub_rva+pos
    struct.pack_into("<i", buf, pos+insn_len-4, target_rva-(src+insn_len))

patch_rel32(code, jne_pos, 6, stub+success_off, stub)
patch_rel32(code, jmp_call_pos, 5, CALL_PATH, stub)
patch_rel32(code, jmp_exit_pos, 5, EXIT, stub)
pe[coff:coff+len(code)]=code

off=rva2off(pe,Isec,SITE_EO)
pe[off:off+10]=bytes([0xE9])+struct.pack("<i", stub-(SITE_EO+5))+b"\x90"*5

out_name="xlang_isol1060_ZZ.exe"
out=(CAVE_DIR/out_name) if CAVE_DIR.exists() else Path("/tmp/p1060_dig/bins")/out_name
out.write_bytes(pe)
sha=hashlib.sha256(pe).hexdigest()
print("Isol-ZZ", sha[:12], "YY+CapFN SoftCap CALL fallthrough")

if not CAVE_DIR.exists():
    print("no Win cave — plant only"); raise SystemExit(0)

outdir=Path("out_zz"); outdir.mkdir(exist_ok=True)
def find(name):
    for root in [Path(r"C:/xlang_tmp/p1060"), Path(r"C:/Users/shuliangfu/worker/xlang/x-lang/tests/probes/p_big_struct")]:
        p=root/name
        if p.exists(): return str(p)
    return None
for label,fname in [("p_ret_lit","p_ret_lit.x"),("p_ret_fwd","p_ret_fwd.x"),("p_ret_local","p_ret_local.x")]:
    src=find(fname); dst=str((outdir/(label+".exe")).resolve()); rec={"src":src}
    if not src: print(label,{"fail":"missing"}); continue
    r=subprocess.run([str(out.resolve()),src,"-o",dst],capture_output=True,timeout=180)
    rec["crc"]=r.returncode&0xffffffff
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
