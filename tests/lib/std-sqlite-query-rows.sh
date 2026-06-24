#!/usr/bin/env bash
# std-sqlite-query-rows.sh — STD-066 manifest 与 query_rows 烟测辅助

STD_DB_QUERY_ROWS_PREFIX="${SHUX_STD066_PREFIX:-shux: [SHUX_STD066_DB_ROWS]}"

# 复用 STD-057 SQLite 探测与编译。
std_sqlite_query_rows_source_sqlite() {
  # shellcheck source=tests/lib/std-sqlite-gate.sh
  . tests/lib/std-sqlite-gate.sh
}

# 遍历 manifest，校验 api/symbol/file/smoke。
std_sqlite_query_rows_symbols_ok() {
  local mod_sx="$1"
  local db_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null; then
          echo "std-sqlite-query-rows FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/db/sqlite/sqlite.sx" ]; then path="$db_c"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-sqlite-query-rows FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors|cross_ref)
        if [ "$kind" = "cross_ref" ]; then
          if [ ! -f "$anchor" ]; then
            echo "std-sqlite-query-rows FAIL: missing '$anchor'" >&2
            miss=$((miss + 1))
          fi
        elif [ ! -f "$anchor" ]; then
          echo "std-sqlite-query-rows FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# C 烟测：query_rows_roundtrip_ok.c + sqlite.o + -lsqlite3。
std_sqlite_query_rows_run_c_smoke() {
  local db_c="$1"
  local src="tests/std-sqlite/query_rows_roundtrip_ok.c"
  local out="/tmp/shux_std_sqlite_query_rows_$$"
  local db_o
  sqlite_o="$(dirname "$db_c")/sqlite.o"
  if [ ! -f "$sqlite_o" ]; then
    echo "std-sqlite-query-rows FAIL: missing $sqlite_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$sqlite_o" -lsqlite3 2>/dev/null; then
    echo "std-sqlite-query-rows FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-sqlite-query-rows FAIL: c smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出门禁报告行。
std_sqlite_query_rows_emit_report() {
  local status="$1"
  local rows_c="$2"
  local rows_sx="$3"
  local skip="$4"
  echo "${STD_DB_QUERY_ROWS_PREFIX} status=${status} rows_c=${rows_c} rows_sx=${rows_sx} skip=${skip}"
}
