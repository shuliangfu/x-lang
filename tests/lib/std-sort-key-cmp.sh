#!/usr/bin/env bash
# std-sort-key-cmp.sh — STD-150 manifest 与烟测辅助

STD150_PREFIX="${SHUX_STD150_SORT_KEY_CMP_PREFIX:-shux: [SHUX_STD150_SORT_KEY_CMP]}"

# 校验 manifest；echo 缺失数。
std_sort_key_cmp_symbols_ok() {
  local mod_su="$1"
  local sort_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api|struct)
        if ! grep -qE "(function ${anchor}\\(|struct ${anchor} )" "$mod_su" 2>/dev/null; then
          echo "std-sort-key-cmp FAIL: missing '$anchor' in $mod_su" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/sort/sort.c" ]; then path="$sort_c"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-sort-key-cmp FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|gate)
        if [ ! -f "$anchor" ]; then
          echo "std-sort-key-cmp FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ ! -f "$anchor" ]; then
          echo "std-sort-key-cmp FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "analysis/std-sort-key-cmp-v1.md" 2>/dev/null; then
          echo "std-sort-key-cmp FAIL: missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_sort_key_cmp_vectors_ok() {
  local tsv="$1"
  local min="${2:-3}"
  local n=0
  while IFS=$'\t' read -r use_case _rest; do
    [ -z "${use_case:-}" ] && continue
    case "$use_case" in \#*) continue ;; esac
    n=$((n + 1))
  done < "$tsv"
  if [ "$n" -lt "$min" ]; then
    echo "std-sort-key-cmp FAIL: vectors $n < min $min" >&2
    return 1
  fi
  return 0
}

std_sort_key_cmp_run_c_smoke() {
  local sort_c="$1"
  local src="tests/std-sort/key_cmp_ok.c"
  local out="/tmp/shux_sort_key_cmp_c_$$"
  local sort_o
  sort_o="$(dirname "$sort_c")/sort.o"
  if [ ! -f "$sort_o" ]; then
    echo "std-sort-key-cmp FAIL: missing $sort_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$sort_o" 2>/dev/null; then
    echo "std-sort-key-cmp FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-sort-key-cmp FAIL: C smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

std_sort_key_cmp_run_sx_smoke() {
  local shux="$1"
  local src="$2"
  local sort_o="$3"
  local exe="/tmp/shux_sort_key_cmp_su_$$"
  if ! "$shux" -L . "$src" -o "$exe" "$sort_o" >/dev/null 2>&1; then
    echo "std-sort-key-cmp FAIL: compile $src" >&2
    "$shux" -L . "$src" -o "$exe" "$sort_o" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-sort-key-cmp FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_sort_key_cmp_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  echo "${STD150_PREFIX} status=${status} c=${c_ok} su=${su_ok} skip=${skip}"
}
