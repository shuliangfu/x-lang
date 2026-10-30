"""Isol-XX: Capless/SoftMega call-mk gap — plant LIVE @284d24; retarget all E8→@56d014.
Minimal plant (LIVE SoftCap CallExpr helper + chkstk already on Isol); no mega/whole-tree.
From Isol-TT. SoftCap CallExpr uses @284d24 on LIVE (Capless 3× + SoftCap 1×);
Isol SoftMega reaches @56d014 via @59aa8c→@59bb30 — retarget covers Capless+SoftMega.
"""
from pathlib import Path
import struct, hashlib, subprocess, time, os

CAVE_DIR = Path(r"C:/xlang_tmp/p1060/cave")
os.chdir(CAVE_DIR)

TT = Path("xlang_isol1060_TT.exe")
pe = bytearray(TT.read_bytes())
assert hashlib.sha256(pe).hexdigest()[:12] == "1f836615e0fc", hashlib.sha256(pe).hexdigest()[:12]

LIVE = Path("lab_LIVE_pret.exe")
assert LIVE.exists(), "lab_LIVE_pret.exe missing in cave"
live = bytearray(LIVE.read_bytes())
print("LIVE", hashlib.sha256(live).hexdigest()[:12])

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

def body_size(buf, secs, fn, limit=0x2000):
    """First ret after push-rbp prologue (prefer pop rbp; ret)."""
    from capstone import Cs, CS_ARCH_X86, CS_MODE_64
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    off = rva2off(buf, secs, fn)
    for insn in md.disasm(bytes(buf[off:off+limit]), fn):
        if insn.mnemonic == "ret":
            return insn.address + insn.size - fn
    raise ValueError(hex(fn))

Isec = pe_secs(pe); Lsec = pe_secs(live)

# --- Plant LIVE SoftCap CallExpr helper @284d24 (+ leaf @2984c9 if needed) ---
# Isol already has __chkstk @63a7b0; memset IAT thunk @63b200
PLANT_LIVE = [0x284d24, 0x2984c9, 0x29bac6]  # CallExpr helper + std_ leaf + small helper
sizes = {la: body_size(live, Lsec, la) for la in PLANT_LIVE}
print("plant sizes", {hex(k): hex(v) for k,v in sizes.items()})

CAVE = 0x116998  # TT INT3 cave (UU/VV use copies; XX from TT)
# skip past any non-INT3 if prior local edits (TT should be clean)
coff = rva2off(pe, Isec, CAVE)
assert pe[coff:coff+16] == b"\xcc"*16, pe[coff:coff+16].hex()

cursor = CAVE
layout = {}
for la in PLANT_LIVE:
    cursor = (cursor + 15) & ~15
    layout[la] = cursor
    cursor += sizes[la]
print("layout", {hex(k): hex(v) for k,v in layout.items()}, "end", hex(cursor))
assert cursor < CAVE + 0x2000, "cave overflow"

# L2I: exact Isol twins + role-parallel Capless@56d014 pairing + planted
L2I = {
    0x84fc2: 0x20cd98,
    0x77cbe: 0x1fff7e,
    0x77996: 0x1ffc56,
    0x7702f: 0x1ff2ef,
    0x76fe3: 0x1ff2a3,
    0x79cee: 0x201f36,
    0x79dac: 0x201ff4,
    0x79adb: 0x201d23,
    0x274325: 0x5237d0,
    0x2a39e2: 0x53ff24,
    0x277eef: 0x525130,
    0x243a41: 0xfca38,      # exact head+span
    0x33ba10: 0x63a7b0,     # Isol __chkstk
    0x33c038: 0x63b200,     # memset IAT thunk
    # role-parallel (Isol Capless@56d014 sites; span DIFF but push-rbp)
    0x281a3b: 0x55d99c,
    0x2873cf: 0x57464c,
}
L2I.update(layout)

for ld, id_ in list(L2I.items()):
    if ld in layout:
        continue
    io = rva2off(pe, Isec, id_)
    # memset / chkstk may not be push rbp
    if ld in (0x33c038, 0x33ba10):
        continue
    assert pe[io] == 0x55, (hex(ld), hex(id_), hex(pe[io]))

def patch_e8_bytes(body, live_rva, plant_rva, L2I):
    from capstone import Cs, CS_ARCH_X86, CS_MODE_64
    md = Cs(CS_ARCH_X86, CS_MODE_64)
    nfix = 0
    for insn in md.disasm(bytes(body), live_rva):
        if insn.mnemonic != "call" or insn.bytes[:1] != b"\xe8":
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
    print(f"  plant LIVE@{la:#x} -> Isol@{dest_rva:#x} size={sizes[la]:#x} e8fix={nfix}")

print("total e8fix", total_fix)
PLANT_284 = layout[0x284d24]

def patch_e8(src, new_dest, expect_old=None):
    off = rva2off(pe, Isec, src)
    assert pe[off] == 0xE8
    old = src + 5 + struct.unpack_from("<i", pe, off+1)[0]
    if expect_old is not None:
        assert old == expect_old, (hex(src), hex(old), hex(expect_old))
    pe[off:off+5] = bytes([0xE8]) + struct.pack("<i", new_dest - (src + 5))
    got = src + 5 + struct.unpack_from("<i", pe, off+1)[0]
    assert got == new_dest
    print(f"  E8 {src:#x}: {old:#x} -> {got:#x}")

# All Isol E8→@56d014 (Capless 3 + SoftMega path + siblings)
RETARGET = [
    0x576c6e,  # Capless +0x702
    0x576d29,  # Capless +0x7bd
    0x577475,  # Capless +0xf09
    0x5859f1,
    0x59d14a,
    0x59d2c5,
    0x59ed31,
]
print("=== retarget E8 @56d014 -> plant @284d24 ===")
for src in RETARGET:
    patch_e8(src, PLANT_284, expect_old=0x56d014)

# Keep TT LEA plants
assert pe[rva2off(pe,Isec,0x513861):rva2off(pe,Isec,0x513861)+3] == bytes.fromhex("4889d8")
assert pe[rva2off(pe,Isec,0x514a0d):rva2off(pe,Isec,0x514a0d)+3] == bytes.fromhex("488b00")
assert pe[rva2off(pe,Isec,0x57656c):rva2off(pe,Isec,0x57656c)+4] == bytes.fromhex("554881ec")

out = Path("xlang_isol1060_XX.exe")
out.write_bytes(pe)
sha = hashlib.sha256(pe).hexdigest()
print("Isol-XX", sha[:12], "size", len(pe), "plant284", hex(PLANT_284))

outdir = Path("out_xx"); outdir.mkdir(exist_ok=True)
LIVE_sha = "dbaab1c7ce70"
TT_sha = "5b173cef1205"

def find(name):
    for root in [Path(r"C:/xlang_tmp/p1060"), Path(r"C:/Users/shuliangfu/worker/xlang/x-lang/tests")]:
        if not root.exists():
            continue
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
    rec = dict(crc=r.returncode & 0xFFFFFFFF, dt=round(time.time()-t0, 2))
    err = (r.stderr or b"").decode("utf-8", "replace")[-500:]
    if err:
        rec["stderr_tail"] = err
    if r.returncode == 0 and Path(dst).exists() and Path(dst).stat().st_size > 0:
        raw = Path(dst).read_bytes()
        h = hashlib.sha256(raw).hexdigest()[:12]
        rec["sha"] = h
        rec["vs_tt"] = (h != TT_sha)
        rec["match_live"] = (h == LIVE_sha) if label == "p_ret_lit" else None
        rec["n_sub_0x868"] = raw.count(bytes.fromhex("4881ec68080000"))
        rec["n_sub_0x878"] = raw.count(bytes.fromhex("4881ec78080000"))
        rec["n_sub_0x68"] = raw.count(bytes.fromhex("4883ec68"))
        rec["n_sub_0x1b8"] = raw.count(bytes.fromhex("4881ecb8010000"))
        # call-mk: imm10 + E8 pattern rough — count E8 in .text of user emit
        # disasm main: look for call after lea rcx
        try:
            rr = subprocess.run([dst], capture_output=True, timeout=30)
            rec["run"] = rr.returncode & 0xFFFFFFFF
        except Exception as e:
            rec["run"] = str(e)
    else:
        rec["fail"] = True
    results[label] = rec
    print(label, rec)

Path("out_xx/results.json").write_text(__import__("json").dumps(results, indent=2))
print("DONE Isol-XX", sha[:12])
