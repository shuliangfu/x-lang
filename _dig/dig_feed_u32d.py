"""DIG: USER sub rsp via emit_raw4@511094 / 0xEC8148 packs — not emit_u32(frame_sz).
Who feeds 0x68/0x1b8 into that path; SoftCap 0x868 plant?
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
RAW4 = 0x511094

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

def dump(buf, secs, rva, n=0xa0, label=""):
    o = rva2off(buf, secs, rva)
    print(f"--- {label} @{rva:06x} ---", flush=True)
    for insn in md.disasm(bytes(buf[o:o+n]), rva):
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)

def e8_callers(buf, secs, target, limit=60):
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

def find_fn(buf, secs, rva, back=0x180):
    start = max(0, rva - back)
    o = rva2off(buf, secs, start)
    best = None
    for insn in md.disasm(bytes(base[o:o+(rva-start)+1]), start):
        if insn.address > rva: break
        if insn.mnemonic == "push" and insn.op_str == "rbp":
            best = insn.address
    return best

def plant(baseb, rvas, label):
    pe2 = bytearray(baseb); s = pe_secs(pe2)
    for rva in rvas:
        pe2[rva2off(pe2, s, rva)] = 0xCC
    out = cave / f"_dig_host_fud_{label}.exe"
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
    for p in list(cave.glob("_dig_host_fud_*.exe")) + list(cave.glob("_tmp__dig_host_fud_*")):
        try: p.unlink()
        except Exception: pass

clean()
base = bytearray((cave / "xlang_isol1060_alt_frame2.exe").read_bytes())
secs = pe_secs(base)
print(f"base sha12={hashlib.sha256(bytes(base)).hexdigest()[:12]}", flush=True)

# 1) All emit_raw4 callers + FN entries
print("\n=== emit_raw4@511094 callers ===", flush=True)
rcs = e8_callers(base, secs, RAW4, limit=60)
print(f"  n={len(rcs)}", flush=True)
fn_map = {}
for c in rcs:
    fe = find_fn(base, secs, c)
    print(f"  call@{c:06x} fn={fe and hex(fe)}", flush=True)
    if fe:
        fn_map.setdefault(fe, []).append(c)

# 2) Which of those FNs mention 0x81/0xEC/0x48 or size 0x68/0x1b8 in body?
print("\n=== raw4 FNs with prologue/size markers ===", flush=True)
prol_fns = []
for fe, cs in sorted(fn_map.items()):
    o = rva2off(base, secs, fe)
    body = bytes(base[o:o+0x200])
    marks = []
    if b"\x48\x81\xec" in body: marks.append("has_subrsp_bytes")
    if struct.pack("<I", 0xEC8148) in body: marks.append("imm_EC8148")
    if struct.pack("<I", 0x68) in body and (b"\xb8\x68\x00\x00\x00" in body or b"\xba\x68\x00\x00\x00" in body):
        marks.append("imm_68")
    if struct.pack("<I", 0x1b8) in body and (b"\xb8\xb8\x01\x00\x00" in body or b"\xba\xb8\x01\x00\x00" in body):
        marks.append("imm_1b8")
    if struct.pack("<I", 0x868) in body and b"\xb8\x68\x08\x00\x00" in body:
        marks.append("imm_868")
    # also check for mov eax,0x81 / 0xec as byte stores (enc_prologue style)
    if b"\xb8\x81\x00\x00\x00" in body: marks.append("mov_eax_81")
    if b"\xb8\xec\x00\x00\x00" in body: marks.append("mov_eax_ec")
    if marks:
        print(f"  FN@{fe:06x} calls={list(map(hex,cs))} marks={marks}", flush=True)
        prol_fns.append(fe)
        dump(base, secs, fe, n=0x120, label=f"raw4fn_{fe:06x}")

# 3) All 0xEC8148 imm sites in enc band — dump context
print("\n=== 0xEC8148 sites in 0x50f000-0x530000 ===", flush=True)
ec_sites = []
for o in find_all(bytes(base), struct.pack("<I", 0xEC8148)):
    r = off2rva(secs, o)
    if r is None or not (0x50f000 <= r < 0x530000): continue
    # back up to insn start roughly
    dump(base, secs, r - 4, n=0x28, label=f"EC8148_{r:06x}")
    ec_sites.append(r)

# 4) enc_prologue @512f0c continues — does it call raw4? dump more of body for E8s
print("\n=== enc_prologue@512f0c E8 targets ===", flush=True)
o = rva2off(base, secs, 0x512f0c)
body = bytes(base[o:o+0x400])
for i in range(len(body)-5):
    if body[i] == 0xE8:
        rel = struct.unpack_from("<i", body, i+1)[0]
        src = 0x512f0c + i
        dest = src + 5 + rel
        if 0x1000 < dest < 0x600000:
            print(f"  E8@{src:06x} -> @{dest:06x}", flush=True)

# 5) Search FNs that both have imm_68/1b8 AND call raw4 or emit_u32
print("\n=== Cross: mov 0x68/0x1b8 FN that calls raw4 or emit_u32 ===", flush=True)
for imm in (0x68, 0x1b8):
    for o in find_all(bytes(base), struct.pack("<I", imm)):
        r = off2rva(secs, o)
        if r is None or not (0x510000 <= r < 0x560000): continue
        if o < 1 or not (0xB8 <= base[o-1] <= 0xBF): continue
        mov_rva = r - 1
        fe = find_fn(base, secs, mov_rva)
        if not fe: continue
        o2 = rva2off(base, secs, fe)
        body = bytes(base[o2:o2+0x280])
        calls_raw = False; calls_u32 = False
        for i in range(len(body)-5):
            if body[i] != 0xE8: continue
            rel = struct.unpack_from("<i", body, i+1)[0]
            dest = fe + i + 5 + rel
            if dest == RAW4: calls_raw = True
            if dest == 0x5110f8: calls_u32 = True
        if calls_raw or calls_u32:
            print(f"  mov@{mov_rva:06x} imm={imm:#x} fn@{fe:06x} raw4={calls_raw} u32={calls_u32}", flush=True)
            dump(base, secs, fe, n=0xc0, label=f"szfn_{fe:06x}")

# 6) INT3: raw4, prol_fns, ec_sites FN entries, promising size FNs
print("\n=== INT3 ===", flush=True)
sites = [(RAW4, "emit_raw4"), (0x5110f8, "emit_u32")]
for fe in prol_fns[:6]:
    sites.append((fe, f"prolfn_{fe:06x}"))
# unique FNs covering EC8148 sites
seen = set()
for r in ec_sites[:10]:
    fe = find_fn(base, secs, r)
    if fe and fe not in seen:
        seen.add(fe)
        sites.append((fe, f"ecfn_{fe:06x}"))

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
    print(f"  @{rva:06x} {name:32s} -> {tag:8s}{mark} ({time.time()-t1:.1f}s)", flush=True)

print(f"\nHITs: {[(hex(r),n) for r,n,_,_ in hits]}", flush=True)

# Plant: if HIT FN has mov 0x1b8/0x68 — try 0x868
print("\n=== Plant attempt ===", flush=True)
planted = False
for rva, name, sh, b in hits:
    # search FN body for mov eax/edx,0x1b8 or 0x68
    fe = rva
    o = rva2off(base, secs, fe)
    body = bytearray(base[o:o+0x280])
    for imm in (0x1b8, 0x68):
        pat = bytes([0xB8]) + struct.pack("<I", imm)  # mov eax,imm
        idx = body.find(pat)
        reg = "eax"
        if idx < 0:
            for rb in range(0xB9, 0xC0):
                pat = bytes([rb]) + struct.pack("<I", imm)
                idx = body.find(pat)
                if idx >= 0:
                    reg = f"r{rb-0xB8}"; break
        if idx < 0: continue
        abs_rva = fe + idx
        pe2 = bytearray(base)
        oo = rva2off(pe2, secs, abs_rva)
        print(f"  HIT fn has mov {reg},{imm:#x} @{abs_rva:06x} — plant 0x868", flush=True)
        pe2[oo+1:oo+5] = struct.pack("<I", 0x868)
        outp = cave / "xlang_isol1060_fsz_868.exe"
        outp.write_bytes(pe2)
        print(f"  planted sha12={hashlib.sha256(bytes(pe2)).hexdigest()[:12]}", flush=True)
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
    if planted: break

if not planted:
    print("  not isolatable: no on-path FN with size imm to retarget; frame_sz≠emit_u32 feed", flush=True)

tag, sh, b = run(cave / "xlang_isol1060_alt_frame2.exe", timeout=8)
print(f"baseline {tag} sha={sh}", flush=True)
print(f"elapsed={time.time()-T0:.1f}s DONE", flush=True)
clean()
for p in list(cave.glob("xlang_isol1060_fsz_868.exe")) + list(cave.glob("_dig_host_fud_*")) + list(cave.glob("_tmp__dig_host_fud_*")):
    try: p.unlink()
    except Exception: pass
