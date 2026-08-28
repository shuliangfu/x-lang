#!/usr/bin/env bash
# std-sqlite-gate.sh — STD-057 manifest helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_sqlite_symbols_ok MOD_X SQLITE_X TSV
#   std_sqlite_probe_libs
#   std_sqlite_run_c_smoke SQLITE_X   # prebuilt sqlite.o only
#   std_sqlite_run_smoke XLANG_BIN SRC TAG
#   std_sqlite_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / soft ensure; report run=/obs=/skip=.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).
# NOTE: STD-139 sqlite-stub sources this lib for probe / nm helpers; keep those stable.

# shellcheck source=compiler-make.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/compiler-make.sh"
STD_SQLITE_PREFIX="${XLANG_STD_SQLITE_PREFIX:-xlang: [XLANG_STD_SQLITE]}"

# Probe whether the host can link libsqlite3.
# PLATFORM: SHARED — Darwin Homebrew / Ubuntu libsqlite3-dev.
std_sqlite_probe_libs() {
  local out="/tmp/xlang_std_sqlite_probe_$$"
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

# Validate manifest; echo miss count; return 0 iff miss==0.
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
      section)
        local doc="${XLANG_STD_SQLITE_DOC:-analysis/archive/std/std-sqlite-v1.md}"
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-sqlite FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|cross_ref)
        if [ ! -f "$anchor" ]; then
          echo "std-sqlite FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ -n "$anchor" ] && [ -f "$anchor" ]; then
          :
        elif [ -n "$mod_path" ] && [ -f "$mod_path" ]; then
          :
        else
          echo "std-sqlite FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Whether sqlite.o already merged .x symbols (nm face).
# Kept for STD-139 sqlite-stub consumers.
std_sqlite_o_has_x_symbols() {
  local sqlite_o="$1"
  [ -f "$sqlite_o" ] && nm "$sqlite_o" 2>/dev/null | grep -q ' db_sqlite_exec_smoke_c'
}

# Host-C archaeology: prebuilt std/db/sqlite/sqlite.o only + -lsqlite3.
# Refuse soft xlang_compiler_make / soft ensure_std_c_o.
# Returns 0 green, 1 link/run fail, 2 missing prebuilt / missing lib / missing .x symbols.
# PLATFORM: SHARED — do not toggle set -e (leaks make return 1 kill the gate).
std_sqlite_run_c_smoke() {
  local sqlite_c="$1"
  local src="tests/std-sqlite/exec_roundtrip_ok.c"
  local out="/tmp/xlang_std_sqlite_$$"
  local sqlite_o
  sqlite_o="$(dirname "$sqlite_c")/sqlite.o"
  if ! std_sqlite_probe_libs; then
    echo "std-sqlite OBS c smoke (no libsqlite3; refuse soft SKIP→OK)" >&2
    return 2
  fi
  if [ ! -f "$sqlite_o" ]; then
    echo "std-sqlite OBS c smoke (missing prebuilt $sqlite_o; refuse soft auto-make)" >&2
    return 2
  fi
  if ! std_sqlite_o_has_x_symbols "$sqlite_o"; then
    echo "std-sqlite OBS c smoke (sqlite.o missing .x symbols; refuse soft rebuild)" >&2
    return 2
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$sqlite_o" -lsqlite3 2>/tmp/std_sqlite_c_$$.log; then
    echo "std-sqlite OBS c smoke link (refuse soft ensure)" >&2
    return 1
  fi
  # Do not restore set -e here: return 1 must not trip the gate's set +e window.
  # PLATFORM: SHARED — SEGV/exit≠0 is obs, not soft die.
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-sqlite OBS c smoke run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Product tip -o smoke. Caller decides hard vs obs (tip SEGV/UNDEF = obs leave).
# PLATFORM: SHARED archaeology — product honesty path.
std_sqlite_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-exec}"
  local exe="/tmp/xlang_std_sqlite_${tag}_$$"
  local log="/tmp/xlang_std_sqlite_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-sqlite FAIL: missing $src" >&2
    return 1
  fi
  rm -f "$exe" "$log"
  # Do not restore set -e between steps: return 1 must not trip the gate's set +e window.
  # PLATFORM: SHARED archaeology.
  set +e
  "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1
  local o_ec=$?
  if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    echo "std-sqlite OBS tip product -o (ec=$o_ec)" >&2
    tail -n 8 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-sqlite OBS tip run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired c_smoke=/x=).
std_sqlite_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_SQLITE_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
