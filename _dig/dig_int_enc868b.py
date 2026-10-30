"""DIG Capless-internal follow-up: CapFN HIT path + USER frame emit origin + @50f8a5.
Budget<=80s. Ban tip@121278/join/epi/LIVE/mega.
"""
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

def dump(buf, secs, rva, n=0x80, label=""):
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
    out = cave / f"_dig_host_ieb_{label}.exe"
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
    for p in list(cave.glob("_dig_host_ieb_*.exe")) + list(cave.glob("_tmp__dig_host_ieb_*")):
        try: p.unlink()
        except Exception: pass

clean()
base = bytearray((cave / "xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12] == "9378df517f96"
secs = pe_secs(base)

# CapFN full dump + its E8 helpers
print("=== CapFN @5752bc body (HIT on lit) ===", flush=True)
dump(base, secs, 0x5752bc, 0x120, "CapFN")
# Capless call sites into CapFN
for c in [0x576a98, 0x5775a7, 0x577b78]:
    dump(base, secs, c - 0x20, 0x50, f"caller_CapFN@{c:06x}")

# CapFN internal E8s
print("\n=== CapFN internal E8 map ===", flush=True)
o0 = rva2off(base, secs, 0x5752bc)
for i in range(o0, o0 + 0x700):
    if base[i] == 0xE8:
        rel = struct.unpack_from("<i", base, i + 1)[0]
        src = 0x5752bc + (i - o0); tgt = src + 5 + rel
        if 0x100000 <= tgt < 0x600000:
            print(f"  CapFN@{src:06x} -> @{tgt:06x}", flush=True)

# clc68 dump — confirm HOST stack vs USER emit
print("\n=== clc68 @55ab88 (HIT) ===", flush=True)
dump(base, secs, 0x55ab88, 0x80, "clc68")
print("E8→clc68", [hex(c) for c in e8_callers(base, secs, 0x55ab88)], flush=True)
dump(base, secs, 0x577ffc - 0x18, 0x40, "Capless_e8_clc68")

# Capless-band only HOST 0x868 @50f8a5
print("\n=== Capless-band HOST sub rsp,0x868 @50f8a5 ===", flush=True)
dump(base, secs, 0x50f890, 0x60, "band868")
print("E8→50f8a5-ish FN: find prol start", flush=True)
# walk back to push rbp / sub rsp
for back in range(0, 0x40):
    r = 0x50f8a5 - back
    o = rva2off(base, secs, r)
    if base[o] == 0x55:  # push rbp
        dump(base, secs, r, 0x50, f"prol_back{back}")
        print(f"  E8 callers of @{r:06x}: {[hex(c) for c in e8_callers(base, secs, r)[:10]]}", flush=True)
        break

# USER emit origin: who writes bytes 48 81 EC 68/1b8 into OUT?
# Search for imm32 0x68/0x1b8 near emit helpers that Capless reaches.
# Also search mov edx/r8d,0x68 and push 0x68 patterns in 0x51-0x58
print("\n=== Broader imm feeders near Capless emit (edx/r8d/push) ===", flush=True)
def scan_ops(buf, secs, lo, hi, imm):
    hits = []
    # B8+reg imm32
    for reg, nm in enumerate(["eax","ecx","edx","ebx","esp","ebp","esi","edi"]):
        pat = bytes([0xB8 + reg]) + struct.pack("<I", imm)
        for o in find_all(bytes(buf), pat):
            r = off2rva(secs, o)
            if r and lo <= r < hi:
                hits.append((r, f"mov {nm},{imm:#x}"))
    # 41 B8+ = mov r8d..r15d
    for reg, nm in enumerate(["r8d","r9d","r10d","r11d","r12d","r13d","r14d","r15d"]):
        pat = bytes([0x41, 0xB8 + reg]) + struct.pack("<I", imm)
        for o in find_all(bytes(buf), pat):
            r = off2rva(secs, o)
            if r and lo <= r < hi:
                hits.append((r, f"mov {nm},{imm:#x}"))
    # 68 xx = push imm32
    pat = b"\x68" + struct.pack("<I", imm)
    for o in find_all(bytes(buf), pat):
        r = off2rva(secs, o)
        if r and lo <= r < hi:
            hits.append((r, f"push {imm:#x}"))
    return hits

for imm in (0x68, 0x1b8, 0x868):
    hits = scan_ops(base, secs, 0x510000, 0x590000, imm)
    print(f"  band51-59 {imm:#x}: n={len(hits)} sample={[hex(h[0])+':'+h[1] for h in hits[:10]]}", flush=True)

# Capless lit path CapFN call sites INT3 which of 3 CapFN calls HIT
print("\n=== INT3 which Capless→CapFN call HIT ===", flush=True)
sites = [
    (0x576a98, "cap_e8_CapFN_a"),
    (0x5775a7, "cap_e8_CapFN_b"),
    (0x577b78, "cap_e8_CapFN_c"),
    (0x57bb30, "near_e8_CapFN"),
]
# CapFN SoftCap mode check area — find real bytes (prior @576b71 looked corrupted/data)
# Search Capless for cmp [rbp+0x4b0],1 SoftCap mode
print("\n=== Capless SoftCap-mode / frame-related cmp dump ===", flush=True)
dump(base, secs, 0x576a80, 0xa0, "around_CapFN_call_a")
dump(base, secs, 0x577580, 0x80, "around_CapFN_call_b")
dump(base, secs, 0x577b50, 0x80, "around_CapFN_call_c")

# Find enc that writes prologue: search for code that stores 0xEC81 (little-endian 81 EC as word) or builds it
# Pattern often: mov eax,0x68; ...; or template memcpy from HOST
# Check if USER out bytes 0x68/0x1b8 match HOST templates that Capless copies
print("\n=== USER baseline frames vs nearest HOST templates ===", flush=True)
tag, sh, b = run(cave / "xlang_isol1060_alt_frame2.exe")
print(f"baseline {tag} sha={sh}", flush=True)
# find sub rsp,0x68 and 0x1b8 in USER and show surrounding
for imm, lab in [(0x68, "u68"), (0x1b8, "u1b8")]:
    pat = b"\x48\x81\xec" + struct.pack("<I", imm)
    j = b.find(pat)
    if j >= 0:
        print(f"  USER {lab} at file+{j:#x}: {b[j:j+16].hex()}", flush=True)
        # also show if function has mov eax,7 (ret lit)
        window = b[max(0,j-0x20):j+0x40]
        print(f"    window: {window.hex()}", flush=True)

# INT3 CapFN-internal first few E8 targets + SoftCap-band @50f8a5 entry
print("\n=== INT3 CapFN-internal + band868 ===", flush=True)
# collect CapFN E8 targets
capfn_e8 = []
for i in range(o0, o0 + 0x700):
    if base[i] == 0xE8:
        rel = struct.unpack_from("<i", base, i + 1)[0]
        src = 0x5752bc + (i - o0); tgt = src + 5 + rel
        if 0x200000 <= tgt < 0x600000:
            capfn_e8.append((src, tgt))
for src, tgt in capfn_e8[:6]:
    sites.append((tgt, f"CapFN_tgt_{tgt:06x}"))
    sites.append((src, f"CapFN_e8_{src:06x}"))

# band868 FN entry (push rbp found above — recompute)
band_entry = None
for back in range(0, 0x40):
    r = 0x50f8a5 - back
    o = rva2off(base, secs, r)
    if base[o] == 0x55:
        band_entry = r; break
if band_entry:
    sites.append((band_entry, f"band868_entry_{band_entry:06x}"))

# Capless post CapFN success path — after CapFN returns
sites += [
    (0x576aa0, "after_CapFN_a"),  # rough; dump will refine
]

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

print(f"\nHITs: {[(hex(r),n) for r,n in hits]}", flush=True)
print(f"elapsed={time.time()-T0:.1f}s DONE", flush=True)
clean()
