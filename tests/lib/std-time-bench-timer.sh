#!/usr/bin/env bash
# std-time-bench-timer.sh — STD-133 manifest 与烟测辅助

STD_TIME_BENCH_TIMER_PREFIX="${SHUX_STD133_TIME_BENCH_TIMER_PREFIX:-shux: [SHUX_STD133_TIME_BENCH_TIMER]}"

# 校验 manifest 条目；echo 缺失数。
std_time_bench_timer_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path _notes
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}" "$mod_x" 2>/dev/null; then
          echo "std-time-bench-timer FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      struct_timer)
        if ! grep -qE "struct ${anchor}" "$mod_x" 2>/dev/null; then
          echo "std-time-bench-timer FAIL: missing struct '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-time-bench-timer FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .x 烟测。
std_time_bench_timer_run_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_time_bench_$$"
  if ! "$shux" -L . "$src" -o "$exe" 2>&1; then
    echo "std-time-bench-timer FAIL: compile $src" >&2
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-time-bench-timer FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出 gate 报告。
std_time_bench_timer_emit_report() {
  echo "${STD_TIME_BENCH_TIMER_PREFIX} status=$1 x=$2 skip=$3"
}
