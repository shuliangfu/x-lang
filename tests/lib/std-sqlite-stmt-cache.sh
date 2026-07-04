#!/usr/bin/env bash
# std-sqlite-stmt-cache.sh — STD-070 manifest 与 bind 烟测辅助

STD_DB_STMT_PREFIX="${SHUX_STD070_PREFIX:-shux: [SHUX_STD070_DB_STMT]}"

# 复用 STD-057 SQLite 探测与编译。
std_sqlite_stmt_cache_source_sqlite() {
  # shellcheck source=tests/lib/std-sqlite-gate.sh
  . tests/lib/std-sqlite-gate.sh
}

# 遍历 manifest，校验 api/symbol/file/smoke。
std_sqlite_stmt_cache_symbols_ok() {
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
          echo "std-sqlite-stmt-cache FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/db/sqlite/sqlite.x" ]; then path="$db_c"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-sqlite-stmt-cache FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors|cross_ref)
        if [ "$kind" = "cross_ref" ]; then
          if [ ! -f "$anchor" ]; then
            echo "std-sqlite-stmt-cache FAIL: missing '$anchor'" >&2
            miss=$((miss + 1))
          fi
        elif [ ! -f "$anchor" ]; then
          echo "std-sqlite-stmt-cache FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# C 烟测：stmt_bind_roundtrip_ok.c + sqlite.o + -lsqlite3。
std_sqlite_stmt_cache_run_c_smoke() {
  local db_c="$1"
  local src="tests/std-sqlite/stmt_bind_roundtrip_ok.c"
  local out="/tmp/shux_std_sqlite_stmt_$$"
  local sqlite_o
  sqlite_o="$(dirname "$db_c")/sqlite.o"
  if [ ! -f "$sqlite_o" ]; then
    echo "std-sqlite-stmt-cache FAIL: missing $sqlite_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$sqlite_o" -lsqlite3 2>/dev/null; then
    echo "std-sqlite-stmt-cache FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-sqlite-stmt-cache FAIL: c smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出门禁报告行。
std_sqlite_stmt_cache_emit_report() {
  local status="$1"
  local bind_c="$2"
  local bind_x="$3"
  local skip="$4"
  echo "${STD_DB_STMT_PREFIX} status=${status} bind_c=${bind_c} bind_x=${bind_x} skip=${skip}"
}
