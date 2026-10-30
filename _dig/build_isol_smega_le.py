"""Isol-smega_le: SoftMega@59b170 size gate always ≤16 path (skip ARM64 egg).

DIG (this beat):
- Real USER gap: lea→rcx then missing mov eax,imm→spill→mov rdx,rax→call mk
  (NOT ba0a). LIVE SoftCap@289dcb writes via helpers; Isol SoftMega does not.
- SoftCap twin size gate Isol@1d9b91／LIVE@50786 isomorphic; callsz_le forced
  twin ≤16 helpers — still SoftMega sees real size>16 → Isol-only ARM egg.
- SoftMega body@59b170 gate@59b608: cmp size,0x10; setg; je@59b617→@59b85d (≤16).
  >16 fallthrough → sole ARM egg call@59b6a9→@57426c (const 0x02990030).
  LIVE has ZERO that egg const. ≤16 →@59aa8c→SoftCap-full@57effc.
- callsz_le falsified twin helpers; this plant forces SoftMega internal ≤16 so
  SoftCap CallExpr >16B skips ARM egg and takes SoftCap-full emit path.

Plant: je@59b617 → jmp ≤16 @59b85d (+nop). Keep cmp/setg. Semantic smega_le.
Ban LIVE SoftCap transplant / mega / letter pile / cave letter stack.
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
# SoftMega@59b170 size gate: mov eax,0x10; cmp ebx,eax; setg; test; je +0x240 → @59b85d
GATE = 0x59B608
off = rva2off(pe, Isec, GATE)
expect = bytes.fromhex("b81000000039c30f9fc00fb6c085c00f8440020000")
assert pe[off : off + 21] == expect, pe[off : off + 21].hex()
je_at = 0x59B617
target = 0x59B85D
rel = target - (je_at + 5)
assert rel == 0x241, hex(rel)
# keep mov/cmp/setg/test (15B); replace je rel32 (6B) with jmp rel32 (5B) + nop
pe[off + 15 : off + 21] = bytes([0xE9]) + struct.pack("<i", rel) + b"\x90"
assert pe[off : off + 21] == bytes.fromhex("b81000000039c30f9fc00fb6c085c0e94102000090")

out_name = "xlang_isol1060_smega_le.exe"
Path("/tmp/p1060_dig/bins").mkdir(parents=True, exist_ok=True)
(Path("/tmp/p1060_dig/bins") / out_name).write_bytes(pe)
out = (CAVE_DIR / out_name) if CAVE_DIR.exists() else Path("/tmp/p1060_dig/bins") / out_name
out.write_bytes(pe)
sha = hashlib.sha256(pe).hexdigest()
print("Isol-smega_le", sha[:12], "SoftMega je@59b617→jmp ≤16 @59b85d (skip ARM egg@57426c)")

if not CAVE_DIR.exists():
    print("no Win cave — plant only")
    raise SystemExit(0)

outdir = Path("out_smega_le")
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
        # real LIVE signature: mov eax,0xa … mov rdx,rax … near call
        rec["b80a"] = raw.count(bytes.fromhex("b80a000000"))
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
