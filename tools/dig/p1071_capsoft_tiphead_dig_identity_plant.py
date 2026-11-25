"""10.71 Cap soft tiphead dig identity slot plant.

Copy existing 10.69 DIG3h dig PE a1491a74c08b into CapSoft tiphead dig P1071 slot.
Never write Soft Cap PROD / cave Soft Cap / tiphead Prefer-M2 9ecd.
"""
from __future__ import annotations

import hashlib
import shutil
import sys
from pathlib import Path

SRC = Path(
    r"C:\xlang_tmp\p1060\g05th_dig\lab_CapSoftWin_tiphead_P1069_dig3h_clamp18_a1491a74c08b.exe"
)
# also accept short alias
SRC_ALT = Path(r"C:\xlang_tmp\p1060\g05th_dig\lab_CapSoftWin_tiphead_P1069_dig3h_clamp18.exe")
DST = Path(
    r"C:\xlang_tmp\p1060\g05th_dig\lab_CapSoftWin_tiphead_P1071_dig_identity_a1491a74c08b.exe"
)
PROD = Path(r"C:\xlang_tmp\prod_softcap\lab_SoftCap_76795.exe")
CAVE_SC = Path(r"C:\xlang_tmp\p1060\cave\lab_SoftCap_76795.exe")
TIPHEAD = Path(r"C:\xlang_tmp\p1060\cave\lab_CapSoftWin_tiphead.exe")
EXPECTED_PROD = "74d0bd9c9fbf"
EXPECTED_TIP = "9ecd26ea44ab"
EXPECTED_DIG = "a1491a74c08b"


def sha12(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()[:12]


def main() -> int:
    prod_pre = sha12(PROD)
    cave_pre = sha12(CAVE_SC)
    tip_pre = sha12(TIPHEAD)
    print(f"PRE PROD={prod_pre} CAVE_SC={cave_pre} TIPHEAD={tip_pre}", flush=True)
    assert prod_pre == EXPECTED_PROD and cave_pre == EXPECTED_PROD
    assert tip_pre == EXPECTED_TIP

    src = SRC if SRC.exists() else SRC_ALT
    assert src.exists(), src
    src_h = sha12(src)
    assert src_h == EXPECTED_DIG, src_h
    assert src.stat().st_size <= 10_000_000

    shutil.copy2(src, DST)
    dst_h = sha12(DST)
    assert dst_h == EXPECTED_DIG, dst_h
    print(
        f"PLANTED slot={DST} sha12={dst_h} size={DST.stat().st_size} from={src}",
        flush=True,
    )

    prod_post = sha12(PROD)
    cave_post = sha12(CAVE_SC)
    tip_post = sha12(TIPHEAD)
    print(f"POST PROD={prod_post} CAVE_SC={cave_post} TIPHEAD={tip_post}", flush=True)
    assert prod_post == EXPECTED_PROD and cave_post == EXPECTED_PROD
    assert tip_post == EXPECTED_TIP
    print("HOLD Soft Cap 74d0 / tiphead Prefer-M2 9ecd UNTOUCHED", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
