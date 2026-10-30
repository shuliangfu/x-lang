"""Isol-calt_miss: Capless-alt ALL early-success → fallthrough.

DIG (INT3 probes):
- SoftCap-full@57effc INT3 → p_ret_lit still TT ⇒ NEVER SoftCap-full
- SoftCap twin@57ef78 INT3 → still TT ⇒ NEVER SoftCap twin/SoftMega
- Capless@555ed8 INT3 → still TT ⇒ Capless SoftCap-site NOT hit
- Capless-alt@57656c INT3 → TIMEOUT ⇒ SoftCap CallExpr IS Capless-alt (kind 0x30)
Ban LIVE SoftCap transplant. SoftCap-full never CE.

Plant: every Capless-alt early-success (helper>0 → mov eax,0; jmp exit@578278)
→ jmp fallthrough (force Capless SoftCap early-claim into miss / next helper /
post_args@57464c which calls arch_E8). Semantic calt_miss.
"""
from pathlib import Path
import struct, hashlib, subprocess, os, time
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

CAVE_DIR = Path(r"C:/xlang_tmp/p1060/cave")
cands = [CAVE_DIR / "xlang_isol1060_TT.exe", Path("/tmp/p1060_dig/bins/xlang_isol1060_TT.exe")]
TT = next(p for p in cands if p.exists())
if CAVE_DIR.exists():
    os.chdir(CAVE_DIR)
pe = bytearray(TT.read_bytes())
assert hashlib.sha256(pe).hexdigest()[:12] == "1f836615e0fc"

def pe_secs(buf):
    e = struct.unpack_from("<I", buf, 0x3C)[0]
    nsec = struct.unpack_from("<H", buf, e + 6)[0]
    opt = struct.unpack_from("<H", buf, e + 20)[0]
    sec = e + 24 + opt
    out = {}
    for i in range(nsec):
        o = sec + i * 40
        n = bytes(buf[o:o+8]).split(b"\0")[0]
        vs, va, rs, ro = struct.unpack_from("<IIII", buf, o+8)
        out[n] = (va, vs, ro, rs)
    return out

def rva2off(buf, secs, r):
    for n, (va, vs, ro, rs) in secs.items():
        if va <= r < va + max(vs, rs):
            return ro + (r - va)
    raise ValueError(hex(r))

Isec = pe_secs(pe)
md = Cs(CS_ARCH_X86, CS_MODE_64)
CALT, EXIT = 0x57656C, 0x578278
off = rva2off(pe, Isec, CALT)
insns = list(md.disasm(bytes(pe[off:off+(EXIT-CALT)]), CALT))
early = []
for i, insn in enumerate(insns):
    if insn.mnemonic == "mov" and insn.op_str == "eax, 0":
        for j in range(i+1, min(i+4, len(insns))):
            nxt = insns[j]
            if nxt.mnemonic == "jmp" and nxt.op_str == hex(EXIT):
                fall = nxt.address + nxt.size
                if j+1 < len(insns) and insns[j+1].mnemonic == "jmp" and insns[j+1].op_str.startswith("0x"):
                    fall = int(insns[j+1].op_str, 16)
                if i > 0 and insns[i-1].mnemonic == "jle" and insns[i-1].op_str.startswith("0x"):
                    fall = int(insns[i-1].op_str, 16)
                early.append((insn.address, nxt.address, fall))
                break
            if nxt.mnemonic.startswith("j") or nxt.mnemonic == "call":
                break
assert len(early) == 20, len(early)
for a, ja, fall in early:
    offa = rva2off(pe, Isec, a)
    assert pe[offa:offa+5] == bytes.fromhex("b800000000") and pe[offa+5] == 0xE9
    rel8 = fall - (a + 2)
    if -128 <= rel8 <= 127:
        pe[offa:offa+10] = bytes([0xEB, rel8 & 0xFF]) + b"\x90" * 8
    else:
        struct.pack_into("<i", pe, rva2off(pe, Isec, ja)+1, fall - (ja + 5))

out_name = "xlang_isol1060_calt_miss.exe"
Path("/tmp/p1060_dig/bins").mkdir(parents=True, exist_ok=True)
(Path("/tmp/p1060_dig/bins") / out_name).write_bytes(pe)
out = (CAVE_DIR / out_name) if CAVE_DIR.exists() else Path("/tmp/p1060_dig/bins") / out_name
out.write_bytes(pe)
sha = hashlib.sha256(pe).hexdigest()
print("Isol-calt_miss", sha[:12], f"n={len(early)} Capless-alt early→fallthrough")

if not CAVE_DIR.exists():
    print("no Win cave — plant only"); raise SystemExit(0)

outdir = Path("out_calt_miss"); outdir.mkdir(exist_ok=True)

def find(name):
    for root in [Path(r"C:/xlang_tmp/p1060"), Path(r"C:/xlang_tmp/p1060/cave"),
                 Path(r"C:/Users/shuliangfu/worker/xlang/x-lang/tests/probes/p_big_struct")]:
        p = root / name
        if p.exists(): return str(p)
    return None

for label, fname in [("p_ret_lit","p_ret_lit.x"),("p_ret_fwd","p_ret_fwd.x"),("p_ret_local","p_ret_local.x")]:
    src = find(fname); dst = str((outdir/(label+".exe")).resolve()); rec={"src":src}
    if not src: print(label, {"fail":"missing"}); continue
    t0 = time.time()
    r = subprocess.run([str(out.resolve()), src, "-o", dst], capture_output=True, timeout=180)
    rec["crc"] = r.returncode & 0xFFFFFFFF; rec["dt"] = round(time.time()-t0, 2)
    if r.returncode == 0 and Path(dst).exists():
        raw = Path(dst).read_bytes()
        rec["sha"] = hashlib.sha256(raw).hexdigest()[:12]
        rec["n868"] = raw.count(bytes.fromhex("4881ec68080000"))
        rec["n878"] = raw.count(bytes.fromhex("4881ec78080000"))
        rec["n1b8"] = raw.count(bytes.fromhex("4881ecb8010000"))
        rec["ba0a"] = raw.count(bytes.fromhex("ba0a000000"))
        rec["b80a"] = raw.count(bytes.fromhex("b80a000000"))
        rec["match_TT"] = (rec["sha"]=="5b173cef1205") if label=="p_ret_lit" else None
        rec["match_LIVE"] = (rec["sha"]=="dbaab1c7ce70") if label=="p_ret_lit" else None
        try: rec["run"] = subprocess.run([dst], capture_output=True, timeout=30).returncode & 0xFFFFFFFF
        except Exception as e: rec["run"] = str(e)
    else:
        rec["fail"]=True; rec["err"]=(r.stderr or b"")[-400:]
    print(label, rec)
print("DONE", sha[:12])
