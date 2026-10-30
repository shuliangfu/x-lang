"""Isol-YY: SoftMega SoftCap bridge SoftCap-full→Capless (SoftCap CallExpr early-out).

True gap (non-@56d014): SoftCap twin→SoftMega→bridge SoftCap≠0 → SoftCap-full @57effc.
SoftCap-full has no CALL kind=3 / no CE @522c0c / no h_emit — CallExpr early-success
without imm→rdx+call mk after let-init sret lea→rcx. Capless @57656c HAS CALL kind=3.

Minimal single-point: retarget sole SoftCap-full caller @59ab11 → Capless @57656c.
Same 5-arg shape (rcx,rdx,r8,r9,[rsp+0x20]=mode). No mega/whole-tree/cave letter pile.
"""
from pathlib import Path
import struct, hashlib, subprocess, os, time

CAVE_DIR = Path(r"C:/xlang_tmp/p1060/cave")
# Prefer Win cave; fall back to Mac dig bins when run off-box.
cands = [CAVE_DIR / "xlang_isol1060_TT.exe", Path("/tmp/p1060_dig/bins/xlang_isol1060_TT.exe")]
TT = next(p for p in cands if p.exists())
if CAVE_DIR.exists():
    os.chdir(CAVE_DIR)
pe = bytearray(TT.read_bytes())
assert hashlib.sha256(pe).hexdigest()[:12] == "1f836615e0fc"

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
SITE, OLD, NEW = 0x59ab11, 0x57effc, 0x57656c
off = rva2off(pe, Isec, SITE)
assert pe[off] == 0xE8
assert SITE + 5 + struct.unpack_from("<i", pe, off+1)[0] == OLD
pe[off:off+5] = bytes([0xE8]) + struct.pack("<i", NEW - (SITE + 5))

out_name = "xlang_isol1060_YY.exe"
out = (CAVE_DIR / out_name) if CAVE_DIR.exists() else Path("/tmp/p1060_dig/bins") / out_name
out.write_bytes(pe)
sha = hashlib.sha256(pe).hexdigest()
print("Isol-YY", sha[:12], "plant @59ab11 SoftCap-full→Capless")

# Gate on Win when cave present
if not CAVE_DIR.exists():
    print("no Win cave — plant only")
    raise SystemExit(0)

outdir = Path("out_yy"); outdir.mkdir(exist_ok=True)

def find(name):
    for root in [Path(r"C:/xlang_tmp/p1060"), Path(r"C:/Users/shuliangfu/worker/xlang/x-lang/tests")]:
        if not root.exists():
            continue
        for dp, _, fs in os.walk(root):
            if name in fs:
                return str(Path(dp) / name)
    return None

results = {}
for label, fname in [("p_ret_lit","p_ret_lit.x"),("p_ret_fwd","p_ret_fwd.x"),("p_ret_local","p_ret_local.x")]:
    src = find(fname)
    dst = str((outdir / (label + ".exe")).resolve())
    rec = {"src": src}
    if not src:
        rec["fail"] = "src missing"; results[label] = rec; print(label, rec); continue
    t0 = time.time()
    r = subprocess.run([str(out.resolve()), src, "-o", dst], capture_output=True, timeout=180)
    rec["crc"] = r.returncode & 0xffffffff
    rec["dt"] = round(time.time() - t0, 2)
    if r.returncode == 0 and Path(dst).exists():
        raw = Path(dst).read_bytes()
        rec["sha"] = hashlib.sha256(raw).hexdigest()[:12]
        rec["n868"] = raw.count(bytes.fromhex("4881ec68080000"))
        rec["n878"] = raw.count(bytes.fromhex("4881ec78080000"))
        rec["n1b8"] = raw.count(bytes.fromhex("4881ecb8010000"))
        # quick emit sniff: lea→rcx then mov edx / call
        rec["has_ba0a"] = raw.count(bytes.fromhex("ba0a000000"))  # mov edx,10
        try:
            rr = subprocess.run([dst], capture_output=True, timeout=30)
            rec["run"] = rr.returncode & 0xffffffff
        except Exception as e:
            rec["run"] = str(e)
    else:
        rec["fail"] = True
        rec["err"] = (r.stderr or b"")[-400:]
    results[label] = rec
    print(label, rec)

note = Path("isol_yy_NOTE.txt")
note.write_text(
    "Isol-YY = TT + SoftMega bridge SoftCap-full→Capless @59ab11\n"
    "sha12=%s\nresults=%s\n" % (sha[:12], results)
)
print("DONE", sha[:12])
