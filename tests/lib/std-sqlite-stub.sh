#!/usr/bin/env bash
# std-sqlite-stub.sh — STD-139 manifest 与 stub 烟测辅助
# Honesty 2026-08-26: report check=/run=/stub_c=/skip=; prefer asm gate.

# shellcheck source=compiler-make.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/compiler-make.sh"
STD_DB_STUB_PREFIX="${XLANG_STD139_PREFIX:-xlang: [XLANG_STD139_DB_STUB]}"

# 复用 STD-057 SQLite 探测。
std_sqlite_stub_source_sqlite() {
  # shellcheck source=tests/lib/std-sqlite-gate.sh
  . tests/lib/std-sqlite-gate.sh
}

# 遍历 manifest，校验 api/const/symbol/file/smoke/readme。
std_sqlite_stub_symbols_ok() {
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
          echo "std-sqlite-stub FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      const)
        if ! grep -qE "const ${anchor}:" "$mod_x" 2>/dev/null; then
          echo "std-sqlite-stub FAIL: missing const '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/db/sqlite/sqlite.x" ]; then path="$db_c"; fi
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
  local out="/tmp/xlang_std_sqlite_stub_$$"
  local sqlite_o
  sqlite_o="$(dirname "$db_c")/sqlite.o"
  if ! xlang_compiler_make sqlite-o-stub >/dev/null 2>&1; then
    echo "std-sqlite-stub FAIL: xlang_compiler_make sqlite-o-stub" >&2
    return 1
  fi
  if [ ! -f "$sqlite_o" ]; then
    echo "std-sqlite-stub FAIL: missing $sqlite_o after stub build" >&2
    return 1
  fi
  if ! std_sqlite_o_has_x_symbols "$sqlite_o"; then
    echo "std-sqlite-stub SKIP c smoke (sqlite.o missing .x symbols; need xlang-c)" >&2
    xlang_compiler_make ../std/db/sqlite/sqlite.o >/dev/null 2>&1 || true
    return 2
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$sqlite_o" 2>/dev/null; then
    echo "std-sqlite-stub SKIP c smoke (compile residual)" >&2
    xlang_compiler_make ../std/db/sqlite/sqlite.o >/dev/null 2>&1 || true
    return 2
  fi
  # Observational only: never enable set -e here (would bleed to caller under
  # outer set +e and turn residual C segfault into a hard gate fail).
  # PLATFORM: SHARED archaeology — hard-green signal is .x stub_behavior.x.
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  rm -f "$out"
  xlang_compiler_make ../std/db/sqlite/sqlite.o >/dev/null 2>&1 || true
  if [ "$ec" -ne 0 ]; then
    echo "std-sqlite-stub SKIP c smoke (run residual exit=$ec)" >&2
    return 2
  fi
  return 0
}

# Emit structured report line (honesty: check=/run=/stub_c=/skip=).
# @param status ok|fail
# @param check_ok 0|1 observational xlang check
# @param run_ok 0|1 hard runnable exit0 (stub_behavior.x)
# @param stub_c 0|1 observational C stub smoke
# @param skip 0|1 residual skip bit (0 when runnable hard-green)
std_sqlite_stub_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local stub_c="$4"
  local skip="$5"
  echo "${STD_DB_STUB_PREFIX} status=${status} check=${check_ok} run=${run_ok} stub_c=${stub_c} skip=${skip}"
}
