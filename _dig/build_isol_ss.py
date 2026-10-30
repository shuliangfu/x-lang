"""Isol-SS: Capless-slot 9x + Capless-internal 7x HIGH-SCORE exact-prol remaps.
PAIR-slot left as SoftCap stub @0x57ef78 (DIG falsified: LIVE PAIR SoftCap 0x1070 absent in Isol).
No mega / no LIVE whole-tree plant.
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
    print(f"  {src:#x}: {old:#x} -> {got:#x}")

print("=== Capless-slot 9x @59aa08 -> @57656c ===")
for src in [0x12377c, 0x126cda, 0x128402, 0x1d9a89, 0x1d9c8b, 0x1d9d0e, 0x1da455, 0x1dd9b3, 0x270317]:
    patch_e8(src, 0x57656c, expect_old=0x59aa08)

print("=== Capless-internal 7x HIGH-SCORE exact-prol (vs RR weak) ===")
# (call_site, old_broken, new_iso, note)
# Chosen by exact 8B prol match + max masked-128/256; unique; no Capless/PAIR/mega.
internal = [
    (0x576692, 0x56e778, 0x2be519, "LIVE 28e9c0 prol 0x150; RR was 231334"),
    (0x5766ec, 0x56ec6e, 0x2c614f, "LIVE 28eeb6 prol 0x190; same RR"),
    (0x576746, 0x56f8fb, 0x46a4db, "LIVE 28fb43 prol 0x1f0; same RR"),
    (0x5767a0, 0x57100e, 0x493d31, "LIVE 291256 prol 0x260; RR was 29aefb"),
    (0x5767fa, 0x572e38, 0x49c90f, "LIVE 293080 prol 0x220; same RR"),
    (0x576a47, 0x56209a, 0x2b55e7, "LIVE 2822e2 thin 0x30; RR was 5e5d7d sc32"),
    (0x577405, 0x57a9cc, 0x27a89b, "LIVE 29ac14 prol 0x240; RR was 495fa7"),
]
for src, old, new, note in internal:
    print(" ", note)
    patch_e8(src, new, expect_old=old)

# sanity: Capless prol / PAIR stub / mega untouched
assert pe[rva2off(0x57656c):rva2off(0x57656c)+4] == bytes.fromhex("554881ec")
assert pe[rva2off(0x57ef78):rva2off(0x57ef78)+3] == bytes.fromhex("554889")
assert pe[rva2off(0x57effc):rva2off(0x57effc)+3] == bytes.fromhex("554889")

out = Path("xlang_isol1060_SS.exe")
out.write_bytes(pe)
sha = hashlib.sha256(pe).hexdigest()
print("Isol-SS", sha[:12], "size", len(pe))

outdir = Path("out_ss"); outdir.mkdir(exist_ok=True)
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
        h = hashlib.sha256(Path(dst).read_bytes()).hexdigest()[:12]
        rec["sha"]=h
        if label=="p_ret_lit": rec["match_live"]=(h==LIVE_sha)
        # SoftCap frame markers in emit
        blob = Path(dst).read_bytes()
        rec["n_sub_0x868"] = blob.count(bytes.fromhex("4881ec68080000"))
        rec["n_sub_0x878"] = blob.count(bytes.fromhex("4881ec78080000"))
        rec["n_488b00"] = blob.count(bytes.fromhex("488b00"))
        rec["n_4889d8"] = blob.count(bytes.fromhex("4889d8"))
        rec["n_a8feff"] = blob.count(bytes.fromhex("a8feff"))
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

Path("isol_ss_log.txt").write_text(
    "Isol-SS Capless-slot + high-score 7x\nPAIR falsified leave stub\nsha12=%s\nresults=%s\n"%(sha[:12], results),
    encoding="utf-8")
print("DONE", sha[:12])
