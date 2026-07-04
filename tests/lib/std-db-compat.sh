#!/usr/bin/env bash
# std-db-compat.sh — STD-120 manifest 与烟测辅助

STD_DB_COMPAT_PREFIX="${SHUX_STD120_DB_COMPAT_PREFIX:-shux: [SHUX_STD120_DB_COMPAT]}"

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
        grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null || miss=$((miss + 1))
        ;;
      file|smoke|vectors|impl_readme)
        [ -f "$anchor" ] || miss=$((miss + 1))
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_db_compat_run_x_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_db_compat_$$"
  local log="/tmp/shux_std_db_compat_compile_$$.log"
  if ! "$shux" -L . "$src" -o "$exe" -l sqlite3 >"$log" 2>&1; then
    if ! "$shux" -L . "$src" -o "$exe" >"$log" 2>&1; then
      echo "std-db-compat FAIL: compile $src" >&2
      tail -12 "$log" >&2 || true
      rm -f "$log" "$exe"
      return 1
    fi
  fi
  rm -f "$log"
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-db-compat FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_db_compat_emit_report() {
  echo "${STD_DB_COMPAT_PREFIX} status=$1 x=$2 skip=$3"
}
