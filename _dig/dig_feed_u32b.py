"""DIG feed_u32 follow-up: which emit_u32 wrapper encodes sub rsp (48 81 EC)+sz;
who feeds 0x68/0x1b8 into that wrapper. Budget<=85s. Ban tip@121278/join/epi/LIVE/mega.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try: sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception: pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64); md.detail = True

cave = Path("C:/xlang_tmp/p1060/cave"); os.chdir(str(cave))
T0 = time.time(); BUDGET = 85
EMIT_U32 = 0x5110f8; EMIT_U8 = 0x511018

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

def find_fn_entry(buf, secs, rva, back=0x200):
    """Walk back for push rbp; mov rbp,rsp prologue near rva."""
    start = max(0, rva - back)
    o = rva2off(buf, secs, start)
    n = rva - start + 1
    best = None
    for insn in md.disasm(bytes(buf[o:o+n]), start):
        if insn.address > rva: break
        if insn.mnemonic == "push" and insn.op_str == "rbp":
            best = insn.address
    return best

def plant(baseb, rvas, label):
    pe2 = bytearray(baseb); s = pe_secs(pe2)
    for rva in rvas:
        pe2[rva2off(pe2, s, rva)] = 0xCC
    out = cave / f"_dig_host_fub_{label}.exe"
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
    for p in list(cave.glob("_dig_host_fub_*.exe")) + list(cave.glob("_tmp__dig_host_fub_*")):
        try: p.unlink()
        except Exception: pass

clean()
base = bytearray((cave / "xlang_isol1060_alt_frame2.exe").read_bytes())
secs = pe_secs(base)
print(f"base sha12={hashlib.sha256(bytes(base)).hexdigest()[:12]}", flush=True)

# 1) Find emit_u8 callers that load edx=0x48 / 0x81 / 0xEC (sub rsp rex/opcode)
print("\n=== emit_u8 sites with edx=0x48/0x81/0xEC (sub rsp pieces) ===", flush=True)
u8_callers = e8_callers(base, secs, EMIT_U8, limit=200)
print(f"  emit_u8 callers n={len(u8_callers)}", flush=True)
subrsp_sites = []  # (u8_call, imm_byte, fn_entry)
for c in u8_callers:
    # look back 0x20 for mov edx, imm8/32 of 0x48/0x81/0xEC
    start = c - 0x18
    o = rva2off(base, secs, start)
    for insn in md.disasm(bytes(base[o:o+0x18]), start):
        if insn.address >= c: break
        if insn.mnemonic == "mov" and "edx" in insn.op_str:
            op = insn.op_str.lower()
            for b in (0x48, 0x81, 0xec):
                if f"0x{b:x}" in op or op.endswith(f", {b}") or op.endswith(f",{b}"):
                    fe = find_fn_entry(base, secs, c)
                    subrsp_sites.append((c, b, fe, insn.address))
                    print(f"  emit_u8@{c:06x} movedx@{insn.address:06x} imm={b:#x} fn={fe and hex(fe)}", flush=True)

# 2) For each unique FN that emits 0x48 or 0x81 or 0xEC, dump and see if also calls emit_u32
print("\n=== FNs emitting sub-rsp bytes — dump + emit_u32? ===", flush=True)
fns = {}
for c, b, fe, mr in subrsp_sites:
    if fe: fns.setdefault(fe, []).append((c, b, mr))
for fe, items in sorted(fns.items()):
    bytes_emitted = sorted(set(b for _, b, _ in items))
    # does this FN call emit_u32?
    # scan FN body ~0x120 for E8 to emit_u32
    o = rva2off(base, secs, fe)
    body = bytes(base[o:o+0x180])
    calls_u32 = False
    for i in range(len(body) - 5):
        if body[i] == 0xE8:
            rel = struct.unpack_from("<i", body, i + 1)[0]
            if fe + i + 5 + rel == EMIT_U32:
                calls_u32 = True; break
    print(f"  FN@{fe:06x} bytes={list(map(hex,bytes_emitted))} calls_emit_u32={calls_u32}", flush=True)
    dump(base, secs, fe, n=0xc0, label=f"fn_{fe:06x}")

# 3) Also dump @5182ac (prior HIT family) and @512f0c enc_prologue tpl
print("\n=== Prior sites ===", flush=True)
dump(base, secs, 0x5182ac, n=0x100, label="addrax_fn_5182ac")
dump(base, secs, 0x512f0c, n=0x100, label="enc_prologue_tpl_512f0c")

# 4) Find who passes 0x68/0x1b8 as edx/stack arg into FNs that call emit_u32 with [rbp+0x18]
# Known wrappers from dig_feed_u32: @517f?? pattern — find their FN entries
wrapper_calls = [0x517f5b, 0x51801b, 0x5180fb, 0x518115, 0x518318]
print("\n=== Wrapper FN entries for emit_u32([rbp+0x18]) pattern ===", flush=True)
wrapper_fns = []
for c in wrapper_calls:
    fe = find_fn_entry(base, secs, c)
    print(f"  call@{c:06x} fn={fe and hex(fe)}", flush=True)
    if fe:
        wrapper_fns.append(fe)
        dump(base, secs, fe, n=0x80, label=f"wrap_{fe:06x}")
        # E8 callers of this wrapper
        cs = e8_callers(base, secs, fe, limit=30)
        print(f"    E8 callers n={len(cs)}: {list(map(hex, cs[:12]))}", flush=True)
        for cc in cs[:8]:
            # window for 0x68/0x1b8/0x868
            start = cc - 0x30
            o = rva2off(base, secs, start)
            for insn in md.disasm(bytes(base[o:o+0x40]), start):
                if insn.address > cc + 4: break
                op = insn.op_str.lower()
                for imm in (0x68, 0x1b8, 0x868, 0x878):
                    if f"0x{imm:x}" in op:
                        print(f"    !! call@{cc:06x} near@{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)

# 5) Broader: any mov edx/eax,0x68 or 0x1b8 within 0x40 bytes before E8 to any wrapper_fn
print("\n=== Size-imm before wrapper calls (global) ===", flush=True)
size_feed_sites = []
for fe in set(wrapper_fns):
    for cc in e8_callers(base, secs, fe, limit=40):
        start = cc - 0x40
        o = rva2off(base, secs, start)
        for insn in md.disasm(bytes(base[o:o+0x40]), start):
            if insn.address >= cc: break
            op = insn.op_str.lower()
            for imm in (0x68, 0x1b8, 0x868):
                if f"0x{imm:x}" in op and insn.mnemonic.startswith("mov"):
                    print(f"  wrapFN@{fe:06x} via@{cc:06x} @{insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)
                    size_feed_sites.append((insn.address, imm, fe, cc))

# Also search Capless band for call to wrappers with size in edx setup via stack
# Scan all mov eax/edx,0x68 and 0x1b8 and see if within 0x80 there's E8 to a wrapper or emit_u32
print("\n=== mov *,0x68/0x1b8 near E8 to emit_u32 or wrappers (0x80 window) ===", flush=True)
targets = set([EMIT_U32] + wrapper_fns)
# also add FNs that call emit_u32 and emit 0x48
for fe, items in fns.items():
    targets.add(fe)

for imm in (0x68, 0x1b8):
    pat = struct.pack("<I", imm)
    for o in find_all(bytes(base), pat):
        r = off2rva(secs, o)
        if r is None or r < 0x500000 or r > 0x5a0000: continue
        if o < 1: continue
        prev = base[o-1]
        if not (0xB8 <= prev <= 0xBF): continue
        mov_rva = r - 1
        # scan forward 0x80 for E8 to targets
        o2 = rva2off(base, secs, mov_rva)
        for i in range(0, 0x80):
            if o2 + i + 5 > len(base): break
            if base[o2 + i] == 0xE8:
                rel = struct.unpack_from("<i", base, o2 + i + 1)[0]
                src = mov_rva + i
                dest = src + 5 + rel
                if dest in targets:
                    print(f"  mov@{mov_rva:06x} imm={imm:#x} -> E8@{src:06x} -> @{dest:06x}", flush=True)
                    size_feed_sites.append((mov_rva, imm, dest, src))

# 6) INT3: emit_u32 HIT confirm; FN entries of subrsp encoders; size_feed sites; key wrappers
print("\n=== INT3 probe ===", flush=True)
sites = [(EMIT_U32, "emit_u32")]
for fe, items in sorted(fns.items()):
    sites.append((fe, f"subrsp_fn_{fe:06x}"))
for fe in sorted(set(wrapper_fns)):
    if all(fe != s[0] for s in sites):
        sites.append((fe, f"wrap_fn_{fe:06x}"))
for mr, imm, dest, src in size_feed_sites:
    if all(mr != s[0] for s in sites):
        sites.append((mr, f"szfeed_{imm:x}_{mr:06x}"))

# Capless FN @57656c entry? skip banned tip. Probe @5182ac
if all(0x5182ac != s[0] for s in sites):
    sites.append((0x5182ac, "fn_5182ac"))

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

# Plant if size feed HIT
print("\n=== Plant fsz_868 if size-feed HIT ===", flush=True)
planted = False
for rva, name, sh, b in hits:
    if not name.startswith("szfeed_"): continue
    o = rva2off(base, secs, rva)
    if not (0xB8 <= base[o] <= 0xBF): continue
    imm = struct.unpack_from("<I", base, o+1)[0]
    if imm not in (0x68, 0x1b8): continue
    pe2 = bytearray(base)
    pe2[o+1:o+5] = struct.pack("<I", 0x868)
    outp = cave / "xlang_isol1060_fsz_868.exe"
    outp.write_bytes(pe2)
    print(f"  planted fsz_868 @{rva:06x} {imm:#x}->0x868 sha12={hashlib.sha256(bytes(pe2)).hexdigest()[:12]}", flush=True)
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
                    r = subprocess.run([str(tmp)], capture_output=True, timeout=5)
                    print(f"    run rc={r.returncode}", flush=True)
                except Exception as e:
                    print(f"    run err {e}", flush=True)
    break

if not planted:
    print("  no HIT size-feed — not isolatable as fsz_868 this beat", flush=True)

tag, sh, b = run(cave / "xlang_isol1060_alt_frame2.exe", timeout=8)
pat868 = b"\x48\x81\xec" + struct.pack("<I", 0x868)
pat1b8 = b"\x48\x81\xec" + struct.pack("<I", 0x1b8)
pat68 = b"\x48\x81\xec" + struct.pack("<I", 0x68)
print(f"baseline {tag} sha={sh} 868={pat868 in b} 1b8={pat1b8 in b} 68={pat68 in b}", flush=True)
print(f"elapsed={time.time()-T0:.1f}s DONE", flush=True)
clean()
for p in list(cave.glob("xlang_isol1060_fsz_868.exe")) + list(cave.glob("_dig_host_fub_*")) + list(cave.glob("_tmp__dig_host_fub_*")):
    try: p.unlink()
    except Exception: pass
