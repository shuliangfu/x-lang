"""DIG3: callers of @5603b8; epi; post-@5763c4 frontier; one plant alt_frame.
Budget<=85s. post_fa3/alt bases.
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
    n = 0
    for insn in md.disasm(bytes(buf[off:off+nbytes]), start):
        m = ""
        if "rbp" in insn.op_str: m += " RBP"
        if insn.mnemonic == "call": m += " CALL"
        if insn.mnemonic.startswith("j"): m += " BR"
        print(f"  {insn.address:06x}: {insn.mnemonic:8s} {insn.op_str}{m}", flush=True)
        n += 1
        if n > 40: break

def plant_int3(baseb, rvas, label):
    pe2 = bytearray(baseb); s = pe_secs(pe2)
    for rva in rvas:
        pe2[rva2off(pe2, s, rva)] = 0xCC
    out = cave / f"_dig_host_bf3_{label}.exe"
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
    for p in list(cave.glob("_dig_host_bf3_*.exe")) + list(cave.glob("_tmp__dig_host_bf3_*")):
        try: p.unlink()
        except Exception: pass

clean()
post = bytearray((cave / "xlang_isol1060_post_fa3.exe").read_bytes())
assert hashlib.sha256(bytes(post)).hexdigest()[:12] == "453f3e66f96c"
alt = bytearray((cave / "xlang_isol1060_alt_57619e.exe").read_bytes())
assert hashlib.sha256(bytes(alt)).hexdigest()[:12] == "e1c45031fb92"
secs = pe_secs(post)

# Find E8 callers of @5603b8 across .text
print("=== E8 callers of @5603b8 ===", flush=True)
text = secs.get(b".text") or secs.get(".text")
# pe_secs keys are bytes
keys = list(secs.keys())
print("  sections:", keys, flush=True)
va, vs, ro, rs = None, None, None, None
for k, v in secs.items():
    kn = k.decode() if isinstance(k, bytes) else k
    if kn == ".text":
        va, vs, ro, rs = v
        break
assert va is not None
blob = bytes(post[ro:ro+rs])
target = 0x5603b8
callers = []
for i in range(len(blob)-5):
    if blob[i] != 0xE8: continue
    rel = struct.unpack_from("<i", blob, i+1)[0]
    site = va + i
    dest = site + 5 + rel
    if dest == target:
        callers.append(site)
print(f"  n={len(callers)} sites: {[hex(c) for c in callers[:20]]}", flush=True)

# Find ret in @5603b8 by scanning up to 0x2000 with capstone from entry only
print("\n=== @5603b8 size/epi scan 0x2000 ===", flush=True)
off = rva2off(post, secs, 0x5603b8)
insns = list(md.disasm(bytes(post[off:off+0x2000]), 0x5603b8))
rets = [i for i in insns if i.mnemonic == "ret" or (i.mnemonic=="pop" and "rbp" in i.op_str) or i.mnemonic=="leave"]
print(f"  decoded {len(insns)} insns; epi-ish n={len(rets)}", flush=True)
for i in rets[:10]:
    print(f"  {i.address:06x}: {i.mnemonic} {i.op_str}", flush=True)
if rets:
    dump(post, secs, rets[0].address-0x18, 0x30, "first epi")
else:
    # look for jmp-tail to shared epi
    jmps = [i for i in insns if i.mnemonic == "jmp" and i.op_str.startswith("0x")]
    print(f"  bare jmps n={len(jmps)} sample={[hex(i.address)+'->'+i.op_str for i in jmps[:8]]}", flush=True)

# post @5763c4 dump + INT3 frontier on alt plant
dump(alt, pe_secs(alt), 0x5763c4, 0xa0, "post_loop @5763c4")
print("\n=== INT3 alt post-@5763c4 ===", flush=True)
# collect first 12 insn addrs
off2 = rva2off(alt, pe_secs(alt), 0x5763c4)
ins2 = list(md.disasm(bytes(alt[off2:off2+0xc0]), 0x5763c4))
for insn in ins2[:12]:
    if time.time()-T0 > BUDGET: break
    tag, sh, sz = run_host(plant_int3(alt, [insn.address], f"p_{insn.address:x}"), timeout=5)
    mark = " HIT" if tag=="INT3" else (" **AV**" if tag=="AV" else f" {tag}")
    print(f"  @{insn.address:06x} {insn.mnemonic:8s} {insn.op_str[:36]:36s} -> {tag}{mark}", flush=True)
    if tag == "AV":
        dump(alt, pe_secs(alt), insn.address-0x10, 0x40, "AV near")
        break

# Confirm p_ret speed sanity
print("\n=== timing sanity post_fa3 lit ===", flush=True)
t1 = time.time()
tag, sh, sz = run_host(cave / "xlang_isol1060_post_fa3.exe" if False else plant_int3(post, [], "nopbase") if False else None, timeout=1)
# just run post directly
host = cave / "xlang_isol1060_alt_57619e.exe"
t1 = time.time()
tag, sh, sz = run_host(host, "p_ret_lit.x", timeout=8)
print(f"  alt lit -> {tag} in {time.time()-t1:.2f}s sha={sh}", flush=True)

# ---- plant alt_frame: on alt base, after reaching @5763c4, if AV at first call, near-jmp skip one bad call ----
# First identify AV insn from above; if none yet use dump calls
print("\n=== plant alt_frame: jmp @57629b -> @5763c4 (skip inc/loop; land post_loop) ===", flush=True)
pe = bytearray(alt)  # already has jmp 5761c2->57629b
# strengthen: also force [rbp+0x934]=0 and jmp to 5763c4 from 57629b
# replace add [rbp+0x934],1 @57629b (7 bytes 83 85 34 09 00 00 01) with:
#   xor eax,eax; mov [rbp+0x934],eax; jmp 5763c4
# xor eax,eax = 31 c0 (2)
# mov [rbp+0x934],eax = 89 85 34 09 00 00 (6) = 8 bytes already > 7
# Simpler: near jmp @57629b -> @5763c4 (5 bytes), nop pad rest of add (2 nops)
s = pe_secs(pe)
o = rva2off(pe, s, 0x57629b)
# verify add encoding
assert pe[o] == 0x83 and pe[o+1] == 0x85, hex(pe[o])
land = 0x5763c4
rel = land - (0x57629b + 5)
pe[o] = 0xE9
struct.pack_into("<i", pe, o+1, rel)
# add is 7 bytes; jmp is 5; nop 2
pe[o+5] = 0x90
pe[o+6] = 0x90
print(f"  jmp @57629b -> @{land:06x} rel={rel:#x}", flush=True)
sha = hashlib.sha256(pe).hexdigest()
print(f"  Isol-alt_frame sha12={sha[:12]}", flush=True)
host = cave / "xlang_isol1060_alt_frame.exe"
host.write_bytes(pe)

print("\n=== SoftCap p_ret_* alt_frame ===", flush=True)
for src in ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x"]:
    if time.time()-T0 > BUDGET: break
    tag, sh, sz = run_host(host, src, timeout=8)
    print(f"  {src:16s} {tag:8s} sha={sh} sz={sz}", flush=True)

print("\n=== INT3 alt_frame frontier ===", flush=True)
for rva, name in [(0x5763c4, "post_loop"), (0x5763d6, "z934"), (0x576523, "join")]:
    if time.time()-T0 > BUDGET: break
    # resolve join from dump if needed
    tag, sh, sz = run_host(plant_int3(pe, [rva], f"af_{name}"), timeout=5)
    mark = " HIT" if tag=="INT3" else (" **AV**" if tag=="AV" else f" {tag}")
    print(f"  @{rva:06x} {name:16s} -> {tag}{mark}", flush=True)

# also probe a few insns after 5763c4 on plant
off3 = rva2off(pe, pe_secs(pe), 0x5763c4)
for insn in list(md.disasm(bytes(pe[off3:off3+0x80]), 0x5763c4))[:8]:
    if time.time()-T0 > BUDGET: break
    tag, sh, sz = run_host(plant_int3(pe, [insn.address], f"af2_{insn.address:x}"), timeout=4)
    mark = " HIT" if tag=="INT3" else (" **AV**" if tag=="AV" else f" {tag}")
    print(f"  @{insn.address:06x} {insn.mnemonic:8s} -> {tag}{mark}", flush=True)
    if tag == "AV":
        break

clean()
print(f"\nelapsed={time.time()-T0:.1f}s DONE sha12={sha[:12]}", flush=True)
