from pathlib import Path
import struct, hashlib, subprocess
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
md = Cs(CS_ARCH_X86, CS_MODE_64)
cave = Path("C:/xlang_tmp/p1060/cave")
print("=== p_ret_fwd.x ===")
print((cave/"p_ret_fwd.x").read_text()[:800])
buf = (cave/"host_967_sret_tr460.exe").read_bytes()
e = struct.unpack_from("<I", buf, 0x3C)[0]
nsec = struct.unpack_from("<H", buf, e+6)[0]; opt = struct.unpack_from("<H", buf, e+20)[0]
sec = e+24+opt; secs = {}
for i in range(nsec):
    o = sec+i*40; n = bytes(buf[o:o+8]).split(b"\0")[0]
    vs,va,rs,ro = struct.unpack_from("<IIII", buf, o+8); secs[n] = (va,vs,ro,rs)
def r2o(r):
    for n,(va,vs,ro,rs) in secs.items():
        if va <= r < va+max(vs,rs): return ro+(r-va)
    raise ValueError(hex(r))
print("=== Capless 57bbae..57be20 ===")
for insn in md.disasm(buf[r2o(0x57bbae):r2o(0x57bbae)+0x380], 0x57bbae):
    print(f"  {insn.address:06x}: {insn.bytes.hex():24s} {insn.mnemonic} {insn.op_str}")
# BE67
r = subprocess.run([str(cave/"host_967_sret_tr460.exe"), str(cave/"p_ret_fwd.x"), "-o", str(cave/"_be67_fwd.exe")], capture_output=True, timeout=8)
buf = (cave/"_be67_fwd.exe").read_bytes()
print("BE67 sha", hashlib.sha256(buf).hexdigest()[:12], "host_rc", r.returncode)
e = struct.unpack_from("<I", buf, 0x3C)[0]
nsec = struct.unpack_from("<H", buf, e+6)[0]; opt = struct.unpack_from("<H", buf, e+20)[0]
sec = e+24+opt; secs = {}
for i in range(nsec):
    o = sec+i*40; n = bytes(buf[o:o+8]).split(b"\0")[0]
    vs,va,rs,ro = struct.unpack_from("<IIII", buf, o+8); secs[n] = (va,vs,ro,rs)
va,vs,ro,rs = secs[b".text"]; w = buf[ro:ro+rs]
j = w.find(bytes.fromhex("488b45c04889c1e8"))
print("BE67 binExpr+call @", hex(j) if j>=0 else None)
start = max(0, (j if j>=0 else 0x500) - 0x40)
print("=== BE67 near call ===")
for insn in md.disasm(w[start:start+0xa0], start):
    print(f"  {insn.address:06x}: {insn.bytes.hex():20s} {insn.mnemonic} {insn.op_str}")
j = w.find(bytes.fromhex("488b4dd04883ec20b80a000000"))
print("USER16 @", hex(j) if j>=0 else None)
# run BE67
r = subprocess.run([str(cave/"_be67_fwd.exe")], capture_output=True, timeout=3)
print("BE67 run", r.returncode & 0xffffffff, r.stdout[:100], r.stderr[:100])
# run lit OK for reference
r = subprocess.run([str(cave/"host_967_sret_tr460.exe"), str(cave/"p_ret_lit.x"), "-o", str(cave/"_lit.exe")], capture_output=True, timeout=8)
r2 = subprocess.run([str(cave/"_lit.exe")], capture_output=True, timeout=3)
print("LIT run", r2.returncode & 0xffffffff, "out", r2.stdout[:100])
