#!/usr/bin/env bash
# std-sqlite-pool.sh — STD-084 manifest 与 pool 烟测辅助

STD_DB_POOL_PREFIX="${SHUX_STD084_PREFIX:-shux: [SHUX_STD084_DB_POOL]}"

std_sqlite_pool_source_sqlite() {
  # shellcheck source=tests/lib/std-sqlite-gate.sh
  . tests/lib/std-sqlite-gate.sh
}

std_sqlite_pool_symbols_ok() {
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
          echo "std-sqlite-pool FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/db/sqlite/sqlite.sx" ]; then path="$db_c"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-sqlite-pool FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors|cross_ref)
        if [ "$kind" = "cross_ref" ]; then
          if [ ! -f "$anchor" ]; then
            echo "std-sqlite-pool FAIL: missing '$anchor'" >&2
            miss=$((miss + 1))
          fi
        elif [ ! -f "$anchor" ]; then
          echo "std-sqlite-pool FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_sqlite_pool_run_c_smoke() {
  local db_c="$1"
  local src="tests/std-sqlite/pool_roundtrip_ok.c"
  local out="/tmp/shux_std_sqlite_pool_$$"
  local sqlite_o
  sqlite_o="$(dirname "$db_c")/sqlite.o"
  if [ ! -f "$sqlite_o" ]; then
    echo "std-sqlite-pool FAIL: missing $sqlite_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$sqlite_o" -lsqlite3 2>/dev/null; then
    echo "std-sqlite-pool FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-sqlite-pool FAIL: c smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

std_sqlite_pool_emit_report() {
  local status="$1"
  local pool_c="$2"
  local pool_sx="$3"
  local skip="$4"
  echo "${STD_DB_POOL_PREFIX} status=${status} pool_c=${pool_c} pool_sx=${pool_sx} skip=${skip}"
}
