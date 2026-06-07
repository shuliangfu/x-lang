#!/usr/bin/env bash
# P3 编译器自优化 dogfood：固定模块 `-o` / `check` 编译耗时中位数，对比基线防回退。
# 用法：
#   ./tests/run-perf-compile-dogfood.sh
#   SHU=./compiler/shu_asm ./tests/run-perf-compile-dogfood.sh
#   SHU_PERF_FAIL_ON_COMPILE_REGRESSION=1 ./tests/run-perf-compile-dogfood.sh
#   SHU_PERF_UPDATE_BASELINE=1 ./tests/run-perf-compile-dogfood.sh   # 刷新 tests/baseline/compile-dogfood.tsv
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler

SHU="${SHU:-./compiler/shu}"
# CI make all 产出 C-only shu；dogfood 编译耗时统一用 shu-c，与 run-perf-io/run-perf-baseline 一致。
PERF_COMPILE_SHU="$SHU"
if [ -x ./compiler/shu-c ]; then
  PERF_COMPILE_SHU=./compiler/shu-c
fi
SHU="$PERF_COMPILE_SHU"
RUNS="${SHU_PERF_COMPILE_RUNS:-3}"
BASELINE="${SHU_PERF_COMPILE_BASELINE:-tests/baseline/compile-dogfood.tsv}"
FAIL_REGRESS=0
UPDATE_BASELINE=0
[ "${SHU_PERF_FAIL_ON_COMPILE_REGRESSION:-0}" = "1" ] && FAIL_REGRESS=1
[ "${SHU_PERF_UPDATE_BASELINE:-0}" = "1" ] && UPDATE_BASELINE=1

ROOT=$(pwd)
case "$SHU" in
  /*) SHU_EXE="$SHU" ;;
  *) SHU_EXE="$ROOT/$SHU" ;;
esac
if [ ! -x "$SHU_EXE" ]; then
  echo "run-perf-compile-dogfood: missing executable: $SHU_EXE" >&2
  exit 1
fi

echo "=== compile dogfood (SHU=$SHU RUNS=$RUNS) ==="

export SHU_EXE RUNS BASELINE FAIL_REGRESS UPDATE_BASELINE ROOT
python3 <<'PY'
import os, statistics, subprocess, sys, time

shu = os.environ["SHU_EXE"]
runs = int(os.environ["RUNS"])
baseline_path = os.environ["BASELINE"]
fail_regress = os.environ["FAIL_REGRESS"] == "1"
update_baseline = os.environ["UPDATE_BASELINE"] == "1"
root = os.environ["ROOT"]

# 固定用例：P0 bench 的 -o 编译 + 编译器重模块 check（frontend dogfood）
cases = [
    ("loop_i32", f'"{shu}" tests/bench/loop_i32.su -o /tmp/shu_dog_loop_i32'),
    ("mem_copy", f'"{shu}" tests/bench/mem_copy.su -o /tmp/shu_dog_mem_copy'),
    ("struct_param", f'"{shu}" tests/bench/struct_param.su -o /tmp/shu_dog_struct_param'),
    ("call_boundary", f'"{shu}" tests/bench/call_boundary.su -o /tmp/shu_dog_call_boundary'),
    ("perf_main", f'"{shu}" tests/perf-baseline/main.su -o /tmp/shu_dog_perf_main'),
    ("check_backend", f'"{shu}" check compiler/src/asm/backend.su'),
    ("check_parser", f'"{shu}" check compiler/src/parser/parser.su'),
]

def load_baseline(path):
    out = {}
    if not os.path.isfile(path):
        return out
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            parts = line.split("\t")
            if len(parts) >= 2:
                out[parts[0]] = float(parts[1])
    return out

def median_time(cmd, n):
    times = []
    for _ in range(n):
        t0 = time.perf_counter()
        r = subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, cwd=root)
        dt = time.perf_counter() - t0
        if r.returncode != 0:
            return None, f"exit {r.returncode}"
        times.append(dt)
    return statistics.median(times), times

baseline = load_baseline(baseline_path)
failures = 0
rows = []

print(f"| case | median (s) | baseline (s) |")
print(f"|---|---:|---:|")

for name, cmd in cases:
    med, detail = median_time(cmd, runs)
    if med is None:
        print(f"run-perf-compile-dogfood: FAIL {name}: {detail}", file=sys.stderr)
        sys.exit(1)
    cap = baseline.get(name)
    eff_cap = cap
    if cap is not None and os.environ.get("CI") == "1":
        eff_cap = cap * 1.4
    status = "OK"
    if eff_cap is not None and med > eff_cap:
        status = "SLOW"
        if fail_regress:
            failures += 1
    rows.append((name, med, cap, status))
    cap_s = f"{cap:.4f}" if cap is not None else "—"
    print(f"| {name} | {med:.4f} | {cap_s} | {status} |")

if update_baseline:
    os.makedirs(os.path.dirname(baseline_path) or ".", exist_ok=True)
    with open(baseline_path, "w", encoding="utf-8") as f:
        f.write("# shu 固定模块 compile/check 中位数上限（秒）；门禁：实测 median ≤ 本列值\n")
        f.write("# 更新：SHU_PERF_UPDATE_BASELINE=1 ./tests/run-perf-compile-dogfood.sh\n")
        for name, med, _, _ in rows:
            # 留 ~50% 余量，降低 CI/本机抖动误报
            ceiling = max(med * 1.5, med + 0.015)
            f.write(f"{name}\t{ceiling:.4f}\n")
    print(f"updated baseline: {baseline_path}")

if failures:
    print(f"compile dogfood FAIL: {failures} case(s) over baseline", file=sys.stderr)
    sys.exit(1)

print("=== compile dogfood OK ===")
PY
