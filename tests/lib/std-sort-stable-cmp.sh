#!/usr/bin/env bash
# std-sort-stable-cmp.sh — STD-060 manifest 与烟测辅助

STD_SORT_STABLE_CMP_PREFIX="${SHU_STD_SORT_STABLE_CMP_PREFIX:-shu: [SHU_STD_SORT_STABLE_CMP]}"

# 遍历 manifest TSV，校验 api/symbol/file/smoke。
std_sort_stable_cmp_symbols_ok() {
  local mod_su="$1"
  local sort_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-sort-stable-cmp FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/sort/sort.c" ]; then path="$sort_c"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-sort-stable-cmp FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-sort-stable-cmp FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# C 烟测。
std_sort_stable_cmp_run_c_smoke() {
  local sort_c="$1"
  local src="tests/std-sort/stable_smoke_ok.c"
  local out="/tmp/shu_std_sort_stable_$$"
  local sort_o
  sort_o="$(dirname "$sort_c")/sort.o"
  if [ ! -f "$sort_o" ]; then
    echo "std-sort-stable-cmp FAIL: missing $sort_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$sort_o" 2>/dev/null; then
    echo "std-sort-stable-cmp FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-sort-stable-cmp FAIL: c smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# .su 烟测。
std_sort_stable_cmp_run_smoke() {
  local shu="$1"
  local src="$2"
  local tag="${3:-sort}"
  local exe="/tmp/shu_std_sort_${tag}_$$"
  if ! "$shu" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-sort-stable-cmp FAIL: compile $src" >&2
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
    echo "std-sort-stable-cmp FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出门禁报告。
std_sort_stable_cmp_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  echo "${STD_SORT_STABLE_CMP_PREFIX} status=${status} c_smoke=${c_ok} su=${su_ok} skip=${skip}"
}
