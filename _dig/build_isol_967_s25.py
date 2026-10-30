#!/usr/bin/env python3
"""Isol-967_s25 (fwd_46_967_sret_persist): durable rebuild + cold gate.

Recipe (from dig25 winner):
  BASE host_967_sret_tr460.exe sha12 336f7fe218be
  1) Capless USER16 plant @57ba3b / len @57ba94:
       sub rsp,0x20; mov rax,[rbp-0x10]; inc rax; mov rdx,rax
  2) Fixup body @INT3 cave 0x559821 (589B) via trampoline jmp @57bbae→cave→57bd4e:
       scan c1→c2 / let_sret / main_imm9
  HOST sha12 e53841ce0e24 (assert)

Cold gate: lit/fwd/local/let must compile OK and run=0 with expected USER sha12.
PROD SoftCap 7a2cf5da581a / pin ecdb5cc1e: DO NOT TOUCH.
Gate green != PROD bump.
"""
from pathlib import Path
import struct, hashlib, subprocess, time, sys

CAVE = Path("C:/xlang_tmp/p1060/cave")
BASE = CAVE / "host_967_sret_tr460.exe"
HOST_NAME = "host_967_s25.exe"
HOST_ALIAS = "xlang_isol1060_967_s25.exe"  # semantic Isol WORK alias (not letter-pile)
BASE_SHA12 = "336f7fe218be"
HOST_SHA12 = "e53841ce0e24"
CAVE_RVA = 0x559821
TRAMP_AT = 0x57bbae
TRAMP_END = 0x57bd4e
XP1 = bytes.fromhex("4883ec20488b45f048ffc04889c2")  # sub20; mov rax,[rbp-0x10]; inc; mov rdx,rax
SRCS = ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x", "_var_let.x"]
EXPECT_USER = {
    "p_ret_lit.x": "5c6778769c3c",
    "p_ret_fwd.x": "a99121ae7a80",
    "p_ret_local.x": "36d26fcc9657",
    "_var_let.x": "d16c78ade1f2",
}
PREFIX = "_cold_s25"


def P(*a):
    print(*a, flush=True)


def pe_secs(buf):
    e = struct.unpack_from("<I", buf, 0x3C)[0]
    nsec = struct.unpack_from("<H", buf, e + 6)[0]
    opt = struct.unpack_from("<H", buf, e + 20)[0]
    sec = e + 24 + opt
    secs = {}
    for i in range(nsec):
        o = sec + i * 40
        n = bytes(buf[o : o + 8]).split(b"\0")[0]
        vs, va, rs, ro = struct.unpack_from("<IIII", buf, o + 8)
        secs[n] = (va, vs, ro, rs)
    return secs


def rva2off(buf, secs, r):
    for n, (va, vs, ro, rs) in secs.items():
        if va <= r < va + max(vs, rs):
            return ro + (r - va)
    raise ValueError(hex(r))


def tag_of(crc):
    return {
        0: "OK",
        0x80000003: "INT3",
        0xC0000409: "GS",
        0xC0000005: "AV",
    }.get(crc & 0xFFFFFFFF, hex(crc & 0xFFFFFFFF))


def plant_capless(pe, secs, payload):
    n = len(payload)
    assert 1 <= n <= 16
    pe = bytearray(pe)
    off = rva2off(pe, secs, 0x57ba3b)
    pe[off : off + 64] = b"".join(
        bytes([0xC6, 0x43, i, (payload[i] if i < n else 0x90)]) for i in range(16)
    )
    pe[rva2off(pe, secs, 0x57ba94) : rva2off(pe, secs, 0x57ba94) + 5] = bytes(
        [0xB8, n, 0, 0, 0]
    )
    return pe


def build_fixup_body(base_r=CAVE_RVA, end_r=TRAMP_END, scan_back=0x180):
    """3-scan fixup (c1→c2 / let_sret / main_imm9); ends with jmp end_r."""
    f = bytearray()

    def E(h):
        f.extend(bytes.fromhex(h) if isinstance(h, str) else h)

    def p32(at, tgt):
        struct.pack_into("<i", f, at + 2, tgt - (at + 6))

    def p8(at, tgt):
        f[at + 1] = (tgt - (at + 2)) & 0xFF

    E("4883ec20")
    E("b800000000")
    E("8985e0fdffff")
    E("b830007902")
    E("8985dcfdffff")
    E("488b45e8")
    E("8b95dcfdffff")
    E("4863d2")
    E("4801d0")
    E("488985d8fdffff")
    E("488b45e8")
    E("8b95e0fdffff")
    E("4863d2")
    E("4801d0")
    E("8b00")
    E("8985e4fdffff")
    E("3d04000000")
    jl0 = len(f)
    E("0f8c00000000")
    # scan1 c1→c2
    E("488b85d8fdffff")
    E("8b95e4fdffff")
    E("4863d2")
    E("488d3410")
    E("4889f7")
    E("4881ef" + struct.pack("<I", scan_back).hex())
    E("488b85d8fdffff")
    E("4839c7")
    E("480f42f8")
    L1 = len(f)
    E("4839f7")
    J1 = len(f)
    E("0f8300000000")
    E("803f48")
    a1 = len(f)
    E("7500")
    E("807f0189")
    a2 = len(f)
    E("7500")
    E("807f02c1")
    a3 = len(f)
    E("7500")
    E("807f03e8")
    a4 = len(f)
    E("7500")
    E("c64702c2")
    E("eb00")
    s1 = len(f) - 1
    N1 = len(f)
    E("48ffc7")
    b1 = len(f)
    E("e900000000")
    S1 = len(f)
    # scan2 let_sret
    E("488b85d8fdffff")
    E("8b95e4fdffff")
    E("4863d2")
    E("488d3410")
    E("4889f7")
    E("4881ef" + struct.pack("<I", scan_back).hex())
    E("488b85d8fdffff")
    E("4839c7")
    E("480f42f8")
    L2 = len(f)
    E("4839f7")
    J2 = len(f)
    E("0f8300000000")
    E("803f48")
    c1 = len(f)
    E("7500")
    E("807f018d")
    c2 = len(f)
    E("7500")
    E("807f0245")
    c3 = len(f)
    E("7500")
    E("807f03c8")
    c4 = len(f)
    E("7500")
    E("c647018b")
    E("c64703b0")
    E("eb00")
    s2 = len(f) - 1
    N2 = len(f)
    E("48ffc7")
    b2 = len(f)
    E("e900000000")
    S2 = len(f)
    # scan3 main_imm9
    E("488b85d8fdffff")
    E("8b95e4fdffff")
    E("4863d2")
    E("488d3410")
    E("4889f7")
    E("4881ef" + struct.pack("<I", scan_back).hex())
    E("488b85d8fdffff")
    E("4839c7")
    E("480f42f8")
    L3 = len(f)
    E("4839f7")
    J3 = len(f)
    E("0f8300000000")
    E("803f48")
    d1 = len(f)
    E("0f8500000000")
    E("807f018d")
    d2 = len(f)
    E("0f8500000000")
    E("807f0245")
    d3 = len(f)
    E("0f8500000000")
    E("807f03d8")
    d4 = len(f)
    E("0f8500000000")
    E("807f0448")
    d5 = len(f)
    E("0f8500000000")
    E("807f0589")
    d6 = len(f)
    E("0f8500000000")
    E("807f06c1")
    d7 = len(f)
    E("0f8500000000")
    E("807f0748")
    d8 = len(f)
    E("0f8500000000")
    E("807f0883")
    d9 = len(f)
    E("0f8500000000")
    E("807f09ec")
    d10 = len(f)
    E("0f8500000000")
    E("807f0a20")
    d11 = len(f)
    E("0f8500000000")
    E("807f0b48")
    d12 = len(f)
    E("0f8500000000")
    E("807f0c8b")
    d13 = len(f)
    E("0f8500000000")
    E("807f0d45")
    d14 = len(f)
    E("0f8500000000")
    E("807f0ef0")
    d15 = len(f)
    E("0f8500000000")
    E("807f0f48")
    d16 = len(f)
    E("0f8500000000")
    E("807f10ff")
    d17 = len(f)
    E("0f8500000000")
    E("807f11c0")
    d18 = len(f)
    E("0f8500000000")
    E("807f1248")
    d19 = len(f)
    E("0f8500000000")
    E("807f1389")
    d20 = len(f)
    E("0f8500000000")
    E("807f14c2")
    d21 = len(f)
    E("0f8500000000")
    E("c6470bb8")
    E("c6470c09")
    E("c6470d00")
    E("c6470e00")
    E("c6470f00")
    E("c6471048")
    E("c6471189")
    E("c64712c2")
    E("c6471390")
    E("c6471490")
    E("eb00")
    s3 = len(f) - 1
    N3 = len(f)
    E("48ffc7")
    b3 = len(f)
    E("e900000000")
    S3 = len(f)
    E("4883c420")
    e9 = len(f)
    E("e900000000")
    p32(jl0, S3)
    p32(J1, S1)
    p32(J2, S2)
    p32(J3, S3)
    for a in (a1, a2, a3, a4):
        p8(a, N1)
    f[s1] = (S1 - (s1 + 1)) & 0xFF
    struct.pack_into("<i", f, b1 + 1, L1 - (b1 + 5))
    for a in (c1, c2, c3, c4):
        p8(a, N2)
    f[s2] = (S2 - (s2 + 1)) & 0xFF
    struct.pack_into("<i", f, b2 + 1, L2 - (b2 + 5))
    for a in (
        d1,
        d2,
        d3,
        d4,
        d5,
        d6,
        d7,
        d8,
        d9,
        d10,
        d11,
        d12,
        d13,
        d14,
        d15,
        d16,
        d17,
        d18,
        d19,
        d20,
        d21,
    ):
        p32(a, N3)
    f[s3] = (S3 - (s3 + 1)) & 0xFF
    struct.pack_into("<i", f, b3 + 1, L3 - (b3 + 5))
    struct.pack_into("<i", f, e9 + 1, end_r - (base_r + e9 + 5))
    return f


def apply(pe, secs):
    pe = bytearray(pe)
    body = build_fixup_body()
    P(f"  body len={len(body)} @cave {CAVE_RVA:#x}")
    coff = rva2off(pe, secs, CAVE_RVA)
    assert pe[coff : coff + 4] == b"\xcc" * 4, pe[coff : coff + 8].hex()
    pe[coff : coff + len(body)] = body
    tramp = bytearray()
    tramp.append(0xE9)
    tramp.extend(struct.pack("<i", CAVE_RVA - (TRAMP_AT + 5)))
    pad = TRAMP_END - TRAMP_AT - len(tramp)
    tramp.extend(b"\x90" * pad)
    pe[rva2off(pe, secs, TRAMP_AT) : rva2off(pe, secs, TRAMP_END)] = tramp
    P(f"  trampoline jmp {CAVE_RVA:#x} pad={pad}")
    return pe


def rebuild():
    assert BASE.exists(), f"missing BASE {BASE}"
    base = bytearray(BASE.read_bytes())
    bsha = hashlib.sha256(base).hexdigest()[:12]
    P(f"BASE sha={bsha} (expect {BASE_SHA12})")
    assert bsha == BASE_SHA12, bsha
    secs = pe_secs(base)
    pe = plant_capless(base, secs, XP1)
    pe = apply(pe, pe_secs(pe))
    hsha = hashlib.sha256(pe).hexdigest()[:12]
    P(f"HOST sha={hsha} (expect {HOST_SHA12})")
    assert hsha == HOST_SHA12, hsha
    out = CAVE / HOST_NAME
    out.write_bytes(bytes(pe))
    alias = CAVE / HOST_ALIAS
    alias.write_bytes(bytes(pe))
    P(f"wrote {out.name} + alias {alias.name}")
    return out, hsha


def cold_gate(host: Path):
    rows = []
    ok_all = True
    for s in SRCS:
        out = CAVE / f"{PREFIX}_{Path(s).stem}.exe"
        if out.exists():
            try:
                out.unlink()
            except OSError:
                pass
        r = subprocess.run(
            [str(host), str(CAVE / s), "-o", str(out)],
            capture_output=True,
            timeout=15,
        )
        crc = r.returncode & 0xFFFFFFFF
        user = "-"
        rt = "-"
        if out.exists() and out.stat().st_size > 0:
            user = hashlib.sha256(out.read_bytes()).hexdigest()[:12]
            rc = subprocess.run([str(out)], capture_output=True, timeout=3).returncode
            rc = rc & 0xFFFFFFFF
            rt = tag_of(rc) if rc > 3 else str(rc)
        expect = EXPECT_USER[s]
        mark = "OK" if (tag_of(crc) == "OK" and rt == "0" and user == expect) else "FAIL"
        if mark != "OK":
            ok_all = False
        P(
            f"  {s:16s} host={tag_of(crc):8s} USER={user} (exp {expect}) run={rt:8s} {mark}"
        )
        rows.append((s, tag_of(crc), user, rt, mark))
    return ok_all, rows


def main():
    t0 = time.time()
    if not CAVE.exists():
        P("no Win cave — abort")
        return 2
    P("=== rebuild Isol-967_s25 (persist) ===")
    host, hsha = rebuild()
    P("=== cold gate lit/fwd/local/let ===")
    ok, rows = cold_gate(host)
    P(f"\n=== SUMMARY elapsed={time.time()-t0:.1f}s host={hsha} cold={'GREEN' if ok else 'RED'} ===")
    P("PROD SoftCap / pin: untouched (gate green != PROD bump)")
    return 0 if ok else 1


if __name__ == "__main__":
    try:
        sys.exit(main())
    except subprocess.TimeoutExpired as e:
        P(f"TIMEOUT: {e}")
        sys.exit(3)
