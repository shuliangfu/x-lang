"""Isol-tip_scfull: tip SoftCap kind0x30 Capless→SoftCap-full @121278 (Isol-native Cap@0024e6-class candidate).
Ban LIVE transplant / arg-loop / twin SoftMega / letter-pile.
Also dig SoftCap-full ABI vs tip Capless call ABI.
"""
from pathlib import Path
import struct, hashlib, os, subprocess
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

cave = Path("C:/xlang_tmp/p1060/cave")
os.chdir(str(cave))
TT = bytearray((cave / "xlang_isol1060_TT.exe").read_bytes())
assert hashlib.sha256(bytes(TT)).hexdigest()[:12] == "1f836615e0fc"

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

secs = pe_secs(TT)
md = Cs(CS_ARCH_X86, CS_MODE_64)

print("=== SoftCap-full @121278 prologue / ABI ===")
o = rva2off(TT, secs, 0x121278)
for insn in md.disasm(bytes(TT[o:o+0xa0]), 0x121278):
    print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

print("\n=== tip Capless call site @123753..123787 (args) ===")
o = rva2off(TT, secs, 0x123753)
for insn in md.disasm(bytes(TT[o:o+0x40]), 0x123753):
    print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

print("\n=== SoftCap-full caller @1215b9 context ===")
o = rva2off(TT, secs, 0x121580)
for insn in md.disasm(bytes(TT[o:o+0x60]), 0x121580):
    print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Capless ABI: rcx, rdx, r8d, r9, [rsp+20]=ecx stack
# SoftCap-full ABI from prologue
print("\n=== plant tip_scfull: @12377c call Capless → SoftCap-full @121278 ===")
pe = bytearray(TT)
o = rva2off(pe, secs, 0x12377c)
assert pe[o] == 0xE8
old_rel = struct.unpack_from("<i", pe, o+1)[0]
old_tgt = 0x12377c + 5 + old_rel
print(f"  old tgt=@{old_tgt:06x}")
assert old_tgt == 0x57656c
new_tgt = 0x121278
new_rel = new_tgt - (0x12377c + 5)
struct.pack_into("<i", pe, o+1, new_rel)
# verify
assert 0x12377c + 5 + struct.unpack_from("<i", pe, o+1)[0] == new_tgt
sha = hashlib.sha256(pe).hexdigest()
print(f"Isol-tip_scfull sha12={sha[:12]}")
host = cave / "xlang_isol1060_tip_scfull.exe"
host.write_bytes(pe)

LIVE_SHA, TT_SHA = "dbaab1c7ce70", "5b173cef1205"

def run_host(h, src="p_ret_lit.x", timeout=15):
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
    return tag, sha, len(b), b.count(bytes.fromhex("68080000")), b.count(bytes.fromhex("78080000"))

print("\n=== tip_scfull SoftCap p_ret_* ===")
for src in ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x"]:
    tag, sha, sz, n868, n878 = run_host(host, src)
    mark = " **LIVE**" if sha == LIVE_SHA else (" (=TT)" if sha == TT_SHA else "")
    print(f"  {src:16s} {tag:8s} sha={sha} sz={sz} n868={n868} n878={n878}{mark}")

# Also try SoftCap-full @121230 (sibling entry)
print("\n=== plant tip_scfull0: → SoftCap-full @121230 ===")
pe2 = bytearray(TT)
o = rva2off(pe2, secs, 0x12377c)
new_rel = 0x121230 - (0x12377c + 5)
struct.pack_into("<i", pe2, o+1, new_rel)
sha2 = hashlib.sha256(pe2).hexdigest()
print(f"Isol-tip_scfull0 sha12={sha2[:12]}")
h2 = cave / "xlang_isol1060_tip_scfull0.exe"; h2.write_bytes(pe2)
for src in ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x"]:
    tag, sha, sz, n868, n878 = run_host(h2, src)
    mark = " **LIVE**" if sha == LIVE_SHA else (" (=TT)" if sha == TT_SHA else "")
    print(f"  {src:16s} {tag:8s} sha={sha} sz={sz} n868={n868} n878={n878}{mark}")

# tip SoftCap-full @50f8a0 (other SoftCap-full used by Cap emit @5228b3)
print("\n=== SoftCap-full @50f8a0 prologue ===")
o = rva2off(TT, secs, 0x50f8a0)
for insn in md.disasm(bytes(TT[o:o+0x60]), 0x50f8a0):
    print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

print("\n=== plant tip_sc50f: → SoftCap-full @50f8a0 ===")
pe3 = bytearray(TT)
o = rva2off(pe3, secs, 0x12377c)
new_rel = 0x50f8a0 - (0x12377c + 5)
struct.pack_into("<i", pe3, o+1, new_rel)
sha3 = hashlib.sha256(pe3).hexdigest()
print(f"Isol-tip_sc50f sha12={sha3[:12]}")
h3 = cave / "xlang_isol1060_tip_sc50f.exe"; h3.write_bytes(pe3)
for src in ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x"]:
    tag, sha, sz, n868, n878 = run_host(h3, src)
    mark = " **LIVE**" if sha == LIVE_SHA else (" (=TT)" if sha == TT_SHA else "")
    print(f"  {src:16s} {tag:8s} sha={sha} sz={sz} n868={n868} n878={n878}{mark}")

print("\nDONE")
