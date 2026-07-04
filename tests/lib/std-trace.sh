#!/usr/bin/env bash
# std-trace.sh — STD-088 manifest 与烟测辅助（F-trace v2：纯 trace.x）

STD_TRACE_PREFIX="${SHUX_STD_TRACE_PREFIX:-shux: [SHUX_STD_TRACE]}"

# 遍历 manifest；symbol 在 trace.x。
std_trace_symbols_ok() {
  local mod_x="$1"
  local trace_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-trace FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/trace/trace.c|std/trace/trace.x|std/trace/trace_span_glue.c) path="$trace_x" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-trace FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors)
        if [ ! -f "$anchor" ]; then
          echo "std-trace FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# C 烟测：trace_smoke_ok.c + trace.o + time.o + random.o。
std_trace_run_c_smoke() {
  local trace_x="$1"
  local src="tests/std-trace/trace_smoke_ok.c"
  local out="/tmp/shux_std_trace_$$"
  local trace_o time_o random_o
  trace_o="$(dirname "$trace_x")/trace.o"
  time_o="std/time/time.o"
  random_o="std/random/random.o"
  if [ ! -f "$trace_o" ]; then
    echo "std-trace FAIL: missing $trace_o" >&2
    return 1
  fi
  if [ ! -f "$time_o" ]; then
    make -C compiler ../std/time/time.o >/dev/null 2>&1 || true
  fi
  if [ ! -f "$random_o" ]; then
    make -C compiler ../std/random/random.o >/dev/null 2>&1 || true
  fi
  make -C compiler runtime_time_os.o runtime_random_fill.o >/dev/null 2>&1 || true
  if ! cc -std=c11 -O1 -o "$out" "$src" "$trace_o" "$time_o" compiler/runtime_time_os.o "$random_o" compiler/runtime_random_fill.o 2>/dev/null; then
    echo "std-trace FAIL: compile c smoke" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-trace FAIL: c smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

std_trace_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-trace}"
  local exe="/tmp/shux_std_trace_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-trace FAIL: compile $src" >&2
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
    echo "std-trace FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_trace_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  echo "${STD_TRACE_PREFIX} status=${status} c_smoke=${c_ok} x=${su_ok} skip=${skip}"
}
