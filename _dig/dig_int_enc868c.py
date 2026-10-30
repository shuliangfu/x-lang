"""DIG Capless-internal: on-path Capless E8 HIT map + @57bb30 CapFN + @55d948 + USER enc writer.
Budget<=85s. Ban tip@121278/join/epi/LIVE/mega.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64)

cave = Path("C:/xlang_tmp/p1060/cave"); os.chdir(str(cave))
T0 = time.time(); BUDGET = 85

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

def dump(buf, secs, rva, n=0x70, label=""):
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
    out = cave / f"_dig_host_iec_{label}.exe"
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
    for p in list(cave.glob("_dig_host_iec_*.exe")) + list(cave.glob("_tmp__dig_host_iec_*")):
        try: p.unlink()
        except Exception: pass

clean()
base = bytearray((cave / "xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12] == "9378df517f96"
secs = pe_secs(base)

CAP_LO, CAP_HI = 0x57656c, 0x578300

# 1) Capless unique E8 targets — INT3 TARGET entries (not call sites) for on-path map
print("=== Capless E8 unique targets (sample) ===", flush=True)
o0 = rva2off(base, secs, CAP_LO)
by_tgt = {}
i = o0; end = o0 + (CAP_HI - CAP_LO)
while i < end - 5:
    if base[i] == 0xE8:
        rel = struct.unpack_from("<i", base, i + 1)[0]
        src = CAP_LO + (i - o0); tgt = src + 5 + rel
        if 0x100000 <= tgt < 0x700000:
            by_tgt.setdefault(tgt, src)
    i += 1
print(f"  unique targets: {len(by_tgt)}", flush=True)

# 2) @57bb30 CapFN caller context
print("\n=== @57bb30 CapFN caller (HIT; outside Capless FN) ===", flush=True)
dump(base, secs, 0x57bb00, 0xa0, "near_57bb30")
print("E8→5752bc CapFN callers:", [hex(c) for c in e8_callers(base, secs, 0x5752bc)], flush=True)
# find FN prol containing 57bb30
for back in range(0, 0x200):
    r = 0x57bb30 - back
    o = rva2off(base, secs, r)
    if base[o] == 0x55 and base[o+1] == 0x48 and base[o+2] == 0x89 and base[o+3] == 0xe5:
        dump(base, secs, r, 0x40, f"FN_prol@{r:06x}")
        print(f"  CapFN-caller FN entry @{r:06x}; E8 callers: {[hex(c) for c in e8_callers(base, secs, r)[:8]]}", flush=True)
        break

# 3) CapFN→@55d948 dump
print("\n=== CapFN helper @55d948 (HIT) ===", flush=True)
dump(base, secs, 0x55d948, 0xa0, "h55d948")
# CapFN e8 @575316
dump(base, secs, 0x575300, 0x50, "CapFN_around_e8")

# 4) Search enc_prologue-like: functions that take size and write 81 EC
# Heuristic: look for mov [mem], 0xEC81 or write of byte 0x48 then 0x81 then 0xEC
# Or: lea/mov of immediate template. Search for C7 00 81 EC / C7 01 / etc
print("\n=== Search write-imm of 0xEC81 / prologue opcode builders ===", flush=True)
# little-endian store of 81 EC xx xx as dword start: C7 /0 with imm including 00EC81??
# Simpler: find 81 EC as immediate in mov: B8 81 EC 00 00 or C7 xx 81 EC 00 00
for pat, lab in [
    (b"\xb8\x81\xec\x00\x00", "mov eax,0xec81"),
    (b"\xb9\x81\xec\x00\x00", "mov ecx,0xec81"),
    (b"\xba\x81\xec\x00\x00", "mov edx,0xec81"),
    (b"\x41\xb8\x81\xec\x00\x00", "mov r8d,0xec81"),
    (b"\xc7\x00\x81\xec\x00\x00", "mov [rax],0xec81"),
    (b"\xc7\x01\x81\xec\x00\x00", "mov [rcx],0xec81"),
    (b"\xc7\x02\x81\xec\x00\x00", "mov [rdx],0xec81"),
    (b"\x66\xb8\x81\xec", "mov ax,0xec81"),
    (b"\xb8\x48\x81\xec\x00", "mov eax,0xec8148?"),  # unlikely aligned
]:
    offs = find_all(bytes(base), pat)
    rvas = [off2rva(secs, o) for o in offs]
    rvas = [r for r in rvas if r]
    band = [r for r in rvas if 0x500000 <= r < 0x5c0000]
    print(f"  {lab}: n={len(rvas)} band={[hex(x) for x in band[:8]]} all_sample={[hex(x) for x in rvas[:6]]}", flush=True)

# Also search for byte-emit of 0x48,0x81,0xEC sequence via consecutive stores
# Pattern in xlang enc often: emit_u8(0x48); emit_u8(0x81); emit_u8(0xEC); emit_u32(sz)
# Look for mov ecx,0x48 / mov edx,0x81 near each other in enc helpers
print("\n=== mov imm 0x48 / 0x81 near Capless-band (prologue opcode emit?) ===", flush=True)
hits48 = []
for o in find_all(bytes(base), b"\xb9\x48\x00\x00\x00"):  # mov ecx,0x48
    r = off2rva(secs, o)
    if r and 0x500000 <= r < 0x5c0000: hits48.append(r)
for o in find_all(bytes(base), b"\xba\x48\x00\x00\x00"):
    r = off2rva(secs, o)
    if r and 0x500000 <= r < 0x5c0000: hits48.append(r)
print(f"  mov e*x,0x48 band: {[hex(x) for x in hits48[:12]]}", flush=True)

# 5) INT3 Capless E8 TARGETS — budgeted sample prioritizing emit-ish names
print("\n=== INT3 Capless E8 targets (on-path map) ===", flush=True)
# prioritize known + first N unique
prio = [0x55ab88, 0x5752bc, 0x57464c, 0x567a30, 0x57b98c, 0x1ffefe, 0x24b022,
        0x530b50, 0x530a78, 0x1ff2ef, 0x55d948]
# add more from by_tgt sorted
tgts = list(prio)
for t in sorted(by_tgt.keys()):
    if t not in tgts:
        tgts.append(t)
    if len(tgts) >= 28:
        break

hits = []
oks = []
for tgt in tgts:
    if time.time() - T0 > BUDGET - 20:
        print("BUDGET", flush=True); break
    name = f"tgt_{tgt:06x}"
    t1 = time.time()
    tag, sh, b = run(plant(base, [tgt], name), timeout=5)
    mark = ""
    if tag == "INT3":
        mark = " HIT"; hits.append(tgt)
    elif tag == "TIMEOUT":
        mark = " TIMEOUT"; hits.append(tgt)  # on-path hang class
    elif tag == "OK":
        oks.append(tgt)
    elif tag in ("AV", "GS"):
        mark = f" **{tag}**"
    src = by_tgt.get(tgt, -1)
    print(f"  @{tgt:06x} (from Capless@{src:06x}) -> {tag:8s}{mark} ({time.time()-t1:.1f}s)", flush=True)

print(f"\nHIT/TIMEOUT targets: {[hex(x) for x in hits]}", flush=True)
print(f"OK (off-path) sample: {[hex(x) for x in oks[:12]]}", flush=True)

# 6) Dump HIT targets that look like enc
print("\n=== Dump new HIT targets ===", flush=True)
for t in hits:
    if t in (0x55ab88, 0x5752bc):  # already known
        continue
    dump(base, secs, t, 0x50, f"HIT_{t:06x}")

# 7) @55d948 imm scan for frame sizes
print("\n=== @55d948 FN band imm 0x68/0x1b8/0x868 ===", flush=True)
for imm in (0x68, 0x1b8, 0x868, 0x48, 0x81, 0xec):
    pat = struct.pack("<I", imm)
    n = 0; sample = []
    for o in find_all(bytes(base), b"\xb8" + pat):  # mov eax
        r = off2rva(secs, o)
        if r and 0x55d948 <= r < 0x55d948 + 0x400:
            n += 1; sample.append(hex(r))
    print(f"  mov eax,{imm:#x} in @55d948+0x400: n={n} {sample[:6]}", flush=True)

# baseline
pat868 = b"\x48\x81\xec" + struct.pack("<I", 0x868)
pat68 = b"\x48\x81\xec" + struct.pack("<I", 0x68)
tag, sh, b = run(cave / "xlang_isol1060_alt_frame2.exe")
print(f"\nbaseline {tag} sha={sh} 868={pat868 in b} 68={pat68 in b}", flush=True)
print(f"elapsed={time.time()-T0:.1f}s DONE", flush=True)
clean()
