#!/usr/bin/env bash
# std-mem-safe.sh — STD-144 manifest 与烟测辅助

STD_MEM_SAFE_PREFIX="${SHU_STD144_MEM_SAFE_PREFIX:-shu: [SHU_STD144_MEM_SAFE]}"

# 校验 manifest；echo 缺失数。
std_mem_safe_symbols_ok() {
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
          echo "std-mem-safe FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      smoke|gate|script)
        if [ ! -f "$anchor" ]; then
          echo "std-mem-safe FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "analysis/std-mem-safe-v1.md" 2>/dev/null; then
          echo "std-mem-safe FAIL: missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 mem_safe_boundary 烟测。
std_mem_safe_run_smoke() {
  local shu="$1"
  local src="$2"
  local exe="/tmp/shu_std_mem_safe_$$"
  if ! "$shu" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-mem-safe FAIL: compile $src" >&2
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
    echo "std-mem-safe FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_mem_safe_emit_report() {
  local status="$1"
  local su_ok="$2"
  local skip="$3"
  echo "${STD_MEM_SAFE_PREFIX} status=${status} su=${su_ok} skip=${skip}"
}
