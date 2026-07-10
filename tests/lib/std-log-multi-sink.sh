#!/usr/bin/env bash
# std-log-multi-sink.sh — STD-053 manifest 与烟测辅助

STD_LOG_MULTI_SINK_PREFIX="${SHUX_STD_LOG_MULTI_SINK_PREFIX:-shux: [SHUX_STD_LOG_MULTI_SINK]}"

# 遍历 manifest TSV，校验 api/const/symbol/file/smoke。
std_log_multi_sink_symbols_ok() {
  local mod_x="$1"
  local log_x="$2"
  local log_glue="$3"
  local tsv="$4"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-log-multi-sink FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      const)
        if ! grep -qE "const ${anchor}:" "$mod_x" 2>/dev/null; then
          echo "std-log-multi-sink FAIL: missing const '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/log/log.c|std/log/log.x) path="$log_x" ;;
          std/log/log_os_glue.c|compiler/src/asm/runtime_log_os.inc) path="$log_glue" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-log-multi-sink FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-log-multi-sink FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .x 烟测。
std_log_multi_sink_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shux_std_log_ms_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-log-multi-sink FAIL: compile $src" >&2
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
    echo "std-log-multi-sink FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# C 烟测：multi_sink_ok.c + log.o + runtime_log_os.o。
std_log_multi_sink_run_c_smoke() {
  local log_impl="$1"
  local src="tests/std-log/multi_sink_ok.c"
  local out="/tmp/shux_std_log_multi_sink_$$"
  local log_o="std/log/log.o"
  local rt_o="compiler/runtime_log_os.o"
  if [ ! -f "$log_o" ]; then
    echo "std-log-multi-sink FAIL: missing $log_o" >&2
    return 1
  fi
  if [ ! -f "$rt_o" ]; then
    make -C compiler -q runtime_log_os.o 2>/dev/null || make -C compiler runtime_log_os.o >/dev/null 2>&1 || true
  fi
  if [ ! -f "$rt_o" ]; then
    echo "std-log-multi-sink FAIL: missing $rt_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$log_o" "$rt_o" 2>/dev/null; then
    echo "std-log-multi-sink FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-log-multi-sink FAIL: c smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出门禁报告行。
std_log_multi_sink_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  echo "${STD_LOG_MULTI_SINK_PREFIX} status=${status} c_smoke=${c_ok} x=${su_ok} skip=${skip}"
}
