#!/usr/bin/env bash
# std-process-xplat.sh — STD-142 manifest 与烟测辅助

STD_PROC_XPLAT_PREFIX="${SHUX_STD142_PROCESS_XPLAT_PREFIX:-shux: [SHUX_STD142_PROCESS_XPLAT]}"

# 校验 manifest 锚点；echo 缺失数。
std_process_xplat_symbols_ok() {
  local mod_su="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-process-xplat FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      smoke|gate)
        if [ ! -f "$anchor" ]; then
          echo "std-process-xplat FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|script)
        if [ ! -f "$anchor" ]; then
          echo "std-process-xplat FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "analysis/std-process-xplat-v1.md" 2>/dev/null; then
          echo "std-process-xplat FAIL: missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 校验向量 TSV 最少行数。
std_process_xplat_vectors_ok() {
  local tsv="$1"
  local min_rows="${2:-10}"
  local n=0
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ''|\#*) continue ;;
      min_*) continue ;;
    esac
    n=$((n + 1))
  done < "$tsv"
  if [ "$n" -lt "$min_rows" ]; then
    echo "std-process-xplat FAIL: vectors $n < min $min_rows" >&2
    return 1
  fi
  return 0
}

# 编译并运行烟测 .sx。
std_process_xplat_run_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_proc_xplat_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-process-xplat FAIL: compile $src" >&2
    "$shux" -L . "$src" -o "$exe" 2>&1 | tail -12 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-process-xplat FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_process_xplat_emit_report() {
  local status="$1"
  local su_ok="$2"
  local skip="$3"
  echo "${STD_PROC_XPLAT_PREFIX} status=${status} su=${su_ok} skip=${skip}"
}
