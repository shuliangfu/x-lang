#!/usr/bin/env bash
# std-trace.sh — STD-088 manifest 与烟测辅助

STD_TRACE_PREFIX="${SHU_STD_TRACE_PREFIX:-shu: [SHU_STD_TRACE]}"

std_trace_symbols_ok() {
  local mod_su="$1"
  local trace_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-trace FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/trace/trace.c" ]; then path="$trace_c"; fi
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

std_trace_run_smoke() {
  local shu="$1"
  local src="$2"
  local tag="${3:-trace}"
  local exe="/tmp/shu_std_trace_${tag}_$$"
  if ! "$shu" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-trace FAIL: compile $src" >&2
    "$shu" -L . "$src" 2>&1 | tail -12 >&2 || true
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
  echo "${STD_TRACE_PREFIX} status=${status} c_smoke=${c_ok} su=${su_ok} skip=${skip}"
}
