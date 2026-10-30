"""Isol-post_fa3b: h3_jesk + jmp over bad call block @5760c2..@57610f → @576110.
Falsify xor-only; skip both mid-insn calls + their ret stores.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

cave = Path("C:/xlang_tmp/p1060/cave")
os.chdir(str(cave))
base = bytearray((cave / "xlang_isol1060_h3_jesk.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12] == "cfb0fae4f5d9"
T0 = time.time()

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

secs = pe_secs(base)
md = Cs(CS_ARCH_X86, CS_MODE_64)
pe = bytearray(base)

# Verify original calls
for rva, tgt in [(0x5760c2, 0x5862f8), (0x5760fb, 0x5863c9)]:
    o = rva2off(pe, secs, rva)
    assert pe[o] == 0xE8
    rel = struct.unpack_from("<i", pe, o+1)[0]
    assert rva + 5 + rel == tgt

# Plant: at @5760c2, short jmp to @576110 (after both stores)
# EB XX = jmp rel8; distance from 5760c4 to 576110 = 0x576110 - 0x5760c4 = 0x4C
# Need 2-byte jmp: EB 4C, then pad rest of 5-byte call with NOPs: EB 4C 90 90 90
o = rva2off(pe, secs, 0x5760c2)
dist = 0x576110 - (0x5760c2 + 2)
assert 0 < dist < 128, hex(dist)
pe[o:o+5] = bytes([0xEB, dist, 0x90, 0x90, 0x90])
print(f"jmp @{0x5760c2:06x} -> @{0x576110:06x} dist={dist:#x} bytes={bytes(pe[o:o+5]).hex()}")

# Also nop second call in case something else lands there (belt)
o2 = rva2off(pe, secs, 0x5760fb)
pe[o2:o2+5] = bytes([0x31, 0xC0, 0x90, 0x90, 0x90])  # unreachable if jmp works, but safe

print("=== disasm patched @5760b5..@576120 ===")
o = rva2off(pe, secs, 0x5760b5)
for insn in md.disasm(bytes(pe[o:o+0x80]), 0x5760b5):
    print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    if insn.address >= 0x576120:
        break

sha = hashlib.sha256(pe).hexdigest()
print(f"Isol-post_fa3b sha12={sha[:12]}")
# overwrite post_fa3 with improved plant (same semantic name family) — keep post_fa3.exe as xor, write post_fa3b
host = cave / "xlang_isol1060_post_fa3b.exe"
host.write_bytes(pe)
# also update post_fa3.exe to this stronger plant as the one Isol plant result
(cave / "xlang_isol1060_post_fa3.exe").write_bytes(pe)
print(f"(post_fa3.exe updated to jmp-skip sha12={sha[:12]})")

def run_host(h, src, timeout=10):
    out = cave / f"_tmp_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except Exception: pass
    try:
        r = subprocess.run([str(h), str(cave/src), "-o", str(out)],
                           capture_output=True, timeout=timeout)
        crc = r.returncode & 0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT", "-", 0
    tag = {0x80000003: "INT3", 0xC0000005: "AV", 0xC0000409: "GS", 0: "OK"}.get(crc, f"crc={crc:#x}")
    b = out.read_bytes() if out.exists() else b""
    sh = hashlib.sha256(b).hexdigest()[:12] if b else "-"
    return tag, sh, len(b)

print("\n=== post_fa3 SoftCap p_ret_* ===")
for src in ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x"]:
    tag, sh, sz = run_host(host, src, timeout=10)
    print(f"  {src:16s} {tag:8s} sha={sh} sz={sz}")

def plant_int3(baseb, rvas, label):
    pe2 = bytearray(baseb); s = pe_secs(pe2)
    for rva in rvas:
        pe2[rva2off(pe2, s, rva)] = 0xCC
    out = cave / f"_dig_host_{label}.exe"; out.write_bytes(pe2); return out

print("\n=== INT3 after jmp-skip ===")
for rva, name in [
    (0x5760c2, "jmp_site"),
    (0x576110, "land_after_skip"),
    (0x576132, "test_5c0"),
    (0x576134, "je_alt"),
    (0x57619e, "alt"),
    (0x57629b, "inc_934"),
    (0x5762a2, "loop_cond"),
    (0x5762b4, "loop_exit"),
    (0x5762be, "jmp_3c4"),
    (0x5763c4, "post_loop"),
]:
    if time.time()-T0 > 80: break
    tag, sh, sz = run_host(plant_int3(pe, [rva], f"pfb_{name}"), "p_ret_lit.x", timeout=6)
    mark = " HIT" if tag=="INT3" else (" **AV**" if tag=="AV" else "")
    print(f"  @{rva:06x} {name:18s} -> {tag:8s}{mark}")

for p in list(cave.glob("_dig_host_pfb_*.exe")) + list(cave.glob("_tmp__dig_host_pfb_*")):
    try: p.unlink()
    except Exception: pass
print(f"elapsed={time.time()-T0:.1f}s DONE")
