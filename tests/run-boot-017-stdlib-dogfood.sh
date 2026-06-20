#!/usr/bin/env bash
# BOOT-017：std/core 全模块 shux check 分模块耗时 dogfood（PERF-004 扩展）
#
# 用法：
#   ./tests/run-boot-017-stdlib-dogfood.sh
#   SHUX_BOOT017_UPDATE_BASELINE=1 SHUX_BOOT017_RUNS=3 ./tests/run-boot-017-stdlib-dogfood.sh
#   SHUX_BOOT017_FAIL_ON_REGRESSION=1 ./tests/run-boot-017-stdlib-dogfood.sh
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler

MATRIX="${SHUX_BOOT017_MATRIX:-tests/baseline/stdlib-check-matrix.tsv}"
BASELINE="${SHUX_BOOT017_BASELINE:-tests/baseline/stdlib-dogfood.tsv}"
RUNS="${SHUX_BOOT017_RUNS:-1}"
FAIL_REGRESS=0
UPDATE_BASELINE=0
[ "${SHUX_BOOT017_FAIL_ON_REGRESSION:-0}" = "1" ] && FAIL_REGRESS=1
[ "${SHUX_BOOT017_UPDATE_BASELINE:-0}" = "1" ] && UPDATE_BASELINE=1

SHUX="${SHUX:-./compiler/shux}"
if [ -x ./compiler/shux-c ]; then
  SHUX=./compiler/shux-c
fi
ROOT=$(pwd)
case "$SHUX" in
  /*) SHUX_EXE="$SHUX" ;;
  *) SHUX_EXE="$ROOT/$SHUX" ;;
esac
if [ ! -x "$SHUX_EXE" ]; then
  echo "run-boot-017-stdlib-dogfood: missing executable: $SHUX_EXE" >&2
  exit 1
fi

# shellcheck source=tests/lib/boot-017-stdlib-dogfood.sh
. tests/lib/boot-017-stdlib-dogfood.sh

echo "=== BOOT-017: stdlib per-module check dogfood (SHUX=$SHUX RUNS=$RUNS) ==="

export SHUX_EXE RUNS BASELINE FAIL_REGRESS UPDATE_BASELINE ROOT MATRIX
python3 <<'PY'
import os, statistics, subprocess, sys, tempfile, time

shux = os.environ["SHUX_EXE"]
runs = int(os.environ["RUNS"])
baseline_path = os.environ["BASELINE"]
fail_regress = os.environ["FAIL_REGRESS"] == "1"
update_baseline = os.environ["UPDATE_BASELINE"] == "1"
root = os.environ["ROOT"]
matrix_path = os.environ["MATRIX"]

HEAVY = {
    "std.async", "std.http", "std.json", "std.regex", "std.crypto",
    "std.compress", "std.fs", "std.net", "std.thread", "std.process",
    "std.channel", "std.backtrace", "std.sqlite", "std.simd", "std.dynlib", "std.ffi",
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
    sys.exit(1)

baseline = load_baseline(baseline_path, modules)
tmpdir = tempfile.mkdtemp(prefix="shu_boot017_")
failures = 0
check_fail = 0
rows = []
medians = []

for mod, layer in modules:
    safe = mod.replace(".", "_")
    probe = os.path.join(tmpdir, f"probe_{safe}.sx")
    with open(probe, "w", encoding="utf-8") as f:
        f.write(f"// BOOT-017 check probe for {mod}\n")
        f.write(f'const _m = import("{mod}");\n')
        f.write("function main(): i32 { return 0; }\n")
    cmd = f'"{shux}" check -L . "{probe}"'
    med, detail = median_time(cmd, runs, root)
    if med is None:
        print(f"run-boot-017-stdlib-dogfood: FAIL {mod}: {detail}", file=sys.stderr)
        check_fail += 1
        continue
    medians.append(med)
    cap = baseline.get(mod, default_cap(mod, layer))
    eff_cap = cap
    if os.environ.get("CI", "").lower() in ("1", "true"):
        ci_mult = 1.4
        if os.path.isfile("/.dockerenv") or os.environ.get("SHUX_CI_DOCKER"):
            ci_mult = 1.65
        eff_cap = cap * ci_mult
    status = "OK"
    if med > eff_cap:
        status = "SLOW"
        if fail_regress:
            failures += 1
    rows.append((mod, layer, med, cap, status))

medians.sort()
p50 = medians[len(medians) // 2] if medians else 0.0
p95 = medians[int(len(medians) * 0.95)] if len(medians) > 1 else (medians[0] if medians else 0.0)
slow_n = sum(1 for r in rows if r[4] == "SLOW")

print(f"| module | tier | median (s) | cap (s) |")
print(f"|---|---|---:|---:|")
for mod, layer, med, cap, status in rows:
    tier = "heavy" if mod in HEAVY else layer
    flag = "" if status == "OK" else " **SLOW**"
    print(f"| {mod} | {tier} | {med:.4f} | {cap:.4f} |{flag}")

if update_baseline:
    os.makedirs(os.path.dirname(baseline_path) or ".", exist_ok=True)
    with open(baseline_path, "w", encoding="utf-8") as f:
        f.write("# BOOT-017 std/core 单模块 shux check 中位数上限（秒）；median ≤ 本列\n")
        f.write("# 更新：SHUX_BOOT017_UPDATE_BASELINE=1 SHUX_BOOT017_RUNS=3 ./tests/run-boot-017-stdlib-dogfood.sh\n")
        f.write("# 列：module_id\tceiling_s\ttier\n")
        for mod, layer, med, _, _ in rows:
            tier = "heavy" if mod in HEAVY else layer
            ceiling = max(med * 1.5, med + 0.020)
            f.write(f"{mod}\t{ceiling:.4f}\t{tier}\n")
    print(f"updated baseline: {baseline_path}")

# 报告行（gate grep）
print(
    f"shux: [SHUX_BOOT017_STDLIB_DOGFOOD] status="
    f"{'fail' if check_fail or failures else 'ok'} "
    f"modules={len(rows)} slow={slow_n} p50={p50:.4f} p95={p95:.4f} skip=0"
)

if check_fail:
    print(f"compile dogfood FAIL: {check_fail} module(s) check failed", file=sys.stderr)
    sys.exit(1)
if failures:
    print(f"stdlib dogfood FAIL: {failures} module(s) over baseline", file=sys.stderr)
    sys.exit(1)

print("=== boot-017 stdlib dogfood OK ===")
PY
