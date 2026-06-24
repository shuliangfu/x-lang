#!/usr/bin/env bash
# std-fs-dirmeta.sh — STD-123 manifest 与烟测辅助

STD_FS_DIRMETA_PREFIX="${SHUX_STD123_FS_DIRMETA_PREFIX:-shux: [SHUX_STD123_FS_DIRMETA]}"

# 校验 manifest api/symbol/smoke；echo 缺失数。
std_fs_dirmeta_symbols_ok() {
  local mod_sx="$1"
  local fs_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null || miss=$((miss + 1))
        ;;
      symbol)
        local path="$mod_path"
        [ "$path" = "std/fs/fs_posix.sx" ] && path="$fs_c"
        grep -qF "$anchor" "$path" 2>/dev/null || miss=$((miss + 1))
        ;;
      file|smoke)
        [ -f "$anchor" ] || miss=$((miss + 1))
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# C 烟测：mkdir/stat/rmdir。
std_fs_dirmeta_run_c_smoke() {
  local fs_o="$1"
  local out="/tmp/shux_std_fs_dirmeta_c_$$"
  cc -std=c11 -O1 -o "$out" tests/fs/dirmeta_smoke_ok.c "$fs_o" 2>/dev/null || return 1
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

# .sx 烟测。
std_fs_dirmeta_run_sx_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_fs_dirmeta_sx_$$"
  "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1 || return 1
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  [ "$ec" -eq 0 ]
}

std_fs_dirmeta_emit_report() {
  echo "${STD_FS_DIRMETA_PREFIX} status=$1 c=$2 sx=$3 skip=$4"
}
