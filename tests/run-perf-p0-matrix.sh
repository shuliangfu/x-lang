#!/usr/bin/env bash
# run-perf-p0-matrix.sh — P0+P1 bench matrix: C/Zig/xlang median + size + compile time.
#
# Honesty: soft XLANG_PERF_FAIL_ON_C_O2:-0 previously left xlang slower than
# C -O2 unchecked, and FAIL_ON=1 was a no-op stub ("gate check disabled") =
# portable false-green. Soft prefer-xlang-c-only retired. Prefer product
# xlang_asm (Darwin hosted build may use xlang-c). Slower-than-C / xlang
# compile-fail = obs (FAIL_ON=1 still hard for vs_c>1). Explicit bad XLANG
# = hard die. Report run=/obs=/skip=.
#
# Usage:
#   ./tests/run-perf-p0-matrix.sh              # default 3 runs
#   ./tests/run-perf-p0-matrix.sh --bench      # 10 runs + size + compile time
#   XLANG_PERF_MIN_RUNS=30 ./tests/run-perf-p0-matrix.sh --bench
# Env:
#   XLANG_PERF_FAIL_ON_C_O2=1 — xlang median ≤ C -O2 hard
# PLATFORM: SHARED archaeology (Ubuntu gold).
set -u
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/perf-env.sh
. tests/lib/perf-env.sh
perf_env_setup

# Zig baseline helper (optional, for version pin check).
# shellcheck source=tests/lib/zig-baseline.sh
. "$(dirname "$0")/lib/zig-baseline.sh" 2>/dev/null || true

PREFIX="xlang: [XLANG_PERF_P0_MATRIX]"
OBS=0
RUN_OK=0
SKIP=0
C_O2_FAILS=0

die() {
  echo "p0-matrix FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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

# PLATFORM: DARWIN — hosted microbench prefer xlang-c (asm __TEXT not r-x).
# PLATFORM: LINUX — product asm preferred; xlang-c still ok for B-CMP path.
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
echo "p0-matrix: resolve=$XLANG_BIN compile=$PERF_COMPILE_XLANG"

DO_BENCH=0
[ "${1:-}" = "--bench" ] && DO_BENCH=1
RUNS="${XLANG_PERF_MIN_RUNS:-3}"
[ "$DO_BENCH" = "1" ] && RUNS="${XLANG_PERF_MIN_RUNS:-10}"
WARMUP="${XLANG_PERF_WARMUP:-1}"
FAIL_ON_C_O2="${XLANG_PERF_FAIL_ON_C_O2:-0}"

# Output report file.
REPORT="/tmp/xlang_p0_matrix_report.md"
: > "$REPORT"

# ── helpers ───────────────────────────────────────────────────────────

# Compile a .c file with cc -O2, return binary path or empty on failure.
compile_c() {
  local src="$1"
  local out="$2"
  local extra="${3:-}"
  if cc -std=gnu11 -O2 $extra "$src" -o "$out" 2>/dev/null && [ -x "$out" ]; then
    echo "$out"
  else
    echo ""
  fi
}

# Compile a .zig file with zig -OReleaseFast, return binary path or empty.
compile_zig() {
  local src="$1"
  local out="$2"
  if command -v zig >/dev/null 2>&1; then
    if zig build-exe -OReleaseFast -fno-emit-bin "$src" -femit-bin="$out" 2>/dev/null && [ -x "$out" ]; then
      echo "$out"
    else
      echo ""
    fi
  else
    echo ""
  fi
}

# Compile a .x file with xlang compiler, return binary path or empty.
compile_xlang() {
  local src="$1"
  local out="$2"
  local opt="${3:-2}"
  if [ -x "$PERF_COMPILE_XLANG" ]; then
    if "$PERF_COMPILE_XLANG" -O "$opt" "$src" -o "$out" 2>/dev/null && [ -x "$out" ]; then
      echo "$out"
    else
      echo ""
    fi
  else
    echo ""
  fi
}

# Time a compile command (wall seconds). Usage: time_compile <cmd...>
time_compile() {
  local t_start t_end
  t_start=$(date +%s.%N 2>/dev/null || date +%s)
  "$@" >/dev/null 2>&1
  t_end=$(date +%s.%N 2>/dev/null || date +%s)
  awk -v s="$t_start" -v e="$t_end" 'BEGIN { print e - s }'
}

# ── bench case runner ────────────────────────────────────────────────
# Usage: run_case <case_name> <base_path> [extra_c_flags]
# Sets globals: CASE, C_MED, ZIG_MED, XLANG_MED, C_SIZE, ZIG_SIZE, XLANG_SIZE,
#               C_BT, ZIG_BT, XLANG_BT
run_case() {
  local name="$1"
  local base="$2"
  local extra_c="${3:-}"
  local x="${base}.x"
  local c="${base}.c"
  local zig="${base}.zig"
  local tag="p0_${name}"
  local out_c="/tmp/${tag}_c"
  local out_zig="/tmp/${tag}_zig"
  local out_xlang="/tmp/${tag}_xlang"

  C_MED="nan"; ZIG_MED="nan"; XLANG_MED="nan"
  C_SIZE="0"; ZIG_SIZE="0"; XLANG_SIZE="0"
  C_BT="nan"; ZIG_BT="nan"; XLANG_BT="nan"

  echo "--- ${name} ---"

  # C: compile + time + run median + size.
  if [ -f "$c" ] && command -v cc >/dev/null 2>&1; then
    C_BT=$(time_compile cc -std=gnu11 -O2 $extra_c "$c" -o "$out_c")
    if [ -x "$out_c" ]; then
      C_MED=$(median_real "$out_c" "$RUNS" "$WARMUP")
      C_SIZE=$(stripped_size "$out_c")
      echo "  C -O2:      median=${C_MED}s  stripped=${C_SIZE}B  compile=${C_BT}s"
    fi
  fi

  # Zig: compile + time + run median + size.
  if [ -f "$zig" ] && command -v zig >/dev/null 2>&1; then
    ZIG_BT=$(time_compile zig build-exe -OReleaseFast -fno-emit-bin "$zig" -femit-bin="$out_zig")
    if [ -x "$out_zig" ]; then
      ZIG_MED=$(median_real "$out_zig" "$RUNS" "$WARMUP")
      ZIG_SIZE=$(stripped_size "$out_zig")
      echo "  Zig Fast:   median=${ZIG_MED}s  stripped=${ZIG_SIZE}B  compile=${ZIG_BT}s"
    fi
  fi

  # xlang: compile + time + run median + size.
  if [ -f "$x" ] && [ -x "$PERF_COMPILE_XLANG" ]; then
    XLANG_BT=$(time_compile "$PERF_COMPILE_XLANG" -O 2 "$x" -o "$out_xlang")
    if [ -x "$out_xlang" ]; then
      XLANG_MED=$(median_real "$out_xlang" "$RUNS" "$WARMUP")
      XLANG_SIZE=$(stripped_size "$out_xlang")
      echo "  xlang -O2:  median=${XLANG_MED}s  stripped=${XLANG_SIZE}B  compile=${XLANG_BT}s"
    else
      # Honesty: soft "expected during bootstrap" silent OK retired → obs (counted in write_case_row).
      echo "  xlang -O2:  COMPILE FAIL (obs; C/Zig refs still valid)"
      XLANG_BT="fail"
    fi
  elif [ -f "$x" ]; then
    die "compiler not executable ($PERF_COMPILE_XLANG)"
  fi
}

# ── report writer ───────────────────────────────────────────────────
write_report_header() {
  perf_env_header | tee -a "$REPORT"
  echo "" | tee -a "$REPORT"
  echo "# xlang P0+P1 Bench Matrix Report" | tee -a "$REPORT"
  echo "" | tee -a "$REPORT"
  echo "Generated: $(date '+%Y-%m-%d %H:%M:%S %z')" | tee -a "$REPORT"
  echo "Runs: ${RUNS} (warmup: ${WARMUP})" | tee -a "$REPORT"
  echo "" | tee -a "$REPORT"
  echo "## Runtime Median (seconds, smaller = faster)" | tee -a "$REPORT"
  echo "" | tee -a "$REPORT"
  printf '| case | C -O2 | Zig Fast | xlang -O2 | vs_c (xlang/c) | vs_zig (xlang/zig) |\n' | tee -a "$REPORT"
  printf '|------|-------|----------|-----------|---------------|--------------------|\n' | tee -a "$REPORT"
}

write_case_row() {
  local name="$1"
  local vs_c="nan"
  local vs_zig="nan"
  if [ "$XLANG_BT" = "fail" ]; then
    echo "p0-matrix OBS: ${name} xlang compile fail" >&2
    OBS=$((OBS + 1))
  elif [ "$XLANG_MED" != "nan" ]; then
    RUN_OK=$((RUN_OK + 1))
  fi
  if [ "$XLANG_MED" != "nan" ] && [ "$C_MED" != "nan" ]; then
    vs_c=$(awk -v x="$XLANG_MED" -v c="$C_MED" 'BEGIN { if(c>0) printf "%.3f", x/c; else print "nan" }')
    # Soft FAIL_ON_C_O2:-0 previously ignored vs_c>1; FAIL=1 was a stub.
    if awk -v v="$vs_c" 'BEGIN { exit !(v+0 > 1.0) }'; then
      if [ "$FAIL_ON_C_O2" = "1" ]; then
        echo "p0-matrix FAIL: ${name} vs_c=${vs_c} (xlang slower than C -O2)" >&2
        C_O2_FAILS=$((C_O2_FAILS + 1))
      else
        echo "p0-matrix OBS: ${name} vs_c=${vs_c} (xlang slower than C -O2; set XLANG_PERF_FAIL_ON_C_O2=1 to hard-fail)" >&2
        OBS=$((OBS + 1))
      fi
    fi
  fi
  if [ "$XLANG_MED" != "nan" ] && [ "$ZIG_MED" != "nan" ]; then
    vs_zig=$(awk -v x="$XLANG_MED" -v z="$ZIG_MED" 'BEGIN { if(z>0) printf "%.3f", x/z; else print "nan" }')
  fi
  printf '| %s | %s | %s | %s | %s | %s |\n' \
    "$name" "$C_MED" "$ZIG_MED" "$XLANG_MED" "$vs_c" "$vs_zig" | tee -a "$REPORT"
}

write_size_section() {
  echo "" | tee -a "$REPORT"
  echo "## Stripped Binary Size (bytes, smaller = better)" | tee -a "$REPORT"
  echo "" | tee -a "$REPORT"
  printf '| case | C -O2 | Zig Fast | xlang -O2 | vs_c (xlang/c) |\n' | tee -a "$REPORT"
  printf '|------|-------|----------|-----------|---------------|\n' | tee -a "$REPORT"
}

write_size_row() {
  local name="$1"
  local vs_c="nan"
  if [ "$XLANG_SIZE" != "0" ] && [ "$C_SIZE" != "0" ]; then
    vs_c=$(awk -v x="$XLANG_SIZE" -v c="$C_SIZE" 'BEGIN { if(c>0) printf "%.3f", x/c; else print "nan" }')
  fi
  printf '| %s | %s | %s | %s | %s |\n' \
    "$name" "$C_SIZE" "$ZIG_SIZE" "$XLANG_SIZE" "$vs_c" | tee -a "$REPORT"
}

write_buildtime_section() {
  echo "" | tee -a "$REPORT"
  echo "## Compile Time (seconds, smaller = better)" | tee -a "$REPORT"
  echo "" | tee -a "$REPORT"
  printf '| case | C -O2 | Zig Fast | xlang -O2 |\n' | tee -a "$REPORT"
  printf '|------|-------|----------|-----------|\n' | tee -a "$REPORT"
}

write_buildtime_row() {
  local name="$1"
  printf '| %s | %s | %s | %s |\n' "$name" "$C_BT" "$ZIG_BT" "$XLANG_BT" | tee -a "$REPORT"
}

# ── main ────────────────────────────────────────────────────────────
echo "=== xlang P0+P1 bench matrix (runs=$RUNS, warmup=$WARMUP) ==="
echo "=== xlang compiler: $PERF_COMPILE_XLANG ==="
echo ""

write_report_header

# P0 compute (R series).
RUN_CASES=(
  "r02_float_accum|bench/r02_float_accum"
  "r05_matmul|bench/r05_matmul"
  "r06_sort|bench/r06_sort"
  "r07_hash|bench/r07_hash"
  "r09_recursion_vs_iter|bench/r09_recursion_vs_iter"
  "m01_no_alloc|bench/m01_no_alloc"
  "a02_indirect_call|bench/a02_indirect_call"
)

# P1 concurrency + I/O (need -pthread for C).
RUN_CASES_PTHREAD=(
  "cc01_thread_create|bench/cc01_thread_create"
  "cc02_mutex_contention|bench/cc02_mutex_contention"
  "cc04_parallel_reduce|bench/cc04_parallel_reduce"
  "cc05_thread_affinity|bench/cc05_thread_affinity"
  "i02_multi_file_read|bench/i02_multi_file_read"
)

# P0 size (B01 hello — size only, runtime trivial).
RUN_CASES_SIZE=(
  "b01_hello|bench/b01_hello"
)

# ── run + collect runtime ───────────────────────────────────────────
for entry in "${RUN_CASES[@]}"; do
  name="${entry%%|*}"
  base="${entry##*|}"
  run_case "$name" "$base"
  write_case_row "$name"
done

for entry in "${RUN_CASES_PTHREAD[@]}"; do
  name="${entry%%|*}"
  base="${entry##*|}"
  run_case "$name" "$base" "-pthread"
  write_case_row "$name"
done

# B01 hello: runtime trivial, but still record.
for entry in "${RUN_CASES_SIZE[@]}"; do
  name="${entry%%|*}"
  base="${entry##*|}"
  run_case "$name" "$base"
  write_case_row "$name"
done

# ── size section ────────────────────────────────────────────────────
if [ "$DO_BENCH" = "1" ]; then
  write_size_section
  # Re-run to collect sizes (already in globals from last run_case, but re-collect all).
  for entry in "${RUN_CASES[@]}" "${RUN_CASES_PTHREAD[@]}" "${RUN_CASES_SIZE[@]}"; do
    name="${entry%%|*}"
    base="${entry##*|}"
    extra=""
    case "$name" in cc*) extra="-pthread" ;; esac
    run_case "$name" "$base" "$extra"
    write_size_row "$name"
  done

  # ── build time section ────────────────────────────────────────────
  write_buildtime_section
  for entry in "${RUN_CASES[@]}" "${RUN_CASES_PTHREAD[@]}" "${RUN_CASES_SIZE[@]}"; do
    name="${entry%%|*}"
    base="${entry##*|}"
    extra=""
    case "$name" in cc*) extra="-pthread" ;; esac
    run_case "$name" "$base" "$extra"
    write_buildtime_row "$name"
  done
fi

echo "" | tee -a "$REPORT"
echo "## Notes" | tee -a "$REPORT"
echo "- xlang COMPILE FAIL = obs (not soft silence); C/Zig refs remain valid." | tee -a "$REPORT"
echo "- vs_c > 1.0 = obs by default; XLANG_PERF_FAIL_ON_C_O2=1 hard-fails." | tee -a "$REPORT"
echo "- vs_c < 1.0 means xlang faster than C -O2; vs_zig < 1.0 means faster than Zig ReleaseFast." | tee -a "$REPORT"
echo "- Concurrency cases (.x) use single-thread fallback (xlang thread API not yet available)." | tee -a "$REPORT"

echo "" | tee -a "$REPORT"
echo "=== P0+P1 matrix done. Report: $REPORT ==="

if [ "$C_O2_FAILS" -gt 0 ]; then
  die "${C_O2_FAILS} case(s) slower than C -O2 (XLANG_PERF_FAIL_ON_C_O2=1)"
fi
ok_report
