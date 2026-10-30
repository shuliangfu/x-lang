"""Isol-scap0: force emit_expr SoftCap flag @1cf074 SoftCap=0 alt.

DIG (this beat): Isol@1cf074 / LIVE@464cb SoftCap flag isomorphic; encode
Isol@1e20b1 / LIVE@59ad9 isomorphic and ONLY on type==0xa AFTER SoftCap ok.
>16B SoftCap twin early-returns after SoftCap/Capless — NO encode. LIVE
call-mk for p_ret_* written inside LIVE SoftCap @289dcb (kind==0x31);
Isol maps that slot to SoftMega trampoline @57ef78→SoftCap-full (no x86 call-mk).

Plant: single site — nop SoftCap≠0 jne @1cf0a8 so SoftCap=0 alt @272bde always.
Semantic short name scap0 (ban letter pile).
"""
from pathlib import Path
import struct, hashlib, os

cands = [
    Path("/tmp/p1060_dig/bins/xlang_isol1060_TT.exe"),
    Path(r"C:/xlang_tmp/p1060/cave/xlang_isol1060_TT.exe"),
]
TT = next(p for p in cands if p.exists())
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
# @1cf0a6: test eax,eax; jne SoftCap≠0 (+0x33 → 0x1cf0dd)
off = rva2off(pe, Isec, 0x1CF0A6)
assert pe[off : off + 4] == bytes.fromhex("85c07533"), pe[off : off + 4].hex()
pe[off + 2 : off + 4] = b"\x90\x90"  # nop jne → fallthrough SoftCap=0 alt
assert pe[off : off + 4] == bytes.fromhex("85c09090")

out_name = "xlang_isol1060_scap0.exe"
out_dirs = [Path("/tmp/p1060_dig/bins")]
cave = Path(r"C:/xlang_tmp/p1060/cave")
if cave.exists():
    out_dirs.append(cave)
sha = hashlib.sha256(pe).hexdigest()
for d in out_dirs:
    d.mkdir(parents=True, exist_ok=True)
    (d / out_name).write_bytes(pe)
print("Isol-scap0", sha[:12], "SoftCap flag jne@1cf0a8→nop → SoftCap=0 alt")
