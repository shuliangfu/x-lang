"""Isol-alt_57619e / post_57619e: DIG @57619e alt (@5603b8/@56fa68)->@57629b on post_fa3;
one semantic plant: near-jmp skip helpers @5761c2->@57629b. Short timeout.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

cave = Path("C:/xlang_tmp/p1060/cave")
os.chdir(str(cave))
base = bytearray((cave / "xlang_isol1060_post_fa3.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12] == "453f3e66f96c"
T0 = time.time(); BUDGET = 85

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

def plant_int3(baseb, rvas, label):
    pe2 = bytearray(baseb); s = pe_secs(pe2)
    for rva in rvas:
        pe2[rva2off(pe2, s, rva)] = 0xCC
    out = cave / f"_dig_host_{label}.exe"; out.write_bytes(pe2); return out

def run_host(h, src="p_ret_lit.x", timeout=6):
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
    for p in list(cave.glob("_dig_host_a19e_*.exe")) + list(cave.glob("_tmp__dig_host_a19e_*")):
        try: p.unlink()
        except Exception: pass

clean()
print("=== DIG notes: see _dig/dig_alt_57619e.md ===", flush=True)

# Verify calls
for rva, expect in [(0x5761c2, 0x5603b8), (0x5761d5, 0x56fa68)]:
    o = rva2off(base, secs, rva)
    assert base[o] == 0xE8
    rel = struct.unpack_from("<i", base, o+1)[0]
    assert rva + 5 + rel == expect

# Plant: near jmp @5761c2 -> @57629b (skip both helpers + alt body)
pe = bytearray(base)
land = 0x57629b
o = rva2off(pe, secs, 0x5761c2)
rel = land - (0x5761c2 + 5)
pe[o] = 0xE9
struct.pack_into("<i", pe, o+1, rel)
pe[rva2off(pe, secs, 0x5761d5):rva2off(pe, secs, 0x5761d5)+5] = bytes([0x31, 0xC0, 0x90, 0x90, 0x90])
print(f"jmp @{0x5761c2:06x} -> @{land:06x} rel={rel:#x}", flush=True)

sha = hashlib.sha256(pe).hexdigest()
print(f"Isol-alt_57619e/post_57619e sha12={sha[:12]}", flush=True)
host = cave / "xlang_isol1060_alt_57619e.exe"
host.write_bytes(pe)
(cave / "xlang_isol1060_post_57619e.exe").write_bytes(pe)

print("\n=== SoftCap p_ret_* ===", flush=True)
for src in ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x"]:
    tag, sh, sz = run_host(host, src, timeout=8)
    print(f"  {src:16s} {tag:8s} sha={sh} sz={sz}", flush=True)

print("\n=== INT3 frontier ===", flush=True)
for rva, name in [(0x57629b, "inc_934"), (0x5762a2, "loop_cond"),
                  (0x5762b4, "loop_exit"), (0x5763c4, "post_loop")]:
    if time.time()-T0 > BUDGET: break
    tag, sh, sz = run_host(plant_int3(pe, [rva], f"a19e_{name}"), timeout=5)
    mark = " HIT" if tag == "INT3" else (" **AV**" if tag == "AV" else "")
    print(f"  @{rva:06x} {name:18s} -> {tag:8s}{mark}", flush=True)

clean()
print(f"elapsed={time.time()-T0:.1f}s DONE sha12={sha[:12]}", flush=True)
