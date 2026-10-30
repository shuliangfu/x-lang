"""Isol-TT: Isol-SS remaps + single-point LEA opcode-blob plant for mov_rbx/load_64.
DIG: Isol SoftCap thin encoders @0x513828/@0x5149d4 use frozen RIP displ (same as LIVE
0xfc472/0xfbede) that land in .text mid-insn (e90000/a8feff) because Isol layout
diverged; LIVE lands in .rdata 4889d8/488b00. Capless BFS reaches both at depth 2.
Plant: write correct 3B into INT3 cave immediately after each thin ret; retarget LEA disp=0x18.
No mega / no whole-tree / PAIR stub kept.
"""
from pathlib import Path
import struct, hashlib, subprocess, time, os

CAVE = Path(r"C:/xlang_tmp/p1060/cave")
os.chdir(CAVE)

G = Path("xlang_isol1060_G.exe")
pe = bytearray(G.read_bytes())
assert hashlib.sha256(pe).hexdigest()[:12] == "7701dac5b813", hashlib.sha256(pe).hexdigest()[:12]

coff = struct.unpack_from("<I", pe, 0x3C)[0]
nsec = struct.unpack_from("<H", pe, coff + 6)[0]
opt = struct.unpack_from("<H", pe, coff + 20)[0]
sec = coff + 24 + opt
sections = {}
for i in range(nsec):
    o = sec + i * 40
    n = bytes(pe[o:o+8]).split(b"\0")[0]
    vs, va, rs, ro = struct.unpack_from("<IIII", pe, o + 8)
    sections[n] = (va, vs, ro, rs)

def rva2off(r):
    for n, (va, vs, ro, rs) in sections.items():
        if va <= r < va + max(vs, rs):
            return ro + (r - va)
    raise ValueError(hex(r))

def patch_e8(src, new_dest, expect_old=None):
    off = rva2off(src)
    assert pe[off] == 0xE8, (hex(src), hex(pe[off]))
    old = src + 5 + struct.unpack_from("<i", pe, off + 1)[0]
    if expect_old is not None:
        assert old == expect_old, (hex(src), hex(old), hex(expect_old))
    pe[off:off+5] = bytes([0xE8]) + struct.pack("<i", new_dest - (src + 5))
    got = src + 5 + struct.unpack_from("<i", pe, off + 1)[0]
    assert got == new_dest
    print(f"  E8 {src:#x}: {old:#x} -> {got:#x}")

print("=== Capless-slot 9x (SS) ===")
for src in [0x12377c, 0x126cda, 0x128402, 0x1d9a89, 0x1d9c8b, 0x1d9d0e, 0x1da455, 0x1dd9b3, 0x270317]:
    patch_e8(src, 0x57656c, expect_old=0x59aa08)

print("=== Capless-internal 7x HIGH-SCORE (SS) ===")
internal = [
    (0x576692, 0x56e778, 0x2be519),
    (0x5766ec, 0x56ec6e, 0x2c614f),
    (0x576746, 0x56f8fb, 0x46a4db),
    (0x5767a0, 0x57100e, 0x493d31),
    (0x5767fa, 0x572e38, 0x49c90f),
    (0x576a47, 0x56209a, 0x2b55e7),
    (0x577405, 0x57a9cc, 0x27a89b),
]
for src, old, new in internal:
    patch_e8(src, new, expect_old=old)

print("=== LEA opcode-blob plant (mov_rbx + load_64) ===")
# mov_rbx @0x513828: LEA @0x513842 disp was 0xfc472 -> text e90000
# cave after ret @0x513861; LEA end @0x513849; new disp = 0x18
plants = [
    # (lea_rva, cave_rva, want_bytes, name)
    (0x513842, 0x513861, bytes.fromhex("4889d8"), "mov_rbx_to_rax"),
    (0x5149ee, 0x514a0d, bytes.fromhex("488b00"), "load_64_from_rax"),
]
for lea, cave, blob, name in plants:
    loff = rva2off(lea)
    assert pe[loff:loff+3] == bytes.fromhex("488d15"), (name, pe[loff:loff+3].hex())
    old_disp = struct.unpack_from("<i", pe, loff + 3)[0]
    old_tgt = lea + 7 + old_disp
    # cave must be INT3
    coff_ = rva2off(cave)
    assert pe[coff_:coff_+3] == b"\xcc\xcc\xcc", (name, pe[coff_:coff_+3].hex())
    pe[coff_:coff_+3] = blob
    new_disp = cave - (lea + 7)
    assert new_disp == 0x18, new_disp
    pe[loff+3:loff+7] = struct.pack("<i", new_disp)
    new_tgt = lea + 7 + struct.unpack_from("<i", pe, loff + 3)[0]
    assert new_tgt == cave
    assert pe[rva2off(cave):rva2off(cave)+3] == blob
    print(f"  {name}: LEA@{lea:#x} tgt {old_tgt:#x} -> {new_tgt:#x} bytes {blob.hex()} (old_disp={old_disp:#x})")

# sanity
assert pe[rva2off(0x57656c):rva2off(0x57656c)+4] == bytes.fromhex("554881ec")
assert pe[rva2off(0x57ef78):rva2off(0x57ef78)+3] == bytes.fromhex("554889")
assert pe[rva2off(0x513861):rva2off(0x513861)+3] == bytes.fromhex("4889d8")
assert pe[rva2off(0x514a0d):rva2off(0x514a0d)+3] == bytes.fromhex("488b00")

out = Path("xlang_isol1060_TT.exe")
out.write_bytes(pe)
sha = hashlib.sha256(pe).hexdigest()
print("Isol-TT", sha[:12], "size", len(pe))

outdir = Path("out_tt"); outdir.mkdir(exist_ok=True)
LIVE_sha = "dbaab1c7ce70"

def find(name):
    for root in [Path(r"C:/xlang_tmp/p1060"), Path(r"C:/Users/shuliangfu/worker/xlang/x-lang/tests")]:
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
    err = (r.stderr or b"").decode("utf-8","replace")[-400:]
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
        rec["n_a8feff"] = raw.count(bytes.fromhex("a8feff"))
        rec["n_e90000"] = raw.count(bytes.fromhex("e90000"))
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

Path("isol_tt_log.txt").write_text(
    "Isol-TT = SS remaps + LEA opcode plant mov_rbx/load_64\nsha12=%s\nresults=%s\n"%(sha[:12], results),
    encoding="utf-8")
print("DONE", sha[:12])
