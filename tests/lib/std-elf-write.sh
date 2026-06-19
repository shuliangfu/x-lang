#!/usr/bin/env bash
# std-elf-write.sh — STD-121 manifest 与烟测辅助

STD_ELF_WRITE_PREFIX="${SHUX_STD121_ELF_WRITE_PREFIX:-shux: [SHUX_STD121_ELF_WRITE]}"

std_elf_write_symbols_ok() {
  local mod_su="$1"
  local elf_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null || miss=$((miss + 1))
        ;;
      symbol)
        local path="$mod_path"
        [ "$path" = "std/elf/elf.c" ] && path="$elf_c"
        grep -qF "$anchor" "$path" 2>/dev/null || miss=$((miss + 1))
        ;;
      file|smoke|vectors)
        [ -f "$anchor" ] || miss=$((miss + 1))
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_elf_write_run_c_smoke() {
  local elf_o="$1"
  local out="/tmp/shux_std_elf_write_c_$$"
  cc -std=c11 -O1 -o "$out" tests/std-elf/write_smoke_ok.c "$elf_o" 2>/dev/null || return 1
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

std_elf_write_run_sx_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_elf_write_$$"
  "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1 || return 1
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  [ "$ec" -eq 0 ]
}

std_elf_write_emit_report() {
  echo "${STD_ELF_WRITE_PREFIX} status=$1 c=$2 su=$3 skip=$4"
}
