#!/usr/bin/env bash
# std-base64-stream.sh — STD-109 manifest 与烟测辅助

STD_BASE64_STREAM_PREFIX="${SHU_STD109_BASE64_STREAM_PREFIX:-shu: [SHU_STD109_BASE64_STREAM]}"

# 校验 manifest 中 api/symbol/file。
std_base64_stream_symbols_ok() {
  local mod_su="$1"
  local b64_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-base64-stream FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/base64/base64.c" ]; then path="$b64_c"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-base64-stream FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-base64-stream FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .su 烟测。
std_base64_stream_run_su_smoke() {
  local shu="$1"
  local src="$2"
  local tag="${3:-stream}"
  local exe="/tmp/shu_std_b64_stream_${tag}_$$"
  if ! "$shu" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-base64-stream FAIL: compile $src" >&2
    "$shu" -L . "$src" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-base64-stream FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# C 烟测：stream_smoke_ok.c + base64.o。
std_base64_stream_run_c_smoke() {
  local b64_c="$1"
  local src="tests/std-base64/stream_smoke_ok.c"
  local out="/tmp/shu_std_base64_stream_$$"
  local b64_o
  b64_o="$(dirname "$b64_c")/base64.o"
  if [ ! -f "$b64_o" ]; then
    echo "std-base64-stream FAIL: missing $b64_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$b64_o" 2>/dev/null; then
    echo "std-base64-stream FAIL: compile C smoke" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-base64-stream FAIL: C smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
std_base64_stream_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  echo "${STD_BASE64_STREAM_PREFIX} status=${status} c=${c_ok} su=${su_ok} skip=${skip}"
}
