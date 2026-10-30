"""DIG Capless-internal USER enc: who selects frame_sz, who calls enc_prologue.
Base alt_frame2 9378df517f96. Budget<=85s. Ban tip@121278/join/epi/LIVE/mega/arg-loop.
Goal: SoftCap lit 0x868 vs thin 0x68/0x1b8 — Capless-internal path only.
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

def dump(buf, secs, rva, n=0x60, label=""):
    o = rva2off(buf, secs, rva)
    print(f"--- {label} @{rva:06x} ---", flush=True)
    for insn in md.disasm(bytes(buf[o:o+n]), rva):
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)

def e8_callers(buf, secs, target, limit=40):
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
    out = cave / f"_dig_host_ie_{label}.exe"
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
        return "TIMEOUT", "-", 0, b""
    tag = {0x80000003: "INT3", 0xC0000005: "AV", 0xC0000409: "GS", 0: "OK"}.get(crc, f"crc={crc:#x}")
    b = out.read_bytes() if out.exists() else b""
    sh = hashlib.sha256(b).hexdigest()[:12] if b else "-"
    return tag, sh, len(b), b

def clean():
    for p in list(cave.glob("_dig_host_ie_*.exe")) + list(cave.glob("_tmp__dig_host_ie_*")):
        try: p.unlink()
        except Exception: pass

def scan_imm_mov(buf, secs, lo, hi, imm):
    """Find mov eax/ecx/edx/r8d,imm32 in [lo,hi) RVA."""
    pat = struct.pack("<I", imm)
    hits = []
    for o in find_all(bytes(buf), pat):
        r = off2rva(secs, o)
        if r is None or not (lo <= r < hi):
            continue
        # check preceding opcode byte
        if o < 1: continue
        prev = buf[o-1]
        # B8+reg = mov reg,imm32; C7 /0 = mov r/m,imm32 (skip complex)
        if 0xB8 <= prev <= 0xBF:
            hits.append((r-1, f"mov r{(prev-0xB8)},{imm:#x}"))
        elif prev == 0xC7 and o >= 2:
            hits.append((r-2, f"mov_rm,{imm:#x}"))
    return hits

clean()
base = bytearray((cave / "xlang_isol1060_alt_frame2.exe").read_bytes())
sha = hashlib.sha256(bytes(base)).hexdigest()[:12]
assert sha == "9378df517f96", sha
secs = pe_secs(base)
print(f"base alt_frame2 sha12={sha} BUDGET={BUDGET}s", flush=True)

# --- 1) Capless-internal E8 map (known emit helpers) ---
print("\n=== Capless body E8 → known helpers ===", flush=True)
known = {
    0x53ff24: "mov_imm_w", 0x5264bc: "arch_E8", 0x51a534: "E8enc",
    0x57464c: "post_args", 0x5752bc: "CapFN", 0x522c0c: "CE",
    0x55ab88: "clc68", 0x57b98c: "last", 0x567a30: "pre_last",
    0x1ffefe: "early_cl", 0x24b022: "join_helper",
}
CAP_LO, CAP_HI = 0x57656c, 0x57656c + 0x1d00
o0 = rva2off(base, secs, CAP_LO)
cap_calls = []
i = o0; end = o0 + 0x1d00
while i < end - 5:
    if base[i] == 0xE8:
        rel = struct.unpack_from("<i", base, i + 1)[0]
        src = CAP_LO + (i - o0); tgt = src + 5 + rel
        name = known.get(tgt, "")
        if name or (0x510000 <= tgt < 0x5c0000):
            cap_calls.append((src, tgt, name or f"@{tgt:06x}"))
    i += 1
# collapse unique targets with first call site
by_tgt = {}
for src, tgt, name in cap_calls:
    by_tgt.setdefault(tgt, (src, name))
print(f"  Capless E8 unique targets in band: {len(by_tgt)}", flush=True)
for tgt, (src, name) in sorted(by_tgt.items(), key=lambda x: x[0])[:40]:
    print(f"  Capless@{src:06x} -> {tgt:06x} {name}", flush=True)

# --- 2) Dump key helpers that may select frame_sz / call enc ---
print("\n=== Dump CapFN / post_args / clc68 / pre_last / mov_imm_w prol ===", flush=True)
for rva, lab in [
    (0x5752bc, "CapFN"), (0x57464c, "post_args"), (0x55ab88, "clc68"),
    (0x567a30, "pre_last"), (0x53ff24, "mov_imm_w"), (0x51a534, "E8enc"),
    (0x5264bc, "arch_E8"),
]:
    dump(base, secs, rva, 0x50, lab)

# --- 3) Who writes USER frame imm into enc arg? Scan Capless+helpers for 0x68/0x1b8/0x868 ---
print("\n=== Imm scan Capless FN + CapFN/post_args/pre_last bands ===", flush=True)
bands = [
    ("Capless", 0x57656c, 0x578300),
    ("CapFN", 0x5752bc, 0x5752bc + 0x800),
    ("post_args", 0x57464c, 0x57464c + 0x600),
    ("pre_last", 0x567a30, 0x567a30 + 0x800),
    ("clc68", 0x55ab88, 0x55ab88 + 0x200),
    ("mov_imm_w", 0x53ff24, 0x53ff24 + 0x200),
    ("E8enc", 0x51a534, 0x51a534 + 0x300),
]
for lab, lo, hi in bands:
    for imm in (0x68, 0x1b8, 0x868, 0x878):
        hits = scan_imm_mov(base, secs, lo, hi, imm)
        if hits:
            print(f"  {lab} mov*,{imm:#x}: n={len(hits)} {[hex(h[0])+':'+h[1] for h in hits[:6]]}", flush=True)
        else:
            print(f"  {lab} mov*,{imm:#x}: n=0", flush=True)

# --- 4) enc_prologue / compute_frame_size string LEA xrefs — confirm not emit ---
print("\n=== String LEA xrefs enc_prologue / compute_frame_size ===", flush=True)
def lea_xrefs(buf, secs, str_rva, limit=12):
    # RIP-relative LEA: 48 8D xx XX XX XX XX where disp lands on str
    t = text_range(secs)
    if not t: return []
    va, vs, ro, rs = t
    out = []; i = ro; end = ro + rs - 7
    while i <= end and len(out) < limit:
        if buf[i] == 0x48 and buf[i+1] == 0x8D:
            # ModRM: if RIP-rel (mod=00 rm=101)
            modrm = buf[i+2]
            if (modrm & 0xC7) == 0x05:
                disp = struct.unpack_from("<i", buf, i + 3)[0]
                src = va + (i - ro)
                tgt = src + 7 + disp
                if tgt == str_rva:
                    out.append(src)
        i += 1
    return out

for s_rva, sname in [(0xdcd2d9, "enc_prologue"), (0x658417, "compute_frame_size")]:
    xs = lea_xrefs(base, secs, s_rva, limit=10)
    print(f"  {sname}@{s_rva:06x} lea xrefs: {[hex(x) for x in xs]}", flush=True)
    for x in xs[:3]:
        dump(base, secs, x - 0x10, 0x40, f"lea_{sname}@{x:06x}")

# --- 5) Find E8 callers of CapFN / post_args / pre_last / E8enc INSIDE Capless path ---
print("\n=== E8 callers of CapFN/post_args/pre_last (Capless-side vs others) ===", flush=True)
for tgt, name in [(0x5752bc, "CapFN"), (0x57464c, "post_args"), (0x567a30, "pre_last"),
                  (0x51a534, "E8enc"), (0x53ff24, "mov_imm_w"), (0x55ab88, "clc68")]:
    cs = e8_callers(base, secs, tgt, limit=30)
    in_cap = [c for c in cs if CAP_LO <= c < CAP_HI]
    near = [c for c in cs if 0x550000 <= c < 0x590000]
    print(f"  {name}@{tgt:06x}: callers={len(cs)} in_Capless={len(in_cap)} near55-59={[hex(c) for c in near[:8]]}", flush=True)

# --- 6) Look for sub rsp,imm32 writers that look like USER-template emitters
#     HOST has 29x 0x868; USER emit comes from enc writing those bytes into OUT PE.
#     Search Capless-band for push of frame imm pattern / template bytes 48 81 EC
print("\n=== Capless-band template bytes 48 81 EC xx (prologue emit seeds?) ===", flush=True)
for imm in (0x68, 0x1b8, 0x868, 0x878):
    pat = b"\x48\x81\xec" + struct.pack("<I", imm)
    offs = find_all(bytes(base), pat)
    rvas = []
    for o in offs:
        r = off2rva(secs, o)
        if r is not None:
            rvas.append(r)
    in_cap = [r for r in rvas if 0x500000 <= r < 0x5c0000]
    tipb = [r for r in rvas if 0x120000 <= r < 0x130000]
    print(f"  HOST sub rsp,{imm:#x}: n={len(rvas)} Capless-band={ [hex(x) for x in in_cap[:8]] } tipband={[hex(x) for x in tipb[:6]]}", flush=True)

# --- 7) CapFN SoftCap early-out @576b71 context (prior) — dump around ---
print("\n=== Capless CapFN SoftCap early-out @576b71 + CALL body @577c24 ===", flush=True)
dump(base, secs, 0x576b60, 0x50, "capfn_sc_early")
dump(base, secs, 0x577c10, 0x50, "call_kind3")
dump(base, secs, 0x578170, 0x40, "h_emit_area")

# --- 8) INT3 frontier: Capless-internal enc sites ---
print("\n=== INT3 Capless-internal USER enc frontier ===", flush=True)
sites = [
    (0x5752bc, "CapFN_entry"),
    (0x57464c, "post_args"),
    (0x567a30, "pre_last"),
    (0x55ab88, "clc68"),
    (0x53ff24, "mov_imm_w"),
    (0x51a534, "E8enc"),
    (0x5264bc, "arch_E8"),
    (0x576b71, "capfn_sc_early"),
    (0x577c24, "call_kind3"),
    (0x578184, "h_emit"),
]
# add Capless-internal first E8 to CapFN / post_args if present
for tgt, name in [(0x5752bc, "e8_CapFN"), (0x57464c, "e8_post"), (0x567a30, "e8_prelast"),
                  (0x55ab88, "e8_clc68"), (0x51a534, "e8_E8enc")]:
    for src, t2, _ in cap_calls:
        if t2 == tgt:
            sites.append((src, f"{name}_@{src:06x}"))
            break

# Capless-band mov eax,0x68 / 0x1b8 that might feed enc (broader than prior)
for imm, tag in [(0x68, "eax68"), (0x1b8, "eax1b8")]:
    hits = scan_imm_mov(base, secs, 0x550000, 0x590000, imm)
    for h, _lab in hits[:3]:
        sites.append((h, f"{tag}_{h:06x}"))

hit_list = []
for rva, name in sites:
    if time.time() - T0 > BUDGET - 15:
        print("BUDGET", flush=True); break
    t1 = time.time()
    tag, sh, sz, b = run_host(plant_int3(base, [rva], name), timeout=5)
    mark = ""
    if tag == "INT3":
        mark = " HIT"; hit_list.append((rva, name))
    elif tag == "TIMEOUT":
        mark = " TIMEOUT"
    elif tag in ("AV", "GS"):
        mark = f" **{tag}**"
    print(f"  @{rva:06x} {name:28s} -> {tag:8s}{mark} ({time.time()-t1:.1f}s)", flush=True)

# --- 9) baseline frames ---
pat868 = b"\x48\x81\xec" + struct.pack("<I", 0x868)
pat68 = b"\x48\x81\xec" + struct.pack("<I", 0x68)
pat1b8 = b"\x48\x81\xec" + struct.pack("<I", 0x1b8)
tag, sh, sz, b = run_host(cave / "xlang_isol1060_alt_frame2.exe", "p_ret_lit.x", timeout=8)
print(f"\nbaseline lit: {tag} sha={sh} 868={pat868 in b} 68={pat68 in b} 1b8={pat1b8 in b}", flush=True)

print(f"\nHIT sites: {[(hex(r), n) for r, n in hit_list]}", flush=True)
print(f"elapsed={time.time()-T0:.1f}s DONE", flush=True)
clean()
print("PROD/pin untouched; ban tip@121278/join/epi/LIVE/mega", flush=True)
