#!/usr/bin/env bash
# std-cache.sh — STD-087 manifest 与烟测辅助

STD_CACHE_PREFIX="${SHUX_STD_CACHE_PREFIX:-shux: [SHUX_STD_CACHE]}"

std_cache_symbols_ok() {
  local mod_sx="$1"
  local cache_sx="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null; then
          echo "std-cache FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/cache/cache_glue.c" ]; then path="$cache_sx"; fi
        if [ "$path" = "std/cache/cache.sx" ]; then path="$cache_sx"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-cache FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors)
        if [ ! -f "$anchor" ]; then
          echo "std-cache FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_cache_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-cache}"
  local exe="/tmp/shux_std_cache_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-cache FAIL: compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -12 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-cache FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_cache_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  echo "${STD_CACHE_PREFIX} status=${status} c_smoke=${c_ok} sx=${su_ok} skip=${skip}"
}
