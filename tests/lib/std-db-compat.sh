#!/usr/bin/env bash
# std-db-compat.sh — STD-120 manifest 与烟测辅助

STD_DB_COMPAT_PREFIX="${SHUX_STD120_DB_COMPAT_PREFIX:-shux: [SHUX_STD120_DB_COMPAT]}"

std_db_compat_symbols_ok() {
  local mod_su="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null || miss=$((miss + 1))
        ;;
      file|smoke|vectors|impl_readme)
        [ -f "$anchor" ] || miss=$((miss + 1))
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_db_compat_run_sx_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_db_compat_$$"
  if ! "$shux" -L . "$src" -o "$exe" -l sqlite3 >/dev/null 2>&1; then
    if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
      return 1
    fi
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  [ "$ec" -eq 0 ]
}

std_db_compat_emit_report() {
  echo "${STD_DB_COMPAT_PREFIX} status=$1 su=$2 skip=$3"
}
