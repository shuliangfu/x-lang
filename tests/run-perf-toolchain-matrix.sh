#!/usr/bin/env bash
# run-perf-toolchain-matrix.sh — Toolchain metrics: RSS / link size / build time / debug info
#
# Covers dimensions not in run-perf-p0-matrix.sh:
#   M05  peak RSS           — max RSS during runtime (via /usr/bin/time -v or getrusage)
#   B03  static vs dynamic   — stripped size comparing -static vs dynamic libc link
#   B05  three-lang size     — stripped size comparison table across C/Zig/xlang
#   BT02 mid-project build   — xlang compiler compiling a mid-size .x project
#   BT03 incremental build   — rebuild after touching one file
#   BT05 parallel build      — xbuild/hub ensure xlang-c under XLANG_JOBS=1/2/4
#   L02  large gen code      — compile a large generated .x file
#   L03  debug info size     — binary size with -g vs without
#
# Usage: ./tests/run-perf-toolchain-matrix.sh
set -u
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/perf-env.sh
. tests/lib/perf-env.sh
perf_env_setup

PERF_COMPILE_XLANG="./compiler/xlang-c"
[ -x ./compiler/xlang-c ] || PERF_COMPILE_XLANG="./compiler/xlang"
REPORT="/tmp/xlang_toolchain_report.md"
: > "$REPORT"

# ── helpers ──

# Get peak RSS in KB of a command. Cross-platform.
# macOS: /usr/bin/time -l gives "maximum resident set size" in bytes.
# Linux: /usr/bin/time -v gives "Maximum resident set size (kbytes)".
peak_rss_kb() {
  local exe="$1"
  local rss=""
  if [ "$XLANG_PERF_ENV_OS" = "Darwin" ]; then
    rss=$(/usr/bin/time -l "$exe" >/dev/null 2>&1 | grep -i 'maximum resident' | awk '{print $1}')
    # macOS reports bytes; convert to KB.
    if [ -n "$rss" ]; then
      rss=$((rss / 1024))
    fi
  else
    rss=$(/usr/bin/time -v "$exe" >/dev/null 2>&1 | grep -i 'Maximum resident' | awk '{print $NF}')
  fi
  echo "${rss:-0}"
}

# Stripped binary size in bytes.
stripped_size() {
  local bin="$1"
  if [ ! -f "$bin" ]; then echo "0"; return; fi
  local tmp="${TMPDIR:-/tmp}/perf_strip_$$.tmp"
  cp "$bin" "$tmp" 2>/dev/null || true
  command -v strip >/dev/null 2>&1 && strip "$tmp" >/dev/null 2>&1 || true
  ls -l "$tmp" 2>/dev/null | awk '{print $5; exit}'
  rm -f "$tmp" 2>/dev/null || true
}

# Time a command (wall seconds).
time_cmd() {
  local t_start t_end
  t_start=$(date +%s.%N 2>/dev/null || date +%s)
  "$@" >/dev/null 2>&1
  t_end=$(date +%s.%N 2>/dev/null || date +%s)
  awk -v s="$t_start" -v e="$t_end" 'BEGIN { print e - s }'
}

# ── M05: Peak RSS ──
bench_m05_rss() {
  echo "## M05: Peak RSS (KB, smaller = leaner runtime)" | tee -a "$REPORT"
  echo "" | tee -a "$REPORT"
  printf '| case | C -O2 | Zig Fast | xlang -O2 |\n' | tee -a "$REPORT"
  printf '|------|-------|----------|-----------|\n' | tee -a "$REPORT"
  for case in r02_float_accum r05_matmul r06_sort r07_hash m01_no_alloc; do
    local c_rss="0" z_rss="0" x_rss="0"
    local out_c="/tmp/m05_${case}_c" out_z="/tmp/m05_${case}_z" out_x="/tmp/m05_${case}_x"
    if cc -std=gnu11 -O2 "bench/${case}.c" -o "$out_c" 2>/dev/null && [ -x "$out_c" ]; then
      c_rss=$(peak_rss_kb "$out_c")
    fi
    if command -v zig >/dev/null 2>&1; then
      zig build-exe -OReleaseFast -fno-emit-bin "bench/${case}.zig" -femit-bin="$out_z" 2>/dev/null && [ -x "$out_z" ] && z_rss=$(peak_rss_kb "$out_z")
    fi
    if [ -x "$PERF_COMPILE_XLANG" ]; then
      "$PERF_COMPILE_XLANG" -O 2 "bench/${case}.x" -o "$out_x" 2>/dev/null && [ -x "$out_x" ] && x_rss=$(peak_rss_kb "$out_x")
    fi
    printf '| %s | %s | %s | %s |\n' "$case" "$c_rss" "$z_rss" "$x_rss" | tee -a "$REPORT"
    echo "  M05 ${case}: C=${c_rss}KB Zig=${z_rss}KB xlang=${x_rss}KB"
  done
  echo "" | tee -a "$REPORT"
}

# ── B03: Static vs Dynamic link size ──
bench_b03_link() {
  echo "## B03: Static vs Dynamic Link (stripped bytes)" | tee -a "$REPORT"
  echo "" | tee -a "$REPORT"
  printf '| case | C dynamic | C static | ratio (static/dynamic) |\n' | tee -a "$REPORT"
  printf '|------|-----------|----------|------------------------|\n' | tee -a "$REPORT"
  for case in b01_hello r01_loop_i32 m01_no_alloc; do
    local dyn="0" sta="0" ratio="nan"
    local out_d="/tmp/b03_${case}_dyn" out_s="/tmp/b03_${case}_sta"
    if cc -std=gnu11 -O2 "bench/${case}.c" -o "$out_d" 2>/dev/null && [ -x "$out_d" ]; then
      dyn=$(stripped_size "$out_d")
    fi
    # Static link (may fail on macOS with libc differences; best-effort).
    if cc -std=gnu11 -O2 -static "bench/${case}.c" -o "$out_s" 2>/dev/null && [ -x "$out_s" ]; then
      sta=$(stripped_size "$out_s")
    else
      sta="n/a (static link not available)"
    fi
    if [ "$sta" != "n/a (static link not available)" ] && [ "$dyn" != "0" ]; then
      ratio=$(awk -v s="$sta" -v d="$dyn" 'BEGIN { if(d>0) printf "%.3f", s/d; else print "nan" }')
    fi
    printf '| %s | %s | %s | %s |\n' "$case" "$dyn" "$sta" "$ratio" | tee -a "$REPORT"
    echo "  B03 ${case}: dyn=${dyn}B static=${sta} ratio=${ratio}"
  done
  echo "" | tee -a "$REPORT"
}

# ── B05: Three-language same-function size ──
bench_b05_size() {
  echo "## B05: Three-Language Stripped Size (bytes)" | tee -a "$REPORT"
  echo "" | tee -a "$REPORT"
  printf '| case | C -O2 | Zig Fast | xlang -O2 | vs_c |\n' | tee -a "$REPORT"
  printf '|------|-------|----------|-----------|------|\n' | tee -a "$REPORT"
  for case in b01_hello r01_loop_i32 r05_matmul r06_sort r07_hash m01_no_alloc r10_struct_param a01_call_boundary; do
    local c_sz="0" z_sz="0" x_sz="0" vs_c="nan"
    local out_c="/tmp/b05_${case}_c" out_z="/tmp/b05_${case}_z" out_x="/tmp/b05_${case}_x"
    cc -std=gnu11 -O2 "bench/${case}.c" -o "$out_c" 2>/dev/null && [ -x "$out_c" ] && c_sz=$(stripped_size "$out_c")
    if command -v zig >/dev/null 2>&1; then
      zig build-exe -OReleaseFast -fno-emit-bin "bench/${case}.zig" -femit-bin="$out_z" 2>/dev/null && [ -x "$out_z" ] && z_sz=$(stripped_size "$out_z")
    fi
    if [ -x "$PERF_COMPILE_XLANG" ]; then
      "$PERF_COMPILE_XLANG" -O 2 "bench/${case}.x" -o "$out_x" 2>/dev/null && [ -x "$out_x" ] && x_sz=$(stripped_size "$out_x")
    fi
    if [ "$x_sz" != "0" ] && [ "$c_sz" != "0" ]; then
      vs_c=$(awk -v x="$x_sz" -v c="$c_sz" 'BEGIN { if(c>0) printf "%.3f", x/c; else print "nan" }')
    fi
    printf '| %s | %s | %s | %s | %s |\n' "$case" "$c_sz" "$z_sz" "$x_sz" "$vs_c" | tee -a "$REPORT"
    echo "  B05 ${case}: C=${c_sz}B Zig=${z_sz}B xlang=${x_sz}B vs_c=${vs_c}"
  done
  echo "" | tee -a "$REPORT"
}

# ── BT02: Mid-project full build time ──
bench_bt02() {
  echo "## BT02: Mid-Project Full Build (wall seconds)" | tee -a "$REPORT"
  echo "" | tee -a "$REPORT"
  printf '| case | C -O2 | Zig Fast | xlang -O2 |\n' | tee -a "$REPORT"
  printf '|------|-------|----------|-----------|\n' | tee -a "$REPORT"
  # Mid-project = compile multiple bench .x files sequentially (simulates mid project).
  local c_files="" x_files=""
  for case in r01_loop_i32 r02_float_accum r05_matmul r06_sort m01_no_alloc r10_struct_param; do
    [ -f "bench/${case}.c" ] && c_files="$c_files bench/${case}.c"
    [ -f "bench/${case}.x" ] && x_files="$x_files bench/${case}.x"
  done
  local c_bt="nan" z_bt="nan" x_bt="nan"
  # C: compile all to one binary.
  if [ -n "$c_files" ]; then
    c_bt=$(time_cmd cc -std=gnu11 -O2 $c_files -o /tmp/bt02_c_all 2>/dev/null)
  fi
  # xlang: compile each .x (sequential, simulating project build).
  if [ -n "$x_files" ] && [ -x "$PERF_COMPILE_XLANG" ]; then
    local t_start t_end
    t_start=$(date +%s.%N 2>/dev/null || date +%s)
    for xf in $x_files; do
      "$PERF_COMPILE_XLANG" -O 2 "$xf" -o "/tmp/bt02_$(basename "$xf" .x)" >/dev/null 2>&1 || true
    done
    t_end=$(date +%s.%N 2>/dev/null || date +%s)
    x_bt=$(awk -v s="$t_start" -v e="$t_end" 'BEGIN { print e - s }')
  fi
  printf '| mid-project (6 files) | %s | %s | %s |\n' "$c_bt" "$z_bt" "$x_bt" | tee -a "$REPORT"
  echo "  BT02: C=${c_bt}s xlang=${x_bt}s"
  echo "" | tee -a "$REPORT"
}

# ── BT03: Incremental build ──
bench_bt03() {
  echo "## BT03: Incremental Build (wall seconds, touch 1 file + rebuild)" | tee -a "$REPORT"
  echo "" | tee -a "$REPORT"
  printf '| case | xlang -O2 (touch+rebuild) |\n' | tee -a "$REPORT"
  printf '|------|--------------------------|\n' | tee -a "$REPORT"
  if [ -x "$PERF_COMPILE_XLANG" ] && [ -f bench/r01_loop_i32.x ]; then
    # First: full compile.
    "$PERF_COMPILE_XLANG" -O 2 bench/r01_loop_i32.x -o /tmp/bt03_full >/dev/null 2>&1 || true
    # Touch the source (add a comment, recompile).
    cp bench/r01_loop_i32.x /tmp/bt03_touch_backup.x
    echo "// incremental touch $(date +%s)" >> bench/r01_loop_i32.x
    local bt
    bt=$(time_cmd "$PERF_COMPILE_XLANG" -O 2 bench/r01_loop_i32.x -o /tmp/bt03_incr 2>/dev/null)
    # Restore.
    cp /tmp/bt03_touch_backup.x bench/r01_loop_i32.x
    rm -f /tmp/bt03_touch_backup.x
    printf '| r01_loop_i32 incremental | %s |\n' "$bt" | tee -a "$REPORT"
    echo "  BT03: incremental=${bt}s"
  else
    printf '| (xlang compiler not available) | n/a |\n' | tee -a "$REPORT"
    echo "  BT03: skipped (no xlang compiler)"
  fi
  echo "" | tee -a "$REPORT"
}

# ── BT05: Parallel build scaling ──
# Post-MF phys-del: historic make -jN is gone. Bench ./xbuild / hub ensure_xlang_c
# under XLANG_JOBS=N when present; else skip honestly. PLATFORM: SHARED
bench_bt05() {
  echo "## BT05: Parallel Build Scaling (xbuild/hub ensure xlang-c, wall seconds)" | tee -a "$REPORT"
  echo "" | tee -a "$REPORT"
  printf '| -jN | wall time (s) |\n' | tee -a "$REPORT"
  printf '|-----|---------------|\n' | tee -a "$REPORT"
  if [ -x ./xbuild ] || [ -f tests/lib/compiler-make.sh ]; then
    # shellcheck source=tests/lib/compiler-make.sh
    . tests/lib/compiler-make.sh 2>/dev/null || true
    for j in 1 2 4; do
      local bt
      bt=$(time_cmd env XLANG_JOBS="$j" bash -c '
        if [ -x ./xbuild ]; then
          ./xbuild compiler-make xlang-c
        else
          xlang_compiler_make xlang-c
        fi
      ' 2>/dev/null || echo "nan")
      printf '| -j%s | %s |\n' "$j" "$bt" | tee -a "$REPORT"
      echo "  BT05: -j${j}=${bt}s"
    done
  else
    printf '| (no xbuild/hub) | n/a |\n' | tee -a "$REPORT"
    echo "  BT05: skipped (no xbuild / compiler-make hub)"
  fi
  echo "" | tee -a "$REPORT"
}

# ── L02: Large generated code compile time ──
bench_l02() {
  echo "## L02: Large Generated Code Compile (wall seconds)" | tee -a "$REPORT"
  echo "" | tee -a "$REPORT"
  printf '| size | C -O2 | xlang -O2 |\n' | tee -a "$REPORT"
  printf '|------|-------|-----------|\n' | tee -a "$REPORT"
  # Generate a large C file (10000 lines of simple functions).
  local large_c="/tmp/l02_large.c"
  local large_x="/tmp/l02_large.x"
  {
    echo "#include <stdint.h>"
    for i in $(seq 1 1000); do
      echo "int32_t func_${i}(int32_t x) { return x * ${i} + ${i}; }"
    done
    echo "int main(void) { int32_t s = 0; for (int i = 0; i < 1000; i++) s += func_i(i); __asm__ volatile(\"\" : \"+r\"(s) : : \"memory\"); return (int)s; }"
  } > "$large_c"
  # Note: the above main references func_i which doesn't exist; fix to a simpler version.
  {
    echo "#include <stdint.h>"
    for i in $(seq 1 1000); do
      echo "static int32_t func_${i}(int32_t x) { return x * ${i} + ${i}; }"
    done
    echo "int main(void) {"
    echo "  int32_t s = 0;"
    for i in $(seq 1 1000); do
      echo "  s += func_${i}(s);"
    done
    echo "  __asm__ volatile(\"\" : \"+r\"(s) : : \"memory\");"
    echo "  return (int)s;"
    echo "}"
  } > "$large_c"
  local c_bt="nan" x_bt="nan"
  c_bt=$(time_cmd cc -std=gnu11 -O2 "$large_c" -o /tmp/l02_c_out 2>/dev/null)
  if [ -x "$PERF_COMPILE_XLANG" ]; then
    # Generate large .x (1000 functions).
    {
      echo "function main(): i32 {"
      echo "  let s: i32 = 0;"
      for i in $(seq 1 1000); do
        echo "  s = s * ${i} + ${i};"
      done
      echo "  return s;"
      echo "}"
    } > "$large_x"
    x_bt=$(time_cmd "$PERF_COMPILE_XLANG" -O 2 "$large_x" -o /tmp/l02_x_out 2>/dev/null)
  fi
  printf '| 1000 functions | %s | %s |\n' "$c_bt" "$x_bt" | tee -a "$REPORT"
  echo "  L02: C=${c_bt}s xlang=${x_bt}s"
  rm -f "$large_c" "$large_x" 2>/dev/null || true
  echo "" | tee -a "$REPORT"
}

# ── L03: Debug info size ──
bench_l03() {
  echo "## L03: Debug Info Size (stripped bytes, -g vs no -g)" | tee -a "$REPORT"
  echo "" | tee -a "$REPORT"
  printf '| case | C no-g | C -g | delta | xlang -g |\n' | tee -a "$REPORT"
  printf '|------|--------|------|-------|----------|\n' | tee -a "$REPORT"
  for case in b01_hello r01_loop_i32 r06_sort; do
    local nog="0" g="0" delta="0" xg="0"
    local out_ng="/tmp/l03_${case}_ng" out_g="/tmp/l03_${case}_g" out_xg="/tmp/l03_${case}_xg"
    if cc -std=gnu11 -O2 "bench/${case}.c" -o "$out_ng" 2>/dev/null && [ -x "$out_ng" ]; then
      nog=$(stripped_size "$out_ng")
    fi
    if cc -std=gnu11 -O2 -g "bench/${case}.c" -o "$out_g" 2>/dev/null && [ -x "$out_g" ]; then
      g=$(stripped_size "$out_g")
    fi
    if [ "$g" != "0" ] && [ "$nog" != "0" ]; then
      delta=$((g - nog))
    fi
    if [ -x "$PERF_COMPILE_XLANG" ]; then
      "$PERF_COMPILE_XLANG" -O 2 -g "bench/${case}.x" -o "$out_xg" 2>/dev/null && [ -x "$out_xg" ] && xg=$(stripped_size "$out_xg") || xg="n/a"
    fi
    printf '| %s | %s | %s | %s | %s |\n' "$case" "$nog" "$g" "$delta" "$xg" | tee -a "$REPORT"
    echo "  L03 ${case}: no-g=${nog}B -g=${g}B delta=${delta}B xlang-g=${xg}"
  done
  echo "" | tee -a "$REPORT"
}

# ── main ──
echo "=== xlang toolchain metrics matrix ==="
echo "=== xlang compiler: $PERF_COMPILE_XLANG ==="
echo ""

perf_env_header | tee -a "$REPORT"
echo "" | tee -a "$REPORT"
echo "# xlang Toolchain Metrics Report" | tee -a "$REPORT"
echo "" | tee -a "$REPORT"
echo "Generated: $(date '+%Y-%m-%d %H:%M:%S %z')" | tee -a "$REPORT"
echo "" | tee -a "$REPORT"

bench_m05_rss
bench_b03_link
bench_b05_size
bench_bt02
bench_bt03
bench_bt05
bench_l02
bench_l03

echo "## Notes" | tee -a "$REPORT"
echo "- Static link may not be available on macOS (libc differences)." | tee -a "$REPORT"
echo "- BT05 uses './xbuild compiler-make xlang-c' / hub (MF phys-del); otherwise skipped." | tee -a "$REPORT"
echo "- L02 generates 1000 functions and measures compile time." | tee -a "$REPORT"
echo "- L03 compares binary size with/without debug info." | tee -a "$REPORT"

echo "" | tee -a "$REPORT"
echo "=== Toolchain matrix done. Report: $REPORT ==="
