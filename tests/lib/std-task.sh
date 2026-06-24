#!/usr/bin/env bash
# std-task.sh — STD-089 manifest 与烟测辅助（F-task v2：纯 task.sx）

STD_TASK_PREFIX="${SHUX_STD_TASK_PREFIX:-shux: [SHUX_STD_TASK]}"

# 校验 manifest；symbol 在 task.sx。
std_task_symbols_ok() {
  local mod_sx="$1"
  local task_sx="$2"
  local task_glue="$3"
  local tsv="$4"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null; then
          echo "std-task FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/task/task.c|std/task/task_async_glue.c) path="$task_sx" ;;
          std/task/task.sx) path="$task_sx" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-task FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors)
        if [ ! -f "$anchor" ]; then
          echo "std-task FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# C 烟测：task_smoke_ok.c + task.o + deps。
std_task_run_c_smoke() {
  local _task_glue_unused="$1"
  local src="tests/std-task/task_smoke_ok.c"
  local out="/tmp/shux_std_task_c_$$"
  local task_o
  task_o="$(dirname "$_task_glue_unused")/task.o"
  if [ ! -f "$task_o" ]; then
    echo "std-task FAIL: missing $task_o" >&2
    return 1
  fi
  make -C compiler runtime_time_os.o >/dev/null 2>&1 || true
  if ! cc -std=c11 -O1 -o "$out" "$src" "$task_o" std/async/scheduler.o std/context/context.o std/time/time.o compiler/runtime_time_os.o 2>/dev/null; then
    echo "std-task FAIL: compile c smoke" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-task FAIL: c smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

std_task_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-task}"
  local exe="/tmp/shux_std_task_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-task FAIL: compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -12 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-task FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_task_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  echo "${STD_TASK_PREFIX} status=${status} c_smoke=${c_ok} sx=${su_ok} skip=${skip}"
}
