"""DIG Capless-internal USER enc_prologue: @512fxx sub rsp builder + frame_sz @512d28.
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

def dump(buf, secs, rva, n=0x120, label=""):
    o = rva2off(buf, secs, rva)
    print(f"--- {label} @{rva:06x} ---", flush=True)
    for insn in md.disasm(bytes(buf[o:o+n]), rva):
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)

def e8_callers(buf, secs, target, limit=50):
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
    out = cave / f"_dig_host_iee_{label}.exe"
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
    for p in list(cave.glob("_dig_host_iee_*.exe")) + list(cave.glob("_tmp__dig_host_iee_*")):
        try: p.unlink()
        except Exception: pass

clean()
base = bytearray((cave / "xlang_isol1060_alt_frame2.exe").read_bytes())
assert hashlib.sha256(bytes(base)).hexdigest()[:12] == "9378df517f96"
secs = pe_secs(base)

# Dump enc band around 0x48/0x81/0xEC
print("=== enc band @512f2f..@512f89 (48/81/EC) ===", flush=True)
dump(base, secs, 0x512f00, 0x120, "enc_48_81_ec")

# Find FN containing @512f65
fn_entry = None
for back in range(0, 0x200):
    rr = 0x512f65 - back
    o = rva2off(base, secs, rr)
    if base[o] == 0x55 and base[o+1] == 0x48 and base[o+2] == 0x89:
        fn_entry = rr
        dump(base, secs, rr, 0x40, f"enc_fn@{rr:06x}")
        cs = e8_callers(base, secs, rr)
        print(f"  enc_fn@{rr:06x} callers n={len(cs)} {[hex(c) for c in cs[:15]]}", flush=True)
        break

# @512d28 mov eax,0x1b8 context
print("\n=== @512d28 mov eax,0x1b8 ===", flush=True)
dump(base, secs, 0x512d00, 0x80, "imm_1b8")
for back in range(0, 0x100):
    rr = 0x512d28 - back
    o = rva2off(base, secs, rr)
    if base[o] == 0x55 and base[o+1] == 0x48:
        print(f"  FN @{rr:06x} callers {[hex(c) for c in e8_callers(base, secs, rr)[:12]]}", flush=True)
        break

# @511018 emit_u8 / @5110f8 emit_u32
print("\n=== emit_u8 @511018 / emit_u32 @5110f8 ===", flush=True)
dump(base, secs, 0x511018, 0x50, "emit_u8")
dump(base, secs, 0x5110f8, 0x50, "emit_u32")

# Find ALL enc helpers that emit 81 EC (sub rsp,imm32)
print("\n=== Search enc helpers emitting 0x81 then 0xEC ===", flush=True)
# look for mov edx,0x81 followed within 0x30 bytes by mov edx,0xec (or similar)
text = text_range(secs)
va, vs, ro, rs = text
enc_subrsp = []
for o in find_all(bytes(base), b"\xba\x81\x00\x00\x00"):  # mov edx,0x81
    r = off2rva(secs, o)
    if not r or not (0x510000 <= r < 0x520000):
        continue
    window = bytes(base[o:o+0x40])
    if b"\xba\xec\x00\x00\x00" in window or b"\xb9\xec\x00\x00\x00" in window:
        enc_subrsp.append(r)
        dump(base, secs, r - 0x20, 0x80, f"subrsp_enc@{r:06x}")
print(f"  subrsp enc sites: {[hex(x) for x in enc_subrsp]}", flush=True)

# Also mov edx,0xEC near 0x48
for o in find_all(bytes(base), b"\xba\xec\x00\x00\x00"):
    r = off2rva(secs, o)
    if r and 0x510000 <= r < 0x520000:
        dump(base, secs, r - 0x40, 0xa0, f"mov_ec@{r:06x}")

# INT3
print("\n=== INT3 enc_prologue / frame_sz frontier ===", flush=True)
sites = []
if fn_entry:
    sites.append((fn_entry, "enc_fn_entry"))
sites += [
    (0x512f65, "mov48_enc"),
    (0x512f77, "mov81_enc"),
    (0x512f89, "movEC_enc"),
    (0x512d28, "imm_1b8"),
    (0x511018, "emit_u8"),
    (0x5110f8, "emit_u32"),
    (0x5182ac, "addrax_fn"),
    (0x5182da, "mov48_b"),
]
for r in enc_subrsp:
    sites.append((r, f"subrsp_{r:06x}"))
# callers of enc_fn
if fn_entry:
    for c in e8_callers(base, secs, fn_entry)[:6]:
        sites.append((c, f"e8_encfn_{c:06x}"))

hits = []
for rva, name in sites:
    if time.time() - T0 > BUDGET - 15:
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
    print(f"  @{rva:06x} {name:28s} -> {tag:8s}{mark} ({time.time()-t1:.1f}s)", flush=True)

# If imm_1b8 HIT — try plant 0x1b8 → 0x868 (semantic frame_sel)
print("\n=== Plant attempt: frame_sel 0x1b8→0x868 if imm on-path ===", flush=True)
imm_hit = any(n == "imm_1b8" for _, n, _, _ in hits)
enc_hit = any("movEC" in n or "mov81" in n or "enc_fn" in n or "subrsp" in n for _, n, _, _ in hits)
print(f"  imm_1b8_HIT={imm_hit} enc_HIT={enc_hit}", flush=True)

if imm_hit or True:
    # Always try plant at @512d28 if bytes are mov eax,0x1b8 — even if INT3 was OK before;
    # re-verify: only plant if HIT this run OR if enc path HIT and 1b8 is the size arg site near enc
    pe2 = bytearray(base)
    o = rva2off(pe2, secs, 0x512d28)
    # expect B8 B8 01 00 00
    print(f"  bytes@{0x512d28:06x}: {bytes(pe2[o:o+5]).hex()}", flush=True)
    if pe2[o:o+5] == bytes([0xB8, 0xB8, 0x01, 0x00, 0x00]):
        pe2[o:o+5] = bytes([0xB8, 0x68, 0x08, 0x00, 0x00])  # mov eax,0x868
        outp = cave / "xlang_isol1060_int_enc868.exe"
        outp.write_bytes(pe2)
        print(f"  planted int_enc868 sha12={hashlib.sha256(bytes(pe2)).hexdigest()[:12]}", flush=True)
        for src in ("p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x"):
            if not (cave / src).exists():
                print(f"  skip missing {src}", flush=True); continue
            if time.time() - T0 > BUDGET - 5:
                break
            tag, sh, b = run(outp, src=src, timeout=8)
            pat868 = b"\x48\x81\xec" + struct.pack("<I", 0x868)
            pat1b8 = b"\x48\x81\xec" + struct.pack("<I", 0x1b8)
            pat68 = b"\x48\x81\xec" + struct.pack("<I", 0x68)
            print(f"  plant {src}: {tag} sha={sh} 868={pat868 in b} 1b8={pat1b8 in b} 68={pat68 in b}", flush=True)
            if b and tag == "OK":
                # run compiled exe if exists
                tmp = cave / f"_tmp_{outp.stem}_{Path(src).stem}.exe"
                if tmp.exists():
                    try:
                        r = subprocess.run([str(tmp)], capture_output=True, timeout=5)
                        print(f"    run rc={r.returncode}", flush=True)
                    except Exception as e:
                        print(f"    run err {e}", flush=True)

print(f"\nHITs: {[(hex(r),n) for r,n,_,_ in hits]}", flush=True)
tag, sh, b = run(cave / "xlang_isol1060_alt_frame2.exe")
print(f"baseline {tag} sha={sh}", flush=True)
print(f"elapsed={time.time()-T0:.1f}s DONE", flush=True)
# keep plant host if created; clean dig hosts only
for p in list(cave.glob("_dig_host_iee_*.exe")) + list(cave.glob("_tmp__dig_host_iee_*")):
    try: p.unlink()
    except Exception: pass
