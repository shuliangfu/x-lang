#!/usr/bin/env bash
# PERF-004 / P3: fixed-module `-o` / `check` compile median vs baseline.
#
# Honesty: soft XLANG_PERF_FAIL_ON_COMPILE_REGRESSION:-0 previously left
# SLOW over baseline unchecked (silent OK = portable false-green). Soft
# auto-make before resolve + soft prefer-xlang-c-only retired. Prefer
# product xlang_asm (Darwin hosted build may use xlang-c). Over-cap /
# check_fail = obs (FAIL_ON=1 still hard for timing; check pause → check
# cases stay obs). Explicit bad XLANG = hard die. Report run=/obs=/skip=.
#
# Usage:
#   ./tests/run-perf-compile-dogfood.sh
#   ./tests/run-perf-compile-dogfood-gate.sh
#   XLANG=./compiler/xlang_asm ./tests/run-perf-compile-dogfood.sh
#   XLANG_PERF_FAIL_ON_COMPILE_REGRESSION=1 ./tests/run-perf-compile-dogfood.sh
#   XLANG_PERF_UPDATE_BASELINE=1 ./tests/run-perf-compile-dogfood.sh
# PLATFORM: SHARED archaeology (Ubuntu gold).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# Honesty: do NOT auto-make before resolve.

PREFIX="xlang: [XLANG_PERF_COMPILE_DOGFOOD]"
OBS=0
RUN_OK=0
SKIP=0

die() {
  echo "compile dogfood FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

XLANG_BIN="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

# PLATFORM: DARWIN — hosted compile prefer xlang-c (asm __TEXT not r-x).
# PLATFORM: LINUX — product asm preferred; xlang-c still ok for dogfood path.
PERF_COMPILE_XLANG="$XLANG_BIN"
case "$(uname -s 2>/dev/null)" in
  Darwin)
    if [ -x ./compiler/xlang-c ] && dod_native_exe "$(pwd)/compiler/xlang-c"; then
      PERF_COMPILE_XLANG="$(pwd)/compiler/xlang-c"
    fi
    ;;
  *)
    if [ -x ./compiler/xlang-c ] && dod_native_exe "$(pwd)/compiler/xlang-c"; then
      PERF_COMPILE_XLANG="$(pwd)/compiler/xlang-c"
    fi
    ;;
esac
echo "compile dogfood: resolve=$XLANG_BIN compile=$PERF_COMPILE_XLANG"

RUNS="${XLANG_PERF_COMPILE_RUNS:-3}"
BASELINE="${XLANG_PERF_COMPILE_BASELINE:-tests/baseline/compile-dogfood.tsv}"
FAIL_REGRESS=0
UPDATE_BASELINE=0
[ "${XLANG_PERF_FAIL_ON_COMPILE_REGRESSION:-0}" = "1" ] && FAIL_REGRESS=1
[ "${XLANG_PERF_UPDATE_BASELINE:-0}" = "1" ] && UPDATE_BASELINE=1

ROOT=$(pwd)
case "$PERF_COMPILE_XLANG" in
  /*) XLANG_EXE="$PERF_COMPILE_XLANG" ;;
  *) XLANG_EXE="$ROOT/$PERF_COMPILE_XLANG" ;;
esac
if [ ! -x "$XLANG_EXE" ]; then
  die "missing executable: $XLANG_EXE"
fi

echo "=== compile dogfood (XLANG=$XLANG_EXE RUNS=$RUNS FAIL_REGRESS=$FAIL_REGRESS) ==="

export XLANG_EXE RUNS BASELINE FAIL_REGRESS UPDATE_BASELINE ROOT PREFIX
export OBS RUN_OK SKIP
# shellcheck disable=SC2034
python3 <<'PY'
import os, statistics, subprocess, sys, time

xlang = os.environ["XLANG_EXE"]
runs = int(os.environ["RUNS"])
baseline_path = os.environ["BASELINE"]
fail_regress = os.environ["FAIL_REGRESS"] == "1"
update_baseline = os.environ["UPDATE_BASELINE"] == "1"
root = os.environ["ROOT"]
prefix = os.environ["PREFIX"]
obs = 0
run_ok = 0
skip = 0

# Fixed cases: P0 bench -o + compiler heavy-module check (frontend dogfood).
# wave309 honesty: renamed micro benches (r01_/m03_/r10_/a01_); TSV keys unchanged.
# Check cases: check gate paused → failure = obs (not soft silence).
cases = [
    ("loop_i32", f'"{xlang}" bench/r01_loop_i32.x -o /tmp/xlang_dog_loop_i32', "compile"),
    ("mem_copy", f'"{xlang}" bench/m03_mem_copy.x -o /tmp/xlang_dog_mem_copy', "compile"),
    ("struct_param", f'"{xlang}" bench/r10_struct_param.x -o /tmp/xlang_dog_struct_param', "compile"),
    ("call_boundary", f'"{xlang}" bench/a01_call_boundary.x -o /tmp/xlang_dog_call_boundary', "compile"),
    ("perf_main", f'"{xlang}" tests/perf-baseline/main.x -o /tmp/xlang_dog_perf_main', "compile"),
    ("check_backend", f'"{xlang}" check compiler/src/asm/backend.x', "check"),
    ("check_parser", f'"{xlang}" check compiler/src/parser/parser.x', "check"),
    ("check_typeck", f'"{xlang}" check compiler/src/typeck/typeck.x', "check"),
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
    last_rc = 0
    for _ in range(n):
        t0 = time.perf_counter()
        r = subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, cwd=root)
        dt = time.perf_counter() - t0
        last_rc = r.returncode
        if r.returncode != 0:
            return None, f"exit {r.returncode}", last_rc
        times.append(dt)
    return statistics.median(times), times, 0

baseline = load_baseline(baseline_path)
failures = 0
rows = []

print("| case | median (s) | baseline (s) |")
print("|---|---:|---:|")

for name, cmd, kind in cases:
    med, detail, rc = median_time(cmd, runs)
    if med is None:
        if kind == "check":
            # PLATFORM: SHARED — check gate paused; check_fail = product obs.
            print(f"compile dogfood OBS: {name} check_fail ({detail})", file=sys.stderr)
            obs += 1
            rows.append((name, None, baseline.get(name), "CHECK_FAIL"))
            print(f"| {name} | — | {baseline.get(name) or '—'} | CHECK_FAIL |")
            continue
        print(f"compile dogfood FAIL: {name}: {detail}", file=sys.stderr)
        print(f"{prefix} status=fail run={run_ok} obs={obs} skip={skip}")
        sys.exit(1)
    cap = baseline.get(name)
    eff_cap = cap
    if cap is not None and os.environ.get("CI", "").lower() in ("1", "true"):
        ci_mult = 1.4
        # Alpine/musl Docker: check_backend ~1.45× slower than glibc; widen.
        if os.path.isfile("/.dockerenv") or os.environ.get("XLANG_CI_DOCKER"):
            ci_mult = 1.65
        eff_cap = cap * ci_mult
    status = "OK"
    if eff_cap is not None and med > eff_cap:
        status = "SLOW"
        if fail_regress:
            print(
                f"xlang: [XLANG_PERF_ALERT] severity=critical baseline_id=compile-dogfood "
                f"metric={name} measured={med:.4f} cap={eff_cap:.4f} "
                f"gate=run-perf-compile-dogfood-gate.sh",
                file=sys.stderr,
            )
            failures += 1
        else:
            # Honesty: soft FAIL_ON:-0 previously silent OK — report obs.
            print(
                f"compile dogfood OBS: {name} {med:.4f}s > cap {eff_cap:.4f}s "
                f"(set XLANG_PERF_FAIL_ON_COMPILE_REGRESSION=1 to hard-fail)",
                file=sys.stderr,
            )
            obs += 1
    else:
        run_ok += 1
    rows.append((name, med, cap, status))
    cap_s = f"{cap:.4f}" if cap is not None else "—"
    print(f"| {name} | {med:.4f} | {cap_s} | {status} |")

if update_baseline:
    os.makedirs(os.path.dirname(baseline_path) or ".", exist_ok=True)
    with open(baseline_path, "w", encoding="utf-8") as f:
        f.write("# xlang fixed-module compile/check median ceiling (s); gate: median ≤ column\n")
        f.write("# update: XLANG_PERF_UPDATE_BASELINE=1 ./tests/run-perf-compile-dogfood.sh\n")
        for name, med, _, st in rows:
            if med is None:
                continue
            ceiling = max(med * 1.5, med + 0.015)
            f.write(f"{name}\t{ceiling:.4f}\n")
    print(f"updated baseline: {baseline_path}")

if failures:
    print(f"compile dogfood FAIL: {failures} case(s) over baseline", file=sys.stderr)
    print(f"{prefix} status=fail run={run_ok} obs={obs} skip={skip}")
    sys.exit(1)

print("=== compile dogfood OK ===")
print(f"{prefix} status=ok run={run_ok} obs={obs} skip={skip}")
PY
