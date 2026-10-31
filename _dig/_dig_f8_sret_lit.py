# F8: trampoline emit_struct_lit_elf_c -> PAD; when sret active park
# home into rbx then fields(DEST_IN_RBX=-3) + mov_rbx_to_rax (w1778 lit path).
# Base: F3 e4b57ee59d26. Cave tip MUST stay 13e5e99ef39b.
import struct, subprocess, hashlib, shutil, sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

DIG = Path(r"C:\xlang_tmp\p1060\g05th_dig")
CAVE = Path(r"C:\xlang_tmp\p1060\cave")
WORK = Path(r"C:\xlang_tmp\p1060\capsoft_win_rebuild")
F3 = DIG / "lab_CapSoftWin_tiphead_FACE_OKKEEP_dig_UNIFY_F3.exe"

HOOK = 0x1402DB1DA  # pipeline_asm_emit_struct_lit_elf_c
PAD  = 0x1406586C0  # free gap before PAD1 @ 0x1406587c0 (size 0x100)
FIELDS = 0x1402DADF2
SRET_ACTIVE = 0x1402AF954
SRET_HOME   = 0x1402AF973
SRET_SZ     = 0x1402AF992
ENC_LOAD    = 0x14053AA84
ENC_A2B     = 0x14053921C
ENC_B2A     = 0x14053B92C


def pe_meta(data):
    e = struct.unpack_from("<I", data, 0x3C)[0]
    nsec = struct.unpack_from("<H", data, e + 6)[0]
    opt = struct.unpack_from("<H", data, e + 20)[0]
    magic = struct.unpack_from("<H", data, e + 24)[0]
    ib = (
        struct.unpack_from("<Q", data, e + 24 + 24)[0]
        if magic == 0x20B
        else struct.unpack_from("<I", data, e + 24 + 28)[0]
    )
    so = e + 24 + opt
    for i in range(nsec):
        o = so + i * 40
        name = data[o : o + 8].split(b"\x00")[0]
        vsz, rva, rsz, roff = struct.unpack_from("<IIII", data, o + 8)
        if name.startswith(b".text"):
            return ib, rva, roff, rsz
    raise SystemExit("no text")


def foff(va, ib, rva, roff):
    return roff + ((va - ib) - rva)


def sha12(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()[:12]


def rel32(src, dst):
    return (dst - (src + 5)) & 0xFFFFFFFF


def call_rel(at, target):
    return b"\xE8" + struct.pack("<I", rel32(at, target))


def emit_pad(base):
    code = bytearray()
    labels = {}
    fixups = []

    def L(name):
        labels[name] = len(code)

    def put(b):
        code.extend(b)

    def jcc8(op, name):
        put(bytes([op, 0x00]))
        fixups.append((len(code) - 1, "rel8", name))

    def jcc32(op_near, name):
        # op_near is second byte of 0F xx (e.g. 0x85 = jnz)
        put(bytes([0x0F, op_near, 0x00, 0x00, 0x00, 0x00]))
        fixups.append((len(code) - 4, "rel32", name))

    def jmp8(name):
        put(b"\xEB\x00")
        fixups.append((len(code) - 1, "rel8", name))

    def call_abs(target_va):
        at = base + len(code)
        put(call_rel(at, target_va))

    put(b"\x55")
    put(b"\x48\x89\xE5")
    put(b"\x48\x83\xEC\x40")
    put(b"\x48\x89\x4D\x10")
    put(b"\x48\x89\x55\x18")
    put(b"\x44\x89\x45\x20")
    put(b"\x4C\x89\x4D\x28")

    put(b"\x8B\x45\x30")
    put(b"\x85\xC0")
    jcc32(0x85, "ORIG")

    call_abs(SRET_ACTIVE)
    put(b"\x85\xC0")
    jcc32(0x84, "ORIG")

    call_abs(SRET_HOME)
    put(b"\x89\x45\xFC")
    put(b"\x85\xC0")
    jcc32(0x88, "ORIG")

    call_abs(SRET_SZ)
    put(b"\x83\xF8\x10")
    jcc32(0x8E, "ORIG")
    put(b"\x3D\x00\x10\x00\x00")
    jcc32(0x8F, "ORIG")

    put(b"\x8B\x4D\x30")
    put(b"\x8B\x55\xFC")
    put(b"\x48\x8B\x45\x18")
    put(b"\x41\x89\xC8")
    put(b"\x48\x89\xC1")
    call_abs(ENC_LOAD)
    put(b"\x85\xC0")
    jcc8(0x75, "FAIL")

    put(b"\x8B\x55\x30")
    put(b"\x48\x8B\x45\x18")
    put(b"\x48\x89\xC1")
    call_abs(ENC_A2B)
    put(b"\x85\xC0")
    jcc8(0x75, "FAIL")

    put(b"\x4C\x8B\x4D\x28")
    put(b"\x44\x8B\x45\x20")
    put(b"\x48\x8B\x55\x18")
    put(b"\x48\x8B\x45\x10")
    put(b"\xC7\x44\x24\x28\xFD\xFF\xFF\xFF")
    put(b"\x8B\x4D\x30")
    put(b"\x89\x4C\x24\x20")
    put(b"\x48\x89\xC1")
    call_abs(FIELDS)
    put(b"\x85\xC0")
    jcc8(0x75, "FAIL")

    put(b"\x8B\x55\x30")
    put(b"\x48\x8B\x45\x18")
    put(b"\x48\x89\xC1")
    call_abs(ENC_B2A)
    put(b"\x85\xC0")
    jcc8(0x75, "FAIL")

    put(b"\x31\xC0")
    jmp8("EPILOG")

    L("FAIL")
    put(b"\xB8\xFF\xFF\xFF\xFF")
    jmp8("EPILOG")

    L("ORIG")
    put(b"\x4C\x8B\x4D\x28")
    put(b"\x44\x8B\x45\x20")
    put(b"\x48\x8B\x55\x18")
    put(b"\x48\x8B\x45\x10")
    put(b"\xC7\x44\x24\x28\xFF\xFF\xFF\xFF")
    put(b"\x8B\x4D\x30")
    put(b"\x89\x4C\x24\x20")
    put(b"\x48\x89\xC1")
    call_abs(FIELDS)

    L("EPILOG")
    put(b"\x48\x83\xC4\x40")
    put(b"\x5D")
    put(b"\xC3")

    for off, kind, name in fixups:
        target = labels[name]
        if kind == "rel8":
            delta = target - (off + 1)
            if delta < -128 or delta > 127:
                raise SystemExit("rel8 overflow at %s delta=%d" % (name, delta))
            code[off] = delta & 0xFF
        elif kind == "rel32":
            delta = target - (off + 4)
            struct.pack_into("<i", code, off, delta)
    return bytes(code)


assert sha12(F3) == "e4b57ee59d26", sha12(F3)
assert sha12(CAVE / "lab_CapSoftWin_tiphead.exe") == "13e5e99ef39b"

data = bytearray(F3.read_bytes())
ib, rva, roff, rsz = pe_meta(data)
pad_code = emit_pad(PAD)
print("PAD size", hex(len(pad_code)), "limit", hex(0x100))
assert len(pad_code) <= 0x100, len(pad_code)

pad_fo = foff(PAD, ib, rva, roff)
region = bytes(data[pad_fo : pad_fo + len(pad_code)])
assert all(b == 0 for b in region), "PAD not empty: " + region[:16].hex()

data[pad_fo : pad_fo + len(pad_code)] = pad_code

hook_fo = foff(HOOK, ib, rva, roff)
orig5 = bytes(data[hook_fo : hook_fo + 5])
print("HOOK orig5", orig5.hex())
jmp = b"\xE9" + struct.pack("<I", rel32(HOOK, PAD))
data[hook_fo : hook_fo + 5] = jmp

out = DIG / "lab_CapSoftWin_tiphead_FACE_OKKEEP_dig_UNIFY_F8.exe"
out.write_bytes(data)
host = CAVE / "lab_CapSoftWin_tiphead_FACE_UNIFY_F8_dig.exe"
shutil.copy2(out, host)
print("OUT F8", sha12(out))
print("HOST", host, sha12(host))
assert sha12(CAVE / "lab_CapSoftWin_tiphead.exe") == "13e5e99ef39b"

subprocess.run(
    ["objdump", "-d", "--start-address=%s" % hex(HOOK), "--stop-address=%s" % hex(HOOK + 8), str(out)],
    check=False,
)
subprocess.run(
    ["objdump", "-d", "--start-address=%s" % hex(PAD), "--stop-address=%s" % hex(PAD + len(pad_code)), str(out)],
    check=False,
)

OUTDIR = DIG / "unify_cold"
OUTDIR.mkdir(exist_ok=True)
SRCS = ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x", "_var_let.x"]


def cold(h, lab):
    ok = 0
    print("===", lab, sha12(h), "===")
    for s in SRCS:
        o = OUTDIR / ("%s_%s.exe" % (lab, Path(s).stem))
        if o.exists():
            try:
                o.unlink()
            except Exception:
                pass
        r = subprocess.run(
            [str(h), "build", str(CAVE / s), "-o", str(o)],
            capture_output=True,
            timeout=90,
            cwd=str(WORK),
        )
        err = ((r.stderr or b"") + (r.stdout or b"")).decode("utf-8", "replace")
        note = ""
        for line in err.splitlines():
            if "error" in line.lower() or "XT001" in line or "T001" in line or "implicit" in line.lower():
                note = line.strip()[:140]
                break
        if not note and r.returncode != 0:
            note = err.strip().splitlines()[0][:100] if err.strip() else hex(r.returncode & 0xFFFFFFFF)
        run = "-"
        if o.exists() and o.stat().st_size > 0:
            run = str(subprocess.run([str(o)], capture_output=True, timeout=5).returncode & 0xFFFFFFFF)
        mark = "OK" if r.returncode == 0 and run == "0" else "FAIL"
        if mark == "OK":
            ok += 1
        print(" ", s, "rc", r.returncode & 0xFFFFFFFF, "run", run, mark, note)
        if o.exists() and o.stat().st_size > 0:
            d = subprocess.run(
                ["objdump", "-d", str(o)], capture_output=True, text=True, errors="replace"
            ).stdout
            lines = d.splitlines()
            in_mk = False
            buf = []
            for ln in lines:
                if "_mk>" in ln:
                    in_mk = True
                    buf = []
                if in_mk:
                    buf.append(ln)
                    if "ret" in ln and len(buf) > 5:
                        break
                    if len(buf) > 50:
                        break
            for ln in buf:
                if any(k in ln for k in ("rcx", "lea", "ret", "_mk>", "0x0(%", "(%rbx", "%rbx")):
                    print("  |", ln.strip())
    so = OUTDIR / ("%s_ft_slit.exe" % lab)
    r = subprocess.run(
        [str(h), "build", str(DIG / "ft_slit.x"), "-o", str(so)],
        capture_output=True,
        timeout=90,
        cwd=str(WORK),
    )
    run = "-"
    if so.exists() and so.stat().st_size > 0:
        run = str(subprocess.run([str(so)], capture_output=True, timeout=5).returncode & 0xFFFFFFFF)
    print(
        " slit rc",
        r.returncode & 0xFFFFFFFF,
        "run",
        run,
        "OK" if r.returncode == 0 and run == "1" else "FAIL",
    )
    print(" =>", ok, "/4")


cold(host, "F8")
print("CAVE tip", sha12(CAVE / "lab_CapSoftWin_tiphead.exe"))
