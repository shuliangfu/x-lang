#!/usr/bin/env python3
"""Cold gate only for Isol host_967_s25 / xlang_isol1060_967_s25.
Does NOT rebuild. Asserts host sha12 e53841ce0e24 then lit/fwd/local/let run=0.
PROD SoftCap / pin untouched. Gate green != PROD bump.
"""
from pathlib import Path
import hashlib, subprocess, sys, time

CAVE = Path("C:/xlang_tmp/p1060/cave")
CANDS = [CAVE / "host_967_s25.exe", CAVE / "xlang_isol1060_967_s25.exe"]
HOST_SHA12 = "e53841ce0e24"
SRCS = ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x", "_var_let.x"]
EXPECT_USER = {
    "p_ret_lit.x": "5c6778769c3c",
    "p_ret_fwd.x": "a99121ae7a80",
    "p_ret_local.x": "36d26fcc9657",
    "_var_let.x": "d16c78ade1f2",
}
PREFIX = "_coldonly_s25"


def P(*a):
    print(*a, flush=True)


def tag_of(crc):
    return {
        0: "OK",
        0x80000003: "INT3",
        0xC0000409: "GS",
        0xC0000005: "AV",
    }.get(crc & 0xFFFFFFFF, hex(crc & 0xFFFFFFFF))


def main():
    t0 = time.time()
    host = next((p for p in CANDS if p.exists()), None)
    if host is None:
        P("missing host_967_s25 / alias — run build_isol_967_s25.py first")
        return 2
    hsha = hashlib.sha256(host.read_bytes()).hexdigest()[:12]
    P(f"HOST {host.name} sha={hsha} (expect {HOST_SHA12})")
    if hsha != HOST_SHA12:
        P("FAIL: host sha mismatch")
        return 1
    ok = True
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
            ok = False
        P(f"  {s:16s} host={tag_of(crc):8s} USER={user} (exp {expect}) run={rt:8s} {mark}")
    P(f"\n=== cold-only elapsed={time.time()-t0:.1f}s {'GREEN' if ok else 'RED'} ===")
    P("PROD SoftCap / pin: untouched")
    return 0 if ok else 1


if __name__ == "__main__":
    try:
        sys.exit(main())
    except subprocess.TimeoutExpired as e:
        P(f"TIMEOUT: {e}")
        sys.exit(3)
