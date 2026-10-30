"""DIG on-path emit_u32@5110f8 frame_sz feeder.
Base Isol alt_frame2 9378df517f96. Budget<=85s. Ban tip@121278/join/epi/LIVE/mega/arg-loop.
Question: who feeds 0x68/0x1b8 into emit_u32; can we retarget to SoftCap 0x868?
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64); md.detail = True

cave = Path("C:/xlang_tmp/p1060/cave")
os.chdir(str(cave))
T0 = time.time(); BUDGET = 85
EMIT_U32 = 0x5110f8
EMIT_U8 = 0x511018

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
        if kn == ".text":
            return v
    return None

def dump(buf, secs, rva, n=0x80, label=""):
    o = rva2off(buf, secs, rva)
    print(f"--- {label} @{rva:06x} ---", flush=True)
    for insn in md.disasm(bytes(buf[o:o+n]), rva):
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)

def e8_callers(buf, secs, target, limit=80):
    t = text_range(secs)
    if not t: return []
    va, vs, ro, rs = t
    callers = []; i = ro; end = ro + rs - 5
    while i <= end and len(callers) < limit:
        if buf[i] == 0xE8:
            rel = struct.unpack_from("<i", buf, i + 1)[0]
            src = va + (i - ro)
            if src + 5 + rel == target:
                callers.append(src)
        i += 1
    return callers

def find_all(buf, pat):
    out = []; i = 0
    while True:
        j = buf.find(pat, i)
        if j < 0: break
        out.append(j); i = j + 1
    return out

def plant_int3(baseb, rvas, label):
    pe2 = bytearray(baseb); s = pe_secs(pe2)
    for rva in rvas:
        pe2[rva2off(pe2, s, rva)] = 0xCC
    out = cave / f"_dig_host_fu_{label}.exe"
    out.write_bytes(pe2); return out

def run_host(h, src="p_ret_lit.x", timeout=5):
    out = cave / f"_tmp_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except Exception: pass
    try:
        r = subprocess.run([str(h), str(cave / src), "-o", str(out)],
                           capture_output=True, timeout=timeout)
        crc = r.returncode & 0xFFFFFFFF
    except subprocess.TimeoutExpired:
        # kill leftover if any
        return "TIMEOUT", "-", 0, b""
    tag = {0x80000003: "INT3", 0xC0000005: "AV", 0xC0000409: "GS", 0: "OK"}.get(crc, f"crc={crc:#x}")
    b = out.read_bytes() if out.exists() else b""
    sh = hashlib.sha256(b).hexdigest()[:12] if b else "-"
    return tag, sh, len(b), b

def clean():
    for p in list(cave.glob("_dig_host_fu_*.exe")) + list(cave.glob("_tmp__dig_host_fu_*")):
        try: p.unlink()
        except Exception: pass
    for p in cave.glob("xlang_isol1060_feed_u32.exe"):
        try: p.unlink()
        except Exception: pass

def scan_window_imms(buf, secs, call_rva, before=0x40, after=0x8):
    """Disasm window before call; collect imm loads of interest + movs into arg regs."""
    start = max(0, call_rva - before)
    o = rva2off(buf, secs, start)
    n = before + after
    imms = []
    feeders = []  # (rva, text) sites that load 0x68/0x1b8/0x868 near call
    for insn in md.disasm(bytes(buf[o:o+n]), start):
        if insn.address > call_rva + after:
            break
        t = f"{insn.mnemonic} {insn.op_str}"
        # imm32 in op_str
        for imm in (0x68, 0x1b8, 0x868, 0x878):
            if f"0x{imm:x}" in insn.op_str.lower() or f"{imm}" == insn.op_str.split(",")[-1].strip():
                # also catch decimal
                pass
            if hex(imm) in insn.op_str.lower() or f", {imm}" in insn.op_str or f",{imm}" in insn.op_str:
                feeders.append((insn.address, t, imm))
        # capture mov edx/ecx/eax/r8d,imm
        if insn.mnemonic.startswith("mov") and any(r in insn.op_str for r in ("edx", "ecx", "eax", "r8d", "r9d", "esi", "edi")):
            if "0x" in insn.op_str or any(c.isdigit() for c in insn.op_str.split(",")[-1]):
                imms.append((insn.address, t))
    return imms, feeders

clean()
base = bytearray((cave / "xlang_isol1060_alt_frame2.exe").read_bytes())
secs = pe_secs(base)
print(f"base sha12={hashlib.sha256(bytes(base)).hexdigest()[:12]} size={len(base)}", flush=True)

print("\n=== emit_u32 body ===", flush=True)
dump(base, secs, EMIT_U32, n=0x60, label="emit_u32")

print("\n=== emit_u8 body ===", flush=True)
dump(base, secs, EMIT_U8, n=0x40, label="emit_u8")

callers = e8_callers(base, secs, EMIT_U32, limit=80)
print(f"\n=== E8 callers of emit_u32@5110f8: n={len(callers)} ===", flush=True)
for c in callers[:40]:
    print(f"  @{c:06x}", flush=True)

# Classify callers by nearby imm 0x68/0x1b8/0x868
print("\n=== Caller windows: imm 0x68/0x1b8/0x868 feeders ===", flush=True)
interesting = []  # (call_rva, feeder_rva, text, imm)
all_near_imms = []
for c in callers:
    imms, feeders = scan_window_imms(base, secs, c, before=0x50, after=0x4)
    if feeders:
        for fr, t, imm in feeders:
            print(f"  call@{c:06x} feeder@{fr:06x}: {t} imm={imm:#x}", flush=True)
            interesting.append((c, fr, t, imm))
    # also note mov edx,imm near call regardless
    for ir, t in imms:
        if "edx" in t or "ecx" in t or "eax" in t:
            all_near_imms.append((c, ir, t))

# Broader: find all mov reg,0x68 / 0x1b8 in enc-band near emit helpers (0x510000-0x520000)
print("\n=== enc-band mov *,0x68 / 0x1b8 / 0x868 (0x50f000-0x520000) ===", flush=True)
band_lo, band_hi = 0x50f000, 0x520000
for imm in (0x68, 0x1b8, 0x868):
    pat = struct.pack("<I", imm)
    for o in find_all(bytes(base), pat):
        r = off2rva(secs, o)
        if r is None or not (band_lo <= r < band_hi):
            continue
        if o < 1: continue
        prev = base[o-1]
        if 0xB8 <= prev <= 0xBF:
            print(f"  @{r-1:06x}: mov r{prev-0xB8},{imm:#x}", flush=True)
            interesting.append((None, r-1, f"mov r{prev-0xB8},{imm:#x}", imm))
        elif prev == 0xBA:  # mov edx,imm32 is B8+2=BA
            print(f"  @{r-1:06x}: mov edx,{imm:#x}", flush=True)

# Also scan Capless body band for mov before emit_u32 call sites specifically
# Dump each interesting caller +/- 0x30
print("\n=== Dump top callers with nearby size imms ===", flush=True)
seen_c = set()
for c, fr, t, imm in interesting:
    if c is None or c in seen_c: continue
    if imm in (0x68, 0x1b8, 0x868):
        seen_c.add(c)
        dump(base, secs, c - 0x30, n=0x50, label=f"call_near_{c:06x}")

# Also dump ALL callers that are in Capless-ish range 0x55xxxx-0x58xxxx or enc 0x51xxxx
print("\n=== Capless/enc-range callers dump (sample) ===", flush=True)
cap_callers = [c for c in callers if 0x550000 <= c < 0x590000 or 0x510000 <= c < 0x520000]
print(f"  cap/enc callers n={len(cap_callers)}", flush=True)
for c in cap_callers[:12]:
    dump(base, secs, c - 0x28, n=0x40, label=f"cap_call_{c:06x}")

# INT3 probe plan: emit_u32 itself (confirm HIT), unique feeder sites, call sites near 0x68/0x1b8
print("\n=== INT3 probe ===", flush=True)
sites = [(EMIT_U32, "emit_u32")]
# unique feeders
seen_f = set()
for c, fr, t, imm in interesting:
    if fr in seen_f: continue
    if imm in (0x68, 0x1b8):
        seen_f.add(fr)
        sites.append((fr, f"feed_{imm:x}_{fr:06x}"))
# call sites that had feeders
seen_c2 = set()
for c, fr, t, imm in interesting:
    if c is None or c in seen_c2: continue
    if imm in (0x68, 0x1b8):
        seen_c2.add(c)
        sites.append((c, f"e8_u32_{c:06x}"))

# Also probe a few Capless-range callers even without nearby imm (arg may be register-fed)
for c in cap_callers[:8]:
    if c not in seen_c2 and all(c != s[0] for s in sites):
        sites.append((c, f"e8_cap_{c:06x}"))

# Cap callers' preceding instruction INT3 (the mov that sets arg) — scan 0x20 before for last mov *dx/eax
for c in cap_callers[:10]:
    o0 = rva2off(base, secs, c - 0x20)
    last_mov = None
    for insn in md.disasm(bytes(base[o0:o0+0x20]), c - 0x20):
        if insn.address >= c: break
        if insn.mnemonic.startswith("mov") and any(r in insn.op_str for r in ("edx", "eax", "ecx", "r8d")):
            last_mov = (insn.address, f"{insn.mnemonic} {insn.op_str}")
    if last_mov and all(last_mov[0] != s[0] for s in sites):
        sites.append((last_mov[0], f"premov_{last_mov[0]:06x}"))

hits = []
for rva, name in sites:
    if time.time() - T0 > BUDGET - 18:
        print("BUDGET", flush=True); break
    t1 = time.time()
    tag, sh, sz, b = run_host(plant_int3(base, [rva], name), timeout=5)
    mark = ""
    if tag == "INT3":
        mark = " HIT"; hits.append((rva, name, sh, b))
    elif tag == "TIMEOUT":
        mark = " TIMEOUT"
    elif tag in ("AV", "GS"):
        mark = f" **{tag}**"
    print(f"  @{rva:06x} {name:32s} -> {tag:8s}{mark} ({time.time()-t1:.1f}s)", flush=True)

print(f"\nHITs: {[(hex(r), n) for r,n,_,_ in hits]}", flush=True)

# If any feeder HIT with 0x68 or 0x1b8 — try plant to 0x868
print("\n=== Plant attempt feed→0x868 if HIT ===", flush=True)
planted = False
for rva, name, sh, b in hits:
    if not name.startswith("feed_"): continue
    o = rva2off(base, secs, rva)
    # expect B8+reg + imm32
    if not (0xB8 <= base[o] <= 0xBF):
        print(f"  skip @{rva:06x} not B8-form bytes={bytes(base[o:o+5]).hex()}", flush=True)
        continue
    imm = struct.unpack_from("<I", base, o+1)[0]
    if imm not in (0x68, 0x1b8):
        print(f"  skip @{rva:06x} imm={imm:#x}", flush=True)
        continue
    pe2 = bytearray(base)
    pe2[o+1:o+5] = struct.pack("<I", 0x868)
    outp = cave / "xlang_isol1060_feed_u32.exe"
    outp.write_bytes(pe2)
    print(f"  planted feed_u32 @{rva:06x} {imm:#x}->0x868 sha12={hashlib.sha256(bytes(pe2)).hexdigest()[:12]}", flush=True)
    planted = True
    for src in ("p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x"):
        if time.time() - T0 > BUDGET - 5: break
        if not (cave / src).exists(): continue
        tag, sh2, sz, bb = run_host(outp, src=src, timeout=8)
        pat868 = b"\x48\x81\xec" + struct.pack("<I", 0x868)
        pat1b8 = b"\x48\x81\xec" + struct.pack("<I", 0x1b8)
        pat68 = b"\x48\x81\xec" + struct.pack("<I", 0x68)
        print(f"  plant {src}: {tag} sha={sh2} 868={pat868 in bb} 1b8={pat1b8 in bb} 68={pat68 in bb}", flush=True)
        if bb and tag == "OK":
            tmp = cave / f"_tmp_{outp.stem}_{Path(src).stem}.exe"
            if tmp.exists():
                try:
                    r = subprocess.run([str(tmp)], capture_output=True, timeout=5)
                    print(f"    run rc={r.returncode}", flush=True)
                except Exception as e:
                    print(f"    run err {e}", flush=True)
    break  # one plant site only

if not planted:
    print("  no HIT feeder plantable this beat — not isolatable as feed_u32/fsz_868", flush=True)

# baseline
tag, sh, sz, b = run_host(cave / "xlang_isol1060_alt_frame2.exe", timeout=8)
pat868 = b"\x48\x81\xec" + struct.pack("<I", 0x868)
pat1b8 = b"\x48\x81\xec" + struct.pack("<I", 0x1b8)
pat68 = b"\x48\x81\xec" + struct.pack("<I", 0x68)
print(f"baseline {tag} sha={sh} 868={pat868 in b} 1b8={pat1b8 in b} 68={pat68 in b}", flush=True)
print(f"elapsed={time.time()-T0:.1f}s DONE", flush=True)
clean()
# also remove plant host leftovers from cave after reporting
for p in cave.glob("xlang_isol1060_feed_u32.exe"):
    try: p.unlink()
    except Exception: pass
for p in list(cave.glob("_dig_host_fu_*.exe")) + list(cave.glob("_tmp__dig_host_fu_*")):
    try: p.unlink()
    except Exception: pass
