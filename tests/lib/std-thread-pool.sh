#!/usr/bin/env bash
# std-thread-pool.sh — STD-043 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_thread_pool_symbols_ok MOD_SU THREAD_C TSV
#   std_thread_pool_run_smoke SHU_BIN SU TAG
#   std_thread_pool_emit_report status pool_ok name_ok main_ok skip

STD_THREAD_POOL_PREFIX="${SHU_STD_THREAD_POOL_PREFIX:-shu: [SHU_STD_THREAD_POOL]}"

# 校验 manifest symbol/api；echo 缺失数。
std_thread_pool_symbols_ok() {
  local mod_su="$1"
  local thread_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-thread-pool FAIL: missing api '$anchor' in $mod_su" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        case "$mod_path" in
          std/thread/thread.c) mod_path="$thread_c" ;;
          *) mod_path="$mod_su" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-thread-pool FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-thread-pool FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行烟测 .su（须链 thread.o + -lpthread）。
std_thread_pool_run_smoke() {
  local shu="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shu_std_thread_pool_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-thread-pool FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shu" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-thread-pool FAIL: compile $src" >&2
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
    echo "std-thread-pool FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
std_thread_pool_emit_report() {
  local status="$1"
  local pool_ok="$2"
  local name_ok="$3"
  local main_ok="$4"
  local skip="$5"
  echo "${STD_THREAD_POOL_PREFIX} status=${status} pool=${pool_ok} name=${name_ok} main=${main_ok} skip=${skip}"
}
