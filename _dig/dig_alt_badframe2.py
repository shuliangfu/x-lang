"""DIG2: aligned @5603b8 body AV root; loop-body under alt skip; slot init.
Base post_fa3 453f3e66f96c / alt e1c45031fb92. Budget<=85s.
"""
from pathlib import Path
import struct, hashlib, os, subprocess, time, sys
try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

cave = Path("C:/xlang_tmp/p1060/cave")
os.chdir(str(cave))
T0 = time.time(); BUDGET = 85
md = Cs(CS_ARCH_X86, CS_MODE_64)

def pe_secs(buf):
    e = struct.unpack_from("<I", buf, 0x3C)[0]
    nsec = struct.unpack_from("<H", buf, e + 6)[0]
    opt = struct.unpack_from("<H", buf, e + 20)[0]
    sec = e + 24 + opt
    out = {}
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

def dump(buf, secs, start, nbytes, label):
    print(f"\n=== {label} @{start:#x} ===", flush=True)
    off = rva2off(buf, secs, start)
    for insn in md.disasm(bytes(buf[off:off+nbytes]), start):
        m = ""
        if "rbp" in insn.op_str: m += " RBP"
        if insn.mnemonic == "call": m += " CALL"
        print(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}{m}", flush=True)

def plant_int3(baseb, rvas, label):
    pe2 = bytearray(baseb); s = pe_secs(pe2)
    for rva in rvas:
        pe2[rva2off(pe2, s, rva)] = 0xCC
    out = cave / f"_dig_host_bf2_{label}.exe"
    out.write_bytes(pe2); return out

def run_host(h, src="p_ret_lit.x", timeout=5):
    out = cave / f"_tmp_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except Exception: pass
    try:
        r = subprocess.run([str(h), str(cave/src), "-o", str(out)],
                           capture_output=True, timeout=timeout)
        crc = r.returncode & 0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT", "-", 0
    tag = {0x80000003: "INT3", 0xC0000005: "AV", 0xC0000409: "GS", 0: "OK"}.get(crc, f"crc={crc:#x}")
    b = out.read_bytes() if out.exists() else b""
    sh = hashlib.sha256(b).hexdigest()[:12] if b else "-"
    return tag, sh, len(b)

def clean():
    for p in list(cave.glob("_dig_host_bf2_*.exe")) + list(cave.glob("_tmp__dig_host_bf2_*")):
        try: p.unlink()
        except Exception: pass

clean()
post = bytearray((cave / "xlang_isol1060_post_fa3.exe").read_bytes())
assert hashlib.sha256(bytes(post)).hexdigest()[:12] == "453f3e66f96c"
alt = bytearray((cave / "xlang_isol1060_alt_57619e.exe").read_bytes())
assert hashlib.sha256(bytes(alt)).hexdigest()[:12] == "e1c45031fb92"
secs = pe_secs(post)

# Align insn list for @5603b8 first 0x120
off = rva2off(post, secs, 0x5603b8)
insns = list(md.disasm(bytes(post[off:off+0x180]), 0x5603b8))
print("=== aligned INT3 @5603b8 body (post_fa3) ===", flush=True)
# probe every insn until AV after a HIT streak; skip first (entry known HIT)
last_hit = None
first_av = None
for insn in insns[:40]:
    if time.time()-T0 > BUDGET: break
    rva = insn.address
    tag, sh, sz = run_host(plant_int3(post, [rva], f"h_{rva:x}"), timeout=4)
    mark = " HIT" if tag=="INT3" else (" **AV**" if tag=="AV" else f" {tag}")
    print(f"  @{rva:06x} {insn.mnemonic:8s} {insn.op_str[:40]:40s} -> {tag}{mark}", flush=True)
    if tag == "INT3":
        last_hit = rva
    elif tag == "AV" and last_hit is not None and first_av is None:
        first_av = rva
        dump(post, secs, last_hit, 0x50, f"lastHIT@{last_hit:#x} -> firstAV@{rva:#x}")
        break

# Find epi properly (scan 0x800)
print("\n=== @5603b8 epi (pop rbp / ret) ===", flush=True)
body = bytes(post[off:off+0x800])
epi_addrs = []
for insn in md.disasm(body, 0x5603b8):
    if (insn.mnemonic == "pop" and "rbp" in insn.op_str) or insn.mnemonic == "ret" \
       or (insn.mnemonic == "leave"):
        epi_addrs.append(insn)
        print(f"  {insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)
if epi_addrs:
    dump(post, secs, epi_addrs[0].address - 0x10, 0x30, "epi window")
else:
    print("  NO pop-rbp/ret in +0x800 - frame epi missing/far", flush=True)

# Who inits [rbp+0x934]? scan mov [rbp+0x934], *
print("\n=== init writers [rbp+0x934] in CapFN ===", flush=True)
offn = rva2off(post, secs, 0x5752bc)
fn = bytes(post[offn:offn+0x1400])
d = struct.pack("<I", 0x934)
for i in range(len(fn)-7):
    if fn[i] == 0x89 and fn[i+1] == 0x85 and fn[i+2:i+6] == d:
        print(f"  mov [rbp+0x934],r32 @{0x5752bc+i:#x}", flush=True)
        dump(post, secs, 0x5752bc+i-0x10, 0x28, "init934")
    if fn[i] == 0xc7 and fn[i+1] == 0x85 and fn[i+2:i+6] == d:
        imm = struct.unpack_from("<i", fn, i+6)[0]
        print(f"  mov [rbp+0x934],imm={imm:#x} @{0x5752bc+i:#x}", flush=True)
        dump(post, secs, 0x5752bc+i-0x8, 0x20, "init934imm")

# +0x904 writer context (pre mid-call skip)
dump(post, secs, 0x576060, 0x80, "pre-skip @576060 (+0x904 write / mid calls)")

# Under alt plant: loop body first sites
print("\n=== alt-plant loop body INT3 (jl target @576061) ===", flush=True)
dump(alt, pe_secs(alt), 0x576061, 0x70, "loop body head")
for rva, name in [(0x576061, "loop_body"), (0x57607f, "w904"), (0x5760c2, "mid1_skipped"),
                  (0x576110, "after_skip"), (0x576134, "je_alt"), (0x5763c4, "post_loop_land")]:
    if time.time()-T0 > BUDGET: break
    tag, sh, sz = run_host(plant_int3(alt, [rva], f"L_{name}"), timeout=4)
    mark = " HIT" if tag=="INT3" else (" **AV**" if tag=="AV" else f" {tag}")
    print(f"  @{rva:06x} {name:16s} -> {tag}{mark}", flush=True)

# Args at call: dump what alt passes; null-check plant idea
print("\n=== @5603b8 arg null-check region ===", flush=True)
dump(post, secs, 0x560408, 0x50, "null-check rbx=arg0")

clean()
print(f"\nelapsed={time.time()-T0:.1f}s last_hit={last_hit and hex(last_hit)} first_av={first_av and hex(first_av)}", flush=True)
