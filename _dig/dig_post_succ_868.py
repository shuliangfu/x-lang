"""DIG Capless post-success → SoftCap USER frame_sz / enc_prologue(0x868).
Base alt_frame2 9378df517f96. Budget<=85s. Ban tip@121278/join/epi/LIVE transplant/arg-loop/mega.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64)

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
    try:
        o = rva2off(buf, secs, rva)
    except Exception as e:
        print(f"  dump fail @{rva:#x}: {e}", flush=True); return
    print(f"--- {label} @{rva:06x} ---", flush=True)
    for insn in md.disasm(bytes(buf[o:o+n]), rva):
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)

def e8_callers(buf, secs, target, limit=30):
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
    out = cave / f"_dig_host_ps_{label}.exe"
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
    for p in list(cave.glob("_dig_host_ps_*.exe")) + list(cave.glob("_tmp__dig_host_ps_*")):
        try: p.unlink()
        except Exception: pass

clean()
base = bytearray((cave / "xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12] == "9378df517f96"
secs = pe_secs(base)
print("base ok alt_frame2 9378df517f96", flush=True)

# --- 1) Capless FN @57656c: find early-success / post-success exits ---
print("\n=== Capless@57656c head + scan for early/post success (mov eax,1 / ret / jmp) ===", flush=True)
dump(base, secs, 0x57656c, 0x80, "capless_head")

# Disassemble larger Capless body looking for success patterns near known prior sites
# Prior: Capless early-success in SoftCap-full was @5890c8; Capless FN itself may return >0
# Scan Capless FN size: walk until ret after large add rsp / leave
print("\n=== Capless FN epi hunt (add rsp / pop / ret within +0x4000) ===", flush=True)
o0 = rva2off(base, secs, 0x57656c)
# Capless prol: expect push rbp / sub rsp
chunk = bytes(base[o0:o0+0x20])
print(f"  prol bytes: {chunk[:16].hex()}", flush=True)
# Find first leave/ret-ish after reasonable body: look for add rsp,imm32; pop rbp; ret
epi_cands = []
for off in range(0x40, 0x2800):
    at = o0 + off
    if at + 8 >= len(base): break
    # 48 81 C4 xx xx xx xx  = add rsp,imm32
    if base[at] == 0x48 and base[at+1] == 0x81 and base[at+2] == 0xC4:
        imm = struct.unpack_from("<I", base, at+3)[0]
        # following pop rbp; ret?
        nxt = bytes(base[at+7:at+10])
        epi_cands.append((0x57656c + off, imm, nxt.hex()))
        if len(epi_cands) >= 8: break
print(f"  add-rsp epi cands: {[(hex(a),hex(i),n) for a,i,n in epi_cands]}", flush=True)
for a, i, n in epi_cands[:3]:
    dump(base, secs, a - 0x10, 0x40, f"epi_cand@{a:06x}")

# --- 2) Capless success returns: mov eax,1 near Capless body ---
print("\n=== Capless body mov eax,1 / xor eax,eax near post-success ===", flush=True)
pat_eax1 = b"\xb8\x01\x00\x00\x00"
pat_xor = b"\x31\xc0"  # xor eax,eax
pat_xor2 = b"\x33\xc0"
eax1_in = []
for o in find_all(bytes(base[o0:o0+0x2800]), pat_eax1):
    eax1_in.append(0x57656c + o)
print(f"  mov eax,1 in Capless+0x2800: n={len(eax1_in)} sample={[hex(x) for x in eax1_in[:12]]}", flush=True)
for r in eax1_in[:6]:
    dump(base, secs, r - 0x08, 0x30, f"eax1@{r:06x}")

# --- 3) enc_prologue string + who loads frame_sz before call ---
print("\n=== enc_prologue / compute_frame_size string + nearby mov imm ===", flush=True)
for nd in [b"enc_prologue", b"arch_x86_64_enc_enc_prologue", b"compute_frame_size", b"pipeline_asm_compute_frame_size"]:
    offs = find_all(bytes(base), nd)
    print(f"  {nd.decode()}: n={len(offs)}", flush=True)
    for o in offs[:2]:
        r = off2rva(secs, o)
        print(f"    rva={r and hex(r)}", flush=True)

# Known string RVAs from prior DIG
for rva, name in [(0xdcd2d9, "enc_prologue"), (0x658417, "compute_frame_size")]:
    try:
        o = rva2off(base, secs, rva)
        print(f"  @{rva:#x} {name}: {bytes(base[o:o+40])!r}", flush=True)
    except Exception as e:
        print(f"  @{rva:#x}: {e}", flush=True)

# Find functions that encode sub rsp with imm — look for template bytes 48 81 EC near enc helpers
# Search lea xrefs to enc_prologue string via RIP-relative
def lea_xrefs_to(buf, secs, target, limit=12):
    t = text_range(secs)
    if not t: return []
    va, vs, ro, rs = t
    hits = []; i = ro; end = ro + rs - 7
    while i <= end and len(hits) < limit:
        if buf[i] == 0x48 and buf[i+1] == 0x8D and (buf[i+2] & 0xC7) == 0x05:
            disp = struct.unpack_from("<i", buf, i + 3)[0]
            src = va + (i - ro)
            if src + 7 + disp == target:
                hits.append(src)
        i += 1
    return hits

print("\n=== lea xrefs → enc_prologue@dcd2d9 / compute@658417 ===", flush=True)
for rva, name in [(0xdcd2d9, "enc_prol"), (0x658417, "comp_fr")]:
    xs = lea_xrefs_to(base, secs, rva, limit=10)
    print(f"  {name}: {[hex(x) for x in xs]}", flush=True)
    for x in xs[:4]:
        dump(base, secs, x - 0x20, 0x50, f"lea_{name}@{x:06x}")

# --- 4) Who writes USER thin frames: search enc of 48 81 EC 68 00 / B8 01 00 near Capless emit helpers ---
print("\n=== Isol mov eax thin / SoftCap sizes (confirm) ===", flush=True)
for imm, name in [(0x68, "0x68"), (0x1b8, "0x1b8"), (0x868, "0x868"), (0x878, "0x878")]:
    pat = b"\xb8" + struct.pack("<I", imm)
    offs = find_all(bytes(base), pat)
    rvas = [off2rva(secs, o) for o in offs]
    rvas = [r for r in rvas if r is not None]
    # Capless-adjacent band 0x500000..0x5a0000
    band = [r for r in rvas if 0x500000 <= r < 0x5a0000]
    print(f"  mov eax,{name}: n={len(rvas)} band5xxxxx={len(band)} sample_band={[hex(x) for x in band[:8]]}", flush=True)

# --- 5) kind 0x31 Isol SoftMega @57ef78 — is there Isol-native USER 0x868 writer on that path? ---
print("\n=== kind0x31 SoftMega@57ef78 / tip cmp 0x31 / USER 0x868 writers on SoftMega path ===", flush=True)
dump(base, secs, 0x12378c, 0x40, "tip_kind31_call")
dump(base, secs, 0x57ef78, 0x50, "softmega_twin")
# SoftMega callers of enc? Search sub rsp,0x868 near SoftMega body / reachable
# Count sub rsp,0x868 and their containing fn starts
pat868 = b"\x48\x81\xec" + struct.pack("<I", 0x868)
offs868 = find_all(bytes(base), pat868)
rvas868 = [off2rva(secs, o) for o in offs868]
rvas868 = [r for r in rvas868 if r is not None]
print(f"  HOST sub rsp,0x868: n={len(rvas868)} sample={[hex(x) for x in rvas868[:10]]}", flush=True)
# Which of these are near SoftMega 0x57xxxx vs tip SoftCap 0x12xxxx?
near_sm = [r for r in rvas868 if 0x570000 <= r < 0x5b0000]
near_tip = [r for r in rvas868 if 0x120000 <= r < 0x130000]
near_other = [r for r in rvas868 if r not in near_sm and r not in near_tip]
print(f"  near SoftMega band: {[hex(x) for x in near_sm[:8]]}", flush=True)
print(f"  near tip SoftCap band: {[hex(x) for x in near_tip[:8]]}", flush=True)
print(f"  other bands sample: {[hex(x) for x in near_other[:12]]}", flush=True)

# Capless post-success: look at Capless return sites that tip/caller inspect
# tip @12377c call Capless — after call check eax?
dump(base, secs, 0x123770, 0x50, "tip_after_capless_call")

# SoftCap-full early-success @5890c8 region (prior DIG) — confirm still present on alt_frame2
print("\n=== SoftCap-full Capless early-success @5890c8 (prior) ===", flush=True)
try:
    dump(base, secs, 0x5890c0, 0x40, "scfull_early")
except Exception as e:
    print(f"  missing: {e}", flush=True)

# Capless FN return value consumers: e8 callers of Capless
print("\n=== E8 callers → Capless@57656c ===", flush=True)
callers = e8_callers(base, secs, 0x57656c, limit=20)
print(f"  callers: {[hex(c) for c in callers]}", flush=True)
for c in callers[:6]:
    dump(base, secs, c - 0x10, 0x40, f"caller@{c:06x}")

# --- 6) INT3 frontier: Capless post-success + enc_prologue lea sites + kind31 + thin imm band ---
print("\n=== INT3 Capless post-success / enc / kind31 frontier ===", flush=True)
sites = [
    (0x57656c, "capless_entry"),
    (0x12377c, "tip_e8_capless"),
    (0x12378c, "tip_kind31"),
    (0x57ef78, "softmega"),
]
# add Capless eax=1 sites
for r in eax1_in[:4]:
    sites.append((r, f"cl_eax1_{r:06x}"))
# add first epi cand
if epi_cands:
    sites.append((epi_cands[0][0], "cl_epi0"))
# add lea enc_prologue xrefs
xs = lea_xrefs_to(base, secs, 0xdcd2d9, limit=6)
for x in xs[:3]:
    sites.append((x, f"lea_enc_{x:06x}"))
# Capless-band mov eax,0x68 sample (if any) — plant candidate search
band68 = []
for o in find_all(bytes(base), b"\xb8\x68\x00\x00\x00"):
    r = off2rva(secs, o)
    if r is not None and 0x500000 <= r < 0x5a0000:
        band68.append(r)
print(f"  Capless-band mov eax,0x68: n={len(band68)} {[hex(x) for x in band68[:10]]}", flush=True)
for r in band68[:4]:
    sites.append((r, f"eax68_{r:06x}"))

# SoftCap-full early success
sites.append((0x5890c8, "scfull_early"))

hit68 = []
for rva, name in sites:
    if time.time() - T0 > BUDGET - 12:
        print("BUDGET", flush=True); break
    t1 = time.time()
    tag, sh, sz, b = run_host(plant_int3(base, [rva], name), timeout=5)
    mark = ""
    if tag == "INT3":
        mark = " HIT"
        if "eax68" in name:
            hit68.append(rva)
    elif tag == "TIMEOUT":
        mark = " TIMEOUT(on-path-hang?)"
    elif tag in ("AV", "GS"):
        mark = f" **{tag}**"
    print(f"  @{rva:06x} {name:22s} -> {tag:8s}{mark} ({time.time()-t1:.1f}s)", flush=True)

# baseline frames
pat868b = b"\x48\x81\xec" + struct.pack("<I", 0x868)
pat68b = b"\x48\x81\xec" + struct.pack("<I", 0x68)
pat1b8b = b"\x48\x81\xec" + struct.pack("<I", 0x1b8)
tag, sh, sz, b = run_host(cave / "xlang_isol1060_alt_frame2.exe", "p_ret_lit.x", timeout=8)
print(f"\nbaseline lit: {tag} sha={sh} 868={pat868b in b} 68={pat68b in b} 1b8={pat1b8b in b}", flush=True)

print(f"\nHIT mov eax,0x68 Capless-band: {[hex(x) for x in hit68]}", flush=True)
print(f"elapsed={time.time()-T0:.1f}s DONE", flush=True)
clean()
print("PROD/pin untouched; ban tip@121278/join/epi/LIVE", flush=True)
