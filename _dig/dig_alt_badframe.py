"""DIG SoftCap alt bad-frame/rbp root @5603b8 / Cap FN @5752bc.
Base: post_fa3 453f3e66f96c (+ alt plant e1c45031fb92 for skip path).
Short timeout. Ban letter-pile / LIVE SoftCap transplant / arg-loop.
"""
from pathlib import Path
import sys
try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass
import struct, hashlib, os, subprocess, time
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
    print(f"\n=== {label} @{start:#x} +{nbytes:#x} ===", flush=True)
    off = rva2off(buf, secs, start)
    for insn in md.disasm(bytes(buf[off:off+nbytes]), start):
        mark = ""
        if "rbp" in insn.op_str: mark = "  <<RBP"
        if insn.mnemonic == "call": mark += " CALL"
        if insn.mnemonic.startswith("j"): mark += " BR"
        print(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}{mark}", flush=True)

def plant_int3(baseb, rvas, label):
    pe2 = bytearray(baseb); s = pe_secs(pe2)
    for rva in rvas:
        pe2[rva2off(pe2, s, rva)] = 0xCC
    out = cave / f"_dig_host_bf_{label}.exe"
    out.write_bytes(pe2); return out

def run_host(h, src="p_ret_lit.x", timeout=6):
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
    for p in list(cave.glob("_dig_host_bf_*.exe")) + list(cave.glob("_tmp__dig_host_bf_*")):
        try: p.unlink()
        except Exception: pass

clean()

post = bytearray((cave / "xlang_isol1060_post_fa3.exe").read_bytes())
assert hashlib.sha256(bytes(post)).hexdigest()[:12] == "453f3e66f96c"
alt = bytearray((cave / "xlang_isol1060_alt_57619e.exe").read_bytes())
assert hashlib.sha256(bytes(alt)).hexdigest()[:12] == "e1c45031fb92"
secs = pe_secs(post)

print("=== FRAME MATH Cap FN @5752bc ===", flush=True)
print("  prol: push rbp; sub rsp,0x9e0; lea rbp,[rsp+0x80]", flush=True)
print("  saved_rbp @[rbp+0x960]; retaddr @[rbp+0x968]", flush=True)
print("  alt slots: +0x8fc store / +0x904 head / +0x934 inc - ALL in [0..0x960)", flush=True)
print("  [rbp+0x990] loop flag = PAST retaddr (+0x28 into CALLER stack)", flush=True)
print("  SoftCap lit LIVE user emit: sub rsp,0x868/0x878 | Capless thin: 0x1b8/0x68", flush=True)
print("  => alt rbp slots are HOST Cap FN frame, not user SoftCap 0x868 emit size", flush=True)

# Cap FN prol + cookie
dump(post, secs, 0x5752bc, 0x40, "CapFN prol @5752bc")
# scan first 0x80 for cookie xor (65 48 8B / 48 33 / security)
off = rva2off(post, secs, 0x5752bc)
sc = bytes(post[off:off+0x100])
print("\n=== CapFN prol cookie hunt (first 0x100) ===", flush=True)
for i in range(len(sc)-6):
    # mov rax, gs:[...] or xor with __security_cookie
    if sc[i:i+3] == b'\x65\x48\x8b' or sc[i:i+2] == b'\x48\x33' or sc[i:i+3] == b'\x48\x8b\x05':
        dump(post, secs, 0x5752bc+i, 0x18, f"cookie-ish @{0x5752bc+i:#x}")

# Helper @5603b8 prol + early body + find epi
dump(post, secs, 0x5603b8, 0x60, "helper @5603b8 prol+body")
# find ret / leave in next 0x500
off = rva2off(post, secs, 0x5603b8)
body = bytes(post[off:off+0x500])
print("\n=== @5603b8 epi hunt (ret/leave/add rsp) ===", flush=True)
for insn in md.disasm(body, 0x5603b8):
    if insn.mnemonic in ("ret", "leave") or (insn.mnemonic == "add" and "rsp" in insn.op_str) \
       or (insn.mnemonic == "mov" and insn.op_str.startswith("rsp, rbp")) \
       or (insn.mnemonic == "pop" and "rbp" in insn.op_str):
        print(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}", flush=True)
        if insn.mnemonic == "ret":
            # dump 0x20 before ret
            dump(post, secs, max(0x5603b8, insn.address-0x20), 0x28, f"near-ret @{insn.address:#x}")
            break

# Alt path disasm
dump(post, secs, 0x57619e, 0xa0, "alt @57619e (post_fa3)")
dump(alt, pe_secs(alt), 0x5761c0, 0x50, "alt plant region (e1c450 jmp)")

# Who WRITES [rbp+0x934] / [rbp+0x904] / [rbp+0x8fc] in Cap FN range
print("\n=== Cap FN @5752bc..@576555 slot writers (rbp+0x8fc/904/934) ===", flush=True)
off = rva2off(post, secs, 0x5752bc)
fn = bytes(post[off:off+0x12a0])  # ~ to epi
# pattern: 89 xx xx fc 08 00 00 or 01 / ff for add
targets = {0x8fc: "store_8fc", 0x904: "slot_904", 0x934: "inc_934", 0x960: "saved_rbp", 0x990: "flag_990"}
hits = {k: [] for k in targets}
for i in range(len(fn)-7):
    # disp32 at i+3 for modrm mem [rbp+disp32] = 85 / xx
    for disp, name in targets.items():
        d = struct.pack("<I", disp)
        # mov [rbp+disp], r32: 89 85 XX XX XX XX or 89 8d / 89 95 ...
        if fn[i] == 0x89 and fn[i+1] in (0x85, 0x8d, 0x95, 0x9d, 0xa5, 0xad, 0xb5, 0xbd) and fn[i+2:i+6] == d:
            hits[disp].append((0x5752bc+i, "mov[rbp]"))
        # add [rbp+disp], imm: 83 85 XX..  / 01 85
        if fn[i] == 0x83 and fn[i+1] == 0x85 and fn[i+2:i+6] == d:
            hits[disp].append((0x5752bc+i, "add[rbp]imm"))
        if fn[i] == 0x01 and fn[i+1] == 0x85 and fn[i+2:i+6] == d:
            hits[disp].append((0x5752bc+i, "add[rbp]reg"))
        # mov r32, [rbp+disp]: 8b 85 ...
        if fn[i] == 0x8b and fn[i+1] in (0x85, 0x8d, 0x95, 0x9d, 0xa5, 0xad, 0xb5, 0xbd) and fn[i+2:i+6] == d:
            hits[disp].append((0x5752bc+i, "load[rbp]"))
for disp, name in targets.items():
    uniq = sorted(set(hits[disp]))[:12]
    print(f"  rbp+{disp:#x} ({name}): {[(hex(a),k) for a,k in uniq]} n={len(hits[disp])}", flush=True)

# INT3 frontier on post_fa3: prove rbp alive at alt head vs after @5603b8
print("\n=== INT3 post_fa3: rbp-alive vs @5603b8 body ===", flush=True)
probes = [
    (0x57619e, "alt_head"),
    (0x5761c2, "call_5603b8"),
    (0x5603b8, "h_entry"),
    (0x5603bc, "h_after_push"),  # after push rbp; mov rbp,rsp typically
    (0x5603c3, "h_after_sub"),   # after sub rsp - may need adjust from dump
    (0x560480, "h_deep_prior"),  # prior dig deep HIT
    (0x5761c7, "after_call"),
    (0x57629b, "inc_934"),
]
# refine h_after_* from actual disasm
off = rva2off(post, secs, 0x5603b8)
insns = list(md.disasm(bytes(post[off:off+0x30]), 0x5603b8))
print("  @5603b8 first insns:", flush=True)
for insn in insns[:8]:
    print(f"    {insn.address:06x}: {insn.mnemonic} {insn.op_str}", flush=True)
# set after_sub to first insn after sub rsp
after_sub = None
for insn in insns:
    if insn.mnemonic == "sub" and "rsp" in insn.op_str:
        after_sub = insn.address + insn.size
        break
if after_sub:
    probes = [(a,n) for a,n in probes if n != "h_after_sub"] + [(after_sub, "h_after_sub")]

for rva, name in probes:
    if time.time()-T0 > BUDGET: print("BUDGET", flush=True); break
    tag, sh, sz = run_host(plant_int3(post, [rva], name), timeout=5)
    mark = " HIT" if tag == "INT3" else (" **AV**" if tag == "AV" else (" **GS**" if tag == "GS" else ""))
    print(f"  @{rva:06x} {name:16s} -> {tag:8s}{mark}", flush=True)

# Dense body of @5603b8: find first AV boundary (few probes)
print("\n=== @5603b8 body stride INT3 (find AV boundary) ===", flush=True)
# from after_sub to +0x100 step 0x10, stop early
start = after_sub or 0x5603c8
for rva in range(start, start + 0x100, 0x10):
    if time.time()-T0 > BUDGET: break
    tag, sh, sz = run_host(plant_int3(post, [rva], f"hb_{rva:x}"), timeout=4)
    mark = " HIT" if tag == "INT3" else (" **AV**" if tag == "AV" else "")
    print(f"  @{rva:06x} -> {tag:8s}{mark}", flush=True)
    if tag == "AV" and rva > start + 0x20:
        # dump around first post-HIT AV
        dump(post, secs, rva - 0x20, 0x40, f"AV-boundary near @{rva:#x}")
        break

# Compare: under alt skip plant, is rbp still good at inc?
print("\n=== INT3 alt-plant e1c450: rbp at inc / loop ===", flush=True)
for rva, name in [(0x57629b, "inc_934"), (0x5762a0, "inc+5"), (0x5762a2, "loop"),
                  (0x5762b4, "loop_exit")]:
    if time.time()-T0 > BUDGET: break
    tag, sh, sz = run_host(plant_int3(alt, [rva], f"a_{name}"), timeout=5)
    mark = " HIT" if tag == "INT3" else (" **AV**" if tag == "AV" else (" **GS**" if tag == "GS" else ""))
    print(f"  @{rva:06x} {name:16s} -> {tag:8s}{mark}", flush=True)

# Dump exact inc insn bytes
dump(alt, pe_secs(alt), 0x576290, 0x40, "inc/loop region")

# SoftCap p_ret baseline confirmation
print("\n=== SoftCap p_ret_* baselines ===", flush=True)
for label, pe in [("post_fa3", post), ("alt_57619e", alt)]:
    if time.time()-T0 > BUDGET: break
    host = cave / f"_dig_host_bf_base_{label}.exe"
    host.write_bytes(pe)
    row = []
    for src in ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x"]:
        tag, sh, sz = run_host(host, src, timeout=6)
        row.append(f"{src.split('.')[0]}={tag}")
    print(f"  {label}: {' / '.join(row)}", flush=True)

clean()
print(f"\nelapsed={time.time()-T0:.1f}s DONE", flush=True)
