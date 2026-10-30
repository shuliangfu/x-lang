"""Plant Isol-site_emit_pass: abi_r8 SoftCap-site + force kind-gates to emit path.
DIG SoftCap lit kind at SoftCap-site; probe emit helpers. Ban transplant/arg-loop/twin.
"""
from pathlib import Path
import struct, hashlib, os, subprocess
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

cave = Path("C:/xlang_tmp/p1060/cave")
os.chdir(str(cave))
TT = (cave / "xlang_isol1060_TT.exe").read_bytes()
abi = bytearray((cave / "xlang_isol1060_site_abi_r8.exe").read_bytes())
assert hashlib.sha256(bytes(abi)).hexdigest()[:12] == "de066e24b417"

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

secs = pe_secs(abi)
md = Cs(CS_ARCH_X86, CS_MODE_64)

# SoftCap-site kind-gates (abi_r8 bytes):
# 2be72b: cmp [rbp+c4], 3
# 2be732: je 2be73e
# 2be734: mov eax,1; jmp exit   ← miss claim
# Force: patch je to jmp (force take kind==3 path), or nop claim to fall into 2be73e
# Safer force: @2be732 je → jmp (0x74 → 0xeb) same rel
o = rva2off(abi, secs, 0x2be732)
print(f"@2be732 bytes: {bytes(abi[o:o+2]).hex()}")  # expect 74 0a (je +10)
assert abi[o] == 0x74
abi[o] = 0xEB  # jmp

# nested: 2be778 cmp [rbp+c4], 3; 2be77f je 2be78b; 2be781 mov eax,1
o = rva2off(abi, secs, 0x2be77f)
print(f"@2be77f bytes: {bytes(abi[o:o+2]).hex()}")
assert abi[o] == 0x74
abi[o] = 0xEB

sha = hashlib.sha256(abi).hexdigest()
print(f"Isol-site_emit_pass sha12={sha[:12]}")
host = cave / "xlang_isol1060_site_emit_pass.exe"
host.write_bytes(abi)

# Also dig: INT3 after first kind call on abi_r8 to confirm SoftCap lit kind
# Plant on abi_r8: after 2be6cf mov [rbp+c4],eax → INT3 at 2be6d5
def plant_int3(base, rvas, label):
    pe = bytearray(base); s = pe_secs(pe)
    for rva in rvas:
        pe[rva2off(pe, s, rva)] = 0xCC
    out = cave / f"_dig_host_{label}.exe"; out.write_bytes(pe); return out

def run_host(h, src="p_ret_lit.x", timeout=22):
    out = cave / f"_tmp_{h.stem}_{Path(src).stem}.exe"
    if out.exists():
        try: out.unlink()
        except Exception: pass
    try:
        r = subprocess.run([str(h), str(cave/src), "-o", str(out)],
                           capture_output=True, timeout=timeout)
        crc = r.returncode & 0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT", "-", 0, 0, 0
    tag = {0x80000003: "INT3", 0xC0000005: "AV", 0xC0000409: "GS", 0: "OK"}.get(crc, f"crc={crc:#x}")
    b = out.read_bytes() if out.exists() else b""
    sha = hashlib.sha256(b).hexdigest()[:12] if b else "-"
    n868 = b.count(bytes.fromhex("68080000")) if b else 0
    n878 = b.count(bytes.fromhex("78080000")) if b else 0
    return tag, sha, len(b), n868, n878

print("\n=== DIG SoftCap lit kind path INT3 on abi_r8 ===")
abi_bytes = (cave/"xlang_isol1060_site_abi_r8.exe").read_bytes()
for rva, name in [
    (0x2be6ca, "call_kind"),
    (0x2be6d5, "after_kind"),  # cmp kind
    (0x2be6ee, "call_k36"),
    (0x2be71e, "call_k33"),
    (0x2be734, "claim_miss"),
    (0x2be73e, "k3_path"),
    (0x2be74a, "after_kind_dispatch"),
    (0x2be76d, "call_kind2"),
    (0x2be781, "claim_nest"),
    (0x2be79b, "call_sz"),
    (0x2be7dc, "call_name"),
    (0x2be810, "call_emit_cc"),
    (0x2be85d, "call_emit_cp"),
    (0x2be89c, "call_emit_2bd5"),
    (0x2be8ea, "call_emit_5249"),
    (0x2be905, "success_eax0"),
]:
    tag, sha, sz, n868, n878 = run_host(plant_int3(abi_bytes, [rva], f"k_{name}"))
    print(f"  @{rva:06x} {name:20s} → {tag:8s}")

print("\n=== site_emit_pass SoftCap p_ret_* ===")
LIVE_SHA, TT_SHA = "dbaab1c7ce70", "5b173cef1205"
for src in ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x"]:
    tag, sha, sz, n868, n878 = run_host(host, src)
    mark = " **LIVE**" if sha == LIVE_SHA else (" (=TT)" if sha == TT_SHA else "")
    print(f"  {src:16s} {tag:8s} sha={sha} sz={sz} n868={n868} n878={n878}{mark}")

print("\n=== INT3 emit path on site_emit_pass ===")
ep = host.read_bytes()
for rva, name in [
    (0x2be73e, "k3_path"),
    (0x2be74a, "after_disp"),
    (0x2be753, "claim_c8le0"),
    (0x2be76d, "call_kind2"),
    (0x2be78b, "nest_ok"),
    (0x2be79b, "call_sz"),
    (0x2be7bb, "sz_bad"),
    (0x2be7dc, "call_name"),
    (0x2be7e1, "after_name"),
    (0x2be810, "emit_cc"),
    (0x2be832, "ptr_check"),
    (0x2be83c, "claim_nullptr"),
    (0x2be85d, "emit_cp"),
    (0x2be89c, "emit_2bd5"),
    (0x2be8ea, "emit_5249"),
    (0x2be905, "ret0"),
    (0x5766b9, "calt_gt0"),
    (0x5766c3, "calt_fall"),
]:
    tag, sha, sz, n868, n878 = run_host(plant_int3(ep, [rva], f"ep_{name}"))
    print(f"  @{rva:06x} {name:16s} → {tag:8s} sha={sha}")

# h3 AV area disasm
print("\n=== h3 @46a707..46a750 ===")
csecs = pe_secs(c36 := (cave/"xlang_isol1060_site_abi_c36.exe").read_bytes())
off = rva2off(c36, csecs, 0x46a6e0)
for insn in list(md.disasm(bytes(c36[off:off+0x90]), 0x46a6e0))[:40]:
    print(f"  {insn.address:06x}: {insn.mnemonic} {insn.op_str}")

print("\nDONE")
