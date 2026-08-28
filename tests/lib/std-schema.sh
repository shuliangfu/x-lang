#!/usr/bin/env bash
# std-schema.sh — STD-090 Schema decode helpers (JSON/CSV/column map).
#
# Usage (after source):
#   std_schema_symbols_ok MOD_X SCHEMA_X TSV
#   std_schema_run_smoke XLANG SRC [TAG]
#   std_schema_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_SCHEMA_PREFIX="${XLANG_STD_SCHEMA_PREFIX:-xlang: [XLANG_STD_SCHEMA]}"

# Validate manifest api/symbol/file/smoke/vectors anchors.
# Echo miss count; return 0 when miss=0.
std_schema_symbols_ok() {
  local mod_x="$1"
  local schema_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-schema FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/schema/schema_glue.c" ]; then path="$schema_x"; fi
        if [ "$path" = "std/schema/schema.x" ]; then path="$schema_x"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-schema FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors)
        if [ ! -f "$anchor" ]; then
          echo "std-schema FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run .x decode smoke.
# Prefer callers pin XLANG_LINK_XLANG to product asm before invoke.
# Tip product UNDEF for std_schema_* is gate-obs (not this helper's soft OK).
std_schema_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-schema}"
  local exe="/tmp/xlang_std_schema_${tag}_$$"
  if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-schema FAIL: compile $src" >&2
    "$xlang" -L . "$src" -o "$exe" 2>&1 | tail -12 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-schema FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; check / tip UNDEF / host-C = obs).
std_schema_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_SCHEMA_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
