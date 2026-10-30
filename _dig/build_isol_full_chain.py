"""Isol-full_chain: SoftCap-full Capless early success → Capless-miss CALL finish.

DIG (this beat):
- USER gap: LIVE SoftCap writes mov eax,imm; spill; mov rdx,rax; near E8 call-mk.
  Isol SoftMega/SoftCap-full emit = TT thin (lea→rcx then field-read; frame 0x1b8).
- SoftCap-full@57effc Capless@555ed8: if ret>0 → @5890c8 mov eax,0; jmp @58e997
  EXITS SoftCap-full, skipping Capless-miss chain @5890dc+.
- Capless SoftCap twin early-claims success without lit call-mk; SoftCap-full trusts it.
- Capless-miss chain Isol-native: helpers → mov_imm_w@53ff24 → @523ba4 → @57518c
  → post_args@57464c → arch_E8@5264bc → E8enc@51a534 (Isol-native imm+near E8).
  SoftCap-full also calls @57464c@588cf8 before Capless, but that path still leaves
  emit=TT for SoftCap CallExpr (wrong/empty name state); miss-chain is Capless CALL
  isomorphic finish.
- Isol E8 writers: CE→E8enc; @51a534 sole near-E8 with callers; @57464c is the
  SoftCap-full/Capless post-args bridge into it. Ban LIVE SoftCap transplant.

Plant: @5890c8 early success → jmp Capless-miss @5890dc (+nop). Semantic full_chain.
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
# SoftCap-full Capless early success @5890c8: mov eax,0; jmp @58e997 (10B)
SITE = 0x5890C8
MISS = 0x5890DC
off = rva2off(pe, Isec, SITE)
expect = bytes.fromhex("b800000000e9c5580000")
assert pe[off : off + 10] == expect, pe[off : off + 10].hex()
# jmp rel8: eb 12 → SITE+2+0x12 = 0x5890dc; nop remaining 8B
rel8 = MISS - (SITE + 2)
assert rel8 == 0x12, hex(rel8)
pe[off : off + 10] = bytes([0xEB, rel8]) + b"\x90" * 8
assert pe[off : off + 10] == bytes.fromhex("eb129090909090909090")

out_name = "xlang_isol1060_full_chain.exe"
Path("/tmp/p1060_dig/bins").mkdir(parents=True, exist_ok=True)
(Path("/tmp/p1060_dig/bins") / out_name).write_bytes(pe)
out = (CAVE_DIR / out_name) if CAVE_DIR.exists() else Path("/tmp/p1060_dig/bins") / out_name
out.write_bytes(pe)
sha = hashlib.sha256(pe).hexdigest()
print("Isol-full_chain", sha[:12], "SoftCap-full @5890c8→jmp Capless-miss @5890dc")

if not CAVE_DIR.exists():
    print("no Win cave — plant only")
    raise SystemExit(0)

outdir = Path("out_full_chain")
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
