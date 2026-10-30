"""Isol-alt_frame: post_fa3+alt_57619e + jmp @57629b->@5763c4 (skip inc/loop).
Semantic: bypass loop that re-enters mid-call region; land post_loop.
Base alt e1c45031fb92. SoftCap p_ret_* <=90s budget.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

cave = Path("C:/xlang_tmp/p1060/cave")
os.chdir(str(cave))
T0 = time.time(); BUDGET = 85
md = Cs(CS_ARCH_X86, CS_MODE_64)

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

def plant_int3(baseb, rvas, label):
    pe2 = bytearray(baseb); s = pe_secs(pe2)
    for rva in rvas:
        pe2[rva2off(pe2, s, rva)] = 0xCC
    out = cave / f"_dig_host_af_{label}.exe"
    out.write_bytes(pe2); return out

def run_host(h, src="p_ret_lit.x", timeout=8):
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

def clean():
    for p in list(cave.glob("_dig_host_af_*.exe")) + list(cave.glob("_tmp__dig_host_af_*")):
        try: p.unlink()
        except Exception: pass

clean()
base = bytearray((cave / "xlang_isol1060_alt_57619e.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12] == "e1c45031fb92"
secs = pe_secs(base)

# Verify existing jmp @5761c2 -> @57629b
o = rva2off(base, secs, 0x5761c2)
assert base[o] == 0xE9
rel = struct.unpack_from("<i", base, o+1)[0]
assert 0x5761c2 + 5 + rel == 0x57629b

# Plant: jmp @57629b -> @5763c4 (5B) + 2 nop (add was 7B)
pe = bytearray(base)
o = rva2off(pe, secs, 0x57629b)
assert pe[o:o+2] == bytes([0x83, 0x85]), bytes(pe[o:o+2]).hex()
land = 0x5763c4
rel = land - (0x57629b + 5)
pe[o] = 0xE9
struct.pack_into("<i", pe, o+1, rel)
pe[o+5] = 0x90
pe[o+6] = 0x90
print(f"jmp @57629b -> @{land:06x} rel={rel:#x}", flush=True)

sha = hashlib.sha256(pe).hexdigest()
print(f"Isol-alt_frame sha12={sha[:12]}", flush=True)
host = cave / "xlang_isol1060_alt_frame.exe"
host.write_bytes(pe)
(cave / "xlang_isol1060_fix_rbp.exe").write_bytes(pe)  # alias name

print("\n=== SoftCap p_ret_* ===", flush=True)
for src in ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x"]:
    if time.time()-T0 > BUDGET: break
    t1 = time.time()
    tag, sh, sz = run_host(host, src, timeout=8)
    print(f"  {src:16s} {tag:8s} sha={sh} sz={sz} ({time.time()-t1:.1f}s)", flush=True)

print("\n=== INT3 frontier ===", flush=True)
for rva, name in [(0x5763c4, "post_loop"), (0x5763d6, "clr934"),
                  (0x5763e0, "jmp523"), (0x576523, "join523"),
                  (0x576435, "call_523ba4"), (0x576555, "epi")]:
    if time.time()-T0 > BUDGET: break
    t1 = time.time()
    tag, sh, sz = run_host(plant_int3(pe, [rva], name), timeout=5)
    mark = " HIT" if tag == "INT3" else (" **AV**" if tag == "AV" else (" **GS**" if tag == "GS" else ""))
    print(f"  @{rva:06x} {name:16s} -> {tag:8s}{mark} ({time.time()-t1:.1f}s)", flush=True)

clean()
print(f"elapsed={time.time()-T0:.1f}s DONE sha12={sha[:12]}", flush=True)
