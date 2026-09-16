#!/usr/bin/env bash
# std-sqlite-query-rows.sh — STD-066 query_rows / rows helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_sqlite_query_rows_source_sqlite
#   std_sqlite_query_rows_symbols_ok MOD_X SQLITE_X TSV
#   std_sqlite_query_rows_run_c_smoke SQLITE_X   # prebuilt sqlite.o only
#   std_sqlite_query_rows_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / soft ensure; report run=/obs=/skip=.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_DB_QUERY_ROWS_PREFIX="${XLANG_STD066_PREFIX:-xlang: [XLANG_STD066_DB_ROWS]}"

# Source STD-057 helpers (probe_libs / run_smoke / o_has_x_symbols).
std_sqlite_query_rows_source_sqlite() {
  # shellcheck source=tests/lib/std-sqlite-gate.sh
  . tests/lib/std-sqlite-gate.sh
}

# Validate manifest; echo miss count; return 0 iff miss==0.
std_sqlite_query_rows_symbols_ok() {
  local mod_x="$1"
  local db_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-sqlite-query-rows FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/db/sqlite/sqlite.x" ]; then path="$db_c"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-sqlite-query-rows FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        local doc="${XLANG_STD066_DOC:-analysis/archive/std/std-sqlite-query-rows-v1.md}"
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-sqlite-query-rows FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors|cross_ref)
        if [ ! -f "$anchor" ]; then
          echo "std-sqlite-query-rows FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ -n "$anchor" ] && [ -f "$anchor" ]; then
          :
        elif [ -n "$mod_path" ] && [ -f "$mod_path" ]; then
          :
        else
          echo "std-sqlite-query-rows FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Host-C archaeology: prebuilt std/db/sqlite/sqlite.o only + -lsqlite3.
# Refuse soft xlang_compiler_make / soft ensure_std_c_o / soft std_sqlite_build_o.
# Returns 0 green, 1 link/run fail, 2 missing prebuilt / lib / .x symbols.
# PLATFORM: SHARED — do not toggle set -e (leaks make return 1 kill the gate).
std_sqlite_query_rows_run_c_smoke() {
  local db_c="$1"
  local src="tests/std-sqlite/query_rows_roundtrip_ok.c"
  local out="/tmp/xlang_std_sqlite_query_rows_$$"
  local sqlite_o
  sqlite_o="$(dirname "$db_c")/sqlite.o"
  if ! std_sqlite_probe_libs; then
    echo "std-sqlite-query-rows OBS c smoke (no libsqlite3; refuse soft SKIP→OK)" >&2
    return 2
  fi
  if [ ! -f "$sqlite_o" ]; then
    echo "std-sqlite-query-rows OBS c smoke (missing prebuilt $sqlite_o; refuse soft auto-make)" >&2
    return 2
  fi
  if ! std_sqlite_o_has_x_symbols "$sqlite_o"; then
    echo "std-sqlite-query-rows OBS c smoke (sqlite.o missing .x symbols; refuse soft rebuild)" >&2
    return 2
  fi
  if ! nm "$sqlite_o" 2>/dev/null | grep -q ' db_sqlite_query_rows_smoke_c'; then
    echo "std-sqlite-query-rows OBS c smoke (sqlite.o missing query_rows smoke symbol; refuse soft rebuild)" >&2
    return 2
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$sqlite_o" -lsqlite3 2>/tmp/std_sqlite_query_rows_c_$$.log; then
    echo "std-sqlite-query-rows OBS c smoke link (refuse soft ensure)" >&2
    return 1
  fi
  # Do not restore set -e here: return 1 must not trip the gate's set +e window.
  # PLATFORM: SHARED — SEGV/exit≠0 is obs, not soft die.
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-sqlite-query-rows OBS c smoke run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired rows_c=/rows_x=).
std_sqlite_query_rows_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_DB_QUERY_ROWS_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
