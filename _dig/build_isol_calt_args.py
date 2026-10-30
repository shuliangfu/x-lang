"""Isol-calt_args: Capless-alt SoftCap-site early → arg-loop/emit_args.

DIG (this beat):
- SoftCap CallExpr IS Capless-alt@57656c (kind 0x30); SoftCap-full/twin/Capless@555ed8 off-path.
- Capless-alt calls SoftCap-site helper @2be519 (=LIVE @28e9c0, 0x150); ret>0 →
  early @5766b9 mov eax,0; jmp EXIT — Capless SoftCap early-claim WITHOUT lit call-mk.
- Bare e0 fallthrough (@5766c3 next helpers) AV.
- True Isol-native lit call-mk path later in Capless-alt:
  @5770da zero locals → @57711a arg-loop → emit_args@5752bc → post_args@57464c
  → @57bebc → @525544 → success EXIT.
- Fields 460/468/490/4b0 set before e0; 400/410/418/260 set in arg-loop.

Plant (single-site): @5766b9 early-success → jmp @5770da (arg-loop prep).
Semantic: calt_args. Ban LIVE SoftCap transplant / mega / letter pile.
"""
from pathlib import Path
import struct, hashlib, subprocess, os, time

CAVE_DIR = Path(r"C:/xlang_tmp/p1060/cave")
cands = [CAVE_DIR / "xlang_isol1060_TT.exe", Path("/tmp/p1060_dig/bins/xlang_isol1060_TT.exe")]
TT = next(p for p in cands if p.exists())
if CAVE_DIR.exists():
    os.chdir(CAVE_DIR)
pe = bytearray(TT.read_bytes())
assert hashlib.sha256(pe).hexdigest()[:12] == "1f836615e0fc"

def pe_secs(buf):
    e = struct.unpack_from("<I", buf, 0x3C)[0]
    nsec = struct.unpack_from("<H", buf, e + 6)[0]
    opt = struct.unpack_from("<H", buf, e + 20)[0]
    sec = e + 24 + opt
    out = {}
    for i in range(nsec):
        o = sec + i * 40
        n = bytes(buf[o:o+8]).split(b"\0")[0]
        vs, va, rs, ro = struct.unpack_from("<IIII", buf, o+8)
        out[n] = (va, vs, ro, rs)
    return out

def rva2off(buf, secs, r):
    for n, (va, vs, ro, rs) in secs.items():
        if va <= r < va + max(vs, rs):
            return ro + (r - va)
    raise ValueError(hex(r))

Isec = pe_secs(pe)
EARLY, DEST, EXIT = 0x5766B9, 0x5770DA, 0x578278
off = rva2off(pe, Isec, EARLY)
# TT: B8 00 00 00 00 E9 rel32(EXIT)  = 10 bytes
assert pe[off:off+5] == bytes.fromhex("b800000000") and pe[off+5] == 0xE9
rel_exit = struct.unpack_from("<i", pe, off+6)[0]
assert EARLY + 10 + rel_exit == EXIT
# Plant: E9 rel32(@5770da) + 5×NOP over the 10-byte early block
rel = DEST - (EARLY + 5)
pe[off:off+10] = bytes([0xE9]) + struct.pack("<i", rel) + b"\x90" * 5
assert pe[off] == 0xE9
assert EARLY + 5 + struct.unpack_from("<i", pe, off+1)[0] == DEST

out_name = "xlang_isol1060_calt_args.exe"
Path("/tmp/p1060_dig/bins").mkdir(parents=True, exist_ok=True)
(Path("/tmp/p1060_dig/bins") / out_name).write_bytes(pe)
out = (CAVE_DIR / out_name) if CAVE_DIR.exists() else Path("/tmp/p1060_dig/bins") / out_name
out.write_bytes(pe)
sha = hashlib.sha256(pe).hexdigest()
print("Isol-calt_args", sha[:12], f"early@{EARLY:06x}→argloop@{DEST:06x}")

if not CAVE_DIR.exists():
    print("no Win cave — plant only"); raise SystemExit(0)

outdir = Path("out_calt_args"); outdir.mkdir(exist_ok=True)

def find(name):
    for root in [Path(r"C:/xlang_tmp/p1060"), Path(r"C:/xlang_tmp/p1060/cave"),
                 Path(r"C:/Users/shuliangfu/worker/xlang/x-lang/tests/probes/p_big_struct")]:
        p = root / name
        if p.exists(): return str(p)
    return None

for label, fname in [("p_ret_lit","p_ret_lit.x"),("p_ret_fwd","p_ret_fwd.x"),("p_ret_local","p_ret_local.x")]:
    src = find(fname); dst = str((outdir/(label+".exe")).resolve()); rec={"src":src}
    if not src: print(label, {"fail":"missing"}); continue
    t0 = time.time()
    try:
        r = subprocess.run([str(out.resolve()), src, "-o", dst], capture_output=True, timeout=180)
    except subprocess.TimeoutExpired:
        print(label, {"fail":"compile_timeout"}); continue
    rec["crc"] = r.returncode & 0xFFFFFFFF; rec["dt"] = round(time.time()-t0, 2)
    if r.returncode == 0 and Path(dst).exists():
        raw = Path(dst).read_bytes()
        rec["sha"] = hashlib.sha256(raw).hexdigest()[:12]
        rec["n868"] = raw.count(bytes.fromhex("4881ec68080000"))
        rec["n878"] = raw.count(bytes.fromhex("4881ec78080000"))
        rec["n1b8"] = raw.count(bytes.fromhex("4881ecb8010000"))
        rec["ba0a"] = raw.count(bytes.fromhex("ba0a000000"))
        rec["b80a"] = raw.count(bytes.fromhex("b80a000000"))
        rec["match_TT"] = (rec["sha"]=="5b173cef1205") if label=="p_ret_lit" else None
        rec["match_LIVE"] = (rec["sha"]=="dbaab1c7ce70") if label=="p_ret_lit" else None
        try: rec["run"] = subprocess.run([dst], capture_output=True, timeout=30).returncode & 0xFFFFFFFF
        except Exception as e: rec["run"] = str(e)
    else:
        rec["fail"]=True; rec["err"]=(r.stderr or b"")[-400:]
    print(label, rec)
print("DONE", sha[:12])
