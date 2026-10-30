"""Isol-calt_h3miss: site_abi_c36 SoftCap-site LIVE-shaped miss + Capless h3 force-miss continue.
Seek Isol-native SoftCap lit call-mk after Capless continue without h3 AV.
Ban transplant/arg-loop/twin/letter-pile.
"""
from pathlib import Path
import struct, hashlib, os, subprocess
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

cave = Path("C:/xlang_tmp/p1060/cave")
os.chdir(str(cave))
c36 = bytearray((cave / "xlang_isol1060_site_abi_c36.exe").read_bytes())
assert hashlib.sha256(bytes(c36)).hexdigest()[:12] == "29a8ae206733"

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

secs = pe_secs(c36)
md = Cs(CS_ARCH_X86, CS_MODE_64)

# Capless @576746 call h3 → xor eax,eax; nop*3 (force miss, continue)
o = rva2off(c36, secs, 0x576746)
assert c36[o] == 0xE8, bytes(c36[o:o+5]).hex()
c36[o:o+5] = bytes.fromhex("31c0909090")  # xor eax,eax; nop; nop; nop
sha = hashlib.sha256(c36).hexdigest()
print(f"Isol-calt_h3miss sha12={sha[:12]}")
host = cave / "xlang_isol1060_calt_h3miss.exe"
host.write_bytes(c36)

def plant_int3(base, rvas, label):
    pe = bytearray(base); s = pe_secs(pe)
    for rva in rvas:
        pe[rva2off(pe, s, rva)] = 0xCC
    out = cave / f"_dig_host_{label}.exe"; out.write_bytes(pe); return out

def run_host(h, src="p_ret_lit.x", timeout=20):
    out = cave / f"_tmp_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except Exception: pass
    try:
        r = subprocess.run([str(h), str(cave/src), "-o", str(out)],
                           capture_output=True, timeout=timeout)
        crc = r.returncode & 0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT", "-", 0, 0, 0
    tag = {0x80000003: "INT3", 0xC0000005: "AV", 0xC0000409: "GS", 0: "OK"}.get(crc, f"crc={crc:#x}")
    b = out.read_bytes() if out.exists() else b""
    sha = hashlib.sha256(b).hexdigest()[:12] if b else "-"
    return tag, sha, len(b), b.count(bytes.fromhex("68080000")), b.count(bytes.fromhex("78080000"))

LIVE_SHA, TT_SHA = "dbaab1c7ce70", "5b173cef1205"
print("\n=== calt_h3miss SoftCap p_ret_* ===")
for src in ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x"]:
    tag, sha, sz, n868, n878 = run_host(host, src)
    mark = " **LIVE**" if sha == LIVE_SHA else (" (=TT)" if sha == TT_SHA else "")
    print(f"  {src:16s} {tag:8s} sha={sha} sz={sz} n868={n868} n878={n878}{mark}")

# Capless helper walk after h3 skip
print("\n=== Capless INT3 walk after h3 skip ===")
hb = host.read_bytes()
for rva, name in [
    (0x5766c3, "fall"),
    (0x5766ec, "call_h2"),
    (0x576746, "h3_xoreax"),
    (0x57674b, "after_h3"),
    (0x576777, "after_h3_miss"),
    (0x5767a0, "call_h4"),
    (0x493d31, "h4"),
    (0x5767fa, "call_h5"),
    (0x49c90f, "h5"),
    (0x57689f, "call_201d9f"),
    (0x201d9f, "fn_201d9f"),
    (0x5768cf, "call_200ff7"),
    (0x200ff7, "fn_200ff7"),
    (0x5768f7, "call_4dac80"),
    (0x4dac80, "fn_4dac80"),
    (0x5770da, "arg_loop"),
    (0x57464c, "post_args"),
    (0x578278, "calt_exit"),
]:
    tag, sha, sz, n868, n878 = run_host(plant_int3(hb, [rva], f"h3m_{name}"))
    print(f"  @{rva:06x} {name:16s} → {tag:8s} sha={sha} sz={sz}")

# Also try skipping h2+h3+h4 (force miss chain) — calt_h234miss
print("\n=== plant calt_h234miss: force miss h2+h3+h4 ===")
pe = bytearray((cave/"xlang_isol1060_site_abi_c36.exe").read_bytes())
s = pe_secs(pe)
for rva in [0x5766ec, 0x576746, 0x5767a0]:  # call h2, h3, h4
    o = rva2off(pe, s, rva)
    assert pe[o] == 0xE8
    pe[o:o+5] = bytes.fromhex("31c0909090")
sha2 = hashlib.sha256(pe).hexdigest()
print(f"  sha12={sha2[:12]}")
h2 = cave/"xlang_isol1060_calt_h234miss.exe"; h2.write_bytes(pe)
for src in ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x"]:
    tag, sha, sz, n868, n878 = run_host(h2, src)
    mark = " **LIVE**" if sha == LIVE_SHA else (" (=TT)" if sha == TT_SHA else "")
    print(f"  {src:16s} {tag:8s} sha={sha} sz={sz} n868={n868} n878={n878}{mark}")

print("\nDONE")
