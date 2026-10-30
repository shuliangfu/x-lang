"""Isol-callsz_le: force SoftCap twin cmp [rbp-4],0x10 always ≤0x10 path.

DIG: SoftCap twin Isol@1d9b91 / LIVE@50786 isomorphic:
  cmp [rbp-4],0x10; jle ≤16 → SoftCap/SoftMega + post helpers
    (@521f10/@521d78/@524944/@1cd1e5 Isol; LIVE SoftCap@289dcb + helpers)
  >16 → SoftCap/SoftMega + Capless then early mov eax,0 (NO ≤16 helper tail)

LIVE call-mk written inside SoftCap@289dcb on both paths; Isol same slot is
SoftMega@57ef78→SoftCap-full (no x86 call-mk). Plant forces ≤16 helper chain
so DIG whether post helpers install imm→rdx+call mk for large p_ret_*.

Plant: @1d9b95 jle → jmp ≤16 entry @1d9cc1 (keep cmp; semantic callsz_le).
Ban letter pile / mega / LIVE SoftCap transplant.
"""
from pathlib import Path
import struct, hashlib, subprocess, os, time

CAVE_DIR = Path(r"C:/xlang_tmp/p1060/cave")
cands = [CAVE_DIR / "xlang_isol1060_TT.exe", Path("/tmp/p1060_dig/bins/xlang_isol1060_TT.exe")]
TT = next(p for p in cands if p.exists())
if CAVE_DIR.exists():
    os.chdir(CAVE_DIR)
pe = bytearray(TT.read_bytes())
assert hashlib.sha256(pe).hexdigest()[:12] == "1f836615e0fc", hashlib.sha256(pe).hexdigest()[:12]

def pe_secs(buf):
    e = struct.unpack_from("<I", buf, 0x3C)[0]
    nsec = struct.unpack_from("<H", buf, e + 6)[0]
    opt = struct.unpack_from("<H", buf, e + 20)[0]
    sec = e + 24 + opt
    out = {}
    for i in range(nsec):
        o = sec + i * 40
        n = bytes(buf[o : o + 8]).split(b"\0")[0]
        vs, va, rs, ro = struct.unpack_from("<IIII", buf, o + 8)
        out[n] = (va, vs, ro, rs)
    return out

def rva2off(buf, secs, r):
    for n, (va, vs, ro, rs) in secs.items():
        if va <= r < va + max(vs, rs):
            return ro + (r - va)
    raise ValueError(hex(r))

Isec = pe_secs(pe)
# SoftCap twin size gate: cmp [rbp-4],0x10; jle +0x126 → @1d9cc1
SITE = 0x1D9B91
off = rva2off(pe, Isec, SITE)
assert pe[off : off + 10] == bytes.fromhex("837dfc100f8e26010000"), pe[off : off + 10].hex()
# keep cmp; replace jle (6B) with jmp rel32 (5B) + nop
jle_at = SITE + 4  # 0x1d9b95
target = 0x1D9CC1
rel = target - (jle_at + 5)
assert rel == 0x127, hex(rel)
pe[off + 4 : off + 10] = bytes([0xE9]) + struct.pack("<i", rel) + b"\x90"
assert pe[off : off + 10] == bytes.fromhex("837dfc10e92701000090")

out_name = "xlang_isol1060_callsz_le.exe"
Path("/tmp/p1060_dig/bins").mkdir(parents=True, exist_ok=True)
(Path("/tmp/p1060_dig/bins") / out_name).write_bytes(pe)
out = (CAVE_DIR / out_name) if CAVE_DIR.exists() else Path("/tmp/p1060_dig/bins") / out_name
out.write_bytes(pe)
sha = hashlib.sha256(pe).hexdigest()
print("Isol-callsz_le", sha[:12], "SoftCap twin jle@1d9b95→jmp ≤16 @1d9cc1")

if not CAVE_DIR.exists():
    print("no Win cave — plant only")
    raise SystemExit(0)

outdir = Path("out_callsz_le")
outdir.mkdir(exist_ok=True)

def find(name):
    for root in [Path(r"C:/xlang_tmp/p1060"), Path(r"C:/xlang_tmp/p1060/cave"),
                 Path(r"C:/Users/shuliangfu/worker/xlang/x-lang/tests/probes/p_big_struct")]:
        p = root / name
        if p.exists():
            return str(p)
    return None

for label, fname in [("p_ret_lit", "p_ret_lit.x"), ("p_ret_fwd", "p_ret_fwd.x"), ("p_ret_local", "p_ret_local.x")]:
    src = find(fname)
    dst = str((outdir / (label + ".exe")).resolve())
    rec = {"src": src}
    if not src:
        print(label, {"fail": "missing"})
        continue
    t0 = time.time()
    r = subprocess.run([str(out.resolve()), src, "-o", dst], capture_output=True, timeout=180)
    rec["crc"] = r.returncode & 0xFFFFFFFF
    rec["dt"] = round(time.time() - t0, 2)
    if r.returncode == 0 and Path(dst).exists():
        raw = Path(dst).read_bytes()
        rec["sha"] = hashlib.sha256(raw).hexdigest()[:12]
        rec["n868"] = raw.count(bytes.fromhex("4881ec68080000"))
        rec["n878"] = raw.count(bytes.fromhex("4881ec78080000"))
        rec["n1b8"] = raw.count(bytes.fromhex("4881ecb8010000"))
        rec["ba0a"] = raw.count(bytes.fromhex("ba0a000000"))
        rec["match_TT"] = (rec["sha"] == "5b173cef1205") if label == "p_ret_lit" else None
        rec["match_LIVE"] = (rec["sha"] == "dbaab1c7ce70") if label == "p_ret_lit" else None
        try:
            rec["run"] = subprocess.run([dst], capture_output=True, timeout=30).returncode & 0xFFFFFFFF
        except Exception as e:
            rec["run"] = str(e)
    else:
        rec["fail"] = True
        rec["err"] = (r.stderr or b"")[-400:]
    print(label, rec)
print("DONE", sha[:12])
