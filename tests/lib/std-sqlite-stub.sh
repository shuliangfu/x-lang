#!/usr/bin/env bash
# std-sqlite-stub.sh — STD-139 manifest 与 stub 烟测辅助

STD_DB_STUB_PREFIX="${SHUX_STD139_PREFIX:-shux: [SHUX_STD139_DB_STUB]}"

# 复用 STD-057 SQLite 探测。
std_sqlite_stub_source_sqlite() {
  # shellcheck source=tests/lib/std-sqlite-gate.sh
  . tests/lib/std-sqlite-gate.sh
}

# 遍历 manifest，校验 api/const/symbol/file/smoke/readme。
std_sqlite_stub_symbols_ok() {
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
          echo "std-sqlite-stub FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      const)
        if ! grep -qE "const ${anchor}:" "$mod_su" 2>/dev/null; then
          echo "std-sqlite-stub FAIL: missing const '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/db/sqlite/sqlite.c" ]; then path="$db_c"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-sqlite-stub FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      readme)
        if ! grep -qF "DB_NOT_IMPL" "$anchor" 2>/dev/null || ! grep -qF "sqlite-o-stub" "$anchor" 2>/dev/null; then
          echo "std-sqlite-stub FAIL: README missing stub section keywords" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|cross_ref)
        if [ "$kind" = "cross_ref" ]; then
          if [ ! -f "$anchor" ]; then
            echo "std-sqlite-stub FAIL: missing '$anchor'" >&2
            miss=$((miss + 1))
          fi
        elif [ ! -f "$anchor" ]; then
          echo "std-sqlite-stub FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 构建 stub sqlite.o 并运行 C 烟测（不链 libsqlite3）。
std_sqlite_stub_run_c_smoke() {
  local db_c="$1"
  local src="tests/std-sqlite/stub_behavior_ok.c"
  local out="/tmp/shux_std_sqlite_stub_$$"
  local sqlite_o
  sqlite_o="$(dirname "$db_c")/sqlite.o"
  if ! make -C compiler sqlite-o-stub >/dev/null 2>&1; then
    echo "std-sqlite-stub FAIL: make sqlite-o-stub" >&2
    return 1
  fi
  if [ ! -f "$sqlite_o" ]; then
    echo "std-sqlite-stub FAIL: missing $sqlite_o after stub build" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$sqlite_o" 2>/dev/null; then
    echo "std-sqlite-stub FAIL: compile $src (stub.o)" >&2
    make -C compiler ../std/db/sqlite/sqlite.o >/dev/null 2>&1 || true
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  make -C compiler ../std/db/sqlite/sqlite.o >/dev/null 2>&1 || true
  if [ "$ec" -ne 0 ]; then
    echo "std-sqlite-stub FAIL: c smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出门禁报告行。
std_sqlite_stub_emit_report() {
  local status="$1"
  local stub_c="$2"
  local stub_su="$3"
  local doc="$4"
  echo "${STD_DB_STUB_PREFIX} status=${status} stub_c=${stub_c} stub_su=${stub_su} doc=${doc}"
}
