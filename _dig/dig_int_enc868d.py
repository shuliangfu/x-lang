"""DIG Capless-internal: pre_last HIT + @5180bd enc-ish + frame_sz feed. Budget<=80s."""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64)

cave = Path("C:/xlang_tmp/p1060/cave"); os.chdir(str(cave))
T0 = time.time(); BUDGET = 80

def pe_secs(buf):
    e = struct.unpack_from("<I", buf, 0x3C)[0]
    nsec = struct.unpack_from("<H", buf, e + 6)[0]
    opt = struct.unpack_from("<H", buf, e + 20)[0]
    sec = e + 24 + opt; out = {}
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

def off2rva(secs, off):
    for n, (va, vs, ro, rs) in secs.items():
        if ro <= off < ro + max(rs, 1):
            return va + (off - ro)
    return None

def text_range(secs):
    for k, v in secs.items():
        kn = k.decode() if isinstance(k, bytes) else k
        if kn == ".text": return v
    return None

def dump(buf, secs, rva, n=0x100, label=""):
    o = rva2off(buf, secs, rva)
    print(f"--- {label} @{rva:06x} ---", flush=True)
    for insn in md.disasm(bytes(buf[o:o+n]), rva):
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)

def e8_callers(buf, secs, target, limit=40):
    t = text_range(secs)
    if not t: return []
    va, vs, ro, rs = t
    out = []; i = ro; end = ro + rs - 5
    while i <= end and len(out) < limit:
        if buf[i] == 0xE8:
            rel = struct.unpack_from("<i", buf, i + 1)[0]
            src = va + (i - ro)
            if src + 5 + rel == target: out.append(src)
        i += 1
    return out

def find_all(buf, pat):
    out = []; i = 0
    while True:
        j = buf.find(pat, i)
        if j < 0: break
        out.append(j); i = j + 1
    return out

def plant(baseb, rvas, label):
    pe2 = bytearray(baseb); s = pe_secs(pe2)
    for rva in rvas:
        pe2[rva2off(pe2, s, rva)] = 0xCC
    out = cave / f"_dig_host_ied_{label}.exe"
    out.write_bytes(pe2); return out

def run(h, src="p_ret_lit.x", timeout=5):
    out = cave / f"_tmp_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except Exception: pass
    try:
        r = subprocess.run([str(h), str(cave / src), "-o", str(out)],
                           capture_output=True, timeout=timeout)
        crc = r.returncode & 0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT", "-", b""
    tag = {0x80000003: "INT3", 0xC0000005: "AV", 0xC0000409: "GS", 0: "OK"}.get(crc, f"crc={crc:#x}")
    b = out.read_bytes() if out.exists() else b""
    sh = hashlib.sha256(b).hexdigest()[:12] if b else "-"
    return tag, sh, b

def clean():
    for p in list(cave.glob("_dig_host_ied_*.exe")) + list(cave.glob("_tmp__dig_host_ied_*")):
        try: p.unlink()
        except Exception: pass

clean()
base = bytearray((cave / "xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12] == "9378df517f96"
secs = pe_secs(base)

# pre_last full + E8 map
print("=== pre_last @567a30 (HIT) ===", flush=True)
dump(base, secs, 0x567a30, 0x180, "pre_last")
print("E8→pre_last", [hex(c) for c in e8_callers(base, secs, 0x567a30)], flush=True)
o0 = rva2off(base, secs, 0x567a30)
print("pre_last internal E8:", flush=True)
for i in range(o0, o0 + 0x600):
    if base[i] == 0xE8:
        rel = struct.unpack_from("<i", base, i + 1)[0]
        src = 0x567a30 + (i - o0); tgt = src + 5 + rel
        if 0x100000 <= tgt < 0x700000:
            print(f"  @{src:06x} -> @{tgt:06x}", flush=True)

# Capless call to pre_last
dump(base, secs, 0x5781f0, 0x50, "Capless_e8_prelast")

# last @57b98c CapFN path — dump around CapFN call + after
print("\n=== last @57b98c CapFN + after (Capless last-call) ===", flush=True)
dump(base, secs, 0x57bb10, 0xc0, "last_CapFN_zone")

# @5180bd / @5182da mov *,0x48
print("\n=== @5180bd / @5182da mov*,0x48 (possible REX.W emit) ===", flush=True)
for r in (0x5180bd, 0x5182da):
    dump(base, secs, r - 0x30, 0xa0, f"around_{r:06x}")
    # find FN entry
    for back in range(0, 0x80):
        rr = r - back
        o = rva2off(base, secs, rr)
        if base[o] == 0x55 and base[o+1] == 0x48:
            print(f"  FN @{rr:06x} callers {[hex(c) for c in e8_callers(base, secs, rr)[:10]]}", flush=True)
            break

# Search broader for emit_u8(0x81) / emit patterns near 0x51xxxx
print("\n=== band 0x510000-0x520000 mov imm 0x81 / 0xEC ===", flush=True)
for imm, nm in [(0x81, "0x81"), (0xec, "0xEC"), (0x48, "0x48")]:
    hits = []
    for reg in range(8):
        pat = bytes([0xB8 + reg]) + struct.pack("<I", imm)
        for o in find_all(bytes(base), pat):
            r = off2rva(secs, o)
            if r and 0x510000 <= r < 0x520000:
                hits.append((r, reg))
    print(f"  mov r,{nm}: {[hex(h[0]) for h in hits[:12]]}", flush=True)

# Imm 0x68/0x1b8 in 0x510000-0x520000 (enc band?)
print("\n=== band 0x51 frame_sz imm ===", flush=True)
for imm in (0x68, 0x1b8, 0x868, 0x878):
    hits = []
    for o in find_all(bytes(base), b"\xb8" + struct.pack("<I", imm)):
        r = off2rva(secs, o)
        if r and 0x510000 <= r < 0x560000:
            hits.append(r)
    print(f"  mov eax,{imm:#x} in 51-56: {[hex(x) for x in hits[:10]]}", flush=True)

# INT3 frontier
print("\n=== INT3 pre_last internals + enc-ish + last CapFN zone ===", flush=True)
sites = [
    (0x567a30, "pre_last"),
    (0x57820f, "cap_e8_prelast"),
    (0x57bb30, "last_e8_CapFN"),
    (0x57b98c, "last_entry"),
    (0x5180bd, "mov48_a"),
    (0x5182da, "mov48_b"),
]
# add pre_last E8 targets (first 8)
for i in range(o0, o0 + 0x600):
    if base[i] == 0xE8:
        rel = struct.unpack_from("<i", base, i + 1)[0]
        src = 0x567a30 + (i - o0); tgt = src + 5 + rel
        if 0x200000 <= tgt < 0x600000:
            sites.append((tgt, f"pl_tgt_{tgt:06x}"))
            sites.append((src, f"pl_e8_{src:06x}"))
        if len([s for s in sites if s[1].startswith("pl_")]) >= 16:
            break

# FN containing 5180bd
for back in range(0, 0x80):
    rr = 0x5180bd - back
    o = rva2off(base, secs, rr)
    if base[o] == 0x55 and base[o+1] == 0x48:
        sites.append((rr, f"enc48_fn_{rr:06x}"))
        break

hits = []
for rva, name in sites:
    if time.time() - T0 > BUDGET - 12:
        print("BUDGET", flush=True); break
    t1 = time.time()
    tag, sh, b = run(plant(base, [rva], name), timeout=5)
    mark = ""
    if tag == "INT3":
        mark = " HIT"; hits.append((rva, name))
    elif tag == "TIMEOUT":
        mark = " TIMEOUT"
    elif tag in ("AV", "GS"):
        mark = f" **{tag}**"
    print(f"  @{rva:06x} {name:28s} -> {tag:8s}{mark} ({time.time()-t1:.1f}s)", flush=True)

# If mov48 HIT, try plant: change nearby frame? First report.
# Try isolatable plant: if pre_last or enc has on-path mov eax,0x68 HIT — patch to 0x868
print("\n=== Re-check Capless-band/enc-band mov eax,0x68 INT3 ===", flush=True)
for rva in [0x553c15, 0x568303, 0x573d21, 0x573f60, 0x512d28, 0x547a3e]:
    if time.time() - T0 > BUDGET - 5:
        break
    tag, sh, b = run(plant(base, [rva], f"imm_{rva:06x}"), timeout=5)
    mark = " HIT" if tag == "INT3" else ""
    print(f"  @{rva:06x} -> {tag}{mark}", flush=True)

print(f"\nHITs: {[(hex(r),n) for r,n in hits]}", flush=True)
tag, sh, b = run(cave / "xlang_isol1060_alt_frame2.exe")
print(f"baseline {tag} sha={sh}", flush=True)
print(f"elapsed={time.time()-T0:.1f}s DONE", flush=True)
clean()
