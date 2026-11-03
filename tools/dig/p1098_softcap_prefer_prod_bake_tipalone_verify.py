"""10.98 Soft Cap Prefer tip-alone suite re-verify after PROD Soft Cap bake dig 09fe."""
from __future__ import annotations

import hashlib
import os
import subprocess
import sys
from pathlib import Path

PROD = Path(r"C:\xlang_tmp\prod_softcap\lab_SoftCap_76795.exe")
CAVE = Path(r"C:\xlang_tmp\p1060\cave")
DIG09 = Path(
    r"C:\xlang_tmp\p1060\g05th_dig\lab_SoftCap_d8e2_preferM2_SoftCapPrefer_tipx_nested_let_P1092_09fe181dbd0e.exe"
)
DIG3F = Path(
    r"C:\xlang_tmp\p1060\g05th_dig\lab_SoftCap_d8e2_preferM2_SoftCapPrefer_tipx_call_arg_P1091_3f6ad9910c48.exe"
)
BAK = Path(r"C:\xlang_tmp\p1060\bak\lab_SoftCap_76795_74d0bd9c9fbf_pre_1098_raise.exe")
TIPHEAD = Path(r"C:\xlang_tmp\p1060\cave\lab_CapSoftWin_tiphead.exe")
FIXSRC = Path(r"C:\xlang_tmp\p1092")
OUT = Path(r"C:\xlang_tmp\p1098")
STEMS = [
    "softcap_lit",
    "call_arg",
    "nested_let",
    "n_no_assign",
    "call_arg_direct",
]


def sha12(p: Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()[:12]


def prefer_one(host: Path, tag: str, stem: str) -> tuple[str, int, str]:
    src = CAVE / f"{stem}.x"
    o = CAVE / f"{stem}_{tag}.o"
    exe = CAVE / f"{stem}_{tag}.exe"
    err = CAVE / f"{stem}_{tag}.err"
    for p in (o, exe, err):
        if p.exists():
            try:
                p.unlink()
            except OSError:
                pass
    with err.open("wb") as ef:
        r1 = subprocess.run(
            [str(host), "-c", str(src.name), "-o", str(o.name)],
            cwd=str(CAVE),
            stdout=ef,
            stderr=subprocess.STDOUT,
            timeout=90,
        )
    osz = o.stat().st_size if o.exists() else 0
    with err.open("ab") as ef:
        r2 = subprocess.run(
            [str(host), str(src.name), "-o", str(exe.name)],
            cwd=str(CAVE),
            stdout=ef,
            stderr=subprocess.STDOUT,
            timeout=90,
        )
    run = "BUILD_FAIL"
    if exe.exists() and exe.stat().st_size > 0:
        rr = subprocess.run([str(exe)], cwd=str(CAVE), capture_output=True, timeout=15)
        run = str(rr.returncode & 0xFFFFFFFF)
    return tag, osz, run


def main() -> int:
    os.environ["PATH"] = (
        r"C:\w64devkit\bin;C:\mingw64\bin;" + os.environ.get("PATH", "")
    )
    OUT.mkdir(parents=True, exist_ok=True)
    for stem in STEMS:
        src = FIXSRC / f"{stem}.x"
        dst = CAVE / f"{stem}.x"
        dst.write_bytes(src.read_bytes())

    hosts = [
        (PROD, "PROD09fe_tipAlone"),
        (DIG09, "DIG09fe"),
        (DIG3F, "DIG3f6ad"),
        (BAK, "BAK74d0"),
    ]
    print(f"PROD tip-alone sha12={sha12(PROD)} size={PROD.stat().st_size}", flush=True)
    print(f"DIG09fe sha12={sha12(DIG09)} size={DIG09.stat().st_size}", flush=True)
    print(f"DIG3f6ad sha12={sha12(DIG3F)} size={DIG3F.stat().st_size}", flush=True)
    print(f"BAK74d0 sha12={sha12(BAK)} size={BAK.stat().st_size}", flush=True)
    print(f"TIPHEAD sha12={sha12(TIPHEAD)} size={TIPHEAD.stat().st_size}", flush=True)
    assert sha12(PROD) == "09fe181dbd0e"
    assert sha12(DIG09) == "09fe181dbd0e"
    assert sha12(DIG3F) == "3f6ad9910c48"
    assert sha12(BAK) == "74d0bd9c9fbf"
    assert sha12(TIPHEAD) == "9ecd26ea44ab"

    rows: list[str] = []
    for host, tag in hosts:
        print(f"==== {tag} ====", flush=True)
        for stem in STEMS:
            tag2, osz, run = prefer_one(host, tag, stem)
            line = f"{tag2}|{stem}|Prefer.o={osz}|run={run}"
            print(line, flush=True)
            rows.append(line)
    table = OUT / "tipalone_table.txt"
    table.write_text("\n".join(rows) + "\n", encoding="utf-8")
    print(f"TABLE_WRITTEN {table}", flush=True)

    # Acceptance: tip-alone PROD matches dig 09fe on call_arg/nested_let/softcap_lit
    def grab(tag: str, stem: str) -> tuple[int, str]:
        for r in rows:
            a, b, c, d = r.split("|")
            if a == tag and b == stem:
                return int(c.split("=")[1]), d.split("=")[1]
        raise KeyError((tag, stem))

    ok = True
    for stem, exp_o, exp_run in (
        ("softcap_lit", 463, "0"),
        ("call_arg", 553, "0"),
        ("nested_let", 387, "0"),
        ("n_no_assign", 379, "0"),
        ("call_arg_direct", 500, "0"),
    ):
        po, pr = grab("PROD09fe_tipAlone", stem)
        do, dr = grab("DIG09fe", stem)
        print(
            f"ALIGN {stem}: tipAlone Prefer.o={po} run={pr} dig Prefer.o={do} run={dr} expect.o={exp_o} expect.run={exp_run}",
            flush=True,
        )
        if not (po == do == exp_o and pr == dr == exp_run):
            ok = False
    # BAK should still lag call_arg/nested_let (control)
    bo, br = grab("BAK74d0", "call_arg")
    print(f"CONTROL BAK74d0 call_arg Prefer.o={bo} run={br} (expect run=1 lag)", flush=True)
    if ok:
        print("TIP_ALONE_ALIGN_DIG_OK", flush=True)
        return 0
    print("TIP_ALONE_ALIGN_DIG_FAIL", flush=True)
    return 1


if __name__ == "__main__":
    sys.exit(main())
