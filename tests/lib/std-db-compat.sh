#!/usr/bin/env bash
# std-db-compat.sh — STD-120 std.db compat helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_db_compat_source_sqlite
#   std_db_compat_symbols_ok MOD_X TSV
#   std_db_compat_host_c_obs SQLITE_O
#   std_db_compat_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / soft ensure; report run=/obs=/skip=.
# Parent STD-057 helpers (run_smoke / probe_libs / o_has_x_symbols) are G.7
# authority — do not duplicate product -o or host-C rebuild.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_DB_COMPAT_PREFIX="${XLANG_STD120_DB_COMPAT_PREFIX:-xlang: [XLANG_STD120_DB_COMPAT]}"

# Source STD-057 helpers (run_smoke / probe_libs / o_has_x_symbols). G.7: do not fork.
std_db_compat_source_sqlite() {
  # shellcheck source=tests/lib/std-sqlite-gate.sh
  . tests/lib/std-sqlite-gate.sh
}

# Validate manifest; echo miss count; return 0 iff miss==0.
std_db_compat_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-db-compat FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        local doc="${XLANG_STD120_DOC:-analysis/archive/std/std-db-compat-v1.md}"
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-db-compat FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors|impl_readme)
        if [ ! -f "$anchor" ]; then
          echo "std-db-compat FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ -n "$anchor" ] && [ -f "$anchor" ]; then
          :
        elif [ -n "$mod_path" ] && [ -f "$mod_path" ]; then
          :
        else
          echo "std-db-compat FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref)
        if [ ! -f "$anchor" ]; then
          echo "std-db-compat FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Host-C archaeology: prebuilt std/db/sqlite/sqlite.o only (shared C impl).
# Refuse soft xlang_compiler_make / soft ensure_std_c_o / extra CLI .o.
# Returns 0 present, 2 missing prebuilt. Do not compile a new C harness (G.7).
# PLATFORM: SHARED — missing .o is obs, not soft SKIP→OK / soft rebuild.
std_db_compat_host_c_obs() {
  local sqlite_o="${1:-std/db/sqlite/sqlite.o}"
  if [ ! -f "$sqlite_o" ]; then
    echo "std-db-compat OBS host-C (missing prebuilt $sqlite_o; refuse soft auto-make)" >&2
    return 2
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired x=/skip= as hard).
std_db_compat_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_DB_COMPAT_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
