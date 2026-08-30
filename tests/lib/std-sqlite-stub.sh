#!/usr/bin/env bash
# std-sqlite-stub.sh — STD-139 manifest and stub smoke helpers (honesty).
# Honesty 2026-08-28: report run=/obs=/skip=; prefer asm; no soft rebuild.
# Honesty leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. Parent STD-139 already Honesty
# (resolve_shu / prefer-asm). leftover nested product path (manifest /
# stub_behavior -o / observational C stub) stay. Do not fork a third
# resolver here. PLATFORM: SHARED archaeology — Ubuntu gold still required.

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

# Restore product sqlite.o after sqlite-o-stub overwrite.
# Face-less stub (no std_db_sqlite_*) must be deleted so -L . rebuilds via
# formal_mod mod|1. Do NOT call ensure_std_c_o here when host lacks libsqlite3:
# it re-runs sqlite-o-stub and recreates a face-less object (Ubuntu gold UNDEF).
# PLATFORM: SHARED — Ubuntu without libsqlite3-dev is the gold stub path.
std_sqlite_stub_restore_product_o() {
  local sqlite_o="std/db/sqlite/sqlite.o"
  if [ -f "$sqlite_o" ]; then
    if ! nm "$sqlite_o" 2>/dev/null | grep -q 'std_db_sqlite_is_available'; then
      rm -f "$sqlite_o" std/db/sqlite/sqlite_main.o
    fi
  fi
}

# Run C stub smoke against an existing stub sqlite.o (no soft sqlite-o-stub make).
# Observational only. Always restores product sqlite.o before return.
# PLATFORM: SHARED archaeology — hard-green signal is .x stub_behavior.x.
std_sqlite_stub_run_c_smoke() {
  local db_c="$1"
  local src="tests/std-sqlite/stub_behavior_ok.c"
  local out="/tmp/xlang_std_sqlite_stub_$$"
  local sqlite_o
  sqlite_o="$(dirname "$db_c")/sqlite.o"
  # Refuse soft auto-make of sqlite-o-stub; only exercise an existing stub .o.
  if [ ! -f "$sqlite_o" ]; then
    echo "std-sqlite-stub OBS c smoke (missing stub sqlite.o; no soft rebuild)" >&2
    return 2
  fi
  if ! std_sqlite_o_has_x_symbols "$sqlite_o"; then
    echo "std-sqlite-stub OBS c smoke (sqlite.o missing .x symbols)" >&2
    std_sqlite_stub_restore_product_o
    return 2
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$sqlite_o" 2>/dev/null; then
    echo "std-sqlite-stub OBS c smoke (compile residual)" >&2
    std_sqlite_stub_restore_product_o
    return 2
  fi
  local ec=0
  "$out" >/dev/null 2>&1 || ec=$?
  rm -f "$out"
  std_sqlite_stub_restore_product_o
  if [ "$ec" -ne 0 ]; then
    echo "std-sqlite-stub OBS c smoke (run residual exit=$ec)" >&2
    return 2
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=).
# @param $1 status — ok|fail
# @param $2 run_ok — product stub_behavior.x hard green count
# @param $3 obs — check/C stub observational residuals
# @param $4 skip — 1 only for manifest-only
std_sqlite_stub_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_DB_STUB_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
