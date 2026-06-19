#!/usr/bin/env bash
# PERF-004 / P3 编译器自优化 dogfood：固定模块 `-o` / `check` 编译耗时中位数，对比基线防回退。
# 用法：
#   ./tests/run-perf-compile-dogfood.sh
#   ./tests/run-perf-compile-dogfood-gate.sh          # PERF-004 门禁（manifest + 回归）
#   SHUX=./compiler/shux_asm ./tests/run-perf-compile-dogfood.sh
#   SHUX_PERF_FAIL_ON_COMPILE_REGRESSION=1 ./tests/run-perf-compile-dogfood.sh
#   SHUX_PERF_UPDATE_BASELINE=1 ./tests/run-perf-compile-dogfood.sh   # 刷新 tests/baseline/compile-dogfood.tsv
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler

SHUX="${SHUX:-./compiler/shux}"
# CI make all 产出 C-only shux；dogfood 编译耗时统一用 shux-c，与 run-perf-io/run-perf-baseline 一致。
PERF_COMPILE_SHUX="$SHUX"
if [ -x ./compiler/shux-c ]; then
  PERF_COMPILE_SHUX=./compiler/shux-c
fi
SHUX="$PERF_COMPILE_SHUX"
RUNS="${SHUX_PERF_COMPILE_RUNS:-3}"
BASELINE="${SHUX_PERF_COMPILE_BASELINE:-tests/baseline/compile-dogfood.tsv}"
FAIL_REGRESS=0
UPDATE_BASELINE=0
[ "${SHUX_PERF_FAIL_ON_COMPILE_REGRESSION:-0}" = "1" ] && FAIL_REGRESS=1
[ "${SHUX_PERF_UPDATE_BASELINE:-0}" = "1" ] && UPDATE_BASELINE=1

ROOT=$(pwd)
case "$SHUX" in
  /*) SHUX_EXE="$SHUX" ;;
  *) SHUX_EXE="$ROOT/$SHUX" ;;
esac
if [ ! -x "$SHUX_EXE" ]; then
  echo "run-perf-compile-dogfood: missing executable: $SHUX_EXE" >&2
  exit 1
fi

echo "=== compile dogfood (SHUX=$SHUX RUNS=$RUNS) ==="

export SHUX_EXE RUNS BASELINE FAIL_REGRESS UPDATE_BASELINE ROOT
python3 <<'PY'
import os, statistics, subprocess, sys, time

shux = os.environ["SHUX_EXE"]
runs = int(os.environ["RUNS"])
baseline_path = os.environ["BASELINE"]
fail_regress = os.environ["FAIL_REGRESS"] == "1"
update_baseline = os.environ["UPDATE_BASELINE"] == "1"
root = os.environ["ROOT"]

# 固定用例：P0 bench 的 -o 编译 + 编译器重模块 check（frontend dogfood）
cases = [
    ("loop_i32", f'"{shux}" tests/bench/loop_i32.sx -o /tmp/shux_dog_loop_i32'),
    ("mem_copy", f'"{shux}" tests/bench/mem_copy.sx -o /tmp/shux_dog_mem_copy'),
    ("struct_param", f'"{shux}" tests/bench/struct_param.sx -o /tmp/shux_dog_struct_param'),
    ("call_boundary", f'"{shux}" tests/bench/call_boundary.sx -o /tmp/shux_dog_call_boundary'),
    ("perf_main", f'"{shux}" tests/perf-baseline/main.sx -o /tmp/shux_dog_perf_main'),
    ("check_backend", f'"{shux}" check compiler/src/asm/backend.sx'),
    ("check_parser", f'"{shux}" check compiler/src/parser/parser.sx'),
    ("check_typeck", f'"{shux}" check compiler/src/typeck/typeck.sx'),
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
    if cap is not None and os.environ.get("CI", "").lower() in ("1", "true"):
        ci_mult = 1.4
        # Alpine/musl Docker：check_backend 等比 glibc 慢 ~1.45×，单独放宽。
        if os.path.isfile("/.dockerenv") or os.environ.get("SHUX_CI_DOCKER"):
            ci_mult = 1.65
        eff_cap = cap * ci_mult
    status = "OK"
    if eff_cap is not None and med > eff_cap:
        status = "SLOW"
        if fail_regress:
            # OBS-004：回归越界 stderr 告警（机器可 grep）
            print(
                f"shux: [SHUX_PERF_ALERT] severity=critical baseline_id=compile-dogfood "
                f"metric={name} measured={med:.4f} cap={eff_cap:.4f} "
                f"gate=run-perf-compile-dogfood-gate.sh",
                file=sys.stderr,
            )
            failures += 1
    rows.append((name, med, cap, status))
    cap_s = f"{cap:.4f}" if cap is not None else "—"
    print(f"| {name} | {med:.4f} | {cap_s} | {status} |")

if update_baseline:
    os.makedirs(os.path.dirname(baseline_path) or ".", exist_ok=True)
    with open(baseline_path, "w", encoding="utf-8") as f:
        f.write("# shux 固定模块 compile/check 中位数上限（秒）；门禁：实测 median ≤ 本列值\n")
        f.write("# 更新：SHUX_PERF_UPDATE_BASELINE=1 ./tests/run-perf-compile-dogfood.sh\n")
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
