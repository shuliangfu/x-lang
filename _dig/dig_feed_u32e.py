"""DIG: callers of real enc_prologue@50f3e0 (edx=frame_sz); size 0x68/0x1b8 feed; plant 0x868.
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
PROL = 0x50f3e0

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

def e8_callers(buf, secs, target, limit=80):
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

def find_fn(buf, secs, rva, back=0x200):
    start = max(0, rva - back)
    o = rva2off(buf, secs, start)
    best = None
    for insn in md.disasm(bytes(buf[o:o+(rva-start)+1]), start):
        if insn.address > rva: break
        if insn.mnemonic == "push" and insn.op_str == "rbp":
            best = insn.address
    return best

def plant_int3(baseb, rvas, label):
    pe2 = bytearray(baseb); s = pe_secs(pe2)
    for rva in rvas:
        pe2[rva2off(pe2, s, rva)] = 0xCC
    out = cave / f"_dig_host_fue_{label}.exe"
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
    for p in list(cave.glob("_dig_host_fue_*.exe")) + list(cave.glob("_tmp__dig_host_fue_*")):
        try: p.unlink()
        except Exception: pass

clean()
base = bytearray((cave / "xlang_isol1060_alt_frame2.exe").read_bytes())
secs = pe_secs(base)
print(f"base sha12={hashlib.sha256(bytes(base)).hexdigest()[:12]}", flush=True)

print("\n=== E8 callers of prol@50f3e0 ===", flush=True)
cs = e8_callers(base, secs, PROL, limit=80)
print(f"  n={len(cs)}: {list(map(hex, cs))}", flush=True)

size_feeds = []  # (rva, imm, call_site)
for c in cs:
    fe = find_fn(base, secs, c)
    print(f"\n  call@{c:06x} fn={fe and hex(fe)}", flush=True)
    dump(base, secs, c - 0x40, n=0x50, label=f"call_near_{c:06x}")
    # scan 0x60 before call for mov *dx/eax, 0x68/0x1b8/0x868
    start = c - 0x60
    o = rva2off(base, secs, start)
    for insn in md.disasm(bytes(base[o:o+0x60]), start):
        if insn.address >= c: break
        op = insn.op_str.lower()
        if not insn.mnemonic.startswith("mov"): continue
        for imm in (0x68, 0x1b8, 0x868, 0x878, 0x40, 0x28, 0x20, 0x10, 0x8):
            if f"0x{imm:x}" in op:
                print(f"    SIZE? @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)
                if imm in (0x68, 0x1b8, 0x868):
                    size_feeds.append((insn.address, imm, c))
    # also look for edx loaded from [rbp+..] — note that
    for insn in md.disasm(bytes(base[o:o+0x60]), start):
        if insn.address >= c: break
        if "edx" in insn.op_str and insn.mnemonic.startswith("mov"):
            print(f"    edx @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)

# Broader: mov 0x68/0x1b8 then within 0x100 E8 to PROL
print("\n=== mov 0x68/0x1b8 -> E8 prol (0x100 window) ===", flush=True)
for imm in (0x68, 0x1b8):
    for o in find_all(bytes(base), struct.pack("<I", imm)):
        r = off2rva(secs, o)
        if r is None or not (0x500000 <= r < 0x5a0000): continue
        if o < 1 or not (0xB8 <= base[o-1] <= 0xBF): continue
        mov_rva = r - 1
        o2 = rva2off(base, secs, mov_rva)
        for i in range(0, 0x100):
            if o2 + i + 5 >= len(base): break
            if base[o2+i] != 0xE8: continue
            rel = struct.unpack_from("<i", base, o2+i+1)[0]
            src = mov_rva + i
            if src + 5 + rel == PROL:
                print(f"  mov@{mov_rva:06x} imm={imm:#x} -> call@{src:06x} prol", flush=True)
                size_feeds.append((mov_rva, imm, src))

# Indirect: callers of prol may pass computed size — INT3 call sites + edx setup
print("\n=== INT3 ===", flush=True)
sites = [(PROL, "prol_50f3e0")]
for c in cs[:12]:
    sites.append((c, f"e8_prol_{c:06x}"))
for mr, imm, c in size_feeds:
    if all(mr != s[0] for s in sites):
        sites.append((mr, f"sz_{imm:x}_{mr:06x}"))
# also FN entries of callers
seen_fn = set()
for c in cs[:10]:
    fe = find_fn(base, secs, c)
    if fe and fe not in seen_fn:
        seen_fn.add(fe)
        sites.append((fe, f"cfn_{fe:06x}"))

hits = []
for rva, name in sites:
    if time.time() - T0 > BUDGET - 18:
        print("BUDGET", flush=True); break
    t1 = time.time()
    tag, sh, b = run(plant_int3(base, [rva], name), timeout=5)
    mark = ""
    if tag == "INT3":
        mark = " HIT"; hits.append((rva, name, sh, b))
    elif tag == "TIMEOUT":
        mark = " TIMEOUT"
    elif tag in ("AV", "GS"):
        mark = f" **{tag}**"
    print(f"  @{rva:06x} {name:32s} -> {tag:8s}{mark} ({time.time()-t1:.1f}s)", flush=True)

print(f"\nHITs: {[(hex(r),n) for r,n,_,_ in hits]}", flush=True)
print(f"size_feeds: {[(hex(a),hex(b),hex(c)) for a,b,c in size_feeds]}", flush=True)

# Plant size imm if HIT
print("\n=== Plant fsz_868 ===", flush=True)
planted = False
for rva, name, sh, b in hits:
    if not name.startswith("sz_"): continue
    o = rva2off(base, secs, rva)
    if not (0xB8 <= base[o] <= 0xBF): continue
    imm = struct.unpack_from("<I", base, o+1)[0]
    if imm not in (0x68, 0x1b8): continue
    pe2 = bytearray(base)
    pe2[o+1:o+5] = struct.pack("<I", 0x868)
    outp = cave / "xlang_isol1060_fsz_868.exe"
    outp.write_bytes(pe2)
    print(f"  planted @{rva:06x} {imm:#x}->0x868 sha12={hashlib.sha256(bytes(pe2)).hexdigest()[:12]}", flush=True)
    planted = True
    for src in ("p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x"):
        if time.time() - T0 > BUDGET - 5: break
        if not (cave / src).exists(): continue
        tag, sh2, bb = run(outp, src=src, timeout=8)
        pat868 = b"\x48\x81\xec" + struct.pack("<I", 0x868)
        pat1b8 = b"\x48\x81\xec" + struct.pack("<I", 0x1b8)
        pat68 = b"\x48\x81\xec" + struct.pack("<I", 0x68)
        print(f"  plant {src}: {tag} sha={sh2} 868={pat868 in bb} 1b8={pat1b8 in bb} 68={pat68 in bb}", flush=True)
        if bb and tag == "OK":
            tmp = cave / f"_tmp_{outp.stem}_{Path(src).stem}.exe"
            if tmp.exists():
                try:
                    rr = subprocess.run([str(tmp)], capture_output=True, timeout=5)
                    print(f"    run rc={rr.returncode}", flush=True)
                except Exception as e:
                    print(f"    run err {e}", flush=True)
    break

# Alternate plant: force edx=0x868 at HIT call site by patching preceding mov edx,imm or mov edx,reg
# If HIT e8_prol and we can find mov edx,imm nearby — already covered by sz_
# If HIT e8_prol with edx from [rbp+xx] — not a single imm plant

if not planted:
    # Try: at HIT call site, if previous insn is mov edx, something — for computed sizes not isolatable as imm plant
    hit_calls = [r for r,n,_,_ in hits if n.startswith("e8_prol_")]
    print(f"  HIT prol calls: {list(map(hex, hit_calls))}", flush=True)
    print("  no imm size-feed HIT — frame_sz into prol@50f3e0 is arg/computed; feed_u32/fsz_868 not isolatable as imm patch", flush=True)

tag, sh, b = run(cave / "xlang_isol1060_alt_frame2.exe", timeout=8)
pat868 = b"\x48\x81\xec" + struct.pack("<I", 0x868)
pat1b8 = b"\x48\x81\xec" + struct.pack("<I", 0x1b8)
pat68 = b"\x48\x81\xec" + struct.pack("<I", 0x68)
print(f"baseline {tag} sha={sh} 868={pat868 in b} 1b8={pat1b8 in b} 68={pat68 in b}", flush=True)
print(f"elapsed={time.time()-T0:.1f}s DONE", flush=True)
clean()
for p in list(cave.glob("xlang_isol1060_fsz_868.exe")) + list(cave.glob("_dig_host_fue_*")) + list(cave.glob("_tmp__dig_host_fue_*")):
    try: p.unlink()
    except Exception: pass
