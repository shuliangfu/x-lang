#!/usr/bin/env bash
# std-test-runner.sh — STD-145 manifest 与烟测辅助
# Honesty 2026-08-26: report check=/run=/skip=; section anchors use TSV mod_path
# (archive DOC); refuse top-level DOC resurrect via gate.

STD145_PREFIX="${XLANG_STD145_TEST_RUNNER_PREFIX:-xlang: [XLANG_STD145_TEST_RUNNER]}"

# Validate manifest entries against product mod.x / test.x / files; echo miss count.
# @param mod_x path to std/test/mod.x
# @param test_x path to std/test/test.x (symbol anchors)
# @param tsv path to baseline TSV
# @return 0 when miss==0
std_test_runner_symbols_ok() {
  local mod_x="$1"
  local test_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-test-runner FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/test/test_glue.c|std/test/test.c|std/test/test.x) path="$test_x" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-test-runner FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      smoke|gate|script|file)
        if [ ! -f "$anchor" ]; then
          echo "std-test-runner FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        # Use TSV mod_path (archive DOC); do not hardcode top-level fossil path.
        local doc_path="${mod_path:-analysis/archive/std/std-test-runner-v1.md}"
        if ! grep -qF "$anchor" "$doc_path" 2>/dev/null; then
          echo "std-test-runner FAIL: missing section '$anchor' in $doc_path" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run .x smoke (legacy helper; gate prefers RUN_XLANG build).
# @param xlang compiler binary
# @param src .x smoke path
# @param tag temp exe tag
# @return 0 on exit 0 with expected report lines on stderr
std_test_runner_run_x_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-runner_smoke}"
  local exe="/tmp/xlang_std_test_runner_${tag}_$$"
  local err="/tmp/xlang_std_test_runner_${tag}_err_$$.log"
  if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-test-runner FAIL: compile $src" >&2
    "$xlang" -L . "$src" 2>&1 | tail -12 >&2 || true
    rm -f "$exe" "$err"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>"$err"
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    cat "$err" >&2 || true
    rm -f "$err"
    echo "std-test-runner FAIL: run exit=$ec" >&2
    return 1
  fi
  if ! grep -qF 'xlang: [XLANG_TEST] name=case_ok status=pass' "$err" 2>/dev/null; then
    cat "$err" >&2 || true
    rm -f "$err"
    echo "std-test-runner FAIL: missing pass line" >&2
    return 1
  fi
  if ! grep -qF 'xlang: [XLANG_TEST_SUMMARY] total=2 pass=1 fail=0 skip=1' "$err" 2>/dev/null; then
    cat "$err" >&2 || true
    rm -f "$err"
    echo "std-test-runner FAIL: missing summary" >&2
    return 1
  fi
  rm -f "$err"
  return 0
}

# Emit structured report line (honesty: check=/run=/skip=).
# @param status ok|fail
# @param check_ok 0|1 observational xlang check
# @param run_ok 0|1 hard runnable exit0 + report lines
# @param skip 0|1 residual skip bit (0 when runnable hard-green)
std_test_runner_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD145_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
