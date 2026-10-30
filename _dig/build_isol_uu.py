"""Isol-UU: Capless→SoftCap CapFN mid→mega retarget via LIVE SoftCap size-helper cave plant.
From Isol-TT (SS Capless remaps + LEA opcode plant). Plants LIVE SoftCap helpers that CapFN
calls via CapFNΔ into mega mid-insn; retarget CapFN 5× E8. Minimal; no mega/whole-tree.
"""
from pathlib import Path
import struct, hashlib, subprocess, time, os, json

CAVE_DIR = Path(r"C:/xlang_tmp/p1060/cave")
os.chdir(CAVE_DIR)

TT = Path("xlang_isol1060_TT.exe")
pe = bytearray(TT.read_bytes())
assert hashlib.sha256(pe).hexdigest()[:12] == "1f836615e0fc", hashlib.sha256(pe).hexdigest()[:12]

# Also need LIVE host for helper bodies
LIVE = None
for cand in [Path(r"C:/xlang_tmp/p1060/cave/lab_LIVE_pret.exe"),
             Path(r"C:/xlang_tmp/p1060/lab_LIVE_pret.exe"),
             Path(r"C:/xlang_tmp/p1060/bins/lab_LIVE_pret.exe"),
             Path(r"C:/Users/shuliangfu/worker/xlang/x-lang/compiler/lab_LIVE_pret.exe")]:
    if cand.exists():
        LIVE = cand; break
# search
if LIVE is None:
    for root,ds,fs in os.walk(r"C:/xlang_tmp/p1060"):
        if "lab_LIVE_pret.exe" in fs:
            LIVE = Path(root)/"lab_LIVE_pret.exe"; break
assert LIVE is not None, "LIVE pret missing"
live = bytearray(LIVE.read_bytes())
print("LIVE", hashlib.sha256(live).hexdigest()[:12], LIVE)

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

Isec = pe_secs(pe); Lsec = pe_secs(live)
Iva,_,_,Iro = Isec[b".text"]; Lva,_,_,Lro = Lsec[b".text"]

def rva2off(buf, secs, r):
    for n,(va,vs,ro,rs) in secs.items():
        if va <= r < va + max(vs,rs):
            return ro + (r - va)
    raise ValueError(hex(r))

def body_size(buf, secs, fn, limit=0x800):
    va = secs[b".text"][0]
    ro = secs[b".text"][2]
    off = ro + (fn - va)
    # tiny leaves (gt16/units/class) ret within <0x20; start at 0xc
    for i in range(0xc, limit):
        if buf[off+i]==0xC3 and 0x5D in bytes(buf[off+max(0,i-8):off+i]):
            return i+1
    raise ValueError(hex(fn))

PLANT_LIVE = [0x29b965, 0x298759, 0x298688, 0x298627, 0x281df8, 0x281e13, 0x281dca]
sizes = {la: body_size(live, Lsec, la) for la in PLANT_LIVE}
CAVE = 0x116998
cursor = CAVE
layout = {}
for la in PLANT_LIVE:
    cursor = (cursor + 15) & ~15
    layout[la] = cursor
    cursor += sizes[la]
print("layout", {hex(k):hex(v) for k,v in layout.items()}, "end", hex(cursor))

# Ensure cave is INT3
coff = rva2off(pe, Isec, CAVE)
assert pe[coff:coff+16] == b"\xcc"*16, pe[coff:coff+16].hex()

# L2I map: CapFN valid + known + planted
L2I = {
    0x76fe3: 0x1ff2a3,
    0x281a20: 0x55d948,
    0x281e48: 0x5603b8,
    0x29bc53: 0x5aaf18,
    0x48f8e: 0x1d1b37,
    0x78d22: 0x200ff7,
    0x84fc2: 0x20cd98,
    0x243aaf: 0x4dac80,
}
L2I.update(layout)

# verify mapped Isol targets have push rbp (except we accept planted)
for ld,id_ in list(L2I.items()):
    if ld in layout: continue
    io = rva2off(pe, Isec, id_)
    assert pe[io]==0x55, (hex(ld), hex(id_), hex(pe[io]))

def patch_e8_bytes(body, live_rva, plant_rva, L2I):
    """Decode CALL E8s at LIVE RVA (true callees), rewrite displ for plant RVA."""
    from capstone import Cs, CS_ARCH_X86, CS_MODE_64
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    nfix = 0
    for insn in md.disasm(bytes(body), live_rva):
        if insn.mnemonic != "call" or not insn.op_str.startswith("0x"):
            continue
        if insn.bytes[0] != 0xE8:
            continue
        live_dest = int(insn.op_str, 16)
        off = insn.address - live_rva
        if live_dest not in L2I:
            raise KeyError(f"unmapped callee LIVE@{live_dest:#x} from LIVE@{live_rva:#x}+{off:#x}")
        new_dest = L2I[live_dest]
        plant_src = plant_rva + off
        body[off:off+5] = bytes([0xE8]) + struct.pack("<i", new_dest - (plant_src + 5))
        nfix += 1
    return nfix

# Plant each helper
total_fix = 0
for la in PLANT_LIVE:
    l_off = rva2off(live, Lsec, la)
    body = bytearray(live[l_off:l_off+sizes[la]])
    dest_rva = layout[la]
    nfix = patch_e8_bytes(body, la, dest_rva, L2I)
    total_fix += nfix
    d_off = rva2off(pe, Isec, dest_rva)
    assert pe[d_off:d_off+8] == b"\xcc"*8
    pe[d_off:d_off+len(body)] = body
    assert pe[d_off]==0x55
    print(f"  plant LIVE@{la:#x} -> Isol@{dest_rva:#x} size={sizes[la]:#x} e8fix={nfix}")

print("total e8fix", total_fix)

def patch_e8(src, new_dest, expect_old=None):
    off = rva2off(pe, Isec, src)
    assert pe[off]==0xE8
    old = src + 5 + struct.unpack_from("<i", pe, off+1)[0]
    if expect_old is not None:
        assert old == expect_old, (hex(src), hex(old), hex(expect_old))
    pe[off:off+5] = bytes([0xE8]) + struct.pack("<i", new_dest - (src + 5))
    got = src + 5 + struct.unpack_from("<i", pe, off+1)[0]
    assert got == new_dest
    print(f"  CapFN E8 {src:#x}: {old:#x} -> {got:#x}")

print("=== CapFN mega retarget 5x ===")
mega = [
    (0x575471, 0x5895d5, layout[0x29b965]),
    (0x57598f, 0x5863c9, layout[0x298759]),
    (0x5759ba, 0x5862f8, layout[0x298688]),
    (0x5760c2, 0x5862f8, layout[0x298688]),
    (0x5760fb, 0x5863c9, layout[0x298759]),
]
for src, old, new in mega:
    patch_e8(src, new, expect_old=old)

# Keep TT LEA plants
assert pe[rva2off(pe,Isec,0x513861):rva2off(pe,Isec,0x513861)+3]==bytes.fromhex("4889d8")
assert pe[rva2off(pe,Isec,0x514a0d):rva2off(pe,Isec,0x514a0d)+3]==bytes.fromhex("488b00")
assert pe[rva2off(pe,Isec,0x57656c):rva2off(pe,Isec,0x57656c)+4]==bytes.fromhex("554881ec")

out = Path("xlang_isol1060_UU.exe")
out.write_bytes(pe)
sha = hashlib.sha256(pe).hexdigest()
print("Isol-UU", sha[:12], "size", len(pe))

outdir = Path("out_uu"); outdir.mkdir(exist_ok=True)
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
        rec["n_488b00"] = raw.count(bytes.fromhex("488b00"))
        rec["n_4889d8"] = raw.count(bytes.fromhex("4889d8"))
        # call-mk heuristic: E8 to mk@0x1490 from main region
        # scan for call rel to 0x1490 near VA 0x14f8..0x1600
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
                    src=tva+i
                    dest=(src+5+struct.unpack_from("<i",text,i+1)[0])&0xffffffff
                    if dest==0x1490 and 0x14f0 <= src <= 0x1600:
                        calls.append(src)
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

Path("isol_uu_log.txt").write_text(
    "Isol-UU = TT + CapFN mid->mega LIVE SoftCap size-helper cave plant\nsha12=%s\nlayout=%s\nresults=%s\n"%(
        sha[:12], {hex(k):hex(v) for k,v in layout.items()}, results),
    encoding="utf-8")
print("DONE", sha[:12])
