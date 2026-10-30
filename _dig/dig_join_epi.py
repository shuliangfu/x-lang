"""DIG join @576523→epi @576555 INT3 frontier on alt_frame2. Budget<=85s. Ban long hang."""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

cave = Path("C:/xlang_tmp/p1060/cave")
os.chdir(str(cave))
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

def plant_int3(baseb, rvas, label):
    pe2 = bytearray(baseb); s = pe_secs(pe2)
    for rva in rvas:
        pe2[rva2off(pe2, s, rva)] = 0xCC
    out = cave / f"_dig_host_je_{label}.exe"
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
        return "TIMEOUT", "-", 0, b""
    tag = {0x80000003: "INT3", 0xC0000005: "AV", 0xC0000409: "GS", 0: "OK"}.get(crc, f"crc={crc:#x}")
    b = out.read_bytes() if out.exists() else b""
    sh = hashlib.sha256(b).hexdigest()[:12] if b else "-"
    return tag, sh, len(b), b

def clean():
    for p in list(cave.glob("_dig_host_je_*.exe")) + list(cave.glob("_tmp__dig_host_je_*")):
        try: p.unlink()
        except Exception: pass

clean()
base = bytearray((cave / "xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12] == "9378df517f96"
print(f"base alt_frame2 sha12=9378df517f96 t0", flush=True)

# Sanity: baseline compile already known OK; quick lit only
if time.time()-T0 < BUDGET:
    tag, sh, sz, b = run_host(cave/"xlang_isol1060_alt_frame2.exe", "p_ret_lit.x", timeout=8)
    has868 = (b"\x48\x81\xec"+struct.pack("<I",0x868)) in b
    has68 = (b"\x48\x81\xec"+struct.pack("<I",0x68)) in b
    has1b8 = (b"\x48\x81\xec"+struct.pack("<I",0x1b8)) in b
    print(f"baseline lit: {tag} sha={sh} sz={sz} 868={has868} 68={has68} 1b8={has1b8}", flush=True)

print("\n=== INT3 join→epi frontier (p_ret_lit) ===", flush=True)
sites = [
    (0x5763d6, "clr934"),
    (0x5763e0, "jmp523"),
    (0x576523, "join523"),
    (0x57652f, "jl_3e5"),
    (0x576535, "post_jl"),
    (0x57653a, "call_24b022"),
    (0x576544, "jmp_epi"),
    (0x576555, "epi"),
    (0x5763e5, "reenter_3e5"),
    (0x57651c, "inc934"),
]
for rva, name in sites:
    if time.time()-T0 > BUDGET - 5: 
        print("BUDGET stop", flush=True); break
    t1 = time.time()
    tag, sh, sz, _ = run_host(plant_int3(base, [rva], name), timeout=5)
    mark = " HIT" if tag == "INT3" else (" **AV**" if tag == "AV" else (" **GS**" if tag == "GS" else (" TIMEOUT" if tag=="TIMEOUT" else "")))
    print(f"  @{rva:06x} {name:14s} -> {tag:8s}{mark} ({time.time()-t1:.1f}s)", flush=True)

# Optional plant: true epi land (skip jl reentry) — jmp @57629b already to 5763d6;
# new plant: patch @5763e0 jmp @576523 → jmp @576535 (post-jl / true exit)
print("\n=== Isol plant join_epi: @5763e0 jmp→@576535 (skip join jl reentry) ===", flush=True)
if time.time()-T0 < BUDGET - 20:
    pe = bytearray(base)
    secs = pe_secs(pe)
    o = rva2off(pe, secs, 0x5763e0)
    assert pe[o] == 0xE9
    land = 0x576535
    rel = land - (0x5763e0 + 5)
    struct.pack_into("<i", pe, o+1, rel)
    sha = hashlib.sha256(pe).hexdigest()
    print(f"jmp @5763e0 -> @{land:06x} rel={rel:#x} sha12={sha[:12]}", flush=True)
    host = cave / "xlang_isol1060_join_epi.exe"
    host.write_bytes(pe)
    for src in ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x"]:
        if time.time()-T0 > BUDGET: break
        t1 = time.time()
        tag, sh, sz, b = run_host(host, src, timeout=8)
        has868 = (b"\x48\x81\xec"+struct.pack("<I",0x868)) in b if b else False
        has68 = (b"\x48\x81\xec"+struct.pack("<I",0x68)) in b if b else False
        has1b8 = (b"\x48\x81\xec"+struct.pack("<I",0x1b8)) in b if b else False
        # run emit if OK compile
        run_tag = "-"
        if tag == "OK" and b and sz > 0:
            outp = cave / f"_tmp_{host.stem}_{Path(src).stem}.exe"
            try:
                rr = subprocess.run([str(outp)], capture_output=True, timeout=5)
                run_tag = f"rc={rr.returncode}"
            except subprocess.TimeoutExpired:
                run_tag = "RUN_TIMEOUT"
            except Exception as e:
                run_tag = f"run_err"
        print(f"  {src:16s} compile={tag:8s} sha={sh} 868={has868} 68={has68} 1b8={has1b8} run={run_tag} ({time.time()-t1:.1f}s)", flush=True)
    # INT3 epi on plant
    if time.time()-T0 < BUDGET:
        for rva, name in [(0x576535,"post_jl"), (0x576555,"epi"), (0x576523,"join523")]:
            if time.time()-T0 > BUDGET: break
            t1=time.time()
            tag, sh, sz, _ = run_host(plant_int3(pe, [rva], f"je_{name}"), timeout=5)
            mark = " HIT" if tag == "INT3" else (" **AV**" if tag == "AV" else "")
            print(f"  plant INT3 @{rva:06x} {name:14s} -> {tag:8s}{mark} ({time.time()-t1:.1f}s)", flush=True)

clean()
print(f"\nDONE elapsed={time.time()-T0:.1f}s", flush=True)
# leave join_epi host for inspection; do NOT touch PROD
print("PROD untouched; pin untouched", flush=True)
