#!/usr/bin/env bash
# std-sqlite-gate.sh — STD-057 manifest 与 SQLite 烟测辅助

STD_SQLITE_PREFIX="${SHUX_STD_SQLITE_PREFIX:-shux: [SHUX_STD_SQLITE]}"

# 探测本机是否可链 libsqlite3。
std_sqlite_probe_libs() {
  local out="/tmp/shux_std_sqlite_probe_$$"
  if ! cc -std=c11 -x c - -lsqlite3 -o "$out" 2>/dev/null <<'EOF'
#include <sqlite3.h>
int main(void) { return sqlite3_libversion() ? 0 : 1; }
EOF
  then
    rm -f "$out"
    return 1
  fi
  rm -f "$out"
  return 0
}

# 确保 sqlite.o 已构建（默认 SQLite3）。
std_sqlite_build_o() {
  if ! make -C compiler ../std/db/sqlite/sqlite.o >/dev/null 2>&1; then
    echo "std-sqlite FAIL: make ../std/db/sqlite/sqlite.o" >&2
    return 1
  fi
  return 0
}

# 恢复默认 SQLite3 sqlite.o。
std_sqlite_restore_default_o() {
  make -C compiler ../std/db/sqlite/sqlite.o >/dev/null 2>&1 || true
}

# 遍历 manifest TSV，校验 api/const/symbol/file/smoke。
std_sqlite_symbols_ok() {
  local mod_x="$1"
  local sqlite_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-sqlite FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      const)
        if ! grep -qE "const ${anchor}:" "$mod_x" 2>/dev/null; then
          echo "std-sqlite FAIL: missing const '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/db/sqlite/sqlite.x" ]; then path="$sqlite_c"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-sqlite FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|cross_ref)
        if [ "$kind" = "cross_ref" ]; then
          if [ ! -f "$anchor" ]; then
            echo "std-sqlite FAIL: missing '$anchor'" >&2
            miss=$((miss + 1))
          fi
        elif [ ! -f "$anchor" ]; then
          echo "std-sqlite FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# sqlite.o 是否已合并 .x 符号（无 shux-c 时仅含 glue）。
std_sqlite_o_has_x_symbols() {
  local sqlite_o="$1"
  [ -f "$sqlite_o" ] && nm "$sqlite_o" 2>/dev/null | grep -q ' db_sqlite_exec_smoke_c'
}

# C 烟测：exec_roundtrip_ok.c + sqlite.o + -lsqlite3。
std_sqlite_run_c_smoke() {
  local sqlite_c="$1"
  local src="tests/std-sqlite/exec_roundtrip_ok.c"
  local out="/tmp/shux_std_sqlite_$$"
  local sqlite_o
  sqlite_o="$(dirname "$sqlite_c")/sqlite.o"
  if [ ! -f "$sqlite_o" ]; then
    echo "std-sqlite FAIL: missing $sqlite_o" >&2
    return 1
  fi
  if ! std_sqlite_o_has_x_symbols "$sqlite_o"; then
    echo "std-sqlite SKIP c smoke (sqlite.o missing .x symbols; need shux-c)" >&2
    return 2
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$sqlite_o" -lsqlite3 2>/dev/null; then
    echo "std-sqlite FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-sqlite FAIL: c smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# 编译并运行 .x 烟测。
std_sqlite_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-exec}"
  local exe="/tmp/shux_std_sqlite_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-sqlite FAIL: compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-sqlite FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出门禁报告行。
std_sqlite_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  echo "${STD_SQLITE_PREFIX} status=${status} c_smoke=${c_ok} x=${su_ok} skip=${skip}"
}
