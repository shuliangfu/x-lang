"""DIG fwd_46_967_sret #21b: s20b host + post-patch USER main x+1→imm9.
Proves semantic: let needs caller-sret+x+1; main needs imm9; fw BinaryExpr overwrites.
"""
from pathlib import Path
import struct, hashlib, subprocess, time
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

CAVE = Path("C:/xlang_tmp/p1060/cave")
HOST = CAVE / "host_967_s20b.exe"  # already built: x+1 + let_sret + c1toc2
SRCS = ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x", "_var_let.x"]
md = Cs(CS_ARCH_X86, CS_MODE_64)

def P(*a): print(*a, flush=True)
def pe_secs(buf):
    e = struct.unpack_from("<I", buf, 0x3C)[0]
    nsec = struct.unpack_from("<H", buf, e+6)[0]; opt = struct.unpack_from("<H", buf, e+20)[0]
    sec = e+24+opt; secs = {}
    for i in range(nsec):
        o = sec+i*40; n = bytes(buf[o:o+8]).split(b"\0")[0]
        vs,va,rs,ro = struct.unpack_from("<IIII", buf, o+8); secs[n] = (va,vs,ro,rs)
    return secs
def tag_of(crc):
    return {0:"OK", 0x80000003:"INT3", 0xC0000409:"GS", 0xC0000005:"AV"}.get(crc&0xffffffff, hex(crc&0xffffffff))

def patch_main_imm9(buf):
    """In .text: after 488d45d8 4889c1 4883ec20, replace 488b45f048ffc04889c2 with b809..4889c2 9090."""
    secs = pe_secs(buf); va,vs,ro,rs = secs[b".text"]
    w = bytearray(buf[ro:ro+rs])
    n = 0
    pat_pre = bytes.fromhex("488d45d84889c14883ec20")
    old = bytes.fromhex("488b45f048ffc04889c2")
    new = bytes.fromhex("b8090000004889c29090")
    idx = 0
    while True:
        j = w.find(pat_pre, idx)
        if j < 0: break
        k = j + len(pat_pre)
        if w[k:k+len(old)] == old:
            w[k:k+len(old)] = new
            n += 1
            P(f"  patched main imm9 at text+{k:#x}")
        idx = j + 1
    out = bytearray(buf); out[ro:ro+rs] = w
    return bytes(out), n

def dump_region(buf, start, n, label):
    secs=pe_secs(buf); va,vs,ro,rs=secs[b".text"]; w=buf[ro:ro+rs]
    P(f"  dump {label}:")
    for insn in md.disasm(w[start:start+n], start):
        P(f"    {insn.address:06x}: {insn.bytes.hex():18s} {insn.mnemonic} {insn.op_str}")

t0=time.time()
assert HOST.exists(), HOST
P(f"HOST={HOST.name} sha={hashlib.sha256(HOST.read_bytes()).hexdigest()[:12]}")

for s in SRCS:
    out = CAVE/f"_g21b_{Path(s).stem}.exe"
    r = subprocess.run([str(HOST), str(CAVE/s), "-o", str(out)], capture_output=True, timeout=8)
    crc = r.returncode&0xffffffff
    if not out.exists() or out.stat().st_size==0:
        P(f"  {s:16s} host={tag_of(crc)} NO_OUT"); continue
    raw = out.read_bytes()
    patched, n = patch_main_imm9(raw)
    out.write_bytes(patched)
    user = hashlib.sha256(patched).hexdigest()[:12]
    rc = subprocess.run([str(out)], capture_output=True, timeout=3).returncode & 0xffffffff
    rt = tag_of(rc) if rc>3 else str(rc)
    P(f"  {s:16s} host={tag_of(crc):8s} USER={user} run={rt:8s} patches={n}")
    if s in ("_var_let.x","p_ret_fwd.x"):
        dump_region(patched, 0x4f8 if s!="p_ret_fwd.x" else 0x540, 0x80, s)

P(f"\n=== SUMMARY elapsed={time.time()-t0:.1f}s ===")
