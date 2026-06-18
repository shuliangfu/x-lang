#!/usr/bin/env bash
# std-elf-phdr.sh — STD-064 manifest 与 phdr 烟测辅助

STD_ELF_PHDR_PREFIX="${SHU_STD064_PREFIX:-shu: [SHU_STD064_ELF_PHDR]}"

# 校验 manifest 中 api/const/symbol/file。
std_elf_phdr_symbols_ok() {
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
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-elf-phdr FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      const)
        if ! grep -qE "const ${anchor}:" "$mod_su" 2>/dev/null; then
          echo "std-elf-phdr FAIL: missing const '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/elf/elf.c" ]; then path="$elf_c"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-elf-phdr FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|fixture)
        if [ ! -f "$anchor" ]; then
          echo "std-elf-phdr FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# C phdr 烟测。
std_elf_phdr_run_c_smoke() {
  local elf_c="$1"
  local src="tests/std-elf/parse_phdr_smoke_ok.c"
  local out="/tmp/shu_std_elf_phdr_$$"
  local elf_o
  elf_o="$(dirname "$elf_c")/elf.o"
  if [ ! -f "$elf_o" ]; then
    echo "std-elf-phdr FAIL: missing $elf_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$elf_o" 2>/dev/null; then
    echo "std-elf-phdr FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-elf-phdr FAIL: c smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出门禁报告。
std_elf_phdr_emit_report() {
  local status="$1"
  local phdr_c="$2"
  local phdr_su="$3"
  local skip="$4"
  echo "${STD_ELF_PHDR_PREFIX} status=${status} phdr_c=${phdr_c} phdr_su=${phdr_su} skip=${skip}"
}
