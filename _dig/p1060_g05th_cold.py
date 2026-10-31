"""softcap_g05_capsoft_win_tiphead: plant tip-HEAD Cap soft Win -> tip SoftCap; cold 4-gate.
Does NOT touch PROD Capless lab_SoftCap_76795 / nail."""
from pathlib import Path
import hashlib, subprocess, shutil, sys
CAVE=Path(r"C:\xlang_tmp\p1060\cave")
WORK=Path(r"C:\xlang_tmp\p1060\capsoft_win_rebuild")
TIP=Path(r"C:\Users\shuliangfu\worker\xlang\x-lang\compiler")
SRC=TIP/"xlang.exe"
SRCS=["p_ret_lit.x","p_ret_fwd.x","p_ret_local.x","_var_let.x"]
def sha12(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()[:12]
def tag(crc):
    return {0:"OK",0x80000003:"INT3",0xC0000409:"GS",0xC0000005:"AV"}.get(crc & 0xFFFFFFFF, hex(crc & 0xFFFFFFFF))

assert SRC.exists() and SRC.stat().st_size>0, f"missing tiphead {SRC}"
h=sha12(SRC)
print(f"TIPHEAD src={SRC} sha12={h} size={SRC.stat().st_size}", flush=True)
exp=Path(r"C:\xlang_tmp\g05_tiphead_sha12.txt")
if exp.exists() and exp.read_text(encoding="utf-8").strip():
    want=exp.read_text(encoding="utf-8").strip()
    assert h==want, f"tiphead sha {h} != g05_tiphead_sha12.txt {want}"
else:
    print(f"NOTE no g05_tiphead_sha12.txt pin; proceeding with {h}", flush=True)

for name in ("seeds","include"):
    src=TIP/name; dst=WORK/name
    if src.exists():
        if dst.exists():
            shutil.rmtree(dst)
        shutil.copytree(src, dst)
        print(f"synced {name} -> WORK", flush=True)

plants=[
    CAVE/"lab_CapSoftWin_tiphead.exe",
    CAVE/"lab_SoftCap_tip.exe",
    CAVE/"lab_tip_SoftCap_CapSoftWin.exe",
    WORK/"xlang_capsoft_win.exe",
    WORK/"xlang_side.exe",
]
for p in plants:
    shutil.copy2(SRC, p)
    print(f"planted {p.name} sha={sha12(p)} size={p.stat().st_size}", flush=True)

w1778=CAVE/"lab_CapSoftWin_w1778.exe"
prod=CAVE/"lab_SoftCap_76795.exe"
print(f"KEEP w1778 sha={sha12(w1778)} (expect 9c4746d5b5d7)", flush=True)
print(f"KEEP PROD  sha={sha12(prod)} (expect 7a2cf5da581a)", flush=True)
assert sha12(prod)=="7a2cf5da581a", "PROD Capless was mutated — abort"
assert sha12(w1778)=="9c4746d5b5d7", "w1778对照 mutated — abort"

host=CAVE/"lab_SoftCap_tip.exe"
ok=0
print("=== COLD tip SoftCap(=Cap soft tiphead) four-gate ===", flush=True)
for s in SRCS:
    out=CAVE/f"_g05th_cold_{Path(s).stem}.exe"
    if out.exists():
        try: out.unlink()
        except OSError: pass
    r=subprocess.run([str(host),"build",str(CAVE/s),"-o",str(out)],capture_output=True,timeout=60,cwd=str(WORK))
    crc=r.returncode & 0xFFFFFFFF
    err=((r.stderr or b"")+(r.stdout or b"")).decode("utf-8","replace")
    user="-"; run="-"
    if out.exists() and out.stat().st_size>0:
        user=sha12(out)
        rc=subprocess.run([str(out)],capture_output=True,timeout=5).returncode & 0xFFFFFFFF
        run=tag(rc) if rc>3 else str(rc)
    mark="OK" if tag(crc)=="OK" and run=="0" else "FAIL"
    if mark=="OK": ok+=1
    note=""
    if "CG002" in err: note="CG002"
    elif mark!="OK" and err.strip(): note=err.strip().splitlines()[-1][:80]
    print(f"  {s:16s} host={tag(crc):8s} USER={user} run={run:8s} {mark} {note}", flush=True)
print(f"  => {ok}/4 green", flush=True)

host2=CAVE/"lab_CapSoftWin_tiphead.exe"
ok2=0
print("=== COLD Cap soft tiphead direct four-gate ===", flush=True)
for s in SRCS:
    out=CAVE/f"_g05th_cs_{Path(s).stem}.exe"
    if out.exists():
        try: out.unlink()
        except OSError: pass
    r=subprocess.run([str(host2),"build",str(CAVE/s),"-o",str(out)],capture_output=True,timeout=60,cwd=str(WORK))
    crc=r.returncode & 0xFFFFFFFF
    user="-"; run="-"
    if out.exists() and out.stat().st_size>0:
        user=sha12(out)
        rc=subprocess.run([str(out)],capture_output=True,timeout=5).returncode & 0xFFFFFFFF
        run=tag(rc) if rc>3 else str(rc)
    mark="OK" if tag(crc)=="OK" and run=="0" else "FAIL"
    if mark=="OK": ok2+=1
    print(f"  {s:16s} host={tag(crc):8s} USER={user} run={run:8s} {mark}", flush=True)
print(f"  => {ok2}/4 green", flush=True)

print("=== PROD Capless still CG002? ===", flush=True)
r=subprocess.run([str(prod),str(CAVE/"p_ret_lit.x"),"-o",str(CAVE/"_g05th_prod.exe")],capture_output=True,timeout=20)
err=((r.stderr or b"")+(r.stdout or b"")).decode("utf-8","replace")
print(f"  prod sha={sha12(prod)} rc={r.returncode} CG002={'CG002' in err}", flush=True)

isol=CAVE/"host_967_s25.exe"
if isol.exists():
    r=subprocess.run([str(isol),str(CAVE/"p_ret_lit.x"),"-o",str(CAVE/"_g05th_isol.exe")],capture_output=True,timeout=20)
    outp=CAVE/"_g05th_isol.exe"
    user=sha12(outp) if outp.exists() and outp.stat().st_size>0 else "-"
    print(f"  isol sha={sha12(isol)} rc={r.returncode} USER={user}", flush=True)
else:
    print("  isol MISS", flush=True)

(CAVE/"_g05th_cold_summary.txt").write_text(
    f"tiphead={h}\ntip_softcap_ok={ok}/4\ncapsoft_ok={ok2}/4\nprod={sha12(prod)}\n", encoding="utf-8")
print("DONE", flush=True)
sys.exit(0 if ok==4 else 1)
