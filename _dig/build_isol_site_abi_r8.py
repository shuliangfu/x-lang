"""Isol-site_abi_r8: SoftCap-site r8/r9 slots LIVE-shaped + null claim eax=0.

DIG:
- SoftCap lit Capless→SoftCap-site @2be519. Isol stores f0=r8(q), f8=r9d(d);
  LIVE stores f0=r8d(d), f8=r9(q). Capless passes r8d=dword, r9=ptr (LIVE ABI).
- Isol null-check uses f8 (r9d); SoftCap lit hit @2be6b0 eax=1 early-claim → TT thin.
- site_null0 (eax→0 only) / site_live0_all → Capless continue AV (wrong slot state).
- LIVE SoftCap lit SoftCap-site: validate miss eax=0 → Capless continue (not null).
- LIVE SoftCap lit ALSO Cap@0024e6 kind0x30→@0021c8 (Isol SoftCap-site shares Cap21c8
  prologue; Isol has NO Cap@0024e6-like dispatcher calling SoftCap-site — only Capless
  @576692 + wrapper @2be40f).

Plant (semantic site_abi_r8; ban transplant/arg-loop/twin):
1. Entry stores: f0=r8d(d), f8=r9(q) — LIVE-shaped
2. Null check cmp [rbp+0xf8]→[rbp+0xf0]; claim eax=1→0
3. Body dword f8→f0; qword f0→f8 (keep site state coherent)

Gate: lit/fwd/local compile OK (no AV) but still TT thin — SoftCap lit now enters body,
hits kind-gate @2be734 eax=1 (kind∉{0x36,0x33,3}). Neutralize @2be734→0 (site_abi_c36)
→ Capless fallthrough AV. unk3/kany reach @2be781 second kind≠3 claim → same.
"""
from pathlib import Path
import struct, hashlib, os

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
        vs, va, rs, ro = struct.unpack_from("<IIII", buf, o + 8)
        out[n] = (va, vs, ro, rs)
    return out

def rva2off(buf, secs, r):
    for n, (va, vs, ro, rs) in secs.items():
        if va <= r < va + max(vs, rs):
            return ro + (r - va)
    raise ValueError(hex(r))

secs = pe_secs(pe)

def patch(rva, old, new, note):
    o = rva2off(pe, secs, rva)
    got = bytes(pe[o:o+len(old)])
    assert got == old, f"{note} @{rva:06x} want {old.hex()} got {got.hex()}"
    pe[o:o+len(new)] = new
    print(f"  @{rva:06x} {note}")

patch(0x2be537, bytes.fromhex("4c8985f0000000"), bytes.fromhex("448985f0000000"), "store f0=r8d")
patch(0x2be53e, bytes.fromhex("44898df8000000"), bytes.fromhex("4c898df8000000"), "store f8=r9")
patch(0x2be6a7, bytes.fromhex("83bdf800000000"), bytes.fromhex("83bdf000000000"), "cmp f8→f0")
patch(0x2be6b0, bytes.fromhex("b801000000"), bytes.fromhex("b800000000"), "null claim eax=0")
for rva, old in [
    (0x2be6ba, "8b95f8000000"),
    (0x2be6de, "8b95f8000000"),
    (0x2be70e, "8b95f8000000"),
    (0x2be73e, "8b85f8000000"),
]:
    old_b = bytes.fromhex(old)
    new_b = old_b.replace(bytes.fromhex("f8000000"), bytes.fromhex("f0000000"))
    patch(rva, old_b, new_b, "dword f8→f0")
for rva, old in [
    (0x2be7f5, "488b95f0000000"),
    (0x2be832, "4883bdf000000000"),
    (0x2be850, "488b85f0000000"),
]:
    old_b = bytes.fromhex(old)
    new_b = old_b.replace(bytes.fromhex("f0000000"), bytes.fromhex("f8000000"))
    patch(rva, old_b, new_b, "qword f0→f8")

sha = hashlib.sha256(pe).hexdigest()
print(f"Isol-site_abi_r8 sha12={sha[:12]} sha256={sha}")
assert sha[:12] == "de066e24b417", sha[:12]
out = Path("xlang_isol1060_site_abi_r8.exe")
if CAVE_DIR.exists():
    out = CAVE_DIR / out.name
out.write_bytes(pe)
print("wrote", out)
