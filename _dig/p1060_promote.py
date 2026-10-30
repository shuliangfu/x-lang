"""softcap_tip_capsoft_win_promote: wire tip SoftCap identity to Cap soft Win.
Ban: PE Isol as close / LIVE transplant / PROD·pin bump.
PROD lab_SoftCap_76795.exe stays untouched.
"""
from pathlib import Path
import hashlib, subprocess, shutil, time

CAVE = Path(r"C:\xlang_tmp\p1060\cave")
WORK = Path(r"C:\xlang_tmp\p1060\capsoft_win_rebuild")
SRCS = ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x", "_var_let.x"]
PYBIN = r"C:\Users\shuliangfu\AppData\Local\Programs\Python\Python312\python.exe"

def sha12(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()[:12]

def tag(crc):
    return {0:"OK",0x80000003:"INT3",0xC0000409:"GS",0xC0000005:"AV"}.get(crc & 0xFFFFFFFF, hex(crc & 0xFFFFFFFF))

t0 = time.time()
cap = CAVE / "lab_CapSoftWin_w1778.exe"
prod = CAVE / "lab_SoftCap_76795.exe"
isol = CAVE / "host_967_s25.exe"
tip = CAVE / "lab_SoftCap_tip.exe"          # tip SoftCap identity (Cap soft Win)
tip_alias = CAVE / "lab_tip_SoftCap_CapSoftWin.exe"

assert cap.exists(), "missing Cap soft Win host"
assert prod.exists(), "missing PROD SoftCap"
cap_sha = sha12(cap)
prod_sha_before = sha12(prod)
print(f"CapSoftWin sha={cap_sha} size={cap.stat().st_size}", flush=True)
print(f"PROD before sha={prod_sha_before} size={prod.stat().st_size}", flush=True)
print(f"WORK seeds={(WORK/'seeds').exists()} include={(WORK/'include').exists()}", flush=True)

# Plant: tip SoftCap identity = Cap soft Win (copy, do NOT overwrite PROD)
shutil.copy2(cap, tip)
shutil.copy2(cap, tip_alias)
# keep WORK canonical host in sync
shutil.copy2(cap, WORK / "xlang_capsoft_win.exe")
print(f"tip SoftCap identity planted: {tip.name} sha={sha12(tip)}", flush=True)
print(f"alias planted: {tip_alias.name} sha={sha12(tip_alias)}", flush=True)

def gate_build(host, label, prefix, cwd=None):
    print(f"\n=== GATE {label} sha={sha12(host)} ===", flush=True)
    ok = 0
    rows = []
    for s in SRCS:
        out = CAVE / f"{prefix}_{Path(s).stem}.exe"
        if out.exists():
            try: out.unlink()
            except OSError: pass
        cmd = [str(host), "build", str(CAVE / s), "-o", str(out)]
        r = subprocess.run(cmd, capture_output=True, timeout=40, cwd=str(cwd) if cwd else None)
        crc = r.returncode & 0xFFFFFFFF
        err = ((r.stderr or b"") + (r.stdout or b"")).decode("utf-8", "replace")
        user = "-"; run = "-"
        if out.exists() and out.stat().st_size > 0:
            user = sha12(out)
            rc = subprocess.run([str(out)], capture_output=True, timeout=3).returncode & 0xFFFFFFFF
            run = tag(rc) if rc > 3 else str(rc)
        note = "CG002" if "CG002" in err else ""
        mark = "OK" if tag(crc)=="OK" and run=="0" else "FAIL"
        if mark=="OK": ok += 1
        print(f"  {s:16s} host={tag(crc):8s} USER={user} run={run:8s} {mark} {note}", flush=True)
        rows.append((s, tag(crc), user, run, mark, note))
    print(f"  => {ok}/4 green", flush=True)
    return ok, rows

def gate_bare(host, label, prefix):
    print(f"\n=== GATE_BARE {label} sha={sha12(host)} ===", flush=True)
    ok = 0
    for s in SRCS:
        out = CAVE / f"{prefix}_{Path(s).stem}.exe"
        if out.exists():
            try: out.unlink()
            except OSError: pass
        r = subprocess.run([str(host), str(CAVE / s), "-o", str(out)], capture_output=True, timeout=20)
        crc = r.returncode & 0xFFFFFFFF
        err = ((r.stderr or b"") + (r.stdout or b"")).decode("utf-8", "replace")
        user = "-"; run = "-"
        if out.exists() and out.stat().st_size > 0:
            user = sha12(out)
            rc = subprocess.run([str(out)], capture_output=True, timeout=3).returncode & 0xFFFFFFFF
            run = tag(rc) if rc > 3 else str(rc)
        note = "CG002" if "CG002" in err else ""
        mark = "OK" if tag(crc)=="OK" and run=="0" else "FAIL"
        if mark=="OK": ok += 1
        print(f"  {s:16s} host={tag(crc):8s} USER={user} run={run:8s} {mark} {note}", flush=True)
    print(f"  => {ok}/4 green", flush=True)
    return ok

# 1) tip SoftCap (= Cap soft Win) four-gate via Cap soft CLI + WORK seeds/include
ok_tip, tip_rows = gate_build(tip, "tipSoftCap=CapSoftWin", "_prom_tip", cwd=WORK)

# 2) PROD SoftCap still untouched + still CG002 (bare SoftCap CLI)
prod_sha_after = sha12(prod)
print(f"\nPROD after sha={prod_sha_after} unchanged={prod_sha_after==prod_sha_before}", flush=True)
ok_prod = gate_bare(prod, "PROD SoftCap Capless (must stay CG002 / untouched)", "_prom_prod")

# 3) Isol 对照 still green (bare)
ok_isol = gate_bare(isol, "Isol_s25_control", "_prom_isol")

# 4) Cap soft Win direct reconfirm
ok_cap = gate_build(cap, "CapSoftWin_direct", "_prom_cap", cwd=WORK)

print("\n=== SUMMARY ===", flush=True)
print(f"tip SoftCap(=Cap soft Win) {ok_tip}/4  sha={sha12(tip)}", flush=True)
print(f"PROD SoftCap Capless       {ok_prod}/4  sha={prod_sha_after} (untouched={prod_sha_after==prod_sha_before})", flush=True)
print(f"Isol control               {ok_isol}/4  sha={sha12(isol)}", flush=True)
print(f"CapSoftWin direct          {ok_cap}/4  sha={sha12(cap)}", flush=True)
print(f"elapsed={time.time()-t0:.1f}s DONE", flush=True)
