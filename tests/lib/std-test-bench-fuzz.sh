#!/usr/bin/env bash
# std-test-bench-fuzz.sh — STD-054 manifest 与烟测辅助

STD_TEST_BENCH_FUZZ_PREFIX="${SHUX_STD_TEST_BENCH_FUZZ_PREFIX:-shux: [SHUX_STD_TEST_BENCH_FUZZ]}"

std_test_bench_fuzz_symbols_ok() {
  local mod_sx="$1"
  local test_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null; then
          echo "std-test-bench-fuzz FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/test/test_glue.c" ]; then path="std/test/test.sx"; fi
        if [ "$path" = "std/test/test.sx" ]; then path="std/test/test.sx"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-test-bench-fuzz FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-test-bench-fuzz FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_test_bench_fuzz_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shux_std_test_bf_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-test-bench-fuzz FAIL: compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-test-bench-fuzz FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_test_bench_fuzz_run_c_smoke() {
  local test_o="$1"
  local src="tests/std-test/bench_fuzz_ok.c"
  local out="/tmp/shux_std_test_bench_fuzz_$$"
  local comp_dir
  comp_dir="$(cd compiler && pwd)"
  if [ ! -f "$test_o" ]; then
    echo "std-test-bench-fuzz FAIL: missing $test_o" >&2
    return 1
  fi
  make -C compiler -q runtime_test_fn_invoke.o runtime_time_os.o runtime_env_os.o ../std/time/time.o ../std/env/env.o 2>/dev/null \
    || make -C compiler runtime_test_fn_invoke.o runtime_time_os.o runtime_env_os.o ../std/time/time.o ../std/env/env.o 2>/dev/null || true
  if ! cc -std=c11 -O1 -o "$out" "$src" "$test_o" \
    "$comp_dir/runtime_test_fn_invoke.o" "$comp_dir/runtime_time_os.o" "$comp_dir/runtime_env_os.o" ../std/time/time.o ../std/env/env.o -lc 2>/dev/null; then
    echo "std-test-bench-fuzz FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" 2>/tmp/shux_std_test_bench_fuzz_err_$$.log
  local ec=$?
  set -e
  if [ "$ec" -ne 0 ]; then
    cat /tmp/shux_std_test_bench_fuzz_err_$$.log >&2 || true
    rm -f "$out" /tmp/shux_std_test_bench_fuzz_err_$$.log
    echo "std-test-bench-fuzz FAIL: c smoke exit=$ec" >&2
    return 1
  fi
  if ! grep -qF 'shux: [SHUX_BENCH] name=smoke' /tmp/shux_std_test_bench_fuzz_err_$$.log 2>/dev/null; then
    rm -f "$out" /tmp/shux_std_test_bench_fuzz_err_$$.log
    echo "std-test-bench-fuzz FAIL: missing bench report line" >&2
    return 1
  fi
  rm -f "$out" /tmp/shux_std_test_bench_fuzz_err_$$.log
  return 0
}

std_test_bench_fuzz_emit_report() {
  local status="$1"
  local c_ok="$2"
  local bench_ok="$3"
  local fuzz_ok="$4"
  local skip="$5"
  echo "${STD_TEST_BENCH_FUZZ_PREFIX} status=${status} c_smoke=${c_ok} bench_sx=${bench_ok} fuzz_sx=${fuzz_ok} skip=${skip}"
}
