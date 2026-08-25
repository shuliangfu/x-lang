#!/usr/bin/env bash
# std-sort-key-cmp.sh — STD-150 manifest helpers (sort key comparator).
#
# Usage (after source):
#   std_sort_key_cmp_symbols_ok MOD_X SORT_X TSV [DOC]
#   std_sort_key_cmp_vectors_ok TSV [min]
#   std_sort_key_cmp_run_c_smoke SORT_X   # observational host-C archaeology only
#   std_sort_key_cmp_emit_report status check_ok run_ok skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD150_PREFIX="${XLANG_STD150_SORT_KEY_CMP_PREFIX:-xlang: [XLANG_STD150_SORT_KEY_CMP]}"

# Validate manifest api/struct/symbol/file/smoke/section anchors.
# Echo miss count; return 0 when miss=0.
# Optional DOC overrides archive path for section checks (default archived RFC).
std_sort_key_cmp_symbols_ok() {
  local mod_x="$1"
  local sort_x="$2"
  local tsv="$3"
  local doc="${4:-analysis/archive/std/std-sort-key-cmp-v1.md}"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api|struct)
        if ! grep -qE "(function ${anchor}\\(|struct ${anchor} )" "$mod_x" 2>/dev/null; then
          echo "std-sort-key-cmp FAIL: missing '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ -z "$path" ] || [ "$path" = "std/sort/sort.c" ] || [ "$path" = "std/sort/sort.x" ]; then
          path="$sort_x"
        fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-sort-key-cmp FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      absent)
        if [ -f "$anchor" ]; then
          echo "std-sort-key-cmp FAIL: should not exist '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|gate|script)
        if [ ! -f "$anchor" ]; then
          echo "std-sort-key-cmp FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-sort-key-cmp FAIL: missing section '$anchor' in $doc" >&2
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

# Observational C smoke: sort.o + key_cmp_ok.c (host-C archaeology; not hard green).
# PLATFORM: SHARED archaeology — product honesty is key_stable.x via prefer-asm.
std_sort_key_cmp_run_c_smoke() {
  local sort_x="$1"
  local src="tests/std-sort/key_cmp_ok.c"
  local out="/tmp/xlang_sort_key_cmp_c_$$"
  local sort_o
  sort_o="$(dirname "$sort_x")/sort.o"
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

# Structured report line (check observational; run hard; skip only when no binary path).
std_sort_key_cmp_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD150_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
