"""10.70 Soft Cap dig-egg SoftCap SoftCap-parity dig-only gate.

Host = Soft Cap dig egg PE under g05th_dig/lab_SoftCap_*_P1070_*.exe.
PROD Soft Cap d8e2 / cave Soft Cap / tiphead Prefer-M2 9ecd HOLD — never raise.
"""
from __future__ import annotations

import hashlib
import os
import subprocess
import sys
from pathlib import Path

PROD = Path(r"C:\xlang_tmp\prod_softcap\lab_SoftCap_76795.exe")
CAVE_SC = Path(r"C:\xlang_tmp\p1060\cave\lab_SoftCap_76795.exe")
TIPHEAD = Path(r"C:\xlang_tmp\p1060\cave\lab_CapSoftWin_tiphead.exe")
OUT = Path(r"C:\xlang_tmp\dig_logs\p1070_softcap_dig_only_gate")
WORK = Path(r"C:\xlang_tmp\p1060\capsoft_win_rebuild")
CAVE = Path(r"C:\xlang_tmp\p1060\cave")
EXPECTED_PROD = "74d0bd9c9fbf"  # Soft Cap PROD after 10.70 raise; dig-only HOLD
EXPECTED_TIP = "9ecd26ea44ab"
BANNED_HOST = {"a1491a74c08b", "d8e2d409a140", "9ecd26ea44ab", "07eadd3fe8bf", "74d0bd9c9fbf", "1f78def393fc", "5dff12e7772e", "1e59c5261663"}

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
    ):
        p = d / fname
        if p.exists():
            return p
    dst = OUT / fname
    dst.write_text(text, encoding="utf-8")
    return dst


def run_gate(host: Path, label: str, src: Path, cwd: str):
    outp = OUT / f"{host.stem[:20]}_{label}.exe"
    if outp.exists():
        try:
            outp.unlink()
        except OSError:
            pass
    log = OUT / f"{host.stem[:20]}_{label}.bld.log"
    try:
        r = subprocess.run(
            [str(host), str(src), "-o", str(outp)],
            capture_output=True,
            timeout=90,
            cwd=cwd,
            env=os.environ.copy(),
        )
    except subprocess.TimeoutExpired:
        log.write_text("TIMEOUT\n", encoding="utf-8")
        return "TIMEOUT", "BUILD_FAIL", "FAIL", "TIMEOUT"
    errb = (r.stderr or b"") + (r.stdout or b"")
    log.write_bytes(errb)
    hc = tag(r.returncode)
    err = errb.decode("utf-8", "replace")
    note = next(
        (
            k
            for k in ("CG002", "XT001", "BLD001", "TYPECK", "XP001", "code_len=0")
            if k in err
        ),
        "-",
    )
    if "code_len=0" in err and note == "CG002":
        note = "CG002/code_len=0"
    if not outp.exists() or outp.stat().st_size == 0 or hc != "OK":
        return hc, f"BUILD_FAIL/{note}", "FAIL", note
    rr = subprocess.run([str(outp)], capture_output=True, timeout=15)
    rc = rr.returncode & 0xFFFFFFFF
    run = tag(rc) if rc > 3 else str(rc)
    return hc, run, ("OK" if run == "0" else "FAIL"), note


def main() -> int:
    os.environ["PATH"] = (
        r"C:\w64devkit\bin;C:\mingw64\bin;" + os.environ.get("PATH", "")
    )
    if len(sys.argv) < 2:
        print("usage: p1070_softcap_dig_only_gate.py <softcap_dig_egg.exe>")
        return 2
    dig = Path(sys.argv[1])
    assert dig.exists(), dig
    OUT.mkdir(parents=True, exist_ok=True)

    prod_pre = sha12(PROD)
    cave_pre = sha12(CAVE_SC)
    tip_pre = sha12(TIPHEAD)
    dig_h = sha12(dig)
    print(
        f"PRE PROD={prod_pre} CAVE_SC={cave_pre} TIPHEAD={tip_pre} DIG={dig_h} size={dig.stat().st_size}",
        flush=True,
    )
    assert prod_pre == EXPECTED_PROD and cave_pre == EXPECTED_PROD
    assert tip_pre == EXPECTED_TIP
    assert dig_h not in BANNED_HOST, dig_h
    assert "SoftCap" in dig.name or "lab_SoftCap" in dig.name, dig.name
    assert dig.stat().st_size <= 10_000_000

    cwd = str(WORK if (WORK / "seeds").exists() else str(OUT))
    print(f"BUILD_CWD={cwd}", flush=True)

    ok = 0
    rows = []
    for key, (fname, text) in list(PARITY.items()) + list(EXTRAS.items()):
        src = resolve(fname, text)
        hc, run, st, note = run_gate(dig, key, src, cwd)
        if st == "OK":
            ok += 1
        rows.append((key, hc, run, st, note))
        print(f"  {key:10s} build={hc:8s} run={run:8s} {st} note={note}", flush=True)

    prod_post = sha12(PROD)
    cave_post = sha12(CAVE_SC)
    tip_post = sha12(TIPHEAD)
    print(
        f"POST PROD={prod_post} CAVE_SC={cave_post} TIPHEAD={tip_post}",
        flush=True,
    )
    assert prod_post == EXPECTED_PROD and cave_post == EXPECTED_PROD
    assert tip_post == EXPECTED_TIP
    print(f"SOFTCAP_DIG_ONLY {ok}/8 dig={dig_h} size={dig.stat().st_size}", flush=True)
    print("HOLD Soft Cap/nail/9ecd UNTOUCHED", flush=True)
    return 0 if ok == 8 else 1


if __name__ == "__main__":
    raise SystemExit(main())
