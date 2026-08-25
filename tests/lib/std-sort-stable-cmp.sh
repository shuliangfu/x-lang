#!/usr/bin/env bash
# std-sort-stable-cmp.sh — STD-060 manifest helpers (sort stable/cmp).
#
# Usage (after source):
#   std_sort_stable_cmp_symbols_ok MOD_X SORT_X TSV [DOC]
#   std_sort_stable_cmp_run_c_smoke SORT_X   # observational host-C archaeology only
#   std_sort_stable_cmp_run_smoke XLANG SRC TAG
#   std_sort_stable_cmp_emit_report status check_ok run_ok skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_SORT_STABLE_CMP_PREFIX="${XLANG_STD_SORT_STABLE_CMP_PREFIX:-xlang: [XLANG_STD_SORT_STABLE_CMP]}"

# Validate manifest api/symbol/file/smoke/section/absent anchors.
# Echo miss count; return 0 when miss=0.
# Optional DOC overrides archive path for section checks (default archived RFC).
std_sort_stable_cmp_symbols_ok() {
  local mod_x="$1"
  local sort_x="$2"
  local tsv="$3"
  local doc="${4:-analysis/archive/std/std-sort-stable-cmp-v1.md}"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-sort-stable-cmp FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ -z "$path" ] || [ "$path" = "std/sort/sort.c" ] || [ "$path" = "std/sort/sort.x" ]; then
          path="$sort_x"
        fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-sort-stable-cmp FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      absent)
        if [ -f "$anchor" ]; then
          echo "std-sort-stable-cmp FAIL: should not exist '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|gate|script)
        if [ ! -f "$anchor" ]; then
          # script anchors may be basename-relative under tests/
          if [ ! -f "tests/$anchor" ] && [ ! -f "$mod_path" ]; then
            echo "std-sort-stable-cmp FAIL: missing '$anchor'" >&2
            miss=$((miss + 1))
          fi
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-sort-stable-cmp FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Observational C smoke: sort.o + stable_smoke_ok.c (host-C archaeology; not hard green).
# PLATFORM: SHARED archaeology — product honesty is stable_i32.x / cmp_desc.x via prefer-asm.
std_sort_stable_cmp_run_c_smoke() {
  local sort_x="$1"
  local src="tests/std-sort/stable_smoke_ok.c"
  local out="/tmp/xlang_std_sort_stable_c_$$"
  local sort_o
  sort_o="$(dirname "$sort_x")/sort.o"
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
    echo "std-sort-stable-cmp FAIL: C smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# .x smoke via resolved compiler (prefer build path from caller).
std_sort_stable_cmp_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-sort}"
  local exe="/tmp/xlang_std_sort_${tag}_$$"
  if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-sort-stable-cmp FAIL: compile $src" >&2
    "$xlang" -L . "$src" 2>&1 | tail -10 >&2 || true
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

# Structured report line (check observational; run hard; skip only when no binary path).
std_sort_stable_cmp_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_SORT_STABLE_CMP_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
