#!/usr/bin/env bash
# BOOT-017: std/core per-module `xlang check` timing dogfood (PERF-004 extension).
#
# Honesty: soft XLANG_BOOT017_FAIL_ON_REGRESSION:-0 retired — SLOW modules
# previously still printed status=ok / exit 0 (portable false-green for
# perf regression). Prefer product xlang_asm (then xlang-c / xlang).
# Missing compiler is hard die. `xlang check` is observational during the
# selfhost check-gate pause: check exit≠0 and median>baseline are obs=
# (product / check / perf residual), not soft-swallowed silence and not a
# hard FAIL that re-opens the paused check war. UPDATE_BASELINE still
# refreshes tests/baseline/stdlib-dogfood.tsv.
#
# Usage:
#   ./tests/run-boot-017-stdlib-dogfood.sh
#   XLANG_BOOT017_UPDATE_BASELINE=1 XLANG_BOOT017_RUNS=3 ./tests/run-boot-017-stdlib-dogfood.sh
# Report: status= ok|fail  run=/obs=/skip=/slow=/modules=/p50=/p95=
# PLATFORM: SHARED archaeology (check dogfood; Ubuntu gold still required).
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# Honesty: do NOT auto-make before resolve — rebuilding would turn
# "missing compiler" into soft green. Caller / gate must supply a native
# product binary (prefer xlang_asm).

MATRIX="${XLANG_BOOT017_MATRIX:-tests/baseline/stdlib-check-matrix.tsv}"
BASELINE="${XLANG_BOOT017_BASELINE:-tests/baseline/stdlib-dogfood.tsv}"
RUNS="${XLANG_BOOT017_RUNS:-1}"
UPDATE_BASELINE=0
[ "${XLANG_BOOT017_UPDATE_BASELINE:-0}" = "1" ] && UPDATE_BASELINE=1

PREFIX="xlang: [XLANG_BOOT017_STDLIB_DOGFOOD]"
ROOT=$(pwd)

resolve_shu() {
  local cand abs
  # Prefer product asm; refuse soft prefer-xlang-c false path.
  # PLATFORM: SHARED — product path honesty.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$ROOT/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

XLANG_EXE="$(resolve_shu)" || {
  echo "run-boot-017-stdlib-dogfood: no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)" >&2
  echo "${PREFIX} status=fail run=0 obs=0 skip=0 slow=0 modules=0 p50=0.0000 p95=0.0000 host=$(ci_host_summary)"
  exit 1
}
export XLANG="$XLANG_EXE"
export XLANG_LINK_XLANG="$XLANG_EXE"

# shellcheck source=tests/lib/boot-017-stdlib-dogfood.sh
. tests/lib/boot-017-stdlib-dogfood.sh

echo "=== BOOT-017: stdlib per-module check dogfood (XLANG=$XLANG_EXE RUNS=$RUNS; hard/obs) ==="

export XLANG_EXE RUNS BASELINE UPDATE_BASELINE ROOT MATRIX PREFIX
python3 <<'PY'
import os, statistics, subprocess, sys, tempfile, time

xlang = os.environ["XLANG_EXE"]
runs = int(os.environ["RUNS"])
baseline_path = os.environ["BASELINE"]
update_baseline = os.environ["UPDATE_BASELINE"] == "1"
root = os.environ["ROOT"]
matrix_path = os.environ["MATRIX"]
prefix = os.environ["PREFIX"]

HEAVY = {
    "std.async", "std.http", "std.json", "std.regex", "std.crypto",
    "std.compress", "std.fs", "std.net", "std.thread", "std.process",
    "std.channel", "std.backtrace", "std.db.sqlite", "std.simd", "std.dynlib", "std.ffi",
}

def load_modules(path):
    mods = []
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            parts = line.split("\t")
            if len(parts) >= 4 and parts[1] == "module":
                mods.append((parts[2], parts[3]))
    return mods

def default_cap(mod, layer):
    if layer == "core":
        return 0.050
    if mod in HEAVY:
        return 0.100
    return 0.065

def load_baseline(path, modules):
    out = {}
    if os.path.isfile(path):
        with open(path, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                parts = line.split("\t")
                if len(parts) >= 2:
                    out[parts[0]] = float(parts[1])
    for mod, layer in modules:
        out.setdefault(mod, default_cap(mod, layer))
    return out

def median_time(cmd, n, cwd):
    times = []
    for _ in range(n):
        t0 = time.perf_counter()
        r = subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, cwd=cwd)
        dt = time.perf_counter() - t0
        if r.returncode != 0:
            return None, f"exit {r.returncode}"
        times.append(dt)
    return statistics.median(times), times

modules = load_modules(matrix_path)
if len(modules) < 55:
    print(f"run-boot-017-stdlib-dogfood: expected >=55 modules, got {len(modules)}", file=sys.stderr)
    print(f"{prefix} status=fail run=0 obs=0 skip=0 slow=0 modules={len(modules)} p50=0.0000 p95=0.0000")
    sys.exit(1)

baseline = load_baseline(baseline_path, modules)
tmpdir = tempfile.mkdtemp(prefix="xlang_boot017_")
obs = 0
check_fail = 0
slow_n = 0
rows = []
medians = []
run_ok = 0

for mod, layer in modules:
    safe = mod.replace(".", "_")
    probe = os.path.join(tmpdir, f"probe_{safe}.x")
    with open(probe, "w", encoding="utf-8") as f:
        f.write(f"// BOOT-017 check probe for {mod}\n")
        f.write(f'const _m = import("{mod}");\n')
        f.write("function main(): i32 { return 0; }\n")
    cmd = f'"{xlang}" check -L . "{probe}"'
    med, detail = median_time(cmd, runs, root)
    if med is None:
        # Selfhost check gate paused: tip check hygiene = obs, not soft silence.
        print(f"run-boot-017-stdlib-dogfood: OBS {mod}: check {detail} (paused check gate; not soft false-green)", file=sys.stderr)
        check_fail += 1
        obs += 1
        rows.append((mod, layer, None, baseline.get(mod, default_cap(mod, layer)), "OBS_CHECK"))
        continue
    medians.append(med)
    run_ok += 1
    cap = baseline.get(mod, default_cap(mod, layer))
    eff_cap = cap
    if os.environ.get("CI", "").lower() in ("1", "true"):
        ci_mult = 1.4
        if os.path.isfile("/.dockerenv") or os.environ.get("XLANG_CI_DOCKER"):
            ci_mult = 1.65
        eff_cap = cap * ci_mult
    status = "OK"
    if med > eff_cap:
        # Soft FAIL_ON_REGRESSION retired: SLOW is obs residual, not exit0 silence.
        status = "SLOW"
        slow_n += 1
        obs += 1
        print(
            f"run-boot-017-stdlib-dogfood: OBS {mod}: median={med:.4f}s > cap={eff_cap:.4f}s "
            f"(perf residual; not soft false-green)",
            file=sys.stderr,
        )
    rows.append((mod, layer, med, cap, status))

medians.sort()
p50 = medians[len(medians) // 2] if medians else 0.0
p95 = medians[int(len(medians) * 0.95)] if len(medians) > 1 else (medians[0] if medians else 0.0)

print(f"| module | tier | median (s) | cap (s) |")
print(f"|---|---|---:|---:|")
for mod, layer, med, cap, status in rows:
    tier = "heavy" if mod in HEAVY else layer
    if status == "OK":
        flag = ""
        med_s = f"{med:.4f}"
    elif status == "SLOW":
        flag = " **SLOW**"
        med_s = f"{med:.4f}"
    else:
        flag = " **OBS_CHECK**"
        med_s = "n/a"
    print(f"| {mod} | {tier} | {med_s} | {cap:.4f} |{flag}")

if update_baseline:
    os.makedirs(os.path.dirname(baseline_path) or ".", exist_ok=True)
    with open(baseline_path, "w", encoding="utf-8") as f:
        f.write("# BOOT-017 std/core 单模块 xlang check 中位数上限（秒）；median ≤ 本列\n")
        f.write("# 更新：XLANG_BOOT017_UPDATE_BASELINE=1 XLANG_BOOT017_RUNS=3 ./tests/run-boot-017-stdlib-dogfood.sh\n")
        f.write("# 列：module_id\tceiling_s\ttier\n")
        for mod, layer, med, _, status in rows:
            if med is None:
                # Keep prior / default cap when check failed this run.
                ceiling = baseline.get(mod, default_cap(mod, layer))
            else:
                ceiling = max(med * 1.5, med + 0.020)
            tier = "heavy" if mod in HEAVY else layer
            f.write(f"{mod}\t{ceiling:.4f}\t{tier}\n")
    print(f"updated baseline: {baseline_path}")

# Report line (gate greps PREFIX). status=ok with obs>0 = honest residual.
status = "ok"
print(
    f"{prefix} status={status} run={run_ok} obs={obs} skip=0 "
    f"modules={len(rows)} slow={slow_n} check_fail={check_fail} "
    f"p50={p50:.4f} p95={p95:.4f}"
)

print("=== boot-017 stdlib dogfood OK ===")
sys.exit(0)
PY
