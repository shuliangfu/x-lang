#!/usr/bin/env bash
# std-test-runner.sh — STD-145 manifest 与烟测辅助

STD145_PREFIX="${SHUX_STD145_TEST_RUNNER_PREFIX:-shux: [SHUX_STD145_TEST_RUNNER]}"

# 校验 manifest；echo 缺失数。
std_test_runner_symbols_ok() {
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
          echo "std-test-runner FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/test/test_glue.c" ]; then path="std/test/test.sx"; fi
        if [ "$path" = "std/test/test.sx" ]; then path="std/test/test.sx"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-test-runner FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      smoke|gate)
        if [ ! -f "$anchor" ]; then
          echo "std-test-runner FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ ! -f "$anchor" ]; then
          echo "std-test-runner FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "analysis/std-test-runner-v1.md" 2>/dev/null; then
          echo "std-test-runner FAIL: missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 runner_smoke；校验 stderr 含 SHUX_TEST 与 SUMMARY。
std_test_runner_run_smoke() {
  local shux="$1"
  local src="$2"
  local test_o="$3"
  local exe="/tmp/shux_std_test_runner_$$"
  local err="/tmp/shux_std_test_runner_err_$$.log"
  if ! "$shux" -L . "$src" -o "$exe" "$test_o" >/dev/null 2>&1; then
    echo "std-test-runner FAIL: compile $src" >&2
    "$shux" -L . "$src" -o "$exe" "$test_o" 2>&1 | tail -12 >&2 || true
    rm -f "$exe" "$err"
    return 1
  fi
  set +e
  "$exe" 2>"$err"
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    cat "$err" >&2 || true
    rm -f "$err"
    echo "std-test-runner FAIL: run exit=$ec" >&2
    return 1
  fi
  if ! grep -qF 'shux: [SHUX_TEST] name=case_ok status=pass' "$err" 2>/dev/null; then
    cat "$err" >&2 || true
    rm -f "$err"
    echo "std-test-runner FAIL: missing pass line" >&2
    return 1
  fi
  if ! grep -qF 'shux: [SHUX_TEST_SUMMARY]' "$err" 2>/dev/null; then
    cat "$err" >&2 || true
    rm -f "$err"
    echo "std-test-runner FAIL: missing summary" >&2
    return 1
  fi
  rm -f "$err"
  return 0
}

std_test_runner_emit_report() {
  local status="$1"
  local exec_ok="$2"
  local skip="$3"
  echo "${STD145_PREFIX} status=${status} exec=${exec_ok} skip=${skip}"
}
