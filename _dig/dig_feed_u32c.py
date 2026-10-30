"""DIG: where USER 48 81 EC + 0x68/0x1b8 actually comes from if not emit_u32 imm.
Search HOST templates; Capless memcpy/store paths; on-path size compute.
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
    out = cave / f"_dig_host_fuc_{label}.exe"
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
    for p in list(cave.glob("_dig_host_fuc_*.exe")) + list(cave.glob("_tmp__dig_host_fuc_*")):
        try: p.unlink()
        except Exception: pass

clean()
base = bytearray((cave / "xlang_isol1060_alt_frame2.exe").read_bytes())
secs = pe_secs(base)
print(f"base sha12={hashlib.sha256(bytes(base)).hexdigest()[:12]}", flush=True)

# A) HOST contains prebaked 48 81 EC + size templates?
print("\n=== HOST templates 48 81 EC + size ===", flush=True)
for sz in (0x68, 0x1b8, 0x868, 0x878, 0):
    pat = b"\x48\x81\xec" + struct.pack("<I", sz)
    offs = find_all(bytes(base), pat)
    print(f"  pat 48 81 EC {sz:#x}: n={len(offs)}", flush=True)
    for o in offs[:8]:
        r = off2rva(secs, o)
        # which section?
        secname = "?"
        for n, (va, vs, ro, rs) in secs.items():
            kn = n.decode() if isinstance(n, bytes) else n
            if ro <= o < ro + max(rs, 1):
                secname = kn; break
        print(f"    off={o:#x} rva={r and hex(r)} sec={secname}", flush=True)

# B) Also 48 83 EC (sub rsp,imm8) for small frames
print("\n=== HOST 48 83 EC (imm8 sub) ===", flush=True)
for o in find_all(bytes(base), b"\x48\x83\xec")[:15]:
    r = off2rva(secs, o)
    imm = base[o+3] if o+3 < len(base) else -1
    print(f"  @{r and f'{r:06x}'} imm8={imm:#x}", flush=True)

# C) Capless band: who calls emit helpers that could write prologue — look at Capless FN region
# Find references to enc helpers @511018/@5110f8/@5182ac/@517fd8 from Capless 0x576000-0x57c000
print("\n=== Capless-band E8 to enc helpers ===", flush=True)
helpers = {
    0x511018: "emit_u8",
    0x5110f8: "emit_u32",
    0x511094: "emit_raw4?",
    0x5182ac: "add_rax_imm",
    0x517fd8: "mov_eax_imm",
    0x518098: "mov_rax_imm64",
    0x512f0c: "enc_prologue_tpl",
    0x50f8a0: "host_sub_868?",
}
t = text_range(secs)
va, vs, ro, rs = t
# Capless lit path band
for lo, hi, label in [(0x576000, 0x57c000, "Capless"), (0x55a000, 0x560000, "clc/pre"), (0x567000, 0x570000, "h_emit")]:
    for tgt, name in helpers.items():
        cs = []
        i = ro + max(0, lo - va); end = ro + min(rs, hi - va) - 5
        while i <= end:
            if base[i] == 0xE8:
                rel = struct.unpack_from("<i", base, i + 1)[0]
                src = va + (i - ro)
                if src + 5 + rel == tgt:
                    cs.append(src)
            i += 1
        if cs:
            print(f"  {label} -> {name}@{tgt:06x}: {list(map(hex, cs[:8]))}", flush=True)

# D) Find emit_raw / memcpy-into-code: @511094 callers in Capless; dump it
print("\n=== emit helper @511094 ===", flush=True)
dump(base, secs, 0x511094, n=0x50, label="emit_511094")
print(f"  E8 callers n={len(e8_callers(base, secs, 0x511094))}", flush=True)

# E) Search for code that does: store size into buffer after writing 48 81 EC
# Pattern: mov byte/dword with 0x81 or lea+store. Look for 0xEC8148 as imm32 dword store
print("\n=== imm32 0x00EC8148 / 0xEC8148 packs ===", flush=True)
for imm in (0xEC8148, 0x00EC8148, 0x81EC48, 0xEC814800):
    pat = struct.pack("<I", imm & 0xFFFFFFFF)
    offs = find_all(bytes(base), pat)
    print(f"  imm={imm:#x} n={len(offs)}", flush=True)
    for o in offs[:6]:
        r = off2rva(secs, o)
        if r and 0x500000 <= r < 0x5a0000:
            dump(base, secs, r - 8, n=0x30, label=f"pack_{imm:x}_{r:06x}")

# F) Baseline USER: locate 48 81 EC sites and note — already know 68+1b8
tag, sh, ub = run(cave / "xlang_isol1060_alt_frame2.exe", timeout=8)
print(f"\nbaseline {tag} sha={sh}", flush=True)
for sz in (0x68, 0x1b8, 0x868):
    pat = b"\x48\x81\xec" + struct.pack("<I", sz)
    print(f"  USER 48 81 EC {sz:#x}: n={ub.count(pat)}", flush=True)

# G) Who in Capless calls something that eventually produces frame — INT3 Capless emit path sites
# from prior: last@57b98c HIT, CapFN@5752bc HIT, emit_u8 HIT, emit_u32 HIT
# New: find compute_frame or size align near Capless — search lea of string already done off-path
# Look for and/add/align producing 0x68: e.g. add eax,0x1f; and eax,0xffffffe0 patterns near Capless

# H) Critical: @5182ac HIT means add rax,imm on-path — its edx arg comes from callers
print("\n=== Callers of @5182ac (add_rax) with nearby size? ===", flush=True)
cs5182 = e8_callers(base, secs, 0x5182ac, limit=40)
print(f"  n={len(cs5182)}: {list(map(hex, cs5182[:20]))}", flush=True)
for cc in cs5182[:12]:
    start = cc - 0x28
    o = rva2off(base, secs, start)
    for insn in md.disasm(bytes(base[o:o+0x30]), start):
        if insn.address > cc + 2: break
        op = insn.op_str.lower()
        if any(f"0x{x:x}" in op for x in (0x68, 0x1b8, 0x868, 0x10, 0x20, 0x28, 0x30, 0x38, 0x40)):
            print(f"  @{cc:06x} near @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)

# I) Search ALL E8 callers of emit_u32 — for each, find FN entry and see if FN also emits 0x81 or stores EC
print("\n=== emit_u32 caller FNs: do any emit 0x81/0xEC via emit_u8? ===", flush=True)
u32cs = e8_callers(base, secs, 0x5110f8, limit=40)
for c in u32cs:
    # find fn entry
    start = max(0, c - 0x100)
    o = rva2off(base, secs, start)
    fe = None
    for insn in md.disasm(bytes(base[o:o+(c-start)+1]), start):
        if insn.address > c: break
        if insn.mnemonic == "push" and insn.op_str == "rbp":
            fe = insn.address
    if not fe: continue
    # scan FN for mov edx, 0x81 or 0xec
    o2 = rva2off(base, secs, fe)
    body = bytes(base[o2:o2+0x100])
    has81 = b"\xba\x81\x00\x00\x00" in body or b"\xb2\x81" in body  # mov edx,0x81 / mov dl,0x81
    hasEC = b"\xba\xec\x00\x00\x00" in body or b"\xb2\xec" in body
    has48 = b"\xba\x48\x00\x00\x00" in body
    if has81 or hasEC:
        print(f"  call@{c:06x} fn@{fe:06x} has81={has81} hasEC={hasEC} has48={has48}", flush=True)
        dump(base, secs, fe, n=0xa0, label=f"u32fn_{fe:06x}")

# J) Maybe frame written by memcpy of [rbp-0x40] from enc_prologue — but 0 E8 callers.
# Alternative: search for 48 81 EC written via stosd/mov dword [rax], imm with partial
# mov dword [reg], 0x00EC8148 then patch +3 — already searched packs

# K) INT3 probe: @5182ac callers that look size-related; Capless sites; any new FN with 81/EC
print("\n=== INT3 ===", flush=True)
sites = [(0x5110f8, "emit_u32"), (0x5182ac, "add_rax")]
# first few callers of 5182ac
for i, cc in enumerate(cs5182[:6]):
    sites.append((cc, f"e8_addrax_{cc:06x}"))
# Capless last / CapFN already known HIT — skip reconfirm to save budget; probe @512f0c anyway
sites.append((0x512f0c, "enc_tpl"))
# probe @511094
sites.append((0x511094, "emit_raw4"))

hits = []
for rva, name in sites:
    if time.time() - T0 > BUDGET - 12:
        print("BUDGET", flush=True); break
    t1 = time.time()
    tag, sh, b = run(plant(base, [rva], name), timeout=5)
    mark = ""
    if tag == "INT3":
        mark = " HIT"; hits.append((rva, name, sh, b))
    elif tag == "TIMEOUT":
        mark = " TIMEOUT"
    elif tag in ("AV", "GS"):
        mark = f" **{tag}**"
    print(f"  @{rva:06x} {name:32s} -> {tag:8s}{mark} ({time.time()-t1:.1f}s)", flush=True)

print(f"\nHITs: {[(hex(r),n) for r,n,_,_ in hits]}", flush=True)
print("CONCLUSION_HINT: if no enc 48 81 EC via emit_u32 path, USER frames come from template/memcpy or non-imm size compute; SoftCap 0x868 plant at emit_u32 feeder not isolatable.", flush=True)
print(f"elapsed={time.time()-T0:.1f}s DONE", flush=True)
clean()
