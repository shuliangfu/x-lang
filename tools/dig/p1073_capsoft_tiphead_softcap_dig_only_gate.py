"""10.73 Cap soft tiphead dig SoftCap dig-only SoftCap-parity Prefer 4/4 + multi/one/classic/exact → 8/8.

Host = lab_CapSoftWin_tiphead_*_P1073_*.exe under g05th_dig.
Soft Cap PROD/cave 74d0 + tiphead Prefer-M2 9ecd HOLD — never raise.
"""
from __future__ import annotations

import hashlib
import subprocess
import sys
from pathlib import Path

PROD = Path(r"C:\xlang_tmp\prod_softcap\lab_SoftCap_76795.exe")
CAVE_SC = Path(r"C:\xlang_tmp\p1060\cave\lab_SoftCap_76795.exe")
TIPHEAD = Path(r"C:\xlang_tmp\p1060\cave\lab_CapSoftWin_tiphead.exe")
OUT = Path(r"C:\xlang_tmp\dig_logs\p1073_softcap_dig_only_gate")
CAVE = Path(r"C:\xlang_tmp\p1060\cave")
EXPECTED_PROD = "74d0bd9c9fbf"
EXPECTED_TIP = "9ecd26ea44ab"
BANNED_HOST = {"a1491a74c08b", "1e59c5261663", "74d0bd9c9fbf", "9ecd26ea44ab", "07eadd3fe8bf", "d8e2d409a140"}

PARITY = {
    "lit": (
        "p_ret_lit.x",
        "struct Point { a: i64, b: i64, c: i64 }\nfunction f(): Point { return Point { a: 1, b: 2, c: 3 }; }\nfunction main(): i32 {\n  let p: Point = f();\n  if (p.a != 1) { return 1; }\n  if (p.b != 2) { return 2; }\n  if (p.c != 3) { return 3; }\n  return 0;\n}\n",
    ),
    "fwd": (
        "p_ret_fwd.x",
        "struct Point { a: i64, b: i64, c: i64 }\nfunction g(): Point { return Point { a: 1, b: 2, c: 3 }; }\nfunction f(): Point { return g(); }\nfunction main(): i32 {\n  let p: Point = f();\n  if (p.a != 1) { return 1; }\n  if (p.b != 2) { return 2; }\n  if (p.c != 3) { return 3; }\n  return 0;\n}\n",
    ),
    "local": (
        "p_ret_local.x",
        "struct Point { a: i64, b: i64, c: i64 }\nfunction main(): i32 {\n  let p: Point = Point { a: 1, b: 2, c: 3 };\n  if (p.a != 1) { return 1; }\n  if (p.b != 2) { return 2; }\n  if (p.c != 3) { return 3; }\n  return 0;\n}\n",
    ),
    "_var_let": (
        "_var_let.x",
        "struct Point { a: i64, b: i64, c: i64 }\nfunction f(): Point {\n  let a: i64 = 1;\n  let b: i64 = 2;\n  let c: i64 = 3;\n  return Point { a: a, b: b, c: c };\n}\nfunction main(): i32 {\n  let p: Point = f();\n  if (p.a != 1) { return 1; }\n  if (p.b != 2) { return 2; }\n  if (p.c != 3) { return 3; }\n  return 0;\n}\n",
    ),
}
EXTRAS = {
    "multi": (
        "p1061_sret_lit_multi.x",
        "struct Point { a: i64, b: i64, c: i64 }\nfunction f(): Point {\n  let x: i64 = 1;\n  return Point { a: x, b: 2, c: 3 };\n}\nfunction main(): i32 {\n  let p: Point = f();\n  if (p.a != 1) { return 1; }\n  if (p.b != 2) { return 2; }\n  if (p.c != 3) { return 3; }\n  return 0;\n}\n",
    ),
    "one": (
        "p1061_sret_lit_one.x",
        "struct Point { a: i64, b: i64, c: i64 }\nfunction f(): Point {\n  return Point { a: 1, b: 2, c: 3 };\n}\nfunction main(): i32 {\n  let p: Point = f();\n  if (p.a != 1) { return 1; }\n  if (p.b != 2) { return 2; }\n  if (p.c != 3) { return 3; }\n  return 0;\n}\n",
    ),
    "classic": (
        "p1061_sret_lit_multi_classic.x",
        "struct Point { a: i64, b: i64, c: i64 }\nfunction main(): i32 {\n  let x: i64 = 1;\n  let p: Point = Point { a: x, b: 2, c: 3 };\n  if (p.a != 1) { return 1; }\n  if (p.b != 2) { return 2; }\n  if (p.c != 3) { return 3; }\n  return 0;\n}\n",
    ),
    "exact": (
        "p1061_sret_lit_multi_exact.x",
        "struct Point { a: i64, b: i64, c: i64 }\nfunction f(): Point {\n  let x: i64 = 1;\n  return Point { a: x, b: 2, c: 3 };\n}\nfunction main(): i32 {\n  let p: Point = f();\n  if (p.a != 1) { return 1; }\n  if (p.b != 2) { return 2; }\n  if (p.c != 3) { return 3; }\n  return 0;\n}\n",
    ),
}


def sha12(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()[:12]


def tag(c: int) -> str:
    c = c & 0xFFFFFFFF
    return {0: "OK", 0x80000003: "INT3", 0xC0000409: "GS", 0xC0000005: "AV"}.get(
        c, hex(c)
    )


def resolve(fname: str, text: str) -> Path:
    for d in (
        CAVE,
        OUT,
        Path(r"C:\xlang_tmp\dig_logs\cold_parity4_raise_f10"),
        Path(r"C:\xlang_tmp\dig_logs\cold_parity4_raise1062"),
        Path(r"C:\xlang_tmp\dig_logs\p1072_residual"),
    ):
        p = d / fname
        if p.exists():
            return p
    OUT.mkdir(parents=True, exist_ok=True)
    dst = OUT / fname
    dst.write_text(text, encoding="utf-8")
    return dst


def run_gate(host: Path, label: str, src: Path):
    OUT.mkdir(parents=True, exist_ok=True)
    outp = OUT / f"{host.stem[:24]}_{label}.exe"
    if outp.exists():
        try:
            outp.unlink()
        except OSError:
            pass
    log = OUT / f"{host.stem[:24]}_{label}.bld.log"
    try:
        r = subprocess.run(
            [str(host), str(src), "-o", str(outp)],
            capture_output=True,
            timeout=90,
            cwd=str(CAVE),
        )
    except Exception as ex:
        log.write_bytes(str(ex).encode())
        return "BUILD_EX", -1, ""
    log.write_bytes((r.stdout or b"") + b"\n---\n" + (r.stderr or b""))
    if r.returncode != 0 or not outp.exists():
        return "BUILD_FAIL", r.returncode, log.read_text(errors="replace")[:200]
    try:
        rr = subprocess.run([str(outp)], capture_output=True, timeout=30)
        return "RUN", rr.returncode, tag(rr.returncode)
    except Exception as ex:
        return "RUN_EX", -1, str(ex)


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: p1073_capsoft_tiphead_softcap_dig_only_gate.py <host.exe>")
        return 2
    host = Path(sys.argv[1])
    assert host.exists(), host
    hs = sha12(host)
    assert hs not in BANNED_HOST, hs
    pre_prod, pre_cave, pre_tip = sha12(PROD), sha12(CAVE_SC), sha12(TIPHEAD)
    assert pre_prod == EXPECTED_PROD and pre_cave == EXPECTED_PROD and pre_tip == EXPECTED_TIP

    rows = []
    ok = 0
    for name, (fname, text) in {**PARITY, **EXTRAS}.items():
        src = resolve(fname, text)
        kind, code, info = run_gate(host, name, src)
        good = kind == "RUN" and code == 0
        if good:
            ok += 1
        rows.append((name, kind, code, info, good))
        print(f"{name:10s} {kind:10s} code={code} {info} {'OK' if good else 'FAIL'}")

    post_prod, post_cave, post_tip = sha12(PROD), sha12(CAVE_SC), sha12(TIPHEAD)
    print("SCORE", f"{ok}/8")
    print("HOST", hs, host)
    print("HOLD_PRE ", pre_prod, pre_cave, pre_tip)
    print("HOLD_POST", post_prod, post_cave, post_tip)
    assert post_prod == pre_prod == EXPECTED_PROD
    assert post_cave == pre_cave == EXPECTED_PROD
    assert post_tip == pre_tip == EXPECTED_TIP
    print("HOLD_OK")
    return 0 if ok == 8 else 1


if __name__ == "__main__":
    raise SystemExit(main())
