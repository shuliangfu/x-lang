"""Isol-VV: UU (CapFN mid→mega SoftCap size plant) + Capless SoftCap mode force.
CapFN SoftCap size path is gated by mode ([rbp+0x990]==1 ← Capless [rbp+0x4b0]).
Force Capless [rbp+0x4b0]=1 via entry trampoline so CapFN takes SoftCap size/spill.
Minimal; no mega/whole-tree.
"""
from pathlib import Path
import struct, hashlib, subprocess, time, os
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

CAVE_DIR = Path(r"C:/xlang_tmp/p1060/cave")
os.chdir(CAVE_DIR)

# Prefer UU if present; else rebuild from TT via importing plant logic inline
UU = Path("xlang_isol1060_UU.exe")
TT = Path("xlang_isol1060_TT.exe")
assert TT.exists()
if UU.exists() and hashlib.sha256(UU.read_bytes()).hexdigest()[:12] == "54ed284b17dc":
    pe = bytearray(UU.read_bytes())
    print("base Isol-UU 54ed284b17dc")
else:
    raise SystemExit("run build_isol_uu.py first")

def pe_secs(buf):
    e = struct.unpack_from("<I", buf, 0x3C)[0]
    nsec = struct.unpack_from("<H", buf, e+6)[0]
    opt = struct.unpack_from("<H", buf, e+20)[0]
    sec = e+24+opt
    out = {}
    for i in range(nsec):
        o = sec+i*40
        n = bytes(buf[o:o+8]).split(b"\0")[0]
        vs,va,rs,ro = struct.unpack_from("<IIII", buf, o+8)
        out[n] = (va, vs, ro, rs)
    return out

def rva2off(buf, secs, r):
    for n,(va,vs,ro,rs) in secs.items():
        if va <= r < va + max(vs,rs):
            return ro + (r - va)
    raise ValueError(hex(r))

Isec = pe_secs(pe)
Iva = Isec[b".text"][0]

CAPLESS = 0x57656c
# Capless prol16: push rbp; sub rsp,0x500; lea rbp,[rsp+0x80]
prol16 = bytes.fromhex("554881ec00050000488dac2480000000")
assert len(prol16)==16
coff = rva2off(pe, Isec, CAPLESS)
assert pe[coff:coff+16] == prol16, pe[coff:coff+16].hex()

# Cave after UU plant end 0x116e2e → align 16
CAVE = (0x116e30 + 15) & ~15  # 0x116e30
# ensure INT3
assert pe[rva2off(pe,Isec,CAVE):rva2off(pe,Isec,CAVE)+8] == b"\xcc"*8

# Trampoline body at CAVE:
#   push rbp
#   sub rsp, 0x500
#   lea rbp, [rsp+0x80]
#   mov dword [rbp+0x4b0], 1
#   jmp CAPLESS+14
tramp = bytearray()
tramp += bytes.fromhex("554881ec00050000488dac2480000000")  # original 16B
tramp += bytes.fromhex("c785b004000001000000")  # mov dword [rbp+0x4b0], 1
back = CAPLESS + 16
jmp_from = CAVE + len(tramp)
tramp += bytes([0xE9]) + struct.pack("<i", back - (jmp_from + 5))

t_off = rva2off(pe, Isec, CAVE)
pe[t_off:t_off+len(tramp)] = tramp
print(f"tramp @{CAVE:#x} size={len(tramp):#x} back={back:#x}")

# Patch Capless entry → jmp CAVE
pe[coff:coff+5] = bytes([0xE9]) + struct.pack("<i", CAVE - (CAPLESS + 5))
pe[coff+5:coff+16] = b"\x90"*11
got = CAPLESS + 5 + struct.unpack_from("<i", pe, coff+1)[0]
assert got == CAVE
print(f"Capless entry jmp -> {got:#x}")

# Keep UU plants
assert pe[rva2off(pe,Isec,0x513861):rva2off(pe,Isec,0x513861)+3]==bytes.fromhex("4889d8")
assert pe[rva2off(pe,Isec,0x1169a0)]==0x55  # planted SoftCap size

out = Path("xlang_isol1060_VV.exe")
out.write_bytes(pe)
sha = hashlib.sha256(pe).hexdigest()
print("Isol-VV", sha[:12], "size", len(pe))

outdir = Path("out_vv"); outdir.mkdir(exist_ok=True)
LIVE_sha = "dbaab1c7ce70"

def find(name):
    for root in [Path(r"C:/xlang_tmp/p1060"), Path(r"C:/Users/shuliangfu/worker/xlang/x-lang/tests")]:
        if not root.exists(): continue
        for dp, _, fs in os.walk(root):
            if name in fs:
                return str(Path(dp)/name)
    return None

results = {}
for label, fname in [("p_ret_lit","p_ret_lit.x"),("p_ret_fwd","p_ret_fwd.x"),("p_ret_local","p_ret_local.x")]:
    src = find(fname)
    if not src:
        results[label] = dict(err="SRC_MISSING"); print(label, "SRC_MISSING"); continue
    dst = str((outdir/(label+".exe")).resolve())
    t0 = time.time()
    try:
        r = subprocess.run([str(out.resolve()), src, "-o", dst], capture_output=True, timeout=180)
    except subprocess.TimeoutExpired:
        results[label] = dict(err="COMPILE_TIMEOUT"); print(label, "TIMEOUT"); continue
    rec = dict(crc=r.returncode & 0xFFFFFFFF, dt=round(time.time()-t0,2))
    err = (r.stderr or b"").decode("utf-8","replace")[-500:]
    if err: rec["stderr_tail"]=err
    if r.returncode==0 and Path(dst).exists() and Path(dst).stat().st_size>0:
        raw = Path(dst).read_bytes()
        h = hashlib.sha256(raw).hexdigest()[:12]
        rec["sha"]=h
        if label=="p_ret_lit": rec["match_live"]=(h==LIVE_sha)
        rec["n_sub_0x868"] = raw.count(bytes.fromhex("4881ec68080000"))
        rec["n_sub_0x878"] = raw.count(bytes.fromhex("4881ec78080000"))
        rec["n_sub_0x68"] = raw.count(bytes.fromhex("4883ec68"))
        rec["n_sub_0x1b8"] = raw.count(bytes.fromhex("4881ecb8010000"))
        # call-mk
        try:
            e = struct.unpack_from("<I", raw, 0x3C)[0]
            nsec = struct.unpack_from("<H", raw, e+6)[0]
            opt = struct.unpack_from("<H", raw, e+20)[0]
            sec = e+24+opt
            tva=tro=None
            for i in range(nsec):
                o=sec+i*40
                if bytes(raw[o:o+5]).startswith(b".text"):
                    tva,_,_,tro=struct.unpack_from("<IIII", raw, o+8); break
            text=raw[tro:tro+0x800]
            calls=[]
            for i in range(len(text)-5):
                if text[i]==0xE8:
                    srcva=tva+i
                    dest=(srcva+5+struct.unpack_from("<i",text,i+1)[0])&0xffffffff
                    if dest==0x1490 and 0x14f0 <= srcva <= 0x1600:
                        calls.append(srcva)
            rec["main_call_mk"]=calls
        except Exception as ex:
            rec["main_call_mk"]=f"err:{ex}"
        try:
            rr = subprocess.run([dst], capture_output=True, timeout=30)
            rec["run_crc"]=rr.returncode & 0xFFFFFFFF
            rec["run_out"]=(rr.stdout or b"").decode("utf-8","replace")[:200]
        except subprocess.TimeoutExpired:
            rec["run_crc"]="TIMEOUT"
        except OSError as e:
            rec["run_crc"]=f"OSErr:{e}"
    else:
        rec["compile_fail"]=True
    results[label]=rec
    print(label, rec)

Path("isol_vv_log.txt").write_text(
    "Isol-VV = UU + Capless SoftCap mode-force trampoline ([rbp+0x4b0]=1)\nsha12=%s\ncave=%s\nresults=%s\n"%(
        sha[:12], hex(CAVE), results),
    encoding="utf-8")
print("DONE", sha[:12])
