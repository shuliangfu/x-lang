#!/usr/bin/env bash
# std-sqlite-exec-deep.sh — STD-065 manifest 与事务 exec 烟测辅助

STD_DB_EXEC_DEEP_PREFIX="${SHU_STD065_PREFIX:-shu: [SHU_STD065_DB_EXEC]}"

# 复用 STD-057 SQLite 探测与编译。
# shellcheck source=tests/lib/std-sqlite-gate.sh
std_sqlite_exec_deep_source_sqlite() {
  . tests/lib/std-sqlite-gate.sh
}

# 遍历 manifest，校验 api/symbol/file/smoke。
std_sqlite_exec_deep_symbols_ok() {
  local mod_su="$1"
  local db_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-sqlite-exec-deep FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/sqlite/sqlite.c" ]; then path="$db_c"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-sqlite-exec-deep FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors|cross_ref)
        if [ "$kind" = "cross_ref" ]; then
          if [ ! -f "$anchor" ]; then
            echo "std-sqlite-exec-deep FAIL: missing '$anchor'" >&2
            miss=$((miss + 1))
          fi
        elif [ ! -f "$anchor" ]; then
          echo "std-sqlite-exec-deep FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# C 烟测：exec_tx_roundtrip_ok.c + sqlite.o + -lsqlite3。
std_sqlite_exec_deep_run_c_smoke() {
  local db_c="$1"
  local src="tests/std-sqlite/exec_tx_roundtrip_ok.c"
  local out="/tmp/shu_std_sqlite_exec_deep_$$"
  local db_o
  sqlite_o="$(dirname "$db_c")/sqlite.o"
  if [ ! -f "$sqlite_o" ]; then
    echo "std-sqlite-exec-deep FAIL: missing $sqlite_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$sqlite_o" -lsqlite3 2>/dev/null; then
    echo "std-sqlite-exec-deep FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-sqlite-exec-deep FAIL: c smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出门禁报告行。
std_sqlite_exec_deep_emit_report() {
  local status="$1"
  local tx_c="$2"
  local tx_su="$3"
  local skip="$4"
  echo "${STD_DB_EXEC_DEEP_PREFIX} status=${status} tx_c=${tx_c} tx_su=${tx_su} skip=${skip}"
}
